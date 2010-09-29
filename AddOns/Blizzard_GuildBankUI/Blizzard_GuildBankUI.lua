MAX_GUILDBANK_SLOTS_PER_TAB = 98;
NUM_SLOTS_PER_GUILDBANK_GROUP = 14;
NUM_GUILDBANK_ICONS_SHOWN = 0;
NUM_GUILDBANK_ICONS_PER_ROW = 4;
NUM_GUILDBANK_ICON_ROWS = 4;
GUILDBANK_ICON_ROW_HEIGHT = 36;
NUM_GUILDBANK_COLUMNS = 7;
MAX_TRANSACTIONS_SHOWN = 21;
GUILDBANK_TRANSACTION_HEIGHT = 13;

UIPanelWindows["GuildBankFrame"] = { area = "doublewide", pushable = 0, width = 769 };

--REMOVE ME!
TABARDBACKGROUNDUPPER = "Textures\\GuildEmblems\\Background_%s_TU_U";
TABARDBACKGROUNDLOWER = "Textures\\GuildEmblems\\Background_%s_TL_U";
TABARDEMBLEMUPPER = "Textures\\GuildEmblems\\Emblem_%s_15_TU_U";
TABARDEMBLEMLOWER = "Textures\\GuildEmblems\\Emblem_%s_15_TL_U";
TABARDBORDERUPPER = "Textures\\GuildEmblems\\Border_%s_02_TU_U";
TABARDBORDERLOWER = "Textures\\GuildEmblems\\Border_%s_02_TL_U";
TABARDBACKGROUNDID = 1;
TABARDEMBLEMID = 1;
TABARDBORDERID = 1;

GUILD_BANK_LOG_TIME_PREPEND = "|cff009999   ";

function GuildBankFrame_ChangeBackground(id)
	if ( id > 50 ) then
		id = 1;
	elseif ( id < 0 ) then
		id = 50;
	end
	TABARDBACKGROUNDID = id;
	GuildBankFrame_UpdateEmblem();
end
function GuildBankFrame_ChangeEmblem(id)
	if ( id > 169 ) then
		id = 1;
	elseif ( id < 0 ) then
		id = 169;
	end
	TABARDEMBLEMID = id;
	GuildBankFrame_UpdateEmblem();
end
function GuildBankFrame_ChangeBorder(id)
	if ( id > 9 ) then
		id = 1;
	elseif ( id < 0 ) then
		id = 9;
	end
	TABARDBORDERID = id;
	GuildBankFrame_UpdateEmblem();
end

function GuildBankFrame_UpdateEmblem()
	local tabardBGID = TABARDBACKGROUNDID;
	if ( tabardBGID < 10 ) then
		tabardBGID = "0"..tabardBGID;
	end
	local tabardEmblemID = TABARDEMBLEMID;
	if ( tabardEmblemID < 10 ) then
		tabardEmblemID = "0"..tabardEmblemID;
	end
	local tabardBorderID = TABARDBORDERID;
	if ( tabardBorderID < 10 ) then
		tabardBorderID = "0"..tabardBorderID;
	end
	GuildBankEmblemBackgroundUL:SetTexture(format(TABARDBACKGROUNDUPPER, tabardBGID));
	GuildBankEmblemBackgroundUR:SetTexture(format(TABARDBACKGROUNDUPPER, tabardBGID));
	GuildBankEmblemBackgroundBL:SetTexture(format(TABARDBACKGROUNDLOWER, tabardBGID));
	GuildBankEmblemBackgroundBR:SetTexture(format(TABARDBACKGROUNDLOWER, tabardBGID));

	GuildBankEmblemUL:SetTexture(format(TABARDEMBLEMUPPER, tabardEmblemID));
	GuildBankEmblemUR:SetTexture(format(TABARDEMBLEMUPPER, tabardEmblemID));
	GuildBankEmblemBL:SetTexture(format(TABARDEMBLEMLOWER, tabardEmblemID));
	GuildBankEmblemBR:SetTexture(format(TABARDEMBLEMLOWER, tabardEmblemID));

	GuildBankEmblemBorderUL:SetTexture(format(TABARDBORDERUPPER, tabardBorderID));
	GuildBankEmblemBorderUR:SetTexture(format(TABARDBORDERUPPER, tabardBorderID));
	GuildBankEmblemBorderBL:SetTexture(format(TABARDBORDERLOWER, tabardBorderID));
	GuildBankEmblemBorderBR:SetTexture(format(TABARDBORDERLOWER, tabardBorderID));
