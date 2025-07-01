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
			StaticPopupDialogs["BATTLE_PET_RENAME"].maxLetters = 8;
        end,
	},
	zhTW = {},
};

SetupLocalization(l10nTable);
