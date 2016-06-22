--Login Screen Ambience
EXPANSION_GLUE_AMBIENCE = {
	[LE_EXPANSION_BURNING_CRUSADE] = "GlueScreenIntro",
	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = "GlueScreenIntro",
	[LE_EXPANSION_CATACLYSM] = "GlueScreenIntro",
	[LE_EXPANSION_MISTS_OF_PANDARIA] = "GlueScreenIntro",
	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = "AMB_GlueScreen_WarlordsofDraenor",
	[LE_EXPANSION_LEGION] = "AMB_GlueScreen_Legion",
};

--Music
EXPANSION_GLUE_MUSIC = {
	[LE_EXPANSION_BURNING_CRUSADE] = "MUS_1.0_MainTitle_Original",
	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = "GS_Cataclysm",
	[LE_EXPANSION_CATACLYSM] = "GS_Cataclysm",
	[LE_EXPANSION_MISTS_OF_PANDARIA] = "MUS_50_HeartofPandaria_MainTitle",
	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = "MUS_60_MainTitle",
	[LE_EXPANSION_LEGION] = "MUS_70_MainTitle",
};

--Logos
EXPANSION_LOGOS = {
	TRIAL = {texture="Interface\\Glues\\Common\\Glues-WoW-StarterLogo"},
	[LE_EXPANSION_CLASSIC] = {texture="Interface\\Glues\\Common\\Glues-WoW-ClassicLogo"},
	[LE_EXPANSION_BURNING_CRUSADE] = {texture="Interface\\Glues\\Common\\Glues-WoW-BCLogo"},
	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = {texture="Interface\\Glues\\Common\\Glues-WoW-WotLKLogo"},
	[LE_EXPANSION_CATACLYSM] = {texture="Interface\\Glues\\Common\\Glues-WoW-CCLogo"},
	[LE_EXPANSION_MISTS_OF_PANDARIA] = {texture="Interface\\Glues\\Common\\Glues-WoW-MPLogo"},
	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = {texture="Interface\\Glues\\Common\\GLUES-WOW-WODLOGO"},
	-- logos after WoD should be atlas
	[LE_EXPANSION_LEGION] = {atlas="Glues-WoW-LegionLogo"},
	--When adding entries to here, make sure to update the zhTW and zhCN localization files.
};

GLUE_AMBIENCE_TRACKS = {
	["HUMAN"] = "AMB_GlueScreen_Human",
	["ORC"] = "AMB_GlueScreen_Orc",
	["TROLL"] = "AMB_GlueScreen_Troll",
	["DWARF"] = "AMB_GlueScreen_Dwarf",
	["GNOME"] = "AMB_GlueScreen_Gnome",
	["TAUREN"] = "AMB_GlueScreen_Tauren",
	["SCOURGE"] = "AMB_GlueScreen_Undead",
	["NIGHTELF"] = "AMB_GlueScreen_NightElf",
	["DRAENEI"] = "AMB_GlueScreen_Draenei",
	["BLOODELF"] = "AMB_GlueScreen_BloodElf",
	["GOBLIN"] = "AMB_GlueScreen_Goblin",
	["WORGEN"] = "AMB_GlueScreen_Worgen",
	["DEATHKNIGHT"] = "AMB_GlueScreen_Deathknight",
	["CHARACTERSELECT"] = "GlueScreenIntro",
	["PANDAREN"] = "AMB_GlueScreen_Pandaren",
	["HORDE"] = "AMB_50_GlueScreen_HORDE",
	["ALLIANCE"] = "AMB_50_GlueScreen_ALLIANCE",
	["NEUTRAL"] = "AMB_50_GlueScreen_PANDAREN_NEUTRAL",
	["PANDARENCHARACTERSELECT"] = "AMB_50_GlueScreen_PANDAREN_NEUTRAL",
	["DEMONHUNTER"] = "AMB_GlueScreen_DemonHunter",
};

CHAR_MODEL_FOG_INFO = {
	["SCOURGE"] = { r=0, g=0.22, b=0.22, far=26 };
	--[[
	["HUMAN"] = { r=0.8, g=0.65, b=0.73, far=222 };
	["ORC"] = { r=0.5, g=0.5, b=0.5, far=270 };
	["DWARF"] = { r=0.85, g=0.88, b=1.0, far=500 };
	["NIGHTELF"] = { r=0.25, g=0.22, b=0.55, far=611 };
	["TAUREN"] = { r=1.0, g=0.61, b=0.42, far=153 };
	["CHARACTERSELECT"] = { r=0.8, g=0.65, b=0.73, far=222 };
	]]
};

CHAR_MODEL_GLOW_INFO = {
	--[[
	["WORGEN"] = 0.0;
	["GOBLIN"] = 0.0;
	["HUMAN"] = 0.15;
	["DWARF"] = 0.15;
	["CHARACTERSELECT"] = 0.3;
	]]
};

-- for WoW accounts list
MAX_ACCOUNTNAME_DISPLAYED = 8;
ACCOUNTNAME_BUTTON_HEIGHT = 20;

