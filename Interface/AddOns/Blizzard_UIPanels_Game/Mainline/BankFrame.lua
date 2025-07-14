local PURCHASE_TAB_ID = -1;

BankFrameMixin = CreateFromMixins(CallbackRegistryMixin);

BankFrameMixin:GenerateCallbackEvents(
{
	"TitleUpdateRequested",
});

function BankFrameMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:AddDynamicEventMethod(self, BankFrameMixin.Event.TitleUpdateRequested, self.OnTitleUpdateRequested);

	TabSystemOwnerMixin.OnLoad(self);
	self:InitializeTabSystem();
end

function BankFrameMixin:OnTitleUpdateRequested(titleText)
	self:SetTitle(titleText);
end

function BankFrameMixin:InitializeTabSystem()
	self:SetTabSystem(self.TabSystem);
	self:GenerateBankTypeTabs();
end

function BankFrameMixin:GenerateBankTypeTabs()
	self.TabIDToBankType = {};

	self.characterBankTabID = self:AddNamedTab(BANK, self.BankPanel);
	self.TabIDToBankType[self.characterBankTabID] = Enum.BankType.Character;

	self.accountBankTabID = self:AddNamedTab(ACCOUNT_BANK_PANEL_TITLE, self.BankPanel);
	self.TabIDToBankType[self.accountBankTabID] = Enum.BankType.Account;
end

function BankFrameMixin:SetTab(tabID)
	self.BankPanel:SetBankType(self.TabIDToBankType[tabID]);
	TabSystemOwnerMixin.SetTab(self, tabID);
	self:UpdateWidthForSelectedTab();
end

function BankFrameMixin:UpdateWidthForSelectedTab()
	local tabPage = self:GetElementsForTab(self:GetTab())[1];
	self:SetWidth(tabPage:GetWidth());
	UpdateUIPanelPositions(self);
end

function BankFrameMixin:RefreshTabVisibility()
	for _index, tabID in ipairs(self:GetTabSet()) do
		self.TabSystem:SetTabShown(tabID, C_Bank.CanViewBank(self.TabIDToBankType[tabID]));
	end
end

function BankFrameMixin:SelectDefaultTab()
	self:SelectFirstAvailableTab();
end

function BankFrameMixin:SelectFirstAvailableTab()
	for _index, tabID in ipairs(self:GetTabSet()) do
		if self:GetTabButton(tabID):IsShown() then
			self:SetTab(tabID);
			return;
		end
	end
end

function BankFrameMixin:GetActiveBankType()
	return self.BankPanel:IsShown() and self.BankPanel:GetActiveBankType() or nil;
end

function BankFrameMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	OpenAllBags(self);
	self:RefreshTabVisibility();
	self:SelectDefaultTab();
end

function BankFrameMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	CloseAllBags(self);
	C_Bank.CloseBankFrame();
	UpdateContainerFrameAnchors();
end

function BankFrame_Open()
	if not C_Bank.AreAnyBankTypesViewable() then
		HideUIPanel(BankFrame);
		C_Bank.CloseBankFrame();
		UIErrorsFrame:AddExternalErrorMessage(ERR_BANK_NOT_ACCESSIBLE);
		return;
	end

	BankFrame:SetPortraitToUnit("npc");
	ShowUIPanel(BankFrame);
	if not BankFrame:IsShown() then
		C_Bank.CloseBankFrame();
	end
end

BankPanelSystemMixin = {};

function BankPanelSystemMixin:GetBankPanel()
	return BankPanel;
end

function BankPanelSystemMixin:GetBankTabSettingsMenu()
	return self:GetBankPanel().TabSettingsMenu;
end

function BankPanelSystemMixin:GetActiveBankType()
	return self:GetBankPanel():GetActiveBankType();
end

function BankPanelSystemMixin:IsActiveBankTypeLocked()
	return self:GetBankPanel():IsBankTypeLocked();
end

StaticPopupDialogs["CONFIRM_BUY_BANK_TAB"] = {
	text = CONFIRM_BUY_CHARACTER_BANK_TAB, 	-- Text is dynamically updated
	wide = true,
	wideText = true,

	button1 = YES,
	button2 = NO,

	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1,

	OnAccept = function(dialog, data)
		C_Bank.PurchaseBankTab(data.bankType);
	end,
	OnShow = function(dialog, data)
		local tabData = C_Bank.FetchNextPurchasableBankTabData(data.bankType);
		if tabData then
			MoneyFrame_Update(dialog.MoneyFrame, tabData.tabCost);
		end
	end,
};

