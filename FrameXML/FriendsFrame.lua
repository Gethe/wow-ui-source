FRIENDS_TO_DISPLAY = 10;
FRIENDS_FRAME_FRIEND_HEIGHT = 34;
IGNORES_TO_DISPLAY = 19;
FRIENDS_FRAME_IGNORE_HEIGHT = 16;
PENDING_INVITES_TO_DISPLAY = 4;
PENDING_BUTTON_MIN_HEIGHT = 92;
FRIENDS_FRIENDS_TO_DISPLAY = 11;
FRIENDS_FRAME_FRIENDS_FRIENDS_HEIGHT = 16;
MAX_INVITE_MESSAGE_LINES = 10;
MAX_INVITE_MESSAGE_HEIGHT = 0;		-- automatically set in FriendsFramePendingScrollFrame:OnLoad
WHOS_TO_DISPLAY = 17;
FRIENDS_FRAME_WHO_HEIGHT = 16;
MAX_WHOS_FROM_SERVER = 50;
FRIENDS_SCROLLFRAME_HEIGHT = 307;
FRIENDS_BUTTON_HEADER_HEIGHT = 16;
FRIENDS_BUTTON_NORMAL_HEIGHT = 34;
FRIENDS_BUTTON_TYPE_HEADER = 1;
FRIENDS_BUTTON_TYPE_BNET = 2;
FRIENDS_BUTTON_TYPE_WOW = 3;
FRIENDS_TEXTURE_ONLINE = "Interface\\FriendsFrame\\StatusIcon-Online";
FRIENDS_TEXTURE_AFK = "Interface\\FriendsFrame\\StatusIcon-Away";
FRIENDS_TEXTURE_DND = "Interface\\FriendsFrame\\StatusIcon-DnD";
FRIENDS_TEXTURE_OFFLINE = "Interface\\FriendsFrame\\StatusIcon-Offline";
FRIENDS_TEXTURE_BROADCAST = "Interface\\FriendsFrame\\BroadcastIcon";
FRIENDS_BNET_NAME_COLOR = {r=0.510, g=0.773, b=1.0};
FRIENDS_BNET_BACKGROUND_COLOR = {r=0, g=0.694, b=0.941, a=0.05};
FRIENDS_WOW_NAME_COLOR = {r=0.996, g=0.882, b=0.361};
FRIENDS_WOW_BACKGROUND_COLOR = {r=1.0, g=0.824, b=0.0, a=0.05};
FRIENDS_GRAY_COLOR = {r=0.486, g=0.518, b=0.541};
FRIENDS_OFFLINE_BACKGROUND_COLOR = {r=0.588, g=0.588, b=0.588, a=0.05};
FRIENDS_PRESENCE_COLOR_CODE = "|cff7c848a";
FRIENDS_BNET_NAME_COLOR_CODE = "|cff82c5ff";
FRIENDS_BROADCAST_TIME_COLOR_CODE = "|cff4381a8"
FRIENDS_WOW_NAME_COLOR_CODE = "|cfffde05c";
FRIENDS_OTHER_NAME_COLOR_CODE = "|cff7b8489";
SQUELCH_TYPE_IGNORE = 1;
SQUELCH_TYPE_BLOCK_INVITE = 2;
SQUELCH_TYPE_MUTE = 3;
SQUELCH_TYPE_BLOCK_TOON = 4;
FRIENDS_FRIENDS_POTENTIAL = 1;
FRIENDS_FRIENDS_MUTUAL = 2;
FRIENDS_FRIENDS_ALL = 3;
FRIENDS_TOOLTIP_MAX_TOONS = 5;
FRIENDS_TOOLTIP_MAX_WIDTH = 200;
FRIENDS_TOOLTIP_MARGIN_WIDTH = 12;

ADDFRIENDFRAME_WOWHEIGHT = 218;
ADDFRIENDFRAME_BNETHEIGHT = 296;

FRIEND_TABS_MAX_WIDTH = 0;		-- some locales may need to abbreviate tab headers to fit

local INVITE_RESTRICTION_NO_TOONS = 0;
local INVITE_RESTRICTION_CLIENT = 1;
local INVITE_RESTRICTION_LEADER = 2;
local INVITE_RESTRICTION_FACTION = 3;
local INVITE_RESTRICTION_INFO = 4;
local INVITE_RESTRICTION_NONE = 5;

local FriendButtons = { count = 0 };
local PendingInvitesNew = { };
local playerRealmName;
local playerFactionGroup;

local ONE_MINUTE = 60;
local ONE_HOUR = 60 * ONE_MINUTE;
local ONE_DAY = 24 * ONE_HOUR;
local ONE_MONTH = 30 * ONE_DAY;
local ONE_YEAR = 12 * ONE_MONTH;
-- local ONE_MILLENIUM = 1000 * ONE_YEAR; 	for the future

WHOFRAME_DROPDOWN_LIST = {
	{name = ZONE, sortType = "zone"},
	{name = GUILD, sortType = "guild"},
	{name = RACE, sortType = "race"}
};

FRIENDSFRAME_SUBFRAMES = { "FriendsListFrame", "IgnoreListFrame", "PendingListFrame", "WhoFrame", "ChannelFrame", "RaidFrame" };
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

function FriendsFrame_SummonButton_Update (self)
	local id = self:GetParent().id;
	if ( not id or (self:GetParent().buttonType ~= FRIENDS_BUTTON_TYPE_WOW) or not IsReferAFriendLinked(GetFriendInfo(id)) ) then
		self:Hide();
		return;
	end
	
	self:Show();
	
	local start, duration = GetSummonFriendCooldown();
	
	if ( duration > 0 ) then
		self.duration = duration;
		self.start = start;
	else
		self.duration = nil;
		self.start = nil;
	end
	
	local enable = CanSummonFriend(GetFriendInfo(id));
	
	local icon = _G[self:GetName().."Icon"];
	local normalTexture = _G[self:GetName().."NormalTexture"];
	if ( enable ) then
		icon:SetVertexColor(1.0, 1.0, 1.0);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	else
		icon:SetVertexColor(0.4, 0.4, 0.4);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
	CooldownFrame_SetTimer(_G[self:GetName().."Cooldown"], start, duration, ((enable and 0) or 1));
end

function FriendsFrame_ClickSummonButton (self)
	local name = GetFriendInfo(self:GetParent().id);
	if ( CanSummonFriend(name) ) then
		SummonFriend(name);
	end
end

function FriendsFrame_ShowDropdown(name, connected, lineID, chatType, chatFrame, friendsList, isMobile)
	HideDropDownMenu(1);
	if ( connected or friendsList ) then
		if ( connected ) then
			FriendsDropDown.initialize = FriendsFrameDropDown_Initialize;
		else
			FriendsDropDown.initialize = FriendsFrameOfflineDropDown_Initialize;
		end
		
		FriendsDropDown.displayMode = "MENU";
		FriendsDropDown.name = name;
		FriendsDropDown.friendsList = friendsList;
		FriendsDropDown.lineID = lineID;
		FriendsDropDown.chatType = chatType;
		FriendsDropDown.chatTarget = name;
		FriendsDropDown.chatFrame = chatFrame;
		FriendsDropDown.presenceID = nil;
		FriendsDropDown.isMobile = isMobile;
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor");
	end
end

function FriendsFrame_ShowBNDropdown(name, connected, lineID, chatType, chatFrame, friendsList, presenceID)
	if ( connected or friendsList ) then
		if ( connected ) then
			FriendsDropDown.initialize = FriendsFrameBNDropDown_Initialize;
		else
			FriendsDropDown.initialize = FriendsFrameBNOfflineDropDown_Initialize;
		end
		FriendsDropDown.displayMode = "MENU";
		FriendsDropDown.name = name;
		FriendsDropDown.friendsList = friendsList;
		FriendsDropDown.lineID = lineID;
		FriendsDropDown.chatType = chatType;
		FriendsDropDown.chatTarget = name;
		FriendsDropDown.chatFrame = chatFrame;
		FriendsDropDown.presenceID = presenceID;
		FriendsDropDown.isMobile = nil;
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor");
	end
end

function FriendsFrameDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "FRIEND", nil, FriendsDropDown.name);
end

function FriendsFrameOfflineDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "FRIEND_OFFLINE", nil, FriendsDropDown.name);
end

function FriendsFrameBNDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "BN_FRIEND", nil, FriendsDropDown.name);
end

function FriendsFrameBNOfflineDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "BN_FRIEND_OFFLINE", nil, FriendsDropDown.name);
end

function FriendsFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 4);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
	self:RegisterEvent("FRIENDLIST_SHOW");
	self:RegisterEvent("FRIENDLIST_UPDATE");
	self:RegisterEvent("IGNORELIST_UPDATE");
	self:RegisterEvent("MUTELIST_UPDATE");
	self:RegisterEvent("WHO_LIST_UPDATE");
	self:RegisterEvent("VOICE_CHAT_ENABLED_UPDATE");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	self:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED");
	self:RegisterEvent("BN_FRIEND_INFO_CHANGED");
	self:RegisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED");
	self:RegisterEvent("BN_FRIEND_INVITE_ADDED");
	self:RegisterEvent("BN_FRIEND_INVITE_REMOVED");
	self:RegisterEvent("BN_CUSTOM_MESSAGE_CHANGED");
	self:RegisterEvent("BN_CUSTOM_MESSAGE_LOADED");
	self:RegisterEvent("BN_SELF_ONLINE");
	self:RegisterEvent("BN_BLOCK_LIST_UPDATED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("BN_CONNECTED");
	self:RegisterEvent("BN_DISCONNECTED");
	self:RegisterEvent("BN_INFO_CHANGED");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("BATTLETAG_INVITE_SHOW");
	self.playersInBotRank = 0;
	self.playerStatusFrame = 1;
	self.selectedFriend = 1;
	self.selectedIgnore = 1;
	-- friends list
	local scrollFrame = FriendsFrameFriendsScrollFrame;
	scrollFrame.update = FriendsFrame_UpdateFriends;
	FriendsFrameFriendsScrollFrameScrollBarTrack:Hide();
	FriendsFrameFriendsScrollFrameScrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(scrollFrame, "FriendsFrameButtonTemplate");

	FriendsFrameBroadcastInputClearButton.icon:SetVertexColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);	
	FriendsFrameOfflineHeader:SetParent(FriendsFrameFriendsScrollFrameScrollChild);
	if ( not BNFeaturesEnabled() ) then
		FriendsTabHeaderTab3:Hide();
		FriendsFrameBattlenetFrame:Hide();
		FriendsFrameBroadcastInput:Hide();
	end	
	
	--Create lists of buttons for various subframes
	for i = 2, 19 do
		local button = CreateFrame("Button", "FriendsFrameIgnoreButton"..i, IgnoreListFrame, "FriendsFrameIgnoreButtonTemplate");
		button:SetPoint("TOP", _G["FriendsFrameIgnoreButton"..(i-1)], "BOTTOM");
	end
	for i = 2, 17 do
		local button = CreateFrame("Button", "WhoFrameButton"..i, WhoFrame, "FriendsFrameWhoButtonTemplate");
		button:SetID(i);
		button:SetPoint("TOP", _G["WhoFrameButton"..(i-1)], "BOTTOM");
	end

	
