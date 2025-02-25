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
			if (PetJournalHealPetButtonSpellName) then
				PetJournalHealPetButtonSpellName:SetWidth(90);
			end
		end,
	},
	zhCN = {},
	zhTW = {},
};

SetupLocalization(l10nTable);