end


function GuildBankFrame_OnLoad(self)
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
	-- Set the button id's
	local index, column, button;
	for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
		index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP);
		if ( index == 0 ) then
			index = NUM_SLOTS_PER_GUILDBANK_GROUP;
		end
		column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
		button = _G["GuildBankColumn"..column.."Button"..index];
		button:SetID(i);
	end
	GuildBankFrame.mode = "bank";
	GuildBankFrame.numTabs = 4;
	GuildBankFrame_UpdateTabs();
	GuildBankFrame_UpdateTabard();

end

function GuildBankFrame_OnEvent(self, event, ...)
	if ( not GuildBankFrame:IsVisible() ) then
		return;
	end
	if ( event == "GUILDBANKBAGSLOTS_CHANGED" or event =="GUILDBANK_ITEM_LOCK_CHANGED" ) then
		GuildBankFrame_UpdateTabs();
		GuildBankFrame_Update();
	elseif ( event == "GUILDBANK_UPDATE_TABS" or event == "GUILD_ROSTER_UPDATE" ) then
		local tab = GetCurrentGuildBankTab();
		if ( event == "GUILD_ROSTER_UPDATE" and not select(1, ...) and GuildBankFrame.noViewableTabs and GuildBankFrame.mode == "bank" ) then
			-- if rank changed while at the bank tab and not having any viewable tabs, query for new item data 
			QueryGuildBankTab(tab);
		end
		
		GuildBankFrame_SelectAvailableTab();
		
		if ( GuildBankFrameBuyInfo:IsShown() ) then
			GuildBankFrame_UpdateTabBuyingInfo();
		end
		local _, _, canView, canDeposit, numWithdrawals = GetGuildBankTabInfo(tab);
		if ( canView and CanEditGuildTabInfo(GetCurrentGuildBankTab(tab)) ) then
			GuildBankInfoSaveButton:Show();
		else
			GuildBankInfoSaveButton:Hide();
		end
	elseif ( event == "GUILDBANKLOG_UPDATE" ) then
		if ( GuildBankFrame.mode == "log" ) then
			GuildBankFrame_UpdateLog();
		else
			GuildBankFrame_UpdateMoneyLog();
		end
		GuildBankLogScroll();
	elseif ( event == "GUILDTABARD_UPDATE" ) then
		GuildBankFrame_UpdateTabard();
	elseif ( event == "GUILDBANK_UPDATE_MONEY" or event == "GUILDBANK_UPDATE_WITHDRAWMONEY" ) then
		GuildBankFrame_UpdateWithdrawMoney();
	elseif ( event == "GUILDBANK_UPDATE_TEXT" ) then
		GuildBankFrame_UpdateTabInfo(...);
	elseif ( event == "GUILDBANK_TEXT_CHANGED" ) then
		local arg1 = ...
		if ( GetCurrentGuildBankTab() == tonumber(arg1) ) then
			QueryGuildBankText(arg1);
		end
	elseif ( event == "PLAYER_MONEY" ) then
		if ( GuildBankFrameBuyInfo:IsShown() ) then
			GuildBankFrame_UpdateTabBuyingInfo();
		end
	end
end

function GuildBankFrame_SelectAvailableTab()
	--If the selected tab is notViewable then select the next available one
	if ( IsTabViewable(GetCurrentGuildBankTab()) ) then
		GuildBankFrame_UpdateTabs();
		GuildBankFrame_Update();
	else
		if ( GuildBankFrame.nextAvailableTab ) then
			GuildBankTab_OnClick(_G["GuildBankTab" .. GuildBankFrame.nextAvailableTab], "LeftButton", GuildBankFrame.nextAvailableTab);
		else
			GuildBankFrame_UpdateTabs();
			GuildBankFrame_Update();
		end
	end
end

function GuildBankFrame_OnShow()
	GuildBankFrameTab_OnClick(GuildBankFrameTab1, 1);
	GuildBankFrame_UpdateTabard();
	GuildBankFrame_SelectAvailableTab();
	PlaySound("GuildVaultOpen");
end