end

function FriendsFrame_OnShow()
	VoiceChat_Toggle();
	FriendsList_Update();
	FriendsFrame_Update();
	UpdateMicroButtons();
	PlaySound("igCharacterInfoTab");
end

function FriendsFrame_Update()
	if ( FriendsFrame.selectedTab == 1 ) then
		ButtonFrameTemplate_ShowButtonBar(FriendsFrame);
		FriendsFrameInset:SetPoint("TOPLEFT", 4, -83);
		FriendsFrameIcon:SetTexture("Interface\\FriendsFrame\\Battlenet-Portrait");
		FriendsTabHeader:Show();
		if ( FriendsTabHeader.selectedTab == 1 ) then
			ShowFriends();
			FriendsFrameTitleText:SetText(FRIENDS_LIST);
			FriendsFrame_ShowSubFrame("FriendsListFrame");
		elseif ( FriendsTabHeader.selectedTab == 3 ) then
			FriendsFrameTitleText:SetText(PENDING_INVITE_LIST);
			FriendsFrame_ShowSubFrame("PendingListFrame");
		else
			if ( IsVoiceChatEnabled() ) then
				FriendsFrameMutePlayerButton:Show();
				FriendsFrameIgnorePlayerButton:SetWidth(110);
				FriendsFrameUnsquelchButton:SetWidth(111);
			else
				FriendsFrameMutePlayerButton:Hide();
				FriendsFrameIgnorePlayerButton:SetWidth(131);
				FriendsFrameUnsquelchButton:SetWidth(134);
			end
			FriendsFrameTitleText:SetText(IGNORE_LIST);
			FriendsFrame_ShowSubFrame("IgnoreListFrame");
			IgnoreList_Update();
		end
	else
		FriendsTabHeader:Hide();
		if ( FriendsFrame.selectedTab == 2 ) then
			ButtonFrameTemplate_ShowButtonBar(FriendsFrame);
			FriendsFrameInset:SetPoint("TOPLEFT", 4, -80);
			FriendsFrameIcon:SetTexture("Interface\\FriendsFrame\\Battlenet-Portrait");
			FriendsFrameTitleText:SetText(WHO_LIST);
			FriendsFrame_ShowSubFrame("WhoFrame");
			WhoList_Update();
		elseif ( FriendsFrame.selectedTab == 3 ) then
			ButtonFrameTemplate_ShowButtonBar(FriendsFrame);
			FriendsFrameInset:SetPoint("TOPLEFT", 4, -60);
			FriendsFrameIcon:SetTexture("Interface\\FriendsFrame\\Battlenet-Portrait");
			FriendsFrameTitleText:SetText(CHAT_CHANNELS);
			FriendsFrame_ShowSubFrame("ChannelFrame");
		elseif ( FriendsFrame.selectedTab == 4 ) then
			ButtonFrameTemplate_ShowButtonBar(FriendsFrame);
			FriendsFrameInset:SetPoint("TOPLEFT", 4, -60);
			FriendsFrameIcon:SetTexture("Interface\\LFGFrame\\UI-LFR-PORTRAIT");
			FriendsFrameTitleText:SetText(RAID);
			ClaimRaidFrame(FriendsFrame);
			FriendsFrame_ShowSubFrame("RaidFrame");
		end
	end
end

function FriendsFrame_OnHide()
	UpdateMicroButtons();
	PlaySound("igMainMenuClose");
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
end

function FriendsTabHeader_ClickTab(tab)
	PanelTemplates_Tab_OnClick(tab, FriendsTabHeader);
	if ( FRIEND_TABS_MAX_WIDTH > 0 ) then
		FriendsTabHeader_ResizeTabs();
	end
	FriendsFrame_Update();
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function FriendsTabHeader_ResizeTabs()
	local selectedIndex = PanelTemplates_GetSelectedTab(FriendsTabHeader);
	if ( not selectedIndex ) then
		return;
	end

	local availableWidth = FRIEND_TABS_MAX_WIDTH;
	local widthPerTab;

	local currentTab = _G["FriendsTabHeaderTab"..selectedIndex];
	PanelTemplates_TabResize(currentTab, 0);
	availableWidth = availableWidth - currentTab:GetWidth();
	widthPerTab = availableWidth / (FriendsTabHeader.numTabs - 1);
	for i = 1, FriendsTabHeader.numTabs do
		if ( i ~= selectedIndex ) then
			PanelTemplates_TabResize(_G["FriendsTabHeaderTab"..i], 0, widthPerTab)
		end
	end
end

