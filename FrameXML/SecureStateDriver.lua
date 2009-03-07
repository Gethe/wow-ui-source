--
-- SecureStateDriverManager
-- Automatically sets states based on macro options for state driver frames
-- Also handled showing/hiding frames based on unit existence (code by Tem)
--

-- Register a frame with the state driver manager, and set a managed state
function RegisterStateDriver(frame, state, values)
    if ( state and values ) then
        SecureStateDriverManager:SetAttribute("setframe", frame);
        SecureStateDriverManager:SetAttribute("setstate", state.." "..values);
    end
end

-- Unregister a frame from the state driver manager.
function UnregisterStateDriver(frame, state)
    if ( state ) then
        SecureStateDriverManager:SetAttribute("setframe", frame);
        SecureStateDriverManager:SetAttribute("setstate", state.." ".."");
    else
        SecureStateDriverManager:SetAttribute("delframe", frame);
    end
end

-- Register a frame to be notified when a unit's existence changes, the
-- unit is obtained from the frame's attributes. If asState is true then
-- notification is via the 'state-unitexists' attribute with values
-- true and false. Otherwise it's via :Show() and :Hide()
function RegisterUnitWatch(frame, asState)
    if ( asState ) then
        SecureStateDriverManager:SetAttribute("addwatchstate", frame);
    else
        SecureStateDriverManager:SetAttribute("addwatch", frame);
    end
end

-- Unregister a frame from the unit existence monitor.
function UnregisterUnitWatch(frame)
    SecureStateDriverManager:SetAttribute("removewatch", frame);
end

--
-- Private implementation
--
local secureStateDrivers = {};
local unitExistsWatchers = {};
local unitExistsCache = setmetatable({},
                                     { __index = function(t,k)
                                                     local v = UnitExists(k) or false;
                                                     t[k] = v;
                                                     return v;
                                                 end
                                     });
local STATE_DRIVER_UPDATE_THROTTLE = 0.2;
local timer = 0;

-- Check to see if a frame is registered
function UnitWatchRegistered(frame)
        return not (unitExistsWatchers[frame] == nil);
end

local function SecureStateDriverManager_UpdateUnitWatch(frame, doState)
    local unit = SecureButton_GetUnit(frame);
    local exists = (unit and unitExistsCache[unit]);
    if ( doState ) then
        local attr = exists or false;
        if ( frame:GetAttribute("state-unitexists") ~= attr ) then
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

local pairs = pairs;

local function SecureStateDriverManager_OnUpdate(self,elapsed)
    timer = timer - elapsed;
    if ( timer <= 0 ) then
        timer = STATE_DRIVER_UPDATE_THROTTLE;

        -- Handle state driver updates
        for frame,states in pairs(secureStateDrivers) do
            for state,values in pairs(states) do
                local newValue = SecureCmdOptionParse(values);

                if ( state == "state-visibility" ) then
                    if ( newValue == "show" ) then
                        frame:Show();
                    elseif ( newValue == "hide" ) then
                        frame:Hide();
                    end
                else
                    local oldValue = frame:GetAttribute(state);
                    if ( newValue and newValue ~= oldValue ) then
                        frame:SetAttribute(state, newValue);
                    end
                end
            end
        end

        -- Handle unit existence changes
        for k in pairs(unitExistsCache) do
            unitExistsCache[k] = nil;
        end
        for frame,doState in pairs(unitExistsWatchers) do
            SecureStateDriverManager_UpdateUnitWatch(frame, doState);
        end
    end
end

local function SecureStateDriverManager_OnEvent(self, event)
    timer = 0;
end

local function SecureStateDriverManager_OnAttributeChanged(self, name, value)
    if ( not value ) then
        return;
    end
    if ( name == "setframe" ) then
        if ( not secureStateDrivers[value] ) then
            secureStateDrivers[value] = {};
        end
        SecureStateDriverManager:Show();
    elseif ( name == "delframe" ) then
        secureStateDrivers[value] = nil;
    elseif ( name == "setstate" ) then
        local frame = self:GetAttribute("setframe");
        local state, values = strmatch(value, "^(%S+)%s+(.*)$");
        state = "state-"..state;
        if ( values == "" ) then
            secureStateDrivers[frame][state] = nil;
        else
            secureStateDrivers[frame][state] = values;
            local newValue = SecureCmdOptionParse(values);

            if ( state == "state-visibility" ) then
                if ( newValue == "show" ) then
                    frame:Show();
                elseif ( newValue == "hide" ) then
                    frame:Hide();
                end
            else
                local oldValue = frame:GetAttribute(state);
                if ( newValue and newValue ~= oldValue ) then
                    frame:SetAttribute(state, newValue);
                end
            end
        end
    elseif ( name == "addwatch" or name == "addwatchstate" ) then
        local doState = (name == "addwatchstate");
        unitExistsWatchers[value] = doState;
        SecureStateDriverManager:Show();
        SecureStateDriverManager_UpdateUnitWatch(value, doState);
    elseif ( name == "removewatch" ) then
        unitExistsWatchers[value] = nil;
    elseif ( name == "updatetime" ) then
        STATE_DRIVER_UPDATE_THROTTLE = value;
    end
end

SecureStateDriverManager = CreateFrame("Frame", "SecureStateDriverManager", nil, "SecureFrameTemplate");
SecureStateDriverManager:Hide();
SecureStateDriverManager:SetScript("OnUpdate", SecureStateDriverManager_OnUpdate);
SecureStateDriverManager:SetScript("OnEvent", SecureStateDriverManager_OnEvent);
SecureStateDriverManager:SetScript("OnAttributeChanged", SecureStateDriverManager_OnAttributeChanged);

-- Events that trigger early rescans
SecureStateDriverManager:RegisterEvent("MODIFIER_STATE_CHANGED");
SecureStateDriverManager:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
SecureStateDriverManager:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
SecureStateDriverManager:RegisterEvent("PLAYER_ENTERING_WORLD");
SecureStateDriverManager:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
SecureStateDriverManager:RegisterEvent("UPDATE_STEALTH");
SecureStateDriverManager:RegisterEvent("PLAYER_TARGET_CHANGED");
SecureStateDriverManager:RegisterEvent("PLAYER_FOCUS_CHANGED");
SecureStateDriverManager:RegisterEvent("PLAYER_REGEN_DISABLED");
SecureStateDriverManager:RegisterEvent("PLAYER_REGEN_ENABLED");
SecureStateDriverManager:RegisterEvent("UNIT_PET");
SecureStateDriverManager:RegisterEvent("RAID_ROSTER_UPDATE");
SecureStateDriverManager:RegisterEvent("PARTY_MEMBERS_CHANGED");
-- Deliberately ignoring mouseover and others' target changes because they change so much
