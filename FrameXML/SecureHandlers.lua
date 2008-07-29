-- SecureHandlers.lua (Part of the new Secure Headers implementation)
--
-- Lua code to support the various handlers and templates which can execute
-- code in a secure, but restricted, environment.
--
-- Daniel Stephens (iriel@vigilance-committee.org)
-- Nevin Flanagan (alestane@comcast.net)
---------------------------------------------------------------------------

local SPARE_NAMESPACES = {}
local SPARE_NAMESPACE_COUNT = 0;
local USED_NAMESPACES = {};
setmetatable(USED_NAMESPACES, { __mode = "k"; });

local function GetNamespace(...)
    local ns;
    if ((not issecure()) or (SPARE_NAMESPACE_COUNT == 0)) then
        ns = {};
    else
        ns = SPARE_NAMESPACES[SPARE_NAMESPACE_COUNT];
        SPARE_NAMESPACES[SPARE_NAMESPACE_COUNT] = nil;
        SPARE_NAMESPACE_COUNT = SPARE_NAMESPACE_COUNT - 1;
    end

    USED_NAMESPACES[ns] = true;

    for i=1, select('#', ...), 2 do
        local key, value = select(i, ...);
        if (value) then
            ns[key] = value;
        end
    end

    return ns;
end

local function FreeNamespace(ns)
    if (not USED_NAMESPACES[ns]) then return; end
    USED_NAMESPACES[ns] = nil;
    wipe(ns);

    if (issecure()) then
        SPARE_NAMESPACE_COUNT = SPARE_NAMESPACE_COUNT + 1;
        SPARE_NAMESPACES[SPARE_NAMESPACE_COUNT] = ns;
    end
end

---------------------------------------------------------------------------

local RestrictedTable_create = rtable.newtable;
local function ManagedEnvironmentsIndex(t, k)
    if (not issecure() or type(k) ~= "table") then
        error("Invalid access of managed environments table");
        return;
    end;

    if (type(k[0]) ~= "userdata") then
        error("Invalid access of managed environments table");
        return;
    end

    local e = RestrictedTable_create();
    e._G = e;
    t[k] = e;
    return e;
end

local MANAGED_ENVIRONMENTS = {};
setmetatable(MANAGED_ENVIRONMENTS,
             {
                 __index = ManagedEnvironmentsIndex,
                 __mode = "k",
             });

local rawget = rawget;
function GetManagedEnvironment(envKey)
    return rawget(MANAGED_ENVIRONMENTS, envKey);
end

---------------------------------------------------------------------------

local tostring = tostring;
local type = type;

local function SecureHandler_ChildExecute(self, environment, bodyid, ...)
    local n = select('#', ...);
    if (n == 0) then return; end

    local selfSurrogate = GetFrameSurrogate(self, false);
    local namespace = GetNamespace("header", selfSurrogate);

    for i = 1, n do
        local child = select(i, ...);
        if (child:IsProtected()) then
            local body = child:GetAttribute(bodyid);
            if (body and type(body) == "string") then
                local childSurrogate = GetFrameSurrogate(child, true);
                namespace.self = childSurrogate;
                CallRestrictedClosure("", environment, namespace, body);
                namespace.self = nil;
                ReleaseFrameSurrogate(childSurrogate);
            end
        end
    end
    FreeNamespace(namespace);
    ReleaseFrameSurrogate(selfSurrogate);
end

local SecureHandler_OnUpdate;
local function SecureHandler_Execute(self, signature, body, ...)
    if (not self:IsProtected()) then
        return;
    end

    local surrogate = GetFrameSurrogate(self, true);
    local environment = MANAGED_ENVIRONMENTS[self];
    local namespace = GetNamespace("self", surrogate);

    local childupdate, animate =
        CallRestrictedClosure(signature, environment, namespace,
                              body, ...);
    FreeNamespace(namespace);
    ReleaseFrameSurrogate(surrogate);
    surrogate = nil;

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

    SecureHandler_ChildExecute(self, environment, childmethod,
                               self:GetChildren());