StaticPopupDialogs["BANK_MONEY_WITHDRAW"] = {
	text = BANK_MONEY_WITHDRAW_PROMPT,

	button1 = ACCEPT,
	button2 = CANCEL,

	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1,

	OnAccept = function(dialog, data)
		local amountToWithdraw = MoneyInputFrame_GetCopper(dialog.MoneyInputFrame);
		C_Bank.WithdrawMoney(data.bankType, amountToWithdraw);
	end,
	OnHide = function(dialog, data)
		MoneyInputFrame_ResetMoney(dialog.MoneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent():GetParent();
		local amountToWithdraw = MoneyInputFrame_GetCopper(dialog.MoneyInputFrame);
		C_Bank.WithdrawMoney(data.bankType, amountToWithdraw);
		dialog:Hide();
	end,
};

StaticPopupDialogs["BANK_MONEY_DEPOSIT"] = {
	text = BANK_MONEY_DEPOSIT_PROMPT,

	button1 = ACCEPT,
	button2 = CANCEL,

	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1,

	OnAccept = function(dialog, data)
		local amountToDeposit = MoneyInputFrame_GetCopper(dialog.MoneyInputFrame);
		C_Bank.DepositMoney(data.bankType, amountToDeposit);
	end,
	OnHide = function(dialog, data)
		MoneyInputFrame_ResetMoney(dialog.MoneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent():GetParent();
		local amountToDeposit = MoneyInputFrame_GetCopper(dialog.MoneyInputFrame);
		C_Bank.DepositMoney(data.bankType, amountToDeposit);
		dialog:Hide();
	end,
};

StaticPopupDialogs["ACCOUNT_BANK_DEPOSIT_NO_REFUND_CONFIRM"] = {
	text = END_REFUND,
	button1 = OKAY,
	button2 = CANCEL,
	OnCancel = function(dialog, data)
		ClearCursor();
	end,
	OnAccept = function(dialog, data)
		if (BankFrame:GetActiveBankType() ~= Enum.BankType.Account) or not C_Bank.CanUseBank(Enum.BankType.Account) or not data.itemToDeposit then
			return;
		end

		local depositAtTargetLocation = data.targetItemLocation ~= nil;
		if depositAtTargetLocation then
			local cursorItemLocation = C_Cursor.GetCursorItem();
			local cursorItemChanged = not cursorItemLocation or (C_Item.GetItemGUID(cursorItemLocation) ~= data.itemToDeposit:GetItemGUID());
			if cursorItemChanged then
				return;
			end

			local targetBag, targetSlot = data.targetItemLocation:GetBagAndSlot();
			if targetBag and targetSlot then
				C_Container.PickupContainerItem(targetBag, targetSlot);
			end
		else
			-- Auto deposit the item
			local itemLocation = data.itemToDeposit:GetItemLocation();
			local bag, slot = itemLocation:GetBagAndSlot();
			if bag and slot then
				local unitToken, isReagentBankOpen = nil, false;
				C_Container.UseContainerItem(bag, slot, unitToken, Enum.BankType.Account, isReagentBankOpen);
			end
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["ACCOUNT_BANK_DEPOSIT_ALL_NO_REFUND_CONFIRM"] = {
	text = ACCOUNT_BANK_DEPOSIT_ALL_NO_REFUND_CONFIRM,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_Bank.AutoDepositItemsIntoBank(Enum.BankType.Account);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
};

BankPanelTabMixin = CreateFromMixins(BankPanelSystemMixin);

local BANK_PANEL_TAB_EVENTS = {
	"INVENTORY_SEARCH_UPDATE",
};

function BankPanelTabMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp","RightButtonUp");

	self:AddDynamicEventMethod(self:GetBankPanel(), BankPanelMixin.Event.NewBankTabSelected, self.OnNewBankTabSelected);
end

function BankPanelTabMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	FrameUtil.RegisterFrameForEvents(self, BANK_PANEL_TAB_EVENTS);
end

function BankPanelTabMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, BANK_PANEL_TAB_EVENTS);
end

function BankPanelTabMixin:OnEvent(event, ...)
	if event == "INVENTORY_SEARCH_UPDATE" then
		self:RefreshSearchOverlay();
	end
end

function BankPanelTabMixin:OnClick(button)
	if button == "RightButton" and not self:IsPurchaseTab() then
		self:GetBankTabSettingsMenu():TriggerEvent(BankPanelTabSettingsMenuMixin.Event.OpenTabSettingsRequested, self.tabData.ID);
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
	self:GetBankPanel():TriggerEvent(BankPanelMixin.Event.BankTabClicked, self.tabData.ID);
end

function BankPanelTabMixin:OnEnter()
	if not self:IsPurchaseTab() then
		self:ShowTooltip();
	end
end

local function AddBankTabSettingsToTooltip(tooltip, depositFlags)
	if not tooltip or not depositFlags then
		return;
	end

	if FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionCurrent) then
		GameTooltip_AddNormalLine(tooltip, BANK_TAB_EXPANSION_ASSIGNMENT:format(BANK_TAB_EXPANSION_FILTER_CURRENT));
	elseif FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionLegacy) then
		GameTooltip_AddNormalLine(tooltip, BANK_TAB_EXPANSION_ASSIGNMENT:format(BANK_TAB_EXPANSION_FILTER_LEGACY));
	end
	
	local filterList = ContainerFrameUtil_ConvertFilterFlagsToList(depositFlags);
	if filterList then
		local wrapText = true;
		GameTooltip_AddNormalLine(tooltip, BANK_TAB_DEPOSIT_ASSIGNMENTS:format(filterList), wrapText);
	end
end

function BankPanelTabMixin:ShowTooltip()
	if not self.tabData then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.tabData.name, NORMAL_FONT_COLOR);
	AddBankTabSettingsToTooltip(GameTooltip, self.tabData.depositFlags);
	GameTooltip_AddInstructionLine(GameTooltip, BANK_TAB_TOOLTIP_CLICK_INSTRUCTION);
	GameTooltip:Show();
end

function BankPanelTabMixin:OnLeave()
	GameTooltip_Hide();
end

function BankPanelTabMixin:OnNewBankTabSelected(tabID)
	self:RefreshVisuals();
end

function BankPanelTabMixin:RefreshVisuals()
	local enabled = self:IsEnabled();
	self.Icon:SetDesaturated(not enabled);
	self.SelectedTexture:SetShown(enabled and self:IsSelected());
	self:RefreshSearchOverlay();
end

function BankPanelTabMixin:RefreshSearchOverlay()
	self.SearchOverlay:SetShown(self.tabData.ID and not self:IsPurchaseTab() and C_Container.IsContainerFiltered(self.tabData.ID));
end

function BankPanelTabMixin:Init(tabData)
	if not tabData then
		return;
	end

	self.tabData = tabData;
	if self:IsPurchaseTab() then
		self.Icon:SetAtlas("Garr_Building-AddFollowerPlus", TextureKitConstants.UseAtlasSize);
	else
		self.Icon:SetTexture(self.tabData.icon or QUESTION_MARK_ICON);
	end

	self:RefreshVisuals();
end

function BankPanelTabMixin:IsSelected()
	return self.tabData.ID == self:GetBankPanel():GetSelectedTabID();
end

function BankPanelTabMixin:SetEnabledState(enable)
	self:SetEnabled(enable);
	self:RefreshVisuals();
end

function BankPanelTabMixin:IsPurchaseTab()
	return self.tabData.ID == PURCHASE_TAB_ID;
end

BankPanelItemButtonMixin = {};

function BankPanelItemButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function BankPanelItemButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetBagItem(self:GetBankTabID(), self:GetContainerSlotID());

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	end

	self:SetScript("OnUpdate", BankPanelItemButtonMixin.OnUpdate);
end

function BankPanelItemButtonMixin:OnLeave()
	GameTooltip_Hide();
	ResetCursor();

	self:SetScript("OnUpdate", nil);
end


function BankUtil_IsAccountBankDepositRefundable(itemLocation)
	if not itemLocation or not itemLocation:IsValid() then
		return false;
	end

	return (BankFrame:GetActiveBankType() == Enum.BankType.Account) and C_Item.CanBeRefunded(itemLocation);
end

function BankPanelItemButtonMixin:HandleItemPickup()
	local cursorItemLocation = C_Cursor.GetCursorItem();
	if cursorItemLocation and BankUtil_IsAccountBankDepositRefundable(cursorItemLocation) then
		StaticPopup_Show("ACCOUNT_BANK_DEPOSIT_NO_REFUND_CONFIRM", nil, nil, { itemToDeposit = Item:CreateFromItemGUID(C_Item.GetItemGUID(cursorItemLocation)), targetItemLocation = self.itemLocation });
	else
		C_Container.PickupContainerItem(self:GetBankTabID(), self:GetContainerSlotID());
	end
end

function BankPanelItemButtonMixin:OnClick(button)
	if IsModifiedClick() then
		self:OnModifiedClick(button);
		return;
	end

	if ( button == "LeftButton" ) then
		self:HandleItemPickup();
	else
		C_Container.UseContainerItem(self:GetBankTabID(), self:GetContainerSlotID());
	end
end

function BankPanelItemButtonMixin:OnModifiedClick()
	local bankTabID, containerSlotID = self:GetBankTabID(), self:GetContainerSlotID();
	if HandleModifiedItemClick(C_Container.GetContainerItemLink(bankTabID, containerSlotID), self:GetItemLocation()) then
		return;
	end

	if not CursorHasItem() and IsModifiedClick("SPLITSTACK") then
		local info = C_Container.GetContainerItemInfo(bankTabID, containerSlotID);
		if info and not info.isLocked and info.stackCount > 1 then
			StackSplitFrame:OpenStackSplitFrame(self.count, self, "BOTTOMLEFT", "TOPLEFT");
		end
	end
end

function BankPanelItemButtonMixin:OnDragStart()
	C_Container.PickupContainerItem(self:GetBankTabID(), self:GetContainerSlotID());
