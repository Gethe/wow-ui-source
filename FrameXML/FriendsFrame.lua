FRIENDS_TO_DISPLAY = 10;
FRIENDS_FRAME_FRIEND_HEIGHT = 34;
IGNORES_TO_DISPLAY = 19;
FRIENDS_FRAME_IGNORE_HEIGHT = 16;
PENDING_INVITES_TO_DISPLAY = 4;
PENDING_BUTTON_MIN_HEIGHT = 92;
FRIENDS_FRIENDS_TO_DISPLAY = 11;
FRIENDS_FRAME_FRIENDS_FRIENDS_HEIGHT = 16;
WHOS_TO_DISPLAY = 17;
FRIENDS_FRAME_WHO_HEIGHT = 16;
MAX_WHOS_FROM_SERVER = 50;

FRIENDS_SCROLLFRAME_HEIGHT = 307;
FRIENDS_BUTTON_TYPE_DIVIDER = 1;
FRIENDS_BUTTON_TYPE_BNET = 2;
FRIENDS_BUTTON_TYPE_WOW = 3;
FRIENDS_BUTTON_TYPE_INVITE = 4;
FRIENDS_BUTTON_TYPE_INVITE_HEADER = 5;
FRIENDS_BUTTON_HEIGHTS = {
	[FRIENDS_BUTTON_TYPE_DIVIDER] = 16,
	[FRIENDS_BUTTON_TYPE_BNET] = 34,
	[FRIENDS_BUTTON_TYPE_WOW] = 34,
	[FRIENDS_BUTTON_TYPE_INVITE] = 34,
	[FRIENDS_BUTTON_TYPE_INVITE_HEADER] = 31,
}

FRIENDS_TEXTURE_ONLINE = "Interface\\FriendsFrame\\StatusIcon-Online";
FRIENDS_TEXTURE_AFK = "Interface\\FriendsFrame\\StatusIcon-Away";
FRIENDS_TEXTURE_DND = "Interface\\FriendsFrame\\StatusIcon-DnD";
FRIENDS_TEXTURE_OFFLINE = "Interface\\FriendsFrame\\StatusIcon-Offline";
FRIENDS_TEXTURE_BROADCAST = "Interface\\FriendsFrame\\BroadcastIcon";
SQUELCH_TYPE_IGNORE = 1;
SQUELCH_TYPE_BLOCK_INVITE = 2;
FRIENDS_FRIENDS_POTENTIAL = 1;
FRIENDS_FRIENDS_MUTUAL = 2;
FRIENDS_FRIENDS_ALL = 3;
FRIENDS_TOOLTIP_MAX_GAME_ACCOUNTS = 5;
FRIENDS_TOOLTIP_MAX_WIDTH = 200;
FRIENDS_TOOLTIP_MARGIN_WIDTH = 12;

ADDFRIENDFRAME_WOWHEIGHT = 218;
ADDFRIENDFRAME_BNETHEIGHT = 296;

FRIEND_TAB_COUNT = 4;
FRIEND_TAB_FRIENDS = 1;
FRIEND_TAB_WHO = 2;
FRIEND_TAB_RAID = 3;
FRIEND_TAB_QUICK_JOIN = 4;

FRIEND_HEADER_TAB_COUNT = 2;	-- Updated in FriendsTabHeaderMixin:OnLoad based on whether RAF is enabled or not
FRIEND_HEADER_TAB_FRIENDS = 1;
FRIEND_HEADER_TAB_IGNORE = 2;
FRIEND_HEADER_TAB_RAF = 3;

local INVITE_RESTRICTION_NO_GAME_ACCOUNTS = 0;
local INVITE_RESTRICTION_CLIENT = 1;
local INVITE_RESTRICTION_LEADER = 2;
local INVITE_RESTRICTION_FACTION = 3;
local INVITE_RESTRICTION_REALM = 4;
local INVITE_RESTRICTION_INFO = 5;
local INVITE_RESTRICTION_WOW_PROJECT_ID = 6;
local INVITE_RESTRICTION_WOW_PROJECT_MAINLINE = 7;
local INVITE_RESTRICTION_WOW_PROJECT_CLASSIC = 8;
local INVITE_RESTRICTION_NONE = 9;
local INVITE_RESTRICTION_MOBILE = 10;
local INVITE_RESTRICTION_REGION = 11;

local FriendListEntries = { };
local playerRealmID = GetRealmID();
local playerRealmName = GetRealmName();
local playerFactionGroup = UnitFactionGroup("player");

WHOFRAME_DROPDOWN_LIST = {
	{name = ZONE, sortType = "zone"},
	{name = GUILD, sortType = "guild"},
	{name = RACE, sortType = "race"}
};

FRIENDSFRAME_SUBFRAMES = { "FriendsListFrame", "QuickJoinFrame", "IgnoreListFrame", "WhoFrame", "RecruitAFriendFrame", "RaidFrame" };
function FriendsFrame_ShowSubFrame(frameName)
	for index, value in pairs(FRIENDSFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			_G[value]:Show()
		elseif ( value == "RaidFrame" ) then
			if ( RaidFrame:GetParent() == FriendsFrame ) then
				RaidFrame:Hide();
			end
		else
			_G[value]:Hide();
		end
	end
end

function FriendsFrame_SummonButton_OnShow (self)
	FriendsFrame_SummonButton_Update(self);
end

function FriendsFrame_ShouldShowSummonButton(self)
	--returns shouldShow, enabled
	local id = self:GetParent().id;
	if ( not id ) then
		return false, false;
	end

	local enable = false;
	local bType = self:GetParent().buttonType;
	if ( self:GetParent().buttonType == FRIENDS_BUTTON_TYPE_WOW ) then
		--Get the information by WoW friends list ID (not BNet id.)
		local info = C_FriendList.GetFriendInfoByIndex(id);

		if not info or info.mobile or not info.connected or info.rafLinkType == Enum.RafLinkType.None then
			return false, false;
		end

		return true, CanSummonFriend(info.guid);
	elseif ( self:GetParent().buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
		--Get the information by BNet friends list index.
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id);

		local restriction = FriendsFrame_GetInviteRestriction(id);
		if restriction ~= INVITE_RESTRICTION_NONE or accountInfo.rafLinkType == Enum.RafLinkType.None then
			return false, false;
		else
			return true, accountInfo.gameAccountInfo.canSummon;
		end
	else
		return false, false;
	end
end

function FriendsFrame_SummonButton_Update (self)
	local shouldShow, enable = FriendsFrame_ShouldShowSummonButton(self);
	self:SetShown(shouldShow);

	local start, duration = GetSummonFriendCooldown();

	if ( duration > 0 ) then
		self.duration = duration;
		self.start = start;
	else
		self.duration = nil;
		self.start = nil;
	end


	local normalTexture = self:GetNormalTexture();
	local pushedTexture = self:GetPushedTexture();
	self.enabled = enable;
	if ( enable ) then
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
		pushedTexture:SetVertexColor(1.0, 1.0, 1.0);
	else
		normalTexture:SetVertexColor(0.4, 0.4, 0.4);
		pushedTexture:SetVertexColor(0.4, 0.4, 0.4);
	end
	CooldownFrame_Set(_G[self:GetName().."Cooldown"], start, duration, ((enable and 0) or 1));
end

function FriendsFrame_ClickSummonButton (self)
	local id = self:GetParent().id;
	if ( not id ) then
		return;
	end

	if ( self:GetParent().buttonType == FRIENDS_BUTTON_TYPE_WOW ) then
		--Summon by WoW friends list ID (not BNet id.)
		local info = C_FriendList.GetFriendInfoByIndex(id);

		SummonFriend(info.guid, info.name);
	elseif ( self:GetParent().buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
		--Summon by BNet friends list ID (index in this case.)
		BNSummonFriendByIndex(id);
	end
end

function FriendsFrame_ShowDropdown(name, connected, lineID, chatType, chatFrame, friendsList, isMobile, communityClubID, communityStreamID, communityEpoch, communityPosition, guid)
	HideDropDownMenu(1);
	if ( connected or friendsList ) then
		if ( connected ) then
			FriendsDropDown.initialize = FriendsFrameDropDown_Initialize;
		else
			FriendsDropDown.initialize = FriendsFrameOfflineDropDown_Initialize;
		end

		FriendsDropDown.displayMode = "MENU";
		FriendsDropDown.friendsDropDownName = name;
		FriendsDropDown.friendsList = friendsList;
		FriendsDropDown.lineID = lineID;
		FriendsDropDown.communityClubID = communityClubID;
		FriendsDropDown.communityStreamID = communityStreamID;
		FriendsDropDown.communityEpoch = communityEpoch;
		FriendsDropDown.communityPosition = communityPosition;
		FriendsDropDown.chatType = chatType;
		FriendsDropDown.chatTarget = name;
		FriendsDropDown.chatFrame = chatFrame;
		FriendsDropDown.bnetIDAccount = nil;
		FriendsDropDown.isMobile = isMobile;
		FriendsDropDown.guid = guid;
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor");
	end
end

function FriendsFrame_ShowBNDropdown(name, connected, lineID, chatType, chatFrame, friendsList, bnetIDAccount, communityClubID, communityStreamID, communityEpoch, communityPosition, mobile)
	if ( connected or friendsList ) then
		if ( connected ) then
			FriendsDropDown.initialize = FriendsFrameBNDropDown_Initialize;
		else
			FriendsDropDown.initialize = FriendsFrameBNOfflineDropDown_Initialize;
		end
		FriendsDropDown.displayMode = "MENU";
		FriendsDropDown.friendsDropDownName = name;
		FriendsDropDown.friendsList = friendsList;
		FriendsDropDown.lineID = lineID;
		FriendsDropDown.communityClubID = communityClubID;
		FriendsDropDown.communityStreamID = communityStreamID;
		FriendsDropDown.communityEpoch = communityEpoch;
		FriendsDropDown.communityPosition = communityPosition;
		FriendsDropDown.chatType = chatType;
		FriendsDropDown.chatTarget = name;
		FriendsDropDown.chatFrame = chatFrame;
		FriendsDropDown.bnetIDAccount = bnetIDAccount;
		FriendsDropDown.isMobile = mobile;
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor");
	end
end

function FriendsFrameDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "FRIEND", nil, FriendsDropDown.friendsDropDownName);
end

function FriendsFrameOfflineDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "FRIEND_OFFLINE", nil, FriendsDropDown.friendsDropDownName);
end

function FriendsFrameBNDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "BN_FRIEND", nil, FriendsDropDown.friendsDropDownName);
end

function FriendsFrameBNOfflineDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "BN_FRIEND_OFFLINE", nil, FriendsDropDown.friendsDropDownName);
end

function FriendsFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, FRIEND_TAB_COUNT);
	self.selectedTab = FRIEND_TAB_FRIENDS;
	PanelTemplates_UpdateTabs(self);
	self:RegisterEvent("FRIENDLIST_UPDATE");
	self:RegisterEvent("IGNORELIST_UPDATE");
	self:RegisterEvent("WHO_LIST_UPDATE");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	self:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED");
	self:RegisterEvent("BN_FRIEND_INFO_CHANGED");
	self:RegisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED");
	self:RegisterEvent("BN_FRIEND_INVITE_ADDED");
	self:RegisterEvent("BN_FRIEND_INVITE_REMOVED");
	self:RegisterEvent("BN_CUSTOM_MESSAGE_CHANGED");
	self:RegisterEvent("BN_CUSTOM_MESSAGE_LOADED");
	self:RegisterEvent("BN_BLOCK_LIST_UPDATED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("BN_CONNECTED");
	self:RegisterEvent("BN_DISCONNECTED");
	self:RegisterEvent("BN_INFO_CHANGED");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("BATTLETAG_INVITE_SHOW");
	self:RegisterEvent("SOCIAL_QUEUE_UPDATE");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("GROUP_JOINED");
	self:RegisterEvent("GROUP_LEFT");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self.selectedFriend = 1;

	-- friends list
	local scrollFrame = FriendsListFrameScrollFrame;
	scrollFrame.update = FriendsFrame_UpdateFriends;
	scrollFrame.dynamic = FriendsList_GetScrollFrameTopButton;
	scrollFrame.dividerPool = CreateFramePool("FRAME", self, "FriendsFrameFriendDividerTemplate");
	scrollFrame.invitePool = CreateFramePool("FRAME", self, "FriendsFrameFriendInviteTemplate");
	-- can't do this in XML because we're inheriting from a template
	scrollFrame.PendingInvitesHeaderButton:SetParent(scrollFrame.ScrollChild);
	HybridScrollFrame_CreateButtons(scrollFrame, "FriendsListButtonTemplate");

	IgnoreListFrameScrollFrame.update = IgnoreList_Update;
	HybridScrollFrame_CreateButtons(IgnoreListFrameScrollFrame, "IgnoreListButtonTemplate");

	WhoListScrollFrame.Slider:SetPoint("BOTTOMLEFT", WhoListScrollFrame, "BOTTOMRIGHT", 0, -1);
	WhoListScrollFrame.update = WhoList_Update;
	HybridScrollFrame_CreateButtons(WhoListScrollFrame, "WhoListButtonTemplate");

	if not BNFeaturesEnabled() then
		FriendsFrameBattlenetFrame:Hide();
	end

	FriendsFrame_UpdateQuickJoinTab(0);
end

local function IsIntroRAFHelpTipShowing()
	return HelpTip:IsShowing(QuickJoinToastButton, RAF_INTRO_TUTORIAL_TEXT);
end

local function IsRAFHelpTipShowing()
	return HelpTip:IsShowing(QuickJoinToastButton, RAF_INTRO_TUTORIAL_TEXT) or HelpTip:IsShowing(QuickJoinToastButton, RAF_REWARD_TUTORIAL_TEXT);
end

function FriendsFrame_OnShow()
	FriendsList_Update(true);
	UpdateMicroButtons();
	FriendsFrame_CheckQuickJoinHelpTip();
	FriendsFrame_UpdateQuickJoinTab(#C_SocialQueue.GetAllGroups());
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	C_GuildInfo.GuildRoster();

	if IsRAFHelpTipShowing() then
		PanelTemplates_SetTab(FriendsTabHeader, 3);
		if IsIntroRAFHelpTipShowing() then
			RecruitAFriendFrame:ShowSplashScreen();
			FriendsTabHeader.Tab3.New:Show();
			HelpTip:Acknowledge(QuickJoinToastButton, RAF_INTRO_TUTORIAL_TEXT);
		else
			HelpTip:Acknowledge(QuickJoinToastButton, RAF_REWARD_TUTORIAL_TEXT);
		end
	end

	FriendsFrame_Update();
end

function FriendsFrame_Update()
	local selectedTab = PanelTemplates_GetSelectedTab(FriendsFrame) or FRIEND_TAB_FRIENDS;

	FriendsTabHeader:SetShown(selectedTab == FRIEND_TAB_FRIENDS);

	if selectedTab == FRIEND_TAB_FRIENDS then
		local selectedHeaderTab = PanelTemplates_GetSelectedTab(FriendsTabHeader) or FRIEND_HEADER_TAB_FRIENDS;

		ButtonFrameTemplate_ShowButtonBar(FriendsFrame);
		FriendsFrameInset:SetPoint("TOPLEFT", 4, -83);
		FriendsFrameIcon:SetTexture("Interface\\FriendsFrame\\Battlenet-Portrait");

		for i, Tab in ipairs(FriendsTabHeader.Tabs) do
			if i ~= selectedHeaderTab then
				Tab.New:Hide();
			end
		end

		if selectedHeaderTab == FRIEND_HEADER_TAB_FRIENDS then
			C_FriendList.ShowFriends();
			FriendsFrameTitleText:SetText(FRIENDS_LIST);
			FriendsFrame_ShowSubFrame("FriendsListFrame");
		elseif selectedHeaderTab == FRIEND_HEADER_TAB_IGNORE then
			FriendsFrameTitleText:SetText(IGNORE_LIST);
			FriendsFrame_ShowSubFrame("IgnoreListFrame");
			IgnoreList_Update();
		elseif selectedHeaderTab == FRIEND_HEADER_TAB_RAF then
			FriendsFrameTitleText:SetText(RECRUIT_A_FRIEND);
			FriendsFrame_ShowSubFrame("RecruitAFriendFrame");
		end
	elseif ( selectedTab == FRIEND_TAB_WHO ) then
		ButtonFrameTemplate_ShowButtonBar(FriendsFrame);
		FriendsFrameInset:SetPoint("TOPLEFT", 4, -83);
		FriendsFrameIcon:SetTexture("Interface\\FriendsFrame\\Battlenet-Portrait");
		FriendsFrameTitleText:SetText(WHO_LIST);
		FriendsFrame_ShowSubFrame("WhoFrame");
		WhoList_Update();
	elseif ( selectedTab == FRIEND_TAB_RAID ) then
		ButtonFrameTemplate_ShowButtonBar(FriendsFrame);
		FriendsFrameInset:SetPoint("TOPLEFT", 4, -60);
		FriendsFrameIcon:SetTexture("Interface\\LFGFrame\\UI-LFR-PORTRAIT");
		FriendsFrameTitleText:SetText(RAID);
		ClaimRaidFrame(FriendsFrame);
		FriendsFrame_ShowSubFrame("RaidFrame");
	elseif ( selectedTab == FRIEND_TAB_QUICK_JOIN ) then
		FriendsFrameInset:SetPoint("TOPLEFT", 4, -83);
		FriendsFrameIcon:SetTexture("Interface\\FriendsFrame\\Battlenet-Portrait");
		FriendsFrameTitleText:SetText(QUICK_JOIN);
		FriendsFrame_ShowSubFrame("QuickJoinFrame");
	end
end

function FriendsFrame_UpdateQuickJoinTab(numGroups)
	FriendsFrameTab4:SetText(QUICK_JOIN.." "..string.format(NUMBER_IN_PARENTHESES, numGroups));
	PanelTemplates_TabResize(FriendsFrameTab4, 0);
end

function FriendsFrame_OnHide()
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	RaidInfoFrame:Hide();
	for index, value in pairs(FRIENDSFRAME_SUBFRAMES) do
		if ( value == "RaidFrame" ) then
			if ( RaidFrame:GetParent() == FriendsFrame ) then
				RaidFrame:Hide();
			end
		else
			_G[value]:Hide();
		end
	end
	FriendsFriendsFrame:Hide();
	RecruitAFriendFrame:UpdateRAFTutorialTips();
	FriendsTabHeader.Tab3.New:Hide();
end

FriendsTabHeaderMixin = {};

function FriendsTabHeaderMixin:OnLoad()
	self:SetRAFSystemEnabled(C_RecruitAFriend.IsEnabled());
	PanelTemplates_SetTab(self, 1);
	self:RegisterEvent("RAF_SYSTEM_ENABLED_STATUS");
end

function FriendsTabHeaderMixin:OnEvent(event, ...)
	if event == "RAF_SYSTEM_ENABLED_STATUS" then
		local rafEnabled = ...;
		self:SetRAFSystemEnabled(rafEnabled);
	end
end

function FriendsTabHeaderMixin:SetRAFSystemEnabled(rafEnabled)
	FRIEND_HEADER_TAB_COUNT = rafEnabled and 3 or 2;

	local selectedHeaderTab = PanelTemplates_GetSelectedTab(FriendsTabHeader);
	if not rafEnabled and selectedHeaderTab == FRIEND_HEADER_TAB_RAF then
		PanelTemplates_SetTab(self, 1);
		FriendsFrame_Update();
	end

	self.Tab3:SetShown(rafEnabled);
	PanelTemplates_SetNumTabs(self, FRIEND_HEADER_TAB_COUNT);
end

-- Used for the sub-tabs within Friends
FriendsTabMixin = {};

function FriendsTabMixin:OnLoad()
	PanelTemplates_TabResize(self, 0);
	self.HighlightTexture:SetWidth(self:GetTextWidth() + 31);
end

function FriendsTabMixin:OnClick()
	PanelTemplates_Tab_OnClick(self, FriendsTabHeader);
	FriendsFrame_Update();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

-- Used for the tabs at the bottom
FriendsFrameTabMixin = {};

function FriendsFrameTabMixin:OnClick()
	PanelTemplates_Tab_OnClick(self, FriendsFrame);
	FriendsFrame_OnShow();
end

function FriendsListFrame_OnShow(self)
end

function FriendsListFrame_OnHide(self)
	FriendsList_ClosePendingInviteDialogs();
end

function FriendsListFrame_ToggleInvites()
	local collapsed = GetCVarBool("friendInvitesCollapsed");
	SetCVar("friendInvitesCollapsed", not collapsed);
	FriendsListFrameScrollFrame.PendingInvitesHeaderButton.Flash.Anim:Stop();
	FriendsList_Update();
end

function FriendsList_InitializePendingInviteDropDown(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;

	if level == 1 then
		info.text = DECLINE;
		info.func = function()
						FriendsList_ClosePendingInviteDialogs();
						BNDeclineFriendInvite(self.inviteID);
					end
		UIDropDownMenu_AddButton(info, level)

		info.text = REPORT_PLAYER;
		info.hasArrow = true;
		info.func = nil;
		UIDropDownMenu_AddButton(info, level)

		info.text = BLOCK_INVITES;
		info.hasArrow = false;
		info.func = function()
						local inviteID, accountName = BNGetFriendInviteInfo(self.inviteIndex);
						local dialog = StaticPopup_Show("CONFIRM_BLOCK_INVITES", accountName);
						if ( dialog ) then
							dialog.data = inviteID;
						end
					end
		UIDropDownMenu_AddButton(info, level)
	else
		if level == 2 then
			local bnetIDAccount, name = BNGetFriendInviteInfo(self.inviteIndex);
			local playerLocation = PlayerLocation:CreateFromBattleNetID(bnetIDAccount);
			info.text = REPORT_SPAMMING;
			info.func = function()
							UIDROPDOWNMENU_MENU_VALUE = self.inviteIndex;
							C_ReportSystem.OpenReportPlayerDialog(PLAYER_REPORT_TYPE_SPAM, name, playerLocation);
						end
			UIDropDownMenu_AddButton(info, level)

			info.text = REPORT_ABUSE;
			info.func = function()
							UIDROPDOWNMENU_MENU_VALUE = self.inviteIndex;
							C_ReportSystem.OpenReportPlayerDialog(PLAYER_REPORT_TYPE_ABUSE, name, playerLocation);
						end
			UIDropDownMenu_AddButton(info, level)

			info.text = REPORT_BAD_NAME;
			info.func = function()
							UIDROPDOWNMENU_MENU_VALUE = self.inviteIndex;
							C_ReportSystem.OpenReportPlayerDialog(PLAYER_REPORT_TYPE_BAD_PLAYER_NAME, name, playerLocation);
						end
			UIDropDownMenu_AddButton(info, level)
			info.notCheckable = false;
		end
	end
end

function FriendsList_ClosePendingInviteDialogs()
	CloseDropDownMenus();
	StaticPopup_Hide("CONFIRM_BLOCK_INVITES");
	StaticPopupSpecial_Hide(PlayerReportFrame);
end

function FriendsList_GetScrollFrameTopButton(offset)
	local usedHeight = 0;
	for i = 1, #FriendListEntries do
		local buttonHeight = FRIENDS_BUTTON_HEIGHTS[FriendListEntries[i].buttonType];
		if ( usedHeight + buttonHeight >= offset ) then
			return i - 1, offset - usedHeight;
		else
			usedHeight = usedHeight + buttonHeight;
		end
	end
end

function FriendsList_CanWhisperFriend(friendType, friendIndex)
	if friendType == FRIENDS_BUTTON_TYPE_BNET then
		return true;
	elseif friendType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList.GetFriendInfoByIndex(friendIndex);
		return info.connected and not info.mobile;
	end

	return false;
end

function FriendsList_Update(forceUpdate)
	local numBNetTotal, numBNetOnline, numBNetFavorite, numBNetFavoriteOnline = BNGetNumFriends();
	local numBNetOffline = numBNetTotal - numBNetOnline;
	local numBNetFavoriteOffline = numBNetFavorite - numBNetFavoriteOnline;
	local numWoWTotal = C_FriendList.GetNumFriends();
	local numWoWOnline = C_FriendList.GetNumOnlineFriends();
	local numWoWOffline = numWoWTotal - numWoWOnline;

	QuickJoinToastButton:UpdateDisplayedFriendCount();
	if ( not FriendsListFrame:IsShown() and not forceUpdate) then
		return;
	end

	local addButtonIndex = 0;
	local totalButtonHeight = 0;

	local function AddButtonInfo(buttonType, id)
		addButtonIndex = addButtonIndex + 1;
		if ( not FriendListEntries[addButtonIndex] ) then
			FriendListEntries[addButtonIndex] = { };
		end
		FriendListEntries[addButtonIndex].buttonType = buttonType;
		FriendListEntries[addButtonIndex].id = id;
		totalButtonHeight = totalButtonHeight + FRIENDS_BUTTON_HEIGHTS[buttonType];
	end

	-- invites
	local numInvites = BNGetNumFriendInvites();
	if ( numInvites > 0 ) then
		AddButtonInfo(FRIENDS_BUTTON_TYPE_INVITE_HEADER, nil);
		if ( not GetCVarBool("friendInvitesCollapsed") ) then
			for i = 1, numInvites do
				AddButtonInfo(FRIENDS_BUTTON_TYPE_INVITE, i);
			end
			-- add divider before friends
			if ( numBNetTotal + numWoWTotal > 0 ) then
				AddButtonInfo(FRIENDS_BUTTON_TYPE_DIVIDER, nil);
			end
		end
	end

	local bnetFriendIndex = 0;
	-- favorite friends, online and offline
	for i = 1, numBNetFavorite do
		bnetFriendIndex = bnetFriendIndex + 1;
		AddButtonInfo(FRIENDS_BUTTON_TYPE_BNET, bnetFriendIndex);
	end
	if (numBNetFavorite > 0) then
		AddButtonInfo(FRIENDS_BUTTON_TYPE_DIVIDER, nil);
	end

	-- online Battlenet friends
	for i = 1, numBNetOnline - numBNetFavoriteOnline do
		bnetFriendIndex = bnetFriendIndex + 1;
		AddButtonInfo(FRIENDS_BUTTON_TYPE_BNET, bnetFriendIndex);
	end
	-- online WoW friends
	for i = 1, numWoWOnline do
		AddButtonInfo(FRIENDS_BUTTON_TYPE_WOW, i);
	end
	-- divider between online and offline friends
	if ( (numBNetOnline > 0 or numWoWOnline > 0) and (numBNetOffline > 0 or numWoWOffline > 0) ) then
		AddButtonInfo(FRIENDS_BUTTON_TYPE_DIVIDER, nil);
	end

	-- offline Battlenet friends
	for i = 1, numBNetOffline - numBNetFavoriteOffline do
		bnetFriendIndex = bnetFriendIndex + 1;
		AddButtonInfo(FRIENDS_BUTTON_TYPE_BNET, bnetFriendIndex);
	end
	-- offline WoW friends
	for i = 1, numWoWOffline do
		AddButtonInfo(FRIENDS_BUTTON_TYPE_WOW, i + numWoWOnline);
	end

	FriendsListFrameScrollFrame.totalFriendListEntriesHeight = totalButtonHeight;
	FriendsListFrameScrollFrame.numFriendListEntries = addButtonIndex;

	-- selection
	local selectedFriend = 0;
	-- check that we have at least 1 friend
	if ( numBNetTotal + numWoWTotal > 0 ) then
		-- get friend
		if ( FriendsFrame.selectedFriendType == FRIENDS_BUTTON_TYPE_WOW ) then
			selectedFriend = C_FriendList.GetSelectedFriend();
		elseif ( FriendsFrame.selectedFriendType == FRIENDS_BUTTON_TYPE_BNET ) then
			selectedFriend = BNGetSelectedFriend();
		end
		-- set to first in list if no friend
		if ( not selectedFriend or selectedFriend == 0 ) then
			FriendsFrame_SelectFriend(FriendListEntries[1].buttonType, 1);
			selectedFriend = 1;
		end
		-- check if friend is online
		FriendsFrameSendMessageButton:SetEnabled(FriendsList_CanWhisperFriend(FriendsFrame.selectedFriendType, selectedFriend));
	else
		FriendsFrameSendMessageButton:Disable();
	end
	FriendsFrame.selectedFriend = selectedFriend;
	FriendsFrame_UpdateFriends();

	-- RID warning, upon getting the first RID invite
	local showRIDWarning = false;
	local numInvites = BNGetNumFriendInvites();
	if ( numInvites > 0 and not GetCVarBool("pendingInviteInfoShown") ) then
		local _, _, _, _, _, _, isRIDEnabled = BNGetInfo();
		if ( isRIDEnabled ) then
			for i = 1, numInvites do
				local inviteID, accountName, isBattleTag = BNGetFriendInviteInfo(i);
				if ( not isBattleTag ) then
					-- found one
					showRIDWarning = true;
					break;
				end
			end
		end
	end
	if ( showRIDWarning ) then
		FriendsListFrame.RIDWarning:Show();
		FriendsListFrameScrollFrame.scrollBar:Disable();
		FriendsListFrameScrollFrame.scrollUp:Disable();
		FriendsListFrameScrollFrame.scrollDown:Disable();
	else
		FriendsListFrame.RIDWarning:Hide();
	end
end

function IgnoreList_Update()
	local scrollFrame = IgnoreListFrameScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numIgnores = C_FriendList.GetNumIgnores();
	local numBlocks = BNGetNumBlocked();
	local usedHeight = 0;

	-- Headers
	local ignoredHeader = 0;
	if numIgnores > 0 then
		numIgnores = numIgnores + 1;
		ignoredHeader = 1;
	end

	local blockedHeader = 0;
	if numBlocks > 0 then
		numBlocks = numBlocks + 1;
		blockedHeader = numIgnores + 1;
	end

	FriendsFrameIgnoredHeader:Hide();
	FriendsFrameBlockedInviteHeader:Hide();

	-- selection stuff
	local selectedSquelchType = FriendsFrame.selectedSquelchType;
	local selectedSquelchIndex = 0 ;
	if selectedSquelchType == SQUELCH_TYPE_IGNORE then
		selectedSquelchIndex = C_FriendList.GetSelectedIgnore() or 0;
	elseif selectedSquelchType == SQUELCH_TYPE_BLOCK_INVITE then
		selectedSquelchIndex = BNGetSelectedBlock();
	end
	if ( selectedSquelchIndex == 0 ) then
		if ( numIgnores > 0 ) then
			FriendsFrame_SelectSquelched(SQUELCH_TYPE_IGNORE, 1);
			selectedSquelchType = SQUELCH_TYPE_IGNORE;
			selectedSquelchIndex = 1;
		elseif ( numBlocks > 0 ) then
			FriendsFrame_SelectSquelched(SQUELCH_TYPE_BLOCK_INVITE, 1);
			selectedSquelchType = SQUELCH_TYPE_BLOCK_INVITE;
			selectedSquelchIndex = 1;
		end
	end
	if ( selectedSquelchIndex > 0 ) then
		FriendsFrameUnsquelchButton:Enable();
	else
		FriendsFrameUnsquelchButton:Disable();
	end

	local totalNumEntries = numIgnores + numBlocks;

	for i = 1, numButtons do
		local button = buttons[i];
		button.type = nil;
		local index = offset + i;
		if index <= totalNumEntries then
			if index == ignoredHeader then
				IgnoreList_SetHeader(FriendsFrameIgnoredHeader, button);
			elseif index <= numIgnores then
				button.index = index - ignoredHeader;
				local name = C_FriendList.GetIgnoreName(button.index);
				if not name then
					button.name:SetText(UNKNOWN);
				else
					button.name:SetText(name);
					button.type = SQUELCH_TYPE_IGNORE;
				end
			elseif index == blockedHeader then
				IgnoreList_SetHeader(FriendsFrameBlockedInviteHeader, button);
			else
				button.index = index - blockedHeader;

				local blockID, blockName = BNGetBlockedInfo(button.index);
				button.name:SetText(blockName);
				button.type = SQUELCH_TYPE_BLOCK_INVITE;
			end

			button:Show();
			usedHeight = usedHeight + FRIENDS_FRAME_IGNORE_HEIGHT;
		else
			button.index = nil;
			button:Hide();
		end

		if (selectedSquelchType == button.type) and (selectedSquelchIndex == button.index) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
	end

	local totalHeight = totalNumEntries * FRIENDS_FRAME_IGNORE_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, usedHeight);
end

function IgnoreList_SetHeader(header, parent)
	parent.name:SetText("");
	header:SetParent(parent);
	header:SetPoint("TOPLEFT", parent, 0, 0);
	header:Show();
end

function WhoList_Update()
	local scrollFrame = WhoListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numWhos, totalCount = C_FriendList.GetNumWhoResults();
	local usedHeight = 0;

	local displayedText = "";
	if ( totalCount > MAX_WHOS_FROM_SERVER ) then
		displayedText = format(WHO_FRAME_SHOWN_TEMPLATE, MAX_WHOS_FROM_SERVER);
	end
	WhoFrameTotals:SetText(format(WHO_FRAME_TOTAL_TEMPLATE, totalCount).."  "..displayedText);

	for i = 1, numButtons do
		local button = buttons[i];
		button.tooltip1 = nil;
		button.tooltip2 = nil;

		local index = offset + i;
		if index <= numWhos then
			local info = C_FriendList.GetWhoInfo(index);

			local classTextColor;
			if info.filename then
				classTextColor = RAID_CLASS_COLORS[info.filename];
			else
				classTextColor = HIGHLIGHT_FONT_COLOR;
			end

			button.Name:SetText(info.fullName);
			button.Level:SetText(info.level);
			button.Class:SetText(info.classStr);
			button.Class:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);

			local variableColumnTable = { info.area, info.fullGuildName, info.raceStr };
			local variableText = variableColumnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)];
			button.Variable:SetText(variableText);

			if button.Variable:IsTruncated() or button.Name:IsTruncated() then
				button.tooltip1 = info.fullName;
				button.tooltip2 = variableText;
			end

			button.index = index;

			button:Show();
			usedHeight = usedHeight + FRIENDS_FRAME_WHO_HEIGHT;
		else
			button.index = nil;
			button:Hide();
		end

		if WhoFrame.selectedWho == index then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
	end

	local totalHeight = numWhos * FRIENDS_FRAME_WHO_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, usedHeight);

	if not WhoFrame.selectedWho then
		WhoFrameGroupInviteButton:Disable();
		WhoFrameAddFriendButton:Disable();
	else
		WhoFrameGroupInviteButton:Enable();
		WhoFrameAddFriendButton:Enable();

		local selectedWhoInfo = C_FriendList.GetWhoInfo(WhoFrame.selectedWho);
		if selectedWhoInfo then
			WhoFrame.selectedName = selectedWhoInfo.fullName;
		else
			WhoFrame.selectedName = "";
		end
	end

	PanelTemplates_SetTab(FriendsFrame, 2);
	ShowUIPanel(FriendsFrame);
