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
		["trial"] = { ["enabled"] = true, ["ignoreClasses"] = { "DEMONHUNTER" } },
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
	if (CheckKioskModeRealmKey()) then
		C_RealmList.RequestChangeRealmList();
	end
end

function KioskModeSplash_SetMode(mode)
	KioskModeSplash.mode = mode;
end

function KioskModeSplash_GetModeData()
	return kioskModeData[KioskModeSplash.mode];
end

function KioskModeSplash_GetIDForSelection(type, selection)
	if (type == "races") then
		return RACE_NAME_BUTTON_ID_MAP[selection];
	elseif (type == "classes") then
		return CLASS_NAME_BUTTON_ID_MAP[selection];
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
	PlaySound("igMainMenuOptionCheckBoxOn");
	if (self:GetID() == 1) then
		KioskModeSplash_SetMode("highlevel");
	else
		KioskModeSplash_SetMode("newcharacter");
	end

	GlueParent_SetScreen("charcreate");
end