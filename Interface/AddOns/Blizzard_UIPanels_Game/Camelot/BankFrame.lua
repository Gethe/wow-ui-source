StaticPopupDialogs["CONFIRM_BUY_BANK_TAB"] = {
	text = CONFIRM_BUY_BANK_SLOT, 	-- Text is dynamically updated
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

bankFrameWidthOverride = 560;

function GetBagIDFromBankTypeAndSlot(bankType, bagSlot)
	if(bankType == Enum.BankType.Character) then
		return bagSlot + ITEM_INVENTORY_BANK_BAG_OFFSET;
	elseif(bankType == Enum.BankType.Account) then
		return bagSlot + ITEM_INVENTORY_BANK_BAG_OFFSET + NUM_CHARACTER_BANK_SLOTS;
	end
end

BankFrameMixin = {};

function BankFrameMixin:OnTriggerSetTabEffects(id)
	self:SetTab(id);
	self:RefreshBankTabHighlights();
end

function BankFrameMixin:OnShowOrHideBagCost()
	local bankType = self:GetActiveBankType();
	local numPurchasedBankTabs = C_Bank.FetchNumPurchasedBankTabs(bankType);
	if (numPurchasedBankTabs >= C_Bank.FetchMaxNumBankTabs(bankType) or (bankType == Enum.BankType.Account and numPurchasedBankTabs == 0)) then
		self.BankPanel.MoneyDisplay:Hide();
		self.BagCost:Hide();
		self.BankPanel.PurchaseButton:Hide();
	else
		self.BankPanel.MoneyDisplay:Show();
		self.BagCost:Show();
		self.BankPanel.PurchaseButton:Show();
	end
end

function BankFrameMixin:OnLoad()
	BankFrameBaseMixin.OnLoad(self);
	local function BankItemButtonBagResetter(itemButtonBagPool, itemButton)
		itemButton.isInitialized = false;
		Pool_HideAndClearAnchors(itemButtonBagPool, itemButton);
	end
	local function BankPageTabResetter(bankPageTabPool, pageTab)
		pageTab.pageNumber = nil;
		pageTab.bankType = nil;
		Pool_HideAndClearAnchors(bankPageTabPool, pageTab);
	end
	self.itemButtonBagPool = CreateFramePool("ItemButton", self, "BankItemButtonBagTemplate", BankItemButtonBagResetter);
	self.bankPageTabPool = CreateFramePool("FRAME", self, "BankPageTabTemplate", BankPageTabResetter);
	EventRegistry:RegisterCallback("BankPanelMixin.TriggerSetTabEffects", self.OnTriggerSetTabEffects, self);
	EventRegistry:RegisterCallback("BankPanelMixin.ShowOrHideBagCost", self.OnShowOrHideBagCost, self);
	EventRegistry:RegisterCallback("BankPanelMixin.PageInfoChanged", self.OnPageInfoChanged, self);
end

function BankFrameMixin:OnPageInfoChanged(currentPage)
	self.currentBankPage = currentPage;
	self:RefreshPageTabs(currentPage);
end

function BankFrameMixin:GetTabIDForBankType(bankType)
	for tabID, tabBankType in pairs(self.TabIDToBankType) do
		if tabBankType == bankType then
			return tabID;
		end
	end
end

function BankFrameMixin:GetNumPagesForBankType(bankType)
	if not C_Bank.ShouldUsePlayerBagsInBank() then
		return 1;
	end

	local bankTabData = C_Bank.FetchPurchasedBankTabData(bankType);
	if not bankTabData then
		return 1;
	end

	local totalSlots = 0;
	for _index, tabData in ipairs(bankTabData) do
		totalSlots = totalSlots + C_Container.GetContainerNumSlots(tabData.ID);
	end

	return math.max(1, math.ceil(totalSlots / self.BankPanel:GetMaximumTotalSlotsPerPage()));
end

function BankFrameMixin:RefreshPageTabs(currentPage)
	if not self.bankPageTabPool then
		return;
	end

	self.bankPageTabPool:ReleaseAll();

	local activeBankType = self:GetActiveBankType();
	local lastTab;

	local function AddPageTabs(bankType)
		if not C_Bank.CanViewBank(bankType) then
			return;
		end

		for pageNumber = 1, self:GetNumPagesForBankType(bankType) do
			local pageTab = self.bankPageTabPool:Acquire();
			if lastTab then
				pageTab:SetPoint("TOPLEFT", lastTab, "BOTTOMLEFT", 0, -2);
			else
				pageTab:SetPoint("TOPLEFT", self, "TOPRIGHT", 3, -60);
			end
			pageTab:SetPageInfo(bankType, pageNumber, bankType == activeBankType and currentPage or nil);
			pageTab:Show();
			lastTab = pageTab;
		end
	end

	AddPageTabs(Enum.BankType.Character);
	AddPageTabs(Enum.BankType.Account);
end

function BankFrameMixin:RefreshBagButtons()
	if(not self.itemButtonBagPool) then
		return;
	end
	self.itemButtonBagPool:ReleaseAll();

	local bankType = self:GetActiveBankType();
	local maxBankBags = C_Bank.FetchMaxNumBankTabs(bankType);
	local bagData = C_Bank.FetchPurchasedBankTabData(bankType);

	if(not bagData) then
		UIErrorsFrame:AddMessage("No BankTab data found on loading BankFrame.", RED_FONT_COLOR:GetRGBA());
		return;
	end

	local lastCreatedButton;

	-- We skip the first bag as we start with the first bag purchased.
	for bagNum = 2, maxBankBags do
		local button = self.itemButtonBagPool:Acquire();
			
		local isFirstButton = bagNum == 2;
		if isFirstButton then
			local xOffset, yOffset = 10, 5;
			button:SetPoint("TOPLEFT", self.BagText, "TOPRIGHT", bagNum * xOffset, yOffset);
		else
			local xOffset, yOffset = 50, 0;
			button:SetPoint("TOPLEFT", lastCreatedButton, "TOPLEFT", xOffset, yOffset);
		end

		button.bankType = bankType;
		button.bagSlotID = bagNum;

		button:Show();

		lastCreatedButton = button;

		local curBagData = bagData[button.bagSlotID];
		if (curBagData) then
			-- We have bought this bag!
			button.DisabledOverlay:SetShown(false);
			button.tooltipText = BANK_BAG;
			self.bought = true;
		else
			-- This bag is unbought
			button.DisabledOverlay:SetShown(true);
			button.tooltipText = BANK_BAG_PURCHASE;
			self.bought = false;
		end

		if(button.bankType == Enum.BankType.Character) then
			button:SetItemLocation(ItemLocation:CreateFromBagAndSlot(Enum.BagIndex.Characterbanktab, button.bagSlotID));
		elseif(button.bankType == Enum.BankType.Account) then
			button:SetItemLocation(ItemLocation:CreateFromBagAndSlot(Enum.BagIndex.Accountbanktab, button.bagSlotID));
		end
	end
end

local BankFrameEvents = {
	"BANK_TABS_CHANGED",
};

function BankFrameMixin:PurchaseFirstSlot()
	local bankType = self:GetActiveBankType();
	if (bankType == Enum.BankType.Character) then
		local tabData = C_Bank.FetchNextPurchasableBankTabData(bankType);
		if (not tabData) or (tabData.tabCost > 0) then
			return;
		end
		C_Bank.PurchaseBankTab(bankType);
	end
end

function BankFrameMixin:RefreshAll()
	self:RefreshBagButtons();
	self.BankPanel.MoneyDisplay:Refresh();
	self.BankPanel:Reset();
	self:RefreshBankTabHighlights();
end

function BankFrameMixin:OnShow()
	BankFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, BankFrameEvents);

	self:RefreshPageTabs(1);

	self:RefreshAll();
