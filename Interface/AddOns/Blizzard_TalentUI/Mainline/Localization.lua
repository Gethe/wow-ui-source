local function LocalizeTalentTabs_zh()
	for i=1, (PlayerTalentFrame.numTabs or 0) do
		local tabName = "PlayerTalentFrameTab"..i;
		_G[tabName.."Text"]:SetPoint("CENTER", tabName, "CENTER", 0, 5);
	end
end

local l10nTable = {
	deDE = {
		localize = function()
			EXTEND_TALENT_FRAME_TALENT_DISPLAY = true;
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
	ruRU = {
		localize = function()
			EXTEND_TALENT_FRAME_TALENT_DISPLAY = true;
		end,
	},
	zhCN = {
		localize = function()
			LocalizeTalentTabs_zh();
			TALENT_HEADER_DEFAULT_Y = -33;
			TALENT_HEADER_CHOOSE_SPEC_Y = -24;

		end,
	},
	zhTW = {
		localize = function()
			LocalizeTalentTabs_zh();
		end,
	},
};

SetupLocalization(l10nTable);