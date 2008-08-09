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

---------------------------------------------------------------------------
-- Pooled Work Tables -- Used for parameter and action lists
--
-- PARAMETER tables have numeric keys and are used to store positional args
--
-- ACTION tables have arbitrary (hash) keys and are used to store action
-- lists and keyed arguments
--[[
local SPARE_PARAM_TABLES = {};
local SPARE_PARAM_COUNT = 0;

local function FreeParamTable(t)
    wipe(t);
    if (issecure()) then
        SPARE_PARAM_COUNT = SPARE_PARAM_COUNT + 1;
        SPARE_PARAM_TABLES[SPARE_PARAM_COUNT] = t;
    end
end

local function NewParamTable(...)
    local t;
    if (issecure() and SPARE_PARAM_COUNT > 0) then
        t = SPARE_PARAM_TABLES[SPARE_PARAM_COUNT];
        SPARE_PARAM_TABLES[SPARE_PARAM_COUNT] = nil;
        SPARE_PARAM_COUNT = SPARE_PARAM_COUNT - 1;
    else
        t = {};
    end
    for i = 1, select('#', ...) do
        t[i] = select(i, ...);
    end
    return t;
end

local SPARE_ACTION_TABLES = {};
local SPARE_ACTION_COUNT = 0;

local function FreeActionTable(t)
    wipe(t);
    if (issecure()) then
        SPARE_ACTION_COUNT = SPARE_ACTION_COUNT + 1;
        SPARE_ACTION_TABLES[SPARE_ACTION_COUNT] = t;
    end
end

local function NewActionTable()
    local t;
    if (issecure() and SPARE_ACTION_COUNT > 0) then
        t = SPARE_ACTION_TABLES[SPARE_ACTION_COUNT];
        SPARE_ACTION_TABLES[SPARE_ACTION_COUNT] = nil;
        SPARE_ACTION_COUNT = SPARE_ACTION_COUNT - 1;
    else
        t = {};
    end
    return t;
end
]]
---------------------------------------------------------------------------
-- Frame Handles -- Userdata handles referencing explicitly protected frames
--
-- _frame_handle_frames -- handle keys, frame surrogate values
-- _frame_handle_lookup -- protected frame keys, handle values
--
-- The lookup table auto-populates via an __index metamethod

local _frame_handle_frames = {};
local _frame_handle_lookup = {};
setmetatable(_frame_handle_frames, { __mode = "k" });

-- Setup metatable for prototype object
local _frame_handle_prototype = newproxy(true);
-- HANDLE is the frame handle method namespace (populated below)
local HANDLE = {};
do
    local meta = getmetatable(_frame_handle_prototype);
    meta.__index = HANDLE;
    meta.__metatable = false;
end

function IsFrameHandle(handle)
    local handle = _frame_handle_frames[handle];
    if (handle ~= nil) then
        return true, handle[1];
    end
end

local function FrameHandleLookup_index(t, frame)
    -- Verify the frame is actually protected
    local _, protect = frame:IsProtected();
    if (not protect) then
        error("Cannot get a handle for an unprotected frame");
        return;
    end
    if (not issecure()) then
        return;
    end
    -- Create a 'surrogate' frame object
    local surrogate = { [0] = frame[0], [1] = frame };
    setmetatable(surrogate, getmetatable(frame));
    -- Re-verify the frame is actually protected (avoids some hijinks)
    local _, protect = surrogate:IsProtected();
    if (not protect and issecure()) then
        return;
    end
    local handle = newproxy(_frame_handle_prototype);
    _frame_handle_lookup[frame] = handle;
    _frame_handle_frames[handle] = surrogate;
    return handle;
end
setmetatable(_frame_handle_lookup, { __index = FrameHandleLookup_index; });

-- Gets the handle for a frame (if available)
function GetFrameHandle(frame)
    return _frame_handle_lookup[frame];
end

---------------------------------------------------------------------------
-- Management of current (and nested) execution states
--
-- The BeginFrameActions / EndFrameActions pair start and stop activity
-- and write-only status.
-- If something goes wrong then they'll obliterate the stored scope and try
-- and start again.
--
-- EndFrameActions will also (unless directed not to) execute any pending
-- actions for the current namespace.

local _status_history = {};
local _status_depth = 0;

local _current_active = nil;
local _current_readok = nil;

function BeginFrameActions(readok)
    local status = (readok and true) or false;

    if (not issecure()) then
        error("Cannot begin frame actions from insecure code");
        return;
    end

    _status_depth = _status_depth + 1;
    _status_history[_status_depth] = _current_readok;

    _current_active = true;
    _current_readok = status;
end

