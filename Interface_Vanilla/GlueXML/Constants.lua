--Login Screen Ambience
EXPANSION_GLUE_AMBIENCE = {
	[LE_EXPANSION_CLASSIC]					= SOUNDKIT.GLUESCREEN_INTRO,
--	[LE_EXPANSION_BURNING_CRUSADE]			= SOUNDKIT.GLUESCREEN_INTRO,
--	[LE_EXPANSION_WRATH_OF_THE_LICH_KING]	= SOUNDKIT.GLUESCREEN_INTRO,
--	[LE_EXPANSION_CATACLYSM]				= SOUNDKIT.GLUESCREEN_INTRO,
--	[LE_EXPANSION_MISTS_OF_PANDARIA]		= SOUNDKIT.GLUESCREEN_INTRO,
--	[LE_EXPANSION_WARLORDS_OF_DRAENOR]		= SOUNDKIT.AMB_GLUESCREEN_WARLORDS_OF_DRAENOR,
--	[LE_EXPANSION_LEGION]					= SOUNDKIT.AMB_GLUESCREEN_LEGION,
--	[LE_EXPANSION_BATTLE_FOR_AZEROTH]		= SOUNDKIT.AMB_GLUESCREEN_BATTLE_FOR_AZEROTH,
};

--Music
EXPANSION_GLUE_MUSIC = {
	[LE_EXPANSION_CLASSIC]					= SOUNDKIT.MUS_1_0_MAINTITLE_ORIGINAL,
--	[LE_EXPANSION_BURNING_CRUSADE]			= SOUNDKIT.MUS_1_0_MAINTITLE_ORIGINAL,
--	[LE_EXPANSION_WRATH_OF_THE_LICH_KING]	= SOUNDKIT.GS_LICH_KING,
--	[LE_EXPANSION_CATACLYSM]				= SOUNDKIT.GS_CATACLYSM,
--	[LE_EXPANSION_MISTS_OF_PANDARIA]		= SOUNDKIT.MUS_50_HEART_OF_PANDARIA_MAINTITLE,
--	[LE_EXPANSION_WARLORDS_OF_DRAENOR]		= SOUNDKIT.MUS_60_MAIN_TITLE,
--	[LE_EXPANSION_LEGION]					= SOUNDKIT.MUS_70_MAIN_TITLE,
--	[LE_EXPANSION_BATTLE_FOR_AZEROTH]		= SOUNDKIT.MUS_80_MAIN_TITLE,
};

GLUE_AMBIENCE_TRACKS = {
	["HUMAN"]					= SOUNDKIT.AMB_GLUESCREEN_HUMAN,
	["ORC"]						= SOUNDKIT.AMB_GLUESCREEN_ORC,
	["TROLL"]					= SOUNDKIT.AMB_GLUESCREEN_TROLL,
	["DWARF"]					= SOUNDKIT.AMB_GLUESCREEN_DWARF,
	["GNOME"]					= SOUNDKIT.AMB_GLUESCREEN_GNOME,
	["TAUREN"]					= SOUNDKIT.AMB_GLUESCREEN_TAUREN,
	["SCOURGE"]					= SOUNDKIT.AMB_GLUESCREEN_UNDEAD,
	["NIGHTELF"]				= SOUNDKIT.AMB_GLUESCREEN_NIGHTELF,
	["DRAENEI"]					= SOUNDKIT.AMB_GLUESCREEN_DRAENEI,
	["BLOODELF"]				= SOUNDKIT.AMB_GLUESCREEN_BLOODELF,
	["GOBLIN"]					= SOUNDKIT.AMB_GLUESCREEN_GOBLIN,
	["WORGEN"]					= SOUNDKIT.AMB_GLUESCREEN_WORGEN,
	["VOIDELF"]					= SOUNDKIT.AMB_GLUESCREEN_VOIDELF,
	["LIGHTFORGEDDRAENEI"]		= SOUNDKIT.AMB_GLUESCREEN_LIGHTFORGEDDRAENEI,
	["NIGHTBORNE"]				= SOUNDKIT.AMB_GLUESCREEN_NIGHTBORNE,
	["HIGHMOUNTAINTAUREN"]		= SOUNDKIT.AMB_GLUESCREEN_HIGHMOUNTAINTAUREN,
	["DEATHKNIGHT"]				= SOUNDKIT.AMB_GLUESCREEN_DEATHKNIGHT,
	["CHARACTERSELECT"]			= SOUNDKIT.GLUESCREEN_INTRO,
	["PANDAREN"]				= SOUNDKIT.AMB_GLUESCREEN_PANDAREN,
	["HORDE"]					= SOUNDKIT.AMB_50_GLUESCREEN_HORDE,
	["ALLIANCE"]				= SOUNDKIT.AMB_50_GLUESCREEN_ALLIANCE,
	["NEUTRAL"]					= SOUNDKIT.AMB_50_GLUESCREEN_PANDAREN_NEUTRAL,
	["PANDARENCHARACTERSELECT"]	= SOUNDKIT.AMB_50_GLUESCREEN_PANDAREN_NEUTRAL,
	["DEMONHUNTER"]				= SOUNDKIT.AMB_GLUESCREEN_DEMONHUNTER,
	["DARKIRONDWARF"] 			= SOUNDKIT.AMB_GLUESCREEN_DARKIRONDWARF,
	["MAGHARORC"] 				= SOUNDKIT.AMB_GLUESCREEN_MAGHARORC,
};

