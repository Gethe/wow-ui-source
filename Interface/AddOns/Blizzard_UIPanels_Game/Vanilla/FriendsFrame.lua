-- See FriendsFrame_Shared.lua for functions shared across Classic expansions

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
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("GROUP_JOINED");
	self:RegisterEvent("GROUP_LEFT");
	self:RegisterEvent("STREAM_VIEW_MARKER_UPDATED");
	self:RegisterEvent("CLUB_INVITATION_ADDED_FOR_SELF");
	self:RegisterEvent("CLUB_INVITATION_REMOVED_FOR_SELF");
	self:RegisterEvent("GUILD_RENAME_REQUIRED");
	self:RegisterEvent("REQUIRED_GUILD_RENAME_RESULT");
	self.playerStatusFrame = 1;
	self.selectedFriend = 1;
	self.selectedIgnore = 1;
	GuildFrame.hasForcedNameChange = GetGuildRenameRequired();
	-- friends list
	local scrollFrame = FriendsFrameFriendsScrollFrame;
	scrollFrame.update = FriendsFrame_UpdateFriends;
	scrollFrame.dynamic = FriendsList_GetScrollFrameTopButton;
	scrollFrame.dividerPool = CreateFramePool("FRAME", self, "FriendsFrameFriendDividerTemplate");
	scrollFrame.invitePool = CreateFramePool("FRAME", self, "FriendsFrameFriendInviteTemplate");
	-- can't do this in XML because we're inheriting from a template
	scrollFrame.PendingInvitesHeaderButton:SetParent(scrollFrame.ScrollChild);
	FriendsFrameFriendsScrollFrameScrollBarTrack:Hide();
	FriendsFrameFriendsScrollFrameScrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(scrollFrame, "FriendsFrameButtonTemplate");
	FriendsFrameIcon:SetTexture("Interface\\FriendsFrame\\FriendsFrameScrollIcon");

	FriendsFrameBroadcastInputClearButton.icon:SetVertexColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
	if ( not BNFeaturesEnabled() ) then
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

function FriendsFrame_OnEvent(self, event, ...)
	if ( event == "SPELL_UPDATE_COOLDOWN" ) then
		if ( self:IsShown() ) then
			local buttons = FriendsFrameFriendsScrollFrame.buttons;
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
				FriendsFriendsList_Update();
			end
		end
	elseif ( event == "BN_CUSTOM_MESSAGE_CHANGED" ) then
		local arg1 = ...;
		if ( arg1 ) then	--There is no bnetIDAccount given if this is ourself.
			FriendsList_Update();
		else
			FriendsFrameBattlenetFrame_UpdateBroadcast();
		end
	elseif ( event == "BN_CUSTOM_MESSAGE_LOADED" ) then
		FriendsFrameBattlenetFrame_UpdateBroadcast();
	elseif ( event == "BN_FRIEND_INVITE_ADDED" ) then
		-- flash the invites header if collapsed
		local collapsed = GetCVarBool("friendInvitesCollapsed");
		if ( collapsed ) then
			FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton.Flash.Anim:Play();
		end
		FriendsList_Update();
	elseif ( event == "BN_FRIEND_INVITE_LIST_INITIALIZED" ) then
		FriendsList_Update();
	elseif ( event == "BN_FRIEND_INVITE_REMOVED" ) then
		FriendsList_Update();
	elseif ( event == "IGNORELIST_UPDATE" or event == "BN_BLOCK_LIST_UPDATED" ) then
		IgnoreList_Update();
	elseif ( event == "WHO_LIST_UPDATE" ) then
		WhoFrame.selectedWho = nil;
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
		end
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		FriendsFrame_CheckDethroneStatus();

		if ( GuildFrame:IsVisible() ) then
			local canRequestGuildRoster = ...;
			if ( canRequestGuildRoster ) then
				C_GuildInfo.GuildRoster();
			end
			GuildStatus_Update();
			FriendsFrame_Update();
		end
	elseif ( event == "STREAM_VIEW_MARKER_UPDATED" ) then
		BlizzardGroups_UpdateNotifications();
	elseif ( event == "CLUB_INVITATION_ADDED_FOR_SELF" or event == "CLUB_INVITATION_REMOVED_FOR_SELF" ) then
		BlizzardGroups_UpdateShowTab();
		BlizzardGroups_UpdateNotifications();
	elseif ( event == "GUILD_RENAME_REQUIRED" ) then
		GuildFrame.hasForcedNameChange = ...;
		GuildFrame_CheckName();
	elseif ( event == "REQUIRED_GUILD_RENAME_RESULT" ) then
		local success = ...
		if ( success ) then
			GuildFrame.hasForcedNameChange = GetGuildRenameRequired();
			GuildFrame_CheckName();
		else
			UIErrorsFrame:AddMessage(ERR_GUILD_NAME_INVALID, 1.0, 0.1, 0.1, 1.0);
		end
	end
end

