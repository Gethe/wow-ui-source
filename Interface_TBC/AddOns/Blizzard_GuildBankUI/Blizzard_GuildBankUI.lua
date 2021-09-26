local MAX_GUILDBANK_SLOTS_PER_TAB = 98;
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14;
local NUM_GUILDBANK_ICONS_SHOWN = 0;
local NUM_GUILDBANK_ICONS_PER_ROW = 10;
local NUM_GUILDBANK_ICON_ROWS = 9;
local NUM_GUILDBANK_COLUMNS = 7;
local MAX_TRANSACTIONS_SHOWN = 21;
GUILDBANK_ICON_ROW_HEIGHT = 36;
GUILDBANK_TRANSACTION_HEIGHT = 13;

UIPanelWindows["GuildBankFrame"] = { area = "doublewide", pushable = 0, width = 769, xoffset = -16, yoffset = 12 };

GuildBankFrameMixin = {};

function GuildBankFrameMixin:OnLoad()
	NUM_GUILDBANK_ICONS_SHOWN = NUM_GUILDBANK_ICONS_PER_ROW * NUM_GUILDBANK_ICON_ROWS;
	self:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED");
	self:RegisterEvent("GUILDBANK_ITEM_LOCK_CHANGED");
	self:RegisterEvent("GUILDBANK_UPDATE_TABS");
	self:RegisterEvent("GUILDBANK_UPDATE_MONEY");
	self:RegisterEvent("GUILDBANK_UPDATE_WITHDRAWMONEY");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("GUILDBANKLOG_UPDATE");
	self:RegisterEvent("GUILDTABARD_UPDATE");
	self:RegisterEvent("GUILDBANK_UPDATE_TEXT");
	self:RegisterEvent("GUILDBANK_TEXT_CHANGED");
	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
	-- Set the button id's
	local index, column, button;
	for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
		index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP);
		if ( index == 0 ) then
			index = NUM_SLOTS_PER_GUILDBANK_GROUP;
		end
		column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
		button = self.Columns[column].Buttons[index];
		button:SetID(i);
	end
	self.mode = "bank";
	self.numTabs = 4;
	self.maxTabWidth = 128;
	self:UpdateTabs();
	self:UpdateTabard();
end

function GuildBankFrameMixin:OnEvent(event, ...)
	if ( not self:IsVisible() ) then
		return;
	end
	if ( event == "GUILDBANKBAGSLOTS_CHANGED" or event =="GUILDBANK_ITEM_LOCK_CHANGED" ) then
		self:UpdateTabs();
		self:Update();
	elseif ( event == "GUILDBANK_UPDATE_TABS" or event == "GUILD_ROSTER_UPDATE" ) then
		local tab = GetCurrentGuildBankTab();
		if ( event == "GUILD_ROSTER_UPDATE" and not select(1, ...) and self.noViewableTabs and self.mode == "bank" ) then
			-- if rank changed while at the bank tab and not having any viewable tabs, query for new item data 
			QueryGuildBankTab(tab);
		end
		
		self:SelectAvailableTab();
		
		if ( self.BuyInfo:IsShown() ) then
			self:UpdateTabBuyingInfo();
		end
		local _, _, canView, canDeposit, numWithdrawals = GetGuildBankTabInfo(tab);
		if ( canView and CanEditGuildTabInfo(GetCurrentGuildBankTab(tab)) ) then
			self.Info.SaveButton:Show();
		else
			self.Info.SaveButton:Hide();
		end
	elseif ( event == "GUILDBANKLOG_UPDATE" ) then
		if ( self.mode == "log" ) then
			GuildBankFrame_UpdateLog();
		else
			GuildBankFrame_UpdateMoneyLog();
		end
		GuildBankLogScroll();
	elseif ( event == "GUILDTABARD_UPDATE" ) then
		self:UpdateTabard();
	elseif ( event == "GUILDBANK_UPDATE_MONEY" or event == "GUILDBANK_UPDATE_WITHDRAWMONEY" ) then
		self:UpdateWithdrawMoney();
	elseif ( event == "GUILDBANK_UPDATE_TEXT" ) then
		self:UpdateTabInfo(...);
	elseif ( event == "GUILDBANK_TEXT_CHANGED" ) then
		local arg1 = ...;
		if ( GetCurrentGuildBankTab() == tonumber(arg1) ) then
			QueryGuildBankText(arg1);
		end
	elseif ( event == "PLAYER_MONEY" ) then
		if ( self.BuyInfo:IsShown() ) then
			self:UpdateTabBuyingInfo();
		end
	end
end

