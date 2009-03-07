-- SecureHandlers.lua (Part of the new Secure Headers implementation)
--
-- Lua code to support the various handlers and templates which can execute
-- code in a secure, but restricted, environment.
--
-- Daniel Stephens (iriel@vigilance-committee.org)
-- Nevin Flanagan (alestane@comcast.net)
---------------------------------------------------------------------------

-- Local references to things so that they can't be subverted
local forceinsecure = forceinsecure;
local geterrorhandler = geterrorhandler;
local issecure = issecure;
local newproxy = newproxy;
local pairs = pairs;
local pcall = pcall;
local rawget = rawget;
local scrub = scrub;
local securecall = securecall;
local select = select;
local tostring = tostring;
local type = type;
local wipe = wipe;

local GetCursorInfo = GetCursorInfo;
local GetTime = GetTime;
local InCombatLockdown = InCombatLockdown;

local CallRestrictedClosure = CallRestrictedClosure;
local GetFrameHandle = GetFrameHandle;
local IsFrameHandle = IsFrameHandle;
local RestrictedTable_create = rtable.newtable;

-- SoftError(message)
-- Report an error message without stopping execution
local function SoftError_inner(message)
    local func = geterrorhandler();
    func(message);
end

local function SoftError(message)
    securecall(pcall, SoftError_inner, message);
end

---------------------------------------------------------------------------
-- Working environments and control handles

local LOCAL_Managed_Control_Frames = {};
setmetatable(LOCAL_Managed_Control_Frames, { __mode = "v"; });

local LOCAL_CTRL = {};
local LOCAL_Managed_Control_Proto = newproxy(true);
do
    local mt = getmetatable(LOCAL_Managed_Control_Proto);
    mt.__index = LOCAL_CTRL;
    mt.__metatable = false;
end

local LOCAL_Managed_Controls = {};
setmetatable(LOCAL_Managed_Controls, { __mode = "k"; });

local function ManagedEnvironmentsIndex(t, k)
    if (not issecure() or type(k) ~= "table") then
        error("Invalid access of managed environments table");
        return;
    end;

    local ownerHandle = GetFrameHandle(k, true);
    if (not ownerHandle) then
        error("Invalid access of managed environments table (bad frame)");
        return;
    end
    local _, explicitProtected = ownerHandle:IsProtected();
    if (not explicitProtected) then
        error("Invalid access of managed environments table (not protected)");
        return;
    end

    local e = RestrictedTable_create();
    e._G = e;
    e.owner = ownerHandle;
    local control = newproxy(LOCAL_Managed_Control_Proto);
    t[k] = e;
    LOCAL_Managed_Controls[e] = control;
    LOCAL_Managed_Control_Frames[control] = k;
    return e;
end

local LOCAL_Managed_Environments = {};
setmetatable(LOCAL_Managed_Environments,
             {
                 __index = ManagedEnvironmentsIndex,
                 __mode = "k",
             });

function GetManagedEnvironment(envKey)
    return rawget(LOCAL_Managed_Environments, envKey);
end

---------------------------------------------------------------------------
-- Standard invocation for header executions and child executions

local function SecureHandler_Self_Execute(self, signature, body, ...)
    if (type(body) ~= "string") then return; end

    local selfHandle = GetFrameHandle(self, true);
    if (not selfHandle) then
        error("Invalid 'self' frame handle");
        return;
    end

    local environment = LOCAL_Managed_Environments[self];
    local controlHandle = LOCAL_Managed_Controls[environment];

    return CallRestrictedClosure(signature, environment, controlHandle,
                                 body, selfHandle, ...);
end

local function SecureHandler_Other_Execute(header, self, signature, body, ...)
    if (type(body) ~= "string") then return; end

    local selfHandle = GetFrameHandle(self, true);
    if (not selfHandle) then return; end

    local environment = LOCAL_Managed_Environments[header];
    local controlHandle = LOCAL_Managed_Controls[environment];
    return CallRestrictedClosure(signature, environment, controlHandle,
                                 body, selfHandle, ...);
end

---------------------------------------------------------------------------
-- Script handlers for various header templates