function FriendsFrame_InviteOrRequestToJoin(guid, gameAccountID)
	local inviteType = GetDisplayedInviteType(guid);
	if ( inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" ) then
		BNInviteFriend(gameAccountID);
	elseif ( inviteType == "REQUEST_INVITE" ) then
		BNRequestInviteFriend(gameAccountID);
	end
end

-- ============================================ GUILD ===============================================================================
function GuildControlPopupFrameDropDown_OnLoad()
	UIDropDownMenu_Initialize(GuildControlPopupFrameDropDown, GuildControlPopupFrameDropDown_Initialize);
	UIDropDownMenu_SetWidth(GuildControlPopupFrameDropDown, 110);
	UIDropDownMenu_SetButtonWidth(GuildControlPopupFrameDropDown, 54);
	UIDropDownMenu_JustifyText(GuildControlPopupFrameDropDown, "LEFT");
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

function GuildControlPopupFrame_OnLoad()
	GuildControlCheckboxUpdate(C_GuildInfo.GuildControlGetRankFlags(1));

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

function GuildControlPopupFrameDropDownButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, self:GetID());
	GuildControlSetRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
	GuildControlCheckboxUpdate(C_GuildInfo.GuildControlGetRankFlags(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
	GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
	GuildControlPopupFrameAddRankButton_OnUpdate();
	GuildControlPopupFrameRemoveRankButton_OnUpdate();
	GuildControlPopupAcceptButton:Disable();
end

function GuildControlCheckboxUpdate(flags)
	for i=1, GUILD_NUM_RANK_FLAGS do
		checkbox = _G["GuildControlPopupFrameCheckbox"..i];
		if ( checkbox ) then
			checkbox:SetChecked(flags[i]);
		else
			message("GuildControlPopupFrameCheckbox"..i.." does not exist!");
		end
	end
end

function GuildControlPopupFrame_OnShow()
	FriendsFrame.guildControlShow = 1;
	GuildControlSetRank(1);
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1);
	UIDropDownMenu_SetText(GuildControlPopupFrameDropDown, GuildControlGetRankName(1));
	GuildControlCheckboxUpdate(C_GuildInfo.GuildControlGetRankFlags(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
	GuildControlPopupAcceptButton:Disable();
	-- Hide center frame if there is one
	if ( GetUIPanel("center") ) then
		HideUIPanel(GetUIPanel("center"), true);
	end
	-- Hide guild member detail frame if its open
	GuildMemberDetailFrame:Hide();
	GuildInfoFrame:Hide();
	GuildControlPopupFrameRemoveRankButton_OnUpdate();
end

function GuildControlPopupFrame_OnHide()
	FriendsFrame.guildControlShow = 0;
end

function GuildControlPopupAcceptButton_OnClick()
	GuildControlSaveRank(GuildControlPopupFrameEditBox:GetText());
	GuildStatus_Update();
	GuildControlPopupAcceptButton:Disable();
	UIDropDownMenu_SetText(GuildControlPopupFrameDropDown, GuildControlPopupFrameEditBox:GetText());
	GuildControlPopupFrame:Hide();
end

function GuildControlPopupFrameRemoveRankButton_OnClick()
	GuildControlDelRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
	GuildControlSetRank(1);
	GuildStatus_Update();
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1);
	GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(1));
	GuildControlCheckboxUpdate(C_GuildInfo.GuildControlGetRankFlags(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
	CloseDropDownMenus();
	GuildControlPopupFrameRemoveRankButton_OnUpdate();
end

function GuildControlPopupFrameRemoveRankButton_OnUpdate()
	if ( (UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown) == GuildControlGetNumRanks()) and (GuildControlGetNumRanks() > 5) ) then
		GuildControlPopupFrameRemoveRankButton:Show();
		if ( GetNumMembersInRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)) > 0 ) then
			GuildControlPopupFrameRemoveRankButton:Disable();
		else
			GuildControlPopupFrameRemoveRankButton:Enable();
		end
	else
		GuildControlPopupFrameRemoveRankButton:Hide();
	end
end

function FriendsFrameGuildStatusButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		GuildFrame.previousSelectedGuildMember = GuildFrame.selectedGuildMember;
		GuildFrame.selectedGuildMember = self.guildIndex;
		GuildFrame.selectedName = getglobal(self:GetName().."Name"):GetText();
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
		local guildIndex = self.guildIndex;
		local name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(guildIndex);
		FriendsFrame_ShowDropdown(name, online);
	end
end

