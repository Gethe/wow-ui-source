
BANK_TAB_OFFSET = 4;
BANK_TAB_HEIGHT = BANK_TAB_OFFSET + 73;
NUM_RANK_FLAGS = 18;
MAX_GUILDRANKS = 10;


function GuildControlUI_OnLoad(self)
	GuildFrame_RegisterPopup(self);
	self:RegisterEvent("GUILD_RANKS_UPDATE");

	UIDropDownMenu_SetWidth(self.dropdown, 120);
	UIDropDownMenu_SetButtonWidth(self.dropdown, 54);
	UIDropDownMenu_JustifyText(self.dropdown, "LEFT");
	UIDropDownMenu_Initialize(self.dropdown, GuildControlUINavigationDropDown_Initialize);
	
	local buttonText;
	for i=1, 18 do	
		buttonText = _G["GuildControlUIRankSettingsFrameCheckbox"..i.."Text"];
		if ( buttonText ) then
			buttonText:SetText(_G["GUILDCONTROL_OPTION"..i]);
		end
	end
	
	self.currentRank = 2;
	GuildControlSetRank(2);
	GuildControlUINavigationDropDown_OnSelect(nil, 1, GUILDCONTROL_GUILDRANKS);
	self:RegisterEvent("GUILDBANK_UPDATE_TABS");
end


function GuildControlUI_OnEvent(self, event)
	GuildControlUI.rankUpdate(GuildControlUI.currFrame);
end


function GuildControlUI_SubmitChanges(self)

end


function GuildControlUI_SetBankTabChange(self)

	SetGuildBankTabPermissions(self:GetParent():GetParent().tabIndex, self:GetID(), self:GetChecked());

	-- for index, value in pairs(PENDING_GUILDBANK_PERMISSIONS) do
		-- for i=1, 3 do
			-- if ( value[i] ) then
				-- SetGuildBankTabPermissions(index, i, value[i]);
			-- end
		-- end
		-- if ( value["withdraw"] ) then
			-- SetGuildBankTabWithdraw(index, value["withdraw"]);
		-- end
	-- end
	
	--SetPendingGuildBankTabPermissions(GuildControlPopupFrameTabPermissions.selectedTab, self:GetID(), self:GetChecked());
end

function GuildControlUI_SetBankTabWithdrawChange(self)
	local withdrawals = self:GetText();
	if ( not tonumber(withdrawals) ) then
		withdrawals = 0;
	end
	SetGuildBankTabItemWithdraw(self:GetParent():GetParent().tabIndex, withdrawals);
end

