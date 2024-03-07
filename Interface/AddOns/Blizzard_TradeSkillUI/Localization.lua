-- This file is executed at the end of addon load
TradeSkillFrame.DetailsFrame.Contents.Description:SetFontObject("GameFontHighlightSmall");

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
	zhCN = {},
	zhTW = {
		localize = function()
			TradeSkillFrame.DetailsFrame.Contents.Description:SetFontObject("GameFontHighlightSmall");
		end,
	},
};

SetupLocalization(l10nTable);