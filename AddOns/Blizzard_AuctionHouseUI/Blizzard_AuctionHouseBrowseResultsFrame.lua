
local BROWSE_SCROLL_OFFSET_REFRESH_THRESHOLD = 30;


AuctionHouseBrowseResultsFrameMixin = CreateFromMixins(AuctionHouseSortOrderSystemMixin);

-- These events are registered in OnLoad, as the browse results can be updated
-- when the player retrieves specific item and commodity results.
local AUCTION_HOUSE_BROWSE_RESULTS_FRAME_EVENTS = {
	"AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
	"AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
	"AUCTION_HOUSE_BROWSE_FAILURE",
};

function AuctionHouseBrowseResultsFrameMixin:SetupTableBuilder(extraColumnInfo, sortable, ...)
	self.ItemList:SetTableBuilderLayout(AuctionHouseTableBuilder.GetBrowseListLayout(self, self.ItemList, extraColumnInfo, sortable, ...));

	self.tableBuilderLayoutDirty = false;
end

function AuctionHouseBrowseResultsFrameMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_BROWSE_RESULTS_FRAME_EVENTS);
	
	AuctionHouseSortOrderSystemMixin.OnLoad(self);

	local scrollFrame = self.ItemList.ScrollFrame;

	self.ItemList:SetLineTemplate("AuctionHouseFavoritableLineTemplate", self:GetAuctionHouseFrame():GetFavoriteDropDown(), AuctionHouseFavoriteDropDownLineCallback);

	self.ItemList:SetSelectionCallback(function(browseResult)
		self:OnBrowseResultSelected(browseResult);
		return false; -- browse lines are never selected.
	end);

	self.ItemList:SetLineOnEnterCallback(AuctionHouseUtil.LineOnEnterCallback);
	self.ItemList:SetLineOnLeaveCallback(AuctionHouseUtil.LineOnLeaveCallback);

	local extraInfoColumn = nil;
	self:SetupTableBuilder(extraInfoColumn);

	local function BrowseListSearchStarted()
		return self.searchStarted, AUCTION_HOUSE_BROWSE_FAVORITES_TIP;
	end

	local function BrowseListGetNumEntries()
		return #self.browseResults; -- Implemented in-line instead of using GetNumBrowseResults for performance.
	end

	local function BrowseListGetEntry(index)
		return self.browseResults[index];
	end

	self.ItemList:SetDataProvider(BrowseListSearchStarted, BrowseListGetEntry, BrowseListGetNumEntries, C_AuctionHouse.HasFullBrowseResults);

	self:Reset();

	self.categorySelectedCallback = function (event, ...)
		self:OnCategorySelected(...);
	end;

	self.browseSearchStartedCallback = function ()
		self.searchStarted = true;
		self.browseResults = {};
		self.ItemList:DirtyScrollFrame();
	end;

	-- If the player has favorites, an automatic search will be started immediately. This is required because
	-- when the addon is loaded, the AuctionHouseFrame on show is called first. All other times the auction house
	-- is opened, the BrowseResultsFrame will have on show called first and register for the browse search started event first.
	self.searchStarted = C_AuctionHouse.HasFavorites();
end

function AuctionHouseBrowseResultsFrameMixin:OnShow()
	self.ItemList:RefreshScrollFrame();

	self:GetAuctionHouseFrame():RegisterCallback(AuctionHouseFrameMixin.Event.CategorySelected, self.categorySelectedCallback);
	self:GetAuctionHouseFrame():RegisterCallback(AuctionHouseFrameMixin.Event.BrowseSearchStarted, self.browseSearchStartedCallback);
end

function AuctionHouseBrowseResultsFrameMixin:OnHide()
	self:GetAuctionHouseFrame():UnregisterCallback(AuctionHouseFrameMixin.Event.CategorySelected, self.categorySelectedCallback);
	self:GetAuctionHouseFrame():UnregisterCallback(AuctionHouseFrameMixin.Event.BrowseSearchStarted, self.browseSearchStartedCallback);
