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
GUILDMEMBERS_TO_DISPLAY = 13;
FRIENDS_FRAME_GUILD_HEIGHT = 14;
MAX_WHOS_FROM_SERVER = 50;
MAX_GUILDCONTROL_OPTIONS = 12;
CURRENT_GUILD_MOTD = "";
GUILD_DETAIL_NORM_HEIGHT = 195
GUILD_DETAIL_OFFICER_HEIGHT = 255
MAX_GUILDBANK_TABS = 6;
MAX_GOLD_WITHDRAW = 1000;
GUILDEVENT_TRANSACTION_HEIGHT = 13;
MAX_EVENTS_SHOWN = 25;
MAX_GOLD_WITHDRAW_DIGITS = 9;
PENDING_GUILDBANK_PERMISSIONS = {};
FRIENDS_BUTTON_HEADER_HEIGHT = 16;
FRIENDS_BUTTON_NORMAL_HEIGHT = 34;
FRIENDS_BUTTON_LARGE_HEIGHT = 48;
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
BNET_CLIENT_WOW = "WoW";
BNET_CLIENT_SC2 = "S2";
FRIENDS_TOOLTIP_MAX_TOONS = 5;
FRIENDS_TOOLTIP_MAX_WIDTH = 200;
FRIENDS_TOOLTIP_MARGIN_WIDTH = 12;

local FriendButtons = { };
local BNetBroadcasts = { };
local totalScrollHeight = 0;
local numOnlineBroadcasts = 0;
local numOfflineBroadcasts = 0;
local PendingInvitesNew = { };
local playerRealmName;
local playerFactionGroup;

WHOFRAME_DROPDOWN_LIST = {
	{name = ZONE, sortType = "zone"},
	{name = GUILD, sortType = "guild"},
	{name = RACE, sortType = "race"}
};

FRIENDSFRAME_SUBFRAMES = { "FriendsListFrame", "IgnoreListFrame", "PendingListFrame", "WhoFrame", "GuildFrame", "ChannelFrame", "RaidFrame" };
function FriendsFrame_ShowSubFrame(frameName)
	for index, value in pairs(FRIENDSFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			_G[value]:Show()
		else
			_G[value]:Hide();
		end	
	end 
end

function FriendsFrame_SummonButton_OnEvent (self, event, ...)
	if ( event == "SPELL_UPDATE_COOLDOWN" and self:GetParent().id ) then
		FriendsFrame_SummonButton_Update(self);
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

function FriendsFrame_ShowDropdown(name, connected, lineID, chatType, chatFrame, friendsList)
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
	PanelTemplates_SetNumTabs(self, 5);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
	self:RegisterEvent("FRIENDLIST_SHOW");
	self:RegisterEvent("FRIENDLIST_UPDATE");
	self:RegisterEvent("IGNORELIST_UPDATE");
	self:RegisterEvent("MUTELIST_UPDATE");
	self:RegisterEvent("WHO_LIST_UPDATE");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("GUILD_MOTD");
	self:RegisterEvent("VOICE_CHAT_ENABLED_UPDATE");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
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
	self.playersInBotRank = 0;
	self.playerStatusFrame = 1;
	self.selectedFriend = 1;
	self.selectedIgnore = 1;
	self.guildStatus = 0;
	GuildFrame.notesToggle = 1;
	GuildFrame.selectedGuildMember = 0;
	SetGuildRosterSelection(0);
	CURRENT_GUILD_MOTD = GetGuildRosterMOTD();
	GuildFrameNotesText:SetText(CURRENT_GUILD_MOTD);
	GuildMemberDetailRankText:SetPoint("RIGHT", GuildFramePromoteButton, "LEFT");
	-- friends list
	DynamicScrollFrame_CreateButtons(FriendsFrameFriendsScrollFrame, "FriendsFrameButtonTemplate", FRIENDS_BUTTON_HEADER_HEIGHT, FriendsFrame_SetButton, FriendsFrame_GetTopButton);
	FriendsFrameOfflineHeader:SetParent(FriendsFrameFriendsScrollFrameScrollChild);
	FriendsFrameBroadcastInputClearButton.icon:SetVertexColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);	
	if ( not BNFeaturesEnabled() ) then
		FriendsTabHeaderTab3:Hide();
		FriendsFrameBroadcastInput:Hide();
		FriendsFrameBattlenetStatus:Hide();
		FriendsFrameStatusDropDown:Show();
	end	
end

function FriendsFrame_OnShow()
	VoiceChat_Toggle();
	FriendsList_Update();
	FriendsFrame_Update();
	UpdateMicroButtons();
	PlaySound("igCharacterInfoTab");
	GuildFrame.selectedGuildMember = 0;
	SetGuildRosterSelection(0);
	InGuildCheck();
end

function FriendsFrame_Update()
	if ( FriendsFrame.selectedTab == 1 ) then	
		FriendsTabHeader:Show();
		if ( FriendsTabHeader.selectedTab == 1 ) then
			ShowFriends();
			FriendsFrameTopLeft:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-TopLeft-bnet");
			FriendsFrameTopRight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-TopRight-bnet");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrameMute-BotLeft-bnet");
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrameMute-BotRight-bnet");
			FriendsFrameTitleText:SetText(FRIENDS_LIST);
			FriendsFrame_ShowSubFrame("FriendsListFrame");
		elseif ( FriendsTabHeader.selectedTab == 3 ) then
			FriendsFrameTopLeft:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-TopLeft-bnet");
			FriendsFrameTopRight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-TopRight-bnet");		
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-Pending-BotRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-Pending-BotLeft");
			FriendsFrameTitleText:SetText(PENDING_INVITE_LIST);
			FriendsFrame_ShowSubFrame("PendingListFrame");
		else
			FriendsFrameTopLeft:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-TopLeft-bnet");
			FriendsFrameTopRight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-TopRight-bnet");
			if ( IsVoiceChatEnabled() ) then
				FriendsFrameMutePlayerButton:Show();
				FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrameThree-BotLeft-bnet");
				FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrameThree-BotRight-bnet");
				FriendsFrameIgnorePlayerButton:SetWidth(110);
				FriendsFrameUnsquelchButton:SetWidth(111);
			else
				FriendsFrameMutePlayerButton:Hide();
				FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrameMute-BotLeft-bnet");
				FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrameMute-BotRight-bnet");
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
			FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
			FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotLeft");
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotRight");
			FriendsFrameTitleText:SetText(WHO_LIST);
			FriendsFrame_ShowSubFrame("WhoFrame");
			WhoList_Update();
		elseif ( FriendsFrame.selectedTab == 3 ) then
			FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
			FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotLeft");
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotRight");
			local guildName, title, rank = GetGuildInfo("player");
			if ( guildName ) then
				FriendsFrameTitleText:SetFormattedText(GUILD_TITLE_TEMPLATE, title, guildName);
			else 
				FriendsFrameTitleText:SetText("");
			end
			GuildStatus_Update();
			FriendsFrame_ShowSubFrame("GuildFrame");
		elseif ( FriendsFrame.selectedTab == 4 ) then
			FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
			FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-ChannelFrame-BotLeft");
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-ChannelFrame-BotRight");
			FriendsFrameTitleText:SetText(CHAT_CHANNELS);
			FriendsFrame_ShowSubFrame("ChannelFrame");
		elseif ( FriendsFrame.selectedTab == 5 ) then
			FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
			FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft");
			FriendsFrameBottomRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight");
			FriendsFrameTitleText:SetText(RAID);
			FriendsFrame_ShowSubFrame("RaidFrame");
		end
	end
end

