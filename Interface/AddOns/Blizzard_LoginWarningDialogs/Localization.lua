local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {
        localizeFrames = function()
			KoreanRatings.localeMatches = true;
        end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
        localizeFrames = function()
			ChinaAgeAppropriatenessWarning.localeMatches = true;
        end,
	},
	zhTW = {
        localizeFrames = function()
			TaiwanFraudWarning.localeMatches = true;
        end,
	},
};

SetupLocalization(l10nTable);