function GuildBankFrame_Update()
	--Figure out which mode you're in and which tab is selected
	if ( GuildBankFrame.mode == "bank" ) then
		-- Determine whether its the buy tab or not
		GuildBankFrameLog:Hide();
		GuildBankInfo:Hide();	
		local tab = GetCurrentGuildBankTab();
		if ( GuildBankFrame.noViewableTabs ) then
			GuildBankFrame_HideColumns();
			GuildBankFrameBuyInfo:Hide();
			GuildBankErrorMessage:SetText(NO_VIEWABLE_GUILDBANK_TABS);
			GuildBankErrorMessage:Show();
		elseif ( tab > GetNumGuildBankTabs() ) then
			if ( IsGuildLeader() ) then
				--Show buy screen
				GuildBankFrame_HideColumns();
				GuildBankFrameBuyInfo:Show();
				GuildBankErrorMessage:Hide();
			else
				GuildBankFrame_HideColumns();
				GuildBankFrameBuyInfo:Hide();
				GuildBankErrorMessage:SetText(NO_GUILDBANK_TABS);
				GuildBankErrorMessage:Show();
			end
		else
			local _, _, _, canDeposit, numWithdrawals = GetGuildBankTabInfo(tab);
			if ( not canDeposit and numWithdrawals == 0 ) then
				GuildBankFrame_DesaturateColumns(1);
			else
				GuildBankFrame_DesaturateColumns(nil);
			end
			GuildBankFrame_ShowColumns()
			GuildBankFrameBuyInfo:Hide();
			GuildBankErrorMessage:Hide();
		end

		-- Update the tab items		
		local button, index, column;
		local texture, itemCount, locked;
		for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
			index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP);
			if ( index == 0 ) then
				index = NUM_SLOTS_PER_GUILDBANK_GROUP;
			end
			column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
			button = _G["GuildBankColumn"..column.."Button"..index];
			button:SetID(i);
			texture, itemCount, locked = GetGuildBankItemInfo(tab, i);
			SetItemButtonTexture(button, texture);
			SetItemButtonCount(button, itemCount);
			SetItemButtonDesaturated(button, locked);
		end
		MoneyFrame_Update("GuildBankMoneyFrame", GetGuildBankMoney());
		if ( CanWithdrawGuildBankMoney() ) then
			GuildBankFrameWithdrawButton:Enable();
		else
			GuildBankFrameWithdrawButton:Disable();
		end
	elseif ( GuildBankFrame.mode == "log" or GuildBankFrame.mode == "moneylog" ) then
		GuildBankFrame_HideColumns();
		GuildBankFrameBuyInfo:Hide();
		GuildBankInfo:Hide();	
		if ( GuildBankFrame.noViewableTabs and GuildBankFrame.mode == "log" ) then
			GuildBankErrorMessage:SetText(NO_VIEWABLE_GUILDBANK_LOGS);
			GuildBankErrorMessage:Show();
			GuildBankFrameLog:Hide();
		else
			GuildBankErrorMessage:Hide();
			GuildBankFrameLog:Show();
		end
	elseif ( GuildBankFrame.mode == "tabinfo" ) then
		GuildBankFrame_HideColumns();
		GuildBankErrorMessage:Hide();
		GuildBankFrameBuyInfo:Hide();
		GuildBankFrameLog:Hide();
		GuildBankInfo:Show();
	end
	--Update remaining money
	GuildBankFrame_UpdateWithdrawMoney();
end

function GuildBankFrameTab_OnClick(tab, id, doNotUpdate)
	PanelTemplates_SetTab(GuildBankFrame, id);
	if ( id == 1 ) then
		--Bank
		GuildBankFrame.mode = "bank";
		if ( not doNotUpdate ) then
			QueryGuildBankTab(GetCurrentGuildBankTab());
		end
	elseif ( id == 2 ) then
		--Log
		GuildBankMessageFrame:Clear();
		GuildBankTransactionsScrollFrame:Hide();
		GuildBankFrame.mode = "log";
		if ( not doNotUpdate ) then
			QueryGuildBankLog(GetCurrentGuildBankTab());
		end
		GuildBankTransactionsScrollFrameScrollBar:SetValue(0);
	elseif ( id == 3 ) then
		--Money log
		GuildBankMessageFrame:Clear();
		GuildBankTransactionsScrollFrame:Hide();
		GuildBankFrame.mode = "moneylog";
		if ( not doNotUpdate ) then
			QueryGuildBankLog(MAX_GUILDBANK_TABS + 1);
		end
		GuildBankTransactionsScrollFrameScrollBar:SetValue(0);
	else
		--Tab Info
		GuildBankFrame.mode = "tabinfo";
		if ( not doNotUpdate ) then
			QueryGuildBankText(GetCurrentGuildBankTab());
		end
	end
	--Call this to gray out tabs or activate them
	GuildBankFrame_UpdateTabs();
	if ( not doNotUpdate ) then
		GuildBankFrame_Update();
	end
	PlaySound("igCharacterInfoTab");
