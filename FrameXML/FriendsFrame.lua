FRIENDS_TO_DISPLAY = 10;
FRIENDS_FRAME_FRIEND_HEIGHT = 34;
IGNORES_TO_DISPLAY = 20;
FRIENDS_FRAME_IGNORE_HEIGHT = 16;
WHOS_TO_DISPLAY = 17;
FRIENDS_FRAME_WHO_HEIGHT = 16;
MAX_IGNORE = 50;
MAX_WHOS_FROM_SERVER = 50;

WHOFRAME_DROPDOWN_LIST = {
	{name = ZONE, sortType = "zone"},
	{name = GUILD, sortType = "guild"},
	{name = RACE, sortType = "race"}
};

FRIENDSFRAME_SUBFRAMES = { "FriendsListFrame", "IgnoreListFrame", "MutedListFrame", "WhoFrame", "ChannelFrame", "RaidFrame" };
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
	if ( event == "SPELL_UPDATE_COOLDOWN" ) then
		FriendsFrame_SummonButton_OnShow(self);
	end
end

function FriendsFrame_SummonButton_OnShow (self)
	local start, duration = GetSummonFriendCooldown();
	
	if ( duration > 0 ) then
		self.duration = duration;
		self.start = start;
	else
		self.duration = nil;
		self.start = nil;
	end
	
	local enable = CanSummonFriend(GetFriendInfo(self:GetID()));
	
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
	local name = GetFriendInfo(self:GetID());
	if ( CanSummonFriend(name) ) then
		SummonFriend(name);
	end
end

function FriendsFrame_ShowDropdown(name, connected, lineID)
	HideDropDownMenu(1);
	if ( connected ) then
		FriendsDropDown.initialize = FriendsFrameDropDown_Initialize;
		FriendsDropDown.displayMode = "MENU";
		FriendsDropDown.name = name;
		FriendsDropDown.lineID = lineID;
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor");
	end
end

function FriendsFrameDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "FRIEND", nil, FriendsDropDown.name);
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
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self.playersInBotRank = 0;
	self.playerStatusFrame = 1;
	self.selectedFriend = 1;
	self.selectedIgnore = 1;
	self.showFriendsList = 1;
end

function FriendsFrame_OnShow()
	VoiceChat_Toggle();
	FriendsFrame.showMutedList = nil;
	FriendsList_Update();
	FriendsFrame_Update();
	UpdateMicroButtons();
	PlaySound("igCharacterInfoTab");
end

