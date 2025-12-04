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
			ChatFrameUtil.SetIMEShown(true);
		end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localizeFrames = function()
			LocalizeCombatConfig_zh();
			ChatFrameUtil.SetIMEShown(true);
		end,
	},
	zhTW = {
        localizeFrames = function()
			LocalizeCombatConfig_zh();
			ChatFrameUtil.SetIMEShown(true);
        end,
    },
};

SetupLocalization(l10nTable);