function GuildBankFrameMixin:SelectAvailableTab()
	-- If the selected tab is notViewable then select the next available one
	if ( self:IsTabViewable(GetCurrentGuildBankTab()) ) then
		self:UpdateTabs();
		self:Update();
	else
		if ( self.nextAvailableTab ) then
			self.BankTabs[self.nextAvailableTab]:OnClick("LeftButton");
		else
			self:UpdateTabs();
			self:Update();
		end
	end
end

function GuildBankFrameMixin:OnShow()
	self.FrameTabs[1]:OnClick();
	self:UpdateTabard();
	self:SelectAvailableTab();
	PlaySound(SOUNDKIT.GUILD_VAULT_OPEN);
end

function GuildBankFrameMixin:OnHide()
	GuildBankPopupFrame:Hide();
	StaticPopup_Hide("GUILDBANK_WITHDRAW");
	StaticPopup_Hide("GUILDBANK_DEPOSIT");
	StaticPopup_Hide("CONFIRM_BUY_GUILDBANK_TAB");
	CloseGuildBankFrame();
	PlaySound(SOUNDKIT.GUILD_VAULT_CLOSE);
	GB_ICON_FILENAMES = nil;
	collectgarbage();
end

function GuildBankFrameMixin:Update()
	-- Figure out which mode you're in and which tab is selected
	if ( self.mode == "bank" ) then
		-- Determine whether its the buy tab or not
		self.Log:Hide();
		self.Info:Hide();
		local tab = GetCurrentGuildBankTab();
		if ( self.noViewableTabs ) then
			self:HideColumns();
			self.BuyInfo:Hide();
			self.ErrorMessage:SetText(NO_VIEWABLE_GUILDBANK_TABS);
			self.ErrorMessage:Show();
		elseif ( tab > GetNumGuildBankTabs() ) then
			if ( IsGuildLeader() ) then
				--Show buy screen
				self:HideColumns();
				self.BuyInfo:Show();
				self.ErrorMessage:Hide();
			else
				self:HideColumns();
				self.BuyInfo:Hide();
				self.ErrorMessage:SetText(NO_GUILDBANK_TABS);
				self.ErrorMessage:Show();
			end
		else
			local _, _, _, canDeposit, numWithdrawals = GetGuildBankTabInfo(tab);
			if ( not canDeposit and numWithdrawals == 0 ) then
				self:DesaturateColumns(true);
			else
				self:DesaturateColumns(false);
			end
			self:ShowColumns()
			self.BuyInfo:Hide();
			self.ErrorMessage:Hide();
		end

		-- Update the tab items		
		local button, index, column;
		local texture, itemCount, locked, isFiltered, quality;
		for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
			index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP);
			if ( index == 0 ) then
				index = NUM_SLOTS_PER_GUILDBANK_GROUP;
			end
			column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
			button = self.Columns[column].Buttons[index];
			button:SetID(i);
			texture, itemCount, locked, isFiltered, quality = GetGuildBankItemInfo(tab, i);
			SetItemButtonTexture(button, texture);
			SetItemButtonCount(button, itemCount);
			SetItemButtonDesaturated(button, locked);
		end
		MoneyFrame_Update("GuildBankMoneyFrame", GetGuildBankMoney());
		if ( CanWithdrawGuildBankMoney() ) then
			self.WithdrawButton:Enable();
		else
			self.WithdrawButton:Disable();
		end
	elseif ( self.mode == "log" or self.mode == "moneylog" ) then
		self:HideColumns();
		self.BuyInfo:Hide();
		self.Info:Hide();
		if ( self.noViewableTabs and self.mode == "log" ) then
			self.ErrorMessage:SetText(NO_VIEWABLE_GUILDBANK_LOGS);
			self.ErrorMessage:Show();
			self.Log:Hide();
		else
			self.ErrorMessage:Hide();
			self.Log:Show();
		end
	elseif ( self.mode == "tabinfo" ) then
		self:HideColumns();
		self.ErrorMessage:Hide();
		self.BuyInfo:Hide();
		self.Log:Hide();
		self.Info:Show();
	end
	--Update remaining money
	self:UpdateWithdrawMoney();
end

function GuildBankFrameMixin:UpdateTabBuyingInfo()
	local tabCost = GetGuildBankTabCost();
	local numTabs = GetNumGuildBankTabs();
	self.BuyInfo.PurchasedText:SetText(format(NUM_GUILDBANK_TABS_PURCHASED, numTabs, MAX_BUY_GUILDBANK_TABS));
	if ( not tabCost ) then
		-- You've bought all the tabs
		self.BankTabs[1]:OnClick("LeftButton");
	else
		if ( GetMoney() >= tabCost or (GetMoney() + GetGuildBankMoney()) >= tabCost ) then
			SetMoneyFrameColor("GuildBankFrameTabCostMoneyFrame", "white");
			self.BuyInfo.PurchaseButton:Enable();
		else
			SetMoneyFrameColor("GuildBankFrameTabCostMoneyFrame", "red");
			self.BuyInfo.PurchaseButton:Disable();
		end
		self.BankTabs[numTabs+1]:OnClick("LeftButton");
		MoneyFrame_Update("GuildBankFrameTabCostMoneyFrame", tabCost);
	end