function GuildControlUI_BankTabPermissions_Update(self)
	local currentRank = self:GetParent().currentRank;
	-- if currentRank doesn't apply, reset to first available
	if ( currentRank < 2 or currentRank > GuildControlGetNumRanks() ) then
		currentRank = 2;
		self:GetParent().currentRank = 2;
	end
	GuildControlSetRank(currentRank);
	UIDropDownMenu_SetText(self.dropdown, GuildControlGetRankName(currentRank));

	local numTabs = GetNumGuildBankTabs();
	local canBuyTab = false;
	local hasScrollBar = true;
	if numTabs < MAX_BUY_GUILDBANK_TABS then
		canBuyTab = true;
		numTabs = numTabs + 1;
		hasScrollBar = numTabs > 3;
	end	
	
	local scrollFrame = self.scrollFrame;
	local scrollFrameName = scrollFrame:GetName();
	local buttonWidth;
	if ( hasScrollBar ) then
		scrollFrame:SetPoint("BOTTOMRIGHT",-28 ,8);
		scrollFrame.ScrollBar:Show();
		_G[scrollFrameName.."Top"]:Show();
		_G[scrollFrameName.."Bottom"]:Show();
		buttonWidth = scrollFrame:GetWidth() - 2;
	else
		scrollFrame:SetPoint("BOTTOMRIGHT",-2 ,8);
		scrollFrame.ScrollBar:Hide();
		_G[scrollFrameName.."Top"]:Hide();
		_G[scrollFrameName.."Bottom"]:Hide();
		buttonWidth = scrollFrame:GetWidth() - 5;
	end
	
	for i = 1, numTabs do
		local button = _G["GuildControlBankTab"..i];
		if ( not button ) then
			button = CreateFrame("Frame", "GuildControlBankTab"..i, scrollFrame:GetScrollChild(), "BankTabPermissionTemplate");
			GuildControlUI_LocalizeBankTab(button);
			if ( i == 1 ) then
				button:SetPoint("TOPLEFT", 0, 0);
			else
				local prevButton = _G["GuildControlBankTab"..(i - 1)];
				button:SetPoint("TOPLEFT", prevButton, "BOTTOMLEFT", 0, -BANK_TAB_OFFSET);
			end
		end
		button:SetWidth(buttonWidth);
		local index = i;
		if ( index == numTabs and canBuyTab ) then
			button:Show();
			button.buy:Show();
			button.owned:Hide();
			local tabCost = GetGuildBankTabCost();
			if(  (GetMoney() + GetGuildBankMoney()) >= tabCost ) then
				SetMoneyFrameColor(button.buy.money:GetName(), "white");
				button.buy.button:Enable();
			else
				SetMoneyFrameColor(button.buy.money:GetName(), "red");
				button.buy.button:Disable();
			end
			MoneyFrame_Update(button.buy.money:GetName(), tabCost);		
		elseif index > numTabs then
			button:Hide();
			button.tabIndex = nil;
		else
			button.tabIndex = index;
			local name, icon = GetGuildBankTabInfo(index);												-- returns info and permissions for player's rank
			local isViewable, canDeposit, editText, numWithdrawals = GetGuildBankTabPermissions(index);	-- returns permissions for the selected rank
			button:Show();
			local ownedTab = button.owned;
			ownedTab.tabName:SetText(name);	
			ownedTab.tabIcon:SetTexture(icon);
			ownedTab.viewCB:SetChecked(isViewable);
			ownedTab.infoCB:SetChecked(editText);
			ownedTab.depositCB:SetChecked(canDeposit);
			if ( isViewable ) then
				ownedTab.infoCB:Enable();
				ownedTab.infoCB.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				ownedTab.depositCB:Enable();
				ownedTab.depositCB.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				ownedTab.editBox.mask:Hide();
				-- do not update text if the user is typing
				if ( ownedTab.editBox:HasFocus() ) then
					ownedTab.editBox.startValue = numWithdrawals;
				else
					ownedTab.editBox:SetText(numWithdrawals);
					ownedTab.editBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				end
			else
				ownedTab.infoCB:Disable();
				ownedTab.infoCB.text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				ownedTab.depositCB:Disable();
				ownedTab.depositCB.text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				if ( ownedTab.editBox:HasFocus() ) then
					ownedTab.editBox:ClearFocus();
				end
				ownedTab.editBox.mask:Show();
				ownedTab.editBox:SetText(numWithdrawals);
				ownedTab.editBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end
			ownedTab:Show();
			button.buy:Hide();
		end
	end
end


function GuildControlUI_RankPermissions_Update(self)	
	local currentRank = self:GetParent().currentRank;
	-- if currentRank doesn't apply, reset to first available
	if ( currentRank < 2 or currentRank > GuildControlGetNumRanks() ) then
		currentRank = 2;
		self:GetParent().currentRank = 2;
	end
	GuildControlSetRank(currentRank);
	UIDropDownMenu_SetText(self.dropdown, GuildControlGetRankName(currentRank));
	local flags = {GuildControlGetRankFlags()};
	local checkbox;
	local prefix = self:GetName().."Checkbox";
	for i=1, NUM_RANK_FLAGS do
		checkbox = _G[prefix..i]
		if ( checkbox ) then -- skip obsolete (14)
			checkbox:SetChecked(flags[i]);
		end
	end
	
	-- enable the gold/day editbox if at least one of Guild Bank Repair and Withdraw Gold are unchecked
	if ( flags[15] or flags[16] ) then
		self.goldBox.mask:Hide();
		-- do not update text if the user is typing
		if ( self.goldBox:HasFocus() ) then
			self.goldBox.startValue = GetGuildBankWithdrawGoldLimit();
		else
			self.goldBox:SetText(GetGuildBankWithdrawGoldLimit());
			self.goldBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	else
		if ( self.goldBox:HasFocus() ) then
			self.goldBox:ClearFocus();
		end	
		self.goldBox.mask:Show();
		self.goldBox:SetText(GetGuildBankWithdrawGoldLimit());
		self.goldBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	
	-- disable the Authenticate checkbox for the last rank or if a rank has members
	checkbox = _G[prefix.."18"];
	if ( currentRank == GuildControlGetNumRanks() ) then
		checkbox.text:SetFontObject("GameFontDisableSmall");
		checkbox:Disable();
		checkbox.tooltipFrame.tooltip = AUTHENTICATOR_GUILD_RANK_LAST;
	elseif ( GetNumMembersInRank(currentRank ) > 0 ) then
		checkbox.text:SetFontObject("GameFontDisableSmall");
		checkbox:Disable();
		checkbox.tooltipFrame.tooltip = AUTHENTICATOR_GUILD_RANK_IN_USE;
	else
		checkbox.text:SetFontObject("GameFontHighlightSmall");
		checkbox:Enable();
		checkbox.tooltipFrame.tooltip = nil;
	end
	
	