function GuildStatus_Update()
	-- Set the tab
	PanelTemplates_SetTab(FriendsFrame, 3);
	-- Show the frame
	ShowUIPanel(FriendsFrame);

	local totalMembers, onlineMembers, onlineAndMobileMembers = GetNumGuildMembers();
	local numGuildMembers = 0;
	local showOffline = GetGuildRosterShowOffline();
	if (showOffline) then
		numGuildMembers = totalMembers;
	else
		numGuildMembers = onlineMembers;
	end
	local fullName, rank, rankIndex, level, class, zone, note, officernote, online;
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
	local maxRankIndex = GuildControlGetNumRanks() - 1;
	local button;
	local onlinecount = 0;
	local guildIndex;

	-- Get selected guild member info
	fullName, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());
	GuildFrame.selectedName = fullName;
	-- If there's a selected guildmember
	if ( GetGuildRosterSelection() > 0 ) then
		local displayedName = Ambiguate(fullName, "guild");
		-- Update the guild member details frame
		GuildMemberDetailName:SetText(displayedName);
		GuildMemberDetailLevel:SetText(format(FRIENDS_LEVEL_TEMPLATE, level, class));
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
		if ( C_GuildInfo.CanViewOfficerNote() ) then
			if ( C_GuildInfo.CanEditOfficerNote() ) then
				if ( (not officernote) or (officernote == "") ) then
					officernote = GUILD_OFFICERNOTE_EDITLABEL;
				end
				OfficerNoteText:SetTextColor(1.0, 1.0, 1.0);
			else
				OfficerNoteText:SetTextColor(0.65, 0.65, 0.65);
			end
			GuildMemberOfficerNoteBackground:EnableMouse(C_GuildInfo.CanEditOfficerNote());
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
		if ( not GuildFrameDemoteButton:IsEnabled() and not GuildFramePromoteButton:IsEnabled() ) then
			GuildFramePromoteButton:Hide();
			GuildFrameDemoteButton:Hide();
			GuildMemberDetailRankText:SetPoint("RIGHT", "GuildMemberDetailFrame", "RIGHT", -10, 0);
		else
			GuildFramePromoteButton:Show();
			GuildFrameDemoteButton:Show();
			GuildMemberDetailRankText:SetPoint("RIGHT", "GuildFramePromoteButton", "LEFT", 3, 0);
		end
		if ( CanGuildRemove() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) ) then
			GuildMemberRemoveButton:Enable();
		else
			GuildMemberRemoveButton:Disable();
		end
		if ( (UnitName("player") == displayedName) or (not online) ) then
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
			--guildMOTD = GUILD_MOTD_EDITLABEL; -- A bug in the 1.12 lua code caused this to never actually appear.
		end
		GuildFrameNotesText:SetTextColor(1.0, 1.0, 1.0);
		GuildMOTDEditButton:Enable();
	else
		GuildFrameNotesText:SetTextColor(0.65, 0.65, 0.65);
		GuildMOTDEditButton:Disable();
	end
	GuildFrameNotesText:SetText(guildMOTD);

	-- Scrollbar stuff
	local showScrollBar = nil;
	if ( numGuildMembers > GUILDMEMBERS_TO_DISPLAY ) then
		showScrollBar = 1;
	end

	GuildFrameTotals:SetText(format(GetText("GUILD_TOTAL", nil, numGuildMembers), numGuildMembers));
	GuildFrameOnlineTotals:SetText(format(GUILD_TOTALONLINE, onlineMembers));

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

			fullName, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(guildIndex);
			if (fullName and (showOffline or online)) then
				local displayedName = Ambiguate(fullName, "guild");
				getglobal("GuildFrameButton"..i.."Name"):SetText(displayedName);
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
			else
				getglobal("GuildFrameButton"..i.."Name"):SetText(nil);
				getglobal("GuildFrameButton"..i.."Zone"):SetText(nil);
				getglobal("GuildFrameButton"..i.."Level"):SetText(nil);
				getglobal("GuildFrameButton"..i.."Class"):SetText(nil);
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
		
		-- GuildFrameGuildListToggleButton:SetText(PLAYER_STATUS);
		-- If need scrollbar resize column headers
		if ( showScrollBar ) then
			WhoFrameColumn_SetWidth(GuildFrameColumnHeader2, 105);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 272, -98);
		else
			WhoFrameColumn_SetWidth(GuildFrameColumnHeader2, 120);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 295, -98);
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

			fullName, rank, rankIndex, level, class, zone, note, officernote, online, isAway = GetGuildRosterInfo(guildIndex);
			if (fullName and (showOffline or online)) then
				local displayedName = Ambiguate(fullName, "guild");
				getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetText(displayedName);
				getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetText(rank);
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetText(note);

				if ( online ) then
					if ( isAway == 2 ) then
						getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(CHAT_FLAG_DND);
					elseif ( isAway == 1 ) then
						getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(CHAT_FLAG_AFK);
					else
						getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(GUILD_ONLINE_LABEL);
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
			else
				getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetText(nil);
				getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetText(nil);
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetText(nil);
				getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(nil);
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
		
		-- GuildFrameGuildListToggleButton:SetText(GUILD_STATUS);
		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			WhoFrameColumn_SetWidth(GuildFrameGuildStatusColumnHeader3, 75);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 272, -98);
		else
			WhoFrameColumn_SetWidth(GuildFrameGuildStatusColumnHeader3, 90);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 295, -98);
		end
		
		-- ScrollFrame update
		FauxScrollFrame_Update(GuildListScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );

		GuildPlayerStatusFrame:Hide();
		GuildStatusFrame:Show();
	end
end