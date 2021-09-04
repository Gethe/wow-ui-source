
local BIDS_TAB_ID = 2;


AuctionHouseAuctionsFrameTabMixin = {};

function AuctionHouseAuctionsFrameTabMixin:OnClick()
	AuctionHouseFrameTopTabMixin.OnClick(self);

	self:GetParent():SetTab(self:GetID());
end


AuctionHouseAuctionsSummaryListMixin = {};

function AuctionHouseAuctionsSummaryListMixin:OnLoad()
	AuctionHouseBackgroundMixin.OnLoad(self);

	self.InsetFrame:Hide();

	local selectedHighlight = self:GetSelectedHighlight();
	selectedHighlight:SetAtlas("auctionhouse-ui-row-select", true);
	selectedHighlight:SetBlendMode("ADD");
	selectedHighlight:SetAlpha(0.8);
end


AuctionHouseAuctionsSummaryLineMixin = {};

function AuctionHouseAuctionsSummaryLineMixin:InitElement(auctionsFrame)
	self.auctionsFrame = auctionsFrame;
end

function AuctionHouseAuctionsSummaryLineMixin:OnLoad()
	self:SetNormalTexture(nil);
	self.Text:ClearAllPoints();
	self.Text:SetPoint("LEFT", self.Icon, "RIGHT", 4, 0);
	self.Text:SetPoint("RIGHT", -4, 0);
	self.Text:SetFontObject(Number13FontYellow);
end

function AuctionHouseAuctionsSummaryLineMixin:OnEvent(event, ...)
	if event == "ITEM_KEY_ITEM_INFO_RECEIVED" then
		local itemID = ...;
		if itemID == self.pendingItemID then
			self:UpdateDisplay();
		end
	end
end

function AuctionHouseAuctionsSummaryLineMixin:OnHide()
	self:UnregisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
end

function AuctionHouseAuctionsSummaryLineMixin:SetIconShown(shown)
	self.Icon:SetShown(shown);
	self.IconBorder:SetShown(shown);
end

function AuctionHouseAuctionsSummaryLineMixin:UpdateDisplay()
	self:SetIconShown(false);

	local listIndex = self:GetListIndex();
	local isDisplayingBids = self.auctionsFrame:IsDisplayingBids();
	if listIndex == 1 then
		self.Text:SetText(isDisplayingBids and AUCTION_HOUSE_ALL_BIDS or AUCTION_HOUSE_ALL_AUCTIONS);
		self.Text:SetPoint("LEFT", 4, 0);
	else
		self.Text:SetPoint("LEFT", self.Icon, "RIGHT", 4, 0);

		local typeIndex = listIndex - 1;
		local itemKey = isDisplayingBids and C_AuctionHouse.GetBidType(typeIndex) or C_AuctionHouse.GetOwnedAuctionType(typeIndex);
		local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
		if not itemKeyInfo then
			self.pendingItemID = itemKey.itemID;
			self:RegisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
			self.Text:SetText("");
			return;
		end

		self:SetIconShown(true);
		self.Icon:SetTexture(itemKeyInfo.iconFileID);
		self.Text:SetText(AuctionHouseUtil.GetItemDisplayTextFromItemKey(itemKey, itemKeyInfo));
	end

	if self.pendingItemID ~= nil then
		self:UnregisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
		self.pendingItemID = nil;
	end
end


AuctionHouseBidsSummaryLineMixin = {};

function AuctionHouseBidsSummaryLineMixin:OnEvent(event, ...)
	if event == "ITEM_KEY_ITEM_INFO_RECEIVED" then
		local itemID = ...;
		if itemID == self.pendingItemID then
			self:UpdateDisplay();
		end
	end
end

function AuctionHouseBidsSummaryLineMixin:OnHide()
	self:UnregisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
end