function FriendsFrame_OnHide()
	UpdateMicroButtons();
	PlaySound("igMainMenuClose");
	SetGuildRosterSelection(0);
	GuildFrame.selectedGuildMember = 0;
	GuildFramePopup_HideAll();
	RaidInfoFrame:Hide();
	for index, value in pairs(FRIENDSFRAME_SUBFRAMES) do
		_G[value]:Hide();
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

	local buttonCount = numBNetTotal + numWoWTotal;
	local haveHeader;
	
	totalScrollHeight = 0;	
	if ( numBNetOnline > 0 or numWoWOnline > 0 ) then
		totalScrollHeight = totalScrollHeight + (numBNetOnline + numWoWOnline) * FRIENDS_BUTTON_NORMAL_HEIGHT + numOnlineBroadcasts * (FRIENDS_BUTTON_LARGE_HEIGHT - FRIENDS_BUTTON_NORMAL_HEIGHT);
	end
	if ( numBNetOffline > 0 or numWoWOffline > 0 ) then
		totalScrollHeight = totalScrollHeight + (numBNetOffline + numWoWOffline) * FRIENDS_BUTTON_NORMAL_HEIGHT + numOfflineBroadcasts * (FRIENDS_BUTTON_LARGE_HEIGHT - FRIENDS_BUTTON_NORMAL_HEIGHT);
		-- use a header if there are online and offline friends
		if ( numBNetOnline > 0 or numWoWOnline > 0 ) then
			haveHeader = true;
			buttonCount = buttonCount + 1;
			totalScrollHeight = totalScrollHeight + FRIENDS_BUTTON_HEADER_HEIGHT;
		end
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
			local presenceID, givenName, surname, toonName, toonID, client;
			presenceID, givenName, surname, toonName, toonID, client, isOnline = BNGetFriendInfo(selectedFriend);
			if ( not givenName or not surname ) then
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
		
	DynamicScrollFrame_Update(FriendsFrameFriendsScrollFrame);
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
		if ( not GetCVarBool("pendingInviteInfoShown") ) then
			PendingListInfoFrame:SetFrameLevel(FriendsFramePendingButton1:GetFrameLevel() + 1);
			PendingListInfoFrame:Show();
		end
	
		local scrollFrame = FriendsFramePendingScrollFrame;
		local buttonHeight, message, _;
		local heightLeft = scrollFrame.scrollHeight;
		local scrollBar = scrollFrame.scrollBar;

		FriendsFramePendingButton1.message:SetHeight(0);
		for i = numPending, 1, -1 do
			buttonHeight = PENDING_BUTTON_MIN_HEIGHT;
			_, _, _, message = BNGetFriendInviteInfo(i);
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
	local name, surname, message;
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
			inviteID, givenName, surname, message, timeSent, days = BNGetFriendInviteInfo(offset);
			button.index = offset;
			button.inviteID = inviteID;
			buttonHeight = PENDING_BUTTON_MIN_HEIGHT;
			if ( givenName and surname ) then
				button.name:SetFormattedText(BATTLENET_NAME_FORMAT, givenName, surname);
			else
				button.name:SetText(UNKNOWN);
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
			if ( timeSent and timeSent ~= 0 ) then
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
	local inviteID, name, surname, message = BNGetFriendInviteInfo(self:GetParent().index);
	local dialog = StaticPopup_Show("CONFIRM_BLOCK_INVITES", string.format(BATTLENET_NAME_FORMAT, name, surname));
	if ( dialog ) then
		dialog.data = inviteID;
	end
end

function PendingListFrame_ReportSpam(self)
	local inviteID, name, surname, message = BNGetFriendInviteInfo(self:GetParent().index);
	local dialog = StaticPopup_Show("CONFIRM_REPORT_SPAM_INVITE", string.format(BATTLENET_NAME_FORMAT, name, surname));
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
	PanelTemplates_TabResize(FriendsTabHeaderTab3, 0);
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

