-- RestrictedFrames.lua (Part of the new Secure Headers implementation)
--
-- Surrogate objects to stand-in for frames to allow manipulation of frame
-- properies etc during execution.
--
-- Daniel Stephens (iriel@vigilance-committee.org)
-- Nevin Flanagan (alestane@comcast.net)
--
-- The design has:
--
-- METHODS: There's a table with the actual methods on it, which
--          is made essentially immutable.
-- ACTIONS: This is an internal accumulator for pending actions
-- SURROGATE: A table with a blank __newindex, and the METHODS table as
--            its __index.
--
-- There are then a couple of global reference tables
--   SURROGATE_FRAMES -- keyed by surrogate, values are frames
--   SURROGATE_ACTIONS -- keyed by surrogate, values are action tables for
--                       'mutable' surrogates
--
-- The frame is looked up by its surrogate, as are the states. Actions
-- are represented as function-keyed entries into the states table. parameters
-- are represented as the values either in table form (will be unpacked)
-- or as simple values for simple cases.
--
-- Some of the operations allow operations against 'arbitrary' frames, which
-- are identified via 'frameref-<id>' attributes. For those frames to be
-- used they must be explcitly protected.
---------------------------------------------------------------------------

local issecure = issecure;
local select = select;
local type = type;
local unpack = unpack;
local wipe = wipe;

local FRAME_G = { };
local FRAME_S = { };

setmetatable(FRAME_S, { __index = FRAME_G });

local SURROGATE_FRAMES = {};
local SURROGATE_ACTIONS = {};
setmetatable(SURROGATE_FRAMES, { __mode = "k" });
setmetatable(SURROGATE_ACTIONS, { __mode = "k" });

local SURROGATE_METAS = {};
setmetatable(SURROGATE_METAS, { __mode = "k" });

local SPARE_SURROGATES = {
    [FRAME_G] = { count = 0 },
    [FRAME_S] = { count = 0 },
}

local EMPTY_FUNCTION = function() end

local SURROGATE_METAS = {
    [FRAME_G] = {
        __index = FRAME_G, __newindex = EMPTY_FUNCTION, __metatable = false
    },
    [FRAME_S] = {
        __index = FRAME_S, __newindex = EMPTY_FUNCTION, __metatable = false
    },
}

function GetFrameSurrogate(frame, mutable)
    local flavor;
    local surrogate;

    if (mutable) then
        flavor = FRAME_S;
    else
        flavor = FRAME_G;
    end

    local spares = SPARE_SURROGATES[flavor];
    local spareCount = spares.count;

    if ((not issecure()) or spareCount == 0) then
        surrogate = {};
        local meta = SURROGATE_METAS[flavor];
        setmetatable(surrogate, meta);
        local actions;
        if (mutable) then
            actions = {};
        else
            actions = false;
        end
        SURROGATE_ACTIONS[surrogate] = actions;
    else
        surrogate = spares[spareCount];
        spares[spareCount] = nil;
        spares.count = spareCount - 1;
    end

    SURROGATE_FRAMES[surrogate] = frame;
    return surrogate;
end

local SPARE_PARAM_TABLES = {};
local SPARE_PARAM_COUNT = 0;

local function FreeParamTable(t)
    if (issecure()) then
        wipe(t);
        SPARE_PARAM_COUNT = SPARE_PARAM_COUNT + 1;
        SPARE_PARAM_TABLES[SPARE_PARAM_COUNT] = t;
    end
end

local function GetParamTable(...)
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

local TABLE_ACTIONS = {};

function ReleaseFrameSurrogate(surrogate)
    local frame = SURROGATE_FRAMES[surrogate];
    if (not frame) then return; end
    SURROGATE_FRAMES[surrogate] = nil;

    local actions = SURROGATE_ACTIONS[surrogate];

    if (actions) then
        for k, v in pairs(actions) do
            actions[k] = nil;
            if (type(v) == "table") then
                if (TABLE_ACTIONS[k]) then
                    k(frame, v);
                else
                    k(frame, unpack(v));
                end
                FreeParamTable(v);
            else
                k(frame, v);
            end
        end
    end

    local flavor;
    if (actions == false) then
        flavor = FRAME_G;
    else
        flavor = FRAME_S;
    end

    local spares = SPARE_SURROGATES[flavor];
    -- Prevent pollution
    if (not issecure()) then return; end

    local spareCount = spares.count + 1;
    spares[spareCount] = surrogate;
    spares.count = spareCount;
