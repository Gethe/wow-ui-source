FRIENDS_TO_DISPLAY = 10;
FRIENDS_FRAME_FRIEND_HEIGHT = 34;
IGNORES_TO_DISPLAY = 20;
FRIENDS_FRAME_IGNORE_HEIGHT = 16;
WHOS_TO_DISPLAY = 17;
FRIENDS_FRAME_WHO_HEIGHT = 16;
GUILDMEMBERS_TO_DISPLAY = 14;
FRIENDS_FRAME_GUILD_HEIGHT = 14;
MAX_IGNORE = 50;
MAX_WHOS_FROM_SERVER = 50;
MAX_GUILDCONTROL_OPTIONS = 12;

WHOFRAME_DROPDOWN_LIST = {
	{name = ZONE, sortType = "zone"},
	{name = GUILD, sortType = "guild"},
	{name = RACE, sortType = "race"}
};

RAIDFRAME_SUBFRAMES = { "FriendsListFrame", "IgnoreListFrame", "WhoFrame", "GuildFrame", "RaidFrame" };
function RaidFrame_ShowSubFrame(frameName)
	for index, value in RAIDFRAME_SUBFRAMES do
		if ( value == frameName ) then
			getglobal(value):Show()
		else
			getglobal(value):Hide();	
		end	
	end 
end

function FriendsFrame_OnLoad()
	PanelTemplates_SetNumTabs(this, 5);
	FriendsFrame.selectedTab = 1;
	PanelTemplates_UpdateTabs(this);
	this:RegisterEvent("FRIENDLIST_SHOW");
	this:RegisterEvent("FRIENDLIST_UPDATE");
	this:RegisterEvent("IGNORELIST_UPDATE");
	this:RegisterEvent("WHO_LIST_UPDATE");
	this:RegisterEvent("GUILD_ROSTER_SHOW");
	this:RegisterEvent("GUILD_ROSTER_UPDATE");
	this:RegisterEvent("PLAYER_GUILD_UPDATE");
	FriendsFrame.playersInBotRank = 0;
	FriendsFrame.playerStatusFrame = 1;
	FriendsFrame.selectedFriend = 1;
	FriendsFrame.selectedIgnore = 1;
	FriendsFrame.guildStatus = 0;
	GuildFrame.notesToggle = 1;
	GuildFrame.selectedGuildMember = 0;
	SetGuildRosterSelection(0);
end

function FriendsFrame_OnShow()
	FriendsFrame_Update();
	UpdateMicroButtons();
	PlaySound("igMainMenuOpen");
	GuildFrame.selectedGuildMember = 0;
	SetGuildRosterSelection(0);
	InGuildCheck();
end