function GuildStatus_Update()
	-- Set the tab
	PanelTemplates_SetTab(FriendsFrame, 3);
	-- Show the frame
	ShowUIPanel(FriendsFrame);
	-- Number of players in the lowest rank
	FriendsFrame.playersInBotRank = 0;

	local numGuildMembers = GetNumGuildMembers();
	local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName;
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
	local maxRankIndex = GuildControlGetNumRanks() - 1;
	local button, buttonText, classTextColor;
	local onlinecount = 0;
	local guildIndex;

	-- Get selected guild member info
	name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());
	GuildFrame.selectedName = name;
	-- If there's a selected guildmember
	if ( GetGuildRosterSelection() > 0 ) then
		-- Update the guild member details frame
		GuildMemberDetailName:SetText(GuildFrame.selectedName);
		GuildMemberDetailLevel:SetFormattedText(FRIENDS_LEVEL_TEMPLATE, level, class);
		GuildMemberDetailZoneText:SetText(zone);
		GuildMemberDetailRankText:SetText(rank);
		if ( online ) then
			GuildMemberDetailOnlineText:SetText(GUILD_ONLINE_LABEL);
		else
			GuildMemberDetailOnlineText:SetText(GuildFrame_GetLastOnline(GetGuildRosterSelection()));
		end
		-- Update public note
		if ( CanEditPublicNote() ) then
			PersonalNoteText:SetTextColor(1.0, 1.0, 1.0);
			if ( (not note) or (note == "") ) then
				note = GUILD_NOTE_EDITLABEL;
			end
		else
			PersonalNoteText:SetTextColor(0.65, 0.65, 0.65);
		end
		GuildMemberNoteBackground:EnableMouse(CanEditPublicNote());
		PersonalNoteText:SetText(note);
		-- Update officer note
		if ( CanViewOfficerNote() ) then
			if ( CanEditOfficerNote() ) then
				if ( (not officernote) or (officernote == "") ) then
					officernote = GUILD_OFFICERNOTE_EDITLABEL;
				end
				OfficerNoteText:SetTextColor(1.0, 1.0, 1.0);
			else
				OfficerNoteText:SetTextColor(0.65, 0.65, 0.65);
			end
			GuildMemberOfficerNoteBackground:EnableMouse(CanEditOfficerNote());
			OfficerNoteText:SetText(officernote);

			-- Resize detail frame
			GuildMemberDetailOfficerNoteLabel:Show();
			GuildMemberOfficerNoteBackground:Show();
			GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_OFFICER_HEIGHT);
		else
			GuildMemberDetailOfficerNoteLabel:Hide();
			GuildMemberOfficerNoteBackground:Hide();
			GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_NORM_HEIGHT);
		end

		-- Manage guild member related buttons
		if ( CanGuildPromote() and ( rankIndex > 1 ) and ( rankIndex > (guildRankIndex + 1) ) ) then
			GuildFramePromoteButton:Enable();
		else 
			GuildFramePromoteButton:Disable();
		end
		if ( CanGuildDemote() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) and ( rankIndex ~= maxRankIndex ) ) then
			GuildFrameDemoteButton:Enable();
		else
			GuildFrameDemoteButton:Disable();
		end
		-- Hide promote/demote buttons if both disabled
		if ( GuildFrameDemoteButton:IsEnabled() == 0 and GuildFramePromoteButton:IsEnabled() == 0 ) then
			GuildFramePromoteButton:Hide();
			GuildFrameDemoteButton:Hide();
		else
			GuildFramePromoteButton:Show();
			GuildFrameDemoteButton:Show();
		end
		if ( CanGuildRemove() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) ) then
			GuildMemberRemoveButton:Enable();
		else
			GuildMemberRemoveButton:Disable();
		end
		if ( (UnitName("player") == name) or (not online) ) then
			GuildMemberGroupInviteButton:Disable();
		else
			GuildMemberGroupInviteButton:Enable();
		end

		GuildFrame.selectedName = GetGuildRosterInfo(GetGuildRosterSelection()); 
	else
		GuildMemberDetailFrame:Hide();
	end
	
	-- Message of the day stuff
	local guildMOTD = GetGuildRosterMOTD();
	if ( CanEditMOTD() ) then
		if ( (not guildMOTD) or (guildMOTD == "") ) then
			guildMOTD = GUILD_MOTD_EDITLABEL;
		end
		GuildFrameNotesText:SetTextColor(1.0, 1.0, 1.0);
		GuildMOTDEditButton:Enable();
	else
		GuildFrameNotesText:SetTextColor(0.65, 0.65, 0.65);
		GuildMOTDEditButton:Disable();
	end
	GuildFrameNotesText:SetText(CURRENT_GUILD_MOTD);

	-- Scrollbar stuff
	local showScrollBar = nil;
	if ( numGuildMembers > GUILDMEMBERS_TO_DISPLAY ) then
		showScrollBar = 1;
	end
	
	-- Get number of online members
	for i=1, numGuildMembers, 1 do
		name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(i);
		if ( online ) then
			onlinecount = onlinecount + 1;
		end
		if ( rankIndex == maxRankIndex ) then
			FriendsFrame.playersInBotRank = FriendsFrame.playersInBotRank + 1;
		end
	end
	GuildFrameTotals:SetFormattedText(GUILD_TOTAL, numGuildMembers);
	GuildFrameOnlineTotals:SetFormattedText(GUILD_TOTALONLINE, onlinecount);

	-- Update global guild frame buttons
	if ( IsGuildLeader() ) then
		GuildFrameControlButton:Enable();
	else
		GuildFrameControlButton:Disable();
	end
	if ( CanGuildInvite() ) then
		GuildFrameAddMemberButton:Enable();
	else
		GuildFrameAddMemberButton:Disable();
	end


	if ( FriendsFrame.playerStatusFrame ) then
		-- Player specific info
		local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);

		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i;
			button = _G["GuildFrameButton"..i];
			button.guildIndex = guildIndex;
			name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(guildIndex);

			if ( not online ) then
				buttonText = _G["GuildFrameButton"..i.."Name"];
				buttonText:SetText(name);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
				buttonText = _G["GuildFrameButton"..i.."Zone"];
				buttonText:SetText(zone);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
				buttonText = _G["GuildFrameButton"..i.."Level"];
				buttonText:SetText(level);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
				buttonText = _G["GuildFrameButton"..i.."Class"];
				buttonText:SetText(class);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
			else
				if ( classFileName ) then
					classTextColor = RAID_CLASS_COLORS[classFileName];
				else
					classTextColor = NORMAL_FONT_COLOR;
				end

				buttonText = _G["GuildFrameButton"..i.."Name"];
				buttonText:SetText(name);
				buttonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				buttonText = _G["GuildFrameButton"..i.."Zone"];
				buttonText:SetText(zone);
				buttonText:SetTextColor(1.0, 1.0, 1.0);
				buttonText = _G["GuildFrameButton"..i.."Level"];
				buttonText:SetText(level);
				buttonText:SetTextColor(1.0, 1.0, 1.0);
				buttonText = _G["GuildFrameButton"..i.."Class"];
				buttonText:SetText(class);
				buttonText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
			end

			-- If need scrollbar resize columns
			if ( showScrollBar ) then
				_G["GuildFrameButton"..i.."Zone"]:SetWidth(95);
			else
				_G["GuildFrameButton"..i.."Zone"]:SetWidth(110);
			end

			-- Highlight the correct who
			if ( GetGuildRosterSelection() == guildIndex ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
			
			if ( guildIndex > numGuildMembers ) then
				button:Hide();
			else
				button:Show();
			end
		end
		
		GuildFrameGuildListToggleButton:SetText(PLAYER_STATUS);
		-- If need scrollbar resize column headers
		if ( showScrollBar ) then
			WhoFrameColumn_SetWidth(GuildFrameColumnHeader2, 105);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 284, -67);
		else
			WhoFrameColumn_SetWidth(GuildFrameColumnHeader2, 120);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 307, -67);
		end
		-- ScrollFrame update
		FauxScrollFrame_Update(GuildListScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );
		
		GuildPlayerStatusFrame:Show();
		GuildStatusFrame:Hide();
	else
		-- Guild specific info
		local year, month, day, hour;
		local yearlabel, monthlabel, daylabel, hourlabel;
		local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);
		local classFileName;
		
		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i;
			button = _G["GuildFrameGuildStatusButton"..i];
			button.guildIndex = guildIndex;
			name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(guildIndex);

			_G["GuildFrameGuildStatusButton"..i.."Name"]:SetText(name);
			_G["GuildFrameGuildStatusButton"..i.."Rank"]:SetText(rank);
			_G["GuildFrameGuildStatusButton"..i.."Note"]:SetText(note);

			if ( online ) then
				if ( status == "" ) then
					_G["GuildFrameGuildStatusButton"..i.."Online"]:SetText(GUILD_ONLINE_LABEL);
				else
					_G["GuildFrameGuildStatusButton"..i.."Online"]:SetText(status);
				end

				if ( classFileName ) then
					classTextColor = RAID_CLASS_COLORS[classFileName];
				else
					classTextColor = NORMAL_FONT_COLOR;
				end
				_G["GuildFrameGuildStatusButton"..i.."Name"]:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				_G["GuildFrameGuildStatusButton"..i.."Rank"]:SetTextColor(1.0, 1.0, 1.0);
				_G["GuildFrameGuildStatusButton"..i.."Note"]:SetTextColor(1.0, 1.0, 1.0);
				_G["GuildFrameGuildStatusButton"..i.."Online"]:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
			else
				_G["GuildFrameGuildStatusButton"..i.."Online"]:SetText(GuildFrame_GetLastOnline(guildIndex));
				_G["GuildFrameGuildStatusButton"..i.."Name"]:SetTextColor(0.5, 0.5, 0.5);
				_G["GuildFrameGuildStatusButton"..i.."Rank"]:SetTextColor(0.5, 0.5, 0.5);
				_G["GuildFrameGuildStatusButton"..i.."Note"]:SetTextColor(0.5, 0.5, 0.5);
				_G["GuildFrameGuildStatusButton"..i.."Online"]:SetTextColor(0.5, 0.5, 0.5);
			end

			-- If need scrollbar resize columns
			if ( showScrollBar ) then
				_G["GuildFrameGuildStatusButton"..i.."Note"]:SetWidth(70);
			else
				_G["GuildFrameGuildStatusButton"..i.."Note"]:SetWidth(85);
			end

			-- Highlight the correct who
			if ( GetGuildRosterSelection() == guildIndex ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end

			if ( guildIndex > numGuildMembers ) then
				button:Hide();
			else
				button:Show();
			end
		end
		
		GuildFrameGuildListToggleButton:SetText(GUILD_STATUS);
		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			WhoFrameColumn_SetWidth(GuildFrameGuildStatusColumnHeader3, 75);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 284, -67);
		else
			WhoFrameColumn_SetWidth(GuildFrameGuildStatusColumnHeader3, 90);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 307, -67);
		end
		
		-- ScrollFrame update
		FauxScrollFrame_Update(GuildListScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );

		GuildPlayerStatusFrame:Hide();
		GuildStatusFrame:Show();
	end
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
	if ( event == "FRIENDLIST_SHOW" ) then
		FriendsList_Update();
		FriendsFrame_Update();
	elseif ( event == "FRIENDLIST_UPDATE" or event == "PARTY_MEMBERS_CHANGED" ) then
		FriendsList_Update();
	elseif ( event == "BN_FRIEND_LIST_SIZE_CHANGED" or event == "BN_FRIEND_INFO_CHANGED" ) then
		BNetBroadcasts, numOnlineBroadcasts, numOfflineBroadcasts = BNGetCustomMessageTable(BNetBroadcasts);
		if(not BNetBroadcasts) then
			BNetBroadcasts = { };
		end
		FriendsList_Update();
	elseif ( event == "BN_CUSTOM_MESSAGE_CHANGED" ) then
		local arg1 = ...;
		if ( arg1 ) then	--There is no presenceID given if this is ourself.
			BNetBroadcasts, numOnlineBroadcasts, numOfflineBroadcasts = BNGetCustomMessageTable(BNetBroadcasts);
			if(not BNetBroadcasts) then
				BNetBroadcasts = { };
			end
			FriendsList_Update();
		else
			FriendsFrameBroadcastInput_UpdateDisplay();
		end
	elseif ( event == "BN_CUSTOM_MESSAGE_LOADED" ) then
		FriendsFrameBroadcastInput_UpdateDisplay();
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
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		GuildInfoFrame.cachedText = nil;
		if ( GuildFrame:IsShown() ) then
			local arg1 = ...;
			if ( arg1 ) then
				GuildRoster();
			end
			GuildStatus_Update();
			FriendsFrame_Update();
			GuildControlPopupFrame_Initialize();
		end
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		if ( FriendsFrame:IsVisible() ) then
			InGuildCheck();
		end
		if ( not IsInGuild() ) then
			GuildControlPopupFrame.initialized = false;
		end
	elseif ( event == "GUILD_MOTD") then
		CURRENT_GUILD_MOTD = ...;
		GuildFrameNotesText:SetText(CURRENT_GUILD_MOTD);
	elseif ( event == "VOICE_CHAT_ENABLED_UPDATE" ) then
		VoiceChat_Toggle();
	elseif ( event == "PLAYER_FLAGS_CHANGED" ) then
		SynchronizeBNetStatus();
		FriendsFrameStatusDropDown_Update();
	elseif ( event == "PLAYER_ENTERING_WORLD" or event == "BN_CONNECTED" or event == "BN_DISCONNECTED" or event == "BN_SELF_ONLINE" ) then
		FriendsFrame_CheckBattlenetStatus();
	end