end

function GuildBankFrame_UpdateTabBuyingInfo()
	local tabCost = GetGuildBankTabCost();
	local numTabs = GetNumGuildBankTabs();
	GuildBankFrameBuyInfoNumTabsPurchasedText:SetText(format(NUM_GUILDBANK_TABS_PURCHASED, numTabs, MAX_BUY_GUILDBANK_TABS));
	if ( not tabCost ) then
		--You've bought all the tabs
		GuildBankTab_OnClick(GuildBankTab1, "LeftButton", 1);
	else
		if( GetMoney() >= tabCost or (GetMoney() + GetGuildBankMoney()) >= tabCost ) then
			SetMoneyFrameColor("GuildBankFrameTabCostMoneyFrame", "white");
			GuildBankFramePurchaseButton:Enable();
		else
			SetMoneyFrameColor("GuildBankFrameTabCostMoneyFrame", "red");
			GuildBankFramePurchaseButton:Disable();
		end
		GuildBankTab_OnClick(_G["GuildBankTab" .. numTabs+1], "LeftButton", numTabs+1);
		MoneyFrame_Update("GuildBankFrameTabCostMoneyFrame", tabCost);
	end
end

function GuildBankFrame_UpdateTabs()
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
	if ( GuildBankFrame.mode == "moneylog" ) then
		disableAll = 1;
	end
	for i=1, MAX_GUILDBANK_TABS do
		tab = _G["GuildBankTab"..i];
		tabButton = _G["GuildBankTab"..i.."Button"];
		name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(i);
		iconTexture = _G["GuildBankTab"..i.."ButtonIconTexture"];
		if ( not name or name == "" ) then
			name = format(GUILDBANK_TAB_NUMBER, i);
		end
		if ( i == tabToBuyIndex and IsGuildLeader() ) then
			iconTexture:SetTexture("Interface\\GuildBankFrame\\UI-GuildBankFrame-NewTab");
			tabButton.tooltip = BUY_GUILDBANK_TAB;
			tab:Show();
			
			if ( disableAll or GuildBankFrame.mode == "log" or GuildBankFrame.mode == "tabinfo" ) then
				tabButton:SetChecked(nil);
				SetDesaturation(iconTexture, 1);
				tabButton:SetButtonState("NORMAL");
				tabButton:Disable();
				if ( GuildBankFrame.mode == "log" and i == currentTab and numTabs > 0 ) then
					SetCurrentGuildBankTab(1);
					updateAgain = 1;
				end
			else
				if ( i == currentTab ) then
					tabButton:SetChecked(1);
					tabButton:Disable();
					SetDesaturation(iconTexture, nil);
					titleText = BUY_GUILDBANK_TAB;
				else
					tabButton:SetChecked(nil);
					tabButton:Enable();
					SetDesaturation(iconTexture, nil);
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
						tabButton:SetChecked(nil);
					else
						tabButton:SetChecked(1);
						tabButton:Enable();
					end
					withdrawalText = name;
					titleText =  name;
				else
					tabButton:SetChecked(nil);
					tabButton:Enable();
				end
				if ( disableAll ) then
					tabButton:Disable();
					SetDesaturation(iconTexture, 1);
				else
					SetDesaturation(iconTexture, nil);
				end
			else
				unviewableCount = unviewableCount+1;
				tabButton:Disable();
				SetDesaturation(iconTexture, 1);
				tabButton:SetChecked(nil);
			end
			
		end
		if ( unviewableCount == numTabs and not IsGuildLeader() ) then
			--Can't view any tabs so hide everything
			GuildBankFrame.noViewableTabs = 1;
		else
			GuildBankFrame.noViewableTabs = nil;
		end
		if ( updateAgain ) then
			GuildBankFrame_UpdateTabs();
		end
	end

	-- Set Title
	if ( GuildBankFrame.mode == "moneylog" ) then
		titleText = GUILD_BANK_MONEY_LOG;
		withdrawalText = nil;
	elseif ( GuildBankFrame.mode == "log" ) then
		if ( titleText ) then
			titleText = format(GUILDBANK_LOG_TITLE_FORMAT, titleText);	
		end
	elseif ( GuildBankFrame.mode == "tabinfo" ) then
		withdrawalText = nil;
		if ( titleText ) then
			titleText = format(GUILDBANK_INFO_TITLE_FORMAT, titleText);
		end
	end
	--Get selected tab info
	name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(currentTab);
	if ( titleText and (GuildBankFrame.mode ~= "moneylog" and titleText ~= BUY_GUILDBANK_TAB) ) then
		local access;
		if ( not canDeposit and numWithdrawals == 0 ) then
			access = RED_FONT_COLOR_CODE.."("..GUILDBANK_TAB_LOCKED..")"..FONT_COLOR_CODE_CLOSE;
		elseif ( not canDeposit ) then
			access = RED_FONT_COLOR_CODE.."("..GUILDBANK_TAB_WITHDRAW_ONLY..")"..FONT_COLOR_CODE_CLOSE;
		elseif ( numWithdrawals == 0 ) then
			access = RED_FONT_COLOR_CODE.."("..GUILDBANK_TAB_DEPOSIT_ONLY..")"..FONT_COLOR_CODE_CLOSE;
		else
			access = GREEN_FONT_COLOR_CODE.."("..GUILDBANK_TAB_FULL_ACCESS..")"..FONT_COLOR_CODE_CLOSE;
		end
		titleText = titleText.."  "..access;
	end
	if ( titleText ) then
		GuildBankTabTitle:SetText(titleText);
		GuildBankTabTitleBackground:SetWidth(GuildBankTabTitle:GetWidth()+20);

		GuildBankTabTitle:Show();
		GuildBankTabTitleBackground:Show();
		GuildBankTabTitleBackgroundLeft:Show();
		GuildBankTabTitleBackgroundRight:Show();
	else
		GuildBankTabTitle:Hide();
		GuildBankTabTitleBackground:Hide();
		GuildBankTabTitleBackgroundLeft:Hide();
		GuildBankTabTitleBackgroundRight:Hide();
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
		GuildBankLimitLabel:SetText(format(GUILDBANK_REMAINING_MONEY, withdrawalText, stackString));
		GuildBankTabLimitBackground:SetWidth(GuildBankLimitLabel:GetWidth()+20);
		--If the tab name is too long then reanchor the withdraw box so it's not longer centered
		if ( GuildBankLimitLabel:GetWidth() > 298 ) then
			GuildBankTabLimitBackground:ClearAllPoints();
			GuildBankTabLimitBackground:SetPoint("RIGHT", GuildBankFrameWithdrawButton, "LEFT", -14, -1);
		else
			GuildBankTabLimitBackground:ClearAllPoints();
			GuildBankTabLimitBackground:SetPoint("TOP", "GuildBankFrame", "TOP", 6, -388);
		end

		GuildBankLimitLabel:Show();
		GuildBankTabLimitBackground:Show();
		GuildBankTabLimitBackgroundLeft:Show();
		GuildBankTabLimitBackgroundRight:Show();
	else
		GuildBankLimitLabel:Hide();
		GuildBankTabLimitBackground:Hide();
		GuildBankTabLimitBackgroundLeft:Hide();
		GuildBankTabLimitBackgroundRight:Hide();
	end