function AuctionHouseBidsSummaryLineMixin:UpdateDisplay()
	local listIndex = self:GetListIndex();
	if listIndex == 1 then
		self.Text:SetText(AUCTION_HOUSE_ALL_BIDS);
	else
		local typeOffset = listIndex - 1;
		local itemKey = C_AuctionHouse.GetBidType(typeOffset);
		local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
		if not itemKeyInfo then
			self.pendingItemID = itemKey.itemID;
			self:RegisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
			self.Text:SetText("");
			return;
		end

		self.Text:SetText(AuctionHouseUtil.GetItemDisplayTextFromItemKey(itemKey, itemKeyInfo));
	end

	if self.pendingItemID ~= nil then
		self:UnregisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
		self.pendingItemID = nil;
	end
end


CancelAuctionButtonMixin = {};

function CancelAuctionButtonMixin:OnClick()
	local auctionsFrame = self:GetParent();
	auctionsFrame:CancelSelectedAuction();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end


AuctionHouseAuctionsFrameMixin = CreateFromMixins(AuctionHouseBuySystemMixin, AuctionHouseSortOrderSystemMixin);

local AUCTIONS_FRAME_EVENTS = {
	"OWNED_AUCTIONS_UPDATED",
	"ITEM_SEARCH_RESULTS_UPDATED",
	"ITEM_SEARCH_RESULTS_ADDED",
	"BIDS_UPDATED",
	"BID_ADDED",
	"AUCTION_CANCELED",
	"AUCTION_HOUSE_NEW_BID_RECEIVED",
};

local AuctionsFrameDisplayMode = {
	AllAuctions = 1,
	BidsList = 2,
	Item = 3,
	Commodity = 4,
};

function AuctionHouseAuctionsFrameMixin:OnLoad()
	AuctionHouseBuySystemMixin.OnLoad(self);
	AuctionHouseSortOrderSystemMixin.OnLoad(self);

	self.numTabs = 2;
	self:SetTab(1);

	self.ItemDisplay:SetAuctionHouseFrame(self:GetAuctionHouseFrame());

	self:InitializeSummaryList();
	self:InitializeAllAuctionsList();
	self:InitializeBidsList();
	self:InitializeItemList();
	self:InitializeCommoditiesList();

	self:SetDisplayMode(AuctionsFrameDisplayMode.AllAuctions);
end

function AuctionHouseAuctionsFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, AUCTIONS_FRAME_EVENTS);

	-- AllBids and AllAuctions will update the entire list. Other views require
	-- and explicit update.
	local displayMode = self:GetDisplayMode();
	if displayMode ~= AuctionsFrameDisplayMode.BidsList and displayMode ~= AuctionsFrameDisplayMode.AllAuctions then
		self:RefreshSeachResults();
	end
end

function AuctionHouseAuctionsFrameMixin:RefreshSeachResults()
	local displayMode = self:GetDisplayMode();
	if self:IsDisplayingBids() then
		self:GetAuctionHouseFrame():QueryAll(AuctionHouseSearchContext.AllBids);
	else
		self:GetAuctionHouseFrame():QueryAll(AuctionHouseSearchContext.AllAuctions);
	end

	self:UpdateCancelAuctionButton();
end

function AuctionHouseAuctionsFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, AUCTIONS_FRAME_EVENTS);
end

function AuctionHouseAuctionsFrameMixin:OnEvent(event, ...)
	if event == "OWNED_AUCTIONS_UPDATED" then
		self.AllAuctionsList:SetSelectedEntry(nil);
		self.AllAuctionsList:Reset();
		self.SummaryList:RefreshListDisplay();
		self:ValidateDisplayMode();
	elseif event == "ITEM_SEARCH_RESULTS_UPDATED" then
		self.ItemList:DirtyScrollFrame();
	elseif event == "ITEM_SEARCH_RESULTS_ADDED" then
		self.ItemList:DirtyScrollFrame();
	elseif event == "BIDS_UPDATED" then
		self.BidsList:DirtyScrollFrame();

		if self:IsDisplayingBids() then
			self.SummaryList:RefreshListDisplay();
			self:ValidateDisplayMode();
		end

	elseif event == "BID_ADDED" then
		self.BidsList:DirtyScrollFrame();

		if self:IsDisplayingBids() then
			self.SummaryList:RefreshListDisplay();
		end
	elseif event == "AUCTION_CANCELED" then
		self:RefreshSeachResults();
	elseif event == "AUCTION_HOUSE_NEW_BID_RECEIVED" then
		self:RefreshSeachResults();
	end