end



function GuildControlUI_RankOrder_Update(self)	
	local numRanks = GuildControlGetNumRanks();
	if numRanks == MAX_GUILDRANKS then
		self.newButton:Hide();
		self.dupButton:Hide();
	else
		self.newButton:Show();
		--self.dupButton:Show();
	end	
	
	local prefix = self:GetName().."Rank";
	for i=1, numRanks do
		local rankFrame = _G[prefix..i];
		if not rankFrame then
			rankFrame =  CreateFrame("FRAME", prefix..i, self, "RankChangeTemplate");
			rankFrame:SetPoint("TOP", _G[prefix..(i-1)], "BOTTOM", 0, -7);
			rankFrame:SetID(i);
		end
		rankFrame:Show();
		rankFrame.rankLabel:SetText(RANK.." "..i..":");
		rankFrame.nameBox:SetText(GuildControlGetRankName(i));

		if numRanks == 2 then
			rankFrame.deleteButton:Disable();
			rankFrame.deleteButton.tooltip = nil;
			rankFrame.upButton:Disable();
			rankFrame.downButton:Disable();
		elseif i > 1 then
			if ( GetNumMembersInRank(i) == 0 ) then
				-- can't delete last rank if next-to-last has authenticator
				rankFrame.deleteButton:Enable();
				rankFrame.deleteButton.tooltip = nil;
				if ( i == numRanks ) then
					GuildControlSetRank(i - 1);
					local requiresAuthenticator = select(18, GuildControlGetRankFlags());
					if ( requiresAuthenticator ) then
						rankFrame.deleteButton:Disable();
						rankFrame.deleteButton.tooltip = AUTHENTICATOR_GUILD_RANK_CHANGE;
					end
				end
			else
				rankFrame.deleteButton:Disable();
				rankFrame.deleteButton.tooltip = ERR_GUILD_RANK_IN_USE;
			end
			local canShiftUp, canShiftDown = GuildControlGetAllowedShifts(i);
			if ( canShiftUp ) then
				rankFrame.upButton:Enable();
				rankFrame.upButton.tooltip = nil;
			else
				-- if it's the last rank then it can't shift up if it would move an authenticated rank to the bottom
				if ( i == numRanks ) then
					rankFrame.upButton:Disable();
					rankFrame.upButton.tooltip = AUTHENTICATOR_GUILD_RANK_CHANGE;
				else
					rankFrame.upButton:Disable();
					rankFrame.upButton.tooltip = nil;
				end
			end
			if ( canShiftDown ) then
				rankFrame.downButton:Enable();
				rankFrame.downButton.tooltip = nil;
			else
				-- if it's the next to last rank then it can't shift down if it would move an authenticated rank to the bottom
				if ( i == numRanks - 1 ) then
					rankFrame.downButton:Disable();
					rankFrame.downButton.tooltip = AUTHENTICATOR_GUILD_RANK_CHANGE;
				else
					rankFrame.downButton:Disable();
					rankFrame.downButton.tooltip = nil;
				end
			end
		end
	end
	--hide removed ransk	
	for i=numRanks+1, MAX_GUILDRANKS do
		local rankFrame = _G[prefix..i];
		if rankFrame then
			rankFrame:Hide()
		end
	end
end


function GuildControlUI_BankFrame_OnLoad(self)
	self:GetParent().scrollFrame = self.scrollFrame;
	self.scrollFrame.update = function() GuildControlUI.rankUpdate(GuildControlUI.currFrame) end;
	self.scrollFrame.stepSize = 8;
end


-- function GuildControlUI_SubmitClicked()
	-- if GuildControlUI.selectedTab == 1 then	
	-- elseif GuildControlUI.selectedTab == 2 then
		-- local amount = GuildControlUI.currFrame.goldBox:GetText();
		-- if(amount) then
			-- SetGuildBankWithdrawLimit(amount);
		-- end
		-- GuildControlSaveRank(GuildControlGetRankName(GuildControlUI.currentRank));
	-- elseif GuildControlUI.selectedTab == 3 then
	-- end
-- end


-- function GuildControlUI_RevertClicked()	
	-- GuildControlUIRevertButton:Disable();
	-- GuildControlUISubmitButton:Disable();
	-- GuildControlUI.rankUpdate(GuildControlUI.currFrame);
