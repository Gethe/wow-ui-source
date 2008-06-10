FRIENDS_TO_DISPLAY = 10;
FRIENDS_FRAME_FRIEND_HEIGHT = 34;
IGNORES_TO_DISPLAY = 20;
FRIENDS_FRAME_IGNORE_HEIGHT = 16;
WHOS_TO_DISPLAY = 17;
FRIENDS_FRAME_WHO_HEIGHT = 16;
GUILDMEMBERS_TO_DISPLAY = 13;
FRIENDS_FRAME_GUILD_HEIGHT = 14;
MAX_IGNORE = 50;
MAX_WHOS_FROM_SERVER = 50;
MAX_GUILDCONTROL_OPTIONS = 12;
CURRENT_GUILD_MOTD = "";
SHOW_OFFLINE_GUILD_MEMBERS = 1;	-- This variable is saved
GUILD_DETAIL_NORM_HEIGHT = 195
GUILD_DETAIL_OFFICER_HEIGHT = 255


WHOFRAME_DROPDOWN_LIST = {
	{name = ZONE, sortType = "zone"},
	{name = GUILD, sortType = "guild"},
	{name = RACE, sortType = "race"}
};

FRIENDSFRAME_SUBFRAMES = { "FriendsListFrame", "IgnoreListFrame", "WhoFrame", "GuildFrame", "RaidFrame" };
function FriendsFrame_ShowSubFrame(frameName)
	for index, value in FRIENDSFRAME_SUBFRAMES do
		if ( value == frameName ) then
			getglobal(value):Show()
		else
			getglobal(value):Hide();
		end	
	end 
end

function FriendsFrame_ShowDropdown(name, connected)
	HideDropDownMenu(1);
	if ( connected ) then
		FriendsDropDown.initialize = FriendsFrameDropDown_Initialize;
		FriendsDropDown.displayMode = "MENU";
		FriendsDropDown.name = name;
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor");
	end
end

function FriendsFrameDropDown_Initialize()
	UnitPopup_ShowMenu(getglobal(UIDROPDOWNMENU_OPEN_MENU), "FRIEND", nil, FriendsDropDown.name);
end

function FriendsFrame_OnLoad()
	PanelTemplates_SetNumTabs(this, 4);
	FriendsFrame.selectedTab = 1;
	PanelTemplates_UpdateTabs(this);
	this:RegisterEvent("FRIENDLIST_SHOW");
	this:RegisterEvent("FRIENDLIST_UPDATE");
	this:RegisterEvent("IGNORELIST_UPDATE");
	this:RegisterEvent("WHO_LIST_UPDATE");
	this:RegisterEvent("GUILD_ROSTER_UPDATE");
	this:RegisterEvent("PLAYER_GUILD_UPDATE");
	this:RegisterEvent("GUILD_MOTD");
	FriendsFrame.playersInBotRank = 0;
	FriendsFrame.playerStatusFrame = 1;
	FriendsFrame.selectedFriend = 1;
	FriendsFrame.selectedIgnore = 1;
	FriendsFrame.guildStatus = 0;
	GuildFrame.notesToggle = 1;
	GuildFrame.selectedGuildMember = 0;
	SetGuildRosterSelection(0);
	CURRENT_GUILD_MOTD = GetGuildRosterMOTD();
end

