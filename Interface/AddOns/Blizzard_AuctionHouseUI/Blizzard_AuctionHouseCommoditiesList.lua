
local COMMODITIES_LIST_SCROLL_OFFSET_REFRESH_THRESHOLD = 30;
local MINIMUM_UNSELECTED_ENTRIES = 6;


AuctionHouseCommoditiesListMixin = CreateFromMixins(AuctionHouseItemListMixin, AuctionHouseSystemMixin);

local AUCTION_HOUSE_COMMODITIES_LIST_EVENTS = {
	"COMMODITY_SEARCH_RESULTS_UPDATED",
	"COMMODITY_SEARCH_RESULTS_RECEIVED",
	"COMMODITY_SEARCH_RESULTS_ADDED",
};

function AuctionHouseCommoditiesListMixin:OnLoad()
	AuctionHouseItemListMixin.OnLoad(self);
	
	local function CommoditiesListGetTotalQuantity()
		return self.itemID and C_AuctionHouse.GetCommoditySearchResultsQuantity(self.itemID) or 0;
	end

	local function CommoditiesListRefreshResults()
		self.resultsLoaded = false;

		if self.itemID then
			self:GetAuctionHouseFrame():RefreshSearchResults(self.searchContext, C_AuctionHouse.MakeItemKey(self.itemID));
		end
	end

	self:SetRefreshFrameFunctions(CommoditiesListGetTotalQuantity, CommoditiesListRefreshResults);
end

function AuctionHouseCommoditiesListMixin:OnShow()
	self:UpdateDataProvider();

	self.resultsLoaded = false;

	AuctionHouseItemListMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_COMMODITIES_LIST_EVENTS);
end

function AuctionHouseCommoditiesListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, AUCTION_HOUSE_COMMODITIES_LIST_EVENTS);
end

function AuctionHouseCommoditiesListMixin:OnEvent(event, ...)
	if event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
		self:Reset();
	elseif event == "COMMODITY_SEARCH_RESULTS_RECEIVED" then
		self.resultsLoaded = true;
		self:Reset();
	elseif event == "COMMODITY_SEARCH_RESULTS_ADDED" then
		self:DirtyScrollFrame();
	end
end

function AuctionHouseCommoditiesListMixin:SetItemID(itemID)
	self.itemID = itemID;
	self:UpdateDataProvider();
	self:DirtyScrollFrame();
end

function AuctionHouseCommoditiesListMixin:UpdateDataProvider()
	local itemID = self.itemID;

	local function CommoditiesListSearchStarted()
		return itemID ~= nil;
	end

	local function CommoditiesListGetEntry(index)
		return C_AuctionHouse.GetCommoditySearchResultInfo(itemID, index);
	end

	local function CommoditiesListGetNumEntries()
		return C_AuctionHouse.GetNumCommoditySearchResults(itemID);
	end

	local function CommoditiesListHasFullResults()
		return C_AuctionHouse.HasFullCommoditySearchResults(itemID);
	end

	self:SetDataProvider(CommoditiesListSearchStarted, CommoditiesListGetEntry, CommoditiesListGetNumEntries, CommoditiesListHasFullResults);
end

function AuctionHouseCommoditiesListMixin:RefreshScrollFrame()
	AuctionHouseItemListMixin.RefreshScrollFrame(self);

	if not self.isInitialized or not self.itemID then
		return;
	end

	self:GetAuctionHouseFrame():TriggerEvent(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, self.quantitySelected);

	if C_AuctionHouse.HasFullCommoditySearchResults(self.itemID) then
		return;
	end

	local numEntries = C_AuctionHouse.GetNumCommoditySearchResults(self.itemID);
	if numEntries > 0 and (numEntries - self.ScrollBox:GetDataIndexEnd() < COMMODITIES_LIST_SCROLL_OFFSET_REFRESH_THRESHOLD) then
		C_AuctionHouse.RequestMoreCommoditySearchResults(self.itemID);
	end
end


AuctionHouseCommoditiesBuyListMixin = CreateFromMixins(AuctionHouseCommoditiesListMixin);

function AuctionHouseCommoditiesBuyListMixin:OnLoad()
	AuctionHouseItemListMixin.OnLoad(self);
	
	local function CommoditiesListGetTotalQuantity()
		return self.itemID and C_AuctionHouse.GetCommoditySearchResultsQuantity(self.itemID) or 0;
	end

	local function CommoditiesListRefreshResults()
		self.resultsLoaded = false;
		self:GetParent().BuyDisplay.resultsLoaded = false;

		if self.itemID then
			self:GetAuctionHouseFrame():RefreshSearchResults(self.searchContext, C_AuctionHouse.MakeItemKey(self.itemID));
		end
	end
	self:SetRefreshFrameFunctions(CommoditiesListGetTotalQuantity, CommoditiesListRefreshResults);

	self:SetTableBuilderLayout(AuctionHouseTableBuilder.GetCommoditiesBuyListLayout(self));
	self.quantitySelected = 1;

	self.getEntryInfoCallback = function(index)
		return C_AuctionHouse.GetCommoditySearchResultInfo(self.itemID, index);
	end

	self.ScrollBox:SetPoint("TOPLEFT", self.HeaderContainer, "TOPLEFT", 0, -6);
end

function AuctionHouseCommoditiesBuyListMixin:OnEnterListLine(line, rowData)
	if rowData.containsOwnerItem then
		GameTooltip:SetOwner(line, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, AUCTION_HOUSE_OWNED_COMMODITIES_LINE_TOOLTIP_TITLE);
		GameTooltip_AddNormalLine(GameTooltip, AUCTION_HOUSE_OWNED_COMMODITIES_LINE_TOOLTIP_TEXT);
		GameTooltip:Show();
	end