local function ResetFrameActions()
    wipe(_status_history);
    _current_active = nil;
    _current_readok = nil;
end

function EndFrameActions(readok)
    local status = (readok and true) or false;

    if (not issecure()) then
        -- This is unrecoverable, at least discard the old
        -- history
        ResetFrameActions();
        error("Insecure call to end frame actions!");
        return;
    end

    if (status ~= _current_readok) then
        if (_current_readok == nil) then
            -- Still recovering from earlier reset
            return;
        end

        ResetFrameActions();
        error("Frame action nesting mismatch");
        return;
    end

    if (_status_depth <= 0) then
        _current_active = true;
        _current_readok = true;
        wipe(_status_history);
        _status_depth = 0;
    else
        _current_readok = _status_history[_status_depth];
        _current_active = (_current_readok ~= nil);
        _status_history[_status_depth] = nil;
        _status_depth = _status_depth - 1;
    end
end

---------------------------------------------------------------------------
-- Action implementation support functions
--
-- GetReadFrame -- Get the frame for a handle (if read methods are allowed)
-- GetWriteFrame -- Get the frame for a handle (if write methods are allowed)
-- GetAlwaysReadFrame -- Get the frame for a handle (always) -- Only use this
--                       for methods that return immutable data

local function GetReadFrame(handle)
    local frame = _frame_handle_frames[handle];
    if (not frame) then
        error("Invalid frame handle");
        return;
    end
    if ((not _current_readok) and issecure()) then
        error("Method blocked during protected execution");
        return;
    end
    return frame;
end

local function GetWriteFrame(handle)
    local frame = _frame_handle_frames[handle];
    if (not frame) then
        error("Invalid frame handle");
        return;
    end
    if ((not _current_active) and issecure()) then
        error("Method blocked during protected execution");
        return;
    end
    return frame;
end

local function GetAlwaysReadFrame(handle)
    local frame = _frame_handle_frames[handle];
    if (not frame) then
        error("Invalid frame handle");
        return;
    end
    return frame;
end

---------------------------------------------------------------------------
-- "GETTER" methods

function HANDLE:GetName()   return GetAlwaysReadFrame(self):GetName() end

function HANDLE:GetID()     return GetReadFrame(self):GetID()     end
function HANDLE:IsShown()   return GetReadFrame(self):IsShown()   end
function HANDLE:IsVisible() return GetReadFrame(self):IsVisible() end
function HANDLE:GetWidth()  return GetReadFrame(self):GetWidth()  end
function HANDLE:GetHeight() return GetReadFrame(self):GetHeight() end
function HANDLE:GetScale()  return GetReadFrame(self):GetScale()  end
function HANDLE:GetEffectiveScale()
    return GetReadFrame(self):GetEffectiveScale()
end
-- Cannot expose GetAlpha since alpha is not protected
function HANDLE:GetFrameLevel()  return GetReadFrame(self):GetFrameLevel()  end


function HANDLE:GetAttribute(name)
    if (type(name) ~= "string" or name:match("^_")) then
        return;
    end
    local val = GetReadFrame(self):GetAttribute(name)
    local tv = type(val);
    if (tv == "string" or tv == "number" or tv == "boolean" or val == nil) then
        return val;
    end
    if (tv == "userdata" and _frame_handle_frames[val]) then
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
    local val = SecureButton_GetModifiedAttribute(GetReadFrame(self),
                                                  name, button, prefix,
                                                  suffix);
    local tv = type(val);
    if (tv == "string" or tv == "number" or tv == "boolean" or val == nil) then
        return val;
    end
    if (tv == "userdata" and _frame_handle_frames[val]) then
        return val;
    end
    return nil;
end


local FrameHandleMapper;
function FrameHandleMapper(frame, nextFrame, ...)
    if (not frame) then
        return;
    end
    -- Do an explicit protection check to avoid errors from
    -- the frame handle lookup
    local _, p = frame:IsProtected();
    if (p) then
        frame = _frame_handle_lookup[frame];
        if (frame) then
            if (nextFrame) then
                return frame, FrameHandleMapper(nextFrame, ...);
            else
                return frame;
            end
        end
    end
    if (nextFrame) then
        return FrameHandleMapper(nextFrame, ...);
    end
end

function HANDLE:GetChildren()
    return FrameHandleMapper(GetReadFrame(self):GetChildren());
end

function HANDLE:GetParent()
    return FrameHandleMapper(GetReadFrame(self):GetParent());
end

-- NOTE: Cannot allow the frame to figure out if it has mouse focus
-- because an insecure frame could be appearing on top of it.