function FriendsFrame_OnShow()
	FriendsFrame.showFriendsList = 1;
	FriendsFrame_Update();
	UpdateMicroButtons();
	PlaySound("igMainMenuOpen");
	GuildFrame.selectedGuildMember = 0;
	SetGuildRosterSelection(0);
	InGuildCheck();
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
		else
			FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
			FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotLeft");
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotRight");
			IgnoreList_Update();
			FriendsFrameTitleText:SetText(IGNORE_LIST);
			FriendsFrame_ShowSubFrame("IgnoreListFrame");
		end
	elseif ( FriendsFrame.selectedTab == 2 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotRight");
		FriendsFrameTitleText:SetText(WHO_LIST);
		WhoList_Update();
		FriendsFrame_ShowSubFrame("WhoFrame");
	elseif ( FriendsFrame.selectedTab == 3 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotRight");
		local guildName;
		guildName = GetGuildInfo("player");
		FriendsFrameTitleText:SetText(guildName);
		FriendsFrame_ShowSubFrame("GuildFrame");
		GuildStatus_Update();
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
	SetGuildRosterSelection(0);
	GuildFrame.selectedGuildMember = 0;
	GuildControlPopupFrame:Hide();
	GuildMemberDetailFrame:Hide();
	GuildInfoFrame:Hide();
	RaidInfoFrame:Hide();
	for index, value in FRIENDSFRAME_SUBFRAMES do
		getglobal(value):Hide();
	end
end

function FriendsList_Update()
	local numFriends = GetNumFriends();
	local nameLocationText;
	local infoText;
	local name;
	local level;
	local class;
	local area;
	local connected;
	local friendButton;

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
	for i=1, FRIENDS_TO_DISPLAY, 1 do
		friendIndex = friendOffset + i;
		name, level, class, area, connected, status = GetFriendInfo(friendIndex);
		nameLocationText = getglobal("FriendsFrameFriendButton"..i.."ButtonTextNameLocation");
		infoText = getglobal("FriendsFrameFriendButton"..i.."ButtonTextInfo");
		if ( not name ) then
			name = UNKNOWN
		end
		if ( connected ) then
			nameLocationText:SetText(format(TEXT(FRIENDS_LIST_TEMPLATE), name, area, status));
			infoText:SetText(format(TEXT(FRIENDS_LEVEL_TEMPLATE), level, class));
		else
			nameLocationText:SetText(format(TEXT(FRIENDS_LIST_OFFLINE_TEMPLATE), name));
			infoText:SetText(TEXT(UNKNOWN));
		end
		friendButton = getglobal("FriendsFrameFriendButton"..i);
		friendButton:SetID(friendIndex);
		
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
		nameText = getglobal("FriendsFrameIgnoreButton"..i.."ButtonTextName");
		nameText:SetText(GetIgnoreName(ignoreIndex));
		ignoreButton = getglobal("FriendsFrameIgnoreButton"..i);
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

function WhoList_Update()
	local numWhos, totalCount = GetNumWhoResults();
	local name, guild, level, race, class, zone;
	local button;
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
	WhoFrameTotals:SetText(format(GetText("WHO_FRAME_TOTAL_TEMPLATE", nil, totalCount), totalCount).."  "..displayedText);
	for i=1, WHOS_TO_DISPLAY, 1 do
		whoIndex = whoOffset + i;
		button = getglobal("WhoFrameButton"..i);
		button.whoIndex = whoIndex;
		name, guild, level, race, class, zone = GetWhoInfo(whoIndex);
		columnTable = { zone, guild, race };
		getglobal("WhoFrameButton"..i.."Name"):SetText(name);
		getglobal("WhoFrameButton"..i.."Level"):SetText(level);
		getglobal("WhoFrameButton"..i.."Class"):SetText(class);
		local variableText = getglobal("WhoFrameButton"..i.."Variable");
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
		WhoFrameColumn_SetWidth(105, WhoFrameColumnHeader2);
		UIDropDownMenu_SetWidth(80, WhoFrameDropDown);
	else
		WhoFrameColumn_SetWidth(120, WhoFrameColumnHeader2);
		UIDropDownMenu_SetWidth(95, WhoFrameDropDown);
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
	local name, rank, rankIndex, level, class, zone, note, officernote, online;
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
	local maxRankIndex = GuildControlGetNumRanks() - 1;
	local button;
	local onlinecount = 0;
	local guildIndex;

	-- Get selected guild member info
	name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());
	GuildFrame.selectedName = name;
	-- If there's a selected guildmember
	if ( GetGuildRosterSelection() > 0 ) then
		-- Update the guild member details frame
		GuildMemberDetailName:SetText(GuildFrame.selectedName);
		GuildMemberDetailLevel:SetText(format(TEXT(FRIENDS_LEVEL_TEMPLATE), level, class));
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
	GuildFrameTotals:SetText(format(GetText("GUILD_TOTAL", nil, numGuildMembers), numGuildMembers));
	GuildFrameOnlineTotals:SetText(format(GUILD_TOTALONLINE, onlinecount));

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
			button = getglobal("GuildFrameButton"..i);
			button.guildIndex = guildIndex;
			name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(guildIndex);
			getglobal("GuildFrameButton"..i.."Name"):SetText(name);
			getglobal("GuildFrameButton"..i.."Zone"):SetText(zone);
			getglobal("GuildFrameButton"..i.."Level"):SetText(level);
			getglobal("GuildFrameButton"..i.."Class"):SetText(class);
			if ( not online ) then
				getglobal("GuildFrameButton"..i.."Name"):SetTextColor(0.5, 0.5, 0.5);
				getglobal("GuildFrameButton"..i.."Zone"):SetTextColor(0.5, 0.5, 0.5);
				getglobal("GuildFrameButton"..i.."Level"):SetTextColor(0.5, 0.5, 0.5);
				getglobal("GuildFrameButton"..i.."Class"):SetTextColor(0.5, 0.5, 0.5);
			else
				getglobal("GuildFrameButton"..i.."Name"):SetTextColor(1.0, 0.82, 0.0);
				getglobal("GuildFrameButton"..i.."Zone"):SetTextColor(1.0, 1.0, 1.0);
				getglobal("GuildFrameButton"..i.."Level"):SetTextColor(1.0, 1.0, 1.0);
				getglobal("GuildFrameButton"..i.."Class"):SetTextColor(1.0, 1.0, 1.0);
			end

			-- If need scrollbar resize columns
			if ( showScrollBar ) then
				getglobal("GuildFrameButton"..i.."Zone"):SetWidth(95);
			else
				getglobal("GuildFrameButton"..i.."Zone"):SetWidth(110);
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
			WhoFrameColumn_SetWidth(105, GuildFrameColumnHeader2);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 284, -67);
		else
			WhoFrameColumn_SetWidth(120, GuildFrameColumnHeader2);
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

		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i;
			button = getglobal("GuildFrameGuildStatusButton"..i);
			button.guildIndex = guildIndex;
			name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(guildIndex);

			getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetText(name);
			getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetText(rank);
			getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetText(note);

			if ( online ) then
				if ( status == "" ) then
					getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(GUILD_ONLINE_LABEL);
				else
					getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(status);
				end

				getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetTextColor(1.0, 0.82, 0.0);
				getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetTextColor(1.0, 1.0, 1.0);
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetTextColor(1.0, 1.0, 1.0);
				getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetTextColor(1.0, 1.0, 1.0);
			else
				getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(GuildFrame_GetLastOnline(guildIndex));
				getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetTextColor(0.5, 0.5, 0.5);
				getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetTextColor(0.5, 0.5, 0.5);
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetTextColor(0.5, 0.5, 0.5);
				getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetTextColor(0.5, 0.5, 0.5);
			end

			-- If need scrollbar resize columns
			if ( showScrollBar ) then
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetWidth(70);
			else
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetWidth(85);
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
			WhoFrameColumn_SetWidth(75, GuildFrameGuildStatusColumnHeader3);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 284, -67);
		else
			WhoFrameColumn_SetWidth(90, GuildFrameGuildStatusColumnHeader3);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 307, -67);
		end
		
		-- ScrollFrame update
		FauxScrollFrame_Update(GuildListScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );

		GuildPlayerStatusFrame:Hide();
		GuildStatusFrame:Show();
	end