end

function AuctionHouseAuctionsFrameMixin:InitializeSummaryList()
	self.SummaryList:SetSelectedListIndex(1);

	local function OnSummaryLineSelectedCallback(...)
		self:OnSummaryLineSelected(...);
	end

	self.SummaryList:SetSelectionCallback(OnSummaryLineSelectedCallback);
	self.SummaryList:SetElementTemplate("AuctionHouseAuctionsSummaryLineTemplate", self);
end

function AuctionHouseAuctionsFrameMixin:InitializeAllAuctionsList()
	self.AllAuctionsList:SetSelectionCallback(AuctionHouseUtil.GenerateRowSelectedCallbackWithInspect(self, self.OnAllAuctionsSearchResultSelected));
	self.AllAuctionsList:SetLineOnEnterCallback(AuctionHouseUtil.LineOnEnterCallback);
	self.AllAuctionsList:SetLineOnLeaveCallback(AuctionHouseUtil.LineOnLeaveCallback);

	self.AllAuctionsList:SetHighlightCallback(function(currentRowData, selectedRowData)
		return selectedRowData and currentRowData.auctionID == selectedRowData.auctionID;
	end);

	self.AllAuctionsList:SetTableBuilderLayout(AuctionHouseTableBuilder.GetAllAuctionsLayout(self, self.AllAuctionsList));

	local function AuctionsSearchStarted()
		return true;
	end

	self.AllAuctionsList:SetDataProvider(AuctionsSearchStarted, C_AuctionHouse.GetOwnedAuctionInfo, C_AuctionHouse.GetNumOwnedAuctions, C_AuctionHouse.HasFullOwnedAuctionResults);

	
	local function AllAuctionsRefreshResults()
		self:GetAuctionHouseFrame():QueryAll(AuctionHouseSearchContext.AllAuctions);
		self.AllAuctionsList:DirtyScrollFrame();
	end

	local AllAuctionsGetTotalQuantity = nil;

	self.AllAuctionsList:SetRefreshFrameFunctions(AllAuctionsGetTotalQuantity, AllAuctionsRefreshResults);
end

function AuctionHouseAuctionsFrameMixin:InitializeBidsList()
	self.BidsList:SetSelectionCallback(AuctionHouseUtil.GenerateRowSelectedCallbackWithInspect(self, self.OnBidsListSearchResultSelected)); 
	self.BidsList:SetLineOnEnterCallback(AuctionHouseUtil.LineOnEnterCallback);
	self.BidsList:SetLineOnLeaveCallback(AuctionHouseUtil.LineOnLeaveCallback);

	self.BidsList:SetHighlightCallback(function(currentRowData, selectedRowData)
		return selectedRowData and currentRowData.auctionID == selectedRowData.auctionID;
	end);

	self.BidsList:SetTableBuilderLayout(AuctionHouseTableBuilder.GetBidsListLayout(self, self.BidsList));

	local function BidsSearchStarted()
		return true;
	end

	self.BidsList:SetDataProvider(BidsSearchStarted, C_AuctionHouse.GetBidInfo, C_AuctionHouse.GetNumBids, C_AuctionHouse.HasFullBidResults);

	
	local function BidsListRefreshResults()
		self:GetAuctionHouseFrame():QueryAll(AuctionHouseSearchContext.AllBids);
		self.BidsList:DirtyScrollFrame();
	end

	local BidsListGetTotalQuantity = nil;

	self.BidsList:SetRefreshFrameFunctions(BidsListGetTotalQuantity, BidsListRefreshResults);
