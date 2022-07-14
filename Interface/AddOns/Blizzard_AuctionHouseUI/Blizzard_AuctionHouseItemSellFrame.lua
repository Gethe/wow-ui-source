
local ITEM_SELL_SCROLL_OFFSET_REFRESH_THRESHOLD = 30;


AuctionHouseBuyoutModeCheckButtonMixin = {};

function AuctionHouseBuyoutModeCheckButtonMixin:OnLoad()
	self.text:SetFontObject(GameFontNormal);
	self.text:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	self.text:SetText(AUCTION_HOUSE_BUYOUT_MODE_CHECK_BOX);
end

function AuctionHouseBuyoutModeCheckButtonMixin:OnShow()
	self:SetChecked(true);
	self:UpdateState();
end

function AuctionHouseBuyoutModeCheckButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local wrap = true;
	GameTooltip_AddNormalLine(GameTooltip, AUCTION_HOUSE_BUYOUT_MODE_TOOLTIP, wrap);

	GameTooltip:Show();
end

function AuctionHouseBuyoutModeCheckButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function AuctionHouseBuyoutModeCheckButtonMixin:OnClick()
	self:UpdateState();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function AuctionHouseBuyoutModeCheckButtonMixin:UpdateState()
	self:GetParent():SetSecondaryPriceInputEnabled(not self:GetChecked());
end


AuctionHouseItemSellFrameMixin = CreateFromMixins(AuctionHouseSellFrameMixin);

local AUCTION_HOUSE_ITEM_SELL_FRAME_EVENTS = {
	"ITEM_SEARCH_RESULTS_UPDATED",
	"ITEM_SEARCH_RESULTS_ADDED",
	"AUCTION_MULTISELL_START",
	"AUCTION_MULTISELL_UPDATE",
	"AUCTION_MULTISELL_FAILURE",
};

function AuctionHouseItemSellFrameMixin:OnLoad()
	AuctionHouseSellFrameMixin.OnLoad(self);

	self:SetSearchContext(AuctionHouseSearchContext.SellItems);

	self.PriceInput:SetLabel(AUCTION_HOUSE_BUYOUT_LABEL);
	self.PriceInput:SetErrorTooltip(AUCTION_BUYOUT_ERROR);

	self.SecondaryPriceInput:SetOnValueChangedCallback(function()
		self:UpdatePostState();
	end);
end

function AuctionHouseItemSellFrameMixin:OnShow()
	AuctionHouseSellFrameMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_ITEM_SELL_FRAME_EVENTS);

	self:InitializeItemSellList();
end

function AuctionHouseItemSellFrameMixin:OnHide()
	AuctionHouseSellFrameMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, AUCTION_HOUSE_ITEM_SELL_FRAME_EVENTS);

	if AuctionHouseMultisellProgressFrame:IsShown() then
		-- Clear out any active multisell.
		C_AuctionHouse.CancelSell();
		self:SetMultiSell(false);
	end
end

function AuctionHouseItemSellFrameMixin:OnEvent(event, ...)
	AuctionHouseSellFrameMixin.OnEvent(self, event, ...);

	if event == "ITEM_SEARCH_RESULTS_UPDATED" then
		self:UpdatePriceSelection();
		self:GetItemSellList():DirtyScrollFrame();
	elseif event == "ITEM_SEARCH_RESULTS_ADDED" then
		self:GetItemSellList():DirtyScrollFrame();
	elseif event == "AUCTION_MULTISELL_START" then
		local itemLocation = self:GetItem();
		local itemTexture = itemLocation and C_Item.GetItemIcon(itemLocation);
		AuctionHouseMultisellProgressFrame:Start(itemTexture, self:GetQuantity());

		local inProgress = true;
		self:SetMultiSell(inProgress);
	elseif event == "AUCTION_MULTISELL_UPDATE" then
		local numPosted, total = ...;
		AuctionHouseMultisellProgressFrame:Refresh(numPosted, total);

		if numPosted == total then
			local inProgress = false;
			self:SetMultiSell(inProgress);
		end
	elseif event == "AUCTION_MULTISELL_FAILURE" then
		local inProgress = false;
		self:SetMultiSell(inProgress);
	end
end

function AuctionHouseItemSellFrameMixin:SetMultiSell(inProgress)
	self.multisellInProgress = inProgress;
	AuctionHouseMultisellProgressFrame:SetShown(inProgress);
	self.DisabledOverlay:SetShown(inProgress);
	if not inProgress then
		local fromItemDisplay = nil;
		local refreshListWithPreviousItem = true;
		self:SetItem(nil, fromItemDisplay, refreshListWithPreviousItem);
	end
end

function AuctionHouseItemSellFrameMixin:UpdatePriceSelection()
	self:ClearSearchResultPrice();

	if self.listDisplayedItemKey then
		local defaultPrice = self:GetDefaultPrice();
		local defaultBid = not self.SecondaryPriceInput:IsShown() or self.SecondaryPriceInput:GetAmount() == 0;
		local defaultBuyout = self.PriceInput:GetAmount() == defaultPrice;

		-- If the user hasn't entered a price, update to the lowest price available.
		if defaultBid and defaultBuyout then
			local firstSearchResult = C_AuctionHouse.GetItemSearchResultInfo(self.listDisplayedItemKey, 1);
			if firstSearchResult then
				self:GetItemSellList():SetSelectedEntry(firstSearchResult);
			end
		end
	end