end

function BankPanelItemButtonMixin:OnReceiveDrag()
	self:HandleItemPickup();
end

function BankPanelItemButtonMixin:OnUpdate()
	if GameTooltip:IsOwned(self) then
		if IsModifiedClick("DRESSUP") then
			ShowInspectCursor();
		else
			ResetCursor();
		end
	end
end

function BankPanelItemButtonMixin:SetBankTabID(bankTabID)
	self.bankTabID = bankTabID;
end

function BankPanelItemButtonMixin:GetBankTabID()
	return self.bankTabID;
end

function BankPanelItemButtonMixin:SetBankType(bankType)
	self.bankType = bankType;
end

function BankPanelItemButtonMixin:GetBankType()
	return self.bankType;
end 

function BankPanelItemButtonMixin:Init(bankType, bankTabID, containerSlotID)
	self:SetBankType(bankType);
	self:UpdateVisualsForBankType();
	self:SetBankTabID(bankTabID);
	self:SetContainerSlotID(containerSlotID);
	self:InitItemLocation();
	self.isInitialized = true;

	self:Refresh();
end

function BankPanelItemButtonMixin:SetContainerSlotID(containerSlotID)
	self.containerSlotID = containerSlotID;
end

function BankPanelItemButtonMixin:GetContainerSlotID()
	return self.containerSlotID;
end

function BankPanelItemButtonMixin:InitItemLocation()
	self.itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetBankTabID(), self:GetContainerSlotID());
end

function BankPanelItemButtonMixin:GetItemLocation()
	return self.itemLocation;
end

function BankPanelItemButtonMixin:GetItemContextMatchResult()
	if not self.isInitialized then
		return ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
	end

	return ItemButtonUtil.GetItemContextMatchResultForItem(self:GetItemLocation());
end

function BankPanelItemButtonMixin:Refresh()
	self:RefreshItemInfo();
	self:RefreshQuestItemInfo();

	local questItemInfo = self.questItemInfo;
	local isQuestItem = questItemInfo.isQuestItem;
	local questID = questItemInfo.questID;
	local isActive = questItemInfo.isActive;
	if questID and not isActive then
		self.IconQuestTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
	elseif questID or isQuestItem then
		self.IconQuestTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
	end
	self.IconQuestTexture:SetShown(questID or isQuestItem);

	local itemInfo = self.itemInfo;
	if itemInfo then
		self.icon:SetTexture(itemInfo.iconFileID);
	end
	self.icon:SetShown(itemInfo ~= nil);
	SetItemButtonCount(self, itemInfo and itemInfo.stackCount or 0);

	self:UpdateItemContextMatching();
	local isFiltered = itemInfo and itemInfo.isFiltered;
	self:SetMatchesSearch(not isFiltered);

	local quality = itemInfo and itemInfo.quality;
	local itemID = itemInfo and itemInfo.itemID;
	local isBound = itemInfo and itemInfo.isBound;
	local suppressOverlays = false;
	SetItemButtonQuality(self, quality, itemID, suppressOverlays, isBound);

	self:UpdateLocked();
	self:UpdateCooldown();
end

function BankPanelItemButtonMixin:RefreshItemInfo()
	self.itemInfo = C_Container.GetContainerItemInfo(self:GetBankTabID(), self:GetContainerSlotID());
end

function BankPanelItemButtonMixin:RefreshQuestItemInfo()
	self.questItemInfo = C_Container.GetContainerItemQuestInfo(self:GetBankTabID(), self:GetContainerSlotID());
end

function BankPanelItemButtonMixin:UpdateCooldown()
	local start, duration, enable = C_Container.GetContainerItemCooldown(self:GetBankTabID(), self:GetContainerSlotID());
	CooldownFrame_Set(self.Cooldown, start, duration, enable);
	if ( duration and duration > 0 and enable == 0 ) then
		local r, g, b = 0.4, 0.4, 0.4;
		SetItemButtonTextureVertexColor(self, r, g, b);
	end
end

function BankPanelItemButtonMixin:UpdateLocked()
	SetItemButtonDesaturated(self, self.itemInfo and self.itemInfo.isLocked);
end

function BankPanelItemButtonMixin:UpdateVisualsForBankType()
	self:UpdateBackgroundForBankType();
end

function BankPanelItemButtonMixin:UpdateBackgroundForBankType()
	self.Background:ClearAllPoints();
	if self.bankType == Enum.BankType.Account then
		self.Background:SetPoint("TOPLEFT", -6, 5);
		self.Background:SetPoint("BOTTOMRIGHT", 6, -7);
		self.Background:SetAtlas("warband-bank-slot", TextureKitConstants.IgnoreAtlasSize);
	else
		self.Background:SetPoint("TOPLEFT");
		self.Background:SetPoint("BOTTOMRIGHT");
		self.Background:SetAtlas("bags-item-slot64", TextureKitConstants.IgnoreAtlasSize);
	end
end

function BankPanelItemButtonMixin:SplitStack(amount)
	C_Container.SplitContainerItem(self:GetBankTabID(), self:GetContainerSlotID(), amount);
end

BankPanelMixin = CreateFromMixins(CallbackRegistryMixin);

local BankPanelEvents = {
	"ACCOUNT_MONEY",
	"BANK_TABS_CHANGED",
	"BAG_UPDATE",
	"BANK_TAB_SETTINGS_UPDATED",
	"INVENTORY_SEARCH_UPDATE",
	"ITEM_LOCK_CHANGED",
	"PLAYER_MONEY",
};

BankPanelMixin:GenerateCallbackEvents(
{
	"BankTabClicked",
	"NewBankTabSelected",
});

function BankPanelMixin:GetBankContainerFrame()
	return BankFrame;
end

function BankPanelMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:AddDynamicEventMethod(self, BankPanelMixin.Event.BankTabClicked, self.OnBankTabClicked);
	self:AddDynamicEventMethod(self, BankPanelMixin.Event.NewBankTabSelected, self.OnNewBankTabSelected);

	self.bankTabPool = CreateFramePool("BUTTON", self, "BankPanelTabTemplate");

	local function BankItemButtonResetter(itemButtonPool, itemButton)
		itemButton.isInitialized = false;
		Pool_HideAndClearAnchors(itemButtonPool, itemButton);
	end
	self.itemButtonPool = CreateFramePool("ItemButton", self, "BankItemButtonTemplate", BankItemButtonResetter);

	self.selectedTabID = nil;
end

function BankPanelMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	FrameUtil.RegisterFrameForEvents(self, BankPanelEvents);

	self:Reset();
end

function BankPanelMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, BankPanelEvents);

	self.TabSettingsMenu:Hide();
	self.selectedTabID = nil;

	self:CloseAllBankPopups();
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function BankPanelMixin:MarkDirty()
	self.isDirty = true;
	self:SetScript("OnUpdate", self.OnUpdate);
end

function BankPanelMixin:Clean()
	if not self.isDirty then
		return;
	end
	
	local hasItemSlots = self.itemButtonPool:GetNumActive() > 0;
	if hasItemSlots then
		self:RefreshAllItemsForSelectedTab();
	else
		-- Newly purchased bank tabs may need to have item slots generated
		self:GenerateItemSlotsForSelectedTab();
	end

	self.isDirty = false;
	self:SetScript("OnUpdate", nil);