end

function WhoFrameColumn_SetWidth(width, frame)
	if ( not frame ) then
		frame = this;
	end
	frame:SetWidth(width);
	getglobal(frame:GetName().."Middle"):SetWidth(width - 9);
end

function WhoFrameDropDown_Initialize()
	local info;
	for i=1, getn(WHOFRAME_DROPDOWN_LIST), 1 do
		info = {};
		info.text = WHOFRAME_DROPDOWN_LIST[i].name;
		info.func = WhoFrameDropDownButton_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function WhoFrameDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, WhoFrameDropDown_Initialize);
	UIDropDownMenu_SetWidth(80);
	UIDropDownMenu_SetButtonWidth(24);
	UIDropDownMenu_JustifyText("LEFT", WhoFrameDropDown)
end

function WhoFrameDropDownButton_OnClick()
	UIDropDownMenu_SetSelectedID(WhoFrameDropDown, this:GetID());
	WhoList_Update();
end

function FriendsFrame_OnEvent()
	if ( event == "FRIENDLIST_SHOW" ) then
		FriendsList_Update();
		FriendsFrame_Update();
	elseif ( event == "FRIENDLIST_UPDATE" ) then
		FriendsList_Update();
	elseif ( event == "IGNORELIST_UPDATE" ) then
		IgnoreList_Update();
	elseif ( event == "WHO_LIST_UPDATE" ) then
		WhoList_Update();
		FriendsFrame_Update();
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		if ( GuildFrame:IsVisible() ) then
			if ( arg1 ) then
				GuildRoster();
			end
			GuildStatus_Update();
			FriendsFrame_Update();
		end
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		if ( FriendsFrame:IsVisible() ) then
			InGuildCheck();
		end
	elseif ( event == "GUILD_MOTD") then
		CURRENT_GUILD_MOTD = arg1;
		GuildFrameNotesText:SetText(CURRENT_GUILD_MOTD);
	end