end

function AuctionHouseAuctionsFrameMixin:InitializeItemList()
	self.ItemList:SetTableBuilderLayout(AuctionHouseTableBuilder.GetAuctionsItemListLayout(self, self.ItemList));


	self.ItemList:SetHighlightCallback(function(currentRowData, selectedRowData)
		return selectedRowData and currentRowData.auctionID == selectedRowData.auctionID;
	end);

	self.ItemList:SetSelectionCallback(AuctionHouseUtil.GenerateRowSelectedCallbackWithInspect(self, self.OnItemSearchResultSelected));
	self.ItemList:SetLineOnEnterCallback(AuctionHouseUtil.LineOnEnterCallback);
	self.ItemList:SetLineOnLeaveCallback(AuctionHouseUtil.LineOnLeaveCallback);

	local function AuctionsItemListSearchStarted()
		return self.itemKey ~= nil;
	end

	local function AuctionsItemListGetEntry(index)
		return self.itemKey and C_AuctionHouse.GetItemSearchResultInfo(self.itemKey, index);
	end

	local function AuctionsItemListGetNumEntries()
		return self.itemKey and C_AuctionHouse.GetNumItemSearchResults(self.itemKey) or 0;
	end

	local function AuctionsItemListHasFullResults()
		return self.itemKey == nil or C_AuctionHouse.HasFullItemSearchResults(self.itemKey);
	end

	self.ItemList:SetDataProvider(AuctionsItemListSearchStarted, AuctionsItemListGetEntry, AuctionsItemListGetNumEntries, AuctionsItemListHasFullResults);


	local function AuctionsItemListGetTotalQuantity()
		return self.itemKey and C_AuctionHouse.GetItemSearchResultsQuantity(self.itemKey) or 0;
	end

	local function AuctionsItemListRefreshResults()
		if self.itemKey ~= nil then
			self:GetAuctionHouseFrame():RefreshSearchResults(self:GetSearchContext(), self.itemKey);
		end
	end

	self.ItemList:SetRefreshFrameFunctions(AuctionsItemListGetTotalQuantity, AuctionsItemListRefreshResults);
end

function AuctionHouseAuctionsFrameMixin:InitializeCommoditiesList()
	self.CommoditiesList:SetTableBuilderLayout(AuctionHouseTableBuilder.GetCommoditiesAuctionsListLayout(self, self.CommoditiesList));

	self.CommoditiesList:SetHighlightCallback(function(currentRowData, selectedRowData)
		return selectedRowData and currentRowData.auctionID == selectedRowData.auctionID;
	end);

	self.CommoditiesList:SetSelectionCallback(AuctionHouseUtil.GenerateRowSelectedCallbackWithLink(self, self.OnCommoditySearchResultSelected));

	local function AuctionsCommoditiesList_GetAuctionHouseFrame(commoditiesList)
		return commoditiesList:GetParent():GetAuctionHouseFrame();
	end

	self.CommoditiesList.GetAuctionHouseFrame = AuctionsCommoditiesList_GetAuctionHouseFrame;
end

function AuctionHouseAuctionsFrameMixin:SetItemKey(itemKey)
	self.itemKey = itemKey;
	self.ItemDisplay:SetItemKey(itemKey);
end

function AuctionHouseAuctionsFrameMixin:GetItemKey()
	return self.itemKey;
end

function AuctionHouseAuctionsFrameMixin:SetDisplayMode(displayMode)
	self.displayMode = displayMode;

	local isAllAuctions = displayMode == AuctionsFrameDisplayMode.AllAuctions;
	self.AllAuctionsList:SetShown(isAllAuctions);
	self.AllAuctionsList:SetSelectedEntry(nil);

	local isBidsList = displayMode == AuctionsFrameDisplayMode.BidsList;
	self.BidsList:SetShown(isBidsList);
	self.BidsList:SetSelectedEntry(nil);

	local isItem = displayMode == AuctionsFrameDisplayMode.Item;
	self.ItemList:SetShown(isItem);
	self.ItemList:SetSelectedEntry(nil);

	local isCommodity = displayMode == AuctionsFrameDisplayMode.Commodity;
	self.CommoditiesList:SetShown(isCommodity);
	self.CommoditiesList:SetSelectedEntry(nil);

	self.ItemDisplay:SetShown(not isAllAuctions and not isBidsList);
