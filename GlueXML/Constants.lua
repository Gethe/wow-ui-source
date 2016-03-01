--Login Screen Ambience
EXPANSION_GLUE_AMBIENCE = {
	TRIAL = "GlueScreenIntro",
	VETERAN = "GlueScreenIntro",
	[1] = "GlueScreenIntro",
	[2] = "GlueScreenIntro",
	[3] = "GlueScreenIntro",
	[4] = "GlueScreenIntro",
	[5] = "AMB_GlueScreen_WarlordsofDraenor",
	[6] = "GlueScreenIntro", --FIXME
}

--Music
EXPANSION_GLUE_MUSIC = {
	TRIAL = "GS_Cataclysm",
	VETERAN = "GS_Cataclysm",
	[1] = "MUS_1.0_MainTitle_Original",
	[2] = "GS_Cataclysm",
	[3] = "GS_Cataclysm",
	[4] = "MUS_50_HeartofPandaria_MainTitle",
	[5] = "MUS_60_MainTitle",
	[6] = "GS_BurningCrusade",   -- FIXME
}

--Logos
EXPANSION_LOGOS = {
	TRIAL = "Interface\\Glues\\Common\\Glues-WoW-StarterLogo",
	VETERAN = "Interface\\Glues\\Common\\GLUES-WOW-WODLOGO",
	[1] = "Interface\\Glues\\Common\\Glues-WoW-ClassicLogo",
	[2] = "Interface\\Glues\\Common\\Glues-WoW-WotLKLogo",
	[3] = "Interface\\Glues\\Common\\Glues-WoW-CCLogo",
	[4] = "Interface\\Glues\\Common\\Glues-WoW-MPLogo",
	[5] = "Interface\\Glues\\Common\\GLUES-WOW-WODLOGO",
	[6] = "Interface\\Glues\\Common\\GLUES-WOW-WODLOGO",  -- FIXME
	--When adding entries to here, make sure to update the zhTW and zhCN localization files.
};

GLUE_AMBIENCE_TRACKS = {
	["HUMAN"] = "AMB_GlueScreen_Human";
	["ORC"] = "AMB_GlueScreen_Orc";
	["TROLL"] = "AMB_GlueScreen_Troll";
	["DWARF"] = "AMB_GlueScreen_Dwarf";
	["GNOME"] = "AMB_GlueScreen_Gnome";
	["TAUREN"] = "AMB_GlueScreen_Tauren";
	["SCOURGE"] = "AMB_GlueScreen_Undead";
	["NIGHTELF"] = "AMB_GlueScreen_NightElf";
	["DRAENEI"] = "AMB_GlueScreen_Draenei";
	["BLOODELF"] = "AMB_GlueScreen_BloodElf";
	["GOBLIN"] = "AMB_GlueScreen_Goblin";
	["WORGEN"] = "AMB_GlueScreen_Worgen";
	["DEATHKNIGHT"] = "AMB_GlueScreen_Deathknight";
	["CHARACTERSELECT"] = "GlueScreenIntro";
	["PANDAREN"] = "AMB_GlueScreen_Pandaren";
	["HORDE"] = "AMB_50_GlueScreen_HORDE";
	["ALLIANCE"] = "AMB_50_GlueScreen_ALLIANCE";
	["NEUTRAL"] = "AMB_50_GlueScreen_PANDAREN_NEUTRAL";
	["PANDARENCHARACTERSELECT"] = "AMB_50_GlueScreen_PANDAREN_NEUTRAL";
}

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
}

CHAR_MODEL_GLOW_INFO = {
	--[[
	["WORGEN"] = 0.0;
	["GOBLIN"] = 0.0;
	["HUMAN"] = 0.15;
	["DWARF"] = 0.15;
	["CHARACTERSELECT"] = 0.3;
	]]
}

-- for WoW accounts list
MAX_ACCOUNTNAME_DISPLAYED = 8;
ACCOUNTNAME_BUTTON_HEIGHT = 20;

--Credits titles
CREDITS_TITLES = { --Note: These are off by 1 from the other expansion tables
	CREDITS_WOW_CLASSIC,
	CREDITS_WOW_BC,
	CREDITS_WOW_LK,
	CREDITS_WOW_CC,
	CREDITS_WOW_MOP,
	CREDITS_WOW_WOD,
	CREDITS_WOW_7,   -- FIXME
}

--Backgrounds
EXPANSION_HIGH_RES_BG = {
	TRIAL = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
	VETERAN = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Warlords.m2",
	[1] = "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
	[2] = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
	[3] = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
	[4] = "Interface\\Glues\\Models\\UI_MainMenu_Pandaria\\UI_MainMenu_Pandaria.m2",
	[5] = "Interface\\Glues\\Models\\UI_MainMenu_Warlords\\UI_MainMenu_Warlords.m2",
	[6] = "Interface\\Glues\\Models\\UI_MainMenu_Warlords\\UI_MainMenu_Warlords.m2",	-- TODO: Fix for 7.0
}

EXPANSION_LOW_RES_BG = {
	TRIAL =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
	VETERAN =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Warlords_LowBandwidth.m2",
	[1] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
	[2] =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
	[3] =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
	[4] =  "Interface\\Glues\\Models\\UI_MainMenu_LowBandwidth\\UI_MainMenu_LowBandwidth.m2",
	[5] =  "Interface\\Glues\\Models\\UI_MainMenu_Warlords\\UI_MainMenu_Warlords_LowBandwidth.m2",
	[6] =  "Interface\\Glues\\Models\\UI_MainMenu_Warlords\\UI_MainMenu_Warlords_LowBandwidth.m2",	-- TODO: Fix for 7.0
}

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
}

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

CREDITS_ART_INFO = {};
CREDITS_ART_INFO[1] = {};
CREDITS_ART_INFO[1][1] = { file="NightsHollow", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CREDITS_ART_INFO[2] = {};
CREDITS_ART_INFO[2][1] = { file="Illidan", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CREDITS_ART_INFO[3] = {};
CREDITS_ART_INFO[3][1] = { file="CinSnow01TGA", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CREDITS_ART_INFO[4] = { path="CATACLYSM\\" };
CREDITS_ART_INFO[4][1] = {  file="Greymane City Map01", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CREDITS_ART_INFO[5] = { path="Pandaria\\" };
CREDITS_ART_INFO[5][1] = { file="Mogu_BossConcept_New", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CREDITS_ART_INFO[6] = { path="Warlords\\" };
CREDITS_ART_INFO[6][1] = { file="Arrak_Forest_Dark", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };

GLUE_CREDITS_SOUND_KITS = { };
GLUE_CREDITS_SOUND_KITS[1] = "Menu-Credits01";
GLUE_CREDITS_SOUND_KITS[2] = "Menu-Credits02";
GLUE_CREDITS_SOUND_KITS[3] = "Menu-Credits03";
GLUE_CREDITS_SOUND_KITS[4] = "Menu-Credits04";
GLUE_CREDITS_SOUND_KITS[5] = "Menu-Credits05";
GLUE_CREDITS_SOUND_KITS[6] = "Menu-Credits06";

AUTO_LOGIN_WAIT_TIME = 1.75;