function FriendsFrame_Update()
	if ( FriendsFrame.selectedTab == 1 ) then
		ShowFriends();
		FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-BotRight");
		FriendsFrameTitleText:SetText(FRIENDS_LIST);
		RaidFrame_ShowSubFrame("FriendsListFrame");
	elseif ( FriendsFrame.selectedTab == 2 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotRight");
		IgnoreList_Update();
		FriendsFrameTitleText:SetText(IGNORE_LIST);
		RaidFrame_ShowSubFrame("IgnoreListFrame");
	elseif ( FriendsFrame.selectedTab == 3 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotRight");
		FriendsFrameTitleText:SetText(WHO_LIST);
		WhoList_Update();
		RaidFrame_ShowSubFrame("WhoFrame");
	elseif ( FriendsFrame.selectedTab == 4 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotRight");
		local guildName;
		guildName = GetGuildInfo("player");
		FriendsFrameTitleText:SetText(guildName);
		RaidFrame_ShowSubFrame("GuildFrame");
		if ( FriendsFrame.playerStatusFrame ) then
			GuildPlayerStatusFrame:Show();
			GuildStatusFrame:Hide();
			GuildPlayerStatus_Update();
		else
			GuildPlayerStatusFrame:Hide();
			GuildStatusFrame:Show();
			GuildStatus_Update();
		end
	elseif ( FriendsFrame.selectedTab == 5 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight");
		FriendsFrameTitleText:SetText(RAID);
		RaidFrame_ShowSubFrame("RaidFrame");
	end
end

function FriendsFrame_OnHide()
	UpdateMicroButtons();
	PlaySound("igMainMenuClose");
	SetGuildRosterSelection(0);
	GuildFrame.selectedGuildMember = 0;
	GuildControlPopupFrame:Hide();
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
		name, level, class, area, connected = GetFriendInfo(friendIndex);
		nameLocationText = getglobal("FriendsFrameFriendButton"..i.."ButtonTextNameLocation");
		infoText = getglobal("FriendsFrameFriendButton"..i.."ButtonTextInfo");
		if ( not name ) then
			name = UNKNOWN
		end
		if ( connected ) then
			nameLocationText:SetText(format(TEXT(FRIENDS_LIST_TEMPLATE), name, area));
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
	local name, guild, level, race, class, zone, group;
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
		name, guild, level, race, class, zone, group = GetWhoInfo(whoIndex);
		columnTable = { zone, guild, race };
		getglobal("WhoFrameButton"..i.."Name"):SetText(name);
		getglobal("WhoFrameButton"..i.."Level"):SetText(level);
		getglobal("WhoFrameButton"..i.."Class"):SetText(class);
		local variableText = getglobal("WhoFrameButton"..i.."Variable");
		variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)]);
		if ( not group  ) then
			group = "";
		end
		getglobal("WhoFrameButton"..i.."Group"):SetText(getglobal(strupper(group)));
		
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

	PanelTemplates_SetTab(FriendsFrame, 3);
	ShowUIPanel(FriendsFrame);
end

function GuildPlayerStatus_Update()
	PanelTemplates_SetTab(FriendsFrame, 4);
	ShowUIPanel(FriendsFrame);

	FriendsFrame.playersInBotRank = 0;
	FriendsFrame.playerStatusFrame = 1;
	local numGuildMembers = GetNumGuildMembers();
	local name, rank, rankIndex, level, class, zone, group, note, officernote, online;
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
	local maxRankIndex = GuildControlGetNumRanks() - 1;
	local button;
	local onlinecount = 0;
	local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);
	local guildIndex;
	local showScrollBar = nil;
	if ( numGuildMembers > GUILDMEMBERS_TO_DISPLAY ) then
		showScrollBar = 1;
	end

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

	name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

	if ( GetGuildRosterSelection() > 0 ) then
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
		if ( CanGuildRemove() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) ) then
			GuildFrameRemoveMemberButton:Enable();
		else
			GuildFrameRemoveMemberButton:Disable();
		end
		if ( (UnitName("player") == name) or (not online) ) then
			GuildFrameGroupInviteButton:Disable();
		else
			GuildFrameGroupInviteButton:Enable();
		end

		GuildFrame.selectedName = GetGuildRosterInfo(GetGuildRosterSelection()); 
	else
		GuildFramePromoteButton:Disable();
		GuildFrameDemoteButton:Disable();
		GuildFrameRemoveMemberButton:Disable();
		GuildFrameGroupInviteButton:Disable();
	end

	GuildFrameNoteCheck();

	for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
		guildIndex = guildOffset + i;
		button = getglobal("GuildFrameButton"..i);
		button.guildIndex = guildIndex;
		name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(guildIndex);
		getglobal("GuildFrameButton"..i.."Name"):SetText(name);
		getglobal("GuildFrameButton"..i.."Zone"):SetText(zone);
		getglobal("GuildFrameButton"..i.."Level"):SetText(level);
		getglobal("GuildFrameButton"..i.."Class"):SetText(class);
		if ( not group ) then
			group = "";
		end
		getglobal("GuildFrameButton"..i.."Group"):SetText(getglobal(strupper(group)));
		
		if ( not online ) then
			getglobal("GuildFrameButton"..i.."Name"):SetTextColor(0.5, 0.5, 0.5);
			getglobal("GuildFrameButton"..i.."Zone"):SetTextColor(0.5, 0.5, 0.5);
			getglobal("GuildFrameButton"..i.."Level"):SetTextColor(0.5, 0.5, 0.5);
			getglobal("GuildFrameButton"..i.."Class"):SetTextColor(0.5, 0.5, 0.5);
			getglobal("GuildFrameButton"..i.."Group"):SetTextColor(0.5, 0.5, 0.5);
		else
			getglobal("GuildFrameButton"..i.."Name"):SetTextColor(1.0, 0.82, 0.0);
			getglobal("GuildFrameButton"..i.."Zone"):SetTextColor(1.0, 1.0, 1.0);
			getglobal("GuildFrameButton"..i.."Level"):SetTextColor(1.0, 1.0, 1.0);
			getglobal("GuildFrameButton"..i.."Class"):SetTextColor(1.0, 1.0, 1.0);
			getglobal("GuildFrameButton"..i.."Group"):SetTextColor(1.0, 1.0, 1.0);
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

	-- Get number of online members
	for i=1, numGuildMembers, 1 do
		name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(i);
		if ( online ) then
			onlinecount = onlinecount + 1;
		end
		if ( rankIndex == maxRankIndex ) then
			FriendsFrame.playersInBotRank = FriendsFrame.playersInBotRank + 1;
		end
	end

	GuildFrameTotals:SetText(format(GetText("GUILD_TOTAL", nil, numGuildMembers), numGuildMembers));
	GuildFrameOnlineTotals:SetText(format(GUILD_TOTALONLINE, onlinecount));
	GuildFrameGuildListToggleButton:SetText(GUILD_STATUS);

	-- If need scrollbar resize columns
	if ( showScrollBar ) then
		WhoFrameColumn_SetWidth(105, GuildFrameColumnHeader2);
		GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 284, -80);
	else
		WhoFrameColumn_SetWidth(120, GuildFrameColumnHeader2);
		GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 307, -80);
	end


	-- ScrollFrame update
	FauxScrollFrame_Update(GuildListScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );
