--
-- New shared constants should be added to this
--

-- faction
PLAYER_FACTION_GROUP = { [0] = "Horde", [1] = "Alliance", Horde = 0, Alliance = 1 };

FACTION_LOGO_TEXTURES = {
	[0]	= "Interface\\Icons\\Inv_Misc_Tournaments_banner_Orc",
	[1]	= "Interface\\Icons\\Achievement_PVP_A_A",
};

FACTION_LABELS = {
	[0] = FACTION_HORDE,
	[1] = FACTION_ALLIANCE,
};

-- If you add a class here, you also need to add it to RAID_CLASS_COLORS, CHARCREATE_CLASS_INFO, and maybe to ALT_MANA_BAR_PAIR_DISPLAY_INFO
CLASS_ICON_TCOORDS = {
	["WARRIOR"]		= {0, 0.25, 0, 0.25},
	["MAGE"]		= {0.25, 0.49609375, 0, 0.25},
	["ROGUE"]		= {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"]		= {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"]		= {0, 0.25, 0.25, 0.5},
	["SHAMAN"]	 	= {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"]		= {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"]		= {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"]		= {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"]	= {0.25, .5, 0.5, .75},
	["MONK"]		= {0.5, 0.73828125, 0.5, .75},
	["DEMONHUNTER"]	= {0.7421875, 0.98828125, 0.5, 0.75},
};

-- For these races, the names are shortened for the atlas
local fixedRaceAtlasNames = {
	["highmountaintauren"] = "highmountain",
	["lightforgeddraenei"] = "lightforged",
	["scourge"] = "undead",
	["zandalaritroll"] = "zandalari",
};

function GetRaceAtlas(raceName, gender, useHiRez)
	if (fixedRaceAtlasNames[raceName]) then
		raceName = fixedRaceAtlasNames[raceName];
	end
	local formatingString = useHiRez and "raceicon128-%s-%s" or "raceicon-%s-%s";
	return formatingString:format(raceName, gender);
end

function GetClassAtlas(className)
	return ("classicon-%s"):format(className);
end

function GetGenderAtlases(sexID)
	local genderName = (sexID == Enum.Unitsex.Male) and "male" or "female";
	local baseAtlas = ("charactercreate-gendericon-%s"):format(genderName);
	local selectedAtlas = ("%s-selected"):format(baseAtlas);
	return baseAtlas, selectedAtlas;
end

WOW_GAMES_CATEGORY_ID = 33;
WOW_GAME_TIME_CATEGORY_ID = 37;
WOW_SUBSCRIPTION_CATEGORY_ID = 156;