end

function AuctionHouseAuctionsFrameMixin:ValidateDisplayMode()
	local displayMode = self.displayMode;

	if displayMode == AuctionsFrameDisplayMode.Item or displayMode == AuctionsFrameDisplayMode.Commodity then
		local itemKey = self:GetItemKey();
		if self:IsDisplayingBids() then
			local hasType, typeIndex = AuctionHouseUtil.HasBidType(itemKey);
			self.SummaryList:SetSelectedListIndex(hasType and (typeIndex + 1) or 1);
		else
			local hasType, typeIndex = AuctionHouseUtil.HasOwnedAuctionType(itemKey);
			self.SummaryList:SetSelectedListIndex(hasType and (typeIndex + 1) or 1);
		end
	end
end

function AuctionHouseAuctionsFrameMixin:GetDisplayMode()
	return self.displayMode;
end

function AuctionHouseAuctionsFrameMixin:OnSummaryLineSelected(...)
	if self:IsDisplayingBids() then
		self:OnBidSummaryLineSelected(...);
	else
		self:OnAuctionSummaryLineSelected(...);
	end
end

function AuctionHouseAuctionsFrameMixin:OnAuctionSummaryLineSelected(listIndex)
	if listIndex == 1 then
		self:SetItemKey(nil);
		self:SetDisplayMode(AuctionsFrameDisplayMode.AllAuctions);
	else
		local typeIndex = listIndex - 1;
		local itemKey = C_AuctionHouse.GetOwnedAuctionType(typeIndex);
		self:SelectItemKey(itemKey);
	end
end

function AuctionHouseAuctionsFrameMixin:OnBidSummaryLineSelected(listIndex)
	if listIndex == 1 then
		self:SetItemKey(nil);
		self:SetDisplayMode(AuctionsFrameDisplayMode.BidsList);
	else
		local typeIndex = listIndex - 1;
		local itemKey = C_AuctionHouse.GetBidType(typeIndex);
		self:SelectItemKey(itemKey);
	end
end

function AuctionHouseAuctionsFrameMixin:GetSearchContext(displayMode)
	displayMode = displayMode or self:GetDisplayMode();
	if displayMode == AuctionsFrameDisplayMode.Item then
		if self:IsDisplayingBids() then
			return AuctionHouseSearchContext.BidItems;
		else
			return AuctionHouseSearchContext.AuctionsItems;
		end
	elseif displayMode == AuctionsFrameDisplayMode.Commodity then
		return AuctionHouseSearchContext.AuctionsCommodities;
	elseif displayMode == AuctionsFrameDisplayMode.AllAuctions then
		return AuctionHouseSearchContext.AllAuctions;
	elseif displayMode == AuctionsFrameDisplayMode.BidsList then
		return AuctionHouseSearchContext.AllBids;
	end
end

function AuctionHouseAuctionsFrameMixin:SelectItemKey(itemKey)
	local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
	if not itemKeyInfo then
		return;
	end

	self:SetItemKey(itemKey);

	if itemKeyInfo.isCommodity then
		self.CommoditiesList:SetItemID(itemKey.itemID);
	end

	local newDisplayMode = itemKeyInfo.isCommodity and AuctionsFrameDisplayMode.Commodity or AuctionsFrameDisplayMode.Item;
	local displayMode = self:GetDisplayMode();
	if newDisplayMode == displayMode then
		-- If we're switching display modes, the OnShow will automatically force a refresh. If not, we need to do it manually here.
		self:GetAuctionHouseFrame():QueryItem(self:GetSearchContext(newDisplayMode), itemKey);
	end

	self:SetDisplayMode(newDisplayMode);