end

function GuildStatus_Update()
	PanelTemplates_SetTab(FriendsFrame, 4);
	ShowUIPanel(FriendsFrame);
	
	FriendsFrame.playersInBotRank = 0;
	FriendsFrame.playerStatusFrame = nil;
	local numGuildMembers = GetNumGuildMembers();
	local name, rank, rankIndex, level, class, zone, group, note, officernote, online;
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
	local maxRankIndex = GuildControlGetNumRanks() - 1;
	local year, month, day, hour;
	local yearlabel, monthlabel, daylabel, hourlabel;
	local button;
	local onlinecount = 0;
	local guildOffset = FauxScrollFrame_GetOffset(GuildStatusScrollFrame);
	local guildIndex;
	local showScrollBar = nil;
	if ( numGuildMembers > GUILDMEMBERS_TO_DISPLAY ) then
		showScrollBar = 1;
	end

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

	name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

	if ( GetGuildRosterSelection() > 0 ) then
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
		if ( CanGuildRemove() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) ) then
			GuildFrameRemoveMemberButton:Enable();
		else
			GuildFrameRemoveMemberButton:Disable();
		end
		if ( (UnitName("player") == name) or (not online) ) then
			GuildFrameGroupInviteButton:Disable();
		else
			GuildFrameGroupInviteButton:Enable();
		end

		GuildFrame.selectedName = GetGuildRosterInfo(GetGuildRosterSelection()); 
	else
		GuildFramePromoteButton:Disable();
		GuildFrameDemoteButton:Disable();
		GuildFrameRemoveMemberButton:Disable();
		GuildFrameGroupInviteButton:Disable();
	end

	GuildFrameNoteCheck();

	for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
		guildIndex = guildOffset + i;
		button = getglobal("GuildFrameGuildStatusButton"..i);
		button.guildIndex = guildIndex;
		name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(guildIndex);

		getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetText(name);
		getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetText(rank);
		getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetText(note);

		if ( online ) then
			getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(GUILD_ONLINE_LABEL);

			getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetTextColor(1.0, 0.82, 0.0);
			getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetTextColor(1.0, 1.0, 1.0);
			getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetTextColor(1.0, 1.0, 1.0);
			getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetTextColor(1.0, 1.0, 1.0);
		else
			year, month, day, hour = GetGuildRosterLastOnline(guildIndex);
			if ( (year == 0) or (year == nil) ) then
				if ( (month == 0) or (month == nil) ) then
					if ( (day == 0) or (day == nil) ) then
						if ( (hour == 0) or (hour == nil) ) then
							getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(LASTONLINE_MINS);
						else
							getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(format(GetText("LASTONLINE_HOURS", nil, hour), hour));
						end
					else
						getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(format(GetText("LASTONLINE_DAYS", nil, day), day));
					end
				else
					getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(format(GetText("LASTONLINE_MONTHS", nil, month), month));
				end
			else
				getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(format(GetText("LASTONLINE_YEARS", nil, year), year));
			end

			getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetTextColor(0.5, 0.5, 0.5);
			getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetTextColor(0.5, 0.5, 0.5);
			getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetTextColor(0.5, 0.5, 0.5);
			getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetTextColor(0.5, 0.5, 0.5);
		end

		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetWidth(85);
		else
			getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetWidth(100);
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

	-- Get number of online members
	for i=1, numGuildMembers, 1 do
		name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(i);
		if ( online ) then
			onlinecount = onlinecount + 1;
		end
		if ( rankIndex == maxRankIndex ) then
			FriendsFrame.playersInBotRank = FriendsFrame.playersInBotRank + 1;
		end
	end

	GuildFrameTotals:SetText(format(GetText("GUILD_TOTAL", nil, numGuildMembers), numGuildMembers));
	GuildFrameOnlineTotals:SetText(format(GUILD_TOTALONLINE, onlinecount));
	GuildFrameGuildListToggleButton:SetText(PLAYER_STATUS);

	-- If need scrollbar resize column headers
	if ( showScrollBar ) then
		WhoFrameColumn_SetWidth(75, GuildFrameGuildStatusColumnHeader3);
		GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 284, -80);
	else
		WhoFrameColumn_SetWidth(90, GuildFrameGuildStatusColumnHeader3);
		GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 307, -80);
	end


	-- ScrollFrame update
	FauxScrollFrame_Update(GuildStatusScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );
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
	local name, rank, rankIndex, level, class, zone, group, note, officernote, online;
	
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
	elseif ( event == "GUILD_ROSTER_SHOW" ) then
		ShowUIPanel(FriendsFrame);
		if ( FriendsFrame.playerStatusFrame ) then
			GuildPlayerStatus_Update();
		else
			GuildStatus_Update();
		end
		FriendsFrame_Update();
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		if ( GuildFrame:IsVisible() ) then
			if ( arg1 ) then
				GuildRoster();
			end
			if ( FriendsFrame.playerStatusFrame ) then
				GuildPlayerStatus_Update();
			else
				GuildStatus_Update();
			end
			FriendsFrame_Update();
		end
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		if ( FriendsFrame:IsVisible() ) then
			InGuildCheck();
		end
	end