end

function FriendsFrameFriendButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		FriendsFrame_SelectFriend(self.buttonType, self.id);
		FriendsList_Update();
	elseif ( button == "RightButton" ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		if ( self.buttonType == FRIENDS_BUTTON_TYPE_BNET ) then
			-- bnet friend
			local presenceID, givenName, surname, toonName, toonID, client, isOnline = BNGetFriendInfo(self.id);
			FriendsFrame_ShowBNDropdown(format(BATTLENET_NAME_FORMAT, givenName, surname), isOnline, nil, nil, nil, 1, presenceID);
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
		if ( BNFeaturesEnabled() ) then
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
	elseif ( FriendsFrame.selectedFriendType == FRIENDS_BUTTON_TYPE_BNET ) then
		local presenceID, givenName, surname = BNGetFriendInfo(FriendsFrame.selectedFriend);
		name = string.format(BATTLENET_NAME_FORMAT, givenName, surname);
	end
	if ( name ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		ChatFrame_SendTell(name);
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

function FriendsFrameGuildStatusButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		GuildFrame.previousSelectedGuildMember = GuildFrame.selectedGuildMember;
		GuildFrame.selectedGuildMember = self.guildIndex;
		GuildFrame.selectedName = _G[self:GetName().."Name"]:GetText();
		SetGuildRosterSelection(GuildFrame.selectedGuildMember);
		-- Toggle guild details frame
		if ( GuildMemberDetailFrame:IsShown() and (GuildFrame.previousSelectedGuildMember and (GuildFrame.previousSelectedGuildMember == GuildFrame.selectedGuildMember)) ) then
			GuildMemberDetailFrame:Hide();
			GuildFrame.selectedGuildMember = 0;
			SetGuildRosterSelection(0);
		else
			GuildFramePopup_Show(GuildMemberDetailFrame);
		end
		GuildStatus_Update();
	else
		local guildIndex = self.guildIndex;
		local name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(guildIndex);
		FriendsFrame_ShowDropdown(name, online);
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
	InviteUnit(name);
	PlaySound("UChatScrollButton");
end

function ToggleFriendsFrame(tab)
	if ( not tab ) then
		if ( FriendsFrame:IsShown() ) then
			HideUIPanel(FriendsFrame);
		else
			ShowUIPanel(FriendsFrame);
		end
	else
		-- If not in a guild don't do anything when they try to toggle the guild tab
		if ( tab == 3 and not IsInGuild() ) then
			return;
		end
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

function WhoFrameEditBox_OnEnterPressed(self)
	SendWho(self:GetText());
	self:ClearFocus();
end

function ToggleFriendsPanel()
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
	local command = WHO_TAG_ZONE.."\""..GetRealZoneText().."\" "..minLevel.."-"..(level+3);
	return command;
end

function GuildControlPopupFrame_OnLoad()
	local buttonText;
	for i=1, 17 do	
		buttonText = _G["GuildControlPopupFrameCheckbox"..i.."Text"];
		if ( buttonText ) then
			buttonText:SetText(_G["GUILDCONTROL_OPTION"..i]);
		end
	end
	GuildControlTabPermissionsViewTabText:SetText(GUILDCONTROL_VIEW_TAB);
	GuildControlTabPermissionsDepositItemsText:SetText(GUILDCONTROL_DEPOSIT_ITEMS);
	GuildControlTabPermissionsUpdateTextText:SetText(GUILDCONTROL_UPDATE_TEXT);
	ClearPendingGuildBankPermissions();
end

--Need to call this function on an event since the guildroster is not available during OnLoad()
function GuildControlPopupFrame_Initialize()
	if ( GuildControlPopupFrame.initialized ) then
		return;
	end
	UIDropDownMenu_Initialize(GuildControlPopupFrameDropDown, GuildControlPopupFrameDropDown_Initialize);
	GuildControlSetRank(1);
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1);
	UIDropDownMenu_SetText(GuildControlPopupFrameDropDown, GuildControlGetRankName(1));
	-- Select tab 1
	GuildBankTabPermissionsTab_OnClick(1);

	GuildControlPopupFrame:SetScript("OnEvent", GuildControlPopupFrame_OnEvent);
	GuildControlPopupFrame.initialized = 1;
	GuildControlPopupFrame.rank = GuildControlGetRankName(1);
end

function GuildControlPopupFrame_OnShow()
	FriendsFrame:SetAttribute("UIPanelLayout-defined", nil);
	FriendsFrame.guildControlShow = 1;
	GuildControlPopupAcceptButton:Disable();
	-- Update popup
	GuildControlPopupframe_Update();
	
	UIPanelWindows["FriendsFrame"].width = FriendsFrame:GetWidth() + GuildControlPopupFrame:GetWidth();
	UpdateUIPanelPositions(FriendsFrame);
	--GuildControlPopupFrame:RegisterEvent("GUILD_ROSTER_UPDATE"); --It was decided that having a risk of conflict when two people are editing the guild permissions at once is better than resetting whenever someone joins the guild or changes ranks.
end

function GuildControlPopupFrame_OnEvent (self, event, ...)
	if ( not IsGuildLeader(UnitName("player")) ) then
		GuildControlPopupFrame:Hide();
		return;
	end
	
	local rank
	for i = 1, GuildControlGetNumRanks() do
		rank = GuildControlGetRankName(i);
		if ( GuildControlPopupFrame.rank and rank == GuildControlPopupFrame.rank ) then
			UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, i);
			UIDropDownMenu_SetText(GuildControlPopupFrameDropDown, rank);
		end
	end
	
	GuildControlPopupframe_Update()
end

function GuildControlPopupFrame_OnHide()
	FriendsFrame:SetAttribute("UIPanelLayout-defined", nil);
	FriendsFrame.guildControlShow = 0;

	UIPanelWindows["FriendsFrame"].width = FriendsFrame:GetWidth();
	UpdateUIPanelPositions();

	GuildControlPopupFrame.goldChanged = nil;
	GuildControlPopupFrame:UnregisterEvent("GUILD_ROSTER_UPDATE");
end