end

function BankFrameMixin:OnHide()
	BankFrameBaseMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, BankFrameEvents);
	self.itemButtonBagPool:ReleaseAll();
	self.bankPageTabPool:ReleaseAll();
end

function BankFrameMixin:SetTab(tabID)
	BankFrameBaseMixin.SetTab(self, tabID);
	self:PurchaseFirstSlot();
	self:RefreshAll();
end

function BankFrameMixin:OnEvent(event, ...)
	if event == "BANK_TABS_CHANGED"	then
		local bankType = ...;
		if bankType == self:GetActiveBankType() then
			self:RefreshAll();
		end
	end
end

function BankFrameMixin:RefreshBankTabHighlights()
	self:RefreshPageTabs(self.BankPanel.currentPage or self.currentBankPage or 1);
end

CamelotBankPanelItemButtonMixin = {};

function CamelotBankPanelItemButtonMixin:Refresh()
	BankPanelItemButtonMixin.Refresh(self);

	local normalTexture = self:GetNormalTexture();
	if normalTexture then
		local normalAtlas = self.itemInfo and "bank-frame-bag-slotframe" or "bank-frame-item-slotframe";
		normalTexture:SetAtlas(normalAtlas, TextureKitConstants.IgnoreAtlasSize);
	end
end

BankPageTabMixin = CreateFromMixins(SidePanelTabButtonMixin);