end

function FriendsFrameFriendButton_OnClick()
	SetSelectedFriend(this:GetID());
	FriendsList_Update();
end

function FriendsFrameIgnoreButton_OnClick()
	SetSelectedIgnore(this:GetID());
	IgnoreList_Update();
end

function FriendsFrameWhoButton_OnClick()
	WhoFrame.selectedWho = getglobal("WhoFrameButton"..this:GetID()).whoIndex;
	WhoFrame.selectedName = getglobal("WhoFrameButton"..this:GetID().."Name"):GetText();
	WhoList_Update();
end

function FriendsFrameGuildPlayerStatusButton_OnClick()
	GuildFrame.selectedGuildMember = getglobal("GuildFrameButton"..this:GetID()).guildIndex;
	GuildFrame.selectedName = getglobal("GuildFrameButton"..this:GetID().."Name"):GetText();
	SetGuildRosterSelection(GuildFrame.selectedGuildMember);
	GuildPlayerStatus_Update();
end

function FriendsFrameGuildStatusButton_OnClick()
	GuildFrame.selectedGuildMember = getglobal("GuildFrameGuildStatusButton"..this:GetID()).guildIndex;
	GuildFrame.selectedName = getglobal("GuildFrameGuildStatusButton"..this:GetID().."Name"):GetText();
	SetGuildRosterSelection(GuildFrame.selectedGuildMember);
	GuildStatus_Update();
end

function GuildPlayerStatusButton_OnClick()
	GuildStatusFrame:Hide();
	GuildPlayerStatusFrame:Show();
	GuildPlayerStatus_Update();
end

function GuildStatusButton_OnClick()
	GuildPlayerStatusFrame:Hide();
	GuildStatusFrame:Show();
	GuildStatus_Update();
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
		if ( tab == 4 and not IsInGuild() ) then
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
	PanelTemplates_SetTab(FriendsFrame, 3);
	if ( FriendsFrame:IsVisible() ) then
		FriendsFrame_OnShow();
	else
		ShowUIPanel(FriendsFrame);
	end
end

function ShowIgnorePanel()
	PanelTemplates_SetTab(FriendsFrame, 2);
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
end

function GuildControlPopupFrame_OnHide()
	FriendsFrame.guildControlShow = 0;
end

function GuildControlPopupAcceptButton_OnClick()
	GuildControlSaveRank(GuildControlPopupFrameEditBox:GetText());
	if ( FriendsFrame.playerStatusFrame ) then
		GuildPlayerStatus_Update();
	else
		GuildStatus_Update();
	end
	GuildControlPopupAcceptButton:Disable();
	UIDropDownMenu_SetText(GuildControlPopupFrameEditBox:GetText(), GuildControlPopupFrameDropDown);
	--GuildRoster();
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
	local checkbox = "GuildControlPopupFrameCheckbox";
	
	for i=1, arg.n, 1 do
		getglobal(checkbox..i):SetChecked(arg[i]);
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
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1);
	GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(1));
	GuildControlCheckboxUpdate(GuildControlGetRankFlags());
	CloseDropDownMenus();
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
		PanelTemplates_DisableTab( FriendsFrame, 4 )
		if ( FriendsFrame.selectedTab == 4 ) then
			FriendsFrame.selectedTab = 1;
			FriendsFrame_Update();
		end
	else
		PanelTemplates_EnableTab( FriendsFrame, 4 )
		FriendsFrame_Update();
	end
