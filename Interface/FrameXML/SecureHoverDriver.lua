-- SecureHoverDriver.lua -- A driver for automatically hiding frames after
-- a delay

-- Code to manage 'rect sets', these are arrays made up of
-- STATE -- Current visibility management state:
--             "new" - freshly registered
--             false - cursor has yet to enter
--             true - cursor is over
--             <numeric> - remaining seconds before hide
-- TTL -- The TTL to use when the mouse leaves the frame
-- COUNT -- the number of rects in the set
-- BOUNDING BOX (L,R,B,T) -- The bounding box of the set's rects
-- FRAME RECT (L,R,B,T) -- The rect of the 'main' frame
-- 0 or more other rects -- Any other rects that make up the set
--
-- The cursor is in the rect set if it's over the frame rect or any of the
-- other rects. (The bounding box is just an optimization to speed that
-- determination without checking each rect)

local STATE_INDEX = 1;
local TTL_INDEX = 2;
local COUNT_INDEX = 3;
local BOUNDING_INDEX = 4;
local FRAME_INDEX = BOUNDING_INDEX + 4;

-- Create a new set, possibly re-using an existing array
local function RectSet_Create(l, r, b, t, TTL, S)
    if (S) then
        S[1] = "new";
        S[2] = tonumber(TTL) or 0; -- ttl
        S[3] = 1; -- count
        S[4] = l; S[5] = r; S[6] = b; S[7] = t;
        S[8] = l; S[9] = r; S[10] = b; S[11] = t;
    else
        S = { "new", tonumber(TTL) or 0, 1, l, r, b, t,  l, r, b, t }
    end
    return S;
end

-- Add a new rect to a set, attempting to minimize growth of the set
-- (without getting too carried away)
local function RectSet_Add(S, NL, NR, NB, NT)
    local N = S[COUNT_INDEX];
    local SL, SR, SB, ST = S[4], S[5], S[6], S[7];

    -- First grow the bounding box
    if (NL < SL) then S[4] = NL; end
    if (NR > SR) then S[5] = NR; end
    if (NB < SB) then S[6] = NB; end
    if (NT > ST) then S[7] = NT; end

    -- Now compare the new rect against the other rects to see
    -- if it's wholly contained by, or wholly contains, them.

    local MAXIDX = (N - 1) * 4 + FRAME_INDEX;
    for i = FRAME_INDEX, MAXIDX, 4 do
        SL, SR, SB, ST = S[i], S[i+1], S[i+2], S[i+3];

        if ((NL >= SL) and (NR <= SR) and (NB >= SB) and (NT <= ST)) then
            -- Wholly contained, dont need to add.
            return;
        end

        if ((NL <= SL) and (NR >= SR) and (NB <= SB) and (NT >= ST)) then
            -- Wholly contains existing, replace unless it's the first
            if (i > 7) then
                S[i], S[i+1], S[i+2], S[i+3] = NL, NR, NB, NT;
                return;
            end
        end
    end

    -- Finally if we didn't find a match, add this one to the end
    S[COUNT_INDEX] = N + 1;
    local i = MAXIDX + 4;
    S[i], S[i+1], S[i+2], S[i+3] = NL, NR, NB, NT;
end

-- Check if a set of coordinates is over the rect set
local function RectSet_IsOver(S, X, Y)
    local N = S[COUNT_INDEX];
    local MAXIDX = N * 4 + BOUNDING_INDEX;
    for i = BOUNDING_INDEX, MAXIDX, 4 do
        local R = (X >= S[i]) and (X <= S[i+1]) and
            (Y >= S[i+2]) and (Y <= S[i+3]);

        if (R) then
            if (i > BOUNDING_INDEX) then return true, ((i - 3) / 4); end
        else
            if (i == BOUNDING_INDEX) then return false, "bound"; end
        end
    end
    return false, "nomatch";
end

-- Utility method to get a screen-normalized rect for a frame
local function GetScreenFrameRect(frame)
    local es = frame:GetEffectiveScale();
    local l, b, w, h = frame:GetRect();
    if (not (l and b)) then return 0, 0, 0, 0; end
    return l * es, (l + w) * es, b * es, (b + h) * es;
end

---------------------------------------------------------------------------
-- Actual tracking and registration code
local LOCAL_TrackedHovers = {};
local LOCAL_PendingHides = {};
local LOCAL_AnyPendingHides = false;

