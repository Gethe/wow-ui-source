-- RestrictedFrames.lua (Part of the new Secure Headers implementation)
--
-- Provides the method definitions for restricted frames.
-- See RestrictedInfrastructure.lua for more details.
--
-- Daniel Stephens (iriel@vigilance-committee.org)
-- Nevin Flanagan (alestane@comcast.net)
--
-- Various methods (SetPoint/SetParent) take frame handles as relative
-- frame arguments also. You can safely obtain frame handles (out of combat)
-- by setting the '_frame-<id>' attribute on a header frame to the frame
-- you want a handle to, and it'll set the 'frameref-<id>' attribute to be
-- the handle to that frame (or nil if it's invalid or unprotected).
-- This handle can then be retrieved using a GetAttribute call.
---------------------------------------------------------------------------

local select = select;
local type = type;
local error = error;
local tostring = tostring;
local tonumber = tonumber;
local securecall = securecall;

local GetCursorPosition = GetCursorPosition;
local InCombatLockdown = InCombatLockdown;

local IsFrameHandle = IsFrameHandle;
local GetFrameHandle = GetFrameHandle;
local GetFrameHandleFrame = GetFrameHandleFrame;

local GetManagedEnvironment = GetManagedEnvironment;

local CallRestrictedClosure = CallRestrictedClosure;

local forceinsecure = forceinsecure;
local scrub = scrub;
local pcall = pcall;

---------------------------------------------------------------------------
-- Frame Handles -- Userdata handles referencing explicitly protected frames
-- Handle support is in RestrictedInfrastructure

-- HANDLE is the frame handle method namespace (populated below)
local HANDLE = {};

---------------------------------------------------------------------------
-- Action implementation support function
--
-- GetUnprotectedHandleFrame -- Get the frame for a handle (always)
-- GetHandleFrame -- Get the frame for a handle that could accept a protected
--                   action (i.e. is protected, or we're not in combat)

local function GetUnprotectedHandleFrame(handle)
    local frame = GetFrameHandleFrame(handle);
    if (frame) then
        return frame;
    end
    error("Invalid frame handle");
end

local function GetHandleFrame(handle)
    local frame, isProtected = GetFrameHandleFrame(handle);
    if (frame and (isProtected
                   or (frame:IsProtected() or not InCombatLockdown()))) then
        return frame;
    end
    error("Invalid frame handle");
end

---------------------------------------------------------------------------
-- "GETTER" methods

function HANDLE:GetName()   return GetUnprotectedHandleFrame(self):GetName() end

function HANDLE:GetID()     return GetHandleFrame(self):GetID()     end
function HANDLE:IsShown()   return GetHandleFrame(self):IsShown()   end
function HANDLE:IsVisible() return GetHandleFrame(self):IsVisible() end
function HANDLE:GetWidth()  return GetHandleFrame(self):GetWidth()  end
function HANDLE:GetHeight() return GetHandleFrame(self):GetHeight() end
function HANDLE:GetRect()   return GetHandleFrame(self):GetRect() end
function HANDLE:GetScale()  return GetHandleFrame(self):GetScale()  end
function HANDLE:GetEffectiveScale()
    return GetHandleFrame(self):GetEffectiveScale()
end

-- Cannot expose GetAlpha since alpha is not protected

function HANDLE:GetFrameLevel()
    return GetHandleFrame(self):GetFrameLevel()
end

function HANDLE:GetFrameStrata()
    return GetHandleFrame(self):GetFrameStrata()
end

function HANDLE:IsMouseEnabled()
    return GetHandleFrame(self):IsMouseEnabled();
end

function HANDLE:IsKeyboardEnabled()
    return GetHandleFrame(self):IsKeyboardEnabled();
end

function HANDLE:GetObjectType()
    return GetUnprotectedHandleFrame(self):GetObjectType()
end

function HANDLE:IsObjectType(ot)
    return GetUnprotectedHandleFrame(self):IsObjectType(tostring(ot))
end

function HANDLE:IsProtected()
    return GetUnprotectedHandleFrame(self):IsProtected();
end


function HANDLE:GetAttribute(name)
    if (type(name) ~= "string" or name:match("^_")) then
        return;
    end
    local val = GetHandleFrame(self):GetAttribute(name)
    local tv = type(val);
    if (tv == "string" or tv == "number" or tv == "boolean" or val == nil) then
        return val;
    end
    if (tv == "userdata" and IsFrameHandle(val)) then
        return val;
    end
    return nil;
end

function HANDLE:GetFrameRef(label)
    if (type(label) ~= "string") then
        return;
    end
    local val = GetHandleFrame(self):GetAttribute("frameref-" .. label);
    local tv = type(val);
    if (tv == "userdata" and IsFrameHandle(val)) then
        return val;
    end
    return nil;
end

function HANDLE:GetEffectiveAttribute(name, button, prefix, suffix)
    if (type(name) ~= "string" or name:match("^_")) then
        return;
    end
    if (button ~= nil) then button = tostring(button) end
    if (prefix ~= nil) then
        prefix = tostring(prefix)
        if (prefix:match("^_")) then
            prefix = nil;
        end
    end
    if (suffix ~= nil) then suffix = tostring(suffix) end
    local val = SecureButton_GetModifiedAttribute(GetHandleFrame(self),
                                                  name, button, prefix,
                                                  suffix);
    local tv = type(val);
    if (tv == "string" or tv == "number" or tv == "boolean" or val == nil) then
        return val;
    end
    if (tv == "userdata" and IsFrameHandle(val)) then
        return val;
    end
    return nil;
end


local function FrameHandleMapper(nolockdown, frame, nextFrame, ...)
    if (not frame) then
        return;
    end
    -- Do an explicit protection check to avoid errors from
    -- the frame handle lookup
    local p = nolockdown;
    if (not p) then
        p = frame:IsProtected();
    end
    if (p) then
        frame = GetFrameHandle(frame);
        if (frame) then
            if (nextFrame) then
                return frame, FrameHandleMapper(nolockdown, nextFrame, ...);
            else
                return frame;
            end
        end
    end
    if (nextFrame) then
        return FrameHandleMapper(nolockdown, nextFrame, ...);
    end
end

local function FrameHandleInserter(result, ...)
    local nolockdown = not InCombatLockdown();
    local idx = #result;
    for i = 1, select('#', ...) do
        local frame = select(i, ...);
        -- Do an explicit protection check to avoid errors from
        -- the frame handle lookup
        local p = nolockdown;
        if (not p) then
            p = frame:IsProtected();
        end
        if (p) then
            frame = GetFrameHandle(frame);
            if (frame) then
                idx = idx + 1;
                result[idx] = frame;
            end
        end
    end

    return result;
end

function HANDLE:GetChildren()
    return FrameHandleMapper(not InCombatLockdown(),
                             GetHandleFrame(self):GetChildren());
end

function HANDLE:GetChildList(tbl)
    return FrameHandleInserter(tbl, GetHandleFrame(self):GetChildren());
end

function HANDLE:GetParent()
    return FrameHandleMapper(not InCombatLockdown(),
                             GetHandleFrame(self):GetParent());
end

-- NOTE: Cannot allow the frame to figure out if it has mouse focus
-- because an insecure frame could be appearing on top of it.

function HANDLE:GetMousePosition()
    local frame = GetHandleFrame(self);
    local x, y = GetCursorPosition()
    local l, b, w, h = frame:GetRect()
    if (not w or not h or w == 0 or h == 0) then return nil; end
    local e = frame:GetEffectiveScale();
    x, y = x / e, y /e;
    x = x - l
    y = y - b
    if x < 0 or x > w or y < 0 or y > h then
        return nil
    else
        return x / w, y / h
    end
end

-- Used only for recursive check, since it's more expensive
--
-- Only check protected and visible children
local function RF_CheckUnderMouse(x, y, ...)
    for i = 1, select('#', ...) do
        local frame = select(i, ...);
        if (frame and frame:IsProtected() and frame:IsVisible()) then
            local l, b, w, h = frame:GetRect()
            if (w and h) then
                local e = frame:GetEffectiveScale();
                local fx = x / e - l;
                if ((fx >= 0) and (fx <= w)) then
                    local fy = y / e - b;
                    if ((fy >= 0) and (fy <= h)) then return true; end
                end
            end
            if (RF_CheckUnderMouse(x, y, frame:GetChildren())) then
                return true;
            end
        end
    end
end

function HANDLE:IsUnderMouse(recursive)
    local frame = GetHandleFrame(self);
    local x, y = GetCursorPosition();
    local l, b, w, h = frame:GetRect()
    if (w and h) then
        local e = frame:GetEffectiveScale();
        local fx = x / e - l;
        if ((fx >= 0) and (fx <= w)) then
            local fy = y / e - b;
            if ((fy >= 0) and (fy <= h)) then return true; end
        end
    end
    if (not recursive) then
        return;
    end
    return RF_CheckUnderMouse(x, y, frame:GetChildren());
end

function HANDLE:GetNumPoints()
    return GetHandleFrame(self):GetNumPoints();
end

function HANDLE:GetPoint(i)
    local point, frame, relative, dx, dy = GetHandleFrame(self):GetPoint(i);
    local handle;
    if (frame) then
        handle = FrameHandleMapper(not InCombatLockdown(), frame);
    end
    if (handle or not frame) then
        return point, handle, relative, dx, dy;
    end
end

---------------------------------------------------------------------------
-- "SETTER" methods and actions

function HANDLE:Show(skipAttr)
    local frame = GetHandleFrame(self);
    frame:Show();
    if (not skipAttr) then
        frame:SetAttribute("statehidden", nil);
    end
end

function HANDLE:Hide(skipAttr)
    local frame = GetHandleFrame(self);
    frame:Hide();
    if (not skipAttr) then
        frame:SetAttribute("statehidden", true);
    end
end

function HANDLE:SetID(id)
    GetHandleFrame(self):SetID(tonumber(id) or 0);
end

function HANDLE:SetWidth(width)
    GetHandleFrame(self):SetWidth(tonumber(width));
end

function HANDLE:SetHeight(height)
    GetHandleFrame(self):SetHeight(tonumber(height));
end

function HANDLE:SetScale(scale)
    GetHandleFrame(self):SetScale(tonumber(scale));
end

function HANDLE:SetAlpha(alpha)
    GetHandleFrame(self):SetAlpha(tonumber(alpha));
end

local _set_points = {
    TOP=true; BOTTOM=true; LEFT=true; RIGHT=true; CENTER=true;
    TOPLEFT=true; BOTTOMLEFT=true; TOPRIGHT=true; BOTTOMRIGHT=true;
};

function HANDLE:ClearAllPoints()
    GetHandleFrame(self):ClearAllPoints();
end

function HANDLE:SetPoint(point, relframe, relpoint, xofs, yofs)
    if (type(relpoint) == "number") then
        relpoint, xofs, yofs = nil, relpoint, xofs;
    end
    if (relpoint == nil) then
        relpoint = point;
    end
    if ((xofs == nil) and (yofs == nil)) then
        xofs, yofs = 0, 0;
    else
        xofs, yofs = tonumber(xofs), tonumber(yofs);
    end
    if (not _set_points[point]) then
        error("Invalid point '" .. tostring(point) .. "'");
        return;
    end
    if (not _set_points[relpoint]) then
        error("Invalid relative point '" .. tostring(relpoint) .. "'");
        return;
    end
    if (not (xofs and yofs)) then
        error("Invalid offset");
        return
    end

    local frame = GetHandleFrame(self);

    local realrelframe = nil;
    if (type(relframe) == "userdata") then
        -- **MUST** be protected
        realrelframe = GetFrameHandleFrame(relframe, true, true);
        if (not realrelframe) then
            error("Invalid relative frame handle");
            return;
        end
    elseif ((relframe == nil) or (relframe == "$screen")) then
        realrelframe = nil;
    elseif (relframe == "$cursor") then
        local cx, cy = GetCursorPosition();
        local eff = frame:GetEffectiveScale();
        xofs = xofs + (cx / eff);
        yofs = yofs + (cy / eff);
        relpoint = "BOTTOMLEFT";
        realrelframe = nil;
    elseif (relframe == "$parent") then
        realrelframe = frame:GetParent();
    else
        error("Invalid relative frame id '" .. tostring(relframe) .. "'");
        return;
    end

    frame:SetPoint(point, realrelframe, relpoint, xofs, yofs);
end

function HANDLE:SetAllPoints(relframe)
    local frame = GetHandleFrame(self);

    local realrelframe = nil;
    if (type(relframe) == "userdata") then
        realrelframe = GetFrameHandleFrame(relframe, true, true);
        if (not realrelframe) then
            error("Invalid relative frame handle");
            return;
        end
    elseif ((relframe == nil) or (relframe == "$screen")) then
        realrelframe = nil;
    elseif (relframe == "$parent") then
        realrelframe = frame:GetParent();
    else
        error("Invalid relative frame id '" .. tostring(relframe) .. "'");
        return;
    end

    frame:SetAllPoints(realrelframe);
end

function HANDLE:SetAttribute(name, value)
    if (type(name) ~= "string" or name:match("^_")) then
        error("Invalid attribute name");
        return;
    end
    local tv = type(value);
    if (tv ~= "string" and tv ~= "nil" and tv ~= "number"
        and tv ~= "boolean") then
        if (not (tv == "userdata" and IsFrameHandle(value))) then
            error("Invalid attribute value");
            return;
        end
    end
    GetHandleFrame(self):SetAttribute(name, value);
end

function HANDLE:ClearBindings()
    ClearOverrideBindings(GetHandleFrame(self));
end

function HANDLE:ClearBinding(key)
    SetOverrideBinding(GetHandleFrame(self), true, key, nil);
end

function HANDLE:SetBindingClick(priority, key, name, button)
    local tn = type(name);
    if (tn == "userdata") then
        if (IsFrameHandle(name)) then
            name = name:GetName();
            tn = type(name);
        end
    end
    if (tn ~= "string" or name:match(":")) then
        error("Invalid click target name");
        return;
    end
    if ((button ~= nil) and type(button) ~= "string") then
        error("Invalid button name");
        return;
    end
    SetOverrideBindingClick(GetHandleFrame(self), priority, key, name, button);
end

function HANDLE:SetBinding(priority, key, action)
    if (action ~= nil and type(action) ~= "string") then
        error("Invalid binding action");
        return;
    end
    SetOverrideBinding(GetHandleFrame(self), priority, key, action);
end

function HANDLE:SetBindingSpell(priority, key, spell)
    if (type(spell) ~= "string") then
        error("Invalid binding spell");
        return;
    end
    SetOverrideBindingSpell(GetHandleFrame(self), priority, key, spell);
end

function HANDLE:SetBindingMacro(priority, key, macro)
    if (type(macro) == "number") then
        macro = tostring(macro);
    elseif (type(macro) ~= "string") then
        error("Invalid binding macro");
        return;
    end
    SetOverrideBindingMacro(GetHandleFrame(self), priority, key, macro);
end

function HANDLE:SetBindingItem(priority, key, item)
    if (type(item) ~= "string") then
        error("Invalid binding item");
        return;
    end
    SetOverrideBindingItem(GetHandleFrame(self), priority, key, item);
end

function HANDLE:Raise()
    GetHandleFrame(self):Raise();
end

function HANDLE:Lower()
    GetHandleFrame(self):Lower();
end

function HANDLE:SetFrameLevel(level)
    GetHandleFrame(self):SetFrameLevel(tonumber(level));
end

function HANDLE:SetFrameStrata(strata)
    GetHandleFrame(self):SetFrameStrata(tostring(strata));
end

function HANDLE:SetParent(handle)
    local parent = nil;
    if (handle ~= nil) then
        if (type(handle) ~= "userdata") then
            error("Invalid frame handle for SetParent");
            return;
        end
        parent = GetFrameHandleFrame(handle, true, true);
        if (not parent) then
            error("Invalid frame handle for SetParent");
            return;
        end
    end

    GetHandleFrame(self):SetParent(parent);
end

function HANDLE:EnableMouse(isEnabled)
    GetHandleFrame(self):EnableMouse((isEnabled and true) or false);
end

function HANDLE:EnableKeyboard(isEnabled)
    GetHandleFrame(self):EnableKeyboard((isEnabled and true) or false);
end

function HANDLE:RegisterAutoHide(duration)
    RegisterAutoHide(GetHandleFrame(self), tonumber(duration));
end

function HANDLE:UnregisterAutoHide()
    UnregisterAutoHide(GetHandleFrame(self));
end

function HANDLE:AddToAutoHide(handle)
    if (type(handle) ~= "userdata") then
        error("Invalid frame handle for AddToAutoHide");
        return;
    end

    local child = GetFrameHandleFrame(handle, true, true);
    if (not child) then
        error("Invalid frame handle for AddToAutoHide");
        return;
    end

    AddToAutoHide(GetHandleFrame(self), child);
end

---------------------------------------------------------------------------
-- Type specific methods

function HANDLE:Disable()
    local frame = GetHandleFrame(self);
    if (not frame:IsObjectType("Button")) then
        error("Frame is not a Button");
        return;
    end
    frame:Disable();
end

function HANDLE:Enable()
    local frame = GetHandleFrame(self);
    if (not frame:IsObjectType("Button")) then
        error("Frame is not a Button");
        return;
    end
    frame:Enable();
end

---------------------------------------------------------------------------
-- Control handle methods

-- SoftError(message)
-- Report an error message without stopping execution
local function SoftError_inner(message)
    local func = geterrorhandler();
    func(message);
end

local function SoftError(message)
    securecall(pcall, SoftError_inner, message);
end

function HANDLE:Run(body, ...)
    local frame = GetHandleFrame(self);
    if (not frame) then
        error("Invalid control handle");
        return;
    end
    if (type(body) ~= "string") then
        error("Invalid function body");
        return;
    end
    local env = GetManagedEnvironment(frame, true);
    local selfHandle = GetFrameHandle(frame, true);
    if (not selfHandle) then
        -- NOTE: This should never actually happen since the frame must
        -- be protected to have an environment or control!
        return;
    end
    return scrub(CallRestrictedClosure("self,...",
                                       env, self, body, self, ...));
end

function HANDLE:RunFor(otherHandle, body, ...)
    local frame = GetHandleFrame(self);
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
    local env = GetManagedEnvironment(frame, true);
    return scrub(CallRestrictedClosure("self,...",
                                       env, self, body, otherHandle, ...));
end

function HANDLE:RunAttribute(snippetAttr, ...)
    local frame = GetHandleFrame(self);
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
    local env = GetManagedEnvironment(frame, true);
    local selfHandle = GetFrameHandle(frame, true);
    if (not selfHandle) then
        -- NOTE: This should never actually happen since the frame must
        -- be protected to have an environment or control!
        return
    end
    return scrub(CallRestrictedClosure("self,...",
                                       env, self, body, self, ...));
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

function HANDLE:ChildUpdate(snippetid, message)
    local frame = GetHandleFrame(self);
    if (not frame) then
        error("Invalid control handle");
        return;
    end
    local env = GetManagedEnvironment(frame, true);
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
function HANDLE:CallMethod(methodName, ...)
    local frame = GetHandleFrame(self);
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

---------------------------------------------------------------------------
-- Callback to initialize handle, discard initializer once used

InitFrameHandleNamespace(HANDLE)
InitFrameHandleNamespace = nil;
