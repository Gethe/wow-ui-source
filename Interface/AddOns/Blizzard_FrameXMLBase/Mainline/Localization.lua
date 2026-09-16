local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {
		localizeFrames = function()
			MIN_CHARACTER_SEARCH = 1;
		end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localizeFrames = function ()
			MIN_CHARACTER_SEARCH = 1;
		end
	},
	zhTW = {
        localize = function()

        end,

        localizeFrames = function()
			MIN_CHARACTER_SEARCH = 1;
        end,
    },
};

SetupLocalization(l10nTable);