end

function GuildBankTab_OnClick(self, mouseButton, currentTab)
	if ( GuildBankInfo:IsShown() ) then
		GuildBankInfoSaveButton:Click();
	end
	if ( not currentTab ) then
		currentTab = self:GetParent():GetID();
	end
	SetCurrentGuildBankTab(currentTab);
	GuildBankFrame_UpdateTabs();
	if ( IsGuildLeader() and mouseButton == "RightButton" and currentTab ~= (GetNumGuildBankTabs() + 1) ) then
		--Show the popup if it's a right click
		GuildBankPopupFrame:Show();
		GuildBankPopupFrame_Update(currentTab);
	end
	GuildBankFrame_Update();
	if ( GuildBankFrameLog:IsShown() ) then
		if ( GuildBankFrame.mode == "log" ) then
			QueryGuildBankTab(currentTab);	--Need this to get the number of withdrawals left for this tab
			QueryGuildBankLog(currentTab);
			GuildBankFrame_UpdateLog();
		else
			QueryGuildBankLog(MAX_GUILDBANK_TABS+1);
			GuildBankFrame_UpdateMoneyLog();
		end
	elseif ( GuildBankInfo:IsShown() ) then
		QueryGuildBankText(currentTab);
	else
		QueryGuildBankTab(currentTab);
	end