end

function AuctionHouseBrowseResultsFrameMixin:OnEvent(event, ...)
	if event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
		self:UpdateBrowseResults();
	elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
		local addedBrowseResults = ...;
		self:UpdateBrowseResults(addedBrowseResults);
	elseif event == "AUCTION_HOUSE_BROWSE_FAILURE" then
		self.ItemList:SetCustomError(RED_FONT_COLOR:WrapTextInColorCode(ERR_AUCTION_DATABASE_ERROR));
	end
end

function AuctionHouseBrowseResultsFrameMixin:Reset()
	self.browseResults = {};
	self.sortOrder = nil;
	self.isSortOrderReversed = false;
	self.searchStarted = false;
end

function AuctionHouseBrowseResultsFrameMixin:OnCategorySelected(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)
	local extraColumnInfo = AuctionFrame_GetDetailColumnStringUnsafe(selectedCategoryIndex, selectedSubCategoryIndex);
	local sortable = not AuctionFrame_DoesCategoryHaveFlag("UNSORTABLE", selectedCategoryIndex);
	self.pendingExtraColumnInfo = { extraColumnInfo, sortable, };
	self.tableBuilderLayoutDirty = true;
end

function AuctionHouseBrowseResultsFrameMixin:UpdateBrowseResults(addedBrowseResults)
	self.searchStarted = true;

	if self.tableBuilderLayoutDirty then
		if self.pendingExtraColumnInfo then
			self:SetupTableBuilder(unpack(self.pendingExtraColumnInfo));
		else
			self:SetupTableBuilder(nil);
		end

		self.pendingExtraColumnInfo = nil;
	end
	
	if addedBrowseResults then
		tAppendAll(self.browseResults, addedBrowseResults);
	else
		self.browseResults = C_AuctionHouse.GetBrowseResults();
	end

	if C_AuctionHouse.HasFullBrowseResults() then
		self.ItemList:SetRefreshCallback(nil);
	else
		local function ItemListRefreshCallback(lastDisplayEntry)
			if C_AuctionHouse.HasFullBrowseResults() then
				self.ItemList:SetRefreshCallback(nil);
			elseif self:GetNumBrowseResults() - lastDisplayEntry < BROWSE_SCROLL_OFFSET_REFRESH_THRESHOLD then
				C_AuctionHouse.RequestMoreBrowseResults();
			end
		end

		self.ItemList:SetRefreshCallback(ItemListRefreshCallback);
	end

	if addedBrowseResults then
		self.ItemList:DirtyScrollFrame();
	else
		self.ItemList:Reset();
	end
end

function AuctionHouseBrowseResultsFrameMixin:GetNumBrowseResults()
	return #self.browseResults;
end

function AuctionHouseBrowseResultsFrameMixin:SetSortOrder(sortOrder)
	self:GetAuctionHouseFrame():SetBrowseSortOrder(sortOrder);
	self:UpdateHeaders();
end

function AuctionHouseBrowseResultsFrameMixin:GetSortOrderState(sortOrder)
	return self:GetAuctionHouseFrame():GetBrowseSortOrderState(sortOrder);
end

function AuctionHouseBrowseResultsFrameMixin:OnBrowseResultSelected(browseResult)
	if IsModifiedClick("DRESSUP") then
		if browseResult.appearanceLink then
			local _, _, hyperlinkString = ExtractHyperlinkString(browseResult.appearanceLink);
			DressUpTransmogLink(hyperlinkString);
		else
			local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(browseResult.itemKey);
			if itemKeyInfo and itemKeyInfo.battlePetLink then
				DressUpBattlePetLink(itemKeyInfo.battlePetLink);
			else
				local _, itemLink = GetItemInfo(browseResult.itemKey.itemID);
				DressUpLink(itemLink);
			end
		end
	else
		self:GetAuctionHouseFrame():SelectBrowseResult(browseResult);
	end
end