end

function BankPanelMixin:OnUpdate()
	self:Clean();
end

function BankPanelMixin:CloseAllBankPopups()
	StaticPopup_Hide("ACCOUNT_BANK_DEPOSIT_ALL_NO_REFUND_CONFIRM");
	StaticPopup_Hide("ACCOUNT_BANK_DEPOSIT_NO_REFUND_CONFIRM");
	StaticPopup_Hide("BANK_MONEY_DEPOSIT");
	StaticPopup_Hide("BANK_MONEY_WITHDRAW");
	StaticPopup_Hide("CONFIRM_BUY_BANK_TAB");
	StaticPopupSpecial_Hide(BankCleanUpConfirmationPopup);
end

function BankPanelMixin:HideAllPrompts()
	for index, prompt in ipairs(self.Prompts) do
		prompt:Hide();
	end
end

function BankPanelMixin:SetItemDisplayEnabled(enable)
	if not enable then
		self.itemButtonPool:ReleaseAll();
	end

	local autoDepositSupported = C_Bank.DoesBankTypeSupportAutoDeposit(self.bankType);
	self.AutoDepositFrame:SetEnabled(enable and autoDepositSupported);
	self.AutoDepositFrame:SetShown(enable and autoDepositSupported);
end

function BankPanelMixin:SetMoneyFrameEnabled(enable)
	self.MoneyFrame:SetEnabled(enable);
end

function BankPanelMixin:OnEvent(event, ...)
	if event == "BANK_TABS_CHANGED"	then
		local bankType = ...;
		if bankType == self.bankType then
			self:Reset();
		end
	elseif event == "BANK_TAB_SETTINGS_UPDATED" then
		local bankType = ...;
		if bankType == self.bankType then
			self.TabSettingsMenu:Hide();
			self:FetchPurchasedBankTabData();
			self:RefreshBankTabs();
			self:RefreshHeaderText();
		end
	elseif event == "BAG_UPDATE" then
		local containerID = ...;
		if self.selectedTabID == containerID then
			self:MarkDirty();
		end
	elseif event == "INVENTORY_SEARCH_UPDATE" then
		self:UpdateSearchResults();
	elseif event == "ITEM_LOCK_CHANGED" then
		local bankTabID, containerSlotID = ...;
		local itemInSelectedTab = bankTabID == self:GetSelectedTabID();
		if not itemInSelectedTab then
			return;
		end

		local itemButton = self:FindItemButtonByContainerSlotID(containerSlotID);
		if itemButton then
			itemButton:Refresh();
		end
	elseif event == "ACCOUNT_MONEY" then
		if self.bankType == Enum.BankType.Account then
			self.MoneyFrame:Refresh();
		end
	elseif event == "PLAYER_MONEY" then
		if self.bankType == Enum.BankType.Character then
			self.MoneyFrame:Refresh();
		end
	end
end

function BankPanelMixin:OnBankTabClicked(clickedTabID)
	self:SelectTab(clickedTabID);
end

function BankPanelMixin:OnNewBankTabSelected(tabID)
	self:RefreshBankPanel();
end

function BankPanelMixin:GetSelectedTabID()
	return self.selectedTabID;
end

function BankPanelMixin:GetTabData(tabID)
	if not self.purchasedBankTabData then
		return;
	end

	for index, tabData in ipairs(self.purchasedBankTabData) do
		if tabData.ID == tabID then
			return tabData;
		end
	end
end

function BankPanelMixin:GetSelectedTabData()
	return self:GetTabData(self.selectedTabID);
end

function BankPanelMixin:InitializePurchaseTab()
	local purchaseTabData =
	{
		ID = PURCHASE_TAB_ID,
		bankType = self.bankType,
	};
	self.PurchaseTab:Init(purchaseTabData);
end

function BankPanelMixin:SetBankType(bankType)
	self.bankType = bankType;
	self:InitializePurchaseTab();
	if self:IsShown() then
		self:CloseAllBankPopups();
		self:Reset();
	end
end

function BankPanelMixin:GetActiveBankType()
	return self.bankType;
end

function BankPanelMixin:IsBankTypeLocked()
	return C_Bank.FetchBankLockedReason(self.bankType) ~= nil;
end

function BankPanelMixin:SelectTab(tabID)
	local alreadySelected = self.selectedTabID == tabID;
	if not alreadySelected then
		self.selectedTabID = tabID;
		self:TriggerEvent(BankPanelMixin.Event.NewBankTabSelected, tabID);
	end
end

function BankPanelMixin:RefreshBankPanel()
	self:HideAllPrompts();
	if self:ShouldShowLockPrompt() then
		self:ShowLockPrompt();
		return;
	end

	if self:ShouldShowPurchasePrompt() then
		self:ShowPurchasePrompt();
		return;
	end

	local noTabSelected = self.selectedTabID == nil;
	if noTabSelected then
		return;
	end
		
	self:SetHeaderEnabled(true);
	self:SetItemDisplayEnabled(true);
	self:SetMoneyFrameEnabled(true);
	self:GenerateItemSlotsForSelectedTab();
end

function BankPanelMixin:SetHeaderEnabled(enabled)
	self.Header:SetShown(enabled);

	if enabled then
		self:RefreshHeaderText();
	end
end

function BankPanelMixin:RefreshHeaderText()
	local selectedBankTabData = self:GetTabData(self.selectedTabID);
	self.Header.Text:SetText(selectedBankTabData and selectedBankTabData.name or "");
end

function BankPanelMixin:ShouldShowLockPrompt()
	return self:IsBankTypeLocked();
end

function BankPanelMixin:ShowLockPrompt()
	self.TabSettingsMenu:Hide();
	self:SetHeaderEnabled(false);
	self:SetItemDisplayEnabled(false);
	self:SetMoneyFrameEnabled(false);
	self.LockPrompt:Show();
end

function BankPanelMixin:ShouldShowPurchasePrompt()
	return self.PurchaseTab:IsSelected() and C_Bank.CanPurchaseBankTab(self.bankType);
end

function BankPanelMixin:ShowPurchasePrompt()
	self.TabSettingsMenu:Hide();
	self:SetHeaderEnabled(false);
	self:SetItemDisplayEnabled(false);
	self:SetMoneyFrameEnabled(false);
	self.PurchasePrompt:Show();
end

function BankPanelMixin:Reset()
	self:FetchPurchasedBankTabData();
	self:SelectFirstAvailableTab();
	self:RefreshBankTabs();
	self:RefreshBankPanel();
	self:RequestTitleRefresh();
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function BankPanelMixin:RequestTitleRefresh()
	local bestTitleForBankType = (self:GetActiveBankType() == Enum.BankType.Account) and ACCOUNT_BANK_PANEL_TITLE or BANK;
	self:GetBankContainerFrame():TriggerEvent(BankFrameMixin.Event.TitleUpdateRequested, bestTitleForBankType);
end

function BankPanelMixin:SelectFirstAvailableTab()
	local hasPurchasedTabs = self.purchasedBankTabData and #self.purchasedBankTabData > 0;
	if hasPurchasedTabs then
		self:SelectTab(self.purchasedBankTabData[1].ID);
	elseif C_Bank.CanPurchaseBankTab(self.bankType) then
		self:SelectTab(PURCHASE_TAB_ID);
	end
