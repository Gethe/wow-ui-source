local function LocalizeCombatConfig_zh()
	CombatConfigColorsExampleTitle:Hide();
	CombatConfigColorsExampleString1:SetPoint("TOPLEFT", 25, -16);
	CombatConfigFormattingExampleTitle:Hide();
	CombatConfigFormattingExampleString1:SetPoint("TOPLEFT", 15, -16);
end

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
			ChatEdit_LanguageShow();
		end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localizeFrames = function()
			LocalizeCombatConfig_zh();
			ChatEdit_LanguageShow();
		end,
	},
	zhTW = {
        localizeFrames = function()
			LocalizeCombatConfig_zh();
			ChatEdit_LanguageShow();
        end,
    },
};

SetupLocalization(l10nTable);