-- end


function GuildControlUI_CheckClicked(self)
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOff");
	else
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
	GuildControlSetRankFlag(self:GetID(), self:GetChecked());
	--WithdrawGoldEditBox_Update();
end



function GuildControlUI_RemoveRankButton_OnClick(self)
	local index = self:GetParent():GetID();
	GuildControlDelRank(index);
end


function GuildControlUI_AddRankButton_OnClick()
	PlaySound("igMainMenuOpen");
	GuildControlAddRank(GUILD_NEW_RANK);
	CloseDropDownMenus();
end


function GuildControlUI_ShiftRankDownButton_OnClick(self)
	local activeEditBox = GuildControlUI.activeEditBox;
	if ( activeEditBox ) then
		activeEditBox:ClearFocus();
	end
	local index = self:GetParent():GetID();
	GuildControlShiftRankDown(index);
end


function GuildControlUI_ShiftRankUpButton_OnClick(self)
	local activeEditBox = GuildControlUI.activeEditBox;
	if ( activeEditBox ) then
		activeEditBox:ClearFocus();
	end
	local index = self:GetParent():GetID();
	GuildControlShiftRankUp(index);
end



function GuildControlUINavigationDropDown_OnSelect(self, arg1, arg2)
	UIDropDownMenu_SetText(GuildControlUINavigationDropDown, arg2);
	GuildControlUIRankSettingsFrame:Hide();
	GuildControlUIRankOrderFrame:Hide();
	GuildControlUIRankBankFrame:Hide();
	GuildControlUI.selectedTab = arg1;
	if arg1 == 1 then	
		GuildControlUIRankOrderFrame:Show();		
		GuildControlUI.currFrame = GuildControlUI.orderFrame;
		GuildControlUI.rankUpdate = GuildControlUI_RankOrder_Update;
	elseif arg1 == 2 then		
		GuildControlUI.currFrame = GuildControlUI.rankPermFrame;
		GuildControlUI.rankUpdate = GuildControlUI_RankPermissions_Update;
		GuildControlUIRankSettingsFrame:Show();
		GuildControlUI.rankUpdate(GuildControlUI.currFrame);
	elseif arg1 == 3 then		
		GuildControlUI.currFrame = GuildControlUI.bankTabFrame;
		GuildControlUI.rankUpdate = GuildControlUI_BankTabPermissions_Update;
		GuildControlUIRankBankFrame:Show();
		GuildControlUI.rankUpdate(GuildControlUI.currFrame);
	end
end

function GuildControlUINavigationDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = GUILDCONTROL_GUILDRANKS;
	info.arg1 = 1;
	info.arg2 = GUILDCONTROL_GUILDRANKS;
	info.func = GuildControlUINavigationDropDown_OnSelect;
	info.checked = GuildControlUI.selectedTab == 1;
	UIDropDownMenu_AddButton(info);	
	
	info.text = GUILDCONTROL_RANK_PERMISSIONS;
	info.arg1 = 2;
	info.arg2 = GUILDCONTROL_RANK_PERMISSIONS;
	info.func = GuildControlUINavigationDropDown_OnSelect;
	info.checked = GuildControlUI.selectedTab == 2;
	UIDropDownMenu_AddButton(info);
	
	info.text = GUILDCONTROL_BANK_PERMISSIONS;
	info.arg1 = 3;
	info.arg2 = GUILDCONTROL_BANK_PERMISSIONS;
	info.func = GuildControlUINavigationDropDown_OnSelect;
	info.checked = GuildControlUI.selectedTab == 3;
	UIDropDownMenu_AddButton(info);
end

function GuildControlUIRankDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	local numRanks = GuildControlGetNumRanks();
	for i=2, numRanks do
		info.text = GuildControlGetRankName(i);
		info.func = GuildControlUIRankDropDown_OnClick;
		info.checked = i == GuildControlUI.currentRank ;
		UIDropDownMenu_AddButton(info);
	end
end


function GuildControlUIRankDropDown_OnClick(self)
	local activeEditBox = GuildControlUI.activeEditBox;
	if ( activeEditBox ) then
		activeEditBox:ClearFocus();
	end
	
	GuildControlUI.currentRank = self:GetID()+1; --igonre officer
	GuildControlSetRank(GuildControlUI.currentRank);
	GuildControlUI.rankUpdate(GuildControlUI.currFrame);
end









-- MAX_GUILDCONTROL_OPTIONS = 12;
-- MAX_GUILDBANK_TABS = 6;
-- MAX_GOLD_WITHDRAW = 1000;
-- MAX_GOLD_WITHDRAW_DIGITS = 9;
-- PENDING_GUILDBANK_PERMISSIONS = {};