end

function AuctionHouseItemSellFrameMixin:InitializeItemSellList()
	if self.itemSellListIsInitialized then
		return;
	end

	self.itemSellListIsInitialized = true;

	local itemSellList = self:GetItemSellList();

	itemSellList:SetSelectionCallback(AuctionHouseUtil.GenerateRowSelectedCallbackWithInspect(self, self.OnSearchResultSelected));

	itemSellList:SetHighlightCallback(function(currentRowData, selectedRowData)
		return selectedRowData and currentRowData.auctionID == selectedRowData.auctionID;
	end);

	itemSellList:SetLineOnEnterCallback(AuctionHouseUtil.LineOnEnterCallback);
	itemSellList:SetLineOnLeaveCallback(AuctionHouseUtil.LineOnLeaveCallback);

	local isEquipment = false;
	local isPet = false;
	itemSellList:SetTableBuilderLayout(AuctionHouseTableBuilder.GetItemSellListLayout(self, itemSellList, isEquipment, isPet));

	local function ItemSellListSearchStarted()
		return self.listDisplayedItemKey ~= nil;
	end

	local function ItemSellListGetEntry(index)
		return self.listDisplayedItemKey and C_AuctionHouse.GetItemSearchResultInfo(self.listDisplayedItemKey, index);
	end

	local function ItemSellListGetNumEntries()
		return self.listDisplayedItemKey and C_AuctionHouse.GetNumItemSearchResults(self.listDisplayedItemKey) or 0; -- Implemented in-line instead for performance.
	end

	local function ItemSellListHasFullResults()
		return self.listDisplayedItemKey == nil or C_AuctionHouse.HasFullItemSearchResults(self.listDisplayedItemKey);
	end

	itemSellList:SetDataProvider(ItemSellListSearchStarted, ItemSellListGetEntry, ItemSellListGetNumEntries, ItemSellListHasFullResults);


	local function ItemSellListGetTotalQuantity()
		return self.listDisplayedItemKey and C_AuctionHouse.GetItemSearchResultsQuantity(self.listDisplayedItemKey) or 0; -- Implemented in-line instead for performance.
	end

	local function ItemSellListRefreshResults()
		if self.listDisplayedItemKey ~= nil then
			self:GetAuctionHouseFrame():RefreshSearchResults(self:GetSearchContext(), self.listDisplayedItemKey);
		end
	end

	itemSellList:SetRefreshFrameFunctions(ItemSellListGetTotalQuantity, ItemSellListRefreshResults);
end

function AuctionHouseItemSellFrameMixin:OnSearchResultSelected(searchResult)
	if self.SecondaryPriceInput:IsShown() then
		self.SecondaryPriceInput:SetAmount(searchResult.bidAmount or 0);
	end

	self.PriceInput:SetAmount(searchResult.buyoutAmount or 0);
	self:SetSearchResultPrice(searchResult.buyoutAmount);
end

function AuctionHouseItemSellFrameMixin:SetSecondaryPriceInputEnabled(enabled)
	self.BuyoutModeCheckButton:SetChecked(not enabled);
	self.PriceInput:SetLabel(AUCTION_HOUSE_BUYOUT_LABEL);
	self.PriceInput:SetSubtext(enabled and AUCTION_HOUSE_BUYOUT_OPTIONAL_LABEL or nil);
	self.PriceInput.PerItemPostfix:SetShown(not enabled);
	self.SecondaryPriceInput:SetShown(enabled);
	self.SecondaryPriceInput:Clear();

	self:UpdatePostState();
	self:UpdateFocusTabbing();
	self:MarkDirty();
end