function GuildControlPopupframe_Update(loadPendingTabPermissions, skipCheckboxUpdate)
	-- Skip non-tab specific updates to fix Bug  ID: 110210
	if ( not skipCheckboxUpdate ) then
		-- Update permission flags
		GuildControlCheckboxUpdate(GuildControlGetRankFlags());
	end
	
	local rankID = UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown);
	GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(rankID));
	if ( GuildControlPopupFrame.previousSelectedRank and GuildControlPopupFrame.previousSelectedRank ~= rankID ) then
		ClearPendingGuildBankPermissions();
	end
	GuildControlPopupFrame.previousSelectedRank = rankID;

	--If rank to modify is guild master then gray everything out
	if ( IsGuildLeader() and rankID == 1 ) then
		GuildBankTabLabel:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlTabPermissionsDepositItems:SetChecked(1);
		GuildControlTabPermissionsViewTab:SetChecked(1);
		GuildControlTabPermissionsUpdateText:SetChecked(1);
		BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsDepositItems);
		BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsViewTab);
		BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsUpdateText);
		GuildControlTabPermissionsWithdrawItemsText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlWithdrawItemsEditBox:SetNumeric(nil);
		GuildControlWithdrawItemsEditBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlWithdrawItemsEditBox:SetText(UNLIMITED);
		GuildControlWithdrawItemsEditBox:ClearFocus();
		GuildControlWithdrawItemsEditBoxMask:Show();
		GuildControlWithdrawGoldText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlWithdrawGoldAmountText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBox:SetNumeric(nil);
		GuildControlWithdrawGoldEditBox:SetMaxLetters(0);
		GuildControlWithdrawGoldEditBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBox:SetText(UNLIMITED);
		GuildControlWithdrawGoldEditBox:ClearFocus();
		GuildControlWithdrawGoldEditBoxMask:Show();
		BlizzardOptionsPanel_CheckButton_Disable(GuildControlPopupFrameCheckbox15);
		BlizzardOptionsPanel_CheckButton_Disable(GuildControlPopupFrameCheckbox16);
	else
		if ( GetNumGuildBankTabs() == 0 ) then
			-- No tabs, no permissions! Disable the tab related doohickies
			GuildBankTabLabel:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsViewTab);
			BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsDepositItems);
			BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsUpdateText);
			GuildControlTabPermissionsWithdrawItemsText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			GuildControlWithdrawItemsEditBox:SetText(UNLIMITED);
			GuildControlWithdrawItemsEditBox:ClearFocus();
			GuildControlWithdrawItemsEditBoxMask:Show();
		else
			GuildBankTabLabel:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			BlizzardOptionsPanel_CheckButton_Enable(GuildControlTabPermissionsViewTab);
			GuildControlTabPermissionsWithdrawItemsText:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			GuildControlWithdrawItemsEditBox:SetNumeric(1);
			GuildControlWithdrawItemsEditBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			GuildControlWithdrawItemsEditBoxMask:Hide();
		end
		
		GuildControlWithdrawGoldText:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GuildControlWithdrawGoldAmountText:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBox:SetNumeric(1);
		GuildControlWithdrawGoldEditBox:SetMaxLetters(MAX_GOLD_WITHDRAW_DIGITS);
		GuildControlWithdrawGoldEditBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBoxMask:Hide();
		BlizzardOptionsPanel_CheckButton_Enable(GuildControlPopupFrameCheckbox15);
		BlizzardOptionsPanel_CheckButton_Enable(GuildControlPopupFrameCheckbox16);

		-- Update tab specific info
		local viewTab, canDeposit, canUpdateText, numWithdrawals = GetGuildBankTabPermissions(GuildControlPopupFrameTabPermissions.selectedTab);
		if ( rankID == 1 ) then
			--If is guildmaster then force checkboxes to be selected
			viewTab = 1;
			canDeposit = 1;
			canUpdateText = 1;
		elseif ( loadPendingTabPermissions ) then
			local permissions = PENDING_GUILDBANK_PERMISSIONS[GuildControlPopupFrameTabPermissions.selectedTab];
			local value;
			value = permissions[GuildControlTabPermissionsViewTab:GetID()];
			if ( value ) then
				viewTab = value;
			end
			value = permissions[GuildControlTabPermissionsDepositItems:GetID()];
			if ( value ) then
				canDeposit = value;
			end
			value = permissions[GuildControlTabPermissionsUpdateText:GetID()];
			if ( value ) then
				canUpdateText = value;
			end
			value = permissions["withdraw"];
			if ( value ) then
				numWithdrawals = value;
			end
		end
		GuildControlTabPermissionsViewTab:SetChecked(viewTab);
		GuildControlTabPermissionsDepositItems:SetChecked(canDeposit);
		GuildControlTabPermissionsUpdateText:SetChecked(canUpdateText);
		GuildControlWithdrawItemsEditBox:SetText(numWithdrawals);
		local goldWithdrawLimit = GetGuildBankWithdrawLimit();
		-- Only write to the editbox if the value hasn't been changed by the player
		if ( not GuildControlPopupFrame.goldChanged ) then
			if ( goldWithdrawLimit >= 0 ) then
				GuildControlWithdrawGoldEditBox:SetText(goldWithdrawLimit);
			else
				-- This is for the guild leader who defaults to -1
				GuildControlWithdrawGoldEditBox:SetText(MAX_GOLD_WITHDRAW);
			end
		end
		GuildControlPopup_UpdateDepositCheckBox();
	end
	
	--Only show available tabs
	local tab;
	local numTabs = GetNumGuildBankTabs();
	local name, permissionsTabBackground, permissionsText;
	for i=1, MAX_GUILDBANK_TABS do
		name = GetGuildBankTabInfo(i);
		tab = _G["GuildBankTabPermissionsTab"..i];
		
		if ( i <= numTabs ) then
			tab:Show();
			tab.tooltip = name;
			permissionsTabBackground = _G["GuildBankTabPermissionsTab"..i.."Background"];
			permissionsText = _G["GuildBankTabPermissionsTab"..i.."Text"];
			if (  GuildControlPopupFrameTabPermissions.selectedTab == i ) then
				tab:LockHighlight();
				permissionsTabBackground:SetTexCoord(0, 1.0, 0, 1.0);
				permissionsTabBackground:SetHeight(32);
				permissionsText:SetPoint("CENTER", permissionsTabBackground, "CENTER", 0, -3);
			else
				tab:UnlockHighlight();
				permissionsTabBackground:SetTexCoord(0, 1.0, 0, 0.875);
				permissionsTabBackground:SetHeight(28);
				permissionsText:SetPoint("CENTER", permissionsTabBackground, "CENTER", 0, -5);
			end
			if ( IsGuildLeader() and rankID == 1 ) then
				tab:Disable();
			else
				tab:Enable();
			end
		else
			tab:Hide();
		end
	end
end

function WithdrawGoldEditBox_Update()
	if ( not GuildControlPopupFrameCheckbox15:GetChecked() and not GuildControlPopupFrameCheckbox16:GetChecked() ) then
		GuildControlWithdrawGoldAmountText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBox:ClearFocus();
		GuildControlWithdrawGoldEditBoxMask:Show();
	else
		GuildControlWithdrawGoldAmountText:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBoxMask:Hide();
	end
end

function GuildControlPopupAcceptButton_OnClick()
	local amount = GuildControlWithdrawGoldEditBox:GetText();
	if(amount and amount ~= "" and amount ~= UNLIMITED and tonumber(amount) and tonumber(amount) > 0) then
		SetGuildBankWithdrawLimit(amount);
	else
		SetGuildBankWithdrawLimit(0);
	end
	SavePendingGuildBankTabPermissions()
	GuildControlSaveRank(GuildControlPopupFrameEditBox:GetText());
	GuildStatus_Update();
	GuildControlPopupAcceptButton:Disable();
	UIDropDownMenu_SetText(GuildControlPopupFrameDropDown, GuildControlPopupFrameEditBox:GetText());
	GuildControlPopupFrame:Hide();
	ClearPendingGuildBankPermissions();
end

function GuildControlPopupFrameDropDown_OnLoad(self)
	UIDropDownMenu_SetWidth(self, 160);
	UIDropDownMenu_SetButtonWidth(self, 54);
	UIDropDownMenu_JustifyText(GuildControlPopupFrameDropDown, "LEFT");
end

function GuildControlPopupFrameDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	for i=1, GuildControlGetNumRanks() do
		info.text = GuildControlGetRankName(i);
		info.func = GuildControlPopupFrameDropDownButton_OnClick;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function GuildControlPopupFrameDropDownButton_OnClick(self)
	local rank = self:GetID();
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, rank);	
	GuildControlSetRank(rank);
	GuildControlPopupFrame.rank = GuildControlGetRankName(rank);
	GuildControlPopupFrame.goldChanged = nil;
	GuildControlPopupframe_Update();
	GuildControlPopupFrameAddRankButton_OnUpdate(GuildControlPopupFrameAddRankButton);
	GuildControlPopupFrameRemoveRankButton_OnUpdate(GuildControlPopupFrameRemoveRankButton);
	GuildControlPopupAcceptButton:Disable();
end

function GuildControlCheckboxUpdate(...)
	local checkbox;
	for i=1, select("#", ...), 1 do
		checkbox = _G["GuildControlPopupFrameCheckbox"..i]
		if ( checkbox ) then
			checkbox:SetChecked(select(i, ...));
		else
			--We need to skip checkbox 14 since it's a deprecated flag
			--message("GuildControlPopupFrameCheckbox"..i.." does not exist!");
		end
	end
end

function GuildControlPopupFrameAddRankButton_OnUpdate(self)
	if ( GuildControlGetNumRanks() >= 10 ) then
		self:Disable();
	else
		self:Enable();
	end
end

