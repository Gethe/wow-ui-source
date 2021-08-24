--
-- Colors
--
NORMAL_FONT_COLOR_CODE		= "|cffffd200";
HIGHLIGHT_FONT_COLOR_CODE	= "|cffffffff";
RED_FONT_COLOR_CODE			= "|cffff2020";
GREEN_FONT_COLOR_CODE		= "|cff20ff20";
GRAY_FONT_COLOR_CODE		= "|cff808080";
YELLOW_FONT_COLOR_CODE		= "|cffffff00";
LIGHTYELLOW_FONT_COLOR_CODE	= "|cffffff9a";
ORANGE_FONT_COLOR_CODE		= "|cffff7f3f";
ACHIEVEMENT_COLOR_CODE		= "|cffffff00";
BATTLENET_FONT_COLOR_CODE	= "|cff82c5ff";
DISABLED_FONT_COLOR_CODE	= "|cff7f7f7f";
FONT_COLOR_CODE_CLOSE		= "|r";

WHITE_FONT_COLOR			= CreateColor(1, 1, 1);
BLACK_FONT_COLOR			= CreateColor(0, 0, 0);
BATTLENET_FONT_COLOR 		= CreateColor(0.510, 0.773, 1.0);
BLUE_FONT_COLOR				= CreateColor(0, 0.749, 0.953);
DARKGRAY_COLOR				= CreateColor(0.4, 0.4, 0.4);
DEFAULT_TOOLTIP_COLOR		= {0.8, 0.8, 0.8, 0.09, 0.09, 0.09};
DIM_RED_FONT_COLOR			= CreateColor(0.8, 0.1, 0.1);
DISABLED_FONT_COLOR			= CreateColor(0.498, 0.498, 0.498);
GRAY_FONT_COLOR				= CreateColor(0.5, 0.5, 0.5);
GREEN_FONT_COLOR			= CreateColor(0.1, 1.0, 0.1);
HIGHLIGHT_FONT_COLOR		= CreateColor(1.0, 1.0, 1.0);
LIGHTBLUE_FONT_COLOR		= CreateColor(0.53, 0.67, 1.0);
LIGHTGRAY_FONT_COLOR		= CreateColor(0.6, 0.6, 0.6);
LIGHTYELLOW_FONT_COLOR		= CreateColor(1.0, 1.0, 0.6);
BRIGHTBLUE_FONT_COLOR		= CreateColor(0.4, 0.733, 1.0);
NORMAL_FONT_COLOR			= CreateColor(1.0, 0.82, 0.0);
ORANGE_FONT_COLOR			= CreateColor(1.0, 0.5, 0.25);
PASSIVE_SPELL_FONT_COLOR	= CreateColor(0.77, 0.64, 0.0);
RED_FONT_COLOR				= CreateColor(1.0, 0.1, 0.1);
TRANSMOGRIFY_FONT_COLOR		= CreateColor(1, 0.5, 1);
VERY_DARK_GRAY_COLOR		= CreateColor(0.15, 0.15, 0.15);
VERY_LIGHT_GRAY_COLOR		= CreateColor(.9, .9, .9);
YELLOW_FONT_COLOR			= CreateColor(1.0, 1.0, 0.0);
TOOLTIP_DEFAULT_COLOR		= CreateColor(1, 1, 1);
TOOLTIP_DEFAULT_BACKGROUND_COLOR = CreateColor(0.09, 0.09, 0.19);

function GetClassAtlas(className)
	return ("classicon-%s"):format(className);
end