local function UpdateTrackedHovers(self, elapsed)
    local cursorX, cursorY = GetCursorPosition();

    for frame, rectSet in pairs(LOCAL_TrackedHovers) do
        if (not frame:IsVisible()) then
            -- Discard if hidden
            LOCAL_TrackedHovers[frame] = nil;
        end
        local cur = rectSet[STATE_INDEX];

        local state = RectSet_IsOver(rectSet, cursorX, cursorY);
        if (state) then
            rectSet[STATE_INDEX] = true;
        else
            if (cur == true) then
                -- The mouse has just left the rect set, check if the
                -- parent frame is still in the same place, and if so
                -- grab the TTL
                local FL, FR, FB, FT = GetScreenFrameRect(frame);
                if ((FL == rectSet[8]) and (FR == rectSet[9])
                    and (FB == rectSet[10]) and (FT == rectSet[11])) then
                    cur = rectSet[TTL_INDEX];
                else
                    -- frame moved, discard
                    cur = nil;
                    LOCAL_TrackedHovers[frame] = nil;
                end
            elseif (cur == "new") then
                -- This is the first update for this frame, and the cursor
                -- isn't yet in it
                cur = false;
                rectSet[STATE_INDEX] = false;
            elseif (cur) then
                -- We're already counting down, so subtract the current time
                cur = cur - elapsed;
            end

            -- If we've got something other than nil or false, it's a
            -- countdown, so see if it's expired or not
            if (cur) then
                if (cur > 0) then
                    -- Still going, save remaining time
                    rectSet[STATE_INDEX] = cur;
                else
                    -- Expired, discard hover and queue for hide
                    LOCAL_TrackedHovers[frame] = nil;
                    LOCAL_PendingHides[frame] = true;
                    LOCAL_AnyPendingHides = true;
                end
            end
        end
    end

    if (LOCAL_AnyPendingHides) then
        for frame, _ in pairs(LOCAL_PendingHides) do
            LOCAL_PendingHides[frame] = nil
            frame:Hide();
            frame:SetAttribute("statehidden", true);
        end
        LOCAL_AnyPendingHides = false;
    end

    if (not next(LOCAL_TrackedHovers)) then
        self:Hide();
    end
end

-- TODO do I need to make this frame secure? Probably.
local LOCAL_UpdateFrame = CreateFrame("Frame", "SecureHoverDriverManager", nil, "SecureFrameTemplate");
LOCAL_UpdateFrame:SetScript("OnUpdate", UpdateTrackedHovers);
LOCAL_UpdateFrame:Hide();

-- Register a frame for auto-hiding
--
--  frame - the frame to register
--  ttl - the time (in seconds) after leaving the frame before hiding
local function SecureRegisterAutoHide(frame, ttl)
    -- TODO check that frame really is a frame?
    local l, r, b, t = GetScreenFrameRect(frame);
    local rectSet = RectSet_Create(l, r, b, t, ttl, LOCAL_TrackedHovers[frame]);
    LOCAL_TrackedHovers[frame] = rectSet;
    LOCAL_UpdateFrame:Show();
end

-- Add another frame as a 'child' of the frame to include it in the frame's
-- rectset. This must be called immediately after the initial registration
-- (i.e. before OnUpdate)
--
--  frame - the already registered frame
--  child - the child frame to include in the rect set
local function SecureAddToAutoHide(frame, child)
    local rectSet = LOCAL_TrackedHovers[frame];
    if (not rectSet) then
        error("Parent frame is not registered for auto-hide");
        return;
    end
    if (rectSet[STATE_INDEX] ~= "new") then
        error("Parent frame is not freshly registered");
        return;
    end
    -- TODO check that child really is a frame?
    local l, r, b, t = GetScreenFrameRect(child);
    RectSet_Add(rectSet, l, r, b, t);
end

-- Cancel a frame's auto-hide registration
--
--  frame - the frame to unregister
local function SecureUnregisterAutoHide(frame)
    LOCAL_TrackedHovers[frame] = nil;
end

local function SecureHoverDriverManager_OnAttributeChanged(self, name, value)
    if ( not value ) then
        return;
    end
    if ( name == "setframe" ) then
        return;
    elseif ( name == "unregister" ) then
        local frame = value;
        if (frame) then
            SecureUnregisterAutoHide(frame);
        end
    elseif ( name == "register" ) then
        local duration = tonumber(value);
        if (not duration) then
            return;
        end
        if (duration < 0) then
            duration = 0;
        end
        local frame = self:GetAttribute("setframe");
        if (frame) then
            SecureRegisterAutoHide(frame, duration);
        end
    elseif ( name == "add" ) then
        local child = value;
        local frame = self:GetAttribute("setframe");
        if (frame and child) then
            SecureAddToAutoHide(frame, child);
        end
    end
end

LOCAL_UpdateFrame:SetScript("OnAttributeChanged", SecureHoverDriverManager_OnAttributeChanged);

-- Register a frame for auto-hiding
--
--  frame - the frame to register
--  ttl - the time (in seconds) after leaving the frame before hiding
function RegisterAutoHide(frame, ttl)
    if (issecure()) then
        return SecureRegisterAutoHide(frame, tonumber(ttl));
    end
    LOCAL_UpdateFrame:SetAttribute("setframe", frame);
    LOCAL_UpdateFrame:SetAttribute("register", tonumber(ttl));
end

-- Add another frame as a 'child' of the frame to include it in the frame's
-- rectset. This must be called immediately after the initial registration
-- (i.e. before OnUpdate)
--
--  frame - the already registered frame
--  child - the child frame to include in the rect set
function AddToAutoHide(frame, child)
    if (issecure()) then
        return SecureAddToAutoHide(frame, child);
    end
    local rectSet = LOCAL_TrackedHovers[frame];
    if (not rectSet) then
        error("Parent frame is not registered for auto-hide");
        return;
    end
    if (rectSet[STATE_INDEX] ~= "new") then
        error("Parent frame is not freshly registered");
        return;
    end
    LOCAL_UpdateFrame:SetAttribute("setframe", frame);
    LOCAL_UpdateFrame:SetAttribute("add", child);
end

-- Cancel a frame's auto-hide registration
--
--  frame - the frame to unregister
function UnregisterAutoHide(frame)
    if (issecure()) then
        return SecureUnregisterAutoHide(frame);
    end
    LOCAL_UpdateFrame:SetAttribute("unregister", frame);
end