end

local function GetFrame(surrogate)
    local frame = SURROGATE_FRAMES[surrogate];
    if (not frame) then
        error("Invalid frame surrogate");
        return;
    end
    return frame;
end

local function GetActionTable(surrogate, method)
    local actions = SURROGATE_ACTIONS[surrogate];
    if (not (actions and issecure())) then
        error("Invalid frame surrogate");
        return;
    end
    if (type(method) ~= "function") then
        local frame = SURROGATE_FRAMES[surrogate];
        method = frame[method];
    end
    assert(type(method) == "function");
    local tbl = actions[method];
    if (tbl == nil) then
        tbl = GetParamTable(tbl);
        actions[method] = tbl;
    elseif (type(tbl) ~= "table") then
        tbl = GetParamTable(tbl);
        actions[method] = tbl;
    end
    return tbl;
end

local function AddAction(surrogate, method, ...)
    local actions = SURROGATE_ACTIONS[surrogate];
    if (not (actions and issecure())) then
        error("Invalid frame surrogate");
        return;
    end
    if (type(method) ~= "function") then
        local frame = SURROGATE_FRAMES[surrogate];
        method = frame[method];
    end
    assert(type(method) == "function");
    local n = select("#", ...);
    local old = actions[method];
    if (type(old) == "table") then
        FreeParamTable(old);
    end
    if (n == 1 and type(...) ~= "table") then
        actions[method] = ...;
    else
        actions[method] = GetParamTable(...);
    end
end


---------------------------------------------------------------------------
-- "GETTER" methods

function FRAME_G:GetID()     return GetFrame(self):GetID()     end
function FRAME_G:GetName()   return GetFrame(self):GetName()   end
function FRAME_G:IsShown()   return GetFrame(self):IsShown()   end
function FRAME_G:IsVisible() return GetFrame(self):IsVisible() end
function FRAME_G:GetWidth()  return GetFrame(self):GetWidth()  end
function FRAME_G:GetHeight() return GetFrame(self):GetHeight() end
function FRAME_G:GetScale()  return GetFrame(self):GetScale()  end
function FRAME_G:GetEffectiveScale()
    return GetFrame(self):GetEffectiveScale()
end
function FRAME_G:GetFrameLevel()  return GetFrame(self):GetFrameLevel()  end
function FRAME_G:GetAttribute(name)
    if (type(name) ~= "string" or name:match("^_")) then
        return;
    end
    local val = GetFrame(self):GetAttribute(name)
    local tv = type(val);
    if (tv == "string" or tv == "number" or tv == "boolean") then
        return val;
    end
    return nil
end

-- NOTE: Cannot allow the frame to figure out if it has mouse focus
-- because an insecure frame could be appearing on top of it.

function FRAME_G:GetMousePosition()
    local x, y = GetCursorPosition()
    local frame = GetFrame(self);
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

function FRAME_G:IsUnderMouse(recursive)
    local x, y = GetCursorPosition();
    local frame = GetFrame(self);
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

local function RF_GetReferencedFrame(frame, id)
    local other = frame:GetAttribute("frameref-" .. id);
    if ( other and ( type(other) == "table" )
        and ( type(other[0]) == "userdata" ) ) then
        local protected, explicit = other:IsProtected();
        if ( protected and explicit ) then
            return other;
        end
    end
end

local function ACTION_visibility(frame, value)
    if (value) then
        frame:SetAttribute("statehidden", nil);
        frame:Show();
    else
        frame:SetAttribute("statehidden", true);
        frame:Hide();
    end
end

function FRAME_S:Show()
    AddAction(self, ACTION_visibility, true);
end

function FRAME_S:Hide()
    AddAction(self, ACTION_visibility, false);
end