end

function WhoFrameColumn_SetWidth(frame, width)
	frame:SetWidth(width);
	_G[frame:GetName().."Middle"]:SetWidth(width - 9);
end

function WhoFrameDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	for i=1, getn(WHOFRAME_DROPDOWN_LIST), 1 do
		info.text = WHOFRAME_DROPDOWN_LIST[i].name;
		info.func = WhoFrameDropDownButton_OnClick;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function WhoFrameDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WhoFrameDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 80);
	UIDropDownMenu_SetButtonWidth(self, 24);
	UIDropDownMenu_JustifyText(WhoFrameDropDown, "LEFT")
end

function WhoFrameDropDownButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(WhoFrameDropDown, self:GetID());
	WhoList_Update();
end

function FriendsFrame_OnEvent(self, event, ...)
	if ( event == "SPELL_UPDATE_COOLDOWN" ) then
		if ( self:IsShown() ) then
			local buttons = FriendsListFrameScrollFrame.buttons;
			for _, button in pairs(buttons) do
				if ( button.summonButton:IsShown() ) then
					FriendsFrame_SummonButton_Update(button.summonButton);
				end
			end
		end
	elseif ( event == "FRIENDLIST_UPDATE" or event == "GROUP_ROSTER_UPDATE" ) then
		FriendsList_Update();
	elseif ( event == "BN_FRIEND_LIST_SIZE_CHANGED" or event == "BN_FRIEND_INFO_CHANGED" ) then
		FriendsList_Update();
		-- update Friends of Friends
		local bnetIDAccount = ...;
		if ( event == "BN_FRIEND_LIST_SIZE_CHANGED" and bnetIDAccount ) then
			FriendsFriendsFrame.requested[bnetIDAccount] = nil;
			if ( FriendsFriendsFrame:IsShown() ) then
				FriendsFriendsFrame:Update();
			end
		end
	elseif ( event == "BN_CUSTOM_MESSAGE_CHANGED" ) then
		local arg1 = ...;
		if ( arg1 ) then	--There is no bnetIDAccount given if this is ourself.
			FriendsList_Update();
		else
			FriendsFrameBattlenetFrame.BroadcastFrame:UpdateBroadcast();
		end
	elseif ( event == "BN_CUSTOM_MESSAGE_LOADED" ) then
			FriendsFrameBattlenetFrame.BroadcastFrame:UpdateBroadcast();
	elseif ( event == "BN_FRIEND_INVITE_ADDED" ) then
		-- flash the invites header if collapsed
		local collapsed = GetCVarBool("friendInvitesCollapsed");
		if ( collapsed ) then
			FriendsListFrameScrollFrame.PendingInvitesHeaderButton.Flash.Anim:Play();
		end
		FriendsList_Update();
	elseif ( event == "BN_FRIEND_INVITE_LIST_INITIALIZED" ) then
		FriendsList_Update();
	elseif ( event == "BN_FRIEND_INVITE_REMOVED" ) then
		FriendsList_Update();
	elseif ( event == "IGNORELIST_UPDATE" or event == "BN_BLOCK_LIST_UPDATED" ) then
		IgnoreList_Update();
	elseif ( event == "WHO_LIST_UPDATE" ) then
		WhoList_Update();
		FriendsFrame_Update();
	elseif ( event == "PLAYER_FLAGS_CHANGED" or event == "BN_INFO_CHANGED") then
		FriendsFrameStatusDropDown_Update();
		FriendsFrame_CheckBattlenetStatus();
	elseif ( event == "PLAYER_ENTERING_WORLD" or event == "BN_CONNECTED" or event == "BN_DISCONNECTED") then
		FriendsFrame_CheckBattlenetStatus();
		-- We want to remove any friends from the frame so they don't linger when it's first re-opened.
		if (event == "BN_DISCONNECTED") then
			FriendsList_Update(true);
		end
	elseif ( event == "BATTLETAG_INVITE_SHOW" ) then
		BattleTagInviteFrame_Show(...);
	elseif ( event == "SOCIAL_QUEUE_UPDATE" or event == "GROUP_LEFT" or event == "GROUP_JOINED" ) then
		if ( self:IsVisible() ) then
			FriendsFrame_Update(); --TODO - Only update the buttons that need updating
			FriendsFrame_UpdateQuickJoinTab(#C_SocialQueue.GetAllGroups());
		end
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		if ( self:IsVisible() ) then
			local canRequestGuildRoster = ...;
			if ( canRequestGuildRoster ) then
				C_GuildInfo.GuildRoster();
			end
		end
	elseif ( event == "PLAYER_GUILD_UPDATE") then 
		C_GuildInfo.GuildRoster();
	end
end

function FriendsFrame_SelectFriend(friendType, id)
	if ( friendType == FRIENDS_BUTTON_TYPE_WOW ) then
		C_FriendList.SetSelectedFriend(id);
	elseif ( friendType == FRIENDS_BUTTON_TYPE_BNET ) then
		BNSetSelectedFriend(id);
	end
	FriendsFrame.selectedFriendType = friendType;
end

function FriendsFrame_SelectSquelched(ignoreType, index)
	if ( ignoreType == SQUELCH_TYPE_IGNORE ) then
		C_FriendList.SetSelectedIgnore(index);
	elseif ( ignoreType == SQUELCH_TYPE_BLOCK_INVITE ) then
		BNSetSelectedBlock(index);
	end
	FriendsFrame.selectedSquelchType = ignoreType;
end

function FriendsFrameAddFriendButton_OnClick(self)
	local name = GetUnitName("target", true);
	if ( UnitIsPlayer("target") and UnitCanCooperate("player", "target") and not C_FriendList.GetFriendInfo(name) ) then
		C_FriendList.AddFriend(name);
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	else
		local _, battleTag, _, _, _, _, isRIDEnabled = BNGetInfo();
		if ( ( battleTag or isRIDEnabled ) and BNFeaturesEnabledAndConnected() ) then
			AddFriendEntryFrame_Init(true);
			AddFriendFrame.editFocus = AddFriendNameEditBox;
			StaticPopupSpecial_Show(AddFriendFrame);
			if ( GetCVarBool("addFriendInfoShown") ) then
				AddFriendFrame_ShowEntry();
			else
				AddFriendFrame_ShowInfo();
			end
		else
			StaticPopup_Show("ADD_FRIEND");
		end
	end
end

function FriendsFrameSendMessageButton_OnClick(self)
	local name;
	if ( FriendsFrame.selectedFriendType == FRIENDS_BUTTON_TYPE_WOW ) then
		name = C_FriendList.GetFriendInfoByIndex(FriendsFrame.selectedFriend).name;
		ChatFrame_SendTell(name);
	elseif ( FriendsFrame.selectedFriendType == FRIENDS_BUTTON_TYPE_BNET ) then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(FriendsFrame.selectedFriend);
		if accountInfo then
			ChatFrame_SendBNetTell(accountInfo.accountName);
		end
	end
	if ( name ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function FriendsFrameMuteButton_OnClick(self)
	SetSelectedMute(self:GetID());
	MutedList_Update();
end

function FriendsFrameUnsquelchButton_OnClick(self)
	local selectedSquelchType = FriendsFrame.selectedSquelchType;
	if ( selectedSquelchType == SQUELCH_TYPE_IGNORE ) then
		C_FriendList.DelIgnoreByIndex(C_FriendList.GetSelectedIgnore());
	elseif ( selectedSquelchType == SQUELCH_TYPE_BLOCK_INVITE ) then
		local blockID = BNGetBlockedInfo(BNGetSelectedBlock());
		BNSetBlocked(blockID, false);
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function FriendsFrameIgnorePlayerButton_OnClick(self)
	if UnitCanCooperate("player", "target") and UnitIsPlayer("target") then
		local name, server = UnitName("target");
		local fullname = name;
		if server and UnitRealmRelationship("target") ~= LE_REALM_RELATION_SAME then
			fullname = name.."-"..server;
		end
		C_FriendList.AddIgnore(fullname);
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	else
		StaticPopup_Show("ADD_IGNORE");
	end
end

function FriendsFrame_UnIgnore(button, name)
	if ( not C_FriendList.DelIgnore(name) ) then
		UIErrorsFrame:AddExternalErrorMessage(ERR_IGNORE_NOT_FOUND);
	end
end

function FriendsFrame_UnBlock(button, blockID)
	BNSetBlocked(blockID, false);
end

function FriendsFrame_RemoveFriend()
	if ( FriendsFrame.selectedFriend ) then
		C_FriendList.RemoveFriendByIndex(FriendsFrame.selectedFriend);
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end
end

function FriendsFrame_SendMessage()
	local name = C_FriendList.GetFriendInfoByIndex(FriendsFrame.selectedFriend).name;
	ChatFrame_SendTell(name);
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function FriendsFrame_GroupInvite()
	local name = C_FriendList.GetFriendInfoByIndex(FriendsFrame.selectedFriend).name;
	C_PartyInfo.InviteUnit(name);
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function ToggleFriendsFrame(tab)
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( not tab ) then
		if ( FriendsFrame:IsShown() ) then
			HideUIPanel(FriendsFrame);
		else
			ShowUIPanel(FriendsFrame);
		end
	else
		if ( tab == PanelTemplates_GetSelectedTab(FriendsFrame) and FriendsFrame:IsShown() ) then
			HideUIPanel(FriendsFrame);
			return;
		end
		PanelTemplates_SetTab(FriendsFrame, tab);
		if ( FriendsFrame:IsShown() ) then
			FriendsFrame_OnShow();
		else
			ShowUIPanel(FriendsFrame);
		end
	end
end

function FriendsFrame_CheckQuickJoinHelpTip()
	-- We want at least two groups to show the tutorial.  This avoids more cases where all groups delist.
	local hasEnoughGroups = #C_SocialQueue.GetAllGroups(false) > 1;
	local hasClosedTutorial = GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FRIENDS_LIST_QUICK_JOIN);
	if ( not hasClosedTutorial and hasEnoughGroups ) then
		local helpTipInfo = {
			text = SOCIAL_QUICK_JOIN_TAB_HELP_TIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_FRIENDS_LIST_QUICK_JOIN,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			offsetX = -13,
		};
		HelpTip:Show(FriendsFrame, helpTipInfo, FriendsFrameTab4);
	end
end

function FriendsFrame_CloseQuickJoinHelpTip()
	-- Don't mark it as closed until you've actually seen it.
	if ( HelpTip:IsShowing(FriendsFrame, SOCIAL_QUICK_JOIN_TAB_HELP_TIP) or #C_SocialQueue.GetAllGroups(false) > 1 ) then
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FRIENDS_LIST_QUICK_JOIN, true);
	end
	HelpTip:Hide(FriendsFrame, SOCIAL_QUICK_JOIN_TAB_HELP_TIP);
end

function OpenFriendsFrame(tab)
	if ( not tab ) then
		ShowUIPanel(FriendsFrame);
	else
		PanelTemplates_SetTab(FriendsFrame, tab);
		if ( FriendsFrame:IsShown() ) then
			FriendsFrame_OnShow();
		else
			ShowUIPanel(FriendsFrame);
		end
	end
end

function WhoFrameEditBox_OnEnterPressed(self)
	C_FriendList.SendWho(self:GetText());
	self:ClearFocus();
end

function ShowWhoPanel()
	PanelTemplates_SetTab(FriendsFrame, 2);
	if ( FriendsFrame:IsShown() ) then
		FriendsFrame_OnShow();
	else
		ShowUIPanel(FriendsFrame);
	end
end

function ToggleFriendsSubPanel(panelIndex)
	if (Kiosk.IsEnabled()) then
		return;
	end

	local panelShown =
		FriendsFrame:IsShown() and
		PanelTemplates_GetSelectedTab(FriendsFrame) == FRIEND_TAB_FRIENDS and
		FriendsTabHeader.selectedTab == panelIndex;

	if ( panelShown ) then
		HideUIPanel(FriendsFrame);
	else
		PanelTemplates_SetTab(FriendsFrame, FRIEND_TAB_FRIENDS);
		PanelTemplates_SetTab(FriendsTabHeader, panelIndex);
		FriendsFrame_Update();
		ShowUIPanel(FriendsFrame);
	end
end

function ToggleFriendsPanel()
	ToggleFriendsSubPanel(FRIEND_HEADER_TAB_FRIENDS);
end

function ToggleIgnorePanel()
	ToggleFriendsSubPanel(FRIEND_HEADER_TAB_IGNORE);
end

function ToggleQuickJoinPanel()
	ToggleFriendsFrame(FRIEND_TAB_QUICK_JOIN);
end

function WhoFrame_GetDefaultWhoCommand()
	local level = UnitLevel("player");
	local minLevel = level-3;
	if ( minLevel <= 0 ) then
		minLevel = 1;
	end
	local maxLevel = min(level + 3, GetMaxPlayerLevel());
	local command = WHO_TAG_ZONE.."\""..GetAreaText().."\" "..minLevel.."-"..maxLevel;
	return command;
end

function FriendsFrame_GetLastOnline(timeDifference, isAbsolute)
	if ( not isAbsolute ) then
		timeDifference = time() - timeDifference;
	end
	local year, month, day, hour, minute;

	if ( timeDifference < SECONDS_PER_MIN ) then
		return LASTONLINE_SECS;
	elseif ( timeDifference >= SECONDS_PER_MIN and timeDifference < SECONDS_PER_HOUR ) then
		return format(LASTONLINE_MINUTES, floor(timeDifference / SECONDS_PER_MIN));
	elseif ( timeDifference >= SECONDS_PER_HOUR and timeDifference < SECONDS_PER_DAY ) then
		return format(LASTONLINE_HOURS, floor(timeDifference / SECONDS_PER_HOUR));
	elseif ( timeDifference >= SECONDS_PER_DAY and timeDifference < SECONDS_PER_MONTH ) then
		return format(LASTONLINE_DAYS, floor(timeDifference / SECONDS_PER_DAY));
	elseif ( timeDifference >= SECONDS_PER_MONTH and timeDifference < SECONDS_PER_YEAR ) then
		return format(LASTONLINE_MONTHS, floor(timeDifference / SECONDS_PER_MONTH));
	else
		return format(LASTONLINE_YEARS, floor(timeDifference / SECONDS_PER_YEAR));
	end
end

-- Battle.net stuff starts here

function FriendsFrame_CheckBattlenetStatus()
	if ( BNFeaturesEnabled() ) then
		local frame = FriendsFrameBattlenetFrame;
		if ( BNConnected() ) then
			FriendsFrameBattlenetFrame.BroadcastFrame:UpdateBroadcast();
			local _, battleTag = BNGetInfo();
			if ( battleTag ) then
				local symbol = string.find(battleTag, "#");
				if ( symbol ) then
					local suffix = string.sub(battleTag, symbol);
					battleTag = string.sub(battleTag, 1, symbol - 1).."|cff416380"..suffix.."|r";
				end
				frame.Tag:SetText(battleTag);
				frame.Tag:Show();
				frame:Show();
			else
				frame:Hide();
			end
			frame.UnavailableLabel:Hide();
			frame.BroadcastButton:Show();
			frame.UnavailableInfoButton:Hide();
			frame.UnavailableInfoFrame:Hide();
		else
			frame:Show();
			FriendsFrameBattlenetFrame_HideSubFrames();
			frame.Tag:Hide();
			frame.UnavailableLabel:Show();
			frame.BroadcastButton:Hide();
			frame.UnavailableInfoButton:Show();
		end
		if ( FriendsFrame:IsShown() ) then
			IgnoreList_Update();
		end
		-- has its own check if it is being shown, after it updates the count on the QuickJoinToastButton
		FriendsList_Update();
	end
end

function FriendsFrame_UpdateFriends()
	local scrollFrame = FriendsListFrameScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numFriendButtons = scrollFrame.numFriendListEntries;

	local usedHeight = 0;

	scrollFrame.dividerPool:ReleaseAll();
	scrollFrame.invitePool:ReleaseAll();
	scrollFrame.PendingInvitesHeaderButton:Hide();
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i;
		if ( index <= numFriendButtons ) then
			button.index = index;
			local height = FriendsFrame_UpdateFriendButton(button);
			button:SetHeight(height);
			usedHeight = usedHeight + height;
		else
			button.index = nil;
			button:Hide();
		end
	end
	HybridScrollFrame_Update(scrollFrame, scrollFrame.totalFriendListEntriesHeight, usedHeight);
end

function FriendsFrame_GetBNetAccountNameAndStatus(accountInfo, noCharacterName)
	if not accountInfo then
		return;
	end

	local nameText, nameColor, statusTexture;

	nameText = BNet_GetBNetAccountName(accountInfo);

	if not noCharacterName then
		local characterName = BNet_GetValidatedCharacterName(accountInfo.gameAccountInfo.characterName, nil, accountInfo.gameAccountInfo.clientProgram);
		if characterName ~= "" then
			if accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW and CanCooperateWithGameAccount(accountInfo) then
				nameText = nameText.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..characterName..")"..FONT_COLOR_CODE_CLOSE;
			else
				if ENABLE_COLORBLIND_MODE == "1" then
					characterName = accountInfo.gameAccountInfo.characterName..CANNOT_COOPERATE_LABEL;
				end
				nameText = nameText.." "..FRIENDS_OTHER_NAME_COLOR_CODE.."("..characterName..")"..FONT_COLOR_CODE_CLOSE;
			end
		end
	end

	if accountInfo.gameAccountInfo.isOnline then
		if accountInfo.isAFK or accountInfo.gameAccountInfo.isGameAFK then
			statusTexture = FRIENDS_TEXTURE_AFK;
		elseif accountInfo.isDND or accountInfo.gameAccountInfo.isGameBusy then
			statusTexture = FRIENDS_TEXTURE_DND;
		else
			statusTexture = FRIENDS_TEXTURE_ONLINE;
		end
		nameColor = FRIENDS_BNET_NAME_COLOR;
	else
		statusTexture = FRIENDS_TEXTURE_OFFLINE;
		nameColor = FRIENDS_GRAY_COLOR;
	end

	return nameText, nameColor, statusTexture;
end

function FriendsFrame_GetLastOnlineText(accountInfo)
	if not accountInfo or (accountInfo.lastOnlineTime == 0) or HasTimePassed(accountInfo.lastOnlineTime, SECONDS_PER_YEAR) then
		return FRIENDS_LIST_OFFLINE;
	else
		return string.format(BNET_LAST_ONLINE_TIME, FriendsFrame_GetLastOnline(accountInfo.lastOnlineTime));
	end
end

local function ShowRichPresenceOnly(client, wowProjectID, faction, realmID)
	if (client ~= BNET_CLIENT_WOW) or (wowProjectID ~= WOW_PROJECT_ID) then
		-- If they are not in wow or in a different version of wow, always show rich presence only
		return true;
	elseif (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) and ((faction ~= playerFactionGroup) or (realmID ~= playerRealmID)) then
		-- If we are both in wow classic and our factions or realms don't match, show rich presence only
		return true;
	else
		-- Otherwise show more detailed info about them
		return false;
	end;
end

local function GetOnlineInfoText(client, isMobile, rafLinkType, locationText)
	if not locationText then
		return UNKNOWN;
	end
	if isMobile then
		return LOCATION_MOBILE_APP;
	end
	if (client == BNET_CLIENT_WOW) and (rafLinkType ~= Enum.RafLinkType.None) and not isMobile then
		if rafLinkType == Enum.RafLinkType.Recruit then
			return RAF_RECRUIT_FRIEND:format(locationText);
		else
			return RAF_RECRUITER_FRIEND:format(locationText);
		end
	end

	return locationText;
end

function FriendsFrame_UpdateFriendButton(button)
	local index = button.index;
	button.buttonType = FriendListEntries[index].buttonType;
	button.id = FriendListEntries[index].id;
	local height = FRIENDS_BUTTON_HEIGHTS[button.buttonType];
	local nameText, nameColor, infoText, isFavoriteFriend, statusTexture;
	local hasTravelPassButton = false;
	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList.GetFriendInfoByIndex(FriendListEntries[index].id);
		if ( info.connected ) then
			button.background:SetColorTexture(FRIENDS_WOW_BACKGROUND_COLOR.r, FRIENDS_WOW_BACKGROUND_COLOR.g, FRIENDS_WOW_BACKGROUND_COLOR.b, FRIENDS_WOW_BACKGROUND_COLOR.a);
			if ( info.afk ) then
				button.status:SetTexture(FRIENDS_TEXTURE_AFK);
			elseif ( info.dnd ) then
				button.status:SetTexture(FRIENDS_TEXTURE_DND);
			else
				button.status:SetTexture(FRIENDS_TEXTURE_ONLINE);
			end
			nameText = info.name..", "..format(FRIENDS_LEVEL_TEMPLATE, info.level, info.className);
			nameColor = FRIENDS_WOW_NAME_COLOR;
			infoText = GetOnlineInfoText(BNET_CLIENT_WOW, info.mobile, info.rafLinkType, info.area);
		else
			button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
			button.status:SetTexture(FRIENDS_TEXTURE_OFFLINE);
			nameText = info.name;
			nameColor = FRIENDS_GRAY_COLOR;
			infoText = FRIENDS_LIST_OFFLINE;
		end
		button.gameIcon:Hide();
		button.summonButton:ClearAllPoints();
		button.summonButton:SetPoint("TOPRIGHT", button, "TOPRIGHT", 1, -1);
		FriendsFrame_SummonButton_Update(button.summonButton);
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(FriendListEntries[index].id);
		if accountInfo then
			nameText, nameColor, statusTexture = FriendsFrame_GetBNetAccountNameAndStatus(accountInfo);
			isFavoriteFriend = accountInfo.isFavorite;

			button.status:SetTexture(statusTexture);

			if accountInfo.gameAccountInfo.isOnline then
				button.background:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a);

				if ShowRichPresenceOnly(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.wowProjectID, accountInfo.gameAccountInfo.factionName, accountInfo.gameAccountInfo.realmID) then
					infoText = GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.richPresence);
				else
					infoText = GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.areaName);
				end

				button.gameIcon:SetTexture(BNet_GetClientTexture(accountInfo.gameAccountInfo.clientProgram));

				local fadeIcon = (accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and (accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID);
				if fadeIcon then
					button.gameIcon:SetAlpha(0.6);
				else
					button.gameIcon:SetAlpha(1);
				end

				--Note - this logic should match the logic in FriendsFrame_ShouldShowSummonButton

				local shouldShowSummonButton = FriendsFrame_ShouldShowSummonButton(button.summonButton);
				button.gameIcon:SetShown(not shouldShowSummonButton);

				-- travel pass
				hasTravelPassButton = true;
				local restriction = FriendsFrame_GetInviteRestriction(button.id);
				if restriction == INVITE_RESTRICTION_NONE then
					button.travelPassButton:Enable();
				else
					button.travelPassButton:Disable();
				end
			else
				button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
				button.gameIcon:Hide();
				infoText = FriendsFrame_GetLastOnlineText(accountInfo);
			end
			button.summonButton:ClearAllPoints();
			button.summonButton:SetPoint("CENTER", button.gameIcon, "CENTER", 1, 0);
			FriendsFrame_SummonButton_Update(button.summonButton);
		end
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_DIVIDER then
		local scrollFrame = FriendsListFrameScrollFrame;
		local divider = scrollFrame.dividerPool:Acquire();
		divider:SetParent(scrollFrame.ScrollChild);
		divider:SetAllPoints(button);
		divider:Show();
		nameText = nil;
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_INVITE_HEADER then
		local header = FriendsListFrameScrollFrame.PendingInvitesHeaderButton;
		header:SetPoint("TOPLEFT", button, 1, 0);
		header:Show();
		header:SetFormattedText(FRIEND_REQUESTS, BNGetNumFriendInvites());
		local collapsed = GetCVarBool("friendInvitesCollapsed");
		if ( collapsed ) then
			header.DownArrow:Hide();
			header.RightArrow:Show();
		else
			header.DownArrow:Show();
			header.RightArrow:Hide();
		end
		nameText = nil;
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_INVITE then
		local scrollFrame = FriendsListFrameScrollFrame;
		local invite = scrollFrame.invitePool:Acquire();
		invite:SetParent(scrollFrame.ScrollChild);
		invite:SetAllPoints(button);
		invite:Show();
		local inviteID, accountName = BNGetFriendInviteInfo(button.id);
		invite.Name:SetText(accountName);
		invite.inviteID = inviteID;
		invite.inviteIndex = button.id;
		nameText = nil;
	end
	-- travel pass?
	if hasTravelPassButton then
		button.travelPassButton:Show();
	else
		button.travelPassButton:Hide();
	end
	-- selection
	if  (FriendsFrame.selectedFriendType == FriendListEntries[index].buttonType) and (FriendsFrame.selectedFriend == FriendListEntries[index].id) then
		button:LockHighlight();
	else
		button:UnlockHighlight();
	end
	-- finish setting up button if it's not a header
	if nameText then
		button.name:SetText(nameText);
		button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b);
		button.info:SetText(infoText);
		button:Show();

		if isFavoriteFriend then
			button.Favorite:Show();
			button.Favorite:ClearAllPoints()
			button.Favorite:SetPoint("TOPLEFT", button.name, "TOPLEFT", button.name:GetStringWidth(), 0);
		else
			button.Favorite:Hide();
		end
	else
		button:Hide();
	end
	-- update the tooltip if hovering over a button
	if (FriendsTooltip.button == button) or (GetMouseFocus() == button) then
		button:OnEnter();
	end
	return height;
