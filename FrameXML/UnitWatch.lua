-- A unit existence monitoring mechanism to avoid duplication of polling logic.
--
-- Code by Tem (some changes from Iriel and slouken)

-- An untainted list of watched frames, the keys are frames, the values
-- are false for show/hide frames, and true for state update frames.
local unitExistsWatchedFrames = {};
local unitExistsCache = 
    setmetatable({}, 
                 { __index = function(t,k) 
                                 local v = UnitExists(k) or false;
                                 t[k] = v;
                                 return v;
                             end});


local UNIT_EXIST_UPDATE_THROTTLE = 0.15;
local timer = 0;

local function SecureUnitWatch_OnUpdate(self,elapsed)
    timer = timer - elapsed;
    if ( timer <= 0 ) then
        timer = UNIT_EXIST_UPDATE_THROTTLE;
        -- Clear the cache
        for k in pairs(unitExistsCache) do
            unitExistsCache[k] = nil;
        end
        for frame,doState in pairs(unitExistsWatchedFrames) do
            local unit = SecureButton_GetUnit(frame);
            local exists = (unit and unitExistsCache[unit]);
            if ( doState ) then
                local attr = (exists and true) or false;
                if (frame:GetAttribute("state-unitexists") ~= attr) then
                    frame:SetAttribute("state-unitexists", attr);
                end
            else
                if ( exists ) then
                    frame:Show();
                else
                    frame:Hide();
                end
            end
        end
    end
end

local function SecureUnitWatch_OnEvent(self, event)
    timer = 0;
end

local function SecureUnitWatch_OnAttributeChanged(self, name, value)
    if ( not value ) then
        return;
    end
    if ( name == "addwatch" ) then
        unitExistsWatchedFrames[value] = (unitExistsWatchedFrames[value]
                                          or false);
        SecureUnitWatchFrame:Show();
        timer = 0;
        return;
    elseif ( name == "addwatchstate" ) then
        unitExistsWatchedFrames[value] = true;
        SecureUnitWatchFrame:Show();
        timer = 0;
        return;
    elseif ( name == "removewatch" ) then
        unitExistsWatchedFrames[value] = nil;
        if (not next(unitExistsWatchedFrames)) then
            SecureUnitWatchFrame:Hide();
        end
        return;
	elseif ( name == "updatetime" ) then
		UNIT_EXIST_UPDATE_THROTTLE = value;
    end
end

-- Register a frame to be notified when a unit's existence changes, the
-- unit is obtained from the frame's attributes. If asState is true then
-- notification is via the 'state-unitexists' attribute with values
-- true and false. Otherwise it's via :Show() and :Hide()
function RegisterUnitWatch(frame, asState)
    if ( asState ) then
        SecureUnitWatchFrame:SetAttribute("addwatchstate", frame);
    else
        SecureUnitWatchFrame:SetAttribute("addwatch", frame);
    end
end

-- Unregister a frame from the unit existence monitor.
function UnregisterUnitWatch(frame)
    SecureUnitWatchFrame:SetAttribute("removewatch", frame);
end

SecureUnitWatchFrame = CreateFrame("Frame", "SecureUnitWatchFrame", nil, "SecureFrameTemplate");
SecureUnitWatchFrame:Hide();
SecureUnitWatchFrame:SetScript("OnUpdate", SecureUnitWatch_OnUpdate);
SecureUnitWatchFrame:SetScript("OnEvent", SecureUnitWatch_OnEvent);
SecureUnitWatchFrame:SetScript("OnAttributeChanged", SecureUnitWatch_OnAttributeChanged);

-- Events that trigger early rescans
SecureUnitWatchFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
SecureUnitWatchFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");
SecureUnitWatchFrame:RegisterEvent("UNIT_PET");
SecureUnitWatchFrame:RegisterEvent("RAID_ROSTER_UPDATE");
SecureUnitWatchFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
-- Deliberately ignoring mouseover and others' target changes because they change so much
