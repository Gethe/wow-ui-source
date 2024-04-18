
AuctionHouseCommoditiesSellFrameMixin = CreateFromMixins(AuctionHouseSellFrameMixin);

local COMMODITIES_SELL_FRAME_EVENTS = {
	"COMMODITY_SEARCH_RESULTS_UPDATED",
};

function AuctionHouseCommoditiesSellFrameMixin:Init()
	if self.isInitialized then
		return;
	end

	self.isInitialized = true;

	self:SetSearchContext(AuctionHouseSearchContext.SellCommodities);

	local commoditiesSellList = self:GetCommoditiesSellList();
	commoditiesSellList:SetSelectionCallback(AuctionHouseUtil.GenerateRowSelectedCallbackWithLink(self, self.OnAuctionSelected));

	commoditiesSellList:RefreshScrollFrame();
end

function AuctionHouseCommoditiesSellFrameMixin:OnShow()
	AuctionHouseSellFrameMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, COMMODITIES_SELL_FRAME_EVENTS);

	self.PriceInput.PerItemPostfix:Show();

	-- We need to use a separate Init instead of OnLoad to avoid load order problems.
	self:Init();
end

function AuctionHouseCommoditiesSellFrameMixin:OnHide()
	AuctionHouseSellFrameMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, COMMODITIES_SELL_FRAME_EVENTS);
end

function AuctionHouseCommoditiesSellFrameMixin:OnEvent(event, ...)
	AuctionHouseSellFrameMixin.OnEvent(self, event, ...);

	if event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
		self:UpdatePriceSelection();
	end
end

function AuctionHouseCommoditiesSellFrameMixin:UpdatePriceSelection()
	self:ClearSearchResultPrice();

	if self:GetUnitPrice() == self:GetDefaultPrice() then
		local itemLocation = self:GetItem();
		if itemLocation then
			local firstSearchResult = C_AuctionHouse.GetCommoditySearchResultInfo(C_Item.GetItemID(itemLocation), 1);
			if firstSearchResult then
				self:GetCommoditiesSellList():SetSelectedEntry(firstSearchResult);
			end
		end
	end
end

function AuctionHouseCommoditiesSellFrameMixin:OnAuctionSelected(commoditySearchResult)
	self.PriceInput:SetAmount(commoditySearchResult.unitPrice);
	self:SetSearchResultPrice(commoditySearchResult.unitPrice);
end

function AuctionHouseCommoditiesSellFrameMixin:GetUnitPrice()
	local unitPrice = self.PriceInput:GetAmount();
	return unitPrice;
end

function AuctionHouseCommoditiesSellFrameMixin:GetDepositAmount()
	local item = self:GetItem();
	if not item then
		return 0;
	end

	local duration = self:GetDuration();
	local quantity = self:GetQuantity();
	local deposit = C_AuctionHouse.CalculateCommodityDeposit(C_Item.GetItemID(item), duration, quantity);
	return deposit;
end

function AuctionHouseCommoditiesSellFrameMixin:GetTotalPrice()
	return self:GetQuantity() * self:GetUnitPrice();
end

function AuctionHouseCommoditiesSellFrameMixin:CanPostItem()
	local canPostItem, reasonTooltip = AuctionHouseSellFrameMixin.CanPostItem(self);
	if not canPostItem then
		return canPostItem, reasonTooltip;
	end

	local unitPrice = self:GetUnitPrice();
	if unitPrice == 0 then
		return false, AUCTION_HOUSE_SELL_FRAME_ERROR_PRICE;
	end

	return true, nil;
end

function AuctionHouseCommoditiesSellFrameMixin:GetPostDetails()
	local item = self:GetItem();
	local duration = self:GetDuration();
	local quantity = self:GetQuantity();
	local unitPrice = self:GetUnitPrice();

	return item, duration, quantity, unitPrice;
end

function AuctionHouseCommoditiesSellFrameMixin:StartPost(...)
	if not self:CanPostItem() then
		return;
	end

	if not C_AuctionHouse.PostCommodity(...) then
		self:ClearPost();
	else
		self:CachePendingPost(...);
	end
end

function AuctionHouseCommoditiesSellFrameMixin:PostItem()
	self:StartPost(self:GetPostDetails());
end

function AuctionHouseCommoditiesSellFrameMixin:ConfirmPost()
	if self.pendingPost then
		C_AuctionHouse.ConfirmPostCommodity(SafeUnpack(self.pendingPost));
		self:ClearPost();
		return true;
	end
end

function AuctionHouseCommoditiesSellFrameMixin:CachePendingPost(...)
	self.pendingPost = SafePack(...);
end

function AuctionHouseCommoditiesSellFrameMixin:ClearPost()
	self.pendingPost = nil;

	local fromItemDisplay = nil;
	local refreshListWithPreviousItem = true;
	self:SetItem(nil, fromItemDisplay, refreshListWithPreviousItem);
end

function AuctionHouseCommoditiesSellFrameMixin:SetItem(itemLocation, fromItemDisplay, refreshListWithPreviousItem)
	local previousItemLocation = self:GetItem();

	AuctionHouseSellFrameMixin.SetItem(self, itemLocation, fromItemDisplay);

	local itemKey = itemLocation and C_AuctionHouse.GetItemKeyFromItem(itemLocation) or nil;
	if refreshListWithPreviousItem then
		local previousItemKey = previousItemLocation and C_AuctionHouse.GetItemKeyFromItem(previousItemLocation) or nil;
		if previousItemKey then
			itemKey = previousItemKey;
		end
	end

	if itemKey then
		self:GetAuctionHouseFrame():QueryItem(self:GetSearchContext(), itemKey);
	end

	self:UpdatePriceSelection();

	if itemLocation then
		self.QuantityInput:SetQuantity(C_Item.GetStackCount(itemLocation));
		self:UpdateTotalPrice();

		-- Hack fix for a spacing problem: Without this line, the edit box would be scrolled to
		-- the left and the text would not be visible. This seems to be a problem with setting
		-- the text on the edit box and showing it in the same frame.
		self.QuantityInput.InputBox:SetCursorPosition(0);
	end

	self:GetCommoditiesSellList():SetItemID(itemKey and itemKey.itemID or nil);
end

function AuctionHouseCommoditiesSellFrameMixin:GetCommoditiesSellList()
	local commoditiesSellList = self:GetAuctionHouseFrame():GetCommoditiesSellListFrames();
	return commoditiesSellList;
end

function AuctionHouseCommoditiesSellFrameMixin:GetCommoditiesSellListFrames()
	return self:GetAuctionHouseFrame():GetCommoditiesSellListFrames();
end
