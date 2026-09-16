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
			GameMenuFrame:SetRatingsButtonShown(true);
		end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {},
	zhTW = {
        localize = function()
        end,

        localizeFrames = function()
        end,
    },
};

SetupLocalization(l10nTable);