function GuildControlPopupFrameRemoveRankButton_OnClick()
	GuildControlDelRank(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
	GuildControlPopupFrame.rank = GuildControlGetRankName(1);
	GuildControlSetRank(1);
	GuildStatus_Update();
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1);
	GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(1));
	GuildControlCheckboxUpdate(GuildControlGetRankFlags());
	CloseDropDownMenus();
	-- Set this to call guildroster in the next frame
	--GuildRoster();
	--GuildControlPopupFrame.update = 1;
end

function GuildControlPopupFrameRemoveRankButton_OnUpdate(self)
	local numRanks = GuildControlGetNumRanks()
	if ( (UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown) == numRanks) and (numRanks > 5) ) then
		self:Show();
		if ( FriendsFrame.playersInBotRank > 0 ) then
			self:Disable();
		else
			self:Enable();
		end
	else
		self:Hide();
	end
end

function GuildControlPopup_UpdateDepositCheckBox()
	if(GuildControlTabPermissionsViewTab:GetChecked()) then
		BlizzardOptionsPanel_CheckButton_Enable(GuildControlTabPermissionsDepositItems);
		BlizzardOptionsPanel_CheckButton_Enable(GuildControlTabPermissionsUpdateText);
	else
		BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsDepositItems);
		BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsUpdateText);
	end
end

function InGuildCheck()
	if ( not IsInGuild() ) then
		PanelTemplates_DisableTab( FriendsFrame, 3 );
		if ( FriendsFrame.selectedTab == 3 ) then
			FriendsFrame.selectedTab = 1;
			FriendsFrame_Update();
		end
	else
		PanelTemplates_EnableTab( FriendsFrame, 3 );
		FriendsFrame_Update();
	end
end

function GuildFrameGuildListToggleButton_OnClick()
	if ( FriendsFrame.playerStatusFrame ) then
		FriendsFrame.playerStatusFrame = nil;
	else
		FriendsFrame.playerStatusFrame = 1;		
	end
	GuildStatus_Update();
end

function GuildFrameControlButton_OnUpdate()
	if ( FriendsFrame.guildControlShow == 1 ) then
		GuildFrameControlButton:LockHighlight();		
	else
		GuildFrameControlButton:UnlockHighlight();
	end
	-- Janky way to make sure a change made to the guildroster will reflect in the guildroster call
	if ( GuildControlPopupFrame.update == 1 ) then
		GuildControlPopupFrame.update = 2;
	elseif ( GuildControlPopupFrame.update == 2 ) then
		GuildRoster();
		GuildControlPopupFrame.update = nil;
	end
end

function GuildFrame_GetLastOnline(guildIndex)
	return RecentTimeDate( GetGuildRosterLastOnline(guildIndex) );
end

function FriendsFrame_GetLastOnline(lastOnline)
	local year, month, day, hour, minute;
	local timeDifference = time() - lastOnline;
	local ONE_MINUTE = 60;
	local ONE_HOUR = 60 * ONE_MINUTE;
	local ONE_DAY = 24 * ONE_HOUR;
	local ONE_MONTH = 30 * ONE_DAY;
	local ONE_YEAR = 12 * ONE_MONTH;
	-- local ONE_MILLENIUM = 1000 * ONE_YEAR; 	for the future

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

function ToggleGuildInfoFrame()
	if ( GuildInfoFrame:IsShown() ) then
		GuildInfoFrame:Hide();
	else
		GuildFramePopup_Show(GuildInfoFrame);
	end
end

function GuildBankTabPermissionsTab_OnClick(tab)
	GuildControlPopupFrameTabPermissions.selectedTab = tab;
	GuildControlPopupframe_Update(true, true);
end

-- Functions to allow canceling
function ClearPendingGuildBankPermissions()
	for i=1, MAX_GUILDBANK_TABS do
		PENDING_GUILDBANK_PERMISSIONS[i] = {};
	end
end

function SetPendingGuildBankTabPermissions(tab, id, checked)
	if ( not checked ) then
		checked = 0;
	end
	PENDING_GUILDBANK_PERMISSIONS[tab][id] = checked;
end

function SetPendingGuildBankTabWithdraw(tab, amount)
	PENDING_GUILDBANK_PERMISSIONS[tab]["withdraw"] = amount;
end

function SavePendingGuildBankTabPermissions()
	for index, value in pairs(PENDING_GUILDBANK_PERMISSIONS) do
		for i=1, 3 do
			if ( value[i] ) then
				SetGuildBankTabPermissions(index, i, value[i]);
			end
		end
		if ( value["withdraw"] ) then
			SetGuildBankTabWithdraw(index, value["withdraw"]);
		end
	end
end

-- Guild event log functions
function ToggleGuildEventLog()
	if ( GuildEventLogFrame:IsShown() ) then
		GuildEventLogFrame:Hide();
	else
		GuildFramePopup_Show(GuildEventLogFrame);
--		QueryGuildEventLog();
	end
end

function GuildEventLog_Update()
	local numEvents = GetNumGuildEvents();
	local type, player1, player2, rank, year, month, day, hour;
	local msg;
	local buffer = "";
	local max = GuildEventMessage:GetFieldSize()
	local length = 0;
	for i=numEvents, 1, -1 do
		type, player1, player2, rank, year, month, day, hour = GetGuildEventInfo(i);
		if ( not player1 ) then
			player1 = UNKNOWN;
		end
		if ( not player2 ) then
			player2 = UNKNOWN;
		end
		if ( type == "invite" ) then
			msg = format(GUILDEVENT_TYPE_INVITE, player1, player2);
		elseif ( type == "join" ) then
			msg = format(GUILDEVENT_TYPE_JOIN, player1);
		elseif ( type == "promote" ) then
			msg = format(GUILDEVENT_TYPE_PROMOTE, player1, player2, rank);
		elseif ( type == "demote" ) then
			msg = format(GUILDEVENT_TYPE_DEMOTE, player1, player2, rank);
		elseif ( type == "remove" ) then
			msg = format(GUILDEVENT_TYPE_REMOVE, player1, player2);
		elseif ( type == "quit" ) then
			msg = format(GUILDEVENT_TYPE_QUIT, player1);
		end
		if ( msg ) then
			msg = msg.."|cff009999   "..format(GUILD_BANK_LOG_TIME, RecentTimeDate(year, month, day, hour)).."|r|n";
			length = length + msg:len();
			if(length>max) then
				i=0
			else
				buffer = buffer..msg
			end
		end
	end
	GuildEventMessage:SetText(buffer);
end

GUILDFRAME_POPUPS = {
	"GuildEventLogFrame",
	"GuildInfoFrame",
	"GuildMemberDetailFrame",
	"GuildControlPopupFrame",
};

function GuildFramePopup_Show(frame)
	local name = frame:GetName();
	for index, value in ipairs(GUILDFRAME_POPUPS) do
		if ( name ~= value ) then
			_G[value]:Hide();
		end
	end
	frame:Show();
end

function GuildFramePopup_HideAll()
	for index, value in ipairs(GUILDFRAME_POPUPS) do
		_G[value]:Hide();
	end
end

-- Battle.net stuff starts here

function FriendsFrame_CheckBattlenetStatus()
	if ( BNFeaturesEnabled() ) then
		if ( BNConnected() ) then
			BNetBroadcasts, numOnlineBroadcasts, numOfflineBroadcasts = BNGetCustomMessageTable(BNetBroadcasts);
			if(not BNetBroadcasts) then
				BNetBroadcasts = { };
			end
			playerRealmName = GetRealmName();
			playerFactionGroup = UnitFactionGroup("player");
			FriendsFrameBattlenetStatus:Hide();
			FriendsFrameStatusDropDown:Show();
			FriendsFrameBroadcastInput:Show();
			FriendsFrameBroadcastInput_UpdateDisplay();
		else
			numOnlineBroadcasts = 0;
			numOfflineBroadcasts = 0;
			FriendsFrameBattlenetStatus:Show();
			FriendsFrameStatusDropDown:Hide();
			FriendsFrameBroadcastInput:Hide();
			FriendsFrameOfflineHeader:Hide();
		end
		if ( FriendsFrame:IsShown() ) then
			IgnoreList_Update();
			PendingList_Update();
		end
		-- has its own check if it is being shown, after it updates the count on the FriendsMicroButton
		FriendsList_Update();
	end
end

