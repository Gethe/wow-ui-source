local function AdjustFriendsFrameDropdown_132()
	UIDropDownMenu_SetWidth(FriendsFriendsFrameDropDown, 132);
end

local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {
		localizeFrames = AdjustFriendsFrameDropdown_132,
	},
	esMX = {
		localizeFrames = AdjustFriendsFrameDropdown_132,
	},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {
		localizeFrames = AdjustFriendsFrameDropdown_132,
	},
	ptPT = {
		localizeFrames = AdjustFriendsFrameDropdown_132,
	},
	ruRU = {},
	zhCN = {},
	zhTW = {},
};

SetupLocalization(l10nTable);