-- luacheck: ignore 111 (setting non-standard global variable)

local function LocalizeFriendsFrame_zh()
	for i=1, (FriendsFrame.numTabs or 0) do
		tabName = "FriendsFrameTab"..i;
		_G[tabName].Text:SetPoint("CENTER", tabName, "CENTER", 0, 5);
	end
end

local function AdjustFriendsFrameDropdownWidth(overrideWidth)
	if overrideWidth then
		FriendsFriendsFrameDropdown.baseWidth = overrideWidth;
	end
end

local l10nTable = {
	deDE = {
		localizeFrames = function() AdjustFriendsFrameDropdownWidth(180) end,
	},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {
		localizeFrames = function() AdjustFriendsFrameDropdownWidth(180) end,
	},
	itIT = {},
	koKR = {},
	ptBR = {
		localizeFrames = function() AdjustFriendsFrameDropdownWidth(180) end,
	},
	ptPT = {
		localizeFrames = function() AdjustFriendsFrameDropdownWidth(180) end,
	},
	ruRU = {},
	zhCN = {
		localizeFrames = function ()
			FRIENDS_BUTTON_NORMAL_HEIGHT = 38;
			FRIENDS_BUTTON_LARGE_HEIGHT = 52;
			LocalizeFriendsFrame_zh();
		end,
	},
	zhTW = {
		localize = function()
		end,

		localizeFrames = function()
			LocalizeFriendsFrame_zh();
		end,
	},
};

SetupLocalization(l10nTable);