end

---------------------------------------------------------------------------
function SecureHandler_OnSimpleEvent(self, scriptid)
    local body = self:GetAttribute(scriptid);
    if (body and type(body) == "string") then
        SecureHandler_Execute(self, "", body);
    end
end

function SecureHandler_OnClick(self, button, down)
    local body = self:GetAttribute("_onclick");
    if (body and type(body) == "string") then
        SecureHandler_Execute(self, "button,down", body, button, down);
    end
end

-- Locally bound above
function SecureHandler_OnUpdate(self, elapsed)
    local body = self:GetAttribute("_onupdate");
    if (body and type(body) == "string") then
        SecureHandler_Execute(self, "elapsed", body, tonumber(elapsed));
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
        SecureHandler_Execute(self, "", value);
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
end


function SecureHandler_StateOnAttributeChanged(self, name, value)
    if (SecureHandler_OnAttributeChanged(self, name, value)) then
        return;
    end

    local stateid = name:match("^state%-(.+)");
    if (stateid) then
        local body = self:GetAttribute("_onstate-" .. stateid);
        if (body and type(body) == "string") then
            SecureHandler_Execute(self, "stateid,newstate", body, stateid, value);
        end
        return;
    end
end

local function SecureHandler_Button_Execute(header, button, signature, body, ...)
    if ((not header:IsProtected())
        or (InCombatLockdown() and not button:IsProtected())) then
        return;
    end

    local headerSurrogate = GetFrameSurrogate(header, false);
    local buttonSurrogate = GetFrameSurrogate(button, true);
    local environment = MANAGED_ENVIRONMENTS[header];
    local namespace = GetNamespace("header", headerSurrogate,
                                   "self", buttonSurrogate);
    local newbutton, updatelater =
        CallRestrictedClosure(signature, environment, namespace,
                              body, ...);
    FreeNamespace(namespace);
    ReleaseFrameSurrogate(headerSurrogate);
    ReleaseFrameSurrogate(buttonSurrogate);
    headerSurrogate, buttonSurrogate = nil, nil;

    if (type(newbutton) ~= "string") then
        newbutton = nil;
    end

    return newbutton, (updatelater and true) or nil;
end

local function SecureHandler_Other_Execute(header, button, signature, body, ...)
    if ((not header:IsProtected())
        or (InCombatLockdown() and not button:IsProtected())) then
        return;
    end

    local headerSurrogate = GetFrameSurrogate(header, false);
    local buttonSurrogate = GetFrameSurrogate(button, true);
    local environment = MANAGED_ENVIRONMENTS[header];
    local namespace = GetNamespace("header", headerSurrogate,
                                   "self", buttonSurrogate);
    local propagate =
        CallRestrictedClosure(signature, environment, namespace,
                              body, ...);
    FreeNamespace(namespace);
    ReleaseFrameSurrogate(headerSurrogate);
    ReleaseFrameSurrogate(buttonSurrogate);
    headerSurrogate, buttonSurrogate = nil, nil;

    return (propagate and true) or nil;
end

function SecureHandlerAdoptee_OnClick(self, button, down)
    local fireupdate, header;

    local body = self:GetAttribute("_childclick");
    if (body and type(body) == "string") then
        header = self:GetAttribute("_secureheader");
        local newbutton, updatelater =
            SecureHandler_Button_Execute(header, self, "button,down", body);
        if (newbutton) then
            button = tostring(newbutton);
        end
        fireupdate = updatelater;
    end

    securecall(SecureHandler_SafeCallOnClick, self, button, down);

    if (fireupdate) then
        local body = header:GetAttribute("_onchildclick");
        if (body and type(body) == "string") then
            SecureHandler_Execute(header, "button,down", body, button, down);
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
        SecureHandler_Execute(header, signature, body, ...);
    end
end