function BankPageTabMixin:OnLoad()
	SidePanelTabButtonMixin.OnLoad(self);

	self.Icon:SetTexture(self.iconTexture);

	self:SetCustomOnMouseUpHandler(function(tab, button, upInside)
		if button == "LeftButton" and upInside and tab.pageNumber then
			local bankFrame = tab:GetParent();
			local bankType = tab.bankType;
			local pageNumber = tab.pageNumber;

			if bankType and bankType ~= bankFrame:GetActiveBankType() then
				EventRegistry:TriggerEvent("BankPanelMixin.TriggerSetTabEffects", bankFrame:GetTabIDForBankType(bankType));
			end
			EventRegistry:TriggerEvent("BankPanelMixin.PageSelected", pageNumber);
		end
	end);
end

function BankPageTabMixin:SetPageInfo(bankType, pageNumber, currentPage)
	self.bankType = bankType;
	self.pageNumber = pageNumber;

	local isAccountBank = bankType == Enum.BankType.Account;
	if isAccountBank then
		self.tooltipText = string.format(ACCOUNT_BANK_PAGE_NUMBER, pageNumber);
	else
		self.tooltipText = string.format(PAGE_NUMBER, pageNumber);
	end

	self:SetChecked(pageNumber == currentPage);

	local iconKey = isAccountBank and "accountBankIconTexture"..pageNumber or "iconTexture"..pageNumber;
	self.Icon:SetTexture(self[iconKey] or self.iconTexture);
end

BankItemButtonBagMixin = {};

function BankItemButtonBagMixin:BagInventorySlot()
	return C_Bank.BankBagTypeAndIDToInvSlot(self.bankType, self.bagSlotID) + 1;
end

function BankItemButtonBagMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp","RightButtonUp");
end

function BankItemButtonBagMixin:GetExactBankTabSlot()
	-- Convert bank type and bag slot to bankTabSlot
	if (self.bankType == Enum.BankType.Character) then
		return Enum.BagIndex.CharacterBankTab_1 + self.bagSlotID - 1;
	elseif (self.bankType == Enum.BankType.Account) then
		return Enum.BagIndex.AccountBankTab_1 + self.bagSlotID - 1;
	end
end

function BankItemButtonBagMixin:GetBagAndSlot()
	if (self.bankType == Enum.BankType.Character) then
		return Enum.BagIndex.Characterbanktab, self.bagSlotID;
	elseif (self.bankType == Enum.BankType.Account) then
		return Enum.BagIndex.Accountbanktab, self.bagSlotID;
	end
end

function BankItemButtonBagMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.DisabledOverlay and self.DisabledOverlay:IsShown() then
		GameTooltip:SetText(self.tooltipText);
	else
		local bagID, slotID = self:GetBagAndSlot();
		if not bagID or not GameTooltip:SetBagItem(bagID, slotID) then
			GameTooltip:SetText(self.tooltipText);
		end
	end
	GameTooltip:Show();
	CursorUpdate(self);
	self:GetParent().BankPanel:ToggleButtonGlowForItemsOfBankBag(self:GetExactBankTabSlot(), true);
end

function BankItemButtonBagMixin:OnLeave()
	GameTooltip:Hide();
	ResetCursor();
	self:GetParent().BankPanel:ToggleButtonGlowForItemsOfBankBag(self:GetExactBankTabSlot(), false);
end

local BankItemButtonBagEvents = {
	"PLAYERBANKSLOTS_CHANGED",
	"PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED",
	"BAG_CONTAINER_UPDATE",
};

function BankItemButtonBagMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, BankItemButtonBagEvents);
end

function BankItemButtonBagMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, BankItemButtonBagEvents);
end

function BankItemButtonBagMixin:OnEvent(event, ...)
	if (event == "PLAYERBANKSLOTS_CHANGED") then
		if(self.bankType == Enum.BankType.Character) then
			self:SetItemLocation(ItemLocation:CreateFromBagAndSlot(Enum.BagIndex.Characterbanktab, self.bagSlotID));
		end
	elseif(event == "PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED") then
		if(self.bankType == Enum.BankType.Account) then
			self:SetItemLocation(ItemLocation:CreateFromBagAndSlot(Enum.BagIndex.Accountbanktab, self.bagSlotID));
		end
	elseif(event == "BAG_CONTAINER_UPDATE") then
		self:GetParent():RefreshAll();
	end
end

function BankItemButtonBagMixin:OnClickInternal()
	local bagID, slotID = self:GetBagAndSlot();
	if bagID then
		C_Container.PickupContainerItem(bagID, slotID);
	end
end

function BankItemButtonBagMixin:Pickup()
	self:OnClickInternal();
end

function BankItemButtonBagMixin:OnClick()
	if (IsModifiedClick("PICKUPITEM")) then
		self:Pickup();
	else
		self:OnClickInternal();
	end
end

BankBagCostMoneyDisplayMixin = {};

function BankBagCostMoneyDisplayMixin:Refresh()
	local bankType = self:GetParent():GetActiveBankType();
	if(not bankType) then
		return;
	end
	EventRegistry:TriggerEvent("BankPanelMixin.ShowOrHideBagCost");
	local tabData = bankType and C_Bank.FetchNextPurchasableBankTabData(bankType) or nil;
	if tabData then
		MoneyFrame_Update(self, tabData.tabCost);
		SetMoneyFrameColorByFrame(self, tabData.canAfford and "white" or "red");
	end
end

local BankPurchasePromptEvents = {
	"PLAYER_MONEY",
};

function BankBagCostMoneyDisplayMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, BankPurchasePromptEvents);
end

function BankBagCostMoneyDisplayMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, BankPurchasePromptEvents);
end

function BankBagCostMoneyDisplayMixin:OnEvent(event, ...)
	if event == "PLAYER_MONEY" then
		self:Refresh();
	end
end

function BankBagCostMoneyDisplayMixin:OnLoad()
	SmallMoneyFrame_OnLoad(self);
	MoneyFrame_SetType(self, "STATIC");
end

BankFramePurchaseButtonMixin = {};

function BankFramePurchaseButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
	StaticPopup_Show("CONFIRM_BUY_BANK_TAB", nil, nil, { bankType = self:GetParent():GetActiveBankType() });
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "BankFrame",
		showFunc = BankFrame_Open,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.Banker, frameInfo);
	RegisterPlayerInteraction(Enum.PlayerInteractionType.CharacterBanker, frameInfo);
	RegisterPlayerInteraction(Enum.PlayerInteractionType.AccountBanker, frameInfo);
end

RegisterWithPlayerInteractionManager();