-- function GuildControlPopupFrame_OnLoad()
	-- local buttonText;
	-- for i=1, 17 do	
		-- buttonText = _G["GuildControlPopupFrameCheckbox"..i.."Text"];
		-- if ( buttonText ) then
			-- buttonText:SetText(_G["GUILDCONTROL_OPTION"..i]);
		-- end
	-- end
	-- GuildControlTabPermissionsViewTabText:SetText(GUILDCONTROL_VIEW_TAB);
	-- GuildControlTabPermissionsDepositItemsText:SetText(GUILDCONTROL_DEPOSIT_ITEMS);
	-- GuildControlTabPermissionsUpdateTextText:SetText(GUILDCONTROL_UPDATE_TEXT);
	-- ClearPendingGuildBankPermissions();
	-- GuildControlPopupFrame_Initialize();
-- end

-- --Need to call this function on an event since the guildroster is not available during OnLoad()
-- function GuildControlPopupFrame_Initialize()
	-- if ( GuildControlPopupFrame.initialized ) then
		-- return;
	-- end
	-- UIDropDownMenu_Initialize(GuildControlPopupFrameDropDown, GuildControlPopupFrameDropDown_Initialize);
	-- GuildControlSetRank(1);
	-- UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1);
	-- UIDropDownMenu_SetText(GuildControlPopupFrameDropDown, GuildControlGetRankName(1));
	-- -- Select tab 1
	-- GuildBankTabPermissionsTab_OnClick(1);

	-- GuildControlPopupFrame:SetScript("OnEvent", GuildControlPopupFrame_OnEvent);
	-- GuildControlPopupFrame.initialized = 1;
	-- GuildControlPopupFrame.rank = GuildControlGetRankName(1);
-- end

-- function GuildControlPopupFrame_OnShow()
	-- FriendsFrame:SetAttribute("UIPanelLayout-defined", nil);
	-- FriendsFrame.guildControlShow = 1;
	-- GuildControlPopupAcceptButton:Disable();
	-- -- Update popup
	-- GuildControlPopupframe_Update();
	
	-- UIPanelWindows["FriendsFrame"].width = FriendsFrame:GetWidth() + GuildControlPopupFrame:GetWidth();
	-- UpdateUIPanelPositions(FriendsFrame);
	-- --GuildControlPopupFrame:RegisterEvent("GUILD_ROSTER_UPDATE"); --It was decided that having a risk of conflict when two people are editing the guild permissions at once is better than resetting whenever someone joins the guild or changes ranks.
-- end

-- function GuildControlPopupFrame_OnEvent (self, event, ...)
	-- if ( not IsGuildLeader(UnitName("player")) ) then
		-- GuildControlPopupFrame:Hide();
		-- return;
	-- end
	
	-- local rank
	-- for i = 1, GuildControlGetNumRanks() do
		-- rank = GuildControlGetRankName(i);
		-- if ( GuildControlPopupFrame.rank and rank == GuildControlPopupFrame.rank ) then
			-- UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, i);
			-- UIDropDownMenu_SetText(GuildControlPopupFrameDropDown, rank);
		-- end
	-- end
	
	-- GuildControlPopupframe_Update()
-- end

-- function GuildControlPopupFrame_OnHide()
	-- FriendsFrame:SetAttribute("UIPanelLayout-defined", nil);
	-- FriendsFrame.guildControlShow = 0;

	-- UIPanelWindows["FriendsFrame"].width = FriendsFrame:GetWidth();
	-- UpdateUIPanelPositions();

	-- GuildControlPopupFrame.goldChanged = nil;
	-- GuildControlPopupFrame:UnregisterEvent("GUILD_ROSTER_UPDATE");
-- end

