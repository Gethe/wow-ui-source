-- luacheck: ignore 111 (setting non-standard global variable)

local function LocalizeFriendsFrame_zh()
	AddFriendNameEditBox:SetPoint("TOP", 0, -144);

	for i=1, (FriendsFrame.numTabs or 0) do
		tabName = "FriendsFrameTab"..i;
		_G[tabName].Text:SetPoint("CENTER", tabName, "CENTER", 0, 5);
	end
end

local function AdjustFriendsFrameDropdown_132()
	FriendsFriendsFrameDropdown:SetWidth(132);
end

local function AdjustFriendsFrameDropdown_136()
	FriendsFriendsFrameDropdown:SetWidth(136);
end

local l10nTable = {
	deDE = {
		localizeFrames = function()
			FriendsFriendsFrameDropdown:SetWidth(146);
		end
	},
	enGB = {},
	enUS = {},
	esES = {
		localizeFrames = AdjustFriendsFrameDropdown_132,
	},
	esMX = {
		localizeFrames = AdjustFriendsFrameDropdown_132,
	},
	frFR = {
		localizeFrames = AdjustFriendsFrameDropdown_136,
	},
	itIT = {
		localizeFrames = AdjustFriendsFrameDropdown_136,
	},
	koKR = {},
	ptBR = {
		localizeFrames = AdjustFriendsFrameDropdown_132,
	},
	ptPT = {
		localizeFrames = AdjustFriendsFrameDropdown_132,
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