function HANDLE:GetMousePosition()
    local frame = GetReadFrame(self);
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
-- Only check protected children
local RF_CheckUnderMouse;
function RF_CheckUnderMouse(x, y, ...)
    for i = 1, select('#', ...) do
        local frame = select(i, ...);
        if (frame and frame:IsProtected()) then
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
    local frame = GetReadFrame(self);
    local x, y = GetCursorPosition();
    local l, b, w, h = frame:GetRect()
    if (not w or not h) then return nil; end
    local e = frame:GetEffectiveScale();
    local fx = x / e - l;
    if ((fx >= 0) and (fx <= w)) then
        local fy = y / e - b;
        if ((fy >= 0) and (fy <= h)) then return true; end
    end
    if (not recursive) then
        return;
    end
    return RF_CheckUnderMouse(x, y, frame:GetChildren());
end

---------------------------------------------------------------------------
-- "SETTER" methods and actions

function HANDLE:Show()
    local frame = GetWriteFrame(self);
    frame:Show();
    frame:SetAttribute("statehidden", nil);
end

function HANDLE:Hide()
    local frame = GetWriteFrame(self);
    frame:Hide();
    frame:SetAttribute("statehidden", true);
end

function HANDLE:SetID(id)
    GetWriteFrame(self):SetID(tonumber(id) or 0);
end

function HANDLE:SetWidth(width)
    GetWriteFrame(self):SetWidth(tonumber(width));
end

function HANDLE:SetHeight(height)
    GetWriteFrame(self):SetHeight(tonumber(height));
end

function HANDLE:SetScale(scale)
    GetWriteFrame(self):SetScale(tonumber(scale));
end

function HANDLE:SetAlpha(alpha)
    GetWriteFrame(self):SetAlpha(tonumber(alpha));
end

local _set_points = {
    TOP=true; BOTTOM=true; LEFT=true; RIGHT=true; CENTER=true;
    TOPLEFT=true; BOTTOMLEFT=true; TOPRIGHT=true; BOTTOMRIGHT=true;
};

function HANDLE:ClearAllPoints()
    GetWriteFrame(self):ClearAllPoints();
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

    local frame = GetWriteFrame(self);

    local realrelframe = nil;
    if (type(relframe) == "userdata") then
        realrelframe = _frame_handle_frames[relframe];
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

function HANDLE:SetAttribute(name, value)
    if (type(name) ~= "string" or name:match("^_")) then
        error("Invalid attribute name");
        return;
    end
    local tv = type(value);
    if (tv ~= "string" and tv ~= "nil" and tv ~= "number"
        and tv ~= "boolean") then
        if (not (tv == "userdata" and _frame_handle_frames[value])) then
            error("Invalid attribute value");
            return;
        end
    end
    GetWriteFrame(self):SetAttribute(name, value);
end

function HANDLE:SetBindingClick(priority, key, name, button)
    local tn = type(name);
    if (tn == "userdata") then
        if (_frame_handle_frames[name]) then
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
    SetOverrideBindingClick(GetWriteFrame(self), priority, key, name, button);
end

function HANDLE:SetBinding(priority, key, action)
    if (type(action) ~= "string") then
        error("Invalid binding action");
        return;
    end
    SetOverrideBinding(GetWriteFrame(self), priority, key, action);
end

function HANDLE:SetBindingSpell(priority, key, spell)
    if (type(spell) ~= "string") then
        error("Invalid binding spell");
        return;
    end
    SetOverrideBindingSpell(GetWriteFrame(self), priority, key, spell);
end

function HANDLE:SetBindingMacro(priority, key, macro)
    if (type(macro) == "number") then
        macro = tostring(macro);
    elseif (type(macro) ~= "string") then
        error("Invalid binding macro");
        return;
    end
    SetOverrideBindingMacro(GetWriteFrame(self), priority, key, macro);
end

function HANDLE:SetBindingItem(priority, key, item)
    if (type(item) ~= "string") then
        error("Invalid binding item");
        return;
    end
    SetOverrideBindingItem(GetWriteFrame(self), priority, key, item);
end

function HANDLE:Raise()
    GetWriteFrame(self):Raise();
end

function HANDLE:Lower()
    GetWriteFrame(self):Lower();
end

function HANDLE:SetFrameLevel(level)
    GetWriteFrame(self):SetFrameLevel(tonumber(level));
end

function HANDLE:SetParent(handle)
    local parent = nil;
    if (handle ~= nil) then
        if (type(handle) ~= "userdata") then
            error("Invalid frame handle for SetParent");
            return;
        end
        parent = _frame_handle_frames[handle];
        if (not parent) then
            error("Invalid frame handle for SetParent");
            return;
        end
    end

    local frame = GetWriteFrame(self);
    frame:SetParent(parent);
end