function FRAME_S:SetID(id)
    id = tonumber(id) or 0;
    AddAction(self, "SetID", id);
end

function FRAME_S:SetWidth(width)
    AddAction(self, "SetWidth", tonumber(width));
end

function FRAME_S:SetHeight(height)
    AddAction(self, "SetHeight", tonumber(height));
end

function FRAME_S:SetScale(scale)
    AddAction(self, "SetScale", tonumber(scale));
end

function FRAME_S:SetAlpha(alpha)
    AddAction(self, "SetAlpha", tonumber(alpha));
end

local SET_POINTS = {
    TOP=true; BOTTOM=true; LEFT=true; RIGHT=true; CENTER=true;
    TOPLEFT=true; BOTTOMLEFT=true; TOPRIGHT=true; BOTTOMRIGHT=true;
};

local function ACTION_setpoints(frame, info)
    if (info == false) then
        frame:ClearAllPoints();
        return;
    end
    if (info[1] == false) then
        frame:ClearAllPoints();
    end
    for point in pairs(SET_POINTS) do
        local relpoint = info[point];
        if (relpoint) then
            local relframeid = info[point .. "_frame"];
            local xofs = info[point .. "_xofs"];
            local yofs = info[point .. "_yofs"];

            local relframe;
            if (relframeid == "$cursor") then
                local cx, cy = GetCursorPosition();
                local eff = frame:GetEffectiveScale();
                xofs = xofs + (cx / eff);
                yofs = yofs + (cy / eff);
            elseif (relframeid == "$parent") then
                relframe = frame:GetParent();
            elseif (relframeid == "$screen") then
                relframe = nil;
            else
                relframe = RF_GetReferencedFrame(frame, relframeid);
                if ( not relframe ) then
                    xofs = nil;
                end
            end
            if (xofs) then
                frame:SetPoint(point, relframe, relpoint, xofs, yofs);
            end
        end
    end
end
TABLE_ACTIONS[ACTION_setpoints] = true;

function FRAME_S:ClearAllPoints()
    AddAction(self, ACTION_setpoints, false);
end

function FRAME_S:SetPoint(point, relframe, relpoint, xofs, yofs)
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
    if (not SET_POINTS[point]) then
        error("Invalid point '" .. tostring(point) .. "'");
        return;
    end
    if (not SET_POINTS[relpoint]) then
        error("Invalid relative point '" .. tostring(relpoint) .. "'");
        return;
    end
    if (not (xofs and yofs)) then
        error("Invalid offset");
        return
    end
    if (relframe == nil) then relframe = "$screen"; end
    if ((relframe ~= "$parent") and (relframe ~= "$cursor")
        and (relframe ~= "$screen")) then
        error("Invalid relative frame '" .. tostring(relframe) .. "'");
        return;
    end

    local info = GetActionTable(self, ACTION_setpoints);
    info[point] = relpoint;
    info[point .. "_frame"] = relframe;
    info[point .. "_xofs"] = xofs;
    info[point .. "_yofs"] = yofs;
end

local NIL_STANDIN = function() end;

local function ACTION_setattributes(frame, info)
    for name, value in pairs(info) do
        if (value == NIL_STANDIN) then value = nil; end
        frame:SetAttribute(name, value);
    end
end
TABLE_ACTIONS[ACTION_setattributes] = true;

function FRAME_S:SetAttribute(name, value)
    if (type(name) ~= "string" or name:match("^_")) then
        error("Invalid attribute name");
        return;
    end
    local tv = type(value);
    if (tv ~= "string" and tv ~= "nil" and tv ~= "number"
        and tv ~= "boolean") then
        error("Invalid attribute value");
        return;
    end
    name = string.lower(name);
    if (value == nil) then value = NIL_STANDIN; end

    local info = GetActionTable(self, ACTION_setattributes);
    info[name] = value;
end