end

function FriendsFrameFriendButton_OnClick(button)
	if ( button == "LeftButton" ) then
		SetSelectedFriend(this:GetID());
		FriendsList_Update();
	else
		local name, level, class, area, connected = GetFriendInfo(this:GetID());
		FriendsFrame_ShowDropdown(name, connected);
	end
end

function FriendsFrameIgnoreButton_OnClick()
	SetSelectedIgnore(this:GetID());
	IgnoreList_Update();
end

function FriendsFrameWhoButton_OnClick(button)
	if ( button == "LeftButton" ) then
		WhoFrame.selectedWho = getglobal("WhoFrameButton"..this:GetID()).whoIndex;
		WhoFrame.selectedName = getglobal("WhoFrameButton"..this:GetID().."Name"):GetText();
		WhoList_Update();
	else
		local name = getglobal("WhoFrameButton"..this:GetID().."Name"):GetText();
		FriendsFrame_ShowDropdown(name, 1);
	end
end

function FriendsFrameGuildStatusButton_OnClick(button)
	if ( button == "LeftButton" ) then
		GuildFrame.previousSelectedGuildMember = GuildFrame.selectedGuildMember;
		GuildFrame.selectedGuildMember = this.guildIndex;
		GuildFrame.selectedName = getglobal(this:GetName().."Name"):GetText();
		SetGuildRosterSelection(GuildFrame.selectedGuildMember);
		-- Toggle guild details frame
		if ( GuildMemberDetailFrame:IsVisible() and (GuildFrame.previousSelectedGuildMember and (GuildFrame.previousSelectedGuildMember == GuildFrame.selectedGuildMember)) ) then
			GuildMemberDetailFrame:Hide();
			GuildFrame.selectedGuildMember = 0;
			SetGuildRosterSelection(0);
		else
			GuildMemberDetailFrame:Show();
			GuildControlPopupFrame:Hide();
			GuildInfoFrame:Hide();
		end
		GuildStatus_Update();
	else
		local guildIndex = this.guildIndex;
		local name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(guildIndex);
		FriendsFrame_ShowDropdown(name, online);
	end
end

function FriendsFrame_UnIgnore()
	local name;
	name = GetIgnoreName(FriendsFrame.selectedIgnore);
	DelIgnore(name);
end

function FriendsFrame_RemoveFriend()
	if ( FriendsFrame.selectedFriend ) then
		RemoveFriend(FriendsFrame.selectedFriend);
	end
end

