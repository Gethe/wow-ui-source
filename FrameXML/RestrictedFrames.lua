-- RestrictedFrames.lua (Part of the new Secure Headers implementation)
--
-- Handle objects to access frames during restricted execution in order to
-- allow safe manipulation of frame properties. These handles can be passed
-- around safely without allowing their destinations or functions to be
-- tampered with.
--
-- Daniel Stephens (iriel@vigilance-committee.org)
-- Nevin Flanagan (alestane@comcast.net)
--
-- The design consists of several components...
--
-- HANDLES: These are lightweight userdata objects with a shared metatable
--          that stand in for frames. They're persistent once created (i.e.
--          a given frame always has the same handle). Internally these map
--          to a 'copied' frame object. Only explcitly protected frames can
--          be assigned handles.
--
-- METHODS: The handler methods are contained in a table which is then set
--          as the __index on the handlers. These are in two groups, there
--          are 'read' methods that may be blocked in some situations, and
--          there are 'write' methods which simply require that an execution
--          is active.
--
-- Various methods (SetPoint/SetParent) take frame handles as relative
-- frame arguments also. You can safely obtain frame handles (out of combat)
-- by setting the '_frame-<id>' attribute on a header frame to the frame
-- you want a handle to, and it'll set the 'frameref-<id>' attribute to be
-- the handle to that frame (or nil if it's invalid or unprotected).
-- This handle can then be retrieved using a GetAttribute call.
---------------------------------------------------------------------------

local issecure = issecure;
local select = select;
local type = type;
local unpack = unpack;
local wipe = wipe;
local pairs = pairs;
local newproxy = newproxy;
local error = error;
local tostring = tostring;
local tonumber = tonumber;
local string = string;
local rawget = rawget;
local securecall = securecall;
local GetCursorPosition = GetCursorPosition;
local InCombatLockdown = InCombatLockdown;

---------------------------------------------------------------------------
-- Frame Handles -- Userdata handles referencing explicitly protected frames
--
-- LOCAL_FrameHandle_Protected_Frames -- handle keys, frame surrogate values
--                                       (explicitly protected)
-- LOCAL_FrameHandle_Other_Frames -- handle keys, frame surrogate values
--                                   (possibly protected)
-- LOCAL_FrameHandle_Lookup -- frame keys, handle values
--
-- The lookup table auto-populates via an __index metamethod

local LOCAL_FrameHandle_Protected_Frames = {};
local LOCAL_FrameHandle_Other_Frames = {};
local LOCAL_FrameHandle_Lookup = {};
setmetatable(LOCAL_FrameHandle_Protected_Frames, { __mode = "k" });
setmetatable(LOCAL_FrameHandle_Other_Frames, { __mode = "k" });

-- Setup metatable for prototype object
local LOCAL_FrameHandle_Prototype = newproxy(true);
-- HANDLE is the frame handle method namespace (populated below)
local HANDLE = {};
do
    local meta = getmetatable(LOCAL_FrameHandle_Prototype);
    meta.__index = HANDLE;
    meta.__metatable = false;
end

function IsFrameHandle(handle, protected)
    local surrogate = LOCAL_FrameHandle_Protected_Frames[handle];
    if ((surrogate == nil) and not protected) then
        surrogate = LOCAL_FrameHandle_Other_Frames[handle];
    end
    return (surrogate ~= nil);
end

function GetFrameHandleFrame(handle, protected)
    local surrogate = LOCAL_FrameHandle_Protected_Frames[handle];
    if ((surrogate == nil) and (not protected or not InCombatLockdown())) then
        surrogate = LOCAL_FrameHandle_Other_Frames[handle];
    end
    if (surrogate ~= nil) then
        return surrogate[1];
    end
end

local function FrameHandleLookup_index(t, frame)
    -- Create a 'surrogate' frame object
    local surrogate = { [0] = frame[0], [1] = frame };
    setmetatable(surrogate, getmetatable(frame));
    -- Test whether the frame is explcitly protected
    local _, protected = surrogate:IsProtected();
    if (not issecure()) then
        return;
    end
    local handle = newproxy(LOCAL_FrameHandle_Prototype);
    LOCAL_FrameHandle_Lookup[frame] = handle;
    if (protected) then
        LOCAL_FrameHandle_Protected_Frames[handle] = surrogate;
    else
        LOCAL_FrameHandle_Other_Frames[handle] = surrogate;
    end
    return handle;
end
setmetatable(LOCAL_FrameHandle_Lookup, { __index = FrameHandleLookup_index; });

-- Gets the handle for a frame (if available)
function GetFrameHandle(frame, protected)
    local handle = LOCAL_FrameHandle_Lookup[frame];
    if (protected and (frame ~= nil)) then
        if (not LOCAL_FrameHandle_Protected_Frames[handle]) then
            return nil;
        end
    end
    return handle;
end

---------------------------------------------------------------------------
-- Action implementation support function
--
-- GetHandleFrame -- Get the frame for a handle

local function GetUnprotectedHandleFrame(handle)
    local frame = LOCAL_FrameHandle_Protected_Frames[handle];
    if (not frame) then
        frame = LOCAL_FrameHandle_Other_Frames[handle];
        if (not frame) then
            error("Invalid frame handle");
            return;
        end
    end
    return frame;
end

local function GetHandleFrame(handle)
    local frame = LOCAL_FrameHandle_Protected_Frames[handle];
    if (not frame) then
        frame = LOCAL_FrameHandle_Other_Frames[handle];
        if (frame) then
            if (frame:IsProtected() or not InCombatLockdown()) then
                return frame;
            end
        end
        error("Invalid frame handle");
        return;
    end
    return frame;
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
    return GetHandleFrame(self):GetFrameLevel()  end
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
    if (tv == "userdata" and
        (LOCAL_FrameHandle_Protected_Frames[val]
         or LOCAL_FrameHandle_Other_Frames[val])) then
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
    if (tv == "userdata" and
        (LOCAL_FrameHandle_Protected_Frames[val]
         or LOCAL_FrameHandle_Other_Frames[val])) then
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
    if (tv == "userdata" and
        (LOCAL_FrameHandle_Protected_Frames[val]
         or LOCAL_FrameHandle_Other_Frames[val])) then
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
        frame = LOCAL_FrameHandle_Lookup[frame];
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
            frame = LOCAL_FrameHandle_Lookup[frame];
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
        realrelframe = LOCAL_FrameHandle_Protected_Frames[relframe];
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
        realrelframe = LOCAL_FrameHandle_Protected_Frames[relframe];
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
        if (not (tv == "userdata" and
                 (LOCAL_FrameHandle_Protected_Frames[value]
                  or LOCAL_FrameHandle_Other_Frames[value]))) then
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
        if (LOCAL_FrameHandle_Protected_Frames[name]
            or LOCAL_FrameHandle_Other_Frames[name]) then
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

function HANDLE:SetParent(handle)
    local parent = nil;
    if (handle ~= nil) then
        if (type(handle) ~= "userdata") then
            error("Invalid frame handle for SetParent");
            return;
        end
        parent = LOCAL_FrameHandle_Protected_Frames[handle];
        if (not parent) then
            error("Invalid frame handle for SetParent");
            return;
        end
    end

    GetHandleFrame(self):SetParent(parent);
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

    local child = LOCAL_FrameHandle_Protected_Frames[handle];
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