function AuctionHouseItemSellFrameMixin:SetItem(itemLocation, fromItemDisplay, refreshListWithPreviousItem)
	if self.DisabledOverlay:IsShown() then
		return;
	end

	AuctionHouseSellFrameMixin.SetItem(self, itemLocation, fromItemDisplay);

	self.SecondaryPriceInput:Clear();

	local itemKey = itemLocation and C_AuctionHouse.GetItemKeyFromItem(itemLocation) or nil;
	if refreshListWithPreviousItem and self.previousItemKey then
		itemKey = self.previousItemKey;
	end

	local newItemKey = AuctionHouseUtil.ConvertItemSellItemKey(itemKey);
	self.listDisplayedItemKey = newItemKey;

	local itemSellList = self:GetItemSellList();
	local itemKeyInfo = nil;
	if itemKey then
		itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
		itemSellList:SetTableBuilderLayout(AuctionHouseTableBuilder.GetItemSellListLayout(self, itemSellList, itemKeyInfo and itemKeyInfo.isEquipment, itemKeyInfo and itemKeyInfo.isPet));
	else
		itemSellList:SetTableBuilderLayout(AuctionHouseTableBuilder.GetItemSellListLayout(self, itemSellList));
	end

	local hasItemKey = itemKey ~= nil;
	if hasItemKey then
		local function ItemSellListRefreshCallback(lastDisplayEntry)
			local numEntries = C_AuctionHouse.GetNumItemSearchResults(itemKey);
			if numEntries > 0 and numEntries - lastDisplayEntry < ITEM_SELL_SCROLL_OFFSET_REFRESH_THRESHOLD then
				local hasFullResults = C_AuctionHouse.RequestMoreItemSearchResults(itemKey);
				if hasFullResults then
					itemSellList:SetRefreshCallback(nil);
				end
			end
		end

		itemSellList:SetRefreshCallback(ItemSellListRefreshCallback);
	else
		itemSellList:SetRefreshCallback(nil);
	end

	if hasItemKey then
		self:GetAuctionHouseFrame():QueryItem(self:GetSearchContext(), itemKey, itemKeyInfo and itemKeyInfo.isEquipment);
	end

	self:UpdatePriceSelection();
	itemSellList:DirtyScrollFrame();

	self.previousItemKey = itemKey;
end

function AuctionHouseItemSellFrameMixin:UpdatePostState()
	AuctionHouseSellFrameMixin.UpdatePostState(self);

	local bidPrice, buyoutPrice = self:GetPrice();
	if bidPrice and buyoutPrice and buyoutPrice <= bidPrice then
		self.PriceInput:SetLabelColor(RED_FONT_COLOR);
		self.PriceInput:SetErrorShown(true);
	else
		self.PriceInput:SetLabelColor(NORMAL_FONT_COLOR);
		self.PriceInput:SetErrorShown(false);
	end
end

function AuctionHouseItemSellFrameMixin:UpdateFocusTabbing()
	if self.SecondaryPriceInput:IsShown() then
		self.QuantityInput:SetNextEditBox(self.SecondaryPriceInput.MoneyInputFrame.GoldBox);
		self.SecondaryPriceInput:SetNextEditBox(self.PriceInput.MoneyInputFrame.GoldBox);
		self.PriceInput:SetNextEditBox(self.QuantityInput:IsShown() and self.QuantityInput.InputBox or self.SecondaryPriceInput.MoneyInputFrame.GoldBox);
	else
		self.QuantityInput:SetNextEditBox(self.PriceInput.MoneyInputFrame.GoldBox);
		self.PriceInput:SetNextEditBox(self.QuantityInput:IsShown() and self.QuantityInput.InputBox or nil);
	end
end

function AuctionHouseItemSellFrameMixin:GetDepositAmount()
	local item = self:GetItem();
	if not item then
		return 0;
	end
	
	local duration = self:GetDuration();
	local quantity = self:GetQuantity();
	local deposit = C_AuctionHouse.CalculateItemDeposit(item, duration, quantity);
	return deposit;
end

function AuctionHouseItemSellFrameMixin:GetTotalPrice()
	local bidPrice, buyoutPrice = self:GetPrice();
	return self:GetQuantity() * (buyoutPrice or bidPrice or 0);
end

function AuctionHouseItemSellFrameMixin:GetPrice()
	local buyoutPrice = self.PriceInput:GetAmount();
	local bidPrice = self.SecondaryPriceInput:IsShown() and self.SecondaryPriceInput:GetAmount() or nil;

	if buyoutPrice == 0 then
		buyoutPrice = nil;
	end

	if bidPrice == 0 then
		bidPrice = nil;
	end

	return bidPrice, buyoutPrice;
end

function AuctionHouseItemSellFrameMixin:CanPostItem()
	if self.multisellInProgress then
		return false, nil;
	end
	
	local canPostItem, reasonTooltip = AuctionHouseSellFrameMixin.CanPostItem(self);
	if not canPostItem then
		return canPostItem, reasonTooltip;
	end

	local bidPrice, buyoutPrice = self:GetPrice();
	if bidPrice == nil and buyoutPrice == nil then
		return false, AUCTION_HOUSE_SELL_FRAME_ERROR_PRICE;
	end

	if bidPrice and buyoutPrice and buyoutPrice <= bidPrice then
		return false, AUCTION_HOUSE_SELL_FRAME_ERROR_BUYOUT;
	end

	return true, nil;
end

function AuctionHouseItemSellFrameMixin:PostItem()
	if not self:CanPostItem() then
		return;
	end

	local item = self:GetItem();
	local duration = self:GetDuration();
	local quantity = self:GetQuantity();
	local bidPrice, buyoutPrice = self:GetPrice();
	C_AuctionHouse.PostItem(item, duration, quantity, bidPrice, buyoutPrice);

	if quantity == 1 then
		local fromItemDisplay = nil;
		local refreshListWithPreviousItem = true;
		self:SetItem(nil, fromItemDisplay, refreshListWithPreviousItem);
	end
end

function AuctionHouseItemSellFrameMixin:GetItemSellList()
	return self:GetAuctionHouseFrame():GetItemSellList();
end