end

function GuildBankFrameMixin:UpdateTabs()
	local tab, iconTexture, tabButton;
	local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals;
	local numTabs = GetNumGuildBankTabs();
	local currentTab = GetCurrentGuildBankTab();
	local unviewableCount = 0;
	local disableAll = nil;
	local updateAgain = nil;
	local isLocked, titleText;
	local withdrawalText, withdrawalStackCount;
	-- Set buyable tab
	local tabToBuyIndex;
	if ( numTabs < MAX_BUY_GUILDBANK_TABS ) then
		tabToBuyIndex = numTabs + 1;
	end
	-- Disable and gray out all tabs if in the moneyLog since the tab is irrelevant
	if ( self.mode == "moneylog" ) then
		disableAll = 1;
	end
	for i=1, MAX_GUILDBANK_TABS do
		tab = self.BankTabs[i];
		tabButton = tab.Button;
		name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(i);
		iconTexture = tabButton.IconTexture;
		if ( not name or name == "" ) then
			name = format(GUILDBANK_TAB_NUMBER, i);
		end
		if ( i == tabToBuyIndex and IsGuildLeader() ) then
			iconTexture:SetTexture("Interface\\GuildBankFrame\\UI-GuildBankFrame-NewTab");
			tabButton.tooltip = BUY_GUILDBANK_TAB;
			tab:Show();
			
			if ( disableAll or self.mode == "log" or self.mode == "tabinfo" ) then
				tabButton:SetChecked(false);
				SetDesaturation(iconTexture, true);
				tabButton:SetButtonState("NORMAL");
				tabButton:Disable();
				if ( self.mode == "log" and i == currentTab and numTabs > 0 ) then
					SetCurrentGuildBankTab(1);
					updateAgain = 1;
				end
			else
				if ( i == currentTab ) then
					tabButton:SetChecked(true);
					tabButton:Disable();
					SetDesaturation(iconTexture, false);
					titleText = BUY_GUILDBANK_TAB;
				else
					tabButton:SetChecked(false);
					tabButton:Enable();
					SetDesaturation(iconTexture, false);
				end
			end
		elseif ( i > numTabs ) then
			tab:Hide();
		else
			iconTexture:SetTexture(icon);
			tab:Show();
			if ( isViewable ) then
				tabButton.tooltip = name;
				if ( i == currentTab ) then
					if ( disableAll ) then
						tabButton:SetChecked(false);
					else
						tabButton:SetChecked(true);
						tabButton:Enable();
					end
					withdrawalText = name;
					titleText =  name;
				else
					tabButton:SetChecked(false);
					tabButton:Enable();
				end
				if ( disableAll ) then
					tabButton:Disable();
					SetDesaturation(iconTexture, true);
				else
					SetDesaturation(iconTexture, false);
				end
			else
				unviewableCount = unviewableCount+1;
				tabButton:Disable();
				SetDesaturation(iconTexture, true);
				tabButton:SetChecked(false);
			end
			
		end
		if ( unviewableCount == numTabs and not IsGuildLeader() ) then
			-- Can't view any tabs so hide everything
			self.noViewableTabs = 1;
		else
			self.noViewableTabs = nil;
		end
		if ( updateAgain ) then
			self:UpdateTabs();
		end
	end

	-- Set Title
	if ( self.mode == "moneylog" ) then
		titleText = GUILD_BANK_MONEY_LOG;
		withdrawalText = nil;
	elseif ( self.mode == "log" ) then
		if ( titleText ) then
			titleText = format(GUILDBANK_LOG_TITLE_FORMAT, titleText);
		end
	elseif ( self.mode == "tabinfo" ) then
		withdrawalText = nil;
		if ( titleText ) then
			titleText = format(GUILDBANK_INFO_TITLE_FORMAT, titleText);
		end
	end
	-- Get selected tab info
	name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(currentTab);
	if ( titleText and (self.mode ~= "moneylog" and titleText ~= BUY_GUILDBANK_TAB) ) then
		local access;
		if ( not canDeposit and numWithdrawals == 0 ) then
			access = GUILDBANK_TAB_LOCKED;
		elseif ( not canDeposit ) then
			access = GUILDBANK_TAB_WITHDRAW_ONLY;
		elseif ( numWithdrawals == 0 ) then
			access = GUILDBANK_TAB_DEPOSIT_ONLY;
		else
			access = GUILDBANK_TAB_FULL_ACCESS;
		end
		titleText = titleText.."  "..access;
	end
	if ( titleText ) then
		self.TabTitle:SetText(titleText);
		self.TabTitleBG:SetWidth(self.TabTitle:GetWidth()+20);

		self.TabTitle:Show();
		self.TabTitleBG:Show();
		self.TabTitleBGLeft:Show();
		self.TabTitleBGRight:Show();
	else
		self.TabTitle:Hide();
		self.TabTitleBG:Hide();
		self.TabTitleBGLeft:Hide();
		self.TabTitleBGRight:Hide();
	end
	if ( withdrawalText ) then
		local stackString;
		if ( remainingWithdrawals > 0 ) then
			stackString = format(STACKS, remainingWithdrawals);
		elseif ( remainingWithdrawals == 0 ) then
			stackString = NONE;
		else
			stackString = UNLIMITED;
		end
		self.LimitLabel:SetText(format(GUILDBANK_REMAINING_MONEY, withdrawalText, stackString));
		self.TabLimitBG:SetWidth(self.LimitLabel:GetWidth()+20);
		-- If the tab name is too long then reanchor the withdraw box so it's not longer centered
		if ( self.LimitLabel:GetWidth() > 298 ) then
			self.TabLimitBG:ClearAllPoints();
			self.TabLimitBG:SetPoint("RIGHT", self.WithdrawButton, "LEFT", -14, -1);
		else
			self.TabLimitBG:ClearAllPoints();
			self.TabLimitBG:SetPoint("TOP", "GuildBankFrame", "TOP", 6, -388);
		end

		self.LimitLabel:Show();
		self.TabLimitBG:Show();
		self.TabLimitBGLeft:Show();
		self.TabLimitBGRight:Show();
	else
		self.LimitLabel:Hide();
		self.TabLimitBG:Hide();
		self.TabLimitBGLeft:Hide();
		self.TabLimitBGRight:Hide();
	end