function SecureHandler_OnSimpleEvent(self, snippetAttr)
    local body = self:GetAttribute(snippetAttr);
    if (body) then
        SecureHandler_Self_Execute(self, "self", body);
    end
end

function SecureHandler_OnClick(self, snippetAttr, button, down)
    local body = self:GetAttribute(snippetAttr);
    if (body) then
        SecureHandler_Self_Execute(self, "self,button,down",
                                   body, button, down);
    end
end

function SecureHandler_OnMouseUpDown(self, snippetAttr, button)
    local body = self:GetAttribute(snippetAttr);
    if (body) then
        SecureHandler_Self_Execute(self, "self,button", body, button);
    end
end

function SecureHandler_OnMouseWheel(self, snippetAttr, delta)
    local body = self:GetAttribute(snippetAttr);
    if (body) then
        SecureHandler_Self_Execute(self, "self,delta", body, delta);
    end
end

function SecureHandler_StateOnAttributeChanged(self, name, value)
    local stateid = name:match("^state%-(.+)");
    if (stateid) then
        local body = self:GetAttribute("_onstate-" .. stateid);
        if (body) then
            SecureHandler_Self_Execute(self, "self,stateid,newstate",
                                       body, stateid, value);
        end
    end
end

function SecureHandler_AttributeOnAttributeChanged(self, name, value)
    if (name:match("^_")) then
        return;
    end;

    local body = self:GetAttribute("_onattributechanged");
    if (body) then
        SecureHandler_Self_Execute(self, "self,name,value",
                                   body, name, value);
    end
end

local function PickupAny(kind, target, detail, ...)
    if (kind == "clear") then
        ClearCursor();
        kind, target, detail = target, detail, ...;
    end

    if kind == 'action' then
        PickupAction(target);
    elseif kind == 'bag' then
        PickupBagFromSlot(target)
    elseif kind == 'bagslot' then
        PickupContainerItem(target, detail)
    elseif kind == 'inventory' then
        PickupInventoryItem(target)
    elseif kind == 'item' then
        PickupItem(target)
    elseif kind == 'macro' then
        PickupMacro(target)
    elseif kind == 'merchant' then
        PickupMerchantItem(target)
    elseif kind == 'petaction' then
        PickupPetAction(target)
    elseif kind == 'money' then
        PickupPlayerMoney(target)
    elseif kind == 'spell' then
        PickupSpell(target, detail)
    elseif kind == 'companion' then
        PickupCompanion(target, detail)
        elseif kind == 'equipmentset' then
                PickupEquipmentSet(target);
    end
end

function SecureHandler_OnDragEvent(self, snippetAttr, button)
    local body = self:GetAttribute(snippetAttr);
    if (body) then
        PickupAny( SecureHandler_Self_Execute(self,
                                              "self,button,kind,value,...",
                                              body, button, GetCursorInfo()) );
    end
end

---------------------------------------------------------------------------
-- "Wrap" handlers for alternate dispatch on various conditions
-- such as OnClick, used for child handlers
--
-- All wrappers use ... to make sure the original handler gets all of
-- its arguments even if WoW is updated and this file is missed.

-- 'Marker object' used to trigger unwrap of wrap closure
local MAGIC_UNWRAP = newproxy();

local LOCAL_Wrapped_Handlers = {};
setmetatable(LOCAL_Wrapped_Handlers, { __mode = "k"; });

-- Create a closure to hold the data for a specific wrap
local function CreateWrapClosure(handler, header, preBody, postBody)
    local wrap;
    if (postBody) then
        wrap = function(self, ...)
                   if (self == MAGIC_UNWRAP) then
                       return header, preBody, postBody;
                   end
                   return handler(self, header, preBody, postBody, wrap, ...);
               end
    else
        wrap = function(self, ...)
                   if (self == MAGIC_UNWRAP) then
                       return header, preBody, nil;
                   end
                   return handler(self, header, preBody, nil, wrap, ...);
               end
    end
    return wrap;
end

