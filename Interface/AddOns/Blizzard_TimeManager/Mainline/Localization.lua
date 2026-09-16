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
			CLOCK_TICKER_Y_OVERRIDE = 2;
			StopwatchTitle:SetPoint("TOP", 0, -1);
			StopwatchTicker:SetPoint("BOTTOMRIGHT", -49, 4)
		end,
	},
	zhTW = {
        localize = function()
			CLOCK_TICKER_Y_OVERRIDE = 2;
			StopwatchTitle:SetPoint("TOP", 0, -1);
			StopwatchTicker:SetPoint("BOTTOMRIGHT", -49, 5);
        end,

        localizeFrames = function()
        end,
    },
};

SetupLocalization(l10nTable);