end

function GuildBankFrameMixin:HideColumns()
	if ( not self.Columns[1]:IsShown() ) then
		return;
	end
	for i=1, NUM_GUILDBANK_COLUMNS do
		self.Columns[i]:Hide();
	end
end

function GuildBankFrameMixin:ShowColumns()
	if ( self.Columns[1]:IsShown() ) then
		return;
	end
	for i=1, NUM_GUILDBANK_COLUMNS do
		self.Columns[i]:Show();
	end
end

function GuildBankFrameMixin:DesaturateColumns(isDesaturated)
	for i=1, NUM_GUILDBANK_COLUMNS do
		SetDesaturation(self.Columns[i].Background, isDesaturated);
	end
end

function GuildBankFrameMixin:UpdateWithdrawMoney()
	local withdrawLimit = GetGuildBankWithdrawMoney();
	if ( withdrawLimit >= 0 ) then
		local amount;
		if ( (not CanGuildBankRepair() and not CanWithdrawGuildBankMoney()) or (CanGuildBankRepair() and not CanWithdrawGuildBankMoney()) ) then
			amount = 0;
		else
			amount = GetGuildBankMoney();
		end
		withdrawLimit = min(withdrawLimit, amount);
		if ( withdrawLimit == 0 ) then
			self.WithdrawButton:Disable();
		else
			self.WithdrawButton:Enable();
		end
		MoneyFrame_Update("GuildBankWithdrawMoneyFrame", withdrawLimit);
		self.UnlimitedLabel:Hide();
		self.WithdrawMoneyFrame:Show();
	else
		self.UnlimitedLabel:Show();
		self.WithdrawMoneyFrame:Hide();
	end
end

function GuildBankFrameMixin:UpdateTabard()
	--Set the tabard images
	local tabardBackgroundUpper, tabardBackgroundLower, tabardEmblemUpper, tabardEmblemLower, tabardBorderUpper, tabardBorderLower = GetGuildTabardFiles();
	if ( not tabardEmblemUpper ) then
		tabardBackgroundUpper = 180159; --"Textures\\GuildEmblems\\Background_49_TU_U";
		tabardBackgroundLower = 180158; --"Textures\\GuildEmblems\\Background_49_TL_U";
	end
	self.Emblem.BackgroundUL:SetTexture(tabardBackgroundUpper);
	self.Emblem.BackgroundUR:SetTexture(tabardBackgroundUpper);
	self.Emblem.BackgroundBL:SetTexture(tabardBackgroundLower);
	self.Emblem.BackgroundBR:SetTexture(tabardBackgroundLower);

	self.Emblem.UL:SetTexture(tabardEmblemUpper);
	self.Emblem.UR:SetTexture(tabardEmblemUpper);
	self.Emblem.BL:SetTexture(tabardEmblemLower);
	self.Emblem.BR:SetTexture(tabardEmblemLower);

	self.Emblem.BorderUL:SetTexture(tabardBorderUpper);
	self.Emblem.BorderUR:SetTexture(tabardBorderUpper);
	self.Emblem.BorderBL:SetTexture(tabardBorderLower);
	self.Emblem.BorderBR:SetTexture(tabardBorderLower);
