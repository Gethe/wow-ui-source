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
	ptPT = {},
	ruRU = {},
	zhCN = {
        localize = function()
			COLLAPSE_ORDER_HALL_FOLLOWER_ITEM_LEVEL_DISPLAY = true;
        end,
	},
	zhTW = {
        localize = function()
			COLLAPSE_ORDER_HALL_FOLLOWER_ITEM_LEVEL_DISPLAY = true;
        end,

        localizeFrames = function()
        end,
    },
};

SetupLocalization(l10nTable);