function FriendsList_Update()
	local numBNetTotal, numBNetOnline = BNGetNumFriends();
	local numBNetOffline = numBNetTotal - numBNetOnline;
	local numWoWTotal, numWoWOnline = GetNumFriends();
	local numWoWOffline = numWoWTotal - numWoWOnline;
	
	FriendsMicroButtonCount:SetText(numBNetOnline + numWoWOnline);
	if ( not FriendsListFrame:IsShown() ) then
		return;
	end

	local haveHeader;
	local buttonCount = numBNetTotal + numWoWTotal;
	if ( (numBNetOnline > 0 or numWoWOnline > 0) and (numBNetOffline > 0 or numWoWOffline > 0) ) then
		haveHeader = true;
		buttonCount = buttonCount + 1;
	end
	if ( buttonCount > #FriendButtons ) then
		for i = #FriendButtons + 1, buttonCount do
			FriendButtons[i] = { };
		end
	end
	
	local index = 0;
	-- online Battlenet friends
	for i = 1, numBNetOnline do
		index = index + 1;
		FriendButtons[index].buttonType = FRIENDS_BUTTON_TYPE_BNET;
		FriendButtons[index].id = i;
	end
	-- online WoW friends
	for i = 1, numWoWOnline do
		index = index + 1;
		FriendButtons[index].buttonType = FRIENDS_BUTTON_TYPE_WOW;
		FriendButtons[index].id = i;
	end
	-- offline header
	if ( haveHeader ) then
		index = index + 1;
		FriendButtons[index].buttonType = FRIENDS_BUTTON_TYPE_HEADER;
		-- we can have a single button of different height than the others in a hybrid scrollframe
		-- even though the header is smaller than the other buttons, it will still work if we "expand" it
		HybridScrollFrame_ExpandButton(FriendsFrameFriendsScrollFrame, (numBNetOnline + numWoWOnline) * FRIENDS_BUTTON_NORMAL_HEIGHT, FRIENDS_BUTTON_HEADER_HEIGHT);
	else
		HybridScrollFrame_CollapseButton(FriendsFrameFriendsScrollFrame);
	end
	-- offline Battlenet friends
	for i = 1, numBNetOffline do
		index = index + 1;
		FriendButtons[index].buttonType = FRIENDS_BUTTON_TYPE_BNET;
		FriendButtons[index].id = i + numBNetOnline;
	end
	-- offline WoW friends
	for i = 1, numWoWOffline do
		index = index + 1;
		FriendButtons[index].buttonType = FRIENDS_BUTTON_TYPE_WOW;
		FriendButtons[index].id = i + numWoWOnline;		
	end
	FriendButtons.count = index;

	-- selection
	local selectedFriend = 0;
	-- check that we have at least 1 friend
	if ( index > 0 ) then
		-- get friend
		if ( FriendsFrame.selectedFriendType == FRIENDS_BUTTON_TYPE_WOW ) then
			selectedFriend = GetSelectedFriend();
		elseif ( FriendsFrame.selectedFriendType == FRIENDS_BUTTON_TYPE_BNET ) then
			selectedFriend = BNGetSelectedFriend();
		end
		-- set to first in list if no friend
		if ( selectedFriend == 0 ) then
			FriendsFrame_SelectFriend(FriendButtons[1].buttonType, 1);
			selectedFriend = 1;
		end
		-- check if friend is online
		local isOnline;
		if ( FriendsFrame.selectedFriendType == FRIENDS_BUTTON_TYPE_WOW ) then
			local name, level, class, area;
			name, level, class, area, isOnline = GetFriendInfo(selectedFriend);
		elseif ( FriendsFrame.selectedFriendType == FRIENDS_BUTTON_TYPE_BNET ) then
			local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client;
			presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline = BNGetFriendInfo(selectedFriend);
			if ( not presenceName ) then
				isOnline = false;
			end
		end
		if ( isOnline ) then
			FriendsFrameSendMessageButton:Enable();
		else
			FriendsFrameSendMessageButton:Disable();
		end
	else
		FriendsFrameSendMessageButton:Disable();
	end
	FriendsFrame.selectedFriend = selectedFriend;
	FriendsFrame_UpdateFriends();
end

function IgnoreList_Update()
	local button;
	local numIgnores = GetNumIgnores();
	local numBlocks = BNGetNumBlocked();
	local numToonBlocks = BNGetNumBlockedToons();
	local numMutes = 0;
	if ( IsVoiceChatEnabled() ) then
		numMutes = GetNumMutes();
	end
	-- Headers stuff
	local ignoredHeader, blockedHeader, mutedHeader, blockedToonHeader;
	if ( numIgnores > 0 ) then
		ignoredHeader = 1;
	else
		ignoredHeader = 0;
	end	
	if ( numBlocks > 0 ) then
		blockedHeader = 1;
	else
		blockedHeader = 0;
	end
	if ( numToonBlocks > 0 ) then
		blockedToonHeader = 1;
	else
		blockedToonHeader = 0;
	end	
	if ( numMutes > 0 ) then
		mutedHeader = 1;
	else
		mutedHeader = 0;
	end
	
	local lastIgnoredIndex = numIgnores + ignoredHeader;
	local lastBlockedIndex = lastIgnoredIndex + numBlocks + blockedHeader;
	local lastBlockedToonIndex = lastBlockedIndex + numToonBlocks + blockedToonHeader;
	local lastMutedIndex = lastBlockedToonIndex + numMutes + mutedHeader;
	local numEntries = lastMutedIndex;

	FriendsFrameIgnoredHeader:Hide();
	FriendsFrameBlockedInviteHeader:Hide();
	FriendsFrameBlockedToonHeader:Hide();
	FriendsFrameMutedHeader:Hide();
	local numOnline = 0;
	
	-- selection stuff
	local selectedSquelchType = FriendsFrame.selectedSquelchType;
	local selectedSquelchIndex = 0 ;
	if ( selectedSquelchType == SQUELCH_TYPE_IGNORE ) then
		selectedSquelchIndex = GetSelectedIgnore();
	elseif ( selectedSquelchType == SQUELCH_TYPE_BLOCK_INVITE ) then
		selectedSquelchIndex = BNGetSelectedBlock();
	elseif ( selectedSquelchType == SQUELCH_TYPE_BLOCK_TOON ) then
		selectedSquelchIndex = BNGetSelectedToonBlock();
	elseif ( selectedSquelchType == SQUELCH_TYPE_MUTE ) then
		selectedSquelchIndex = GetSelectedMute();
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
		elseif ( numToonBlocks > 0 ) then
			FriendsFrame_SelectSquelched(SQUELCH_TYPE_BLOCK_TOON, 1);
			selectedSquelchType = SQUELCH_TYPE_BLOCK_TOON;
			selectedSquelchIndex = 1;
		elseif ( numMutes > 0 ) then
			FriendsFrame_SelectSquelched(SQUELCH_TYPE_MUTE, 1);
			selectedSquelchType = SQUELCH_TYPE_MUTE;
			selectedSquelchIndex = 1;
		end
	end
	if ( selectedSquelchIndex > 0 ) then
		FriendsFrameUnsquelchButton:Enable();
	else
		FriendsFrameUnsquelchButton:Disable();
	end
	
	local scrollOffset = FauxScrollFrame_GetOffset(FriendsFrameIgnoreScrollFrame);
	local squelchedIndex;
	for i = 1, IGNORES_TO_DISPLAY, 1 do
		squelchedIndex = i + scrollOffset;
		button = _G["FriendsFrameIgnoreButton"..i];
		button.type = nil;
		if ( squelchedIndex == ignoredHeader ) then
			-- ignored header
			IgnoreList_SetHeader(FriendsFrameIgnoredHeader, button);
		elseif ( squelchedIndex <= lastIgnoredIndex ) then
			-- ignored
			button.index = squelchedIndex - ignoredHeader;
			button.name:SetText(GetIgnoreName(button.index));
			button.type = SQUELCH_TYPE_IGNORE;
		elseif ( blockedHeader == 1 and squelchedIndex == lastIgnoredIndex + 1 ) then
			-- blocked header
			IgnoreList_SetHeader(FriendsFrameBlockedInviteHeader, button);
		elseif ( squelchedIndex <= lastBlockedIndex ) then
			-- blocked
			button.index = squelchedIndex - lastIgnoredIndex - blockedHeader;
			local blockID, blockName = BNGetBlockedInfo(button.index);
			button.name:SetText(blockName);
			button.type = SQUELCH_TYPE_BLOCK_INVITE;
		elseif ( blockedToonHeader == 1 and squelchedIndex == lastBlockedIndex + 1 ) then
			-- blocked TOON header
			IgnoreList_SetHeader(FriendsFrameBlockedToonHeader, button);
		elseif ( squelchedIndex <= lastBlockedToonIndex ) then
			-- blocked TOON
			button.index = squelchedIndex - lastBlockedIndex - blockedToonHeader;
			local blockID, blockName = BNGetBlockedToonInfo(button.index);
			button.name:SetText(blockName);
			button.type = SQUELCH_TYPE_BLOCK_TOON;
		elseif ( mutedHeader == 1 and squelchedIndex == lastBlockedToonIndex + 1 ) then
			-- muted header
			IgnoreList_SetHeader(FriendsFrameMutedHeader, button);
		elseif ( squelchedIndex <= lastMutedIndex ) then
			-- muted
			button.index = squelchedIndex - lastBlockedToonIndex - mutedHeader;
			button.name:SetText(GetMuteName(button.index));
			button.type = SQUELCH_TYPE_MUTE;
		end
		if ( selectedSquelchType == button.type and selectedSquelchIndex == button.index ) then
			button:LockHighlight();
			numOnline = numOnline + 1;
		else
			button:UnlockHighlight();
		end
		if ( squelchedIndex > numEntries ) then
			button:Hide();
		else
			button:Show();
		end
	end	
	-- ScrollFrame stuff
	FauxScrollFrame_Update(FriendsFrameIgnoreScrollFrame, numEntries, IGNORES_TO_DISPLAY, FRIENDS_FRAME_IGNORE_HEIGHT );
end

function IgnoreList_SetHeader(header, parent)
	parent.name:SetText("");
	header:SetParent(parent);
	header:SetPoint("TOPLEFT", parent, 0, 0);
	header:Show();
end

function PendingListFrame_OnShow(self)
	PendingList_Update();
end

function PendingList_Update(newInvite)
	local numPending = BNGetNumFriendInvites();

	PendingList_UpdateTab();
	if ( numPending > 0 ) then
		-- RID warning, upon getting the first RID invite
		if ( not GetCVarBool("pendingInviteInfoShown") ) then
			local _, battleTag, _, _, _, _, isRIDEnabled = BNGetInfo();
			if ( isRIDEnabled ) then
				for i = 1, numPending do
					local inviteID, presenceName, isBattleTag = BNGetFriendInviteInfo(i);
					if ( not isBattleTag ) then
						-- found one
						PendingListInfoFrame:SetFrameLevel(FriendsFramePendingButton1:GetFrameLevel() + 1);
						PendingListInfoFrame:Show();
						break;
					end
				end
			end
		end

		local scrollFrame = FriendsFramePendingScrollFrame;
		local buttonHeight, message, _;
		local heightLeft = scrollFrame.scrollHeight;
		local scrollBar = scrollFrame.scrollBar;

		FriendsFramePendingButton1.message:SetHeight(0);
		for i = numPending, 1, -1 do
			buttonHeight = PENDING_BUTTON_MIN_HEIGHT;
			_, _, message = BNGetFriendInviteInfo(i);
			if ( message and message ~= "" ) then
				FriendsFramePendingButton1.message:SetText(message);
				local textHeight = min(FriendsFramePendingButton1.message:GetHeight(), MAX_INVITE_MESSAGE_HEIGHT);
				buttonHeight = buttonHeight + textHeight;
			end
			heightLeft = heightLeft - buttonHeight;
			if ( heightLeft <= 0 ) then
				-- one less notch on the scrollbar if it's a perfect fit
				if ( heightLeft == 0 ) then
					i = i - 1;
				end
				local value = scrollBar:GetValue();
				scrollFrame.extraHeight = -heightLeft;
				scrollFrame.max = i;
				scrollBar:Show();
				scrollBar:SetMinMaxValues(0, i);
				if ( newInvite ) then
					-- adjust the scroll if the user is looking at the frame, otherwise jump it to the top
					if ( PendingListFrame:IsShown() ) then
						scrollBar:SetValue(value + 1);
					else
						scrollBar:SetValue(0)
					end
				elseif ( value <= i ) then
					scrollBar:SetValue(value);
					PendingList_Scroll(value);
				end
				return;
			end
		end
		-- not enough buttons to have a scrollbar
		scrollFrame.extraHeight = 0;
		scrollFrame.max = numPending;
		scrollBar:Hide();
		scrollBar:SetValue(0);
	end
	PendingList_Scroll(0);
end

function PendingList_Scroll(offset)
	local button, buttonHeight;
	local name;
	local heightUsed = 0;
	local scrollFrame = FriendsFramePendingScrollFrame;
	local scrollHeight = scrollFrame.scrollHeight;
	local max = scrollFrame.max;
	local numPending = BNGetNumFriendInvites();
	offset = offset or scrollFrame.scrollBar:GetValue();
	-- if scrolled to the bottom and there would be a button partially showing, start with it and "scroll" it up
	if ( offset == max and scrollFrame.extraHeight > 0 ) then
		offset = offset - 1;
		_G["FriendsFramePendingButton1"]:SetPoint("TOPLEFT", 0, scrollFrame.extraHeight);
		heightUsed = heightUsed - scrollFrame.extraHeight;
	else
		_G["FriendsFramePendingButton1"]:SetPoint("TOPLEFT", 0, 0);
	end
	for i = 1, PENDING_INVITES_TO_DISPLAY do
		button = _G["FriendsFramePendingButton"..i];
		offset = offset + 1;
		if ( offset > numPending or heightUsed > scrollHeight ) then
			button:Hide();
		else
			local inviteID, presenceName, isBattleTag, message, timeSent = BNGetFriendInviteInfo(offset);
			button.index = offset;
			button.inviteID = inviteID;
			buttonHeight = PENDING_BUTTON_MIN_HEIGHT;
			if ( presenceName ) then
				button.name:SetText(presenceName);
			else
				button.name:SetText(UNKNOWN);
			end
			if ( isBattleTag ) then
				button.RIDTag:Hide();
			else
				button.RIDTag:Show();
			end
			if ( message ) then
				button.message:SetHeight(0);
				button.message:SetText(message);
				local textHeight = button.message:GetHeight();
				if ( textHeight > MAX_INVITE_MESSAGE_HEIGHT ) then
					textHeight = MAX_INVITE_MESSAGE_HEIGHT;
					button.message:SetHeight(textHeight);
				end
				buttonHeight = buttonHeight + textHeight;
			else
				button.message:SetText("");
				button.message:SetHeight(0);
			end
			if ( timeSent and timeSent ~= 0 and time() - timeSent < ONE_YEAR ) then
				button.sent:SetFormattedText(BNET_INVITE_SENT_TIME, FriendsFrame_GetLastOnline(timeSent));
			else
				button.sent:SetText("");
			end
			button:SetHeight(buttonHeight);
			heightUsed = heightUsed + buttonHeight;
			if ( PendingInvitesNew["all"] or PendingInvitesNew[inviteID] ) then
				button.highlight:Show();
			else
				button.highlight:Hide();
			end
			button:Show();
		end
	end
end

function FriendsFramePendingScrollFrame_AdjustScroll(delta)
	local scrollBar = FriendsFramePendingScrollFrame.scrollBar;
	if ( scrollBar:IsShown() ) then
		scrollBar:SetValue(scrollBar:GetValue() + delta);
	end
end

function PendingListFrame_OnHide()
	table.wipe(PendingInvitesNew);
	PendingList_UpdateTab();
end
	
function PendingListFrame_BlockCommunication(self)
	local inviteID, presenceName = BNGetFriendInviteInfo(self:GetParent().index);
	local dialog = StaticPopup_Show("CONFIRM_BLOCK_INVITES", presenceName);
	if ( dialog ) then
		dialog.data = inviteID;
	end
end

function PendingListFrame_ReportSpam(self)
	local inviteID, presenceName = BNGetFriendInviteInfo(self:GetParent().index);
	local dialog = StaticPopup_Show("CONFIRM_REPORT_SPAM_INVITE", presenceName);
	if ( dialog ) then
		dialog.data = inviteID;
	end
end

function PendingListFrame_ReportPlayer(self)
	ToggleDropDownMenu(1, self:GetParent().index, PendingListFrameDropDown, "cursor", 3, -3)
end

function PendingListFrameDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, PendingListFrameDropDown_Initialize, "MENU");
end

function PendingListFrameDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "BN_REPORT", nil, BNET_REPORT);
end

function PendingList_UpdateTab()
	local numPending = BNGetNumFriendInvites();
	if ( numPending > 0 ) then
		FriendsTabHeaderTab3:SetText(PENDING_INVITE.." ("..numPending..")");
		if ( next(PendingInvitesNew) and FriendsTabHeader.selectedTab ~= 3 and not FriendsTabHeaderTab3:IsMouseOver() ) then
			FriendsTabHeaderInviteAlert:Show();
		else
			FriendsTabHeaderInviteAlert:Hide();
		end
	else
		FriendsTabHeaderTab3:SetText(PENDING_INVITE);
		FriendsTabHeaderInviteAlert:Hide();
	end
	if ( FRIEND_TABS_MAX_WIDTH == 0 ) then
		PanelTemplates_TabResize(FriendsTabHeaderTab3, 0);
	else
		FriendsTabHeader_ResizeTabs();
	end
end

function WhoList_Update()
	local numWhos, totalCount = GetNumWhoResults();
	local name, guild, level, race, class, zone;
	local button, buttonText, classTextColor, classFileName;
	local columnTable;
	local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame);
	local whoIndex;
	local showScrollBar = nil;
	if ( numWhos > WHOS_TO_DISPLAY ) then
		showScrollBar = 1;
	end
	local displayedText = "";
	if ( totalCount > MAX_WHOS_FROM_SERVER ) then
		displayedText = format(WHO_FRAME_SHOWN_TEMPLATE, MAX_WHOS_FROM_SERVER);
	end
	WhoFrameTotals:SetText(format(WHO_FRAME_TOTAL_TEMPLATE, totalCount).."  "..displayedText);
	for i=1, WHOS_TO_DISPLAY, 1 do
		whoIndex = whoOffset + i;
		button = _G["WhoFrameButton"..i];
		button.whoIndex = whoIndex;
		name, guild, level, race, class, zone, classFileName = GetWhoInfo(whoIndex);
		columnTable = { zone, guild, race };

		if ( classFileName ) then
			classTextColor = RAID_CLASS_COLORS[classFileName];
		else
			classTextColor = HIGHLIGHT_FONT_COLOR;
		end
		buttonText = _G["WhoFrameButton"..i.."Name"];
		buttonText:SetText(name);
		buttonText = _G["WhoFrameButton"..i.."Level"];
		buttonText:SetText(level);
		buttonText = _G["WhoFrameButton"..i.."Class"];
		buttonText:SetText(class);
		buttonText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
		local variableText = _G["WhoFrameButton"..i.."Variable"];
		variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)]);
		
		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			variableText:SetWidth(95);
		else
			variableText:SetWidth(110);
		end

		-- Highlight the correct who
		if ( WhoFrame.selectedWho == whoIndex ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
		
		if ( whoIndex > numWhos ) then
			button:Hide();
		else
			button:Show();
		end
	end

	if ( not WhoFrame.selectedWho ) then
		WhoFrameGroupInviteButton:Disable();
		WhoFrameAddFriendButton:Disable();
	else
		WhoFrameGroupInviteButton:Enable();
		WhoFrameAddFriendButton:Enable();
		WhoFrame.selectedName = GetWhoInfo(WhoFrame.selectedWho); 
	end

	-- If need scrollbar resize columns
	if ( showScrollBar ) then
		WhoFrameColumn_SetWidth(WhoFrameColumnHeader2, 105);
		UIDropDownMenu_SetWidth(WhoFrameDropDown, 80);
	else
		WhoFrameColumn_SetWidth(WhoFrameColumnHeader2, 120);
		UIDropDownMenu_SetWidth(WhoFrameDropDown, 95);
	end

	-- ScrollFrame update
	FauxScrollFrame_Update(WhoListScrollFrame, numWhos, WHOS_TO_DISPLAY, FRIENDS_FRAME_WHO_HEIGHT );

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
	if ( event == "SPELL_UPDATE_COOLDOWN" and self:IsShown() ) then
		local buttons = FriendsFrameFriendsScrollFrame.buttons;
		for _, button in pairs(buttons) do
			if ( button.summonButton:IsShown() ) then
				FriendsFrame_SummonButton_Update(button.summonButton);
			end
		end
	elseif ( event == "FRIENDLIST_SHOW" ) then
		FriendsList_Update();
		FriendsFrame_Update();
	elseif ( event == "FRIENDLIST_UPDATE" or event == "GROUP_ROSTER_UPDATE" ) then
		FriendsList_Update();
	elseif ( event == "BN_FRIEND_LIST_SIZE_CHANGED" or event == "BN_FRIEND_INFO_CHANGED" ) then
		FriendsList_Update();
		-- update Friends of Friends
		local presenceID = ...;
		if ( event == "BN_FRIEND_LIST_SIZE_CHANGED" and presenceID ) then
			FriendsFriendsFrame.requested[presenceID] = nil;
			if ( FriendsFriendsFrame:IsShown() ) then
				FriendsFriendsList_Update();
			end
		end
	elseif ( event == "BN_CUSTOM_MESSAGE_CHANGED" ) then
		local arg1 = ...;
		if ( arg1 ) then	--There is no presenceID given if this is ourself.
			FriendsList_Update();
		else
			FriendsFrameBattlenetFrame_UpdateBroadcast();
		end
	elseif ( event == "BN_CUSTOM_MESSAGE_LOADED" ) then
		FriendsFrameBattlenetFrame_UpdateBroadcast();
	elseif ( event == "BN_FRIEND_INVITE_ADDED" ) then
		local arg1 = ...;
		if ( arg1 ) then
			PendingInvitesNew[arg1] = true;
			PendingList_Update(true);
		end
	elseif ( event == "BN_FRIEND_INVITE_LIST_INITIALIZED" ) then
		PendingInvitesNew["all"] = true;
		PendingList_Update();
	elseif ( event == "BN_FRIEND_INVITE_REMOVED" ) then
		PendingList_Update();
	elseif ( event == "IGNORELIST_UPDATE" or event == "MUTELIST_UPDATE" or event == "BN_BLOCK_LIST_UPDATED" ) then
		IgnoreList_Update();
	elseif ( event == "WHO_LIST_UPDATE" ) then
		WhoList_Update();
		FriendsFrame_Update();
	elseif ( event == "VOICE_CHAT_ENABLED_UPDATE" ) then
		VoiceChat_Toggle();
	elseif ( event == "PLAYER_FLAGS_CHANGED" ) then
		SynchronizeBNetStatus();
		FriendsFrameStatusDropDown_Update();
	elseif ( event == "PLAYER_ENTERING_WORLD" or event == "BN_CONNECTED" or event == "BN_DISCONNECTED" or event == "BN_SELF_ONLINE" or event == "BN_INFO_CHANGED" ) then
		FriendsFrame_CheckBattlenetStatus();
	elseif ( event == "BATTLETAG_INVITE_SHOW" ) then
		BattleTagInviteFrame_Show(...);
	end
end

function FriendsFrameFriendButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		FriendsFrame_SelectFriend(self.buttonType, self.id);
		FriendsList_Update();
		-- if friends of friends frame is being shown, switch list if new selection is another battlenet friend
		if ( FriendsFriendsFrame:IsShown() and self.buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
			local presenceID = BNGetFriendInfo(self.id);
			if ( presenceID ~= FriendsFriendsFrame.presenceID ) then
				FriendsFriendsFrame_Show(presenceID);
			end
		end
	elseif ( button == "RightButton" ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		if ( self.buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
			-- bnet friend
			local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline = BNGetFriendInfo(self.id);
			FriendsFrame_ShowBNDropdown(presenceName, isOnline, nil, nil, nil, 1, presenceID);
		else
			-- wow friend
			local name, level, class, area, connected = GetFriendInfo(self.id);
			FriendsFrame_ShowDropdown(name, connected, nil, nil, nil, 1);
		end
	end
end

function FriendsFrame_SelectFriend(friendType, id)
	if ( friendType == FRIENDS_BUTTON_TYPE_WOW ) then
		SetSelectedFriend(id);
	elseif ( friendType == FRIENDS_BUTTON_TYPE_BNET ) then
		BNSetSelectedFriend(id);
	end
	FriendsFrame.selectedFriendType = friendType;
end

function FriendsFrame_SelectSquelched(ignoreType, index)
	if ( ignoreType == SQUELCH_TYPE_IGNORE ) then
		SetSelectedIgnore(index);
	elseif ( ignoreType == SQUELCH_TYPE_BLOCK_INVITE ) then
		BNSetSelectedBlock(index);
	elseif ( ignoreType == SQUELCH_TYPE_BLOCK_TOON ) then
		BNSetSelectedToonBlock(index);
	elseif ( ignoreType == SQUELCH_TYPE_MUTE ) then
		SetSelectedMute(index);
	end
	FriendsFrame.selectedSquelchType = ignoreType;
end

function FriendsFrameAddFriendButton_OnClick(self)
	if ( UnitIsPlayer("target") and UnitCanCooperate("player", "target") and not GetFriendInfo(UnitName("target")) ) then
		local name, server = UnitName("target");
		if ( server and (not UnitIsSameServer("player", "target")) ) then
			name = name.."-"..server;
		end
		AddFriend(name);
		PlaySound("UChatScrollButton");
	else
		local _, battleTag, _, _, _, _, isRIDEnabled = BNGetInfo();
		if ( ( battleTag or isRIDEnabled ) and BNFeaturesEnabledAndConnected() ) then
			AddFriendEntryFrame_Collapse(true);
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
		name = GetFriendInfo(FriendsFrame.selectedFriend);
		ChatFrame_SendTell(name);
	elseif ( FriendsFrame.selectedFriendType == FRIENDS_BUTTON_TYPE_BNET ) then
		local presenceID;
		presenceID, name = BNGetFriendInfo(FriendsFrame.selectedFriend);
		ChatFrame_SendSmartTell(name);
	end
	if ( name ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
end

function FriendsFrameMuteButton_OnClick(self)
	SetSelectedMute(self:GetID());
	MutedList_Update();
end

function FriendsFrameUnsquelchButton_OnClick(self)
	local selectedSquelchType = FriendsFrame.selectedSquelchType;
	if ( selectedSquelchType == SQUELCH_TYPE_IGNORE ) then
		local name = GetIgnoreName(GetSelectedIgnore());
		DelIgnore(name);
	elseif ( selectedSquelchType == SQUELCH_TYPE_BLOCK_INVITE ) then
		local blockID = BNGetBlockedInfo(BNGetSelectedBlock());
		BNSetBlocked(blockID, false);
	elseif ( selectedSquelchType == SQUELCH_TYPE_BLOCK_TOON ) then
		local blockID = BNGetBlockedToonInfo(BNGetSelectedToonBlock());
		BNSetToonBlocked(blockID, false);
	elseif ( selectedSquelchType == SQUELCH_TYPE_MUTE ) then
		local name = GetMuteName(GetSelectedMute());
		DelMute(name);
	end
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function FriendsFrameWhoButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		WhoFrame.selectedWho = _G["WhoFrameButton"..self:GetID()].whoIndex;
		WhoFrame.selectedName = _G["WhoFrameButton"..self:GetID().."Name"]:GetText();
		WhoList_Update();
	else
		local name = _G["WhoFrameButton"..self:GetID().."Name"]:GetText();
		FriendsFrame_ShowDropdown(name, 1);
	end
end

function FriendsFrame_UnIgnore(button, name)
	DelIgnore(name);
end

function FriendsFrame_UnMute(button, name)
	DelMute(name);
end

function FriendsFrame_UnBlock(button, blockID)
	BNSetBlocked(blockID, false);
end

function FriendsFrame_RemoveFriend()
	if ( FriendsFrame.selectedFriend ) then
		RemoveFriend(FriendsFrame.selectedFriend);
		PlaySound("UChatScrollButton");
	end
end

function FriendsFrame_SendMessage()
	local name = GetFriendInfo(FriendsFrame.selectedFriend);
	ChatFrame_SendTell(name);
	PlaySound("UChatScrollButton");
end

function FriendsFrame_GroupInvite()
	local name = GetFriendInfo(FriendsFrame.selectedFriend);
	InviteToGroup(name);
	PlaySound("UChatScrollButton");
end

function ToggleFriendsFrame(tab)
	if (IsBlizzCon()) then
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
	SendWho(self:GetText());
	self:ClearFocus();
end

function ToggleFriendsPanel()
	if (IsBlizzCon()) then
		return;
	end

	local friendsTabShown =
		FriendsFrame:IsShown() and
		PanelTemplates_GetSelectedTab(FriendsFrame) == 1 and
		FriendsTabHeader.selectedTab == 1;

	if ( friendsTabShown ) then
		HideUIPanel(FriendsFrame);
	else
		PanelTemplates_SetTab(FriendsFrame, 1);
		PanelTemplates_SetTab(FriendsTabHeader, 1);
		ShowUIPanel(FriendsFrame);
	end
end

function ShowWhoPanel()
	PanelTemplates_SetTab(FriendsFrame, 2);
	if ( FriendsFrame:IsShown() ) then
		FriendsFrame_OnShow();
	else
		ShowUIPanel(FriendsFrame);
	end
end

function ToggleIgnorePanel()
	if (IsBlizzCon()) then
		return;
	end

	local ignoreTabShown =
		FriendsFrame:IsShown() and
		PanelTemplates_GetSelectedTab(FriendsFrame) == 1 and
		FriendsTabHeader.selectedTab == 2;

	if ( ignoreTabShown ) then
		HideUIPanel(FriendsFrame);
	else
		PanelTemplates_SetTab(FriendsFrame, 1);
		PanelTemplates_SetTab(FriendsTabHeader, 2);
		FriendsFrame_Update();
		ShowUIPanel(FriendsFrame);
	end
end

function WhoFrame_GetDefaultWhoCommand()
	local level = UnitLevel("player");
	local minLevel = level-3;
	if ( minLevel <= 0 ) then
		minLevel = 1;
	end
	local maxLevel = min(level + 3, GetMaxPlayerLevel());
	local command = WHO_TAG_ZONE.."\""..GetRealZoneText().."\" "..minLevel.."-"..maxLevel;
	return command;
end

function FriendsFrame_GetLastOnline(timeDifference, isAbsolute)
	if ( not isAbsolute ) then
		timeDifference = time() - timeDifference;
	end
	local year, month, day, hour, minute;

	if ( timeDifference < ONE_MINUTE ) then
		return LASTONLINE_SECS;
	elseif ( timeDifference >= ONE_MINUTE and timeDifference < ONE_HOUR ) then
		return format(LASTONLINE_MINUTES, floor(timeDifference / ONE_MINUTE));
	elseif ( timeDifference >= ONE_HOUR and timeDifference < ONE_DAY ) then
		return format(LASTONLINE_HOURS, floor(timeDifference / ONE_HOUR));
	elseif ( timeDifference >= ONE_DAY and timeDifference < ONE_MONTH ) then
		return format(LASTONLINE_DAYS, floor(timeDifference / ONE_DAY));
	elseif ( timeDifference >= ONE_MONTH and timeDifference < ONE_YEAR ) then
		return format(LASTONLINE_MONTHS, floor(timeDifference / ONE_MONTH));
	else
		return format(LASTONLINE_YEARS, floor(timeDifference / ONE_YEAR));
	end
end

-- Battle.net stuff starts here

function FriendsFrame_CheckBattlenetStatus()
	if ( BNFeaturesEnabled() ) then
		local frame = FriendsFrameBattlenetFrame;
		if ( BNConnected() ) then
			playerRealmName = GetRealmName();
			playerFactionGroup = UnitFactionGroup("player");
			FriendsFrameBattlenetFrame_UpdateBroadcast();
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
				FriendsFrameBroadcastInput:Hide();
			else
				frame:Hide();
				FriendsFrameBroadcastInput:Show();
				FriendsFrameBroadcastInput_UpdateDisplay();
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
			FriendsFrameBroadcastInput:Hide();
		end
		if ( FriendsFrame:IsShown() ) then
			IgnoreList_Update();
			PendingList_Update();
		end
		-- has its own check if it is being shown, after it updates the count on the FriendsMicroButton
		FriendsList_Update();
	end
end

function FriendsFrame_UpdateFriends()
	local scrollFrame = FriendsFrameFriendsScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numFriendButtons = FriendButtons.count;
	
	local nameText, nameColor, infoText, broadcastText;	

	local height;
	local usedHeight = 0;

	local hasTravelPass = HasTravelPass();
	local hasTravelPassButton;
	local canInvite = FriendsFrame_HasInvitePermission();

	FriendsFrameOfflineHeader:Hide();
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i;
		if ( index <= numFriendButtons ) then
			button.buttonType = FriendButtons[index].buttonType;
			button.id = FriendButtons[index].id;
			height = FRIENDS_BUTTON_NORMAL_HEIGHT;
			hasTravelPassButton = false;
			if ( FriendButtons[index].buttonType == FRIENDS_BUTTON_TYPE_WOW ) then
				local name, level, class, area, connected, status, note = GetFriendInfo(FriendButtons[index].id);
				broadcastText = nil;
				if ( connected ) then
					button.background:SetTexture(FRIENDS_WOW_BACKGROUND_COLOR.r, FRIENDS_WOW_BACKGROUND_COLOR.g, FRIENDS_WOW_BACKGROUND_COLOR.b, FRIENDS_WOW_BACKGROUND_COLOR.a);
					if ( status == "" ) then
						button.status:SetTexture(FRIENDS_TEXTURE_ONLINE);
					elseif ( status == CHAT_FLAG_AFK ) then
						button.status:SetTexture(FRIENDS_TEXTURE_AFK);
					elseif ( status == CHAT_FLAG_DND ) then
						button.status:SetTexture(FRIENDS_TEXTURE_DND);
					end
					nameText = name..", "..format(FRIENDS_LEVEL_TEMPLATE, level, class);
					nameColor = FRIENDS_WOW_NAME_COLOR;
				else
					button.background:SetTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
					button.status:SetTexture(FRIENDS_TEXTURE_OFFLINE);
					nameText = name;
					nameColor = FRIENDS_GRAY_COLOR;
				end
				infoText = area;
				button.gameIcon:Hide();
				FriendsFrame_SummonButton_Update(button.summonButton);
			elseif ( FriendButtons[index].buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
				local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, canSoR = BNGetFriendInfo(FriendButtons[index].id);
				broadcastText = messageText;
				-- set up player name and character name
				local characterName = toonName;
				if ( presenceName ) then
					nameText = presenceName;
					-- if no character name but we have a BattleTag, use that
					if ( isOnline and not characterName and battleTag ) then
						characterName = battleTag;
					end
				elseif ( givenName ) then
					nameText = givenName;
				else
					nameText = UNKNOWN;				
				end

				-- append toon
				if ( characterName ) then
					if ( client == BNET_CLIENT_WOW and CanCooperateWithToon(toonID, hasTravelPass) ) then
						nameText = nameText.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..characterName..")";
					else
						if ( ENABLE_COLORBLIND_MODE == "1" ) then
							characterName = characterName..CANNOT_COOPERATE_LABEL;
						end
						nameText = nameText.." "..FRIENDS_OTHER_NAME_COLOR_CODE.."("..characterName..")";
					end
				end

				if ( isOnline ) then
					local _, _, _, realmName, realmID, faction, _, _, _, zoneName, _, gameText = BNGetToonInfo(toonID);
					button.background:SetTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a);
					if ( isAFK ) then
						button.status:SetTexture(FRIENDS_TEXTURE_AFK);
					elseif ( isDND ) then
						button.status:SetTexture(FRIENDS_TEXTURE_DND);
					else
						button.status:SetTexture(FRIENDS_TEXTURE_ONLINE);
					end
					if ( client == BNET_CLIENT_WOW ) then
						if ( not zoneName or zoneName == "" ) then
							infoText = UNKNOWN;
						else
							infoText = zoneName;
						end
					else
						infoText = gameText;
					end
					button.gameIcon:SetTexture(BNet_GetClientTexture(client));
					nameColor = FRIENDS_BNET_NAME_COLOR;
					button.gameIcon:Show();
					-- travel pass
					if ( hasTravelPass ) then
						hasTravelPassButton = true;
						local restriction = FriendsFrame_GetInviteRestriction(button.id, canInvite);
						if ( restriction == INVITE_RESTRICTION_NONE ) then
							button.travelPassButton:Enable();
						else
							button.travelPassButton:Disable();
						end
					end
				else
					button.background:SetTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
					button.status:SetTexture(FRIENDS_TEXTURE_OFFLINE);
					nameColor = FRIENDS_GRAY_COLOR;
					button.gameIcon:Hide();
					if ( not lastOnline or lastOnline == 0 or time() - lastOnline >= ONE_YEAR ) then
						infoText = FRIENDS_LIST_OFFLINE;
					else
						infoText = string.format(BNET_LAST_ONLINE_TIME, FriendsFrame_GetLastOnline(lastOnline));
					end
				end
				FriendsFrame_SummonButton_Update(button.summonButton);
			else	-- header
				FriendsFrameOfflineHeader:Show();
				FriendsFrameOfflineHeader:SetAllPoints(button);
				height = FRIENDS_BUTTON_HEADER_HEIGHT;
				nameText = nil;
			end
			-- travel pass?
			if ( hasTravelPassButton ) then
				button.travelPassButton:Show();
				button.gameIcon:SetPoint("TOPRIGHT", -21, -2);
			else
				button.travelPassButton:Hide();
				button.gameIcon:SetPoint("TOPRIGHT", -2, -2);
			end
			-- selection
			if ( FriendsFrame.selectedFriendType == FriendButtons[index].buttonType and FriendsFrame.selectedFriend == FriendButtons[index].id ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
			-- finish setting up button if it's not a header
			if ( nameText ) then
				button.name:SetText(nameText);
				button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b);
				button.info:SetText(infoText);
				button:Show();
			else
				button:Hide();
			end
			-- update the tooltip if hovering over a button
			if ( FriendsTooltip.button == button ) then
				FriendsFrameTooltip_Show(button);
			end
			-- set heights
			button:SetHeight(height);
			usedHeight = usedHeight + height;
			if ( GetMouseFocus() == button ) then
				FriendsFrameTooltip_Show(button);
			end
		else
			button:Hide();
		end
	end
	local headerHeight = scrollFrame.largeButtonHeight or 0;
	local totalHeight = numFriendButtons * FRIENDS_BUTTON_NORMAL_HEIGHT - headerHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, usedHeight);
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
	if ( IsChatAFK() ) then
		status = FRIENDS_TEXTURE_AFK;
	elseif ( IsChatDND() ) then
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
	if ( status == FRIENDS_TEXTURE_ONLINE ) then
		if ( IsChatAFK() ) then
			SendChatMessage("", "AFK");
		elseif ( IsChatDND() ) then
			SendChatMessage("", "DND");
		end
	elseif ( status == FRIENDS_TEXTURE_AFK ) then
		if ( not IsChatAFK() ) then
			SendChatMessage("", "AFK");
		end
	elseif ( status == FRIENDS_TEXTURE_DND ) then
		if ( not IsChatDND() ) then
			SendChatMessage("", "DND");
		end
	end
end

function FriendsFrameBroadcastInput_OnEnterPressed(self)
	local broadcastText = self:GetText()
	BNSetCustomMessage(broadcastText);
	FriendsFrameBroadcastInput_UpdateDisplay(self, broadcastText);
end

function FriendsFrameBroadcastInput_OnEscapePressed(self)
	FriendsFrameBroadcastInput_UpdateDisplay(self);
end

function FriendsFrameBroadcastInput_OnClearPressed(self)
	BNSetCustomMessage("");
	FriendsFrameBroadcastInput_UpdateDisplay(nil, "");
end

function FriendsFrameBroadcastInput_UpdateDisplay(self, broadcastText)
	local _;
	self = self or FriendsFrameBroadcastInput;
	if ( not broadcastText ) then
		_, _, _, broadcastText = BNGetInfo();
		broadcastText = broadcastText or "";
	end
	self:ClearFocus();
	self:SetText(broadcastText);
	if ( broadcastText ~= "" ) then
		self.icon:SetAlpha(1);
		self:SetCursorPosition(0);
		self.clear:Show();
		self:SetTextInsets(0, 18, 0, 0);
	else
		self.icon:SetAlpha(0.35);
		self.clear:Hide();
		self:SetTextInsets(0, 10, 0, 0);
	end
end

function FriendsFrameBattlenetFrame_ShowBroadcastFrame()
	FriendsFrameBattlenetFrame.BroadcastFrame:Show();
	FriendsFrameBattlenetFrame.BroadcastFrame.ScrollFrame.EditBox:SetFocus();
	FriendsFrameBattlenetFrame.BroadcastButton:SetNormalTexture("Interface\\FriendsFrame\\broadcast-hover");
	FriendsFrameBattlenetFrame.BroadcastButton:SetPushedTexture("Interface\\FriendsFrame\\broadcast-pressed-hover");	
end

function FriendsFrameBattlenetFrame_HideBroadcastFrame()
	FriendsFrameBattlenetFrame.BroadcastFrame:Hide();
	FriendsFrameBattlenetFrame.BroadcastButton:SetNormalTexture("Interface\\FriendsFrame\\broadcast-normal");
	FriendsFrameBattlenetFrame.BroadcastButton:SetPushedTexture("Interface\\FriendsFrame\\broadcast-press");
end

function FriendsFrameBattlenetFrame_HideSubFrames()
	FriendsFrameBattlenetFrame_HideBroadcastFrame();
	FriendsFrameBattlenetFrame.UnavailableInfoFrame:Hide();
end

function FriendsFrameBattlenetFrame_UpdateBroadcast(newBroadcastText)
	local _, battleTag, _, broadcastText = BNGetInfo();
	broadcastText = newBroadcastText or broadcastText or "";

	if ( battleTag ) then
		local editBox = FriendsFrameBattlenetFrame.BroadcastFrame.ScrollFrame.EditBox;
		editBox:SetText(broadcastText);
		if ( broadcastText == "" ) then
			editBox.PromptText:Show();
		else
			editBox.PromptText:Hide();
		end
	else
		FriendsFrameBroadcastInput_UpdateDisplay(nil, broadcastText);
	end
end

function FriendsFrameBattlenetFrame_SetBroadcast()
	local newBroadcastText = FriendsFrameBattlenetFrame.BroadcastFrame.ScrollFrame.EditBox:GetText();
	local _, _, _, broadcastText = BNGetInfo();
	if ( newBroadcastText ~= broadcastText ) then
		BNSetCustomMessage(newBroadcastText);
	end
	FriendsFrameBattlenetFrame_HideBroadcastFrame();
end

function FriendsFrameTooltip_Show(self)
	if ( self.buttonType == FRIENDS_BUTTON_TYPE_HEADER ) then
		return;
	end
	local anchor, text;
	local FRIENDS_TOOLTIP_WOW_INFO_TEMPLATE = NORMAL_FONT_COLOR_CODE..FRIENDS_LIST_ZONE.."|r%1$s|n"..NORMAL_FONT_COLOR_CODE..FRIENDS_LIST_REALM.."|r%2$s";
	local numToons = 0;
	local tooltip = FriendsTooltip;	
	tooltip.height = 0;
	tooltip.maxWidth = 0;
	
	if ( self.buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
		local nameText;
		local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, broadcastText, noteText, isFriend, broadcastTime = BNGetFriendInfo(self.id);
		-- account name
		if ( presenceName ) then
			nameText = presenceName;
		else
			nameText = UNKNOWN;
		end
		anchor = FriendsFrameTooltip_SetLine(FriendsTooltipHeader, nil, nameText);
		-- toon 1
		if ( toonID ) then
			local hasFocus, toonName, client, realmName, realmID, faction, race, class, guild, zoneName, level, gameText = BNGetToonInfo(toonID);
			level = level or "";
			race = race or "";
			class = class or "";
			if ( client == BNET_CLIENT_WOW ) then
				if ( CanCooperateWithToon(toonID, HasTravelPass()) ) then
					text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, toonName, level, race, class);
				else
					text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, toonName..CANNOT_COOPERATE_LABEL, level, race, class);
				end
				FriendsFrameTooltip_SetLine(FriendsTooltipToon1Name, nil, text);
				anchor = FriendsFrameTooltip_SetLine(FriendsTooltipToon1Info, nil, string.format(FRIENDS_TOOLTIP_WOW_INFO_TEMPLATE, zoneName, realmName), -4);
			else
				FriendsFrameTooltip_SetLine(FriendsTooltipToon1Name, nil, toonName);
				anchor = FriendsFrameTooltip_SetLine(FriendsTooltipToon1Info, nil, gameText, -4);
			end
		else
			FriendsTooltipToon1Info:Hide();
			FriendsTooltipToon1Name:Hide();
		end
		-- note
		if ( noteText and noteText ~= "" ) then
			FriendsTooltipNoteIcon:Show();
			anchor = FriendsFrameTooltip_SetLine(FriendsTooltipNoteText, anchor, noteText, -8);
		else
			FriendsTooltipNoteIcon:Hide();
			FriendsTooltipNoteText:Hide();
		end
		-- broadcast
		if ( broadcastText and broadcastText ~= "" ) then
			FriendsTooltipBroadcastIcon:Show();
			if ( time() - broadcastTime < ONE_YEAR ) then
				broadcastText = broadcastText.."|n"..FRIENDS_BROADCAST_TIME_COLOR_CODE..string.format(BNET_BROADCAST_SENT_TIME, FriendsFrame_GetLastOnline(broadcastTime));
			end
			anchor = FriendsFrameTooltip_SetLine(FriendsTooltipBroadcastText, anchor, broadcastText, -8);
		else
			FriendsTooltipBroadcastIcon:Hide();
			FriendsTooltipBroadcastText:Hide();
		end
		if ( isOnline ) then
			FriendsTooltipHeader:SetTextColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
			FriendsTooltipLastOnline:Hide();
			numToons = BNGetNumFriendToons(self.id);
		else
			FriendsTooltipHeader:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
			if ( not lastOnline or lastOnline == 0 or time() - lastOnline >= ONE_YEAR ) then
				text = FRIENDS_LIST_OFFLINE;
			else
				text = string.format(BNET_LAST_ONLINE_TIME, FriendsFrame_GetLastOnline(lastOnline));
			end
			anchor = FriendsFrameTooltip_SetLine(FriendsTooltipLastOnline, anchor, text, -4);
		end
	elseif ( self.buttonType == FRIENDS_BUTTON_TYPE_WOW ) then
		local name, level, class, area, connected, status, noteText = GetFriendInfo(self.id);
		anchor = FriendsFrameTooltip_SetLine(FriendsTooltipHeader, nil, name);
		if ( connected ) then
			FriendsTooltipHeader:SetTextColor(FRIENDS_WOW_NAME_COLOR.r, FRIENDS_WOW_NAME_COLOR.g, FRIENDS_WOW_NAME_COLOR.b);
			FriendsFrameTooltip_SetLine(FriendsTooltipToon1Name, nil, string.format(FRIENDS_LEVEL_TEMPLATE, level, class));
			anchor = FriendsFrameTooltip_SetLine(FriendsTooltipToon1Info, nil, area);
		else
			FriendsTooltipHeader:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
			FriendsTooltipToon1Name:Hide();
			FriendsTooltipToon1Info:Hide();
		end
		if ( noteText ) then
			FriendsTooltipNoteIcon:Show();
			anchor = FriendsFrameTooltip_SetLine(FriendsTooltipNoteText, anchor, noteText, -8);
		else
			FriendsTooltipNoteIcon:Hide();
			FriendsTooltipNoteText:Hide();
		end
		FriendsTooltipBroadcastIcon:Hide();
		FriendsTooltipBroadcastText:Hide();
		FriendsTooltipLastOnline:Hide();
	end
	
	-- other toons
	local toonIndex = 1;
	local toonNameString;
	local toonInfoString;
	if ( numToons > 1 ) then
		FriendsFrameTooltip_SetLine(FriendsTooltipOtherToons, anchor, nil, -8);
		for i = 1, numToons do
			local hasFocus, toonName, client, realmName, realmID, faction, race, class, guild, zoneName, level, gameText = BNGetFriendToonInfo(self.id, i);
			-- the focused toon is already at the top of the tooltip
			if ( not hasFocus ) then
				toonIndex = toonIndex + 1;
				if ( toonIndex > FRIENDS_TOOLTIP_MAX_TOONS ) then
					break;
				end
				toonNameString = _G["FriendsTooltipToon"..toonIndex.."Name"];
				toonInfoString = _G["FriendsTooltipToon"..toonIndex.."Info"];
				if ( client == BNET_CLIENT_WOW ) then
					if ( realmName == playerRealmName and faction == playerFactionGroup ) then
						text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, toonName, level, race, class);
					else
						text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, toonName..CANNOT_COOPERATE_LABEL, level, race, class);
					end
					gameText = zoneName;
				else
					text = toonName;
				end
				FriendsFrameTooltip_SetLine(toonNameString, nil, text);
				FriendsFrameTooltip_SetLine(toonInfoString, nil, gameText);
			end
		end
	else
		FriendsTooltipOtherToons:Hide();
	end
	for i = toonIndex + 1, FRIENDS_TOOLTIP_MAX_TOONS do
		toonNameString = _G["FriendsTooltipToon"..i.."Name"];
		toonInfoString = _G["FriendsTooltipToon"..i.."Info"];
		toonNameString:Hide();
		toonInfoString:Hide();
	end
	if ( numToons > FRIENDS_TOOLTIP_MAX_TOONS ) then
		FriendsFrameTooltip_SetLine(FriendsTooltipToonMany, nil, string.format(FRIENDS_TOOLTIP_TOO_MANY_CHARACTERS, numToons - FRIENDS_TOOLTIP_MAX_TOONS), 0);
	else
		FriendsTooltipToonMany:Hide();
	end

	tooltip.button = self;
	tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 36, 0);
	tooltip:SetHeight(tooltip.height + FRIENDS_TOOLTIP_MARGIN_WIDTH);
	tooltip:SetWidth(min(FRIENDS_TOOLTIP_MAX_WIDTH, tooltip.maxWidth + FRIENDS_TOOLTIP_MARGIN_WIDTH));
	tooltip:Show();
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
	PlaySound("igMainMenuOpen");
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
	PlaySound("igMainMenuOpen");