function FriendsFrame_GetTopButton(offset)
	local heightLeft = offset;
	local priorHeight = 0;
	local buttonHeight;	
	local numBNetTotal, numBNetOnline = BNGetNumFriends();
	local numBNetOffline = numBNetTotal - numBNetOnline;
	local numWoWTotal, numWoWOnline = GetNumFriends();
	local numWoWOffline = numWoWTotal - numWoWOnline;	
	local buttonIndex = 0;

	-- online
	if ( numBNetOnline + numWoWOnline > 0 ) then
		local totalBNOnlineHeight = numBNetOnline * FRIENDS_BUTTON_NORMAL_HEIGHT + numOnlineBroadcasts * (FRIENDS_BUTTON_LARGE_HEIGHT - FRIENDS_BUTTON_NORMAL_HEIGHT);
		if ( heightLeft < totalBNOnlineHeight ) then
			for i = 1, numBNetOnline do
				if ( BNetBroadcasts[i] ) then
					buttonHeight = FRIENDS_BUTTON_LARGE_HEIGHT;
				else
					buttonHeight = FRIENDS_BUTTON_NORMAL_HEIGHT;
				end
				if ( (heightLeft - buttonHeight) < 1 ) then
					return i + buttonIndex, offset - heightLeft, totalScrollHeight;
				else
					heightLeft = heightLeft - buttonHeight;
				end
			end
		end
		heightLeft = heightLeft - totalBNOnlineHeight;
		buttonIndex = buttonIndex + numBNetOnline;
		if ( heightLeft < numWoWOnline * FRIENDS_BUTTON_NORMAL_HEIGHT ) then
			local index = math.floor(heightLeft / FRIENDS_BUTTON_NORMAL_HEIGHT) + 1;
			return buttonIndex + index, offset - heightLeft + (index - 1) * FRIENDS_BUTTON_NORMAL_HEIGHT, totalScrollHeight;
		end
		heightLeft = heightLeft - numWoWOnline * FRIENDS_BUTTON_NORMAL_HEIGHT;
		buttonIndex = buttonIndex + numWoWOnline;
	end
	-- offline 
	if (  numBNetOffline + numWoWOffline > 0  ) then
		-- check header first
		if ( numBNetOnline + numWoWOnline > 0 ) then
			buttonIndex = buttonIndex + 1;
			if ( heightLeft < FRIENDS_BUTTON_HEADER_HEIGHT ) then
				return buttonIndex, offset - heightLeft, totalScrollHeight;
			else
				heightLeft = heightLeft - FRIENDS_BUTTON_HEADER_HEIGHT;
			end
		end
		local totalBNOfflineHeight = numBNetOffline * FRIENDS_BUTTON_NORMAL_HEIGHT + numOfflineBroadcasts * (FRIENDS_BUTTON_LARGE_HEIGHT - FRIENDS_BUTTON_NORMAL_HEIGHT);
		if ( heightLeft < totalBNOfflineHeight ) then
			for i = 1, numBNetOffline do
				if ( BNetBroadcasts[numBNetOnline + i] ) then
					buttonHeight = FRIENDS_BUTTON_LARGE_HEIGHT;
				else
					buttonHeight = FRIENDS_BUTTON_NORMAL_HEIGHT;
				end
				if ( (heightLeft - buttonHeight) < 1 ) then
					return i + buttonIndex, offset - heightLeft, totalScrollHeight;
				else
					heightLeft = heightLeft - buttonHeight;
				end
			end
		end
		heightLeft = heightLeft - totalBNOfflineHeight;
		buttonIndex = buttonIndex + numBNetOffline;
		if ( heightLeft < numWoWOffline * FRIENDS_BUTTON_NORMAL_HEIGHT ) then
			local index = math.floor(heightLeft / FRIENDS_BUTTON_NORMAL_HEIGHT) + 1;
			return buttonIndex + index, offset - heightLeft + (index - 1) * FRIENDS_BUTTON_NORMAL_HEIGHT, totalScrollHeight;
		end
	end
end

function FriendsFrame_SetButton(button, index, firstButton)
	local height;
	local nameText, nameColor, infoText, broadcastText;
		
	if ( firstButton ) then
		FriendsFrameOfflineHeader:Hide();
		DynamicScrollFrame_UnlockAllHighlights(FriendsFrameFriendsScrollFrame);	
	end
	button.buttonType = FriendButtons[index].buttonType;
	button.id = FriendButtons[index].id;
	if ( FriendButtons[index].buttonType == FRIENDS_BUTTON_TYPE_WOW ) then
		local name, level, class, area, connected, status, note = GetFriendInfo(FriendButtons[index].id);
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
		local presenceID, givenName, surname, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText = BNGetFriendInfo(FriendButtons[index].id);
		broadcastText = messageText;
		if ( isOnline ) then
			local _, _, _, _, _, _, _, _, zoneName, _, gameText = BNGetToonInfo(toonID);
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
				button.gameIcon:SetTexture("Interface\\FriendsFrame\\Battlenet-WoWicon");
			elseif ( client == BNET_CLIENT_SC2 ) then
				button.gameIcon:SetTexture("Interface\\FriendsFrame\\Battlenet-Sc2icon");
				infoText = gameText;
			end
			nameColor = FRIENDS_BNET_NAME_COLOR;
			button.gameIcon:Show();
		else
			button.background:SetTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
			button.status:SetTexture(FRIENDS_TEXTURE_OFFLINE);
			nameColor = FRIENDS_GRAY_COLOR;
			button.gameIcon:Hide();
			if ( lastOnline == 0 ) then
				infoText = FRIENDS_LIST_OFFLINE;
			else
				infoText = string.format(BNET_LAST_ONLINE_TIME, FriendsFrame_GetLastOnline(lastOnline));
			end
		end
		if ( givenName and surname ) then
			if ( toonName ) then
				if ( client == BNET_CLIENT_WOW and CanCooperateWithToon(toonID) ) then
					nameText = string.format(BATTLENET_NAME_FORMAT, givenName, surname).." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..toonName..")";
				else
					if ( ENABLE_COLORBLIND_MODE == "1" ) then
						toonName = toonName..CANNOT_COOPERATE_LABEL;
					end
					nameText = string.format(BATTLENET_NAME_FORMAT, givenName, surname).." "..FRIENDS_OTHER_NAME_COLOR_CODE.."("..toonName..")";
				end
			else
				nameText = string.format(BATTLENET_NAME_FORMAT, givenName, surname);
			end
		else
			nameText = UNKNOWN;
		end
		FriendsFrame_SummonButton_Update(button.summonButton);
	else	-- header
		button:Hide();
		FriendsFrameOfflineHeader:Show();
		FriendsFrameOfflineHeader:SetAllPoints(button);
		return FRIENDS_BUTTON_HEADER_HEIGHT;
	end
	
	if ( FriendsFrame.selectedFriendType == FriendButtons[index].buttonType and FriendsFrame.selectedFriend == FriendButtons[index].id ) then
		button:LockHighlight();
	end
	
	button.name:SetText(nameText);
	button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b);
	button.info:SetText(infoText);
	-- don't display a broadcast if the BNetBroadcasts data is out of sync
	if ( broadcastText and broadcastText ~= "" and BNetBroadcasts[FriendButtons[index].id] ) then
		height = FRIENDS_BUTTON_LARGE_HEIGHT;
		button.broadcastMessage:SetText(broadcastText);
		button.broadcastMessage:Show();
		button.broadcastIcon:Show();
	else
		height = FRIENDS_BUTTON_NORMAL_HEIGHT;
		button.broadcastMessage:Hide();
		button.broadcastIcon:Hide();
	end
	-- update the tooltip if hovering over a button
	if ( FriendsTooltip.button == button ) then
		FriendsFrameTooltip_Show(button);
	end
	button:Show();
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
	if ( status == 2 ) then
		statusText = FRIENDS_LIST_AWAY;
	elseif ( status == 3 ) then
		statusText = FRIENDS_LIST_BUSY;
	else
		statusText = FRIENDS_LIST_AVAILABLE;
	end
	GameTooltip:SetOwner(FriendsFrameStatusDropDown, "ANCHOR_RIGHT", -18, 0);
	GameTooltip:SetText(format(FRIENDS_LIST_STATUS_TOOLTIP, statusText));
	GameTooltip:Show();
