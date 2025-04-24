--
-- New shared constants should be added to this
--

local envTable = GetCurrentEnvironment();

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

FACTION_LABELS_FROM_STRING = {
	["Horde"] = FACTION_HORDE,
	["Alliance"] = FACTION_ALLIANCE,
}

-- If you add a class here, you also need to add it to RAID_CLASS_COLORS, CHARCREATE_CLASS_INFO, CLASS_SORT_ORDER, and maybe to ALT_MANA_BAR_PAIR_DISPLAY_INFO
-- Also add a new RaidButton in Blizzard_RaidUI.xml: name="RaidClassButton###..
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
	["EVOKER"] 		= {0, 0.25, 0.75, 1},
};

function GetClassAtlas(className)
	return ("classicon-%s"):format(className);
end

function GetBodyTypeAtlases(bodyTypeID)
	local genderName = (bodyTypeID == Enum.UnitSex.Male) and "male" or "female";
	local baseAtlas = ("charactercreate-gendericon-%s"):format(genderName);
	local selectedAtlas = ("%s-selected"):format(baseAtlas);
	return baseAtlas, selectedAtlas;
end

function SetGamepadBindingStrings(mainBinding, abbrBinding, name, opt_abbrName)
	local abbrName = opt_abbrName or name;
	envTable[mainBinding] = ("|A:Gamepad_%s_64:24:24|a"):format(name);
	envTable[abbrBinding] = ("|A:Gamepad_%s_32:14:14|a"):format(abbrName);