function FriendsFrame_Update()
	if ( FriendsFrame.selectedTab == 1 ) then
		if ( FriendsFrame.showFriendsList ) then
			ShowFriends();
			FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
			FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-BotLeft");
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-BotRight");
			FriendsFrameTitleText:SetText(FRIENDS_LIST);
			FriendsFrame_ShowSubFrame("FriendsListFrame");
		elseif ( FriendsFrame.showMutedList ) then
			FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
			FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotLeft");
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotRight");
			FriendsFrameTitleText:SetText(MUTED_LIST);
			FriendsFrame_ShowSubFrame("MutedListFrame");
			MutedList_Update();
		else
			FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
			FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotLeft");
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotRight");
			FriendsFrameTitleText:SetText(IGNORE_LIST);
			FriendsFrame_ShowSubFrame("IgnoreListFrame");
			IgnoreList_Update();
		end
	elseif ( FriendsFrame.selectedTab == 2 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotRight");
		FriendsFrameTitleText:SetText(WHO_LIST);
		FriendsFrame_ShowSubFrame("WhoFrame");
		WhoList_Update();
	elseif ( FriendsFrame.selectedTab == 3 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-ChannelFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-ChannelFrame-BotRight");
		FriendsFrameTitleText:SetText(CHAT_CHANNELS);
		FriendsFrame_ShowSubFrame("ChannelFrame");
	elseif ( FriendsFrame.selectedTab == 4 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight");
		FriendsFrameTitleText:SetText(RAID);
		FriendsFrame_ShowSubFrame("RaidFrame");
	end
end

function FriendsFrame_OnHide()
	UpdateMicroButtons();
	PlaySound("igMainMenuClose");
	RaidInfoFrame:Hide();
	for index, value in pairs(FRIENDSFRAME_SUBFRAMES) do
		_G[value]:Hide();
	end
end

function FriendsList_Update()
	local numFriends = GetNumFriends();
	local nameLocationText, infoText, noteText, noteHiddenText;
	local name, level, class, area, connected, status, note;
	local friendButton, RAFIcon, noteFrame, summonButton, RAF;

	FriendsFrame.selectedFriend = GetSelectedFriend();
	if ( numFriends > 0 ) then
		if ( FriendsFrame.selectedFriend == 0 ) then
			SetSelectedFriend(1);
			FriendsFrame.selectedFriend = GetSelectedFriend();
		end
		name, level, class, area, connected = GetFriendInfo(FriendsFrame.selectedFriend);
		if ( connected ) then
			FriendsFrameSendMessageButton:Enable();
			FriendsFrameGroupInviteButton:Enable();
		else
			FriendsFrameSendMessageButton:Disable();
			FriendsFrameGroupInviteButton:Disable();
		end
		FriendsFrameRemoveFriendButton:Enable();
	else
		FriendsFrameSendMessageButton:Disable();
		FriendsFrameGroupInviteButton:Disable();
		FriendsFrameRemoveFriendButton:Disable();
	end
	
	local friendOffset = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame);
	local friendIndex;
	local nameText, LocationText, noteIcon, classFileName;
	local numOnline = 0;
	
	for i=1, FRIENDS_TO_DISPLAY, 1 do
		friendIndex = friendOffset + i;
		name, level, class, area, connected, status, note, RAF = GetFriendInfo(friendIndex);
		nameText = _G["FriendsFrameFriendButton"..i.."ButtonTextName"];
		LocationText = _G["FriendsFrameFriendButton"..i.."ButtonTextLocation"];
		RAFIcon = _G["FriendsFrameFriendButton"..i.."ButtonTextLink"];
		infoText = _G["FriendsFrameFriendButton"..i.."ButtonTextInfo"];
		noteFrame = _G["FriendsFrameFriendButton"..i.."ButtonTextNote"];
		noteText = _G["FriendsFrameFriendButton"..i.."ButtonTextNoteText"];
		noteHiddenText = _G["FriendsFrameFriendButton"..i.."ButtonTextNoteHiddenText"];
		noteIcon = _G["FriendsFrameFriendButton"..i.."ButtonTextNoteIcon"];
		summonButton = _G["FriendsFrameFriendButton" .. i .. "ButtonTextSummonButton"];
		friendButton = _G["FriendsFrameFriendButton"..i];
		nameText:ClearAllPoints();
		nameText:SetPoint("TOPLEFT", 10, -3);
		noteFrame:SetPoint("RIGHT", nameText, "LEFT", 0, 0);
		friendButton:SetID(friendIndex);
		summonButton:SetID(friendIndex);
		
		summonButton:Hide();
		RAFIcon:Hide();
		if ( not name ) then
			name = UNKNOWN;
		end
		if ( connected ) then
			nameText:SetText(name);
			LocationText:SetFormattedText(FRIENDS_LIST_TEMPLATE, area, status);
			if ( RAF ) then
				summonButton:Show();
				noteFrame:SetPoint("RIGHT", nameText, "LEFT", -28, 0);
				nameText:ClearAllPoints();
				nameText:SetPoint("TOPLEFT", 38, -3);			
			end
			infoText:SetFormattedText(FRIENDS_LEVEL_TEMPLATE, level, class);
			noteIcon:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			numOnline = numOnline + 1;
		else
			nameText:SetFormattedText(FRIENDS_LIST_OFFLINE_TEMPLATE, name);
			LocationText:SetText("");
			infoText:SetText(UNKNOWN);
			noteIcon:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end

		if ( note ) then
			if ( connected ) then
				noteText:SetFormattedText(FRIENDS_LIST_NOTE_TEMPLATE, note);
			else
				noteText:SetFormattedText(FRIENDS_LIST_NOTE_OFFLINE_TEMPLATE, note);
			end
			noteHiddenText:SetText(note);
			local width = noteHiddenText:GetWidth() + infoText:GetWidth();
			local friendButtonWidth = friendButton:GetWidth();
			if ( FriendsFrameFriendsScrollFrameScrollBarTop:IsVisible() ) then
				friendButtonWidth = friendButtonWidth - FriendsFrameFriendsScrollFrameScrollBarTop:GetWidth();
			end
			if ( width > friendButtonWidth ) then
				width = friendButtonWidth - infoText:GetWidth();
			end
			noteText:SetWidth(width);
			noteText:SetHeight(14);
		else
			noteText:SetText("");
		end

		-- Update the highlight
		if ( friendIndex == FriendsFrame.selectedFriend ) then
			friendButton:LockHighlight();
		else
			friendButton:UnlockHighlight();
		end
		
		if ( friendIndex > numFriends ) then
			friendButton:Hide();
		else
			friendButton:Show();
		end
	end
	
	-- ScrollFrame stuff
	FauxScrollFrame_Update(FriendsFrameFriendsScrollFrame, numFriends, FRIENDS_TO_DISPLAY, FRIENDS_FRAME_FRIEND_HEIGHT );
	-- Friend count
	FriendsMicroButtonCount:SetText(numOnline);
end

function IgnoreList_Update()
	local numIgnores = GetNumIgnores();
	local nameText;
	local name;
	local ignoreButton;
	FriendsFrame.selectedIgnore = GetSelectedIgnore();
	if ( numIgnores > 0 ) then
		if ( FriendsFrame.selectedIgnore == 0 ) then
			SetSelectedIgnore(1);
		end
		FriendsFrameStopIgnoreButton:Enable();
	else
		FriendsFrameStopIgnoreButton:Disable();
	end

	local ignoreOffset = FauxScrollFrame_GetOffset(FriendsFrameIgnoreScrollFrame);
	local ignoreIndex;
	for i=1, IGNORES_TO_DISPLAY, 1 do
		ignoreIndex = i + ignoreOffset;
		nameText = _G["FriendsFrameIgnoreButton"..i.."ButtonTextName"];
		nameText:SetText(GetIgnoreName(ignoreIndex));
		ignoreButton = _G["FriendsFrameIgnoreButton"..i];
		ignoreButton:SetID(ignoreIndex);
		-- Update the highlight
		if ( ignoreIndex == FriendsFrame.selectedIgnore ) then
			ignoreButton:LockHighlight();
		else
			ignoreButton:UnlockHighlight();
		end
		
		if ( ignoreIndex > numIgnores ) then
			ignoreButton:Hide();
		else
			ignoreButton:Show();
		end
	end
	
	-- ScrollFrame stuff
	FauxScrollFrame_Update(FriendsFrameIgnoreScrollFrame, numIgnores, IGNORES_TO_DISPLAY, FRIENDS_FRAME_IGNORE_HEIGHT );
end

function MutedList_Update()
	local numMuted = GetNumMutes();
	local nameText;
	local name;
	local muteButton;
	FriendsFrame.selectedMute = GetSelectedMute();
	if ( numMuted > 0 ) then
		if ( FriendsFrame.selectedMute == 0 ) then
			SetSelectedMute(1);
		end
		FriendsFrameUnmuteButton:Enable();
	else
		FriendsFrameUnmuteButton:Disable();
	end

	local muteOffset = FauxScrollFrame_GetOffset(FriendsFrameMutedScrollFrame);
	local muteIndex;
	for i=1, IGNORES_TO_DISPLAY, 1 do
		muteIndex = i + muteOffset;
		nameText = _G["FriendsFrameMutedButton"..i.."ButtonTextName"];
		nameText:SetText(GetMuteName(muteIndex));
		muteButton = _G["FriendsFrameMutedButton"..i];
		muteButton:SetID(muteIndex);
		-- Update the highlight
		if ( muteIndex == FriendsFrame.selectedMute ) then
			muteButton:LockHighlight();
		else
			muteButton:UnlockHighlight();
		end
		
		if ( muteIndex > numMuted ) then
			muteButton:Hide();
		else
			muteButton:Show();
		end
	end
	
	-- ScrollFrame stuff
	FauxScrollFrame_Update(FriendsFrameMutedScrollFrame, numMuted, IGNORES_TO_DISPLAY, FRIENDS_FRAME_IGNORE_HEIGHT );
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
	if ( event == "FRIENDLIST_SHOW" ) then
		FriendsList_Update();
		FriendsFrame_Update();
	elseif ( event == "FRIENDLIST_UPDATE" or event == "PARTY_MEMBERS_CHANGED") then
		FriendsList_Update();
	elseif ( event == "IGNORELIST_UPDATE" ) then
		IgnoreList_Update();
	elseif ( event == "MUTELIST_UPDATE" ) then
		MutedList_Update();
	elseif ( event == "WHO_LIST_UPDATE" ) then
		WhoList_Update();
		FriendsFrame_Update();
	elseif ( event == "VOICE_CHAT_ENABLED_UPDATE" ) then
		VoiceChat_Toggle();
	end
end

function FriendsFrameFriendButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		SetSelectedFriend(self:GetID());
		FriendsList_Update();
	else
		local name, level, class, area, connected = GetFriendInfo(self:GetID());
		FriendsFrame_ShowDropdown(name, connected);
	end
end

function FriendsFrameIgnoreButton_OnClick(self)
	SetSelectedIgnore(self:GetID());
	IgnoreList_Update();
end

function FriendsFrameMuteButton_OnClick(self)
	SetSelectedMute(self:GetID());
	MutedList_Update();
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

function FriendsFrame_UnIgnore()
	local name;
	name = GetIgnoreName(FriendsFrame.selectedIgnore);
	DelIgnore(name);
	PlaySound("UChatScrollButton");
end

function FriendsFrame_UnMute()
	local name;
	name = GetMuteName(FriendsFrame.selectedMute);
	DelMute(name);
	PlaySound("UChatScrollButton");
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
		FriendsFrame.showFriendsList == 1;

	if ( friendsTabShown ) then
		HideUIPanel(FriendsFrame);
	else
		PanelTemplates_SetTab(FriendsFrame, 1);
		FriendsFrame.showFriendsList = 1;
		FriendsFrame_Update();
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
		FriendsFrame.showFriendsList == nil;

	if ( ignoreTabShown ) then
		HideUIPanel(FriendsFrame);
	else
		PanelTemplates_SetTab(FriendsFrame, 1);
		FriendsFrame.showFriendsList = nil;
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