end

function AddFriendNameEditBox_OnTextChanged(self, userInput)
	if ( not AutoCompleteEditBox_OnTextChanged(self, userInput) ) then
		local text = self:GetText();
		if ( text ~= "" ) then
			AddFriendNameEditBoxFill:Hide();
			if ( AddFriendFrame.BNconnected ) then
				if ( AddFriendFrame_IsValidBattlenetName(text) ) then
					AddFriendEntryFrame_Expand();
				else
					AddFriendEntryFrame_Collapse();
				end
			end
			AddFriendEntryFrameAcceptButton:Enable();
		else
			AddFriendEntryFrame_Collapse();
			AddFriendNameEditBoxFill:Show();
			AddFriendEntryFrameAcceptButton:Disable();
		end
	end
end

function AddFriendEntryFrame_Expand()
	AddFriendEntryFrame:SetHeight(ADDFRIENDFRAME_BNETHEIGHT);
	AddFriendFrame:SetHeight(ADDFRIENDFRAME_BNETHEIGHT);
	AddFriendNoteFrame:Show();
	AddFriendEntryFrameAcceptButton:SetText(SEND_REQUEST);
	AddFriendEntryFrameRightTitle:SetAlpha(0.35);
	AddFriendEntryFrameRightDescription:SetAlpha(0.35);
	AddFriendEntryFrameRightIcon:SetVertexColor(.4, .4, .4);
	AddFriendEntryFrameRightFriend:SetVertexColor(.4, .4, .4);
	AddFriendEntryFrameLeftIcon:SetAlpha(1);
	AddFriendEntryFrameOrLabel:SetVertexColor(.3, .3, .3);
