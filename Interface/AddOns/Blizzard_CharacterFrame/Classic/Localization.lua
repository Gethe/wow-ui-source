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
	zhCN = {
		localize = function()
			STATFRAME_STATTEXT_FONT_OVERRIDE = TextStatusBarText;
        end,
	},
	zhTW = {
        localize = function()
        end,

        localizeFrames = function()
        end,
    },
};

SetupLocalization(l10nTable);