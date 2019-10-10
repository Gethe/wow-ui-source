
local ITEM_BUY_SCROLL_OFFSET_REFRESH_THRESHOLD = 30;


AuctionHouseItemBuyFrameMixin = CreateFromMixins(AuctionHouseBuySystemMixin, AuctionHouseSortOrderSystemMixin);

local AUCTION_HOUSE_ITEM_BUY_FRAME_EVENTS = {
	"ITEM_SEARCH_RESULTS_UPDATED",
	"ITEM_SEARCH_RESULTS_ADDED",
	"BIDS_UPDATED",
	"AUCTION_CANCELED",
	"AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
};

function AuctionHouseItemBuyFrameMixin:OnLoad()
	AuctionHouseBuySystemMixin.OnLoad(self);
	AuctionHouseSortOrderSystemMixin.OnLoad(self);

	self:SetSearchContext(AuctionHouseSearchContext.BuyItems);

	self.ItemDisplay:SetAuctionHouseFrame(self:GetAuctionHouseFrame());
	
	self:ResetPrice();

	self.ItemList:SetSelectionCallback(function(auctionData)
		self:OnAuctionSelected(auctionData);
	end);

	self.ItemList:SetHighlightCallback(function(currentRowData, selectedRowData)
		if self.selectedAuctionCanceled then
			if selectedRowData.buyoutAmount == currentRowData.buyoutAmount then
				self.ItemList:SetSelectedEntry(currentRowData);
				return true;
			end
		else
			return selectedRowData and (currentRowData.auctionID == selectedRowData.auctionID);
		end
	end);

	self.ItemList:SetLineOnEnterCallback(AuctionHouseUtil.SetAuctionHouseTooltip);
	self.ItemList:SetLineOnLeaveCallback(GameTooltip_Hide);

	self.ItemList:SetTableBuilderLayout(AuctionHouseTableBuilder.GetItemBuyListLayout(self, self.ItemList));


	local function ItemBuyListGetTotalQuantity()
		return self.itemKey and C_AuctionHouse.GetItemSearchResultsQuantity(self.itemKey) or 0;
	end

	local function ItemBuyListRefreshResults()
		if self.itemKey ~= nil then
			C_AuctionHouse.RefreshItemSearchResults(self.itemKey);
		end
	end

	self.ItemList:SetRefreshFrameFunctions(ItemBuyListGetTotalQuantity, ItemBuyListRefreshResults);
end

function AuctionHouseItemBuyFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_ITEM_BUY_FRAME_EVENTS);
end

function AuctionHouseItemBuyFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, AUCTION_HOUSE_ITEM_BUY_FRAME_EVENTS);
end

function AuctionHouseItemBuyFrameMixin:OnEvent(event, ...)
	if event == "ITEM_SEARCH_RESULTS_UPDATED" then
		self.ItemList:DirtyScrollFrame();
	elseif event == "ITEM_SEARCH_RESULTS_ADDED" then
		self.ItemList:DirtyScrollFrame();
	elseif event == "BIDS_UPDATED" then
		self.ItemList:DirtyScrollFrame();
	elseif event == "AUCTION_CANCELED" then
		local auctionID = ...;
		local selectedRowData = self.ItemList:GetSelectedEntry();
		if selectedRowData and selectedRowData.auctionID == auctionID then
			self.selectedAuctionCanceled = true;
		end
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
	self.selectedAuctionCanceled = false;

	if auctionData == nil then
		self:ResetPrice();
	else
		self:SetAuction(auctionData.auctionID, auctionData.minBid, auctionData.buyoutAmount);
	end
end

function AuctionHouseItemBuyFrameMixin:HasAuctionSelected()
	return self.ItemList:GetSelectedEntry() ~= nil;
end