end

function AddFriendEntryFrame_Collapse(clearText)
	AddFriendEntryFrame:SetHeight(ADDFRIENDFRAME_WOWHEIGHT);
	AddFriendFrame:SetHeight(ADDFRIENDFRAME_WOWHEIGHT);
	AddFriendNoteFrame:Hide();
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
		AddFriendNoteEditBox:SetText("");
	end
end

function AddFriendFrame_Accept()
	local name = AddFriendNameEditBox:GetText();
	if ( AddFriendFrame_IsValidBattlenetName(name) and AddFriendFrame.BNconnected ) then
		BNSendFriendInvite(name, AddFriendNoteEditBox:GetText());
	else
		AddFriend(name);
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
	FriendsFriendsScrollFrameScrollBar:SetValue(0);
	FriendsFriendsList_Update();
end

function FriendsFriendsList_Update()
	if ( FriendsFriendsWaitFrame:IsShown() ) then
		return;
	end
	
	local friendsButton, friendsIndex;
	local showMutual, showPotential;
	local view = FriendsFriendsFrame.view;
	local selection = FriendsFriendsFrame.selection;
	local requested = FriendsFriendsFrame.requested;
	local presenceID = FriendsFriendsFrame.presenceID;
	local numFriendsFriends = 0;
	local numMutual, numPotential = BNGetNumFOF(presenceID);
	local offset = FauxScrollFrame_GetOffset(FriendsFriendsScrollFrame);
	local haveSelection;
	if ( view == FRIENDS_FRIENDS_POTENTIAL or view == FRIENDS_FRIENDS_ALL ) then
		showPotential = true;
		numFriendsFriends = numFriendsFriends + numPotential;
	end
	if ( view == FRIENDS_FRIENDS_MUTUAL or view == FRIENDS_FRIENDS_ALL ) then
		showMutual = true;
		numFriendsFriends = numFriendsFriends + numMutual;
	end
	for i = 1, FRIENDS_FRIENDS_TO_DISPLAY, 1 do
		friendsIndex = i + offset;
		friendsButton = _G["FriendsFriendsButton"..i];
		if ( friendsIndex > numFriendsFriends ) then
			friendsButton:Hide();
		else
			local friendID, presenceName, isMutual = BNGetFOFInfo(showMutual, showPotential, friendsIndex);
			if ( isMutual ) then
				friendsButton:Disable();
				if ( view ~= FRIENDS_FRIENDS_MUTUAL ) then
					friendsButton.name:SetText(presenceName.." "..HIGHLIGHT_FONT_COLOR_CODE..FRIENDS_FRIENDS_MUTUAL_TEXT);
				else
					friendsButton.name:SetText(presenceName);
				end
				friendsButton.name:SetTextColor(GRAY_FONT_COLOR	.r, GRAY_FONT_COLOR	.g, GRAY_FONT_COLOR	.b);
			elseif ( requested[friendID] ) then
				friendsButton.name:SetText(presenceName.." "..HIGHLIGHT_FONT_COLOR_CODE..FRIENDS_FRIENDS_REQUESTED_TEXT);
				friendsButton:Disable();
				friendsButton.name:SetTextColor(GRAY_FONT_COLOR	.r, GRAY_FONT_COLOR	.g, GRAY_FONT_COLOR	.b);
			else
				friendsButton.name:SetText(presenceName);
				friendsButton:Enable();
				friendsButton.name:SetTextColor(BATTLENET_FONT_COLOR.r, BATTLENET_FONT_COLOR.g, BATTLENET_FONT_COLOR.b);
				if ( selection == friendID ) then
					haveSelection = true;
					friendsButton:LockHighlight();
				else
					friendsButton:UnlockHighlight();
				end
			end
			friendsButton.friendID = friendID;
			friendsButton:Show();
		end		
	end
	if ( haveSelection ) then
		FriendsFriendsSendRequestButton:Enable();
	else
		FriendsFriendsSendRequestButton:Disable();
	end
	FauxScrollFrame_Update(FriendsFriendsScrollFrame, numFriendsFriends, FRIENDS_FRIENDS_TO_DISPLAY, FRIENDS_FRAME_FRIENDS_FRIENDS_HEIGHT);