end

function BankPanelMixin:FetchPurchasedBankTabData()
	self.purchasedBankTabData = C_Bank.FetchPurchasedBankTabData(self.bankType);
end

function BankPanelMixin:RefreshBankTabs()
	self.bankTabPool:ReleaseAll();

	-- List purchased tabs first...
	local lastBankTab;
	if self.purchasedBankTabData then
		for index, bankTabData in ipairs(self.purchasedBankTabData) do
			local newBankTab = self.bankTabPool:Acquire();

			if lastBankTab == nil then
				newBankTab:SetPoint("TOPLEFT", self, "TOPRIGHT", 2, -25);
			else
				newBankTab:SetPoint("TOPLEFT", lastBankTab, "BOTTOMLEFT", 0, -17);
			end
			
			newBankTab:Init(bankTabData);
			newBankTab:Show();
			lastBankTab = newBankTab;
		end
	end

	-- ...followed by the button to purchase a new tab (if applicable)
	local showPurchaseTab = not self:IsBankTypeLocked() and not C_Bank.HasMaxBankTabs(self.bankType);
	if showPurchaseTab then
		if lastBankTab == nil then
			self.PurchaseTab:SetPoint("TOPLEFT", self, "TOPRIGHT", 2, -25);
		else
			self.PurchaseTab:SetPoint("TOPLEFT", lastBankTab, "BOTTOMLEFT", 0, -17);
		end

		self.PurchaseTab:SetEnabledState(C_Bank.CanPurchaseBankTab(self.bankType));
		self.PurchaseTab:Show();
	else
		self.PurchaseTab:Hide();
	end
end

function BankPanelMixin:GenerateItemSlotsForSelectedTab()
	self.itemButtonPool:ReleaseAll();

	if not self.selectedTabID or self.selectedTabID == PURCHASE_TAB_ID then
		return;
	end

	local numRows = 7;
	local numSubColumns = 2;
	local lastColumnStarterButton;
	local lastCreatedButton;
	local currentColumn = 1;
	for containerSlotID = 1, C_Container.GetContainerNumSlots(self.selectedTabID) do
		local button = self.itemButtonPool:Acquire();
			
		local isFirstButton = containerSlotID == 1;
		local needNewColumn = (containerSlotID % numRows) == 1;
		if isFirstButton then
			local xOffset, yOffset = 26, -63;
			button:SetPoint("TOPLEFT", self, "TOPLEFT", currentColumn * xOffset, yOffset);
			lastColumnStarterButton = button;
		elseif needNewColumn then
			currentColumn = currentColumn + 1;

			local xOffset, yOffset = 8, 0;
			-- We reached the last subcolumn, time to add space for a new "big" column
			local startNewBigColumn = (currentColumn % numSubColumns == 1);
			if startNewBigColumn then
				xOffset = 19;
			end
			button:SetPoint("TOPLEFT", lastColumnStarterButton, "TOPRIGHT", xOffset, yOffset);
			lastColumnStarterButton = button;
		else
			local xOffset, yOffset = 0, -10;
			button:SetPoint("TOPLEFT", lastCreatedButton, "BOTTOMLEFT", xOffset, yOffset);
		end
		
		button:Init(self.bankType, self.selectedTabID, containerSlotID);
		button:Show();

		lastCreatedButton = button;
	end
end

function BankPanelMixin:RefreshAllItemsForSelectedTab()
	for itemButton in self:EnumerateValidItems() do
		itemButton:Refresh();
	end
end

function BankPanelMixin:UpdateSearchResults()
	for itemButton in self:EnumerateValidItems() do
		local itemInfo = C_Container.GetContainerItemInfo(itemButton:GetBankTabID(), itemButton:GetContainerSlotID());
		local isFiltered = itemInfo and itemInfo.isFiltered;
		itemButton:SetMatchesSearch(not isFiltered);
	end
end

function BankPanelMixin:EnumerateValidItems()
	return self.itemButtonPool:EnumerateActive();
end

function BankPanelMixin:FindItemButtonByContainerSlotID(containerSlotID)
	for itemButton in self:EnumerateValidItems() do
		if itemButton:GetContainerSlotID() == containerSlotID then
			return itemButton;
		end
	end
end

BankPanelPromptMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelPromptMixin:OnLoad()
	RaiseFrameLevel(self);
end

function BankPanelPromptMixin:OnShow()
	if self.Refresh then
		self:Refresh();
	end
end

function BankPanelPromptMixin:SetTitle(title)
	self.Title:SetText(title);
end

function BankPanelPromptMixin:SetPromptText(promptText)
	self.PromptText:SetText(promptText);
end

function BankPanelPromptMixin:SetPromptWidth(width)
	self.PromptText:SetWidth(width);
end

local BANK_LOCKED_MESSAGE = {
	[Enum.BankLockedReason.BankConversionFailed] = BANK_LOCKED_REASON_BANK_CONVERSION_FAILED,
	[Enum.BankLockedReason.BankDisabled] = BANK_LOCKED_REASON_BANK_DISABLED,
	[Enum.BankLockedReason.NoAccountInventoryLock] = BANK_LOCKED_REASON_NO_ACCOUNT_INVENTORY_LOCK,
};

BankPanelLockPromptMixin = CreateFromMixins(BankPanelPromptMixin);

function BankPanelLockPromptMixin:OnLoad()
	BankPanelPromptMixin.OnLoad(self);

	self:SetPromptWidth(650);
	self:SetPromptText("");
end

function BankPanelLockPromptMixin:Refresh()
	self:SetPromptText(self:GetBankLockedMessage());
end

function BankPanelLockPromptMixin:GetBankLockedMessage()
	return BANK_LOCKED_MESSAGE[C_Bank.FetchBankLockedReason(self:GetActiveBankType())] or "";
end

BankPanelPurchasePromptMixin = CreateFromMixins(BankPanelPromptMixin);

local BankPurchasePromptEvents = {
	"PLAYER_MONEY",
};

function BankPanelPurchasePromptMixin:OnLoad()
	BankPanelPromptMixin.OnLoad(self);

	self:SetPromptWidth(450);
end

function BankPanelPurchasePromptMixin:OnShow()
	BankPanelPromptMixin.OnShow(self);
	FrameUtil.RegisterFrameForEvents(self, BankPurchasePromptEvents);
end

function BankPanelPurchasePromptMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, BankPurchasePromptEvents);
end

function BankPanelPurchasePromptMixin:OnEvent(event, ...)
	if event == "PLAYER_MONEY" then
		self:Refresh();
	end
end

function BankPanelPurchasePromptMixin:Refresh()
	local bankType = self:GetActiveBankType();
	local tabData = bankType and C_Bank.FetchNextPurchasableBankTabData(bankType) or nil;
	if tabData then
		self:SetTitle(tabData.purchasePromptTitle);
		self:SetPromptText(tabData.purchasePromptBody);
		MoneyFrame_Update(self.TabCostFrame.MoneyDisplay, tabData.tabCost);
		SetMoneyFrameColorByFrame(self.TabCostFrame.MoneyDisplay, tabData.canAfford and "white" or "red");
	end