-- function GuildControlPopupframe_Update(loadPendingTabPermissions, skipCheckboxUpdate)
	-- -- Skip non-tab specific updates to fix Bug  ID: 110210
	-- if ( not skipCheckboxUpdate ) then
		-- -- Update permission flags
		-- GuildControlCheckboxUpdate(GuildControlGetRankFlags());
	-- end
	
	-- local rankID = UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown);
	-- GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(rankID));
	-- if ( GuildControlPopupFrame.previousSelectedRank and GuildControlPopupFrame.previousSelectedRank ~= rankID ) then
		-- ClearPendingGuildBankPermissions();
	-- end
	-- GuildControlPopupFrame.previousSelectedRank = rankID;

	-- --If rank to modify is guild master then gray everything out
	-- if ( IsGuildLeader() and rankID == 1 ) then
		-- GuildBankTabLabel:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		-- GuildControlTabPermissionsDepositItems:SetChecked(1);
		-- GuildControlTabPermissionsViewTab:SetChecked(1);
		-- GuildControlTabPermissionsUpdateText:SetChecked(1);
		-- BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsDepositItems);
		-- BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsViewTab);
		-- BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsUpdateText);
		-- GuildControlTabPermissionsWithdrawItemsText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		-- GuildControlWithdrawItemsEditBox:SetNumeric(nil);
		-- GuildControlWithdrawItemsEditBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		-- GuildControlWithdrawItemsEditBox:SetText(UNLIMITED);
		-- GuildControlWithdrawItemsEditBox:ClearFocus();
		-- GuildControlWithdrawItemsEditBoxMask:Show();
		-- GuildControlWithdrawGoldText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		-- GuildControlWithdrawGoldAmountText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		-- GuildControlWithdrawGoldEditBox:SetNumeric(nil);
		-- GuildControlWithdrawGoldEditBox:SetMaxLetters(0);
		-- GuildControlWithdrawGoldEditBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		-- GuildControlWithdrawGoldEditBox:SetText(UNLIMITED);
		-- GuildControlWithdrawGoldEditBox:ClearFocus();
		-- GuildControlWithdrawGoldEditBoxMask:Show();
		-- BlizzardOptionsPanel_CheckButton_Disable(GuildControlPopupFrameCheckbox15);
		-- BlizzardOptionsPanel_CheckButton_Disable(GuildControlPopupFrameCheckbox16);
	-- else
		-- if ( GetNumGuildBankTabs() == 0 ) then
			-- -- No tabs, no permissions! Disable the tab related doohickies
			-- GuildBankTabLabel:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			-- BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsViewTab);
			-- BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsDepositItems);
			-- BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsUpdateText);
			-- GuildControlTabPermissionsWithdrawItemsText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			-- GuildControlWithdrawItemsEditBox:SetText(UNLIMITED);
			-- GuildControlWithdrawItemsEditBox:ClearFocus();
			-- GuildControlWithdrawItemsEditBoxMask:Show();
		-- else
			-- GuildBankTabLabel:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			-- BlizzardOptionsPanel_CheckButton_Enable(GuildControlTabPermissionsViewTab);
			-- GuildControlTabPermissionsWithdrawItemsText:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			-- GuildControlWithdrawItemsEditBox:SetNumeric(1);
			-- GuildControlWithdrawItemsEditBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			-- GuildControlWithdrawItemsEditBoxMask:Hide();
		-- end
		
		-- GuildControlWithdrawGoldText:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		-- GuildControlWithdrawGoldAmountText:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		-- GuildControlWithdrawGoldEditBox:SetNumeric(1);
		-- GuildControlWithdrawGoldEditBox:SetMaxLetters(MAX_GOLD_WITHDRAW_DIGITS);
		-- GuildControlWithdrawGoldEditBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		-- GuildControlWithdrawGoldEditBoxMask:Hide();
		-- BlizzardOptionsPanel_CheckButton_Enable(GuildControlPopupFrameCheckbox15);
		-- BlizzardOptionsPanel_CheckButton_Enable(GuildControlPopupFrameCheckbox16);

		-- -- Update tab specific info
		-- local viewTab, canDeposit, canUpdateText, numWithdrawals = GetGuildBankTabPermissions(GuildControlPopupFrameTabPermissions.selectedTab);
		-- if ( rankID == 1 ) then
			-- --If is guildmaster then force checkboxes to be selected
			-- viewTab = 1;
			-- canDeposit = 1;
			-- canUpdateText = 1;
		-- elseif ( loadPendingTabPermissions ) then
			-- local permissions = PENDING_GUILDBANK_PERMISSIONS[GuildControlPopupFrameTabPermissions.selectedTab];
			-- local value;
			-- value = permissions[GuildControlTabPermissionsViewTab:GetID()];
			-- if ( value ) then
				-- viewTab = value;
			-- end
			-- value = permissions[GuildControlTabPermissionsDepositItems:GetID()];
			-- if ( value ) then
				-- canDeposit = value;
			-- end
			-- value = permissions[GuildControlTabPermissionsUpdateText:GetID()];
			-- if ( value ) then
				-- canUpdateText = value;
			-- end
			-- value = permissions["withdraw"];
			-- if ( value ) then
				-- numWithdrawals = value;
			-- end
		-- end
		-- GuildControlTabPermissionsViewTab:SetChecked(viewTab);
		-- GuildControlTabPermissionsDepositItems:SetChecked(canDeposit);
		-- GuildControlTabPermissionsUpdateText:SetChecked(canUpdateText);
		-- GuildControlWithdrawItemsEditBox:SetText(numWithdrawals);
		-- local goldWithdrawLimit = GetGuildBankWithdrawLimit();
		-- -- Only write to the editbox if the value hasn't been changed by the player
		-- if ( not GuildControlPopupFrame.goldChanged ) then
			-- if ( goldWithdrawLimit >= 0 ) then
				-- GuildControlWithdrawGoldEditBox:SetText(goldWithdrawLimit);
			-- else
				-- -- This is for the guild leader who defaults to -1
				-- GuildControlWithdrawGoldEditBox:SetText(MAX_GOLD_WITHDRAW);
			-- end
		-- end
		-- GuildControlPopup_UpdateDepositCheckBox();
	-- end
	
	-- --Only show available tabs
	-- local tab;
	-- local numTabs = GetNumGuildBankTabs();
	-- local name, permissionsTabBackground, permissionsText;
	-- for i=1, MAX_GUILDBANK_TABS do
		-- name = GetGuildBankTabInfo(i);
		-- tab = _G["GuildBankTabPermissionsTab"..i];
		
		-- if ( i <= numTabs ) then
			-- tab:Show();
			-- tab.tooltip = name;
			-- permissionsTabBackground = _G["GuildBankTabPermissionsTab"..i.."Background"];
			-- permissionsText = _G["GuildBankTabPermissionsTab"..i.."Text"];
			-- if (  GuildControlPopupFrameTabPermissions.selectedTab == i ) then
				-- tab:LockHighlight();
				-- permissionsTabBackground:SetTexCoord(0, 1.0, 0, 1.0);
				-- permissionsTabBackground:SetHeight(32);
				-- permissionsText:SetPoint("CENTER", permissionsTabBackground, "CENTER", 0, -3);
			-- else
				-- tab:UnlockHighlight();
				-- permissionsTabBackground:SetTexCoord(0, 1.0, 0, 0.875);
				-- permissionsTabBackground:SetHeight(28);
				-- permissionsText:SetPoint("CENTER", permissionsTabBackground, "CENTER", 0, -5);
			-- end
			-- if ( IsGuildLeader() and rankID == 1 ) then
				-- tab:Disable();
			-- else
				-- tab:Enable();
			-- end
		-- else
			-- tab:Hide();
		-- end
	-- end