--Credits titles
CREDITS_TITLES = {
	[LE_EXPANSION_CLASSIC] = CREDITS_WOW_CLASSIC,
	[LE_EXPANSION_BURNING_CRUSADE] = CREDITS_WOW_BC,
	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = CREDITS_WOW_LK,
	[LE_EXPANSION_CATACLYSM] = CREDITS_WOW_CC,
	[LE_EXPANSION_MISTS_OF_PANDARIA] = CREDITS_WOW_MOP,
	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = CREDITS_WOW_WOD,
	[LE_EXPANSION_LEGION] = CREDITS_WOW_LEGION,
};

--Backgrounds
EXPANSION_HIGH_RES_BG = {
	[LE_EXPANSION_BURNING_CRUSADE] = "Interface\\Glues\\Models\\UI_MainMenu_BurningCrusade\\UI_MainMenu_BurningCrusade.m2",
	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = "Interface\\Glues\\Models\\UI_MainMenu_Northrend\\UI_MainMenu_Northrend.m2",
	[LE_EXPANSION_CATACLYSM] = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
	[LE_EXPANSION_MISTS_OF_PANDARIA] = "Interface\\Glues\\Models\\UI_MainMenu_Pandaria\\UI_MainMenu_Pandaria.m2",
	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = "Interface\\Glues\\Models\\UI_MainMenu_Warlords\\UI_MainMenu_Warlords.m2",
	[LE_EXPANSION_LEGION] = "Interface\\Glues\\Models\\UI_MainMenu_Legion\\UI_MainMenu_Legion.m2",	-- TODO: Fix for 7.0
};

EXPANSION_LOW_RES_BG = {
	[LE_EXPANSION_BURNING_CRUSADE] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
	[LE_EXPANSION_CATACLYSM] =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
	[LE_EXPANSION_MISTS_OF_PANDARIA] =  "Interface\\Glues\\Models\\UI_MainMenu_LowBandwidth\\UI_MainMenu_LowBandwidth.m2",
	[LE_EXPANSION_WARLORDS_OF_DRAENOR] =  "Interface\\Glues\\Models\\UI_MainMenu_Warlords\\UI_MainMenu_Warlords_LowBandwidth.m2",
	[LE_EXPANSION_LEGION] =  "Interface\\Glues\\Models\\UI_MainMenu_Legion\\UI_MainMenu_Legion_LowBandwidth.m2",	-- TODO: Fix for 7.0
};

--Tooltip
DEFAULT_TOOLTIP_COLOR = {0.8, 0.8, 0.8, 0.09, 0.09, 0.09};

--Movie
MOVIE_CAPTION_FADE_TIME = 1.0;
-- These are movieID from the MOVIE database file.
MOVIE_LIST = {
  -- Movie sequence 1 = Wow Classic
  { 1, 2 },
  -- Movie sequence 2 = BC
  { 27 },
  -- Movie sequence 3 = LK
  { 18 },
  -- Movie sequence 4 = CC
  { 23 },
  -- Movie sequence 5 = MP
  { 115 },
  -- Movie sequence 6 = WoD
  { 195 },
};

--Credits
CREDITS_SCROLL_RATE_REWIND = -160;
CREDITS_SCROLL_RATE_PAUSE = 0;
CREDITS_SCROLL_RATE_PLAY = 40;
CREDITS_SCROLL_RATE_FASTFORWARD = 160;

CREDITS_SCROLL_RATE = 40;
CREDITS_FADE_RATE = 0.4;

NUM_CREDITS_ART_TEXTURES_WIDE = 4;
NUM_CREDITS_ART_TEXTURES_HIGH = 2;
CACHE_WAIT_TIME = 0.5;

CREDITS_ART_INFO = {
	[LE_EXPANSION_CLASSIC] = {
		{ file="NightsHollow", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7,  maxTexIndex = 4 },
	},

	[LE_EXPANSION_BURNING_CRUSADE] = {
		{ file="Illidan", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
	},

	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = {
		{ file="CinSnow01TGA", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
	},

	[LE_EXPANSION_CATACLYSM] = {
		{  file="CATACLYSM\\Greymane City Map01", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
	},

	[LE_EXPANSION_MISTS_OF_PANDARIA] = {
		{ file="Pandaria\\Mogu_BossConcept_New", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
	},

	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = {
		{ file="Warlords\\Arrak_Forest_Dark", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
	},

	[LE_EXPANSION_LEGION] = {
		{ file="Illidan", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
	},
};

GLUE_CREDITS_SOUND_KITS = {
	[LE_EXPANSION_CLASSIC] = "Menu-Credits01",
	[LE_EXPANSION_BURNING_CRUSADE] = "Menu-Credits02",
	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = "Menu-Credits03",
	[LE_EXPANSION_CATACLYSM] = "Menu-Credits04",
	[LE_EXPANSION_MISTS_OF_PANDARIA] = "Menu-Credits05",
	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = "Menu-Credits06",
	[LE_EXPANSION_LEGION] = "Menu-Credits07",
};

AUTO_LOGIN_WAIT_TIME = 1.75;