function FriendsFrame_SendMessage()
	local name = GetFriendInfo(FriendsFrame.selectedFriend);
	if ( not ChatFrameEditBox:IsVisible() ) then
		ChatFrame_OpenChat("/w "..name.." ");
	else
		ChatFrameEditBox:SetText("/w "..name.." ");
	end
	ChatEdit_ParseText(ChatFrame1.editBox, 0);
end

function FriendsFrame_GroupInvite()
	local name = GetFriendInfo(FriendsFrame.selectedFriend);
	InviteByName(name);
end

function ToggleFriendsFrame(tab)
	if ( not tab ) then
		if ( FriendsFrame:IsVisible() ) then
			HideUIPanel(FriendsFrame);
		else
			ShowUIPanel(FriendsFrame);
		end
	else
		-- If not in a guild don't do anything when they try to toggle the guild tab
		if ( tab == 3 and not IsInGuild() ) then
			return;
		end
		if ( tab == PanelTemplates_GetSelectedTab(FriendsFrame) and FriendsFrame:IsVisible() ) then
			HideUIPanel(FriendsFrame);
			return;
		end
		PanelTemplates_SetTab(FriendsFrame, tab);
		if ( FriendsFrame:IsVisible() ) then
			FriendsFrame_OnShow();
		else
			ShowUIPanel(FriendsFrame);
		end
	end
	
end

function WhoFrameEditBox_OnEnterPressed()
	SendWho(WhoFrameEditBox:GetText());
	WhoFrameEditBox:ClearFocus();
end

function ShowWhoPanel()
	PanelTemplates_SetTab(FriendsFrame, 2);
	if ( FriendsFrame:IsVisible() ) then
		FriendsFrame_OnShow();
	else
		ShowUIPanel(FriendsFrame);
	end
end

function ShowIgnorePanel()
	--PanelTemplates_SetTab(FriendsFrame, 2);
	if ( FriendsFrame:IsVisible() ) then
		FriendsFrame_OnShow();
	else
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
	GuildControlCheckboxUpdate(GuildControlGetRankFlags());

	GuildControlPopupFrameCheckbox1Label:SetText(GUILDCONTROL_OPTION1);
	GuildControlPopupFrameCheckbox2Label:SetText(GUILDCONTROL_OPTION2);
	GuildControlPopupFrameCheckbox3Label:SetText(GUILDCONTROL_OPTION3);
	GuildControlPopupFrameCheckbox4Label:SetText(GUILDCONTROL_OPTION4);
	GuildControlPopupFrameCheckbox5Label:SetText(GUILDCONTROL_OPTION5);
	GuildControlPopupFrameCheckbox6Label:SetText(GUILDCONTROL_OPTION6);
	GuildControlPopupFrameCheckbox7Label:SetText(GUILDCONTROL_OPTION7);
	GuildControlPopupFrameCheckbox8Label:SetText(GUILDCONTROL_OPTION8);
	GuildControlPopupFrameCheckbox9Label:SetText(GUILDCONTROL_OPTION9);
	GuildControlPopupFrameCheckbox10Label:SetText(GUILDCONTROL_OPTION10);
	GuildControlPopupFrameCheckbox11Label:SetText(GUILDCONTROL_OPTION11);
	GuildControlPopupFrameCheckbox12Label:SetText(GUILDCONTROL_OPTION12);
	GuildControlPopupFrameCheckbox13Label:SetText(GUILDCONTROL_OPTION13);
end

function GuildControlPopupFrame_OnShow()
	FriendsFrame.guildControlShow = 1;
	GuildControlSetRank(1);
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1);
	UIDropDownMenu_SetText(GuildControlGetRankName(1), GuildControlPopupFrameDropDown);
	GuildControlCheckboxUpdate(GuildControlGetRankFlags());
	GuildControlPopupAcceptButton:Disable();
	-- Hide center frame if there is one
	if ( GetCenterFrame() ) then
		HideUIPanel(GetCenterFrame());
	end
	-- Hide guild member detail frame if its open
	GuildMemberDetailFrame:Hide();
	GuildInfoFrame:Hide();