-- end

-- function WithdrawGoldEditBox_Update()
	-- if ( not GuildControlPopupFrameCheckbox15:GetChecked() and not GuildControlPopupFrameCheckbox16:GetChecked() ) then
		-- GuildControlWithdrawGoldAmountText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		-- GuildControlWithdrawGoldEditBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		-- GuildControlWithdrawGoldEditBox:ClearFocus();
		-- GuildControlWithdrawGoldEditBoxMask:Show();
	-- else
		-- GuildControlWithdrawGoldAmountText:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		-- GuildControlWithdrawGoldEditBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		-- GuildControlWithdrawGoldEditBoxMask:Hide();
	-- end
-- end

-- function GuildControlPopupAcceptButton_OnClick()
	-- local amount = GuildControlWithdrawGoldEditBox:GetText();
	-- if(amount and amount ~= "" and amount ~= UNLIMITED and tonumber(amount) and tonumber(amount) > 0) then
		-- SetGuildBankWithdrawLimit(amount);
	-- else
		-- SetGuildBankWithdrawLimit(0);
	-- end
	-- SavePendingGuildBankTabPermissions()
	-- GuildControlSaveRank(GuildControlPopupFrameEditBox:GetText());
	-- GuildStatus_Update();
	-- GuildControlPopupAcceptButton:Disable();
	-- UIDropDownMenu_SetText(GuildControlPopupFrameDropDown, GuildControlPopupFrameEditBox:GetText());
	-- GuildControlPopupFrame:Hide();
	-- ClearPendingGuildBankPermissions();
-- end

-- function GuildControlPopupFrameDropDown_OnLoad(self)
	-- UIDropDownMenu_SetWidth(self, 160);
	-- UIDropDownMenu_SetButtonWidth(self, 54);
	-- UIDropDownMenu_JustifyText(self, "LEFT");
-- end