end

function GuildFrameGuildListToggleButton_OnClick()
	if ( FriendsFrame.playerStatusFrame ) then
		GuildStatusButton_OnClick();
	else
		GuildPlayerStatusButton_OnClick();		
	end
end

function GuildFrameControlButton_OnUpdate()
	if ( FriendsFrame.guildControlShow == 1 ) then
		GuildFrameControlButton:LockHighlight();		
	else
		GuildFrameControlButton:UnlockHighlight();
	end
end

function GuildFrameEditBox_UpdateText()
	if ( (GetGuildRosterSelection() == 0) or (GuildFrame.notesToggle == 1) ) then
		StaticPopup_Show("SET_GUILDMOTD");
	elseif ( (GuildFrame.notesToggle == 2) ) then
		StaticPopup_Show("SET_GUILDPLAYERNOTE");
	elseif ( (GuildFrame.notesToggle == 3) ) then
		StaticPopup_Show("SET_GUILDOFFICERNOTE");
	end
end

function GuildFrameNoteCheck()
	local guildMOTD = GetGuildRosterMOTD();
	local name, rank, rankIndex, level, class, zone, group, note, officernote, online;
	name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

	if ( GetGuildRosterSelection() == 0 ) then
		GuildFrameNotesLabel:SetText(GUILD_MOTD_LABEL)
		if ( CanEditMOTD() ) then
			if ( (not guildMOTD) or (guildMOTD == "") ) then
				guildMOTD = GUILD_MOTD_EDITLABEL;
			end
			GuildFrameEditBox:Enable();
			GuildFrameEditBoxText:SetTextColor(1.0, 1.0, 1.0);
		else
			GuildFrameEditBox:Disable();
			GuildFrameEditBoxText:SetTextColor(0.65, 0.65, 0.65);
		end
		GuildFrameEditBoxText:SetText(guildMOTD);
	else
		if ( GuildFrame.notesToggle == 1 ) then
			GuildFrameNotesLabel:SetText(GUILD_MOTD_LABEL)
			GuildFrameGuildMOTDToggleButton:LockHighlight();
			if ( CanEditMOTD() ) then
				if ( (not guildMOTD) or (guildMOTD == "") ) then
					guildMOTD = GUILD_MOTD_EDITLABEL;
				end
				GuildFrameEditBox:Enable();
				GuildFrameEditBoxText:SetTextColor(1.0, 1.0, 1.0);
			else
				GuildFrameEditBox:Disable();
				GuildFrameEditBoxText:SetTextColor(0.65, 0.65, 0.65);
			end
			GuildFrameEditBoxText:SetText(guildMOTD);
		elseif ( GuildFrame.notesToggle == 2 ) then
			GuildFrameNotesLabel:SetText(GUILD_NOTES_LABEL)
			if ( CanEditPublicNote() ) then
				GuildFrameEditBox:Enable();
				GuildFrameEditBoxText:SetTextColor(1.0, 1.0, 1.0);
				if ( (not note) or (note == "") ) then
					note = GUILD_NOTE_EDITLABEL;
				end
			else
				GuildFrameEditBox:Disable();
				GuildFrameEditBoxText:SetTextColor(0.65, 0.65, 0.65);
			end
			GuildFrameEditBoxText:SetText(note);
		elseif ( GuildFrame.notesToggle == 3 ) then
			GuildFrameNotesLabel:SetText(GUILD_OFFICERNOTES_LABEL)
			if ( CanViewOfficerNote() ) then
				if ( CanEditOfficerNote() ) then
					GuildFrameEditBox:Enable();
					GuildFrameEditBoxText:SetTextColor(1.0, 1.0, 1.0);
					if ( (not officernote) or (officernote == "") ) then
						officernote = GUILD_OFFICERNOTE_EDITLABEL;
					end
				else
					GuildFrameEditBox:Disable();
					GuildFrameEditBoxText:SetTextColor(0.65, 0.65, 0.65);
				end
				GuildFrameEditBoxText:SetText(officernote);
			else
				officernote="";
				GuildFrameEditBoxText:SetText(officernote);
				GuildFrameEditBox:Disable();
				GuildFrame.notesToggle = 1;
			end
		end
	end
end