end

function GuildBankFrame_HideColumns()
	if ( not GuildBankColumn1:IsShown() ) then
		return;
	end
	for i=1, NUM_GUILDBANK_COLUMNS do
		_G["GuildBankColumn"..i]:Hide();
	end
end

function GuildBankFrame_ShowColumns()
	if ( GuildBankColumn1:IsShown() ) then
		return;
	end
	for i=1, NUM_GUILDBANK_COLUMNS do
		_G["GuildBankColumn"..i]:Show();
	end
end

function GuildBankFrame_DesaturateColumns(isDesaturated)
	for i=1, NUM_GUILDBANK_COLUMNS do
		SetDesaturation(_G["GuildBankColumn"..i.."Background"], isDesaturated);
	end
end

function GuildBankItemButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
	self.SplitStack = function(button, split)
		SplitGuildBankItem(GetCurrentGuildBankTab(), button:GetID(), split);
	end
	self.UpdateTooltip = GuildBankItemButton_OnEnter;
end

function GuildBankItemButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetGuildBankItem(GetCurrentGuildBankTab(), self:GetID());
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
			GuildBankMessageFrame:AddMessage( msg..GUILD_BANK_LOG_TIME_PREPEND..format(GUILD_BANK_LOG_TIME, RecentTimeDate(year, month, day, hour)) );
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
			msg = format(GUILDBANK_BUYTAB_MONEY_FORMAT, name, money);
		end
		GuildBankMessageFrame:AddMessage(msg..GUILD_BANK_LOG_TIME_PREPEND..format(GUILD_BANK_LOG_TIME, RecentTimeDate(year, month, day, hour)));
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

function IsTabViewable(tab)
	GuildBankFrame.nextAvailableTab = nil;
	local view = false;
	for i=1, MAX_GUILDBANK_TABS do
		local _, _, isViewable = GetGuildBankTabInfo(i);
		if ( isViewable ) then
			if ( not GuildBankFrame.nextAvailableTab ) then
				GuildBankFrame.nextAvailableTab = i;
			end
			if ( i == tab ) then
				view = true;
			end
		end
	end
	return view;
end

function GuildBankFrame_UpdateWithdrawMoney()
	local withdrawLimit = GetGuildBankWithdrawMoney();
	if ( withdrawLimit >= 0 ) then
		local amount;
		if ( (not CanGuildBankRepair() and not CanWithdrawGuildBankMoney()) or (CanGuildBankRepair() and not CanWithdrawGuildBankMoney()) ) then
			amount = 0;
		else
			amount = GetGuildBankMoney();
		end
		withdrawLimit = min(withdrawLimit, amount);
		MoneyFrame_Update("GuildBankWithdrawMoneyFrame", withdrawLimit);
		GuildBankMoneyUnlimitedLabel:Hide();
		GuildBankWithdrawMoneyFrame:Show();
	else
		GuildBankMoneyUnlimitedLabel:Show();
		GuildBankWithdrawMoneyFrame:Hide();
	end
end

function GuildBankFrame_UpdateTabard()
	--Set the tabard images
	local tabardBackgroundUpper, tabardBackgroundLower, tabardEmblemUpper, tabardEmblemLower, tabardBorderUpper, tabardBorderLower = GetGuildTabardFileNames();
	if ( not tabardEmblemUpper ) then
		tabardBackgroundUpper = "Textures\\GuildEmblems\\Background_49_TU_U";
		tabardBackgroundLower = "Textures\\GuildEmblems\\Background_49_TL_U";
	end
	GuildBankEmblemBackgroundUL:SetTexture(tabardBackgroundUpper);
	GuildBankEmblemBackgroundUR:SetTexture(tabardBackgroundUpper);
	GuildBankEmblemBackgroundBL:SetTexture(tabardBackgroundLower);
	GuildBankEmblemBackgroundBR:SetTexture(tabardBackgroundLower);

	GuildBankEmblemUL:SetTexture(tabardEmblemUpper);
	GuildBankEmblemUR:SetTexture(tabardEmblemUpper);
	GuildBankEmblemBL:SetTexture(tabardEmblemLower);
	GuildBankEmblemBR:SetTexture(tabardEmblemLower);

	GuildBankEmblemBorderUL:SetTexture(tabardBorderUpper);
	GuildBankEmblemBorderUR:SetTexture(tabardBorderUpper);
	GuildBankEmblemBorderBL:SetTexture(tabardBorderLower);
	GuildBankEmblemBorderBR:SetTexture(tabardBorderLower);