CHAR_MODEL_FOG_INFO = {
	["HUMAN"] = { r=0.8, g=0.65, b=0.73, far=222 };
	["ORC"] = { r=0.5, g=0.5, b=0.5, far=270 };
	["TROLL"] = { r=0.5, g=0.5, b=0.5, far=270 };
	["DWARF"] = { r=0.85, g=0.88, b=1.0, far=500 };
	["GNOME"] = { r=0.85, g=0.88, b=1.0, far=500 };
	["NIGHTELF"] = { r=0.25, g=0.22, b=0.55, far=611 };
	["TAUREN"] = { r=1.0, g=0.61, b=0.42, far=153 };
	["SCOURGE"] = { r=0, g=0.22, b=0.22, far=26 };
	["CHARACTERSELECT"] = { r=0.8, g=0.65, b=0.73, far=222 };
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

--Credits Type Enum
CREDITS_TYPE_VANILLA = 1;
CREDITS_TYPE_CLASSIC = 2;

--Credits titles
CREDITS_TITLES = {
	[CREDITS_TYPE_VANILLA] = CREDITS_WOW_VANILLA,
	[CREDITS_TYPE_CLASSIC] = CREDITS_WOW_CLASSIC,
--	[LE_EXPANSION_BURNING_CRUSADE] = CREDITS_WOW_BC,
--	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = CREDITS_WOW_LK,
--	[LE_EXPANSION_CATACLYSM] = CREDITS_WOW_CC,
--	[LE_EXPANSION_MISTS_OF_PANDARIA] = CREDITS_WOW_MOP,
--	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = CREDITS_WOW_WOD,
--	[LE_EXPANSION_LEGION] = CREDITS_WOW_LEGION,
--	[LE_EXPANSION_BATTLE_FOR_AZEROTH] = CREDITS_WOW_8_0,
};

--Backgrounds
EXPANSION_HIGH_RES_BG = {
	[LE_EXPANSION_CLASSIC] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
--	[LE_EXPANSION_BURNING_CRUSADE] = "Interface\\Glues\\Models\\UI_MainMenu_BurningCrusade\\UI_MainMenu_BurningCrusade.m2",
--	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = "Interface\\Glues\\Models\\UI_MainMenu_Northrend\\UI_MainMenu_Northrend.m2",
--	[LE_EXPANSION_CATACLYSM] = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
--	[LE_EXPANSION_MISTS_OF_PANDARIA] = "Interface\\Glues\\Models\\UI_MainMenu_Pandaria\\UI_MainMenu_Pandaria.m2",
--	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = "Interface\\Glues\\Models\\UI_MainMenu_Warlords\\UI_MainMenu_Warlords.m2",
--	[LE_EXPANSION_LEGION] = "Interface\\Glues\\Models\\UI_MainMenu_Legion\\UI_MainMenu_Legion.m2",	-- TODO: Fix for 7.0
--	[LE_EXPANSION_BATTLE_FOR_AZEROTH] = "Interface\\Glues\\Models\\UI_MAINMENU_BATTLEFORAZEROTH\\UI_MainMenu_BattleForAzeroth.m2",
};

EXPANSION_LOW_RES_BG = {
	[LE_EXPANSION_CLASSIC] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
--	[LE_EXPANSION_BURNING_CRUSADE] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
--	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
--	[LE_EXPANSION_CATACLYSM] =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
--	[LE_EXPANSION_MISTS_OF_PANDARIA] =  "Interface\\Glues\\Models\\UI_MainMenu_LowBandwidth\\UI_MainMenu_LowBandwidth.m2",
--	[LE_EXPANSION_WARLORDS_OF_DRAENOR] =  "Interface\\Glues\\Models\\UI_MainMenu_Warlords\\UI_MainMenu_Warlords_LowBandwidth.m2",
--	[LE_EXPANSION_LEGION] =  "Interface\\Glues\\Models\\UI_MainMenu_Legion\\UI_MainMenu_Legion_LowBandwidth.m2",	-- TODO: Fix for 7.0
--	[LE_EXPANSION_BATTLE_FOR_AZEROTH] =  "Interface\\Glues\\Models\\UI_MAINMENU_BFA_LOWBANDWIDTH\\UI_MainMenu_BFA_LowBandwidth.m2",
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
  -- Movie sequence 7 = Legion
  { 470 },
  -- Movie sequence 8 = BFA
  { 852 },
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
	[CREDITS_TYPE_VANILLA] = {
		{ file="NightsHollow", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7, maxTexIndex = 4 },
	},

	[CREDITS_TYPE_CLASSIC] = {
		{ file="ClassicGryphon", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
	},

--	[LE_EXPANSION_BURNING_CRUSADE] = {
--		{ file="Illidan", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--	},
--
--	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = {
--		{ file="CinSnow01TGA", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--	},
--
--	[LE_EXPANSION_CATACLYSM] = {
--		path = "CATACLYSM",
--		{ file="Greymane City Map01", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--	},
--
--	[LE_EXPANSION_MISTS_OF_PANDARIA] = {
--		path = "Pandaria",
--		{ file="Mogu_BossConcept_New", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--	},
--
--	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = {
--		path = "Warlords",
--		{ file="Arrak_Forest_Dark", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--	},
--
--	[LE_EXPANSION_LEGION] = {
--		path = "Legion",
--		{ file="Fel", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="BlackRookHold", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="TombofSargeras", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="SuramarColor", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="AegwynnsTower", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="SuramarLandscape", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="DeathPortal", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Tauren", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="SuramarTreesRound", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="NashalStatue", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="BElfDemonHunter", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="VrykulLongHouse", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="SeaGiant", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="FelObelisk", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="DemonHunterArmor", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Valhalla", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="SuramarCrags", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="GreatHall", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="NashalTrees", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="DeathKnightFrostWeapons", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="ItaiMysticFacade", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="NightWellFX", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="PriestArmor", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="TaurenBuildings", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="FelStructureBarrackVariants", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="SuramarCatacombs", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="LegionArmy", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="NightElfBridges", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="RogueArmor", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="AncientSuramarCity", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="NightElfPropInterior", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="AncientSuramar", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="MageArmor", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="CombatRogueWeapons", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="AzunaZone", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="DruidArmor", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="ShamanArmor", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Owl", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="NightElfPropExterior", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="SeaGiantKing", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Satyr", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="AncientNightElfBuilding", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="BugBear", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="SuramarAstronomyRoom", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="ThorimStormFistWeapons", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="NashalPainting", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="ShamanMythicArmor", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--	},
--	[LE_EXPANSION_BATTLE_FOR_AZEROTH] = {
--		path = "BattleforAzeroth",
--		{ file="Battle001_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle002_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle003_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle004_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle005_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle006_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle007_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle008_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle009_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle010_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle011_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle012_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle013_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle014_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle015_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle016_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle017_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle018_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle019_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle020_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle021_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle022_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle023_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle024_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle025_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle026_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle027_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle028_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle029_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle030_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle031_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle032_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle033_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle034_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle035_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle036_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle037_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle038_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle039_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle040_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle041_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle042_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--		{ file="Battle043_", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
--	},
};

GLUE_CREDITS_SOUND_KITS = {
	[CREDITS_TYPE_VANILLA]					= SOUNDKIT.MENU_CREDITS01,
	[CREDITS_TYPE_CLASSIC]					= SOUNDKIT.MENU_CREDITS01,
--	[LE_EXPANSION_BURNING_CRUSADE]			= SOUNDKIT.MENU_CREDITS02,
--	[LE_EXPANSION_WRATH_OF_THE_LICH_KING]	= SOUNDKIT.MENU_CREDITS03,
--	[LE_EXPANSION_CATACLYSM]				= SOUNDKIT.MENU_CREDITS04,
--	[LE_EXPANSION_MISTS_OF_PANDARIA]		= SOUNDKIT.MENU_CREDITS05,
--	[LE_EXPANSION_WARLORDS_OF_DRAENOR]		= SOUNDKIT.MENU_CREDITS06,
--	[LE_EXPANSION_LEGION]					= SOUNDKIT.MENU_CREDITS07,
--	[LE_EXPANSION_BATTLE_FOR_AZEROTH] 		= SOUNDKIT.MENU_CREDITS08,
};

AUTO_LOGIN_WAIT_TIME = 1.75;

NORMAL_FONT_COLOR			= CreateColor(1.0, 0.82, 0.0);
HIGHLIGHT_FONT_COLOR		= CreateColor(1.0, 1.0, 1.0);
RED_FONT_COLOR				= CreateColor(1.0, 0.1, 0.1);
DIM_RED_FONT_COLOR			= CreateColor(0.8, 0.1, 0.1);
GREEN_FONT_COLOR			= CreateColor(0.1, 1.0, 0.1);
GRAY_FONT_COLOR				= CreateColor(0.5, 0.5, 0.5);
YELLOW_FONT_COLOR			= CreateColor(1.0, 1.0, 0.0);
BLUE_FONT_COLOR				= CreateColor(0, 0.749, 0.953);
LIGHTYELLOW_FONT_COLOR		= CreateColor(1.0, 1.0, 0.6);
ORANGE_FONT_COLOR			= CreateColor(1.0, 0.5, 0.25);
PASSIVE_SPELL_FONT_COLOR	= CreateColor(0.77, 0.64, 0.0);
BATTLENET_FONT_COLOR 		= CreateColor(0.510, 0.773, 1.0);
TRANSMOGRIFY_FONT_COLOR		= CreateColor(1, 0.5, 1);
DISABLED_FONT_COLOR			= CreateColor(0.498, 0.498, 0.498);
LIGHTBLUE_FONT_COLOR		= CreateColor(0.53, 0.67, 1.0);

HTML_START = "<html><body><p>";
HTML_START_CENTERED = "<html><body><p align=\"center\">";
HTML_END = "</p></body></html>";

-- month names show up differently for full date displays in some languages
CALENDAR_FULLDATE_MONTH_NAMES = {
	FULLDATE_MONTH_JANUARY,
	FULLDATE_MONTH_FEBRUARY,
	FULLDATE_MONTH_MARCH,
	FULLDATE_MONTH_APRIL,
	FULLDATE_MONTH_MAY,
	FULLDATE_MONTH_JUNE,
	FULLDATE_MONTH_JULY,
	FULLDATE_MONTH_AUGUST,
	FULLDATE_MONTH_SEPTEMBER,
	FULLDATE_MONTH_OCTOBER,
	FULLDATE_MONTH_NOVEMBER,
	FULLDATE_MONTH_DECEMBER,
};