end

function GuildBankFrameMixin:UpdateTabInfo(tab)
	local text = GetGuildBankText(tab);
	local editBox = self.Info.ScrollFrame.EditBox;
	if ( text ) then
		editBox.text = text;
		editBox:SetText(text);
	else
		editBox:SetText("");
	end
end

function GuildBankFrameMixin:IsTabViewable(tab)
	self.nextAvailableTab = nil;
	local view = false;
	for i=1, MAX_GUILDBANK_TABS do
		local _, _, isViewable = GetGuildBankTabInfo(i);
		if ( isViewable ) then
			if ( not self.nextAvailableTab ) then
				self.nextAvailableTab = i;
			end
			if ( i == tab ) then
				view = true;
			end
		end
	end
	return view;
end


GuildBankTabButtonMixin = {};

function GuildBankTabButtonMixin:OnLoad()
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
end

function GuildBankTabButtonMixin:OnEvent(event, ...)
	if ( event == "INVENTORY_SEARCH_UPDATE" ) then
		self:UpdateFiltered();
	end
end

function GuildBankTabButtonMixin:OnClick(button, down)
	local currentTab = self:GetParent():GetID();
	if ( GetCurrentGuildBankTab() ~= currentTab or button == "RightButton" ) then
		PlaySound(SOUNDKIT.GUILD_BANK_OPEN_BAG);
	end
	self:GetParent():OnClick(button);
end

function GuildBankTabButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true);
end

function GuildBankTabButtonMixin:OnLeave()
	GameTooltip:Hide();
end

GuildBankFrameTabMixin = {};

function GuildBankFrameTabMixin:OnClick(button, down)
	local id = self:GetID();
	local guildBankFrame = self:GetParent();
	local messageFrame = guildBankFrame.Log.MessageFrame;
	local transactionsScroll = guildBankFrame.Log.TransactionsScrollFrame;
	PanelTemplates_SetTab(guildBankFrame, id);
	if ( id == 1 ) then
		--Bank
		guildBankFrame.mode = "bank";
		QueryGuildBankTab(GetCurrentGuildBankTab());
	elseif ( id == 2 ) then
		--Log
		messageFrame:Clear();
		transactionsScroll:Hide();
		guildBankFrame.mode = "log";
		QueryGuildBankLog(GetCurrentGuildBankTab());
		transactionsScroll.ScrollBar:SetValue(0);
	elseif ( id == 3 ) then
		--Money log
		messageFrame:Clear();
		transactionsScroll:Hide();
		guildBankFrame.mode = "moneylog";
		QueryGuildBankLog(MAX_GUILDBANK_TABS + 1);
		transactionsScroll.ScrollBar:SetValue(0);
	else
		--Tab Info
		guildBankFrame.mode = "tabinfo";
		QueryGuildBankText(GetCurrentGuildBankTab());
	end
	--Call this to gray out tabs or activate them
	guildBankFrame:UpdateTabs();
	guildBankFrame:Update();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end


GuildBankTabMixin = {};

function GuildBankTabMixin:OnClick(button, down)
	local guildBankFrame = self:GetParent();
	local currentTab = self:GetID();
	if ( guildBankFrame.Info:IsShown() ) then
		guildBankFrame.Info.SaveButton:Click();
	end
	SetCurrentGuildBankTab(currentTab);
	guildBankFrame:UpdateTabs();
	if ( CanEditGuildBankTabInfo() and button == "RightButton" and currentTab ~= (GetNumGuildBankTabs() + 1) ) then
		--Show the popup if it's a right click
		GuildBankPopupFrame:Show();
		GuildBankPopupFrame:Update();
	end
	guildBankFrame:Update();
	if ( guildBankFrame.Log:IsShown() ) then
		if ( guildBankFrame.mode == "log" ) then
			QueryGuildBankTab(currentTab);	--Need this to get the number of withdrawals left for this tab
			QueryGuildBankLog(currentTab);
			GuildBankFrame_UpdateLog();
		else
			QueryGuildBankLog(MAX_GUILDBANK_TABS + 1);
			GuildBankFrame_UpdateMoneyLog();
		end
	elseif ( guildBankFrame.Info:IsShown() ) then
		QueryGuildBankText(currentTab);
	else
		QueryGuildBankTab(currentTab);
	end
