-- SecureHandlers.lua (Part of the new Secure Headers implementation)
--
-- Lua code to support the various handlers and templates which can execute
-- code in a secure, but restricted, environment.
--
-- Daniel Stephens (iriel@vigilance-committee.org)
-- Nevin Flanagan (alestane@comcast.net)
---------------------------------------------------------------------------

local issecure = issecure;
local GetFrameHandle = GetFrameHandle;
local CallRestrictedClosure = CallRestrictedClosure;
local securecall = securecall;
local InCombatLockdown = InCombatLockdown;

---------------------------------------------------------------------------

local RestrictedTable_create = rtable.newtable;
local function ManagedEnvironmentsIndex(t, k)
    if (not issecure() or type(k) ~= "table") then
        error("Invalid access of managed environments table");
        return;
    end;

    local ownerHandle = GetFrameHandle(k);
    if (not ownerHandle) then
        error("Invalid access of managed environments table");
        return;
    end

    local e = RestrictedTable_create();
    e._G = e;
    e.owner = ownerHandle;
    t[k] = e;
    return e;
end

local _managed_environments = {};
setmetatable(_managed_environments,
             {
                 __index = ManagedEnvironmentsIndex,
                 __mode = "k",
             });

local rawget = rawget;
function GetManagedEnvironment(envKey)
    return rawget(_managed_environments, envKey);
end

---------------------------------------------------------------------------

local tostring = tostring;
local type = type;

local function SecureHandler_ChildExecute(self, environment, onupdate,
                                          bodyid, message, ...)
    local n = select('#', ...);
    if (n == 0) then return; end

    for i = 1, n do
        local child = select(i, ...);
        local _, p = child:IsProtected();
        if (p) then
            local body = child:GetAttribute(bodyid);
            if (body and type(body) == "string") then
                local selfHandle = GetFrameHandle(child);
                CallRestrictedClosure("self,message",
                                      environment, onupdate, body,
                                      selfHandle, message);
            end
        end
    end
end

local SecureHandler_OnUpdate;
local function SecureHandler_Execute(self, onupdate, signature, body, ...)
    local _, p = self:IsProtected();
    if (not p) then
        return;
    end

    local environment = _managed_environments[self];
    local selfHandle = GetFrameHandle(self);

    local childupdate, childmessage, animate =
        CallRestrictedClosure(signature, environment, onupdate,
                              body, selfHandle, ...);

    if (animate) then
        self:SetScript("OnUpdate", SecureHandler_OnUpdate);
    else
        self:SetScript("OnUpdate", nil);
    end
    if (not childupdate) then
        return;
    end
    local childmethod;
    if (childupdate == true) then
        childmethod = "_childupdate";
    else
        childmethod = "_childupdate-" .. tostring(childupdate);
    end

    SecureHandler_ChildExecute(self, environment, onupdate,
                               childmethod, childmessage,
                               self:GetChildren());
end

---------------------------------------------------------------------------
function SecureHandler_OnSimpleEvent(self, scriptid)
    local body = self:GetAttribute(scriptid);
    if (body and type(body) == "string") then
        SecureHandler_Execute(self, false,  "self", body);
    end
end

function SecureHandler_OnClick(self, button, down)
    local body = self:GetAttribute("_onclick");
    if (body and type(body) == "string") then
        SecureHandler_Execute(self, false, "self,button,down",
                              body, button, down);
    end
end

-- Locally bound above
function SecureHandler_OnUpdate(self, elapsed)
    local body = self:GetAttribute("_onupdate");
    if (body and type(body) == "string") then
        SecureHandler_Execute(self, true,
                              "self,elapsed", body, tonumber(elapsed));
    end
end

-- Safety function to not taint the header while storing old OnClick
local function SecureHandler_SafeSaveOnClick(frame)
    if (not frame._stateOnClick) then
        frame._stateOnClick = frame:GetScript("OnClick");
    end
end

-- Safety function to invoke the old saved OnClick if it exists
local function SecureHandler_SafeCallOnClick(frame, ...)
    local oldOnClick = frame._stateOnClick;
    if ( type(oldOnClick) == "function" ) then
        return oldOnClick(frame, ...);
    end
