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
	ruRU = {
		localize = function()
			--Adjust text widths for long Russian words
			PetJournalHealPetButtonSpellName:SetWidth(90)
		end,
	},
	zhCN = {
		localize = function()
			StaticPopupDialogs["BATTLE_PET_RENAME"].maxLetters = 8;
        end,
	},
	zhTW = {},
};

SetupLocalization(l10nTable);