end

function FriendsFrameStatusDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, FriendsFrameStatusDropDown_Initialize);
	UIDropDownMenu_SetWidth(FriendsFrameStatusDropDown, 28);
	FriendsFrameStatusDropDownText:Hide();
	FriendsFrameStatusDropDownButton:SetScript("OnEnter", FriendsFrameStatusDropDown_ShowTooltip);
	FriendsFrameStatusDropDownButton:SetScript("OnLeave", function() GameTooltip:Hide(); end);
end

function FriendsFrameStatusDropDown_ShowTooltip()
	local statusText;
	local status = FriendsFrameStatusDropDown.status;
	if ( status == FRIENDS_TEXTURE_ONLINE ) then
		statusText = FRIENDS_LIST_AVAILABLE;
	elseif ( status == FRIENDS_TEXTURE_AFK ) then
		statusText = FRIENDS_LIST_AWAY;
	elseif ( status == FRIENDS_TEXTURE_DND ) then
		statusText = FRIENDS_LIST_BUSY;
	end
	GameTooltip:SetOwner(FriendsFrameStatusDropDown, "ANCHOR_RIGHT", -18, 0);
	GameTooltip:SetText(format(FRIENDS_LIST_STATUS_TOOLTIP, statusText));
	GameTooltip:Show();