end

function FriendsFriendsButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	FriendsFriendsFrame.selection = self.friendID;
	FriendsFriendsList_Update();
end

function FriendsFrameIgnoreButton_OnClick(self)
	FriendsFrame_SelectSquelched(self.type, self.index);
	IgnoreList_Update();
end

function FriendsFriendsFrame_SendRequest()
	PlaySound("igCharacterInfoTab");
	FriendsFriendsFrame.requested[FriendsFriendsFrame.selection] = true;
	BNSendFriendInviteByID(FriendsFriendsFrame.selection, FriendsFriendsNoteEditBox:GetText());
	FriendsFriendsFrame_Reset();
	FriendsFriendsList_Update();
end

function FriendsFriendsFrame_Close()
	StaticPopupSpecial_Hide(FriendsFriendsFrame);
end

function FriendsFriendsFrame_OnEvent(self, event)
	if ( event == "BN_REQUEST_FOF_SUCCEEDED" ) then
		if ( self:IsShown() ) then
			FriendsFriendsFrame.view = FRIENDS_FRIENDS_ALL;
			UIDropDownMenu_EnableDropDown(FriendsFriendsFrameDropDown);
			UIDropDownMenu_Initialize(FriendsFriendsFrameDropDown, FriendsFriendsFrameDropDown_Initialize);
			UIDropDownMenu_SetSelectedValue(FriendsFriendsFrameDropDown, FRIENDS_FRIENDS_ALL);
			local waitFrame = FriendsFriendsWaitFrame;
			-- need to stop the flashing because it's flashing with showWhenDone set to true
			if ( UIFrameIsFlashing(waitFrame) ) then
				UIFrameFlashStop(waitFrame);
			end
			waitFrame:Hide();
			FriendsFriendsList_Update();
		end	
	elseif ( event == "BN_REQUEST_FOF_FAILED" ) then
		-- FIX ME - need an error here
	elseif ( event == "BN_DISCONNECTED" ) then
		FriendsFriendsFrame_Close();
	end