-- Save a hander against a specific wrap (securecall'ed for protection)
local function SaveWrapHandler(frame, script, wrap)
    LOCAL_Wrapped_Handlers[wrap] = frame:GetScript(script) or false;
end

-- Restore a hander from a specific wrap (securecall'ed for protection)
local function RestoreWrapHandler(frame, script, wrap)
    local old = LOCAL_Wrapped_Handlers[wrap];
    if (old == nil) then return; end
    if (old == false) then old = nil; end
    frame:SetScript(script, old);
    return true;
end

-- Create a new handler wrapper and configure it
--
-- frame   - the frame that has the script
-- script  - the script name (such as OnClick)
-- header  - the secure header that owns the 'wrap'
-- handler - the handler function that will process the event
-- preBody - the snippet to execute before the wrapped handler
-- postBody (optional) - the snippet to execute after the wrapped handler
--
-- The resulting closure is called as (self, ...)
--
-- The handler is invoked with (self, header, preBody, postBody, wrap, ...)
-- where 'wrap' is the wrap closure itself (also the key to the wrapped
-- handlers table)
local function CreateWrapper(frame, script, header, handler, preBody, postBody)
    local wrap = CreateWrapClosure(handler, header, preBody, postBody);
    securecall(SaveWrapHandler, frame, script, wrap);
    return wrap;
end

-- Reverse the wrap process, restoring the wrapped handler (does nothing
-- if the current handler is not wrapped)
local function RemoveWrapper(frame, script)
    local wrap = frame:GetScript(script);

    if (not issecure()) then
        -- not valid
        return;
    end

    if (not securecall(RestoreWrapHandler, frame, script, wrap)) then
        -- not valid
        return;
    end

    -- Extract header, preBody, postBody
    return wrap(MAGIC_UNWRAP);
end

-- Invoke the wrapped handler for a wrapper, passing in all arguments
local function SafeCallWrappedHandler(frame, wrap, ...)
    local handler = LOCAL_Wrapped_Handlers[wrap];
    if (type(handler) == "function") then
        local ok, err = pcall(handler, frame, ...);
        if (not ok) then
            SoftError(err);
        end
    end
end

-- Check that a given frame is eligible for wrapped execution
local function IsWrapEligible(frame)
    return (not InCombatLockdown()) or frame:IsProtected();
end

-- Wrapper handler for clicks
local function Wrapped_Click(self, header, preBody, postBody, wrap,
                             button, down, ...)
    local message, newbutton;

    if ( IsWrapEligible(self) ) then
        newbutton, message =
            SecureHandler_Other_Execute(header, self,
                                        "self,button,down", preBody,
                                        button, down);
        if (newbutton == false) then
            return;
        end
        if (newbutton) then
            button = tostring(newbutton);
        end
    end

    securecall(SafeCallWrappedHandler, self, wrap, button, down, ...);

    if (postBody and message ~= nil) then
        SecureHandler_Other_Execute(header, self,
                                    "self,message,button,down",
                                    postBody,
                                    message, button, down);
    end;
end

local function Wrapped_OnEnter(self, header, preBody, postBody, wrap,
                               motion, ...)
    local allow, message;
    if ( motion ) then
        self:SetAttribute("_wrapentered", true);
        if ( IsWrapEligible(self) ) then
            allow, message =
                SecureHandler_Other_Execute(header, self, "self",
                                            preBody);
        end

        if (allow == false) then
            return;
        end
    end

    securecall(SafeCallWrappedHandler, self, wrap, motion, ...);

    if (postBody and message ~= nil) then
        SecureHandler_Other_Execute(header, self, "self,message",
                                    postBody, message);
    end
end

local function Wrapped_OnLeave(self, header, preBody, postBody, wrap,
                               motion, ...)
    local allow, message;
    if ( motion and self:GetAttribute("_wrapentered")) then
        self:SetAttribute("_wrapentered", nil);
        if ( IsWrapEligible(self) ) then
            allow, message =
                SecureHandler_Other_Execute(header, self, "self",
                                            preBody);
            if (allow == false) then
                return;
            end
        end
    end

    securecall(SafeCallWrappedHandler, self, wrap, motion, ...);

    if (postBody and message ~= nil) then
        SecureHandler_Other_Execute(header, self, "self,message",
                                    postBody, message);
    end
end

local function CreateSimpleWrapper(beforeSignature, afterSignature)
    return function(self, header, preBody, postBody, wrap,
                    ...)
               local allow, message;
               if ( IsWrapEligible(self) ) then
                   allow, message =
                       SecureHandler_Other_Execute(header,
                                                   self, beforeSignature,
                                                   preBody, ...);
                   if (allow == false) then
                       return;
                   end
               end

               securecall(SafeCallWrappedHandler, self, wrap, ...);

               if ( postBody and message ~= nil ) then
                   SecureHandler_Other_Execute(header,
                                               self, afterSignature,
                                               postBody, message, ...);
               end
           end;
end

local Wrapped_ShowHide = CreateSimpleWrapper("self", "self,message");

local Wrapped_MouseWheel = CreateSimpleWrapper("self,offset",
                                               "self,message,offset");

local function Wrapped_Drag(self, header, preBody, postBody, wrap, ...)
    local message;
    if ( IsWrapEligible(self) ) then
        local selfHandle = GetFrameHandle(self, true);
        if (selfHandle) then
            local environment = LOCAL_Managed_Environments[header];
            local controlHandle = LOCAL_Managed_Controls[environment];
            local button = ...;
            local type, target, x1, x2, x3 =
                CallRestrictedClosure("self,button,kind,value,...",
                                      environment,
                                      controlHandle, preBody,
                                      selfHandle, button,
                                      GetCursorInfo());
            if (type == false) then
                return;
            elseif (type == "message") then
                message = target;
            elseif (type) then
                PickupAny(type, target, x1, x2, x3);
                return;
            end
        end
    end

    securecall(SafeCallWrappedHandler, self, wrap, ...);

    if ( postBody and message ~= nil ) then
        SecureHandler_Other_Execute(header, self,
                                    "self,message,button",
                                    postBody, message, ...);
    end
end

local function Wrapped_Attribute(self, header, preBody, postBody, wrap,
                                 name, value, ...)
    local allow, message;
    if ( (not name:match("^_")) and IsWrapEligible(self) ) then
        allow, message =
            SecureHandler_Other_Execute(header, self,
                                        "self,name,value", preBody,
                                        name, value);
        if (allow == false) then
            return;
        end
    end

    securecall(SafeCallWrappedHandler, self, wrap, name, value, ...);

    if ( postBody and message ~= nil ) then
        SecureHandler_Other_Execute(header, self,
                                    "self,message,name,value",
                                    postBody, message, name, value);
    end
end

local LOCAL_Wrap_Handlers = {
    OnClick = Wrapped_Click;
    OnDoubleClick = Wrapped_Click;
    PreClick = Wrapped_Click;
    PostClick = Wrapped_Click;

    OnEnter = Wrapped_OnEnter;
    OnLeave = Wrapped_OnLeave;

    OnShow = Wrapped_ShowHide;
    OnHide = Wrapped_ShowHide;

    OnDragStart = Wrapped_Drag;
    OnReceiveDrag = Wrapped_Drag;

    OnMouseWheel = Wrapped_MouseWheel;

    OnAttributeChanged = Wrapped_Attribute;
};

---------------------------------------------------------------------------
-- External API helpers, all are driven off a single control frame
-- using OnAttributeChanged.

-- Quick sanity check that a frame looks like a frame
local function IsValidFrame(frame)
    return (type(frame) == "table") and (type(frame[0]) == "userdata");
end

-- 'Action' handler for most of the API methods, invoked somewhat indirectly
-- via attribute sets so as to allow secure execution (doesn't work from
-- combat for user code (or indeed for any code))
local function API_OnAttributeChanged(self, name, value)
    if (value == nil) then
        return;
    end

    if (InCombatLockdown()) then
        -- This shouldn't ever happen because API frame is protected,
        -- but just in case someone does something silly...
        error("Cannot use SecureHandlers API during combat");
        return;
    end


    -- _execute runs code in the context of a header
    if (name == "_execute") then
        local frame =  self:GetAttribute("_apiframe");
        self:SetAttribute("_execute", nil);
        if (type(value) ~= "string") then
            error("Invalid execute body");
            return;
        end
        -- Most validation is performed by SecureHandler_Self_Execute
        SecureHandler_Self_Execute(frame, "self", value);
        return;
    end

    -- _wrap wraps a script handler in a secure wrapper
    if (name == "_wrap") then
        local frame =  self:GetAttribute("_apiframe");
        local header =  self:GetAttribute("_apiheader");
        local preBody = self:GetAttribute("_apiprebody");
        local postBody = self:GetAttribute("_apipostbody");
        self:SetAttribute("_wrap", nil);
        if (type(value) ~= "string") then
            error("Invalid wrap script id");
        end
        if (not IsValidFrame(frame)) then
            error("Invalid wrap frame");
        end
        if (not IsValidFrame(header)) then
            error("Invalid header frame");
        end
        if (type(preBody) ~= "string") then
            error("Invalid pre-handler body");
        end
        if (postBody ~= nil and type(postBody) ~= "string") then
            error("Invalid post-handler body");
        end
        if (not select(2, header:IsProtected())) then
            error("Header frame must be explicitly protected");
        end
        local script = value;
        if (not frame:HasScript(script)) then
            error("Frame does not support script '" .. script .. "'");
        end
        if (not issecure()) then
            error("Wrap frame cannot be used");
        end
        local handler = LOCAL_Wrap_Handlers[value];
        if (not handler) then
            error("Unsupported script type '" .. value .. "'");
        end
        local wrapper = CreateWrapper(frame, value, header,
                                      handler, preBody, postBody);
        frame:SetScript(script, wrapper);
        return;
    end

    -- _unwrap restores a previously wrapped handler
    if (name == "_unwrap") then
        local frame =  self:GetAttribute("_apiframe");
        local data =  self:GetAttribute("_apidata");
        if (data) then
            self:SetAttribute("_apidata", nil);
        end
        self:SetAttribute("_unwrap", nil);
        if (type(value) ~= "string") then
            error("Invalid unwrap script id");
        end
        if (not IsValidFrame(frame)) then
            error("Invalid unwrap frame");
        end
        local script = value;
        if (not frame:HasScript(script)) then
            error("Frame does not support script '" .. script .. "'");
        end
        local header, preBody, postBody = RemoveWrapper(frame, script);
        if (type(data) == "table") then
            forceinsecure();
            wipe(data);
            data[1] = frame;
            data[2] = script;
            data[3] = header;
            data[4] = preBody;
            data[5] = postBody;
        end
        return;
    end

    -- _frame-<label> creates a frame reference
    local frameid = name:match("^_frame%-(.+)");
    if (frameid) then
        local frame =  self:GetAttribute("_apiframe");
        self:SetAttribute(name, nil);
        if (not IsValidFrame(frame)) then
            error("Invalid destination frame");
            return;
        end
        if (not IsValidFrame(value)) then
            error("Invalid referenced frame");
            return;
        end

        local refid = "frameref-" .. frameid;
        local handle = GetFrameHandle(value);
        frame:SetAttribute(refid, handle);
        return;
    end
end

-- Frame used as both an attribute repository for API functions as well
-- as the OnUpdate timer source for timer and OnUpdate dispatch
local LOCAL_API_Frame = CreateFrame("Frame", "SecureHandlersUpdateFrame",
                                nil, "SecureFrameTemplate");

LOCAL_API_Frame:SetScript("OnAttributeChanged", API_OnAttributeChanged);

-- Wrap the script on a frame to invoke snippets against a header
function SecureHandlerWrapScript(frame, script, header, preBody, postBody)
    if (not IsValidFrame(frame)) then
        error("Invalid frame");
    end
    if (type(script) ~= "string") then
        error("Invalid script id");
    end
    if (header and not IsValidFrame(header)) then
        error("Invalid header frame");
    end
    if (not select(2, header:IsProtected())) then
        error("Header frame must be explicitly protected");
    end
    if (type(preBody) ~= "string") then
        error("Invalid pre-handler body");
    end
    if (postBody ~= nil and type(postBody) ~= "string") then
        error("Invalid post-handler body");
    end
    LOCAL_API_Frame:SetAttribute("_apiframe", frame);
    LOCAL_API_Frame:SetAttribute("_apiheader", header);
    LOCAL_API_Frame:SetAttribute("_apiprebody", preBody);
    LOCAL_API_Frame:SetAttribute("_apipostbody", postBody);
    LOCAL_API_Frame:SetAttribute("_wrap", script);
end

local UNWRAP_TEMP_TABLE = {};

-- Remove previously applied wrapping, returning its details
function SecureHandlerUnwrapScript(frame, script)
    if (not IsValidFrame(frame)) then
        error("Invalid frame");
    end
    if (type(script) ~= "string") then
        error("Invalid script id");
    end
    wipe(UNWRAP_TEMP_TABLE);
    UNWRAP_TEMP_TABLE[1] = false;
    LOCAL_API_Frame:SetAttribute("_apiframe", frame);
    LOCAL_API_Frame:SetAttribute("_apidata", UNWRAP_TEMP_TABLE);
    LOCAL_API_Frame:SetAttribute("_unwrap", script);

    local chkFrame = UNWRAP_TEMP_TABLE[1];
    local chkScript = UNWRAP_TEMP_TABLE[2];
    local header = UNWRAP_TEMP_TABLE[3];
    local preBody = UNWRAP_TEMP_TABLE[4];
    local postBody = UNWRAP_TEMP_TABLE[5];

    if ((chkFrame ~= frame) or (chkScript ~= script)) then
        error("Unable to retrieve unwrap results");
        return;
    end
    wipe(UNWRAP_TEMP_TABLE);
    return header, preBody, postBody;
end

-- Execute a snippet against a header frame
function SecureHandlerExecute(frame, body)
    if (not IsValidFrame(frame)) then
        error("Invalid header frame");
    end
    if (not select(2, frame:IsProtected())) then
        error("Header frame must be explicitly protected");
    end
    if (type(body) ~= "string") then
        error("Invalid body");
    end
    LOCAL_API_Frame:SetAttribute("_apiframe", frame);
    LOCAL_API_Frame:SetAttribute("_execute", body);
end

-- Create a frame handle reference and store it against a frame
function SecureHandlerSetFrameRef(frame, label, refFrame)
    if (not IsValidFrame(frame)) then
        error("Invalid frame");
    end
    if (type(label) ~= "string") then
        error("Invalid body");
    end
    if (not IsValidFrame(refFrame)) then
        error("Invalid reference frame");
    end
    LOCAL_API_Frame:SetAttribute("_apiframe", frame);
    LOCAL_API_Frame:SetAttribute("_frame-" .. label, refFrame);
end

---------------------------------------------------------------------------
-- Helper Methods, these are just friendly wrappers for the
-- global functions.


local function SecureHandlerMethod_Execute(self, body)
    -- Kept as a wrapper for consistency
    return SecureHandlerExecute(self, body);
end

local function SecureHandlerMethod_WrapScript(self, frame, script,
                                              preBody, postBody)
    -- Wrapped since args are in different order
    return SecureHandlerWrapScript(frame, script, self, preBody, postBody);
end

local function SecureHandlerMethod_UnwrapScript(self, frame, script)
    -- Wrapped since args are in different order
    return SecureHandlerUnwrapScript(frame, script);
end

local function SecureHandlerMethod_SetFrameRef(self, id, frame)
    -- Kept as a wrapper for consistency
    return SecureHandlerSetFrameRef(self, id, frame);
end

function SecureHandler_OnLoad(self)
    self.Execute = SecureHandlerMethod_Execute;
    self.WrapScript = SecureHandlerMethod_WrapScript;
    self.UnwrapScript = SecureHandlerMethod_UnwrapScript;
    self.SetFrameRef = SecureHandlerMethod_SetFrameRef;
end

---------------------------------------------------------------------------
-- Control handle methods

function LOCAL_CTRL:Run(body, ...)
    local frame = LOCAL_Managed_Control_Frames[self];
    if (not frame) then
        error("Invalid control handle");
        return;
    end
    if (type(body) ~= "string") then
        error("Invalid function body");
        return;
    end
    local env = LOCAL_Managed_Environments[frame];
    local selfHandle = GetFrameHandle(frame, true);
    if (not selfHandle) then
        -- NOTE: This should never actually happen since the frame must
        -- be protected to have an environment or control!
        return;
    end
    return scrub(CallRestrictedClosure("self,...",
                                       env, self, body, selfHandle, ...));
end

function LOCAL_CTRL:RunFor(otherHandle, body, ...)
    local frame = LOCAL_Managed_Control_Frames[self];
    if (not frame) then
        error("Invalid control handle");
        return;
    end
    if ((otherHandle ~= nil) and (not IsFrameHandle(otherHandle))) then
        error("Invalid handle for other frame");
        return;
    end
    if (type(body) ~= "string") then
        error("Invalid function body");
        return;
    end
    local env = LOCAL_Managed_Environments[frame];
    return scrub(CallRestrictedClosure("self,...",
                                       env, self, body, otherHandle, ...));
end

function LOCAL_CTRL:RunAttribute(snippetAttr, ...)
    local frame = LOCAL_Managed_Control_Frames[self];
    if (not frame) then
        error("Invalid control handle");
        return;
    end
    if (type(snippetAttr) ~= "string") then
        error("Invalid snippet attribute");
        return;
    end
    local body = frame:GetAttribute(snippetAttr);
    if (type(body) ~= "string") then
        error("Invalid snippet body");
        return;
    end
    local env = LOCAL_Managed_Environments[frame];
    local selfHandle = GetFrameHandle(frame, true);
    if (not selfHandle) then
        -- NOTE: This should never actually happen since the frame must
        -- be protected to have an environment or control!
        return
    end
    return scrub(CallRestrictedClosure("self,...",
                                       env, self, body, selfHandle, ...));
end

local function ChildUpdate_Helper(environment, controlHandle,
                                  scriptid, message, ...)
    local scriptattr;
    if (scriptid ~= nil) then
        scriptid = tostring(scriptid);
        scriptattr = "_childupdate-" .. scriptid;
    end
    for i = 1, select('#', ...) do
        local child = select(i, ...);
        local p = child:IsProtected();
        if (p) then
            local body;
            if (scriptattr) then
                body = child:GetAttribute(scriptattr);
            end
            if (body == nil) then
                body = child:GetAttribute("_childupdate");
            end
            if (body and type(body) == "string") then
                local selfHandle = GetFrameHandle(child, true);
                if (selfHandle) then
                    CallRestrictedClosure("self,scriptid,message",
                                          environment, controlHandle, body,
                                          selfHandle, scriptid, message);
                end
            end
        end
    end
end

function LOCAL_CTRL:ChildUpdate(snippetid, message)
    local frame = LOCAL_Managed_Control_Frames[self];
    if (not frame) then
        error("Invalid control handle");
        return;
    end
    local env = LOCAL_Managed_Environments[frame];
    ChildUpdate_Helper(env, self, snippetid, message, frame:GetChildren());
end

local function CallMethod_inner(frame, methodName, ...)
    local method = frame[methodName];
    -- Ensure code isn't run securely
    forceinsecure();
    if (type(method) ~= "function") then
        error("Invalid method '" .. methodName .. "'");
        return;
    end
    method(frame, ...);
end

-- This essentially supports already-possible functionality but without
-- the overhead of having to hook OnAttributeChanged scripts and create
-- temporary restricted tables.
function LOCAL_CTRL:CallMethod(methodName, ...)
    local frame = LOCAL_Managed_Control_Frames[self];
    if (not frame) then
        error("Invalid control handle");
        return;
    end
    if (type(methodName) ~= "string") then
        error("Method name must be a string");
        return;
    end
    -- Use a pcall wrapper here to ensure that execution continues
    -- regardless
    local ok, err =
        securecall(pcall, CallMethod_inner, frame, methodName, scrub(...));
    if (err) then
        SoftError(err);
    end
end
