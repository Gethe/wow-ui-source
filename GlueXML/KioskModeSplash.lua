-- This table cannot override hard Kiosk Mode locks (i.e. Death Knights being disabled), this is merely to lock down character create based on which creation mode was chosen.
local kioskModeData = {
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
		},
	}
}

function KioskModeSplash_OnLoad(self)
	self.autoEnterWorld = false;
	self.mode = nil;
end

function KioskModeSplash_OnShow(self)
	self.mode = nil;
end

function KioskModeSplash_OnKeyDown(self,key)
	if CheckKioskModeRealmKey() then
		C_RealmList.RequestChangeRealmList();
	elseif CheckKioskModeQuitKey() then
		QuitGame();
	end

	if (IsGMClient() and key == "ESCAPE") then
		C_Login.DisconnectFromServer();
	end
end

function KioskModeSplash_SetMode(mode)
	KioskModeSplash.mode = mode;
end

function KioskModeSplash_GetModeData()
	return kioskModeData[KioskModeSplash.mode];
end

function KioskModeSplash_GetMode()
	return KioskModeSplash.mode;
end

function KioskModeSplash_GetRaceList()
	if (not kioskModeData or not kioskModeData[KioskModeSplash.mode]) then
		return;
	end

	if (C_CharacterCreation.GetCurrentRaceMode() == Enum.CharacterCreateRaceMode.Normal) then
		return kioskModeData[KioskModeSplash.mode].races;
	else
		return kioskModeData[KioskModeSplash.mode].alliedRaces;
	end
end

function KioskModeSplash_GetIDForSelection(type, selection)
	if (type == "races") then
		return C_CharacterCreation.GetRaceIDFromName(selection);
	elseif (type == "classes") then
		return C_CharacterCreation.GetClassIDFromName(selection);
	end

	return nil;
end

function KioskModeSplash_SetAutoEnterWorld(value)
	KioskModeSplash.autoEnterWorld = value;
end

function KioskModeSplash_GetAutoEnterWorld()
	return KioskModeSplash.autoEnterWorld;
end

function KioskModeSplashChoice_OnClick(self, button, down)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if (self:GetID() == 1) then
		KioskModeSplash_SetMode("highlevel");
	else
		KioskModeSplash_SetMode("newcharacter");
	end

	GlueParent_SetScreen("charcreate");
end