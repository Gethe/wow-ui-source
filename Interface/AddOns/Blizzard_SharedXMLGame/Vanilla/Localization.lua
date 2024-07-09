-- luacheck: ignore 111 (setting non-standard global variable)

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
	ptPT = {
		localize = function()
			SOCIAL_ITEM_ARMORY_LINK = "http://eu.battle.net/wow/pt/item"; -- This doesn't exist...probably delete this line.
		end,
	},
	ruRU = {},
	zhCN = {},
	zhTW = {},
};

SetupLocalization(l10nTable);