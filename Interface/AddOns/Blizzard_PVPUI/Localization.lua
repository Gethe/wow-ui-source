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
			--Adjust spec font so it doesn't overflow the window
			SpecializationSpecName:SetFontObject(GameFontNormalHuge);
		end,
	},
	zhCN = {
		localize = function()
			ConquestTooltip:SetHeight(242);
		end,
	},
	zhTW = {
		localize = function()
			ConquestTooltip:SetHeight(242);
		end,
	},
};

SetupLocalization(l10nTable);