end

function FriendsFrameStatusDropDown_OnShow(self)
	UIDropDownMenu_Initialize(self, FriendsFrameStatusDropDown_Initialize);
	FriendsFrameStatusDropDown_Update();
end

function FriendsFrameStatusDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	local optionText = "\124T%s.tga:16:16:0:0\124t %s";
	info.padding = 8;
	info.checked = nil;
	info.notCheckable = 1;
	info.func = FriendsFrame_SetOnlineStatus;

	info.text = string.format(optionText, FRIENDS_TEXTURE_ONLINE, FRIENDS_LIST_AVAILABLE);
	info.value = FRIENDS_TEXTURE_ONLINE;
	UIDropDownMenu_AddButton(info);

	info.text = string.format(optionText, FRIENDS_TEXTURE_AFK, FRIENDS_LIST_AWAY);
	info.value = FRIENDS_TEXTURE_AFK;
	UIDropDownMenu_AddButton(info);

	info.text = string.format(optionText, FRIENDS_TEXTURE_DND, FRIENDS_LIST_BUSY);
	info.value = FRIENDS_TEXTURE_DND;
	UIDropDownMenu_AddButton(info);
end

function FriendsFrameStatusDropDown_Update()
	local status;
	local _, _, _, _, bnetAFK, bnetDND = BNGetInfo();
	if ( bnetAFK) then
		status = FRIENDS_TEXTURE_AFK;
	elseif (bnetDND ) then
		status = FRIENDS_TEXTURE_DND;
	else
		status = FRIENDS_TEXTURE_ONLINE;
	end
	FriendsFrameStatusDropDownStatus:SetTexture(status);
	FriendsFrameStatusDropDown.status = status;
end

function FriendsFrame_SetOnlineStatus(button)
	local status = button.value;
	if ( status == FriendsFrameStatusDropDown.status ) then
		return;
	end
	local _, _, _, _, bnetAFK, bnetDND = BNGetInfo();
	if ( status == FRIENDS_TEXTURE_ONLINE ) then
			BNSetAFK(false);
			BNSetDND(false);
	elseif ( status == FRIENDS_TEXTURE_AFK ) then
			BNSetAFK(true);
	elseif ( status == FRIENDS_TEXTURE_DND ) then
			BNSetDND(true);
	end
end

FriendsBroadcastFrameMixin = {};

function FriendsBroadcastFrameMixin:OnLoad()
	self.BroadcastButton = self:GetParent().BroadcastButton;
	self:UpdateBroadcast();
end

