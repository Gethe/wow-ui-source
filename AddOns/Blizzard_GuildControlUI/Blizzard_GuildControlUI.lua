MAX_GUILDCONTROL_OPTIONS = 12;
MAX_GUILDBANK_TABS = 6;
MAX_GOLD_WITHDRAW = 1000;
MAX_GOLD_WITHDRAW_DIGITS = 9;
PENDING_GUILDBANK_PERMISSIONS = {};

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
	GuildControlPopupFrame_Initialize();
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