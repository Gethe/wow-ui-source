-- luacheck: ignore 111 (setting non-standard global variable)

local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {},
	zhTW = {
        localize = function()
			SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD = 60 * 60; -- greater than 1 hour
			SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD = 24 * 60 * 60; -- less than 24 hours
			SMALLER_AURA_DURATION_FONT = "GameFontHighlightSmall2";
			SMALLER_AURA_DURATION_OFFSET_Y = -2;
        end,
    },
};

SetupLocalization(l10nTable);