-- function GuildControlPopupFrameDropDown_Initialize()
	-- local info = UIDropDownMenu_CreateInfo();
	-- for i=1, GuildControlGetNumRanks() do
		-- info.text = GuildControlGetRankName(i);
		-- info.func = GuildControlPopupFrameDropDownButton_OnClick;
		-- info.checked = nil;
		-- UIDropDownMenu_AddButton(info);
	-- end
-- end

-- function GuildControlPopupFrameDropDownButton_OnClick(self)
	-- local rank = self:GetID();
	-- UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, rank);	
	-- GuildControlSetRank(rank);
	-- GuildControlPopupFrame.rank = GuildControlGetRankName(rank);
	-- GuildControlPopupFrame.goldChanged = nil;
	-- GuildControlPopupframe_Update();
	-- GuildControlPopupFrameAddRankButton_OnUpdate(GuildControlPopupFrameAddRankButton);
	-- GuildControlPopupFrameRemoveRankButton_OnUpdate(GuildControlPopupFrameRemoveRankButton);
	-- GuildControlPopupAcceptButton:Disable();
-- end

-- function GuildControlCheckboxUpdate(...)
	-- local checkbox;
	-- for i=1, select("#", ...), 1 do
		-- checkbox = _G["GuildControlPopupFrameCheckbox"..i]
		-- if ( checkbox ) then
			-- checkbox:SetChecked(select(i, ...));
		-- else
			-- --We need to skip checkbox 14 since it's a deprecated flag
			-- --message("GuildControlPopupFrameCheckbox"..i.." does not exist!");
		-- end
	-- end
-- end

-- function GuildControlPopupFrameAddRankButton_OnUpdate(self)
	-- if ( GuildControlGetNumRanks() >= 10 ) then
		-- self:Disable();
	-- else
		-- self:Enable();
	-- end
-- end

-- function GuildControlPopupFrameRemoveRankButton_OnClick()
	-- GuildControlDelRank(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
	-- GuildControlPopupFrame.rank = GuildControlGetRankName(1);
	-- GuildControlSetRank(1);
	-- GuildStatus_Update();
	-- UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1);
	-- GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(1));
	-- GuildControlCheckboxUpdate(GuildControlGetRankFlags());
	-- CloseDropDownMenus();
	-- -- Set this to call guildroster in the next frame
	-- --GuildRoster();
	-- --GuildControlPopupFrame.update = 1;
-- end

-- function GuildControlPopupFrameRemoveRankButton_OnUpdate(self)
	-- local numRanks = GuildControlGetNumRanks()
	-- if ( (UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown) == numRanks) and (numRanks > 5) ) then
		-- self:Show();
		-- if ( FriendsFrame.playersInBotRank > 0 ) then
			-- self:Disable();
		-- else
			-- self:Enable();
		-- end
	-- else
		-- self:Hide();
	-- end
-- end

-- function GuildControlPopup_UpdateDepositCheckBox()
	-- if(GuildControlTabPermissionsViewTab:GetChecked()) then
		-- BlizzardOptionsPanel_CheckButton_Enable(GuildControlTabPermissionsDepositItems);
		-- BlizzardOptionsPanel_CheckButton_Enable(GuildControlTabPermissionsUpdateText);
	-- else
		-- BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsDepositItems);
		-- BlizzardOptionsPanel_CheckButton_Disable(GuildControlTabPermissionsUpdateText);
	-- end
-- end

-- function GuildBankTabPermissionsTab_OnClick(tab)
	-- GuildControlPopupFrameTabPermissions.selectedTab = tab;
	-- GuildControlPopupframe_Update(true, true);
-- end

-- -- Functions to allow canceling
-- function ClearPendingGuildBankPermissions()
	-- for i=1, MAX_GUILDBANK_TABS do
		-- PENDING_GUILDBANK_PERMISSIONS[i] = {};
	-- end
-- end

-- function SetPendingGuildBankTabPermissions(tab, id, checked)
	-- if ( not checked ) then
		-- checked = 0;
	-- end
	-- PENDING_GUILDBANK_PERMISSIONS[tab][id] = checked;
-- end

-- function SetPendingGuildBankTabWithdraw(tab, amount)
	-- PENDING_GUILDBANK_PERMISSIONS[tab]["withdraw"] = amount;
-- end

-- function SavePendingGuildBankTabPermissions()
	-- for index, value in pairs(PENDING_GUILDBANK_PERMISSIONS) do
		-- for i=1, 3 do
			-- if ( value[i] ) then
				-- SetGuildBankTabPermissions(index, i, value[i]);
			-- end
		-- end
		-- if ( value["withdraw"] ) then
			-- SetGuildBankTabWithdraw(index, value["withdraw"]);
		-- end
	-- end
-- end