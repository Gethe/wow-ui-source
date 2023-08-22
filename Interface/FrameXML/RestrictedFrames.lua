-- RestrictedFrames.lua (Part of the new Secure Headers implementation)
--
-- Provides the method definitions for restricted frames.
-- See RestrictedInfrastructure.lua for more details.
--
-- Daniel Stephens
-- Nevin Flanagan
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

local AddReferencedFrame = AddReferencedFrame;
local PropagateForbiddenToReferencedFrames = PropagateForbiddenToReferencedFrames;

local forceinsecure = forceinsecure;
local scrub = scrub;
local pcall = pcall;

---------------------------------------------------------------------------
-- Frame Handles -- Userdata handles referencing explicitly protected frames
-- Handle support is in RestrictedInfrastructure

-- HANDLE is the frame handle method namespace (populated below)
local HANDLE = {};

local LOCAL_CHECK_Button = CopyTable(GetButtonMetatable().__index);
local LOCAL_CHECK_Frame = CopyTable(GetFrameMetatable().__index);

local function CheckForbidden(frame)
	return LOCAL_CHECK_Frame.IsForbidden(frame);
end

local function MakeForbidden(frame)
	LOCAL_CHECK_Frame.SetForbidden(frame);
end

---------------------------------------------------------------------------
-- Action implementation support function
--
-- GetUnprotectedHandleFrame -- Get the frame for a handle (always)
-- GetHandleFrame -- Get the frame for a handle that could accept a protected
--                   action (i.e. is protected, or we're not in combat)

local function GetUnprotectedHandleFrame(handle)
    local frame = GetFrameHandleFrame(handle);
    if (frame) then
		AddReferencedFrame(frame);

        return frame;
    end
    error("Invalid frame handle");
end

local function GetPossiblyForbiddenHandleFrame(handle)
    local frame, isProtected = GetFrameHandleFrame(handle);
    if (frame and (isProtected
                   or (LOCAL_CHECK_Frame.IsProtected(frame) or not InCombatLockdown()))) then
        return frame;
    end
    error("Invalid frame handle");
end

local function GetHandleFrame(handle)
	local frame = GetPossiblyForbiddenHandleFrame(handle);
	if (frame) then
		AddReferencedFrame(frame);

		if (CheckForbidden(frame)) then
			PropagateForbiddenToReferencedFrames();
		else
			return frame;
		end
	end
    error("Invalid frame handle");
end

---------------------------------------------------------------------------
-- "GETTER" methods

function HANDLE:GetName()   return LOCAL_CHECK_Frame.GetName(GetUnprotectedHandleFrame(self)) end

function HANDLE:GetID()     return LOCAL_CHECK_Frame.GetID(GetHandleFrame(self));     end
function HANDLE:IsShown()   return LOCAL_CHECK_Frame.IsShown(GetHandleFrame(self));   end
function HANDLE:IsVisible() return LOCAL_CHECK_Frame.IsVisible(GetHandleFrame(self)); end
function HANDLE:GetWidth()  return LOCAL_CHECK_Frame.GetWidth(GetHandleFrame(self));  end
function HANDLE:GetHeight() return LOCAL_CHECK_Frame.GetHeight(GetHandleFrame(self)); end
function HANDLE:GetScale()  return LOCAL_CHECK_Frame.GetScale(GetHandleFrame(self));  end
function HANDLE:GetEffectiveScale()
    return LOCAL_CHECK_Frame.GetEffectiveScale(GetHandleFrame(self))
end

function HANDLE:GetRect()
	local frame = GetHandleFrame(self);
	if LOCAL_CHECK_Frame.IsAnchoringRestricted(frame) then
		return nil;
	end

	return LOCAL_CHECK_Frame.GetRect(frame);
end

-- Cannot expose GetAlpha since alpha is not protected

function HANDLE:GetFrameLevel()
    return LOCAL_CHECK_Frame.GetFrameLevel(GetHandleFrame(self));
end

function HANDLE:GetFrameStrata()
    return LOCAL_CHECK_Frame.GetFrameStrata(GetHandleFrame(self));
end

function HANDLE:IsMouseEnabled()
    return LOCAL_CHECK_Frame.IsMouseEnabled(GetHandleFrame(self));
end

function HANDLE:IsMouseClickEnabled()
    return LOCAL_CHECK_Frame.IsMouseClickEnabled(GetHandleFrame(self));
end

function HANDLE:IsMouseMotionEnabled()
    return LOCAL_CHECK_Frame.IsMouseMotionEnabled(GetHandleFrame(self));
end

function HANDLE:IsKeyboardEnabled()
    return LOCAL_CHECK_Frame.IsKeyboardEnabled(GetHandleFrame(self));
end

function HANDLE:IsGamePadButtonEnabled()
    return LOCAL_CHECK_Frame.IsGamePadButtonEnabled(GetHandleFrame(self));
end

function HANDLE:IsGamePadStickEnabled()
    return LOCAL_CHECK_Frame.IsGamePadStickEnabled(GetHandleFrame(self));
end

function HANDLE:GetObjectType()
    return LOCAL_CHECK_Frame.GetObjectType(GetUnprotectedHandleFrame(self))
end

function HANDLE:IsObjectType(ot)
    return LOCAL_CHECK_Frame.IsObjectType(GetUnprotectedHandleFrame(self), tostring(ot))
end

function HANDLE:IsProtected()
    return LOCAL_CHECK_Frame.IsProtected(GetUnprotectedHandleFrame(self));
end


function HANDLE:GetAttribute(name)
    if (type(name) ~= "string" or name:match("^_")) then
        return;
    end
    local val = LOCAL_CHECK_Frame.GetAttribute(GetHandleFrame(self), name)
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
    local val = LOCAL_CHECK_Frame.GetAttribute(GetHandleFrame(self), "frameref-" .. label);
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

local function ShouldAllowAccessToFrame(nolockdown, frame)
	if LOCAL_CHECK_Frame.IsForbidden(frame) then
		return false;
	end

	if not nolockdown then
        return LOCAL_CHECK_Frame.IsProtected(frame);
    end

    return nolockdown;
end

local function GetValidatedFrameHandle(nolockdown, frame)
	if ShouldAllowAccessToFrame(nolockdown, frame) then
		return GetFrameHandle(frame);
	end

	return nil;
end


local function FrameHandleMapper(nolockdown, frame, nextFrame, ...)
    if (not frame) then
        return;
    end

    frame = GetValidatedFrameHandle(nolockdown, frame);

    if frame then
        if (nextFrame) then
            return frame, FrameHandleMapper(nolockdown, nextFrame, ...);
        else
            return frame;
        end
    end

    if (nextFrame) then
        return FrameHandleMapper(nolockdown, nextFrame, ...);
    end
end

local function FrameHandleInserter(nolockdown, result, ...)
    local idx = #result;
    for i = 1, select('#', ...) do
        local frame = GetValidatedFrameHandle(nolockdown, select(i, ...));
        if frame then
			idx = idx + 1;
			result[idx] = frame;
        end
    end

    return result;
end

function HANDLE:GetChildren()
    return FrameHandleMapper(not InCombatLockdown(), LOCAL_CHECK_Frame.GetChildren(GetHandleFrame(self)));
end

function HANDLE:GetChildList(tbl)
    return FrameHandleInserter(not InCombatLockdown(), tbl, LOCAL_CHECK_Frame.GetChildren(GetHandleFrame(self)));
end

function HANDLE:GetParent()
    return FrameHandleMapper(not InCombatLockdown(), LOCAL_CHECK_Frame.GetParent(GetHandleFrame(self)));
end

-- NOTE: Cannot allow the frame to figure out if it has mouse focus
-- because an insecure frame could be appearing on top of it.

function HANDLE:GetMousePosition()
    local frame = GetHandleFrame(self);
    local x, y = GetCursorPosition()
    local l, b, w, h = LOCAL_CHECK_Frame.GetRect(frame)
    if (not w or not h or w == 0 or h == 0) then return nil; end
    local e = LOCAL_CHECK_Frame.GetEffectiveScale(frame);
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
        if (frame and LOCAL_CHECK_Frame.IsProtected(frame) and LOCAL_CHECK_Frame.IsVisible(frame)) then
            local l, b, w, h = LOCAL_CHECK_Frame.GetRect(frame)
            if (w and h) then
                local e = LOCAL_CHECK_Frame.GetEffectiveScale(frame);
                local fx = x / e - l;
                if ((fx >= 0) and (fx <= w)) then
                    local fy = y / e - b;
                    if ((fy >= 0) and (fy <= h)) then return true; end
                end
            end
            if (RF_CheckUnderMouse(x, y, LOCAL_CHECK_Frame.GetChildren(frame))) then
                return true;
            end
        end
    end
end

function HANDLE:IsUnderMouse(recursive)
    local frame = GetHandleFrame(self);
    local x, y = GetCursorPosition();
    local l, b, w, h = LOCAL_CHECK_Frame.GetRect(frame)
    if (w and h) then
        local e = LOCAL_CHECK_Frame.GetEffectiveScale(frame);
        local fx = x / e - l;
        if ((fx >= 0) and (fx <= w)) then
            local fy = y / e - b;
            if ((fy >= 0) and (fy <= h)) then return true; end
        end
    end
    if (not recursive) then
        return;
    end
    return RF_CheckUnderMouse(x, y, LOCAL_CHECK_Frame.GetChildren(frame));
end

function HANDLE:GetNumPoints()
    return LOCAL_CHECK_Frame.GetNumPoints(GetHandleFrame(self));
end

function HANDLE:GetPoint(i)
	local frame = GetHandleFrame(self);
	if LOCAL_CHECK_Frame.IsAnchoringRestricted(frame) then
		return nil;
	end

    local point, frame, relative, dx, dy = LOCAL_CHECK_Frame.GetPoint(frame, i);
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
    LOCAL_CHECK_Frame.Show(frame);
    if (not skipAttr) then
        LOCAL_CHECK_Frame.SetAttribute(frame, "statehidden", nil);
    end
end

function HANDLE:Hide(skipAttr)
    local frame = GetHandleFrame(self);
    LOCAL_CHECK_Frame.Hide(frame);
    if (not skipAttr) then
        LOCAL_CHECK_Frame.SetAttribute(frame, "statehidden", true);
    end
end

function HANDLE:SetID(id)
    LOCAL_CHECK_Frame.SetID(GetHandleFrame(self), tonumber(id) or 0);
end

function HANDLE:SetWidth(width)
    LOCAL_CHECK_Frame.SetWidth(GetHandleFrame(self), tonumber(width));
end

function HANDLE:SetHeight(height)
    LOCAL_CHECK_Frame.SetHeight(GetHandleFrame(self), tonumber(height));
end

function HANDLE:SetScale(scale)
    LOCAL_CHECK_Frame.SetScale(GetHandleFrame(self), tonumber(scale));
end

function HANDLE:SetAlpha(alpha)
    LOCAL_CHECK_Frame.SetAlpha(GetHandleFrame(self), tonumber(alpha));
end

local _set_points = {
    TOP=true; BOTTOM=true; LEFT=true; RIGHT=true; CENTER=true;
    TOPLEFT=true; BOTTOMLEFT=true; TOPRIGHT=true; BOTTOMRIGHT=true;
};

function HANDLE:ClearAllPoints()
    LOCAL_CHECK_Frame.ClearAllPoints(GetHandleFrame(self));
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
        local eff = LOCAL_CHECK_Frame.GetEffectiveScale(frame);
        xofs = xofs + (cx / eff);
        yofs = yofs + (cy / eff);
        relpoint = "BOTTOMLEFT";
        realrelframe = nil;
    elseif (relframe == "$parent") then
        realrelframe = LOCAL_CHECK_Frame.GetParent(frame);
    else
        error("Invalid relative frame id '" .. tostring(relframe) .. "'");
        return;
    end

    LOCAL_CHECK_Frame.SetPoint(frame, point, realrelframe, relpoint, xofs, yofs);
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
        realrelframe = LOCAL_CHECK_Frame.GetParent(frame);
    else
        error("Invalid relative frame id '" .. tostring(relframe) .. "'");
        return;
    end

    LOCAL_CHECK_Frame.SetAllPoints(frame, realrelframe);
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
    LOCAL_CHECK_Frame.SetAttribute(GetHandleFrame(self), name, value);
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
    LOCAL_CHECK_Frame.Raise(GetHandleFrame(self));
end

function HANDLE:Lower()
    LOCAL_CHECK_Frame.Lower(GetHandleFrame(self));
end

function HANDLE:SetFrameLevel(level)
    LOCAL_CHECK_Frame.SetFrameLevel(GetHandleFrame(self), tonumber(level));
end

function HANDLE:SetFrameStrata(strata)
    LOCAL_CHECK_Frame.SetFrameStrata(GetHandleFrame(self), tostring(strata));
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

    LOCAL_CHECK_Frame.SetParent(GetHandleFrame(self), parent);
end

function HANDLE:EnableMouse(isEnabled)
    LOCAL_CHECK_Frame.EnableMouse(GetHandleFrame(self), (isEnabled and true) or false);
end

function HANDLE:EnableKeyboard(isEnabled)
    LOCAL_CHECK_Frame.EnableKeyboard(GetHandleFrame(self), (isEnabled and true) or false);
end

function HANDLE:EnableGamePadButton(isEnabled)
    LOCAL_CHECK_Frame.EnableGamePadButton(GetHandleFrame(self), (isEnabled and true) or false);
end

function HANDLE:EnableGamePadStick(isEnabled)
    LOCAL_CHECK_Frame.EnableGamePadStick(GetHandleFrame(self), (isEnabled and true) or false);
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
    if (not LOCAL_CHECK_Frame.IsObjectType(frame, "Button")) then
        error("Frame is not a Button");
        return;
    end
    LOCAL_CHECK_Button.Disable(frame);
end

function HANDLE:Enable()
    local frame = GetHandleFrame(self);
    if (not LOCAL_CHECK_Frame.IsObjectType(frame, "Button")) then
        error("Frame is not a Button");
        return;
    end
    LOCAL_CHECK_Button.Enable(frame);
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
    return scrub(CallRestrictedClosure(frame, "self,...",
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
    return scrub(CallRestrictedClosure(frame, "self,...",
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
    local body = LOCAL_CHECK_Frame.GetAttribute(frame, snippetAttr);
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
    return scrub(CallRestrictedClosure(frame, "self,...",
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
        local p = LOCAL_CHECK_Frame.IsProtected(child);
        if (p) then
            local body;
            if (scriptattr) then
                body = LOCAL_CHECK_Frame.GetAttribute(child, scriptattr);
            end
            if (body == nil) then
                body = LOCAL_CHECK_Frame.GetAttribute(child, "_childupdate");
            end
            if (body and type(body) == "string") then
                local selfHandle = GetFrameHandle(child, true);
                if (selfHandle) then
                    CallRestrictedClosure(child, "self,scriptid,message",
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
    ChildUpdate_Helper(env, self, snippetid, message, LOCAL_CHECK_Frame.GetChildren(frame));
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
