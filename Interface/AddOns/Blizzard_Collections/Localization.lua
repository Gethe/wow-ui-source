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
			local renameDialog = StaticPopupDialogs["BATTLE_PET_RENAME"];
			if renameDialog then
				renameDialog.maxLetters = 8;
			end
		end,
	},
	zhTW = {},
};

SetupLocalization(l10nTable);