end

function AuctionHouseCommoditiesBuyListMixin:OnLeaveListLine(line, rowData)
	GameTooltip:Hide();
end

function AuctionHouseCommoditiesBuyListMixin:UpdateDynamicCallbacks()
	-- These callbacks are based on quantity selected and need to be reset when the quantity selection changes.

	-- Also note that because commodities are selected and highlighted in order, the later results depend
	-- on the earlier ones, so these callbacks also need to be reset when the scroll frame is refreshed.

	self:UpdateListHighlightCallback();
end

function AuctionHouseCommoditiesBuyListMixin:UpdateListHighlightCallback()
	if not self.quantitySelected or self.quantitySelected == 0 then
		self:SetHighlightCallback(nil);
	else
		self:SetHighlightCallback(function(currentRowData, selectedRowData, currentRowIndex)
			local shouldHighlight = currentRowIndex <= (self.resultsMaxHighlightIndex or 0);
			local highlightAlpha = (currentRowData.containsOwnerItem or currentRowData.containsAccountItem or 
					(currentRowIndex == self.resultsMaxHighlightIndex and self.resultsPartiallyPurchased)) and 0.5 or 1.0;
			return shouldHighlight, highlightAlpha;
		end);
	end
end

function AuctionHouseCommoditiesBuyListMixin:SetQuantitySelected(quantity)
	local canUseSearchResults = self.itemID and C_AuctionHouse.HasSearchResults(C_AuctionHouse.MakeItemKey(self.itemID)) and self.resultsLoaded;
	local oldQuantitySelected = self.quantitySelected;
	self.quantitySelected = quantity;
	if canUseSearchResults then
		local totalItemQuantity = C_AuctionHouse.GetCommoditySearchResultsQuantity(self.itemID);
		self.quantitySelected = math.min(totalItemQuantity, quantity);
	else 
		return;
	end

	if self.resultsMaxHighlightIndex == nil or oldQuantitySelected ~= self.quantitySelected then
		self.resultsMaxHighlightIndex, self.resultsPartiallyPurchased = select(3, AuctionHouseUtil.AggregateSearchResultsByQuantity(self.itemID, self.quantitySelected));
		if self.ScrollBox:HasView() and self.ScrollBox:HasDataProvider() then
			local scrollIndex = math.min(self.ScrollBox:GetDataProviderSize(), self.resultsMaxHighlightIndex + MINIMUM_UNSELECTED_ENTRIES);
			self.ScrollBox:ScrollToElementDataIndex(scrollIndex, ScrollBoxConstants.AlignEnd, ScrollBoxConstants.NoScrollInterpolation);
		end

		self:UpdateDynamicCallbacks();
		self:DirtyScrollFrame();
	elseif self.resultsLoaded then
		self.resultsMaxHighlightIndex, self.resultsPartiallyPurchased = select(3, AuctionHouseUtil.AggregateSearchResultsByQuantity(self.itemID, self.quantitySelected));
	end
end

function AuctionHouseCommoditiesBuyListMixin:OnShow()
	AuctionHouseCommoditiesListMixin.OnShow(self);

	self:GetAuctionHouseFrame():RegisterCallback(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, self.OnCommoditiesQuantitySelectionChanged, self);
end

function AuctionHouseCommoditiesBuyListMixin:OnHide()
	AuctionHouseCommoditiesListMixin.OnHide(self);

	self:GetAuctionHouseFrame():UnregisterCallback(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, self);
end

function AuctionHouseCommoditiesBuyListMixin:OnCommoditiesQuantitySelectionChanged(quantity)
	self:SetQuantitySelected(quantity);
end

function AuctionHouseCommoditiesBuyListMixin:SetItemID(itemID)
	AuctionHouseCommoditiesListMixin.SetItemID(self, itemID);

	self.resultsMaxHighlightIndex = nil;
	self:SetQuantitySelected(1);
end

function AuctionHouseCommoditiesBuyListMixin:UpdateDataProvider() -- Overrides AuctionHouseCommoditiesListMixin
	local itemID = self.itemID;

	local function CommoditiesBuyListSearchStarted()
		return itemID ~= nil;
	end

	local function CommoditiesBuyListGetEntry(index)
		return self.getEntryInfoCallback(index);
	end

	local function CommoditiesBuyListGetNumEntries()
		return C_AuctionHouse.GetNumCommoditySearchResults(itemID);
	end

	local function CommoditiesBuyListHasFullResults()
		return C_AuctionHouse.HasFullCommoditySearchResults(itemID);
	end

	self:SetDataProvider(CommoditiesBuyListSearchStarted, CommoditiesBuyListGetEntry, CommoditiesBuyListGetNumEntries, CommoditiesBuyListHasFullResults);
end

function AuctionHouseCommoditiesBuyListMixin:GetAuctionHouseFrame() -- Overrides AuctionHouseCommoditiesListMixin
	return self:GetParent():GetAuctionHouseFrame();
end

function AuctionHouseCommoditiesBuyListMixin:RefreshScrollFrame()
	self:UpdateDynamicCallbacks();

	AuctionHouseCommoditiesListMixin.RefreshScrollFrame(self);
end


AuctionHouseCommoditiesSellListMixin = CreateFromMixins(AuctionHouseCommoditiesListMixin);

function AuctionHouseCommoditiesSellListMixin:OnLoad()
	AuctionHouseCommoditiesListMixin.OnLoad(self);

	self:SetTableBuilderLayout(AuctionHouseTableBuilder.GetCommoditiesSellListLayout(self, self));

	self:SetHighlightCallback(function(currentRowData, selectedRowData)
		return selectedRowData and currentRowData.unitPrice == selectedRowData.unitPrice;
	end);
end
