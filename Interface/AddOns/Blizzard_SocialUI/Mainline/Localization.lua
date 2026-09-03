local function Localize_zh()
	local presenceDropdown = SocialUIFrame.BattleNetBar.ControlsContainer.OnlineStatusDropdown;
	if presenceDropdown then
		presenceDropdown.presenceIconSizeForDropdown = 16;
	end
end

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
		localize = Localize_zh,
	},
	zhTW = {
		localize = Localize_zh,
	},
};

SetupLocalization(l10nTable);
