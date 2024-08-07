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
		localizeFrames = function()
			MONEY_TEXT_VADJUST = 2;
		end,
	},
	zhTW = {
        localizeFrames = function()
			MONEY_TEXT_VADJUST = 1;
        end,
    },
};

SetupLocalization(l10nTable);