end


GuildBankFrameDepositButtonMixin = {};

function GuildBankFrameDepositButtonMixin:OnClick(button, down)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
	StaticPopup_Hide("GUILDBANK_WITHDRAW");
	if ( StaticPopup_Visible("GUILDBANK_DEPOSIT") ) then
		StaticPopup_Hide("GUILDBANK_DEPOSIT");
	else
		StaticPopup_Show("GUILDBANK_DEPOSIT");
	end
end


GuildBankFrameWithdrawButtonMixin = {};

function GuildBankFrameWithdrawButtonMixin:OnClick(button, down)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
	StaticPopup_Hide("GUILDBANK_DEPOSIT");
	if ( StaticPopup_Visible("GUILDBANK_WITHDRAW") ) then
		StaticPopup_Hide("GUILDBANK_WITHDRAW");
	else
		StaticPopup_Show("GUILDBANK_WITHDRAW");
	end
end


GuildBankItemButtonMixin = {};

function GuildBankItemButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
	self.SplitStack = function(button, split)
		SplitGuildBankItem(GetCurrentGuildBankTab(), button:GetID(), split);
	end
	self.UpdateTooltip = self.OnEnter;
end

function GuildBankItemButtonMixin:OnClick(button)
	if ( HandleModifiedItemClick(GetGuildBankItemLink(GetCurrentGuildBankTab(), self:GetID())) ) then
		return;
	end
	if ( IsModifiedClick("SPLITSTACK") ) then
		if ( not CursorHasItem() ) then
			local texture, count, locked = GetGuildBankItemInfo(GetCurrentGuildBankTab(), self:GetID());
			if ( not locked and count and count > 1) then
				OpenStackSplitFrame(count, self, "BOTTOMLEFT", "TOPLEFT");
			end
		end
		return;
	end
	local type, money = GetCursorInfo();
	if ( type == "money" ) then
		DepositGuildBankMoney(money);
		ClearCursor();
	elseif ( type == "guildbankmoney" ) then
		DropCursorMoney();
		ClearCursor();
	else
		if ( button == "RightButton" ) then
			AutoStoreGuildBankItem(GetCurrentGuildBankTab(), self:GetID());
			self:OnLeave();
		else
			PickupGuildBankItem(GetCurrentGuildBankTab(), self:GetID());
		end
	end
end

function GuildBankItemButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetGuildBankItem(GetCurrentGuildBankTab(), self:GetID());
	if(speciesID and speciesID > 0) then
		BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
	end
end

function GuildBankItemButtonMixin:OnLeave()
	self.updateTooltipTimer = nil;
	GameTooltip_Hide();
	ResetCursor();
end

function GuildBankItemButtonMixin:OnHide()
	if ( self.hasStackSplit and (self.hasStackSplit == 1) ) then
		StackSplitFrame:Hide();
	end
end

function GuildBankItemButtonMixin:OnDragStart()
	PickupGuildBankItem(GetCurrentGuildBankTab(), self:GetID());
end

function GuildBankItemButtonMixin:OnReceiveDrag()
	PickupGuildBankItem(GetCurrentGuildBankTab(), self:GetID());
end

function GuildBankItemButtonMixin:OnEvent()
	if ( GameTooltip:IsOwned(self) ) then
		self:OnEnter();
	end
end

function GuildBankFrame_UpdateLog()
	local tab = GetCurrentGuildBankTab();
	local numTransactions = GetNumGuildBankTransactions(tab);
	local type, name, itemLink, count, tab1, tab2, year, month, day, hour;
	
	local msg;
	GuildBankMessageFrame:Clear();
	for i=1, numTransactions, 1 do
		type, name, itemLink, count, tab1, tab2, year, month, day, hour = GetGuildBankTransaction(tab, i);
		if ( not name ) then
			name = UNKNOWN;
		end
		name = NORMAL_FONT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE;
		if ( type == "deposit" ) then
			msg = format(GUILDBANK_DEPOSIT_FORMAT, name, itemLink);
			if ( count > 1 ) then
				msg = msg..format(GUILDBANK_LOG_QUANTITY, count);
			end
		elseif ( type == "withdraw" ) then
			msg = format(GUILDBANK_WITHDRAW_FORMAT, name, itemLink);
			if ( count > 1 ) then
				msg = msg..format(GUILDBANK_LOG_QUANTITY, count);
			end
		elseif ( type == "move" ) then
			msg = format(GUILDBANK_MOVE_FORMAT, name, itemLink, count, GetGuildBankTabInfo(tab1), GetGuildBankTabInfo(tab2));
		end
		if ( msg ) then
			GuildBankMessageFrame:AddMessage( msg..GUILD_BANK_LOG_TIME:format(RecentTimeDate(year, month, day, hour)) );
		end
	end
	FauxScrollFrame_Update(GuildBankTransactionsScrollFrame, numTransactions, MAX_TRANSACTIONS_SHOWN, GUILDBANK_TRANSACTION_HEIGHT );