end

function FriendsFriendsFrame_Reset()
	FriendsFriendsSendRequestButton:Disable();
	FriendsFriendsNoteEditBox:SetText("");
	FriendsFriendsNoteEditBox:ClearFocus();
	FriendsFriendsFrame.selection = nil;
end

function FriendsFriendsFrame_Show(presenceID)
	local presenceID, presenceName = BNGetFriendInfoByID(presenceID);
	-- bail if that presenceID is not valid anymore
	if ( not presenceID ) then
		return;
	end
	FriendsFriendsFrameTitle:SetFormattedText(FRIENDS_FRIENDS_HEADER, FRIENDS_BNET_NAME_COLOR_CODE..presenceName);
	FriendsFriendsFrame.presenceID = presenceID;
	UIDropDownMenu_DisableDropDown(FriendsFriendsFrameDropDown);
	FriendsFriendsFrame_Reset();
	FriendsFriendsWaitFrame:Show();
	for i = 1, FRIENDS_FRIENDS_TO_DISPLAY, 1 do
		_G["FriendsFriendsButton"..i]:Hide();
	end
	FauxScrollFrame_Update(FriendsFriendsScrollFrame, 0, FRIENDS_FRIENDS_TO_DISPLAY, FRIENDS_FRAME_FRIENDS_FRIENDS_HEIGHT);
	StaticPopupSpecial_Show(FriendsFriendsFrame);
	BNRequestFOFInfo(presenceID);
end

function FriendsFrame_BattlenetInvite(button, presenceID)
	-- no button means click from UnitPopup dropdown, find the friend index by presenceID
	local index;
	if ( not button ) then
		index = BNGetFriendIndex(presenceID);
	else
		index = button.id;
	end
	if ( index ) then
		local numToons = BNGetNumFriendToons(index);
		if ( numToons > 1 ) then
			-- if no button, now find the physical friend button to anchor the dropdown
			-- it might not exist if the list was scrolled
			if ( not button ) then
				local buttons = FriendsFrameFriendsScrollFrame.buttons;
				for i = 1, #buttons do
					if ( buttons[i].id == index and buttons[i].buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
						button = buttons[i];
						break;
					end
				end
			end
			
			PlaySound("igMainMenuOptionCheckBoxOn");
			local dropDown = TravelPassDropDown;
			if ( dropDown.index ~= index ) then
				CloseDropDownMenus();
			end
			dropDown.index = index;
			-- show dropdown at the button if one was passed in or we found it
			if ( button ) then
				ToggleDropDownMenu(1, nil, dropDown, button.travelPassButton, 20, 34);
			else
				ToggleDropDownMenu(1, nil, dropDown, "cursor", 1, -1);
			end
		else
			local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID = BNGetFriendInfo(index);
			if ( toonID ) then
				BNInviteFriend(toonID);
			end
		end	
	end
end

function CanCooperateWithToon(presenceID, hasTravelPass)
	local hasFocus, toonName, client, realmName, realmID, faction = BNGetToonInfo(presenceID);
	if ( hasTravelPass ) then
		if ( realmID > 0 and faction == playerFactionGroup ) then
			return true;
		end
	else
		if ( realmName == playerRealmName and faction == playerFactionGroup ) then
			return true;
		end
	end
	return false;
end

--
-- travel pass
--

function CanGroupWithAccount(presenceID)
	if ( HasTravelPass() ) then
		local index = BNGetFriendIndex(presenceID);
		local restriction = FriendsFrame_GetInviteRestriction(index, FriendsFrame_HasInvitePermission());
		return (restriction == INVITE_RESTRICTION_NONE);
	else
		return CanCooperateWithToon(presenceID, false);
	end
end

function FriendsFrame_HasInvitePermission()
	if ( IsInGroup() ) then
		if ( not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") ) then
			return false;
		end
	end
	return true;
end

function FriendsFrame_GetInviteRestriction(index, canInvite)
	local restriction = INVITE_RESTRICTION_NO_TOONS;
	local numToons = BNGetNumFriendToons(index);
	for i = 1, numToons do
		local hasFocus, toonName, client, realmName, realmID, faction = BNGetFriendToonInfo(index, i);
		if ( client == BNET_CLIENT_WOW ) then
			if ( faction ~= playerFactionGroup ) then
				restriction = max(INVITE_RESTRICTION_FACTION, restriction);
			elseif ( realmID == 0 ) then
				restriction = max(INVITE_RESTRICTION_INFO, restriction);
			elseif ( not canInvite ) then
				restriction = max(INVITE_RESTRICTION_LEADER, restriction);
			else
				-- there is at lease 1 toon that can be invited
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
	elseif ( restriction == INVITE_RESTRICTION_INFO ) then
		return ERR_TRAVEL_PASS_NO_INFO;
	elseif ( restriction == INVITE_RESTRICTION_CLIENT ) then
		return ERR_TRAVEL_PASS_NOT_WOW;
	else
		return "";
	end
end

function TravelPassButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local canInvite = FriendsFrame_HasInvitePermission();
	local restriction = FriendsFrame_GetInviteRestriction(self:GetParent().id, canInvite);
	if ( restriction == INVITE_RESTRICTION_NONE ) then
		GameTooltip:SetText(TRAVEL_PASS_INVITE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
	else
		GameTooltip:SetText(TRAVEL_PASS_INVITE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
		GameTooltip:AddLine(FriendsFrame_GetInviteRestrictionText(restriction), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1);
		GameTooltip:Show();
	end
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
	
	local numToons, restriction;
	if ( self.index ) then
		numToons = BNGetNumFriendToons(self.index);
	else
		numToons = 0;
	end
	for i = 1, numToons do
		restriction = INVITE_RESTRICTION_NONE;
		local hasFocus, toonName, client, realmName, realmID, faction, race, class, _, _, level, _, _, _, _, toonID = BNGetFriendToonInfo(self.index, i);
		if ( client == BNET_CLIENT_WOW ) then
			if ( faction ~= playerFactionGroup ) then
				restriction = INVITE_RESTRICTION_FACTIONINVITE_RESTRICTION_FACTION;
			elseif ( realmID == 0 ) then
				restriction = INVITE_RESTRICTION_INFO;
			end
			if ( restriction == INVITE_RESTRICTION_NONE ) then
				info.text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, toonName, level, race, class);
			else
				info.text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, toonName..CANNOT_COOPERATE_LABEL, level, race, class);
			end
		else
			restriction = INVITE_RESTRICTION_CLIENT;
			info.text = BNet_GetClientEmbeddedTexture(client, 18)..toonName;
		end
		if ( restriction == INVITE_RESTRICTION_NONE ) then
			info.arg1 = toonID;
			info.disabled = nil;
		else
			info.arg1 = nil;
			info.disabled = 1;
		end
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
end

function TravelPassDropDown_OnClick(button, toonID)
	BNInviteFriend(toonID);
end

function BattleTagInviteFrame_Show(name)
	BattleTagInviteFrame.BattleTag:SetText(name);
	BattleTagInviteFrame.NoteFrame.EditBox:SetText("");
	if ( not BattleTagInviteFrame:IsShown() ) then
		StaticPopupSpecial_Show(BattleTagInviteFrame);
	end
end
