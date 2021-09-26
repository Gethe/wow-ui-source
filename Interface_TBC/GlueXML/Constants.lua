--Login Screen Ambience
EXPANSION_GLUE_AMBIENCE = {
	[LE_EXPANSION_CLASSIC]					= SOUNDKIT.GLUESCREEN_INTRO,
	[LE_EXPANSION_BURNING_CRUSADE]			= SOUNDKIT.GLUESCREEN_INTRO,
};

--Music
EXPANSION_GLUE_MUSIC = {
	[LE_EXPANSION_CLASSIC]					= SOUNDKIT.MUS_1_0_MAINTITLE_ORIGINAL,
	[LE_EXPANSION_BURNING_CRUSADE]			= SOUNDKIT.GS_BURNINGCRUSADE,
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

--Credits titles
CREDITS_TITLES = {
	[LE_EXPANSION_CLASSIC] = CREDITS_WOW_VANILLA,
	[LE_EXPANSION_BURNING_CRUSADE] = CREDITS_WOW_BC,
};

--Backgrounds
EXPANSION_HIGH_RES_BG = {
	[LE_EXPANSION_CLASSIC] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
	[LE_EXPANSION_BURNING_CRUSADE] = "Interface\\Glues\\Models\\UI_MainMenu_BurningCrusade\\UI_MainMenu_BurningCrusade.m2",
};

EXPANSION_LOW_RES_BG = {
	[LE_EXPANSION_CLASSIC] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
	[LE_EXPANSION_BURNING_CRUSADE] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
};

--Movie
MOVIE_CAPTION_FADE_TIME = 1.0;
-- These are movieID from the MOVIE database file.
MOVIE_LIST = {
  -- Movie sequence 1 = Wow Classic
  { 1, 2 },
  -- Movie sequence 2 = BC
  { 27 },
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
		[LE_RELEASE_TYPE_ORIGINAL] = {
			{ file="Acrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5, maxTexIndex=4 },
			{ file="Tauren", w=640, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Centaur", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="HordeBanner", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 },
			{ file="Naga", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.4 },
			{ file="NightsHollow", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Ocean", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Orc", w=256, h=512, offsetx=192, offsety=0, maxAlpha=0.7 },
			{ file="Strangle", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Troll", w=640, h=512, offsetx=0, offsety=0, maxAlpha=0.6 },
			{ file="TrollBanner", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 },
			{ file="Zepplin", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.5 },
			{ file="drake", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.5 },
			{ file="DwarfCrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 },
			{ file="Dwarfhunter", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.6 },
			{ file="gargoyle", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 },
			{ file="NightelfCrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 },
			{ file="Nightelves", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Orccamp", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="DragonIsles", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="tauren_hunter", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.7 },
			{ file="Darnasis", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="ForsakenCrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 },
			{ file="ShootingDwarf", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.6 },
			{ file="Thunderbluff", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="tolbarad", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="TaurenCrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 },
			{ file="razorfen", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="swampofsorrows", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Desolace", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="SouthernDesolace", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="undeadcrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 },
			{ file="TirisfallGlades", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="ThousandNeedles", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Elemental", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Badlands", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="BlastedLands", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Fellwood", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="OrcShield", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 },
		},
		[LE_RELEASE_TYPE_MODERN] = {
			{ file="ClassicGryphon", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
		},
	},

	[LE_EXPANSION_BURNING_CRUSADE] = {
		[LE_RELEASE_TYPE_ORIGINAL] = {
			{ file="BD", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Wrathguard", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="WOW_BloodElves", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="ZulAman", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Arakkoa", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Hellfire_Concept", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Auchindoun", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Auchindoun_1H", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="1H_Axes", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="BE_Building", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="BE_Building_Two", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="BladesEdge", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="BladesEdgeMountains", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Blood_Elf_One", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="BloodElf_Female", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="BloodElf_Icon", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.7 },
			{ file="BloodElf_Priestess_Master", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="BloodElf_Two", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="BloodElf_Webimage", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Clefthoof_3_horn", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="1000px-Coilfangpaintover", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Dark_Portal", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Ddraenei_Start", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Demon_Chamber", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Draenei", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Draenei_Character", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Draenei_CityInt", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Draenei_Crest", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Draenei_Female", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Draenei_Paladin", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Draenei_Three", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Draenei_Two", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Dranei_F_Hair", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Dranei_M_Hair", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Elekk", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Female_BloodElf", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="FungalGiant", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Arcane_Golem", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Human_Mage", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="HumanMale", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Hunter", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Illidan", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Illidan_Concept", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Outland", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="MilitaryOrcBoss", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Naaru_CrashSite", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Naaru_Ship", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Ogre_Lord", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Shivan", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="L60ETC", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="RazorfenDowns", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="RidingDrake", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Shattrath", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Tier4_Druid", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Silvermoon_Day", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Silvermoon_Tower", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Tempest_Keep", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Terrokkar", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="The_Broken", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
			{ file="Photos", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
		},
		[LE_RELEASE_TYPE_MODERN] = {
			{ file="Illidan", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 },
		},
	},
};

GLUE_CREDITS_SOUND_KITS = {
	[LE_EXPANSION_CLASSIC]					= SOUNDKIT.MENU_CREDITS01,
	[LE_EXPANSION_BURNING_CRUSADE]			= SOUNDKIT.MENU_CREDITS02,
};

AUTO_LOGIN_WAIT_TIME = 1.75;

--Tooltip
GLUE_BACKDROP_COLOR = CreateColor(0.09, 0.09, 0.09);
GLUE_BACKDROP_BORDER_COLOR = CreateColor(0.8, 0.8, 0.8);
GLUE_ALLIANCE_COLOR = CreateColor(0.09, 0.09, 0.19);
GLUE_ALLIANCE_BORDER_COLOR = CreateColor(0.5, 0.5, 0.5);
GLUE_HORDE_COLOR = CreateColor(0.19, 0.05, 0.05);
GLUE_HORDE_BORDER_COLOR = CreateColor(0.5, 0.2, 0.2);

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