end

function GuildBankFrame_UpdateMoneyLog()
	local numTransactions = GetNumGuildBankMoneyTransactions();
	local type, name, amount, year, month, day, hour;
	local msg;
	local money;
	GuildBankMessageFrame:Clear();
	for i=1, numTransactions, 1 do
		type, name, amount, year, month, day, hour = GetGuildBankMoneyTransaction(i);
		if ( not name ) then
			name = UNKNOWN;
		end
		name = NORMAL_FONT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE;
		money = GetDenominationsFromCopper(amount);
		if ( type == "deposit" ) then
			msg = format(GUILDBANK_DEPOSIT_MONEY_FORMAT, name, money);
		elseif ( type == "withdraw" ) then
			msg = format(GUILDBANK_WITHDRAW_MONEY_FORMAT, name, money);
		elseif ( type == "repair" ) then
			msg = format(GUILDBANK_REPAIR_MONEY_FORMAT, name, money);
		elseif ( type == "withdrawForTab" ) then
			msg = format(GUILDBANK_WITHDRAWFORTAB_MONEY_FORMAT, name, money);
		elseif ( type == "buyTab" ) then
			if ( amount > 0 ) then
				msg = format(GUILDBANK_BUYTAB_MONEY_FORMAT, name, money);
			else
				msg = format(GUILDBANK_UNLOCKTAB_FORMAT, name);
			end
		elseif ( type == "depositSummary" ) then
			msg = format(GUILDBANK_AWARD_MONEY_SUMMARY_FORMAT, money);
		end
		GuildBankMessageFrame:AddMessage(msg..GUILD_BANK_LOG_TIME:format(RecentTimeDate(year, month, day, hour)) );
	end
	FauxScrollFrame_Update(GuildBankTransactionsScrollFrame, numTransactions, MAX_TRANSACTIONS_SHOWN, GUILDBANK_TRANSACTION_HEIGHT );
end

function GuildBankLogScroll()
	local offset = FauxScrollFrame_GetOffset(GuildBankTransactionsScrollFrame);
	local numTransactions = 0;
	if ( GuildBankFrame.mode == "log" ) then
		numTransactions = GetNumGuildBankTransactions(GetCurrentGuildBankTab());
	elseif ( GuildBankFrame.mode == "moneylog" ) then
		numTransactions = GetNumGuildBankMoneyTransactions();
	end
	GuildBankMessageFrame:SetScrollOffset(offset);
	FauxScrollFrame_Update(GuildBankTransactionsScrollFrame, numTransactions, MAX_TRANSACTIONS_SHOWN, GUILDBANK_TRANSACTION_HEIGHT );
end


GuildBankPopupFrameMixin = {};

function GuildBankPopupFrameMixin:RefreshIconList()
	if ( GB_ICON_FILENAMES ) then
		return;
	end
	
	GB_ICON_FILENAMES = {};
	GB_ICON_FILENAMES[1] = "INV_MISC_QUESTIONMARK";

	GetLooseMacroItemIcons(GB_ICON_FILENAMES);
	GetLooseMacroIcons(GB_ICON_FILENAMES);
	GetMacroItemIcons(GB_ICON_FILENAMES);
	GetMacroIcons(GB_ICON_FILENAMES);
end

