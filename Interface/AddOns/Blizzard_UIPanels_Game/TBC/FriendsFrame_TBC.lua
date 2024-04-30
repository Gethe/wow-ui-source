-- See FriendsFrame_Shared.lua for functions shared across Classic expansions

PENDING_GUILDBANK_PERMISSIONS = {};

function FriendsFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, FRIEND_TAB_COUNT);
	self.selectedTab = FRIEND_TAB_FRIENDS;
	PanelTemplates_UpdateTabs(self);
	self:RegisterEvent("FRIENDLIST_UPDATE");
	self:RegisterEvent("IGNORELIST_UPDATE");
	self:RegisterEvent("WHO_LIST_UPDATE");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("GUILD_MOTD");
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
	-- guild
	self.guildStatus = 0;
	GuildFrame.notesToggle = 1;
	GuildFrame.selectedGuildMember = 0;
	GuildFrame.hasForcedNameChange = GetGuildRenameRequired();
	SetGuildRosterSelection(0);
	CURRENT_GUILD_MOTD = GetGuildRosterMOTD();
	GuildFrameNotesText:SetText(CURRENT_GUILD_MOTD);
	GuildMemberDetailRankText:SetPoint("RIGHT", GuildFramePromoteButton, "LEFT");
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

		GuildInfoFrame.cachedText = nil;
		if ( GuildFrame:IsShown() ) then
			local arg1 = ...;
			if ( arg1 ) then
				C_GuildInfo.GuildRoster();
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
		if inviteType == "SUGGEST_INVITE" and C_PartyInfo.IsPartyFull() then
			ChatFrame_DisplaySystemMessageInPrimary(ERR_GROUP_FULL);
			return;
		end

		BNInviteFriend(gameAccountID);
	elseif ( inviteType == "REQUEST_INVITE" ) then
		BNRequestInviteFriend(gameAccountID);
	end
end

-- ============================================ GUILD ===============================================================================
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
	GuildControlTabPermissionsUpdateTextText:SetText(GUILDCONTROL_OPTION19); --option # is a lie, we're simply repurposing this globalstring from mainline
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
	GuildControlPopupFrameDropDownButton_ClickedRank(1);

	GuildControlPopupFrame:SetScript("OnEvent", GuildControlPopupFrame_OnEvent);
	GuildControlPopupFrame.initialized = 1;
	GuildControlPopupFrame.rank = GuildControlGetRankName(1);
end

function GuildControlPopupFrame_OnShow()
	FriendsFrame:SetAttribute("UIPanelLayout-defined", nil);
	FriendsFrame.guildControlShow = 1;
	GuildControlPopupAcceptButton:Disable();
	-- Update popup
	GuildControlPopupFrame_Initialize();
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
		local goldWithdrawLimit = GetGuildBankWithdrawGoldLimit();
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
		SetGuildBankWithdrawGoldLimit(amount);
	else
		SetGuildBankWithdrawGoldLimit(0);
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
	UIDropDownMenu_SetWidth(GuildControlPopupFrameDropDown, 160);
	UIDropDownMenu_SetButtonWidth(GuildControlPopupFrameDropDown, 54);
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
	GuildControlPopupFrameDropDownButton_ClickedRank(rank)
end

function GuildControlPopupFrameDropDownButton_ClickedRank(rank)
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

function GuildControlPopupFrameRemoveRankButton_OnClick()
	GuildControlDelRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
	GuildControlPopupFrame.rank = GuildControlGetRankName(1);
	GuildControlSetRank(1);
	GuildStatus_Update();
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1);
	GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(1));
	GuildControlCheckboxUpdate(GuildControlGetRankFlags());
	GuildControlPopupFrameDropDown:SetID(1);
	GuildControlPopupFrameDropDownButton_ClickedRank(1);
	CloseDropDownMenus();
	-- Set this to call guildroster in the next frame
	--C_GuildInfo.GuildRoster();
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
				-- treat 0 as false
				local boolValue = value[i];
				if ( type(boolValue) == "number" ) then
					boolValue = boolValue ~= 0;
				end
				SetGuildBankTabPermissions(index, i, boolValue);
			end
		end
		if ( value["withdraw"] ) then
			SetGuildBankTabItemWithdraw(index, value["withdraw"]);
		end
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
			GuildFramePopup_Show(GuildMemberDetailFrame);
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
	-- Number of players in the lowest rank
	FriendsFrame.playersInBotRank = 0

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