function FriendsBroadcastFrameMixin:ShowFrame()
	self:Show();
	self.EditBox:SetFocus();
	self.BroadcastButton:SetNormalTexture("Interface\\FriendsFrame\\broadcast-hover");
	self.BroadcastButton:SetPushedTexture("Interface\\FriendsFrame\\broadcast-pressed-hover");
end

function FriendsBroadcastFrameMixin:HideFrame()
	self:Hide();
	self.BroadcastButton:SetNormalTexture("Interface\\FriendsFrame\\broadcast-normal");
	self.BroadcastButton:SetPushedTexture("Interface\\FriendsFrame\\broadcast-press");
end

function FriendsBroadcastFrameMixin:ToggleFrame()
	PlaySound(SOUNDKIT.IG_CHAT_EMOTE_BUTTON);
	if self:IsShown() then
		self:HideFrame();
	else
		self:ShowFrame();
	end
end

function FriendsBroadcastFrameMixin:UpdateBroadcast()
	local _, _, _, broadcastText = BNGetInfo();
	broadcastText = broadcastText or "";
	self.EditBox:SetText(broadcastText);
end

function FriendsBroadcastFrameMixin:SetBroadcast()
	local newBroadcastText = self.EditBox:GetText();
	local _, _, _, broadcastText = BNGetInfo();
	if newBroadcastText ~= broadcastText then
		BNSetCustomMessage(newBroadcastText);
	end
	self:HideFrame();
end

function FriendsFrameBattlenetFrame_HideSubFrames()
	FriendsFrameBattlenetFrame.BroadcastFrame:HideFrame();
	FriendsFrameBattlenetFrame.UnavailableInfoFrame:Hide();
end

function FriendsFrameTooltip_SetLine(line, anchor, text, yOffset)
	local tooltip = FriendsTooltip;
	local top = 0;
	local left = FRIENDS_TOOLTIP_MAX_WIDTH - FRIENDS_TOOLTIP_MARGIN_WIDTH - line:GetWidth();

	if ( text ) then
		line:SetText(text);
	end
	if ( anchor ) then
		top = yOffset or 0;
		line:SetPoint("TOP", anchor, "BOTTOM", 0, top);
	else
		local point, _, _, _, y = line:GetPoint(1);
		if ( point == "TOP" or point == "TOPLEFT" ) then
			top = y;
		end
	end
	line:Show();
	tooltip.height = tooltip.height + line:GetHeight() - top;
	tooltip.maxWidth = max(tooltip.maxWidth, line:GetStringWidth() + left);
	return line;
end

function AddFriendFrame_OnShow()
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup and factionGroup ~= "Neutral" ) then
		local textureFile = "Interface\\FriendsFrame\\PlusManz-"..factionGroup;
		AddFriendInfoFrameFactionIcon:SetTexture(textureFile);
		AddFriendInfoFrameFactionIcon:Show();
		AddFriendEntryFrameRightIcon:SetTexture(textureFile);
		AddFriendEntryFrameRightIcon:Show();
		AddFriendInfoFrameFactionIcon:Show();
	else
		AddFriendInfoFrameFactionIcon:Hide();
	end
end

function AddFriendFrame_ShowInfo()
	AddFriendFrame:SetWidth(AddFriendInfoFrame:GetWidth());
	AddFriendFrame:SetHeight(AddFriendInfoFrame:GetHeight());
	AddFriendInfoFrame:Show();
	AddFriendEntryFrame:Hide();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function AddFriendFrame_ShowEntry()
	AddFriendFrame:SetWidth(AddFriendEntryFrame:GetWidth());
	AddFriendFrame:SetHeight(AddFriendEntryFrame:GetHeight());
	AddFriendInfoFrame:Hide();
	AddFriendEntryFrame:Show();
	if ( BNFeaturesEnabledAndConnected() ) then
		AddFriendFrame.BNconnected = true;
		AddFriendEntryFrameLeftTitle:SetAlpha(1);
		AddFriendEntryFrameLeftDescription:SetTextColor(1, 1, 1);
		AddFriendEntryFrameLeftIcon:SetVertexColor(1, 1, 1);
		AddFriendEntryFrameLeftFriend:SetVertexColor(1, 1, 1);
		local _, battleTag, _, _, _, _, isRIDEnabled = BNGetInfo();
		if ( battleTag and isRIDEnabled ) then
			AddFriendEntryFrameLeftTitle:SetText(REAL_ID);
			AddFriendEntryFrameLeftDescription:SetText(REALID_BATTLETAG_FRIEND_LABEL);
			AddFriendNameEditBoxFill:SetText(ENTER_NAME_OR_BATTLETAG_OR_EMAIL);
		elseif ( isRIDEnabled ) then
			AddFriendEntryFrameLeftTitle:SetText(REAL_ID);
			AddFriendEntryFrameLeftDescription:SetText(REALID_FRIEND_LABEL);
			AddFriendNameEditBoxFill:SetText(ENTER_NAME_OR_EMAIL);
		elseif ( battleTag ) then
			AddFriendEntryFrameLeftTitle:SetText(BATTLETAG);
			AddFriendEntryFrameLeftDescription:SetText(BATTLETAG_FRIEND_LABEL);
			AddFriendNameEditBoxFill:SetText(ENTER_NAME_OR_BATTLETAG);
		end
	else
		AddFriendFrame.BNconnected = nil;
		AddFriendEntryFrameLeftTitle:SetAlpha(0.35);
		AddFriendEntryFrameLeftDescription:SetText(BATTLENET_UNAVAILABLE);
		AddFriendEntryFrameLeftDescription:SetTextColor(1, 0, 0);
		AddFriendEntryFrameLeftIcon:SetVertexColor(.4, .4, .4);
		AddFriendEntryFrameLeftFriend:SetVertexColor(.4, .4, .4);
	end
	if ( AddFriendFrame.editFocus ) then
		AddFriendFrame.editFocus:SetFocus();
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function AddFriendNameEditBox_OnTextChanged(self, userInput)
	if ( not AutoCompleteEditBox_OnTextChanged(self, userInput) ) then
		local text = self:GetText();
		if ( text ~= "" ) then
			AddFriendNameEditBoxFill:Hide();
			if ( AddFriendFrame.BNconnected ) then
				AddFriendEntryFrame_Init();
			end
			AddFriendEntryFrameAcceptButton:Enable();
		else
			AddFriendEntryFrame_Init();
			AddFriendNameEditBoxFill:Show();
			AddFriendEntryFrameAcceptButton:Disable();
		end
	end
end

function AddFriendEntryFrame_Init(clearText)
	AddFriendEntryFrame:SetHeight(ADDFRIENDFRAME_WOWHEIGHT);
	AddFriendFrame:SetHeight(ADDFRIENDFRAME_WOWHEIGHT);
	AddFriendEntryFrameAcceptButton:SetText(ADD_FRIEND);
	AddFriendEntryFrameRightTitle:SetAlpha(1);
	AddFriendEntryFrameRightDescription:SetAlpha(1);
	AddFriendEntryFrameRightIcon:SetVertexColor(1, 1, 1);
	AddFriendEntryFrameRightFriend:SetVertexColor(1, 1, 1);
	AddFriendEntryFrameLeftIcon:SetAlpha(0.5);
	if ( AddFriendFrame.BNconnected ) then
		AddFriendEntryFrameOrLabel:SetVertexColor(1, 1, 1);
	else
		AddFriendEntryFrameOrLabel:SetVertexColor(0.3, 0.3, 0.3);
	end
	if ( clearText ) then
		AddFriendNameEditBox:SetText("");
	end
end

function AddFriendFrame_Accept()
	local name = AddFriendNameEditBox:GetText();
	if ( AddFriendFrame_IsValidBattlenetName(name) and AddFriendFrame.BNconnected ) then
		BNSendFriendInvite(name, "");
	else
		C_FriendList.AddFriend(name);
	end
	StaticPopupSpecial_Hide(AddFriendFrame);
end

function AddFriendFrame_IsValidBattlenetName(text)
	local _, battleTag, _, _, _, _, isRIDEnabled = BNGetInfo();
	if ( isRIDEnabled and string.find(text, "@") ) then
		return true;
	end
	if ( battleTag and string.find(text, "#") ) then
		return true;
	end
	return false;
end

function FriendsFriendsFrameDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	local value = FriendsFriendsFrame.view;

	info.value = FRIENDS_FRIENDS_ALL;
	info.text = FRIENDS_FRIENDS_CHOICE_EVERYONE;
	info.func = FriendsFriendsFrameDropDown_OnClick;
	info.arg1 = FRIENDS_FRIENDS_ALL;
	if ( value == info.value ) then
		info.checked = 1;
		UIDropDownMenu_SetText(FriendsFriendsFrameDropDown, info.text);
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.value = FRIENDS_FRIENDS_POTENTIAL;
	info.text = FRIENDS_FRIENDS_CHOICE_POTENTIAL;
	info.func = FriendsFriendsFrameDropDown_OnClick;
	info.arg1 = FRIENDS_FRIENDS_POTENTIAL;
	if ( value == info.value ) then
		info.checked = 1;
		UIDropDownMenu_SetText(FriendsFriendsFrameDropDown, info.text);
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.value = FRIENDS_FRIENDS_MUTUAL;
	info.text = FRIENDS_FRIENDS_CHOICE_MUTUAL;
	info.func = FriendsFriendsFrameDropDown_OnClick;
	info.arg1 = FRIENDS_FRIENDS_MUTUAL;
	if ( value == info.value ) then
		info.checked = 1;
		UIDropDownMenu_SetText(FriendsFriendsFrameDropDown, info.text);
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);
end

function FriendsFriendsFrameDropDown_OnClick(self, value)
	FriendsFriendsFrame.view = value;
	UIDropDownMenu_SetSelectedValue(FriendsFriendsFrameDropDown, value);
	FriendsFriendsScrollFrame.scrollBar:SetValue(0);
	FriendsFriendsFrame:Update();
end

FriendsFriendsButtonMixin = {};

function FriendsFriendsButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	FriendsFriendsFrame.selection = self.friendID;
	FriendsFriendsFrame:Update();
end

IgnoreListButtonMixin = {};

function IgnoreListButtonMixin:OnClick()
	FriendsFrame_SelectSquelched(self.type, self.index);
	IgnoreList_Update();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

WhoListButtonMixin = {};

function WhoListButtonMixin:OnClick(button)
	if button == "LeftButton" then
		WhoFrame.selectedWho = self.index;
		WhoFrame.selectedName = self.Name:GetText();
		WhoList_Update();
	else
		local name = self.Name:GetText();
		FriendsFrame_ShowDropdown(name, 1);
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function WhoListButtonMixin:OnEnter()
	if self.tooltip1 and self.tooltip2 then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText(self.tooltip1);
		GameTooltip:AddLine(self.tooltip2, 1, 1, 1);
		GameTooltip:Show();
	end
end

FriendsListButtonMixin = {};

function FriendsListButtonMixin:OnLoad()
	self.highlight:SetVertexColor(HIGHLIGHT_LIGHT_BLUE:GetRGB());
end

local regionNames = {
	[1] = NORTH_AMERICA,
	[2] = KOREA,
	[3] = EUROPE,
	[4] = TAIWAN,
	[5] = CHINA,
};