function GuildBankPopupFrameMixin:Update()
	local numguildBankIcons = #GB_ICON_FILENAMES;
	local guildBankPopupOffset = FauxScrollFrame_GetOffset(self.ScrollFrame);
	
	local _, tabTexture = GetGuildBankTabInfo(GetCurrentGuildBankTab());
	tabTexture = gsub( strupper(tabTexture), "INTERFACE\\ICONS\\", "")
	-- Icon list
	local texture, guildBankPopupButton, guildBankPopupIcon, index;
	for i=1, NUM_GUILDBANK_ICONS_SHOWN do
		guildBankPopupButton = self.Buttons[i];
		guildBankPopupIcon = guildBankPopupButton.Icon;
		index = (guildBankPopupOffset * NUM_GUILDBANK_ICONS_PER_ROW) + i;
		texture = GB_ICON_FILENAMES[index];
		if ( index <= numguildBankIcons ) then
			if ( type(texture) == "number" ) then
				guildBankPopupIcon:SetTexture(texture);
			else
				guildBankPopupIcon:SetTexture("INTERFACE\\ICONS\\"..texture);
			end
	
			guildBankPopupButton:Show();
		else
			guildBankPopupIcon:SetTexture("");
			guildBankPopupButton:Hide();
		end
		if ( self.selectedIcon ) then
			if ( index == self.selectedIcon ) then
				guildBankPopupButton:SetChecked(true);
			else
				guildBankPopupButton:SetChecked(false);
			end
		elseif ( tabTexture == texture ) then
			guildBankPopupButton:SetChecked(true);
			self.selectedIcon = index;
		else
			guildBankPopupButton:SetChecked(false);
		end
	end
	--Only do this if the player hasn't clicked on an icon or the icon is not visible
	if ( not self.selectedIcon ) then
		for i=1, numguildBankIcons do
			texture = tostring(GB_ICON_FILENAMES[i]);
			if ( tabTexture == texture ) then
				self.selectedIcon = i;
				if ( i <= NUM_GUILDBANK_ICONS_SHOWN ) then
					self.Buttons[i]:SetChecked(true);
				end
				break;
			end
		end
	end
	
	-- Scrollbar stuff
	FauxScrollFrame_Update(self.ScrollFrame, ceil(numguildBankIcons / NUM_GUILDBANK_ICONS_PER_ROW) + 1, NUM_GUILDBANK_ICON_ROWS, GUILDBANK_ICON_ROW_HEIGHT);
end

function GuildBankPopupFrameMixin:OnLoad()
	self.ScrollFrame.ScrollBar.scrollStep = 8 * GUILDBANK_ICON_ROW_HEIGHT;
end

local GUILD_BANK_POPUP_FRAME_MINIMUM_PADDING = 40;
function GuildBankPopupFrameMixin:OnShow()
	local rightPos = GuildBankFrame:GetRight();
	local space = GetScreenWidth() - rightPos;
	
	local name = GetGuildBankTabInfo(GetCurrentGuildBankTab());
	if ( not name or name == "" ) then
		name = format(GUILDBANK_TAB_NUMBER, GetCurrentGuildBankTab());
	end
	self.EditBox:SetText(name);
	self.selectedIcon = nil;
	self:RefreshIconList();

	if ( not self.iconArrayBuilt ) then
		BuildIconArray(self, "GuildBankPopupButton", "GuildBankPopupButtonTemplate", NUM_GUILDBANK_ICONS_PER_ROW, NUM_GUILDBANK_ICON_ROWS);
		self.iconArrayBuilt = true;
	end
end

function GuildBankPopupFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function GuildBankPopupFrameMixin:ConfirmEdit()
	local name = self.EditBox:GetText();
	local tab = GetCurrentGuildBankTab();
	if ( not name or name == "" ) then
		name = format(GUILDBANK_TAB_NUMBER, tab);
	end
	local iconTexture = GB_ICON_FILENAMES[self.selectedIcon];
	if ( not iconTexture ) then
		local _, texture = GetGuildBankTabInfo(tab);
		iconTexture = gsub( strupper(texture), "INTERFACE\\ICONS\\", "");
	end
		
	SetGuildBankTabInfo(tab, name, iconTexture);
	self:Hide();
end

function GuildBankPopupFrameMixin:CancelEdit()
	self:Hide();
end


GuildBankPopupButtonMixin = {};

function GuildBankPopupButtonMixin:OnClick(button, down)
	local popupFrame = self:GetParent();
	local offset = FauxScrollFrame_GetOffset(popupFrame.ScrollFrame);
	local index = (offset * NUM_GUILDBANK_ICONS_PER_ROW) + self:GetID();
	popupFrame.selectedIcon = index;
	popupFrame:Update();
end


GuildBankPopupCancelButtonMixin = {};

function GuildBankPopupCancelButtonMixin:OnClick(button, down)
	self:GetParent():CancelEdit();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end


GuildBankPopupOkayButtonMixin = {};

function GuildBankPopupOkayButtonMixin:OnClick(button, down)
	self:GetParent():ConfirmEdit();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end


GuildBankPopupEditBoxMixin = {};

function GuildBankPopupEditBoxMixin:OnEscapePressed()
	self:GetParent():CancelEdit();
end

function GuildBankPopupEditBoxMixin:OnEnterPressed()
	local popupFrame = self:GetParent();
	if ( popupFrame.OkayButton:IsEnabled() ) then
		popupFrame:ConfirmEdit();
	end
	self:ClearFocus();
end