end

BankPanelAutoDepositFrameMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelAutoDepositFrameMixin:SetEnabled(enable)
	local needsReagentCheckbox = self:GetActiveBankType() == Enum.BankType.Account;
	self.IncludeReagentsCheckbox:SetEnabledState(enable and needsReagentCheckbox);

	self.DepositButton:SetEnabledState(enable);
end

BankPanelItemDepositButtonMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelItemDepositButtonMixin:GetItemDepositConfirmationPopup()
	if self:GetActiveBankType() == Enum.BankType.Account then
		local depositContainsRefundableItems = ItemUtil.IteratePlayerInventory(function(itemLocation)
			return C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation) and C_Item.CanBeRefunded(itemLocation);
		end);
		if depositContainsRefundableItems then
			return "ACCOUNT_BANK_DEPOSIT_ALL_NO_REFUND_CONFIRM";
		end
	end
end

function BankPanelItemDepositButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
	self:AutoDepositItems();
end

function BankPanelItemDepositButtonMixin:AutoDepositItems()
	local itemDepositConfirmationPopup = self:GetItemDepositConfirmationPopup();
	if itemDepositConfirmationPopup then
		local textArg1, textArg2 = nil, nil;
		StaticPopup_Show(itemDepositConfirmationPopup, textArg1, textArg2, { bankType = self:GetActiveBankType() });
	else
		C_Bank.AutoDepositItemsIntoBank(self:GetActiveBankType());
	end
end

function BankPanelItemDepositButtonMixin:SetEnabledState(enable)
	self:SetEnabled(enable);
	self:Refresh();
end

function BankPanelItemDepositButtonMixin:Refresh()
	self:UpdateTextForBankType();
end

function BankPanelItemDepositButtonMixin:GetBestTextForBankType()
	return self:GetActiveBankType() == Enum.BankType.Account and ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL or CHARACTER_BANK_DEPOSIT_BUTTON_LABEL;
end

function BankPanelItemDepositButtonMixin:UpdateTextForBankType()
	self:SetText(self:GetBestTextForBankType());
end

BankPanelTabCostMoneyDisplayMixin = {};

function BankPanelTabCostMoneyDisplayMixin:OnLoad()
	SmallMoneyFrame_OnLoad(self);
	MoneyFrame_SetType(self, "STATIC");
end

BankPanelPurchaseTabButtonMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelPurchaseTabButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
	local textArg1, textArg2 = nil, nil;
	StaticPopup_Show("CONFIRM_BUY_BANK_TAB", textArg1, textArg2, { bankType = self:GetActiveBankType() });
end

BankPanelMoneyFrameMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelMoneyFrameMixin:OnShow()
	self:Refresh();
end

function BankPanelMoneyFrameMixin:SetEnabled(enable)
	self:SetShown(enable);
	self:Refresh();
end

function BankPanelMoneyFrameMixin:Refresh()
	if not self:IsShown() then
		return;
	end

	self:RefreshContents();
	self:UpdateMoneyDisplayAnchoring();
end

function BankPanelMoneyFrameMixin:RefreshContents()
	self.WithdrawButton:Refresh();
	self.DepositButton:Refresh();
	self.MoneyDisplay:Refresh();
end

function BankPanelMoneyFrameMixin:UpdateMoneyDisplayAnchoring()
	local moneyTransferButtonsVisible = self.WithdrawButton:IsShown() and self.DepositButton:IsShown();
	self:SetWidth(moneyTransferButtonsVisible and 394 or 180);
end

BankPanelMoneyFrameMoneyDisplayMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelMoneyFrameMoneyDisplayMixin:OnLoad()
	SmallMoneyFrame_OnLoad(self);

	-- We don't want the money popup functionality in the bank panel
	self:DisableMoneyPopupFunctionality();
end

function BankPanelMoneyFrameMoneyDisplayMixin:DisableMoneyPopupFunctionality()
	self.CopperButton:SetScript("OnClick", nop);
	self.SilverButton:SetScript("OnClick", nop);
	self.GoldButton:SetScript("OnClick", nop);
end

function BankPanelMoneyFrameMoneyDisplayMixin:GetBestMoneyType()
	local isAccountBank = self:GetActiveBankType() == Enum.BankType.Account;
	return isAccountBank and "ACCOUNT" or "PLAYER";
end

function BankPanelMoneyFrameMoneyDisplayMixin:Refresh()
	MoneyFrame_SetType(self, self:GetBestMoneyType());
	MoneyFrame_UpdateMoney(self);
end

BankPanelWithdrawMoneyButtonMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelWithdrawMoneyButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);

	StaticPopup_Hide("BANK_MONEY_DEPOSIT");

	local alreadyShown = StaticPopup_Visible("BANK_MONEY_WITHDRAW");
	if alreadyShown then
		StaticPopup_Hide("BANK_MONEY_WITHDRAW");
		return;
	end

	local textArg1, textArg2 = nil, nil;
	StaticPopup_Show("BANK_MONEY_WITHDRAW", textArg1, textArg2, { bankType = self:GetActiveBankType() });
end

function BankPanelWithdrawMoneyButtonMixin:Refresh()
	local bankType = self:GetActiveBankType();
	self.disabledTooltip = self:IsActiveBankTypeLocked() and ACCOUNT_BANK_ERROR_NO_LOCK or nil;

	local moneyTransferSupported = bankType and C_Bank.DoesBankTypeSupportMoneyTransfer(bankType);
	self:SetShown(moneyTransferSupported);

	local canWithdrawMoney = moneyTransferSupported and C_Bank.CanWithdrawMoney(bankType);
	self:SetEnabled(canWithdrawMoney);
end

BankPanelDepositMoneyButtonMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelDepositMoneyButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);

	StaticPopup_Hide("BANK_MONEY_WITHDRAW");

	local alreadyShown = StaticPopup_Visible("BANK_MONEY_DEPOSIT");
	if alreadyShown then
		StaticPopup_Hide("BANK_MONEY_DEPOSIT");
		return;
	end

	local textArg1, textArg2 = nil, nil;
	StaticPopup_Show("BANK_MONEY_DEPOSIT", textArg1, textArg2, { bankType = self:GetActiveBankType() });
end

function BankPanelDepositMoneyButtonMixin:Refresh()
	local bankType = self:GetActiveBankType();
	self.disabledTooltip = self:IsActiveBankTypeLocked() and ACCOUNT_BANK_ERROR_NO_LOCK or nil;

	local moneyTransferSupported = bankType and C_Bank.DoesBankTypeSupportMoneyTransfer(bankType);
	self:SetShown(moneyTransferSupported);

	local canDepositMoney = moneyTransferSupported and C_Bank.CanDepositMoney(bankType);
	self:SetEnabled(canDepositMoney);
end

BankPanelTabSettingsMenuMixin = CreateFromMixins(CallbackRegistryMixin, BankPanelSystemMixin);

BankPanelTabSettingsMenuMixin:GenerateCallbackEvents(
{
	"OpenTabSettingsRequested",
});

function BankPanelTabSettingsMenuMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	IconSelectorPopupFrameTemplateMixin.OnLoad(self);

	self:AddStaticEventMethod(self, BankPanelTabSettingsMenuMixin.Event.OpenTabSettingsRequested, self.OnOpenTabSettingsRequested);
	self:AddDynamicEventMethod(self:GetBankPanel(), BankPanelMixin.Event.NewBankTabSelected, self.OnNewBankTabSelected);

	local function OnIconSelected(selectionIndex, icon)
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon);

		-- Index is not yet set, but we know if an icon in IconSelector was selected it was in the list, so set directly.
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_CLICK);
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetFontObject(GameFontHighlightSmall);
	end
    self.IconSelector:SetSelectedCallback(OnIconSelected);

	self:OverrideInheritedAnchoring();

	self.selectedTabData = nil;
end

function BankPanelTabSettingsMenuMixin:OnOpenTabSettingsRequested(tabID)
	local shown = self:IsShown();
	if not shown then
		self:SetSelectedTab(tabID);
		self:Show();
		return;
	end

	local alreadyEditingTab = shown and self:GetSelectedTabID() == tabID;
	if alreadyEditingTab then
		self:Hide();
	end
end

function BankPanelTabSettingsMenuMixin:OnNewBankTabSelected(tabID)
	if not self:IsShown() or tabID == PURCHASE_TAB_ID then
		return;
	end
	
	self:SetSelectedTab(tabID);
end

function BankPanelTabSettingsMenuMixin:OverrideInheritedAnchoring()
	-- We inherit from IconSelectorPopupFrameTemplate (used by the Macro UI, Guild Bank UI, etc.)
	-- However, we need to make more room for the bank tab "Sort Settings"
	-- Let's update the template layout to make sure everything fits
	NineSliceUtil.ApplyLayoutByName(self.BorderBox, "BankTabSettingsMenuLayout");

	self:SetHeight(594);
	self.IconSelector:ClearAllPoints();
	self.IconSelector:SetPoint("TOPLEFT", self.BorderBox, "TOPLEFT", 21, -196);

	self.BorderBox.IconSelectionText:ClearAllPoints();
	self.BorderBox.IconSelectionText:SetPoint("BOTTOMLEFT", self.IconSelector, "TOPLEFT", 0, 10);

	self.BorderBox.IconTypeDropdown:ClearAllPoints();
	self.BorderBox.IconTypeDropdown:SetPoint("BOTTOMRIGHT", self.IconSelector, "TOPRIGHT", -33, 0);
end

function BankPanelTabSettingsMenuMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	IconSelectorPopupFrameTemplateMixin.OnShow(self);

	self.iconDataProvider = self:RefreshIconDataProvider();

	self:Update();

	self:SetIconFilter(IconSelectorPopupFrameIconFilterTypes.All);

	self.BorderBox.IconSelectorEditBox:SetFocus();
	self.BorderBox.IconSelectorEditBox:OnTextChanged();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function BankPanelTabSettingsMenuMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	IconSelectorPopupFrameTemplateMixin.OnHide(self);

	if self.iconDataProvider ~= nil then
		self.iconDataProvider:Release();
		self.iconDataProvider = nil;
	end

	self.selectedTabData = nil;

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function BankPanelTabSettingsMenuMixin:RefreshIconDataProvider()
	if self.iconDataProvider == nil then
		self.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.None);
	end

	return self.iconDataProvider;
end

function BankPanelTabSettingsMenuMixin:Update()
	if not self.selectedTabData then
		return;
	end

	self.BorderBox.EditBoxHeaderText:SetText(self.selectedTabData.tabNameEditBoxHeader);
	self.BorderBox.IconSelectorEditBox:SetText(self.selectedTabData.name);
	self.BorderBox.IconSelectorEditBox:HighlightText();

	local defaultIconSelected = self.selectedTabData.icon == QUESTION_MARK_ICON;
	if defaultIconSelected then
		local initialIndex = 1;
		self.IconSelector:SetSelectedIndex(initialIndex);
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self:GetIconByIndex(initialIndex));
	else
		self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(self.selectedTabData.icon));
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self.selectedTabData.icon);
	end

	local getSelection = GenerateClosure(self.iconDataProvider.GetIconByIndex, self.iconDataProvider);
	local getNumSelections = GenerateClosure(self.iconDataProvider.GetNumIcons, self.iconDataProvider);
	self.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections);
	self.IconSelector:ScrollToSelectedIndex();

	self:SetSelectedIconText();

	self:InitDepositSettingCheckboxes();
	self.DepositSettingsMenu.ExpansionFilterDropdown:Refresh();
end

function BankPanelTabSettingsMenuMixin:SetSelectedTab(selectedTabID)
	local alreadySelected = self:GetSelectedTabID() == selectedTabID;
	if alreadySelected then
		return;
	end

	self.selectedTabData = self:GetBankPanel():GetTabData(selectedTabID);

	if self:IsShown() then
		self:Update();
	end
end

function BankPanelTabSettingsMenuMixin:GetSelectedTabID()
	return self.selectedTabData and self.selectedTabData.ID;
end

function BankPanelTabSettingsMenuMixin:CancelButton_OnClick()
	IconSelectorPopupFrameTemplateMixin.CancelButton_OnClick(self);

	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function BankPanelTabSettingsMenuMixin:OkayButton_OnClick()
	self:UpdateBankTabSettings();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);

	IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick(self);
end

function BankPanelTabSettingsMenuMixin:UpdateBankTabSettings()
	local tabData = self:GetSelectedTabData();
	if not tabData then
		return;
	end

	local bankType = tabData.bankType;
	local tabID = tabData.ID;
	local tabIcon = self:GetNewTabIcon();
	local tabName = self:GetNewTabName();
	local depositFlags = self:GetNewTabDepositFlags();
	C_Bank.UpdateBankTabSettings(bankType, tabID, tabName, tabIcon, depositFlags);
end

function BankPanelTabSettingsMenuMixin:GetNewTabName()
	return self.BorderBox.IconSelectorEditBox:GetText() or "";
end

function BankPanelTabSettingsMenuMixin:GetNewTabIcon()
	return self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture() or QUESTION_MARK_ICON;
end

function BankPanelTabSettingsMenuMixin:GetNewTabDepositFlags()
	local depositFlags = 0;
	for index, checkBox in ipairs(self.DepositSettingsMenu.DepositSettingsCheckboxes) do
		local isValidSetting = checkBox.settingFlag ~= nil;
		if isValidSetting then
			local setDepositFlag = checkBox:GetChecked();
			depositFlags = FlagsUtil.Combine(depositFlags, checkBox.settingFlag, setDepositFlag);
		end
	end

	local expansionFlags = self.DepositSettingsMenu.ExpansionFilterDropdown:GetFilterValue();
	if expansionFlags then
		local setFlag = true;
		depositFlags = FlagsUtil.Combine(depositFlags, expansionFlags, setFlag);
	end

	return depositFlags;
end

function BankPanelTabSettingsMenuMixin:InitDepositSettingCheckboxes()
	local tabData = self:GetSelectedTabData();
	if not tabData then
		return;
	end

	local depositFlags = tabData.depositFlags;
	for index, checkBox in ipairs(self.DepositSettingsMenu.DepositSettingsCheckboxes) do
		local isValidSetting = checkBox.settingFlag ~= nil;
		checkBox:SetEnabled(isValidSetting);
		checkBox:SetChecked(isValidSetting and FlagsUtil.IsSet(depositFlags, checkBox.settingFlag) or false);
	end