end

function GuildControlPopupFrame_OnHide()
	FriendsFrame.guildControlShow = 0;
end

function GuildControlPopupAcceptButton_OnClick()
	GuildControlSaveRank(GuildControlPopupFrameEditBox:GetText());
	GuildStatus_Update();
	GuildControlPopupAcceptButton:Disable();
	UIDropDownMenu_SetText(GuildControlPopupFrameEditBox:GetText(), GuildControlPopupFrameDropDown);
	GuildControlPopupFrame:Hide();
end

function GuildControlPopupFrameDropDown_OnLoad()
	UIDropDownMenu_Initialize(GuildControlPopupFrameDropDown, GuildControlPopupFrameDropDown_Initialize);
	UIDropDownMenu_SetWidth(110);
	UIDropDownMenu_SetButtonWidth(54);
	UIDropDownMenu_JustifyText("LEFT", GuildControlPopupFrameDropDown);
end

function GuildControlPopupFrameDropDown_Initialize()
	local info;
	for i=1, GuildControlGetNumRanks(), 1 do
		info = {};
		info.text = GuildControlGetRankName(i);
		info.func = GuildControlPopupFrameDropDownButton_OnClick;
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

function GuildControlPopupFrameDropDownButton_OnClick()
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, this:GetID());
	GuildControlSetRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
	GuildControlCheckboxUpdate(GuildControlGetRankFlags());
	GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
	GuildControlPopupFrameAddRankButton_OnUpdate();
	GuildControlPopupFrameRemoveRankButton_OnUpdate();
	GuildControlPopupAcceptButton:Disable();
end

function GuildControlCheckboxUpdate(...)
	local checkbox;
	for i=1, arg.n, 1 do
		checkbox = getglobal("GuildControlPopupFrameCheckbox"..i)
		if ( checkbox ) then
			checkbox:SetChecked(arg[i]);
		else
			message("GuildControlPopupFrameCheckbox"..i.." does not exist!");
		end
	end
end

function GuildControlPopupFrameAddRankButton_OnUpdate()
	if ( GuildControlGetNumRanks() >= 10 ) then
		GuildControlPopupFrameAddRankButton:Disable();
	else
		GuildControlPopupFrameAddRankButton:Enable();
	end
end

function GuildControlPopupFrameRemoveRankButton_OnClick()
	GuildControlDelRank(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
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

function GuildControlPopupFrameRemoveRankButton_OnUpdate()
	if ( (UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown) == GuildControlGetNumRanks()) and (GuildControlGetNumRanks() > 5) ) then
		GuildControlPopupFrameRemoveRankButton:Show();
		if ( FriendsFrame.playersInBotRank > 0 ) then
			GuildControlPopupFrameRemoveRankButton:Disable();
		else
			GuildControlPopupFrameRemoveRankButton:Enable();
		end
	else
		GuildControlPopupFrameRemoveRankButton:Hide();
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
	year, month, day, hour = GetGuildRosterLastOnline(guildIndex);
	local lastOnline;
	if ( (year == 0) or (year == nil) ) then
		if ( (month == 0) or (month == nil) ) then
			if ( (day == 0) or (day == nil) ) then
				if ( (hour == 0) or (hour == nil) ) then
					lastOnline = LASTONLINE_MINS;
				else
					lastOnline = format(GetText("LASTONLINE_HOURS", nil, hour), hour);
				end
			else
				lastOnline = format(GetText("LASTONLINE_DAYS", nil, day), day);
			end
		else
			lastOnline = format(GetText("LASTONLINE_MONTHS", nil, month), month);
		end
	else
		lastOnline = format(GetText("LASTONLINE_YEARS", nil, year), year);
	end
	return lastOnline;
end

function ToggleGuildInfoFrame()
	if ( GuildInfoFrame:IsShown() ) then
		GuildInfoFrame:Hide();
	else
		GuildInfoFrame:Show();
		GuildMemberDetailFrame:Hide();
		GuildControlPopupFrame:Hide();
	end
end