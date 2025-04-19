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
			PerksProgramFrame:SetLabelFont(SystemFont_Shadow_Med2);
        end,
	},
	zhTW = {
        localize = function()
			PerksProgramFrame:SetLabelFont(SystemFont_Shadow_Med2);
        end,

        localizeFrames = function()
        end,
    },
};

SetupLocalization(l10nTable);