end
-- Generic GamePad button labels
SetGamepadBindingStrings("KEY_PADDUP",			"KEY_ABBR_PADDUP",			"Gen_Up");
SetGamepadBindingStrings("KEY_PADDRIGHT",		"KEY_ABBR_PADDRIGHT",		"Gen_Right");
SetGamepadBindingStrings("KEY_PADDDOWN",		"KEY_ABBR_PADDDOWN",		"Gen_Down");
SetGamepadBindingStrings("KEY_PADDLEFT",		"KEY_ABBR_PADDLEFT",		"Gen_Left");
SetGamepadBindingStrings("KEY_PAD1",			"KEY_ABBR_PAD1",			"Gen_1");
SetGamepadBindingStrings("KEY_PAD2",			"KEY_ABBR_PAD2",			"Gen_2");
SetGamepadBindingStrings("KEY_PAD3",			"KEY_ABBR_PAD3",			"Gen_3");
SetGamepadBindingStrings("KEY_PAD4",			"KEY_ABBR_PAD4",			"Gen_4");
SetGamepadBindingStrings("KEY_PAD5",			"KEY_ABBR_PAD5",			"Gen_5");
SetGamepadBindingStrings("KEY_PAD6",			"KEY_ABBR_PAD6",			"Gen_6");
SetGamepadBindingStrings("KEY_PADLSTICK",		"KEY_ABBR_PADLSTICK",		"Gen_LStickIn");
SetGamepadBindingStrings("KEY_PADRSTICK",		"KEY_ABBR_PADRSTICK",		"Gen_RStickIn");
SetGamepadBindingStrings("KEY_PADLSHOULDER",	"KEY_ABBR_PADLSHOULDER",	"Gen_LShoulder");
SetGamepadBindingStrings("KEY_PADRSHOULDER",	"KEY_ABBR_PADRSHOULDER",	"Gen_RShoulder");
SetGamepadBindingStrings("KEY_PADLTRIGGER",		"KEY_ABBR_PADLTRIGGER",		"Gen_LTrigger");
SetGamepadBindingStrings("KEY_PADRTRIGGER",		"KEY_ABBR_PADRTRIGGER",		"Gen_RTrigger");
SetGamepadBindingStrings("KEY_PADLSTICKUP",		"KEY_ABBR_PADLSTICKUP",		"Gen_LStickUp");
SetGamepadBindingStrings("KEY_PADLSTICKRIGHT",	"KEY_ABBR_PADLSTICKRIGHT",	"Gen_LStickRight");
SetGamepadBindingStrings("KEY_PADLSTICKDOWN",	"KEY_ABBR_PADLSTICKDOWN",	"Gen_LStickDown");
SetGamepadBindingStrings("KEY_PADLSTICKLEFT",	"KEY_ABBR_PADLSTICKLEFT",	"Gen_LStickLeft");
SetGamepadBindingStrings("KEY_PADRSTICKUP",		"KEY_ABBR_PADRSTICKUP",		"Gen_RStickUp");
SetGamepadBindingStrings("KEY_PADRSTICKRIGHT",	"KEY_ABBR_PADRSTICKRIGHT",	"Gen_RStickRight");
SetGamepadBindingStrings("KEY_PADRSTICKDOWN",	"KEY_ABBR_PADRSTICKDOWN",	"Gen_RStickDown");
SetGamepadBindingStrings("KEY_PADRSTICKLEFT",	"KEY_ABBR_PADRSTICKLEFT",	"Gen_RStickLeft");
SetGamepadBindingStrings("KEY_PADPADDLE1",		"KEY_ABBR_PADPADDLE1",		"Gen_Paddle1");
SetGamepadBindingStrings("KEY_PADPADDLE2",		"KEY_ABBR_PADPADDLE2",		"Gen_Paddle2");
SetGamepadBindingStrings("KEY_PADPADDLE3",		"KEY_ABBR_PADPADDLE3",		"Gen_Paddle3");
SetGamepadBindingStrings("KEY_PADPADDLE4",		"KEY_ABBR_PADPADDLE4",		"Gen_Paddle4");
SetGamepadBindingStrings("KEY_PADFORWARD",		"KEY_ABBR_PADFORWARD",		"Gen_Forward");
SetGamepadBindingStrings("KEY_PADBACK",			"KEY_ABBR_PADBACK",			"Gen_Back");
SetGamepadBindingStrings("KEY_PADSYSTEM",		"KEY_ABBR_PADSYSTEM",		"Gen_System");
SetGamepadBindingStrings("KEY_PADSOCIAL",		"KEY_ABBR_PADSOCIAL",		"Gen_Share");
-- "Letters" label style specializations
SetGamepadBindingStrings("KEY_PADDUP_LTR",		"KEY_ABBR_PADDUP_LTR",		"Ltr_Up",		"Gen_Up");
SetGamepadBindingStrings("KEY_PADDRIGHT_LTR",	"KEY_ABBR_PADDRIGHT_LTR",	"Ltr_Right",	"Gen_Right");
SetGamepadBindingStrings("KEY_PADDDOWN_LTR",	"KEY_ABBR_PADDDOWN_LTR",	"Ltr_Down",		"Gen_Down");
SetGamepadBindingStrings("KEY_PADDLEFT_LTR",	"KEY_ABBR_PADDLEFT_LTR",	"Ltr_Left",		"Gen_Left");
SetGamepadBindingStrings("KEY_PAD1_LTR",		"KEY_ABBR_PAD1_LTR",		"Ltr_A");
SetGamepadBindingStrings("KEY_PAD2_LTR",		"KEY_ABBR_PAD2_LTR",		"Ltr_B");
SetGamepadBindingStrings("KEY_PAD3_LTR",		"KEY_ABBR_PAD3_LTR",		"Ltr_X");
SetGamepadBindingStrings("KEY_PAD4_LTR",		"KEY_ABBR_PAD4_LTR",		"Ltr_Y");
SetGamepadBindingStrings("KEY_PADLSHOULDER_LTR","KEY_ABBR_PADLSHOULDER_LTR","Ltr_LShoulder","Gen_LShoulder");
SetGamepadBindingStrings("KEY_PADRSHOULDER_LTR","KEY_ABBR_PADRSHOULDER_LTR","Ltr_RShoulder","Gen_RShoulder");
SetGamepadBindingStrings("KEY_PADLTRIGGER_LTR",	"KEY_ABBR_PADLTRIGGER_LTR",	"Ltr_LTrigger",	"Gen_LTrigger");
SetGamepadBindingStrings("KEY_PADRTRIGGER_LTR",	"KEY_ABBR_PADRTRIGGER_LTR",	"Ltr_RTrigger",	"Gen_RTrigger");
SetGamepadBindingStrings("KEY_PADFORWARD_LTR",	"KEY_ABBR_PADFORWARD_LTR",	"Ltr_Menu");
SetGamepadBindingStrings("KEY_PADBACK_LTR",		"KEY_ABBR_PADBACK_LTR",		"Ltr_View");
SetGamepadBindingStrings("KEY_PADSYSTEM_LTR",	"KEY_ABBR_PADSYSTEM_LTR",	"Ltr_System");
SetGamepadBindingStrings("KEY_PADSOCIAL_LTR",	"KEY_ABBR_PADSOCIAL_LTR",	"Ltr_Share",	"Gen_Share");
-- "Shapes" label style specializations
SetGamepadBindingStrings("KEY_PADDUP_SHP",		"KEY_ABBR_PADDUP_SHP",		"Shp_Up",		"Gen_Up");
SetGamepadBindingStrings("KEY_PADDRIGHT_SHP",	"KEY_ABBR_PADDRIGHT_SHP",	"Shp_Right",	"Gen_Right");
SetGamepadBindingStrings("KEY_PADDDOWN_SHP",	"KEY_ABBR_PADDDOWN_SHP",	"Shp_Down",		"Gen_Down");
SetGamepadBindingStrings("KEY_PADDLEFT_SHP",	"KEY_ABBR_PADDLEFT_SHP",	"Shp_Left",		"Gen_Left");
SetGamepadBindingStrings("KEY_PAD1_SHP",		"KEY_ABBR_PAD1_SHP",		"Shp_Cross");
SetGamepadBindingStrings("KEY_PAD2_SHP",		"KEY_ABBR_PAD2_SHP",		"Shp_Circle");
SetGamepadBindingStrings("KEY_PAD3_SHP",		"KEY_ABBR_PAD3_SHP",		"Shp_Square");
SetGamepadBindingStrings("KEY_PAD4_SHP",		"KEY_ABBR_PAD4_SHP",		"Shp_Triangle");
SetGamepadBindingStrings("KEY_PAD5_SHP",		"KEY_ABBR_PAD5_SHP",		"Shp_MicMute");
SetGamepadBindingStrings("KEY_PAD6_SHP",		"KEY_ABBR_PAD6_SHP",		"Shp_TouchpadR");
SetGamepadBindingStrings("KEY_PADLSTICK_SHP",	"KEY_ABBR_PADLSTICK_SHP",	"Shp_LStickIn");
SetGamepadBindingStrings("KEY_PADRSTICK_SHP",	"KEY_ABBR_PADRSTICK_SHP",	"Shp_RStickIn");
SetGamepadBindingStrings("KEY_PADLSHOULDER_SHP","KEY_ABBR_PADLSHOULDER_SHP","Shp_LShoulder");
SetGamepadBindingStrings("KEY_PADRSHOULDER_SHP","KEY_ABBR_PADRSHOULDER_SHP","Shp_RShoulder");
SetGamepadBindingStrings("KEY_PADLTRIGGER_SHP",	"KEY_ABBR_PADLTRIGGER_SHP",	"Shp_LTrigger");
SetGamepadBindingStrings("KEY_PADRTRIGGER_SHP",	"KEY_ABBR_PADRTRIGGER_SHP",	"Shp_RTrigger");
SetGamepadBindingStrings("KEY_PADFORWARD_SHP",	"KEY_ABBR_PADFORWARD_SHP",	"Shp_Menu");
SetGamepadBindingStrings("KEY_PADBACK_SHP",		"KEY_ABBR_PADBACK_SHP",		"Shp_TouchpadL");
SetGamepadBindingStrings("KEY_PADSYSTEM_SHP",	"KEY_ABBR_PADSYSTEM_SHP",	"Shp_System");
SetGamepadBindingStrings("KEY_PADSOCIAL_SHP",	"KEY_ABBR_PADSOCIAL_SHP",	"Shp_Share");
-- "Reverse" label style specializations
SetGamepadBindingStrings("KEY_PAD1_REV",		"KEY_ABBR_PAD1_REV",		"Rev_B");
SetGamepadBindingStrings("KEY_PAD2_REV",		"KEY_ABBR_PAD2_REV",		"Rev_A");
SetGamepadBindingStrings("KEY_PAD3_REV",		"KEY_ABBR_PAD3_REV",		"Rev_Y");
SetGamepadBindingStrings("KEY_PAD4_REV",		"KEY_ABBR_PAD4_REV",		"Rev_X");
SetGamepadBindingStrings("KEY_PADLSHOULDER_REV","KEY_ABBR_PADLSHOULDER_REV","Rev_LShoulder");
SetGamepadBindingStrings("KEY_PADRSHOULDER_REV","KEY_ABBR_PADRSHOULDER_REV","Rev_RShoulder");
SetGamepadBindingStrings("KEY_PADLTRIGGER_REV",	"KEY_ABBR_PADLTRIGGER_REV",	"Rev_LTrigger");
SetGamepadBindingStrings("KEY_PADRTRIGGER_REV",	"KEY_ABBR_PADRTRIGGER_REV",	"Rev_RTrigger");
SetGamepadBindingStrings("KEY_PADFORWARD_REV",	"KEY_ABBR_PADFORWARD_REV",	"Rev_Plus");
SetGamepadBindingStrings("KEY_PADBACK_REV",		"KEY_ABBR_PADBACK_REV",		"Rev_Minus");
SetGamepadBindingStrings("KEY_PADSYSTEM_REV",	"KEY_ABBR_PADSYSTEM_REV",	"Rev_Home",		"Gen_Home");
SetGamepadBindingStrings("KEY_PADSOCIAL_REV",	"KEY_ABBR_PADSOCIAL_REV",	"Rev_Capture");

WOW_GAMES_CATEGORY_ID = 33;
WOW_GAME_TIME_CATEGORY_ID = 37;
WOW_SUBSCRIPTION_CATEGORY_ID = 156;