local function ACTION_bindkeys(frame, info)
    ClearOverrideBindings(frame);

    for key, spec in pairs(info) do
        local priority, bindtype, name = spec:match("^(%*?)(.)(.+)$");
        priority = (priority == "*");
        if (bindtype == "C") then
            local framename, button = name:match("^([^:]+):?(.*)$");
            if (button == "") then
                button = "LeftButton";
            end
            SetOverrideBindingClick(frame, priority, key, framename, button);
        elseif (bindtype == "I") then
            SetOverrideBindingItem(frame, priority, key, name);
        elseif (bindtype == "M") then
            local num = tonumber(name);
            if (num) then name = num; end
            SetOverrideBindingMacro(frame, priority, key, name);
        elseif (bindtype == "S") then
            SetOverrideBindingSpell(frame, priority, key, name);
        elseif (bindtype == "B") then
            SetOverrideBinding(frame, priority, key, name);
        end
    end
end
TABLE_ACTIONS[ACTION_bindkeys] = true;

local function SetBindingInternal(self, type, priority, key, spec)
    if (type(key) ~= "string") then
        error("Invalid key");
        return;
    end
    if (priority) then
        spec = "*" .. type .. spec;
    else
        spec = type .. spec;
    end
    local info = GetActionTable(self, ACTION_bindkeys);
    info[key] = spec;
end

function FRAME_S:SetBindingClick(priority, key, name, button)
    if (type(name) ~= "string" or name:match(":")) then
        error("Invalid click target name");
        return;
    end
    if ((button ~= nil) and type(button) ~= "string") then
        error("Invalid button name");
        return;
    end
    if (button) then
        name = name .. ":" .. button;
    end
    SetBindingInternal(self, "C", priority, key, name);
end

function FRAME_S:SetBinding(priority, key, action)
    if (type(action) ~= "string") then
        error("Invalid binding action");
        return;
    end
    SetBindingInternal(self, "B", priority, key, action);
end

function FRAME_S:SetBindingSpell(priority, key, spell)
    if (type(spell) ~= "string") then
        error("Invalid binding spell");
        return;
    end
    SetBindingInternal(self, "S", priority, key, spell);
end

function FRAME_S:SetBindingMacro(priority, key, macro)
    if (type(macro) == "number") then
        macro = tostring(macro);
    elseif (type(macro) ~= "string") then
        error("Invalid binding macro");
        return;
    end
    SetBindingInternal(self, "M", priority, key, macro);
end

function FRAME_S:SetBindingItem(priority, key, item)
    if (type(item) ~= "string") then
        error("Invalid binding item");
        return;
    end
    SetBindingInternal(self, "I", priority, key, item);
end

function FRAME_S:ClearBindings()
    local info = GetActionTable(self, ACTION_bindkeys);
    wipe(info);
end

local function ACTION_level(frame, value)
    if (value == true) then
        frame:Raise();
    elseif (value == false) then
        frame:Lower();
    elseif (tonumber(value)) then
        frame:SetFrameLevel(value);
    end
end

function FRAME_S:Raise()
    AddAction(self, ACTION_level, true);
end

function FRAME_S:Lower()
    AddAction(self, ACTION_level, false);
end

function FRAME_S:SetFrameLevel(level)
    level = tonumber(level);
    if (not level) then
        error("Non-numeric frame level");
        return;
    end
    AddAction(self, ACTION_level, level);
end

-- Parent maniplation requires that both the current frame and the
-- target frame are explicitly protected before the operation is
-- performed.
local function ACTION_setparent(frame, id)
    local protected, explicit = frame:IsProtected();
    if ( not ( protected and explicit ) ) then
        return;
    end
    local parent = RF_GetReferencedFrame(frame, id);
    if ( parent ) then
        frame:SetParent(parent);
    end
end

function FRAME_S:SetParent(parentid)
    AddAction(self, ACTION_setparent, tostring(parentid));
end

local function ACTION_makeparent(frame, info)
    local protected, explicit = frame:IsProtected();
    if ( not ( protected and explicit ) ) then
        return;
    end
    for id, _ in pairs(info) do
        local child = RF_GetReferencedFrame(frame, id);
        if ( child ) then
            child:SetParent(frame);
        end
    end
end

function FRAME_S:MakeParent(childid)
    childid = tostring(childid);
    local info = GetActionTable(self, ACTION_makeparent);
    info[childid] = true;
end
