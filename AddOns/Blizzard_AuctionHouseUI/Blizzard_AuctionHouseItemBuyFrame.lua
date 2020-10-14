
local ITEM_BUY_SCROLL_OFFSET_REFRESH_THRESHOLD = 30;


AuctionHouseItemBuyFrameMixin = CreateFromMixins(AuctionHouseBuySystemMixin, AuctionHouseSortOrderSystemMixin);

local AUCTION_HOUSE_ITEM_BUY_FRAME_EVENTS = {
	"ITEM_SEARCH_RESULTS_UPDATED",
	"ITEM_SEARCH_RESULTS_ADDED",
	"BIDS_UPDATED",
	"AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
};

function AuctionHouseItemBuyFrameMixin:OnLoad()
	AuctionHouseBuySystemMixin.OnLoad(self);
	AuctionHouseSortOrderSystemMixin.OnLoad(self);

	self:SetSearchContext(AuctionHouseSearchContext.BuyItems);

	self.ItemDisplay:SetAuctionHouseFrame(self:GetAuctionHouseFrame());
	
	self:ResetPrice();

	self.ItemList:SetSelectionCallback(AuctionHouseUtil.GenerateRowSelectedCallbackWithInspect(self, self.OnAuctionSelected));

	self.ItemList:SetHighlightCallback(function(currentRowData, selectedRowData)
		return selectedRowData and (currentRowData.auctionID == selectedRowData.auctionID);
	end);

	self.ItemList:SetLineOnEnterCallback(AuctionHouseUtil.LineOnEnterCallback);
	self.ItemList:SetLineOnLeaveCallback(AuctionHouseUtil.LineOnLeaveCallback);

	self.ItemList:SetTableBuilderLayout(AuctionHouseTableBuilder.GetItemBuyListLayout(self, self.ItemList));


	local function ItemBuyListGetTotalQuantity()
		return self.itemKey and C_AuctionHouse.GetItemSearchResultsQuantity(self.itemKey) or 0;
	end

	local function ItemBuyListRefreshResults()
		if self.itemKey ~= nil then
			self:GetAuctionHouseFrame():RefreshSearchResults(AuctionHouseSearchContext.BuyItems, self.itemKey);
		end
	end

	self.ItemList:SetRefreshFrameFunctions(ItemBuyListGetTotalQuantity, ItemBuyListRefreshResults);
end

function AuctionHouseItemBuyFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_ITEM_BUY_FRAME_EVENTS);
end

function AuctionHouseItemBuyFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, AUCTION_HOUSE_ITEM_BUY_FRAME_EVENTS);

	self.ItemList:SetSelectedEntry(nil);
	self:SetAuction(nil);
end

function AuctionHouseItemBuyFrameMixin:OnEvent(event, ...)
	if event == "ITEM_SEARCH_RESULTS_UPDATED" then
		local itemKey, auctionID = ...;

		if auctionID then
			local function FindSelectedAuctionInfo(rowData)
				return rowData.auctionID == auctionID;
			end

			local scrollTo = true;
			self.ItemList:SetSelectedEntryByCondition(FindSelectedAuctionInfo, scrollTo);
		else
			self.ItemList:DirtyScrollFrame();
		end
	elseif event == "ITEM_SEARCH_RESULTS_ADDED" then
		self.ItemList:DirtyScrollFrame();
	elseif event == "BIDS_UPDATED" then
		self.ItemList:DirtyScrollFrame();
	elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
		self.ItemList:UpdateRefreshFrame();
	end
end

function AuctionHouseItemBuyFrameMixin:SetItemKey(itemKey)
	self.itemKey = itemKey;

	local function ItemBuyListSearchStarted()
		return self.itemKey ~= nil;
	end

	local function ItemBuyListGetNumEntries()
		return C_AuctionHouse.GetNumItemSearchResults(itemKey);
	end

	local function ItemBuyListGetEntry(index)
		return C_AuctionHouse.GetItemSearchResultInfo(itemKey, index);
	end

	local function ItemBuyListHasFullResults()
		return C_AuctionHouse.HasFullItemSearchResults(itemKey);
	end

	local function ItemBuyListRefreshCallback(lastDisplayEntry)
		local numEntries = ItemBuyListGetNumEntries();
		if numEntries > 0 and numEntries - lastDisplayEntry < ITEM_BUY_SCROLL_OFFSET_REFRESH_THRESHOLD then
			local hasFullResults = C_AuctionHouse.RequestMoreItemSearchResults(itemKey);
			if hasFullResults then
				self.ItemList:SetRefreshCallback(nil);
			end
		end
	end

	self.ItemList:SetDataProvider(ItemBuyListSearchStarted, ItemBuyListGetEntry, ItemBuyListGetNumEntries, ItemBuyListHasFullResults);
	self.ItemDisplay:SetItemKey(itemKey);
	self.ItemList:SetRefreshCallback(ItemBuyListRefreshCallback);
end

function AuctionHouseItemBuyFrameMixin:OnAuctionSelected(auctionData)
	if auctionData == nil then
		self:ResetPrice();
	else
		self:SetAuction(auctionData.auctionID, auctionData.minBid, auctionData.buyoutAmount, AuctionHouseUtil.IsOwnedAuction(auctionData), auctionData.bidder);
	end
end

function AuctionHouseItemBuyFrameMixin:HasAuctionSelected()
	return self.ItemList:GetSelectedEntry() ~= nil;
end