function FriendsListButtonMixin:OnEnter()
	if ( self.buttonType == FRIENDS_BUTTON_TYPE_DIVIDER ) then
		return;
	end
	local anchor, text;
	local numGameAccounts = 0;
	local tooltip = FriendsTooltip;
	local isOnline = false;
	local battleTag = "";
	tooltip.height = 0;
	tooltip.maxWidth = 0;

	if self.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(self.id);
		if accountInfo then
			local noCharacterName = true;
			local nameText, nameColor = FriendsFrame_GetBNetAccountNameAndStatus(accountInfo, noCharacterName);

			isOnline = accountInfo.gameAccountInfo.isOnline;
			battleTag = accountInfo.battleTag;

			anchor = FriendsFrameTooltip_SetLine(FriendsTooltipHeader, nil, nameText);
			FriendsTooltipHeader:SetTextColor(nameColor:GetRGB());

			if accountInfo.gameAccountInfo.gameAccountID then
				if ShowRichPresenceOnly(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.wowProjectID, accountInfo.gameAccountInfo.factionName, accountInfo.gameAccountInfo.realmID) then
					local characterName = BNet_GetValidatedCharacterName(accountInfo.gameAccountInfo.characterName, accountInfo.battleTag, accountInfo.gameAccountInfo.clientProgram);
					FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Name, nil, characterName);
					anchor = FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Info, nil, accountInfo.gameAccountInfo.richPresence, -4);
				else
					local raceName = accountInfo.gameAccountInfo.raceName or UNKNOWN;
					local className = accountInfo.gameAccountInfo.className or UNKNOWN;
					if CanCooperateWithGameAccount(accountInfo) then
						text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, accountInfo.gameAccountInfo.characterName, accountInfo.gameAccountInfo.characterLevel, raceName, className);
					else
						text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, accountInfo.gameAccountInfo.characterName..CANNOT_COOPERATE_LABEL, accountInfo.gameAccountInfo.characterLevel, raceName, className);
					end
					FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Name, nil, text);
					local areaName = accountInfo.gameAccountInfo.isWowMobile and LOCATION_MOBILE_APP or (accountInfo.gameAccountInfo.areaName or UNKNOWN);
					if accountInfo.gameAccountInfo.isInCurrentRegion then
						local realmName = accountInfo.gameAccountInfo.realmDisplayName or UNKNOWN;
						anchor = FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Info, nil, BNET_FRIEND_TOOLTIP_ZONE_AND_REALM:format(areaName, realmName), -4);
					else
						local regionNameString = regionNames[accountInfo.gameAccountInfo.regionID] or UNKNOWN;
						anchor = FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Info, nil, BNET_FRIEND_TOOLTIP_ZONE_AND_REGION:format(areaName, regionNameString), -4);
					end
				end
			else
				FriendsTooltipGameAccount1Info:Hide();
				FriendsTooltipGameAccount1Name:Hide();
			end

			-- note
			if accountInfo.note ~= "" then
				FriendsTooltipNoteIcon:Show();
				anchor = FriendsFrameTooltip_SetLine(FriendsTooltipNoteText, anchor, accountInfo.note, -8);
			else
				FriendsTooltipNoteIcon:Hide();
				FriendsTooltipNoteText:Hide();
			end
			-- broadcast
			if accountInfo.customMessage ~= "" then
				FriendsTooltipBroadcastIcon:Show();
				if not HasTimePassed(accountInfo.customMessageTime, SECONDS_PER_YEAR) then
					accountInfo.customMessage = accountInfo.customMessage.."|n"..FRIENDS_BROADCAST_TIME_COLOR_CODE..string.format(BNET_BROADCAST_SENT_TIME, FriendsFrame_GetLastOnline(accountInfo.customMessageTime)..FONT_COLOR_CODE_CLOSE);
				end
				anchor = FriendsFrameTooltip_SetLine(FriendsTooltipBroadcastText, anchor, accountInfo.customMessage, -8);
				FriendsTooltip.hasBroadcast = true;
			else
				FriendsTooltipBroadcastIcon:Hide();
				FriendsTooltipBroadcastText:Hide();
				FriendsTooltip.hasBroadcast = nil;
			end

			if accountInfo.gameAccountInfo.isOnline then
				FriendsTooltipLastOnline:Hide();
				numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(self.id);
			else
				text = FriendsFrame_GetLastOnlineText(accountInfo);
				anchor = FriendsFrameTooltip_SetLine(FriendsTooltipLastOnline, anchor, text, -4);
			end
		end
	elseif self.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList.GetFriendInfoByIndex(self.id);
		anchor = FriendsFrameTooltip_SetLine(FriendsTooltipHeader, nil, info.name);
		if info.connected then
			FriendsTooltipHeader:SetTextColor(FRIENDS_WOW_NAME_COLOR.r, FRIENDS_WOW_NAME_COLOR.g, FRIENDS_WOW_NAME_COLOR.b);
			FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Name, nil, string.format(FRIENDS_LEVEL_TEMPLATE, info.level, info.className));
			anchor = FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Info, nil, info.mobile and LOCATION_MOBILE_APP or info.area);
		else
			FriendsTooltipHeader:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
			FriendsTooltipGameAccount1Name:Hide();
			FriendsTooltipGameAccount1Info:Hide();
		end
		if ( info.notes ) then
			FriendsTooltipNoteIcon:Show();
			anchor = FriendsFrameTooltip_SetLine(FriendsTooltipNoteText, anchor, info.notes, -8);
		else
			FriendsTooltipNoteIcon:Hide();
			FriendsTooltipNoteText:Hide();
		end
		FriendsTooltipBroadcastIcon:Hide();
		FriendsTooltipBroadcastText:Hide();
		FriendsTooltipLastOnline:Hide();
	end

	-- other game accounts
	local gameAccountIndex = 1;
	local characterNameString;
	local gameAccountInfoString;
	if numGameAccounts > 1 then
		local headerSet = false;
		for i = 1, numGameAccounts do
			local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(self.id, i);

			-- the focused game account is already at the top of the tooltip
			if not gameAccountInfo.hasFocus and (gameAccountInfo.clientProgram ~= BNET_CLIENT_APP) and (gameAccountInfo.clientProgram ~= BNET_CLIENT_CLNT) then
				local areaName = gameAccountInfo.areaName or UNKNOWN;
				local raceName = gameAccountInfo.raceName or UNKNOWN;
				local className = gameAccountInfo.className or UNKNOWN;
				local gameText = gameAccountInfo.richPresence or "";

				if not headerSet then
					FriendsFrameTooltip_SetLine(FriendsTooltipOtherGameAccounts, anchor, nil, -8);
					headerSet = true;
				end
				gameAccountIndex = gameAccountIndex + 1;
				if ( gameAccountIndex > FRIENDS_TOOLTIP_MAX_GAME_ACCOUNTS ) then
					break;
				end
				characterNameString = _G["FriendsTooltipGameAccount"..gameAccountIndex.."Name"];
				gameAccountInfoString = _G["FriendsTooltipGameAccount"..gameAccountIndex.."Info"];
				text = BNet_GetClientEmbeddedTexture(gameAccountInfo.clientProgram, 18).." ";
				if (gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and (gameAccountInfo.wowProjectID == WOW_PROJECT_ID) then
					if (gameAccountInfo.realmName == playerRealmName) and (gameAccountInfo.factionName == playerFactionGroup) then
						text = text..string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, gameAccountInfo.characterName, gameAccountInfo.characterLevel, raceName, className);
					else
						text = text..string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, gameAccountInfo.characterName..CANNOT_COOPERATE_LABEL, gameAccountInfo.characterLevel, raceName, className);
					end
					gameText = areaName;
				else
					local characterName = "";
					if gameAccountInfo.isOnline then
						characterName = BNet_GetValidatedCharacterName(gameAccountInfo.characterName, battleTag, gameAccountInfo.clientProgram);
					end
					text = text..characterName;
				end
				FriendsFrameTooltip_SetLine(characterNameString, nil, text);
				FriendsFrameTooltip_SetLine(gameAccountInfoString, nil, gameText);
			end
		end
		if ( not headerSet ) then
			FriendsTooltipOtherGameAccounts:Hide();
		end
	else
		FriendsTooltipOtherGameAccounts:Hide();
	end
	for i = gameAccountIndex + 1, FRIENDS_TOOLTIP_MAX_GAME_ACCOUNTS do
		characterNameString = _G["FriendsTooltipGameAccount"..i.."Name"];
		gameAccountInfoString = _G["FriendsTooltipGameAccount"..i.."Info"];
		characterNameString:Hide();
		gameAccountInfoString:Hide();
	end
	if ( numGameAccounts > FRIENDS_TOOLTIP_MAX_GAME_ACCOUNTS ) then
		FriendsFrameTooltip_SetLine(FriendsTooltipGameAccountMany, nil, string.format(FRIENDS_TOOLTIP_TOO_MANY_CHARACTERS, numGameAccounts - FRIENDS_TOOLTIP_MAX_GAME_ACCOUNTS), 0);
	else
		FriendsTooltipGameAccountMany:Hide();
	end

	tooltip.button = self;
	tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 36, 0);
	tooltip:SetHeight(tooltip.height + FRIENDS_TOOLTIP_MARGIN_WIDTH);
	tooltip:SetWidth(min(FRIENDS_TOOLTIP_MAX_WIDTH, tooltip.maxWidth + FRIENDS_TOOLTIP_MARGIN_WIDTH));
	tooltip:Show();
end

function FriendsListButtonMixin:OnLeave()
	FriendsTooltip.button = nil;
	FriendsTooltip:Hide();
end