end

function SecureHandler_OnAttributeChanged(self, name, value)
    if (name == "_execute") then
        if (type(value) ~= "string") then
            return true;
        end
        self:SetAttribute(name, nil);
        SecureHandler_Execute(self, false, "self", value);
        return true;
    end

    if (name == "_adopt") then
        if (value == nil) then
            return true;
        end
        self:SetAttribute("_adopt", nil);
        if (type(value) ~= "table" or type(value[0]) ~= "userdata") then
            return true;
        end
        value:SetAttribute("_secureheader", self);
        if (value:HasScript("OnClick")) then
            -- This can lead to tainting the current execution so we use a
            -- secure function for the dirty work.
            securecall(SecureHandler_SafeSaveOnClick, value);
            value:SetScript("OnClick", SecureHandlerAdoptee_OnClick);
        end
        return true;
    end

    local frameid = name:match("^_frame%-(.+)");
    if (frameid) then
        if (value == nil) then
            return true;
        end
        local refid = "frameref-" .. frameid;
        local handle = nil;
        if (type(value) == "table" and type(value[0]) == "userdata") then
            handle = GetFrameHandle(value);
        end
        self:SetAttribute(refid, handle);
        self:SetAttribute(name, nil);
        return true;
    end
end


function SecureHandler_StateOnAttributeChanged(self, name, value)
    if (SecureHandler_OnAttributeChanged(self, name, value)) then
        return;
    end

    local stateid = name:match("^state%-(.+)");
    if (stateid) then
        local body = self:GetAttribute("_onstate-" .. stateid);
        if (body and type(body) == "string") then
            SecureHandler_Execute(self, false, "self,stateid,newstate",
                                  body, stateid, value);
        end
        return;
    end
end

local function SecureHandler_Button_Execute(header, button, signature, body, ...)
    local _, hp = header:IsProtected();
    if ((not hp)
        or (InCombatLockdown() and not button:IsProtected())) then
        return;
    end

    local environment = _managed_environments[header];
    local selfHandle = GetFrameHandle(button);
    local newbutton, updatelater =
        CallRestrictedClosure(signature, environment, false,
                              body, selfHandle, ...);

    if (type(newbutton) ~= "string") then
        newbutton = nil;
    end

    return newbutton, (updatelater and true) or nil;
end

local function SecureHandler_Other_Execute(header, button, signature, body, ...)
    local _, hp = header:IsProtected();
    if ((not hp)
        or (InCombatLockdown() and not button:IsProtected())) then
        return;
    end

    local environment = _managed_environments[header];
    local selfHandle = GetFrameHandle(button);
    local propagate =
        CallRestrictedClosure(signature, environment, false,
                              body, selfHandle, ...);

    return (propagate and true) or nil;
end

function SecureHandlerAdoptee_OnClick(self, button, down)
    local fireupdate, header;

    local body = self:GetAttribute("_childclick");
    if (body and type(body) == "string") then
        header = self:GetAttribute("_secureheader");
        local newbutton, updatelater =
            SecureHandler_Button_Execute(header, self,
                                         "self,button,down", body,
                                         button, down);
        if (newbutton) then
            button = tostring(newbutton);
        end
        fireupdate = updatelater;
    end

    securecall(SecureHandler_SafeCallOnClick, self, button, down);

    if (fireupdate) then
        local body = header:GetAttribute("_onchildclick");
        if (body and type(body) == "string") then
            SecureHandler_Execute(header, false,
                                  "self,button,down", body, button, down);
        end
    end
end

function SecureHandlerChild_ChildAction(self, signature,
                                        childhandler, handler,
                                        ...)
    local body = self:GetAttribute(childhandler);
    if ( ( not body ) or type(body) ~= "string") then
        return;
    end
    local header = self:GetParent();
    local propagate =
        SecureHandler_Other_Execute(header, self, signature, body, ...);
    if (not propagate) then
        return;
    end

    local body = header:GetAttribute(handler);
    if (body and type(body) == "string") then
        SecureHandler_Execute(header, false, signature, body, ...);
    end
end