end

function AuctionHouseAuctionsFrameMixin:SelectAuction(searchResult)
	self.selectedAuctionID = searchResult and searchResult.auctionID or nil;
	self:UpdateCancelAuctionButton(searchResult);
end

function AuctionHouseAuctionsFrameMixin:UpdateCancelAuctionButton(searchResult)
	self.CancelAuctionButton:SetEnabled(self.selectedAuctionID ~= nil and (self.selectedAuctionID > 0) and (searchResult and searchResult.status ~= Enum.AuctionStatus.Sold));
end

function AuctionHouseAuctionsFrameMixin:OnAllAuctionsSearchResultSelected(ownedAuctionInfo)
	self:SelectAuction(ownedAuctionInfo);
end

function AuctionHouseAuctionsFrameMixin:OnBidsListSearchResultSelected(bidInfo)
	if bidInfo then
		local isOwnerItem = false;
		self:SetAuction(bidInfo.auctionID, bidInfo.minBid, bidInfo.buyoutAmount, isOwnerItem, bidInfo.bidder);
	else
		self:SetAuction(nil);
	end
end

function AuctionHouseAuctionsFrameMixin:OnItemSearchResultSelected(itemSearchResultInfo)
	if itemSearchResultInfo then
		if itemSearchResultInfo.containsOwnerItem then
			self:SelectAuction(itemSearchResultInfo);
			self:SetAuction(nil);
		else
			self:SetAuction(itemSearchResultInfo.auctionID, itemSearchResultInfo.minBid, itemSearchResultInfo.buyoutAmount, AuctionHouseUtil.IsOwnedAuction(itemSearchResultInfo), itemSearchResultInfo.bidder);
		end
	else
		self:SelectAuction(nil);
		self:SetAuction(nil);
	end
end

function AuctionHouseAuctionsFrameMixin:OnCommoditySearchResultSelected(commoditySearchResultInfo)
	if commoditySearchResultInfo and commoditySearchResultInfo.containsOwnerItem then
		self:SelectAuction(commoditySearchResultInfo);
	else
		self:SelectAuction(nil);
	end
end

function AuctionHouseAuctionsFrameMixin:CancelSelectedAuction()
	StaticPopup_Show("CANCEL_AUCTION", nil, nil, { auctionID = self.selectedAuctionID });
end

function AuctionHouseAuctionsFrameMixin:GetTab()
	return PanelTemplates_GetSelectedTab(self);
end

function AuctionHouseAuctionsFrameMixin:SetTab(tabID)
	if self:GetTab() == tabID then
		return;
	end

	PanelTemplates_SetTab(self, tabID);

	local isDisplayingBids = self:IsDisplayingBids();
	
	self.CancelAuctionButton:SetShown(not isDisplayingBids);
	self.BidFrame:SetShown(isDisplayingBids);
	self.BuyoutFrame:SetShown(isDisplayingBids);

	if isDisplayingBids then
		self:SetDisplayMode(AuctionsFrameDisplayMode.BidsList);

		local function GetNumBidSummaryResults()
			return C_AuctionHouse.GetNumBidTypes() + 1;
		end

		self.SummaryList:SetGetNumResultsFunction(GetNumBidSummaryResults);
	else
		self:SetDisplayMode(AuctionsFrameDisplayMode.AllAuctions);
		
		local function GetNumOwnedAuctionSummaryResults()
			return C_AuctionHouse.GetNumOwnedAuctionTypes() + 1;
		end

		self.SummaryList:SetGetNumResultsFunction(GetNumOwnedAuctionSummaryResults);
	end

	self.SummaryList:SetSelectedListIndex(1);
end

function AuctionHouseAuctionsFrameMixin:IsDisplayingBids()
	return self:GetTab() == BIDS_TAB_ID;
end