end

function GuildBankFrame_UpdateTabInfo(tab)
	local text = GetGuildBankText(tab);
	if ( text ) then
		GuildBankTabInfoEditBox.text = text;
		GuildBankTabInfoEditBox:SetText(text);
	else
		GuildBankTabInfoEditBox:SetText("");
	end
end

--Popup functions
function GuildBankPopupFrame_Update(tab)
	local numguildBankIcons = GetNumMacroItemIcons();
	local guildBankPopupIcon, guildBankPopupButton;
	local guildBankPopupOffset = FauxScrollFrame_GetOffset(GuildBankPopupScrollFrame);
	local index;
	
	local _, tabTexture  = GetGuildBankTabInfo(GetCurrentGuildBankTab());
	
	-- Icon list
	local texture;
	for i=1, NUM_GUILDBANK_ICONS_SHOWN do
		guildBankPopupIcon = _G["GuildBankPopupButton"..i.."Icon"];
		guildBankPopupButton = _G["GuildBankPopupButton"..i];
		index = (guildBankPopupOffset * NUM_GUILDBANK_ICONS_PER_ROW) + i;
		texture = GetMacroItemIconInfo(index);
		if ( index <= numguildBankIcons ) then
			guildBankPopupIcon:SetTexture(texture);
			guildBankPopupButton:Show();
		else
			guildBankPopupIcon:SetTexture("");
			guildBankPopupButton:Hide();
		end
		if ( GuildBankPopupFrame.selectedIcon ) then
			if ( index == GuildBankPopupFrame.selectedIcon ) then
				guildBankPopupButton:SetChecked(1);
			else
				guildBankPopupButton:SetChecked(nil);
			end
		elseif ( tabTexture == texture ) then
			guildBankPopupButton:SetChecked(1);
			GuildBankPopupFrame.selectedIcon = index;
		else
			guildBankPopupButton:SetChecked(nil);
		end
	end
	--Only do this if the player hasn't clicked on an icon or the icon is not visible
	if ( not GuildBankPopupFrame.selectedIcon ) then
		for i=1, numguildBankIcons do
			texture = GetMacroItemIconInfo(i);
			if ( tabTexture == texture ) then
				GuildBankPopupFrame.selectedIcon = i;
				break;
			end
		end
	end
	
	-- Scrollbar stuff
	FauxScrollFrame_Update(GuildBankPopupScrollFrame, ceil(numguildBankIcons / NUM_GUILDBANK_ICONS_PER_ROW) , NUM_GUILDBANK_ICON_ROWS, GUILDBANK_ICON_ROW_HEIGHT );
end

function GuildBankPopupFrame_OnShow(self)
	local name = GetGuildBankTabInfo(GetCurrentGuildBankTab());
	if ( not name or name == "" ) then
		name = format(GUILDBANK_TAB_NUMBER, GetCurrentGuildBankTab());
	end
	GuildBankPopupEditBox:SetText(name);
	GuildBankPopupFrame.selectedIcon = nil;
end

function GuildBankPopupButton_OnClick(self, button)
	local offset = FauxScrollFrame_GetOffset(GuildBankPopupScrollFrame);
	local index = (offset * NUM_GUILDBANK_ICONS_PER_ROW)+self:GetID();
	GuildBankPopupFrame.selectedIcon = index;
	GuildBankPopupFrame_Update(GetCurrentGuildBankTab());
end

function GuildBankPopupOkayButton_OnClick(self)
	local name = GuildBankPopupEditBox:GetText();
	local tab = GetCurrentGuildBankTab();
	if ( not name or name == "" ) then
		name = format(GUILDBANK_TAB_NUMBER, tab);
	end
	SetGuildBankTabInfo(tab, name, GuildBankPopupFrame.selectedIcon);
	GuildBankPopupFrame:Hide();
end

function GuildBankPopupFrame_CancelEdit()
	GuildBankPopupFrame:Hide();
end