function FriendsListButtonMixin:OnClick(button)
	if ( button == "LeftButton" ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		FriendsFrame_SelectFriend(self.buttonType, self.id);
		FriendsList_Update();
		-- if friends of friends frame is being shown, switch list if new selection is another battlenet friend
		if ( FriendsFriendsFrame:IsShown() and self.buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
			local accountInfo = C_BattleNet.GetFriendAccountInfo(self.id);
			if accountInfo and (accountInfo.bnetAccountID ~= FriendsFriendsFrame.bnetIDAccount) then
				FriendsFriendsFrame_Show(accountInfo.bnetAccountID);
			end
		end
	elseif ( button == "RightButton" ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		if ( self.buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
			-- bnet friend
			local accountInfo = C_BattleNet.GetFriendAccountInfo(self.id);
			if accountInfo then
				FriendsFrame_ShowBNDropdown(accountInfo.accountName, accountInfo.gameAccountInfo.isOnline, nil, nil, nil, 1, accountInfo.bnetAccountID, nil, nil, nil, nil, accountInfo.gameAccountInfo.isWowMobile);
			end
		else
			-- wow friend
			local info = C_FriendList.GetFriendInfoByIndex(self.id);
			FriendsFrame_ShowDropdown(info.name, info.connected, nil, nil, nil, 1, info.mobile, nil, nil, nil, nil, info.guid);
		end
	end
end

FriendsFriendsFrameMixin = {};

function FriendsFriendsFrameMixin:OnLoad()
	self:RegisterEvent("BN_REQUEST_FOF_SUCCEEDED");
	self:RegisterEvent("BN_DISCONNECTED");
	self.requested = {};
	self.hideOnEscape = true;
	self.exclusive = true;
	UIDropDownMenu_SetWidth(FriendsFriendsFrameDropDown, 120);

	FriendsFriendsScrollFrame.update = function() self:Update() end;
	HybridScrollFrame_CreateButtons(FriendsFriendsScrollFrame, "FriendsFriendsButtonTemplate");
end

function FriendsFriendsFrameMixin:OnEvent(event)
	if event == "BN_REQUEST_FOF_SUCCEEDED" then
		if self:IsShown() then
			FriendsFriendsFrame.view = FRIENDS_FRIENDS_ALL;
			UIDropDownMenu_EnableDropDown(FriendsFriendsFrameDropDown);
			UIDropDownMenu_Initialize(FriendsFriendsFrameDropDown, FriendsFriendsFrameDropDown_Initialize);
			UIDropDownMenu_SetSelectedValue(FriendsFriendsFrameDropDown, FRIENDS_FRIENDS_ALL);
			local waitFrame = FriendsFriendsWaitFrame;
			-- need to stop the flashing because it's flashing with showWhenDone set to true
			if UIFrameIsFlashing(waitFrame) then
				UIFrameFlashStop(waitFrame);
			end
			waitFrame:Hide();
			self:Update();
		end
	elseif event == "BN_DISCONNECTED" then
		FriendsFriendsFrame_Close();
	end
end

function FriendsFriendsFrameMixin:SendRequest()
	if self.selection then
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
		self.requested[self.selection] = true;
		BNSendFriendInviteByID(self.selection);
		self:Reset();
		self:Update();
	end
end

function FriendsFriendsFrameMixin:Reset()
	self.SendRequestButton:Disable();
	self.selection = nil;
end

function FriendsFriendsFrameMixin:Update()
	if FriendsFriendsWaitFrame:IsShown() then
		return;
	end

	local scrollFrame = FriendsFriendsScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	local showMutual, showPotential;
	local view = self.view;
	local selection = self.selection;
	local requested = self.requested;
	local bnetIDAccount = self.bnetIDAccount;
	local numFriendsFriends = 0;
	local numMutual, numPotential = BNGetNumFOF(bnetIDAccount);
	if view == FRIENDS_FRIENDS_POTENTIAL or view == FRIENDS_FRIENDS_ALL then
		showPotential = true;
		numFriendsFriends = numFriendsFriends + numPotential;
	end
	if view == FRIENDS_FRIENDS_MUTUAL or view == FRIENDS_FRIENDS_ALL then
		showMutual = true;
		numFriendsFriends = numFriendsFriends + numMutual;
	end

	local haveSelection;
	local usedHeight = 0;

	for i = 1, numButtons do
		local button = buttons[i];

		local index = offset + i;
		if index <= numFriendsFriends then
			local friendID, accountName, isMutual = BNGetFOFInfo(showMutual, showPotential, index);

			if isMutual then
				button:Disable();
				if view ~= FRIENDS_FRIENDS_MUTUAL then
					button.name:SetText(accountName.." "..HIGHLIGHT_FONT_COLOR_CODE..FRIENDS_FRIENDS_MUTUAL_TEXT..FONT_COLOR_CODE_CLOSE);
				else
					button.name:SetText(accountName);
				end
				button.name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			elseif requested[friendID] then
				button.name:SetText(accountName.." "..HIGHLIGHT_FONT_COLOR_CODE..FRIENDS_FRIENDS_REQUESTED_TEXT..FONT_COLOR_CODE_CLOSE);
				button:Disable();
				button.name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			else
				button.name:SetText(accountName);
				button:Enable();
				button.name:SetTextColor(BATTLENET_FONT_COLOR.r, BATTLENET_FONT_COLOR.g, BATTLENET_FONT_COLOR.b);
			end
			button.friendID = friendID;

			if selection == friendID then
				haveSelection = true;
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end

			button:Show();
			usedHeight = usedHeight + FRIENDS_FRAME_FRIENDS_FRIENDS_HEIGHT;
		else
			button.friendID = nil;
			button:Hide();
		end

	end

	local totalHeight = numFriendsFriends * FRIENDS_FRAME_FRIENDS_FRIENDS_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, usedHeight);

	if haveSelection then
		self.SendRequestButton:Enable();
	else
		self.SendRequestButton:Disable();
	end
end

function FriendsFriendsFrame_Close()
	StaticPopupSpecial_Hide(FriendsFriendsFrame);
end

function FriendsFriendsFrame_Show(bnetIDAccount)
	local accountInfo = C_BattleNet.GetAccountInfoByID(bnetIDAccount);
	if not accountInfo then
		return;
	end
	FriendsFriendsFrameTitle:SetFormattedText(FRIENDS_FRIENDS_HEADER, FRIENDS_BNET_NAME_COLOR_CODE..accountInfo.accountName..FONT_COLOR_CODE_CLOSE);
	FriendsFriendsFrame.bnetIDAccount = accountInfo.bnetAccountID;
	UIDropDownMenu_DisableDropDown(FriendsFriendsFrameDropDown);
	FriendsFriendsFrame:Reset();
	FriendsFriendsWaitFrame:Show();
	StaticPopupSpecial_Show(FriendsFriendsFrame);
	BNRequestFOFInfo(accountInfo.bnetAccountID);
end

function FriendsFrame_InviteOrRequestToJoin(guid, gameAccountID)
	local inviteType = GetDisplayedInviteType(guid);
	if ( inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" ) then
		if inviteType == "SUGGEST_INVITE" and C_PartyInfo.IsPartyFull() then
			ChatFrame_DisplaySystemMessageInPrimary(ERR_GROUP_FULL);
			return;
		end

		BNInviteFriend(gameAccountID);
	elseif ( inviteType == "REQUEST_INVITE" ) then
		BNRequestInviteFriend(gameAccountID);
	end
end

function FriendsFrame_BattlenetInviteByIndex(friendIndex)
	local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(friendIndex);
	if numGameAccounts > 1 then
		-- see if there is exactly one game account we could invite
		local numValidGameAccounts = 0;
		local lastGameAccountID;
		local lastGameAccountGUID;
		for i = 1, numGameAccounts do
			local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(friendIndex, i);
			if gameAccountInfo.playerGuid and (gameAccountInfo.factionName == playerFactionGroup) and (gameAccountInfo.realmID ~= 0) then
				numValidGameAccounts = numValidGameAccounts + 1;
				lastGameAccountID = gameAccountInfo.gameAccountID;
				lastGameAccountGUID = gameAccountInfo.playerGuid;
			end
		end

		if ( numValidGameAccounts == 1 ) then
			FriendsFrame_InviteOrRequestToJoin(lastGameAccountGUID, lastGameAccountID);
			return;
		end

		-- if no button, now find the physical friend button to anchor the dropdown
		-- it might not exist if the list was scrolled
		if ( not button ) then
			local buttons = FriendsListFrameScrollFrame.buttons;
			for i = 1, #buttons do
				if ( buttons[i].id == friendIndex and buttons[i].buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
					button = buttons[i];
					break;
				end
			end
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local dropDown = TravelPassDropDown;
		if ( dropDown.index ~= friendIndex ) then
			CloseDropDownMenus();
		end

		dropDown.index = friendIndex;
		-- show dropdown at the button if one was passed in or we found it
		if ( button ) then
			ToggleDropDownMenu(1, nil, dropDown, button.travelPassButton, 20, 34);
		else
			ToggleDropDownMenu(1, nil, dropDown, "cursor", 1, -1);
		end
	else
		local accountInfo = C_BattleNet.GetFriendAccountInfo(friendIndex);
		if accountInfo and accountInfo.gameAccountInfo.playerGuid then
			FriendsFrame_InviteOrRequestToJoin(accountInfo.gameAccountInfo.playerGuid, accountInfo.gameAccountInfo.gameAccountID);
		end
	end
end

function CanCooperateWithGameAccount(accountInfo)
	if not accountInfo then
		return false;
	end
	return accountInfo.gameAccountInfo.realmID and accountInfo.gameAccountInfo.realmID > 0 and accountInfo.gameAccountInfo.factionName == playerFactionGroup;
end

--
-- travel pass
--

function CanGroupWithAccount(bnetIDAccount)
	if (not bnetIDAccount) then
		return false;
	end
	local index = BNGetFriendIndex(bnetIDAccount);
	if (not index) then
		return false;
	end
	local restriction = FriendsFrame_GetInviteRestriction(index);
	return (restriction == INVITE_RESTRICTION_NONE);
end

--Note that a single friend can have multiple GUIDs (if they're dual-boxing). This just gets one if there is one.
function FriendsFrame_GetPlayerGUIDFromIndex(index)
	local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(index);
	for i = 1, numGameAccounts do
		local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(index, i);
		if gameAccountInfo.playerGuid then
			return gameAccountInfo.playerGuid;
		end
	end

	return nil;
end

function FriendsFrame_GetInviteRestriction(index)
	local restriction = INVITE_RESTRICTION_NO_GAME_ACCOUNTS;
	local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(index);
	for i = 1, numGameAccounts do
		local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(index, i);
		if gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
			if gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID then
				if gameAccountInfo.wowProjectID == WOW_PROJECT_CLASSIC then
					restriction = max(INVITE_RESTRICTION_WOW_PROJECT_CLASSIC, restriction);
				elseif gameAccountInfo.wowProjectID == WOW_PROJECT_MAINLINE then
					restriction = max(INVITE_RESTRICTION_WOW_PROJECT_MAINLINE, restriction);
				else
					restriction = max(INVITE_RESTRICTION_WOW_PROJECT_ID, restriction);
				end
			elseif gameAccountInfo.factionName ~= playerFactionGroup then
				restriction = max(INVITE_RESTRICTION_FACTION, restriction);
			elseif gameAccountInfo.realmID == 0 then
				restriction = max(INVITE_RESTRICTION_INFO, restriction);
			elseif (gameAccountInfo.wowProjectID == WOW_PROJECT_CLASSIC) and (gameAccountInfo.realmID ~= playerRealmID) then
				restriction = max(INVITE_RESTRICTION_REALM, restriction);
			elseif gameAccountInfo.isWowMobile then
				restriction = INVITE_RESTRICTION_MOBILE;
			elseif not gameAccountInfo.isInCurrentRegion then
				restriction = INVITE_RESTRICTION_REGION;
			else
				-- there is at lease 1 game account that can be invited
				return INVITE_RESTRICTION_NONE;
			end
		else
			restriction = max(INVITE_RESTRICTION_CLIENT, restriction);
		end
	end
	return restriction;
end

function FriendsFrame_GetInviteRestrictionText(restriction)
	if ( restriction == INVITE_RESTRICTION_LEADER ) then
		return ERR_TRAVEL_PASS_NOT_LEADER;
	elseif ( restriction == INVITE_RESTRICTION_FACTION ) then
		return ERR_TRAVEL_PASS_NOT_ALLIED;
	elseif ( restriction == INVITE_RESTRICTION_REALM ) then
		return ERR_TRAVEL_PASS_DIFFERENT_REALM;
	elseif ( restriction == INVITE_RESTRICTION_INFO ) then
		return ERR_TRAVEL_PASS_NO_INFO;
	elseif ( restriction == INVITE_RESTRICTION_CLIENT ) then
		return ERR_TRAVEL_PASS_NOT_WOW;
	elseif ( restriction == INVITE_RESTRICTION_WOW_PROJECT_ID ) then
		return ERR_TRAVEL_PASS_WRONG_PROJECT;
	elseif ( restriction == INVITE_RESTRICTION_WOW_PROJECT_MAINLINE ) then
		return ERR_TRAVEL_PASS_WRONG_PROJECT_MAINLINE_OVERRIDE;
	elseif ( restriction == INVITE_RESTRICTION_WOW_PROJECT_CLASSIC ) then
		return ERR_TRAVEL_PASS_WRONG_PROJECT_CLASSIC_OVERRIDE;
	elseif ( restriction == INVITE_RESTRICTION_MOBILE ) then
		return ERR_TRAVEL_PASS_MOBILE;
	elseif ( restriction == INVITE_RESTRICTION_REGION ) then
		return ERR_TRAVEL_PASS_DIFFERENT_REGION;
	else
		return "";
	end
end

function TravelPassButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local restriction = FriendsFrame_GetInviteRestriction(self:GetParent().id);
	if ( restriction == INVITE_RESTRICTION_NONE ) then
		local guid = FriendsFrame_GetPlayerGUIDFromIndex(self:GetParent().id);
		local inviteType = GetDisplayedInviteType(guid);
		if ( inviteType == "INVITE" ) then
			GameTooltip:SetText(TRAVEL_PASS_INVITE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		elseif ( inviteType == "SUGGEST_INVITE" ) then
			GameTooltip:SetText(SUGGEST_INVITE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		else --inviteType == "REQUEST_INVITE"
			GameTooltip:SetText(REQUEST_INVITE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			--For REQUEST_INVITE, we'll display other members in the group if there are any.
			local group = C_SocialQueue.GetGroupForPlayer(guid);
			local members = C_SocialQueue.GetGroupMembers(group);
			local numDisplayed = 0;
			for i=1, #members do
				if ( members[i].guid ~= guid ) then
					if ( numDisplayed == 0 ) then
						GameTooltip:AddLine(SOCIAL_QUEUE_ALSO_IN_GROUP);
					elseif ( numDisplayed >= 7 ) then
						GameTooltip:AddLine(SOCIAL_QUEUE_AND_MORE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
						break;
					end
					local name, color = SocialQueueUtil_GetRelationshipInfo(members[i].guid, nil, members[i].clubId);
					GameTooltip:AddLine(color..name..FONT_COLOR_CODE_CLOSE);

					numDisplayed = numDisplayed + 1;
				end
			end
		end
	else
		GameTooltip:SetText(TRAVEL_PASS_INVITE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
		GameTooltip:AddLine(FriendsFrame_GetInviteRestrictionText(restriction), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	end
	GameTooltip:Show();
end

function TravelPassDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, TravelPassDropDown_Initialize, "MENU");
end

function TravelPassDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.text = TRAVEL_PASS_INVITE;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;
	info.func = TravelPassDropDown_OnClick;

	local numGameAccounts, restriction;
	if self.index then
		numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(self.index);
	else
		numGameAccounts = 0;
	end
	for i = 1, numGameAccounts do
		restriction = INVITE_RESTRICTION_NONE;
		local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(self.index, i);
		if gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
			if gameAccountInfo.factionName ~= playerFactionGroup then
				restriction = INVITE_RESTRICTION_FACTION;
			elseif gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID then
				restriction = INVITE_RESTRICTION_WOW_PROJECT_ID;
			elseif gameAccountInfo.realmID == 0 then
				restriction = INVITE_RESTRICTION_INFO;
			elseif (gameAccountInfo.wowProjectID == WOW_PROJECT_CLASSIC) and (gameAccountInfo.realmID ~= playerRealmID) then
				restriction = INVITE_RESTRICTION_REALM;
			end
			if restriction == INVITE_RESTRICTION_NONE then
				info.text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, gameAccountInfo.characterName, gameAccountInfo.characterLevel, gameAccountInfo.raceName or UNKNOWN, gameAccountInfo.className or UNKNOWN);
			else
				info.text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, gameAccountInfo.characterName..CANNOT_COOPERATE_LABEL, gameAccountInfo.characterLevel, gameAccountInfo.raceName or UNKNOWN, gameAccountInfo.className or UNKNOWN);
			end
		else
			restriction = INVITE_RESTRICTION_CLIENT;
			info.text = BNet_GetClientEmbeddedTexture(gameAccountInfo.clientProgram, 18);
		end
		if ( restriction == INVITE_RESTRICTION_NONE ) then
			info.arg1 = gameAccountInfo.gameAccountID;
			info.disabled = nil;
		else
			info.arg1 = nil;
			info.disabled = 1;
		end
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
end

function TravelPassDropDown_OnClick(button, gameAccountID)
	local gameAccountInfo = C_BattleNet.GetGameAccountInfoByID(gameAccountID);
	if gameAccountInfo.playerGuid then
		FriendsFrame_InviteOrRequestToJoin(gameAccountInfo.playerGuid, gameAccountID);
	end
end

function BattleTagInviteFrame_Show(name)
	BattleTagInviteFrame.BattleTag:SetText(name);
	if ( not BattleTagInviteFrame:IsShown() ) then
		StaticPopupSpecial_Show(BattleTagInviteFrame);
	end
end
