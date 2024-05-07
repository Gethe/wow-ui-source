local l10nTable = {
	deDE = {
		localize = function()
			EncounterJournal.localizeInstanceButton = function(self)
				self.name:SetFontObject("GameFontNormal");
			end
		end,
	},
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
	zhTW = {},
};

SetupLocalization(l10nTable);