end

function FriendsFrameStatusDropDown_OnShow(self)
	UIDropDownMenu_Initialize(self, FriendsFrameStatusDropDown_Initialize);
	FriendsFrameStatusDropDown_Update(self);
end

function FriendsFrameStatusDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	local optionText = "\124T%s.tga:16:16:0:0\124t %s";
	info.padding = 8;
	info.checked = nil;
	info.notCheckable = 1;
	info.func = FriendsFrame_SetOnlineStatus;

	info.text = string.format(optionText, FRIENDS_TEXTURE_ONLINE, FRIENDS_LIST_AVAILABLE);
	UIDropDownMenu_AddButton(info);

	info.text = string.format(optionText, FRIENDS_TEXTURE_AFK, FRIENDS_LIST_AWAY);
	UIDropDownMenu_AddButton(info);

	info.text = string.format(optionText, FRIENDS_TEXTURE_DND, FRIENDS_LIST_BUSY);
	UIDropDownMenu_AddButton(info);
end

function FriendsFrameStatusDropDown_Update(self)
	local status;
	self = self or FriendsFrameStatusDropDown;
	if ( UnitIsAFK("player") ) then
		FriendsFrameStatusDropDownStatus:SetTexture(FRIENDS_TEXTURE_AFK);
		status = 2;
	elseif ( UnitIsDND("player") ) then
		FriendsFrameStatusDropDownStatus:SetTexture(FRIENDS_TEXTURE_DND);
		status = 3;
	else
		FriendsFrameStatusDropDownStatus:SetTexture(FRIENDS_TEXTURE_ONLINE);
		status = 1;
	end
	FriendsFrameStatusDropDown.status = status;
end

function FriendsFrame_SetOnlineStatus(button, status)
	status = status or button:GetID();
	if ( status == FriendsFrameStatusDropDown.status ) then
		return;
	end
	if ( status == 1 ) then
		if ( UnitIsAFK("player") ) then
			SendChatMessage("", "AFK");
		elseif ( UnitIsDND("player") ) then
			SendChatMessage("", "DND");
		end
	elseif ( status == 2 ) then
		SendChatMessage("", "AFK");
	else
		SendChatMessage("", "DND");
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
		_, _, broadcastText = BNGetInfo();
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
		local presenceID, givenName, surname, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, broadcastText, noteText, isFriend, broadcastTime = BNGetFriendInfo(self.id);
		-- account name
		if ( givenName and surname ) then
			nameText = format(BATTLENET_NAME_FORMAT, givenName, surname);
		else
			nameText = UNKNOWN;
		end
		anchor = FriendsFrameTooltip_SetLine(FriendsTooltipHeader, nil, nameText);
		-- toon 1
		if ( toonID ) then
			local hasFocus, toonName, client, realmName, faction, race, class, guild, zoneName, level, gameText = BNGetToonInfo(toonID);
			level = level or "";
			race = race or "";
			class = class or "";
			if ( client == BNET_CLIENT_WOW ) then
				if ( CanCooperateWithToon(toonID) ) then
					text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, toonName, level, race, class);
				else
					text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, toonName..CANNOT_COOPERATE_LABEL, level, race, class);
				end
				FriendsFrameTooltip_SetLine(FriendsTooltipToon1Name, nil, text);
				anchor = FriendsFrameTooltip_SetLine(FriendsTooltipToon1Info, nil, string.format(FRIENDS_TOOLTIP_WOW_INFO_TEMPLATE, zoneName, realmName), -4);
			elseif ( client == BNET_CLIENT_SC2 ) then
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
			broadcastText = broadcastText.."|n"..FRIENDS_BROADCAST_TIME_COLOR_CODE..string.format(BNET_BROADCAST_SENT_TIME, FriendsFrame_GetLastOnline(broadcastTime));
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
			if ( lastOnline == 0 ) then
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
			local hasFocus, toonName, client, realmName, faction, race, class, guild, zoneName, level, gameText = BNGetFriendToonInfo(self.id, i);
			-- the focused toon is already at the top of the tooltip
			if ( not hasFocus ) then
				toonIndex = toonIndex + 1;
				if ( toonIndex > FRIENDS_TOOLTIP_MAX_TOONS ) then
					break;
				end
				toonNameString = _G["FriendsTooltipToon"..toonIndex.."Name"];
				toonInfoString = _G["FriendsTooltipToon"..toonIndex.."Info"];
				if ( client == BNET_CLIENT_WOW ) then
					if ( realmName == playerRealmName and PLAYER_FACTION_GROUP[faction] == playerFactionGroup ) then
						text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, toonName, level, race, class);
					else
						text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, toonName..CANNOT_COOPERATE_LABEL, level, race, class);
					end
					gameText = zoneName;
				elseif ( client == BNET_CLIENT_SC2 ) then
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
	if ( factionGroup ) then
		local textureFile = "Interface\\FriendsFrame\\PlusManz-"..factionGroup;
		AddFriendInfoFrameFactionIcon:SetTexture(textureFile);
		AddFriendInfoFrameFactionIcon:Show();
		AddFriendEntryFrameRightIcon:SetTexture(textureFile);
		AddFriendEntryFrameRightIcon:Show();
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
		AddFriendEntryFrameLeftDescription:SetText(BATTLENET_FRIEND_LABEL);
		AddFriendEntryFrameLeftDescription:SetTextColor(1, 1, 1);
		AddFriendEntryFrameLeftIcon:SetVertexColor(1, 1, 1);
		AddFriendEntryFrameLeftFriend:SetVertexColor(1, 1, 1);
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
				if ( string.find(text, "@") ) then
					AddFriendEntryFrame_Expand();
				else
					AddFriendEntryFrame_Collapse();
				end
			end
		else
			AddFriendEntryFrame_Collapse();
			AddFriendNameEditBoxFill:Show();
		end
	end
end

function AddFriendEntryFrame_Expand()
	AddFriendEntryFrame:SetHeight(296);
	AddFriendFrame:SetHeight(296);
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
	AddFriendEntryFrame:SetHeight(218);
	AddFriendFrame:SetHeight(218);
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
	if ( AddFriendFrame.BNconnected and string.find(name, "@") ) then
		BNSendFriendInvite(name, AddFriendNoteEditBox:GetText());
	else
		AddFriend(name);
	end
	StaticPopupSpecial_Hide(AddFriendFrame);
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
			local friendID, givenName, surname, isMutual = BNGetFOFInfo(presenceID, showMutual, showPotential, friendsIndex);
			local name = string.format(BATTLENET_NAME_FORMAT, givenName, surname);
			if ( isMutual ) then
				friendsButton:Disable();
				if ( view ~= FRIENDS_FRIENDS_MUTUAL ) then
					friendsButton.name:SetText(name.." "..HIGHLIGHT_FONT_COLOR_CODE..FRIENDS_FRIENDS_MUTUAL_TEXT);
				else
					friendsButton.name:SetText(name);
				end
				friendsButton.name:SetTextColor(GRAY_FONT_COLOR	.r, GRAY_FONT_COLOR	.g, GRAY_FONT_COLOR	.b);
			elseif ( requested[friendID] ) then
				friendsButton.name:SetText(name.." "..HIGHLIGHT_FONT_COLOR_CODE..FRIENDS_FRIENDS_REQUESTED_TEXT);
				friendsButton:Disable();
				friendsButton.name:SetTextColor(GRAY_FONT_COLOR	.r, GRAY_FONT_COLOR	.g, GRAY_FONT_COLOR	.b);
			else
				friendsButton.name:SetText(name);
				friendsButton:Enable();
				friendsButton.name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
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
	local presenceID, givenName, surname = BNGetFriendInfoByID(presenceID);
	FriendsFriendsFrameTitle:SetFormattedText(FRIENDS_FRIENDS_HEADER, FRIENDS_BNET_NAME_COLOR_CODE..string.format(BATTLENET_NAME_FORMAT, givenName, surname));
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

function CanCooperateWithToon(toonID)
	local hasFocus, toonName, client, realmName, faction = BNGetToonInfo(toonID);
	if ( realmName == playerRealmName and PLAYER_FACTION_GROUP[faction] == playerFactionGroup ) then
		return true;
	else
		return false;
	end
end