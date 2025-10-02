Kiosk.ExpirationWarningSoundKit = 15273;

-- This table cannot override hard Kiosk Mode locks (i.e. Death Knights being disabled), this is merely to lock down character create based on which creation mode was chosen.
Kiosk.CharacterData = {
	["highlevel"] = {
		["races"] = {
			["HUMAN"] = true,
			["DWARF"] = true,
			["NIGHTELF"] = true,
			["GNOME"] = true,
			["DRAENEI"] = true,
			["WORGEN"] = true,
			["PANDAREN"] = true,
			["ORC"] = true,
			["SCOURGE"] = true,
			["TAUREN"] = true,
			["TROLL"] = true,
			["BLOODELF"] = true,
			["GOBLIN"] = true,
		},
		["classes"] = {
			["WARRIOR"] = true,
			["PALADIN"] = true,
			["HUNTER"] = true,
			["ROGUE"] = true,
			["PRIEST"] = true,
			["SHAMAN"] = true,
			["MAGE"] = true,
			["WARLOCK"] = true,
			["MONK"] = true,
			["DRUID"] = true,
			["DEMONHUNTER"] = true,
			["DEATHKNIGHT"] = true,
		},
		["alliedRaces"] = { 
			["LIGHTFORGEDDRAENEI"] = true,
			["HIGHMOUNTAINTAUREN"] = true,
			["NIGHTBORNE"] = true,
			["VOIDELF"] = true,
			["DARKIRONDWARF"] = true,
			["KULTIRAN"] = true,
			["MECHAGNOME"] = true,
			["MAGHARORC"] = true,
			["ZANDALARITROLL"] = true,
			["VULPERA"] = true,
		},
		["template"] = { ["enabled"] = true, ["index"] = 1, ["ignoreClasses"] = { } },
	},
	["newcharacter"] = {
		["races"] = {
			["HUMAN"] = true,
			["DWARF"] = true,
			["NIGHTELF"] = true,
			["GNOME"] = true,
			["DRAENEI"] = true,
			["WORGEN"] = true,
			["PANDAREN"] = true,
			["ORC"] = true,
			["SCOURGE"] = true,
			["TAUREN"] = true,
			["TROLL"] = true,
			["BLOODELF"] = true,
			["GOBLIN"] = true,
		},
		["classes"] = {
			["WARRIOR"] = true,
			["PALADIN"] = true,
			["HUNTER"] = true,
			["ROGUE"] = true,
			["PRIEST"] = true,
			["SHAMAN"] = true,
			["MAGE"] = true,
			["WARLOCK"] = true,
			["MONK"] = true,
			["DRUID"] = true,
			["DEMONHUNTER"] = false,
			["DEATHKNIGHT"] = false,
		},
		["alliedRaces"] = { 
			["LIGHTFORGEDDRAENEI"] = false,
			["HIGHMOUNTAINTAUREN"] = false,
			["NIGHTBORNE"] = false,
			["VOIDELF"] = false,
			["DARKIRONDWARF"] = false,
			["KULTIRAN"] = false,
			["MECHAGNOME"] = false,
			["MAGHARORC"] = false,
			["ZANDALARITROLL"] = false,
			["VULPERA"] = false,
		},
	}
};

StaticPopupDialogs["KIOSK_ENABLED"] = {
	text = KIOSK_ENABLED_DLG_TEXT,
	button1 = OKAY,
	button2 = nil,
};

KioskFrameMixin = {}

function KioskFrameMixin:OnLoad()
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_WARNING");
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_CHANGED");
	self:RegisterEvent("KIOSK_SESSION_STARTED");
	self:RegisterEvent("KIOSK_SESSION_EXPIRED");
	self:RegisterEvent("KIOSK_SESSION_SHUTDOWN");
	self:RegisterEvent("KIOSK_SESSION_RESTART");
	self:RegisterEvent("TOGGLE_CONSOLE");
	self:RegisterEvent("DEBUG_MENU_TOGGLED");
end

function KioskFrameMixin:OnEvent(event, ...)
	if event == "TOGGLE_CONSOLE" then
		if DeveloperConsole and DeveloperConsole:IsShown() then
			local shownRequested = false;
			DeveloperConsole:Toggle(shownRequested);
		end
	elseif event == "DEBUG_MENU_TOGGLED" then
		if DebugMenu.IsVisible() then
			DebugMenu.SetDebugMenuShown(false);
		end
	elseif event == "KIOSK_SESSION_EXPIRATION_CHANGED" then
		if UIErrorsFrame then
			UIErrorsFrame:AddExternalWarningMessage(KIOSK_SESSION_TIMER_CHANGED);
		end

		StaticPopup_Show("OKAY", KIOSK_SESSION_TIMER_CHANGED);
	elseif event == "KIOSK_SESSION_EXPIRATION_WARNING" then
		local secondsRemaining = ...;
		local msg = string.format(KIOSK_SESSION_EXPIRE_WARNING, secondsRemaining / 60);

		if UIErrorsFrame and secondsRemaining > 60 then
			UIErrorsFrame:AddExternalWarningMessage(msg);
		end

		ChatFrameUtil.DisplaySystemMessageInCurrent(msg);

		PlaySound(Kiosk.ExpirationWarningSoundKit);
	elseif event == "KIOSK_SESSION_SHUTDOWN" then
		SettingsPanel:SetAllSettingsToDefaults();
	end
end

function KioskFrameMixin:HasAllowedMaps()
	return #Kiosk.AllowedMapIDs > 0;
end

function KioskFrameMixin:GetAllowedMapIDs()
	return Kiosk.AllowedMapIDs;
end

function KioskFrameMixin:SetMode(mode)
	self.mode = mode;
end

function KioskFrameMixin:GetMode()
	return self.mode;
end

function KioskFrameMixin:GetModeData()
	return Kiosk.CharacterData[self.mode];
end

function KioskFrameMixin:SetAutoEnterWorld(value)
	self.autoEnterWorld = value;
end

function KioskFrameMixin:GetAutoEnterWorld()
	return self.autoEnterWorld;
end

function KioskFrameMixin:GetRaceList()
	local data = GetModeData();
	if not data then
		return;
	end

	if C_CharacterCreation.GetCurrentRaceMode() == Enum.CharacterCreateRaceMode.Normal then
		return data.races;
	end

	return data.alliedRaces;
end

function KioskFrameMixin:GetIDForSelection(type, selection)
	if type == "races" then
		return C_CharacterCreation.GetRaceIDFromName(selection);
	elseif type == "classes" then
		return C_CharacterCreation.GetClassIDFromName(selection);
	end

	return nil;
end