end

function BankPanelTabSettingsMenuMixin:GetSelectedTabData()
	return self.selectedTabData;
end

local BankTabExpansionFilterTypes = {
	["All"] = 0,
	["ExpansionCurrent"] = Enum.BagSlotFlags.ExpansionCurrent,
	["ExpansionLegacy"] = Enum.BagSlotFlags.ExpansionLegacy,
};

local BankTabExpansionFilterOrder = {
	BankTabExpansionFilterTypes.All,
	BankTabExpansionFilterTypes.ExpansionCurrent,
	BankTabExpansionFilterTypes.ExpansionLegacy,
};

local BankTabExpansionFilterTypeNames = {
	[BankTabExpansionFilterTypes.All] = BANK_TAB_EXPANSION_FILTER_ALL,
	[BankTabExpansionFilterTypes.ExpansionCurrent] = BANK_TAB_EXPANSION_FILTER_CURRENT,
	[BankTabExpansionFilterTypes.ExpansionLegacy] = BANK_TAB_EXPANSION_FILTER_LEGACY,
};

BankTabDepositSettingsMenuMixin = {};

function BankTabDepositSettingsMenuMixin:OnLoad()
	self.ExpansionFilterDropdown:SetWidth(110);
end

function BankTabDepositSettingsMenuMixin:OnShow()
	self.ExpansionFilterDropdown:Refresh();
end

BankPanelTabSettingsExpansionFilterDropdownMixin = {};

local function GetCurrentFilterType(tabData)
	local filterType = 0;
	for index, filterValue in ipairs(BankTabExpansionFilterOrder) do
		filterType = FlagsUtil.Combine(filterType, filterValue, FlagsUtil.IsSet(tabData.depositFlags, filterValue));
	end
	return filterType;
end

function BankPanelTabSettingsExpansionFilterDropdownMixin:Refresh()
	local tabData = self:GetSelectedTabData();
	if not tabData then
		return;
	end

	self:SetFilterValue(GetCurrentFilterType(tabData));

	local function IsSelected(filterType)
		return self:GetFilterValue() == filterType;
	end

	local function SetSelected(filterType)
		self:SetFilterValue(filterType);
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_BANK_EXPANSION_FILTER");

		for index, filterType in ipairs(BankTabExpansionFilterOrder) do
			rootDescription:CreateRadio(BankTabExpansionFilterTypeNames[filterType], IsSelected, SetSelected, filterType);
		end
	end);
end

function BankPanelTabSettingsExpansionFilterDropdownMixin:GetSelectedTabData()
	local settingsMenu = self:GetParent():GetParent();
	return settingsMenu:GetSelectedTabData();
end

function BankPanelTabSettingsExpansionFilterDropdownMixin:GetFilterValue()
	return self.selectedValue;
end

function BankPanelTabSettingsExpansionFilterDropdownMixin:SetFilterValue(value)
	self.selectedValue = value;
end

BankPanelCheckboxMixin = {};

function BankPanelCheckboxMixin:OnShow()
	self:Init();
end

function BankPanelCheckboxMixin:OnClick()
	local clickSound = self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON;
	PlaySound(clickSound);
end

function BankPanelCheckboxMixin:Init()
	if self.fontObject then
		self.Text:SetFontObject(self.fontObject);
	end

	if self.textWidth then
		self.Text:SetWidth(self.textWidth);
	end

	if self.maxTextLines then
		self.Text:SetMaxLines(self.maxTextLines);
	end

	if self.text then
		self.Text:SetText(self.text);
	end
end

BankPanelIncludeReagentsCheckboxMixin = CreateFromMixins(BankPanelCheckboxMixin);

function BankPanelIncludeReagentsCheckboxMixin:OnShow()
	BankPanelCheckboxMixin.OnShow(self);
	self:SetChecked(GetCVarBool("bankAutoDepositReagents"));
end

function BankPanelIncludeReagentsCheckboxMixin:OnClick()
	BankPanelCheckboxMixin.OnClick(self);
	SetCVar("bankAutoDepositReagents", self:GetChecked());
end

function BankPanelIncludeReagentsCheckboxMixin:SetEnabledState(enable)
	self:SetEnabled(enable);
	self:Refresh();
end

function BankPanelIncludeReagentsCheckboxMixin:Refresh()
	self:SetShown(self:IsEnabled());
end

BankCleanUpConfirmationPopupMixin = CreateFromMixins(BankPanelSystemMixin);

function BankCleanUpConfirmationPopupMixin:OnShow()
	self:RefreshConfirmationText();
	self:Layout();
end

function BankCleanUpConfirmationPopupMixin:OnLoad()
	self.AcceptButton:SetScript("OnClick", function()
		local shouldShowConfirmationPopup = not self.HidePopupCheckbox.Checkbox:GetChecked();
		SetCVar("bankConfirmTabCleanUp", shouldShowConfirmationPopup);

		C_Container.SortBank(self:GetActiveBankType());
		StaticPopupSpecial_Hide(self);
	end);

	self.CancelButton:SetScript("OnClick", function()
		StaticPopupSpecial_Hide(self);
	end);

	self.HidePopupCheckbox.Checkbox:SetScript("OnShow", function(self) 
		BankPanelCheckboxMixin.OnShow(self);

		-- The player may click the checkbox but then re-enable the popup in the same play session, so let's just refresh it in the OnShow
		local shouldShowConfirmationPopup = GetCVarBool("bankConfirmTabCleanUp");
		self:SetChecked(not shouldShowConfirmationPopup);
	end);
end

function BankCleanUpConfirmationPopupMixin:RefreshConfirmationText()
	local selectedTabData = self:GetBankPanel():GetSelectedTabData();
	self.Text:SetText(selectedTabData and selectedTabData.tabCleanupConfirmation or BANK_CONFIRM_CLEANUP_PROMPT);
end

BankAutoSortButtonMixin = CreateFromMixins(BankPanelSystemMixin);

function BankAutoSortButtonMixin:OnEnter()
	self:ShowBestTooltipForBankType();
end

function BankAutoSortButtonMixin:ShowBestTooltipForBankType()
	GameTooltip:SetOwner(self);

	local bestTooltipTextForBankType = (self:GetActiveBankType() == Enum.BankType.Account) and BAG_CLEANUP_ACCOUNT_BANK or BAG_CLEANUP_BANK;
	GameTooltip:SetText(bestTooltipTextForBankType);
	GameTooltip:Show();
end

function BankAutoSortButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function BankAutoSortButtonMixin:OnClick()
	PlaySound(SOUNDKIT.UI_BAG_SORTING_01);
	self:AutoSortBank();
end

function BankAutoSortButtonMixin:AutoSortBank()
	local bankType = self:GetActiveBankType();
	local hasTabsToSort = bankType and C_Bank.FetchNumPurchasedBankTabs(bankType) > 0;
	if not hasTabsToSort then
		return;
	end

	if GetCVarBool("bankConfirmTabCleanUp") then
		StaticPopupSpecial_Show(BankCleanUpConfirmationPopup);
	else
		C_Container.SortBank(bankType);
	end
end