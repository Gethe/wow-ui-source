
local RED_TEXT_MINUTES_THRESHOLD = 60;

AuctionHouseSearchContext = tInvert({
	"BrowseAll",
	"BrowseTradeGoods",
	"BrowseArmor",
	"BrowseWeapons",
	"BrowseConsumables",
	"BrowseItemEnhancements",
	"BrowseGems",
	"BrowseBattlePets",
	"BrowseRecipes",
	"BrowseQuestItems",
	"BrowseContainers",
	"BrowseGlpyhs",
	"BrowseMiscellaneous",

	"BuyItems",
	"BuyCommodities",
	"SellItems",
	"SellCommodities",
	"AuctionsItems",
	"AuctionsCommodities",
	"BidItems",

	"AllFavorites",
	"AllAuctions",
	"AllBids",
});


AuctionHouseBidStatus = {
	NoBid = 1,
	PlayerBid = 2,
	PlayerOutbid = 3,
	OtherBid = 4,
};


AuctionHouseSystemMixin = {};

function AuctionHouseSystemMixin:GetAuctionHouseFrame()
	return self:GetParent();
end


AuctionHouseSortOrderSystemMixin = CreateFromMixins(AuctionHouseSystemMixin);

function AuctionHouseSortOrderSystemMixin:OnLoad()
	self.headers = {};
end

function AuctionHouseSortOrderSystemMixin:GetSortOrderState(sortOrder)
	local searchContext = self:GetSearchContext();
	if not searchContext then
		return;
	end

	return self:GetAuctionHouseFrame():GetSortOrderState(searchContext, sortOrder);
end

function AuctionHouseSortOrderSystemMixin:SetSortOrder(sortOrder)
	local searchContext = self:GetSearchContext();
	if not searchContext then
		return;
	end

	self:GetAuctionHouseFrame():SetSortOrder(searchContext, sortOrder);

	self:UpdateHeaders();
end

function AuctionHouseSortOrderSystemMixin:UpdateHeaders()
	for i, header in ipairs(self.headers) do
		header:UpdateArrow();
	end
end

function AuctionHouseSortOrderSystemMixin:RegisterHeader(header)
	table.insert(self.headers, header);
end

function AuctionHouseSortOrderSystemMixin:SetSearchContext(searchContext)
	self.searchContext = searchContext;
end

function AuctionHouseSortOrderSystemMixin:GetSearchContext()
	return self.searchContext;
end


AuctionHouseBuySystemMixin = CreateFromMixins(AuctionHouseSystemMixin);

function AuctionHouseBuySystemMixin:OnLoad()
	assert(self.BidFrame and self.BuyoutFrame, "This mixin requires both a BidFrame and a BuyoutFrame.");
	self.BidFrame:SetBidCallback(function ()
		self:PlaceBid();
	end);


	self.BuyoutFrame:SetBuyoutCallback(function ()
		self:BuyoutItem();
	end);
end

function AuctionHouseBuySystemMixin:PlaceBid()
	if not self.auctionID then
		return;
	end

	local bidAmount = self.BidFrame:GetPrice();
	if bidAmount < self.minBid then
		UIErrorsFrame:AddExternalErrorMessage(AUCTION_HOUSE_BID_AMOUNT_IS_TOO_LOW);
	elseif self:GetBuyoutAmount() ~= 0 and bidAmount >= self:GetBuyoutAmount() then
		self:BuyoutItem();
	else
		self:GetAuctionHouseFrame():StartItemBid(self.auctionID, bidAmount);
	end
end

function AuctionHouseBuySystemMixin:BuyoutItem()
	if self.auctionID then
		self:GetAuctionHouseFrame():StartItemBuyout(self.auctionID, self:GetBuyoutAmount());
	end
end

function AuctionHouseBuySystemMixin:SetAuctionID(auctionID)
	self.auctionID = auctionID;
end

function AuctionHouseBuySystemMixin:SetPrice(minBid, buyoutPrice, isOwnerItem)
	minBid = minBid or 0;
	buyoutPrice = buyoutPrice or 0;

	self.minBid = minBid;
	self.BidFrame:SetPrice(minBid, isOwnerItem);
	self.BuyoutFrame:SetPrice(buyoutPrice, isOwnerItem);
end

function AuctionHouseBuySystemMixin:SetAuction(auctionID, minBid, buyoutPrice, isOwnerItem)
	self:SetAuctionID(auctionID);
	self:SetPrice(minBid, buyoutPrice, isOwnerItem);
end

function AuctionHouseBuySystemMixin:ResetPrice()
	self:SetPrice(0);
end

function AuctionHouseBuySystemMixin:GetBidAmount()
	return self.BidFrame:GetPrice()
end

function AuctionHouseBuySystemMixin:GetBuyoutAmount()
	return self.BuyoutFrame:GetPrice()
end


AuctionHouseUtil = {};

function AuctionHouseUtil.ConvertCategoryToSearchContext(selectedCategoryIndex)
	if selectedCategoryIndex == nil then
		return AuctionHouseSearchContext.BrowseAll;
	end

	local categoryName = AuctionCategories[selectedCategoryIndex].name;
	if categoryName == AUCTION_CATEGORY_WEAPONS then
		return AuctionHouseSearchContext.BrowseWeapons;
	elseif categoryName == AUCTION_CATEGORY_ARMOR then
		return AuctionHouseSearchContext.BrowseArmor;
	elseif categoryName == AUCTION_CATEGORY_CONTAINERS then
		return AuctionHouseSearchContext.BrowseContainers;
	elseif categoryName == AUCTION_CATEGORY_GEMS then
		return AuctionHouseSearchContext.BrowseGems;
	elseif categoryName == AUCTION_CATEGORY_ITEM_ENHANCEMENT then
		return AuctionHouseSearchContext.BrowseItemEnhancements;
	elseif categoryName == AUCTION_CATEGORY_CONSUMABLES then
		return AuctionHouseSearchContext.BrowseConsumables;
	elseif categoryName == AUCTION_CATEGORY_GLYPHS then
		return AuctionHouseSearchContext.BrowseGlpyhs;
	elseif categoryName == AUCTION_CATEGORY_TRADE_GOODS then
		return AuctionHouseSearchContext.BrowseTradeGoods;
	elseif categoryName == AUCTION_CATEGORY_RECIPES then
		return AuctionHouseSearchContext.BrowseRecipes;
	elseif categoryName == AUCTION_CATEGORY_BATTLE_PETS then
		return AuctionHouseSearchContext.BrowseBattlePets;
	elseif categoryName == AUCTION_CATEGORY_QUEST_ITEMS then
		return AuctionHouseSearchContext.BrowseQuestItems;
	elseif categoryName == AUCTION_CATEGORY_MISCELLANEOUS then
		return AuctionHouseSearchContext.BrowseMiscellaneous;
	end
end

function AuctionHouseUtil.AggregateSearchResults(itemID, numSearchResults)
	numSearchResults = numSearchResults or C_AuctionHouse.GetNumCommoditySearchResults(itemID);

	local totalQuantity = 0;
	local totalPrice = 0;
	for searchResultIndex = 1, numSearchResults do
		local searchResult = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, searchResultIndex);
		if searchResult then
			local quantityAvailable = searchResult.quantity - searchResult.numOwnerItems;
			totalQuantity = totalQuantity + quantityAvailable;
			totalPrice = totalPrice + (searchResult.unitPrice * quantityAvailable);
		end
	end

	return totalQuantity, totalPrice;
end

function AuctionHouseUtil.AggregateSearchResultsByQuantity(itemID, quantity)
	local remainingQuantity = quantity;
	local totalQuantity = 0;
	local totalPrice = 0;
	local numResultsAggregated = 0;
	for searchResultIndex = 1, C_AuctionHouse.GetNumCommoditySearchResults(itemID) do
		numResultsAggregated = numResultsAggregated + 1;
		local searchResult = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, searchResultIndex);
		if searchResult then
			local quantityAvailable = searchResult.quantity - searchResult.numOwnerItems;
			local quantityToBuy = math.min(quantityAvailable, remainingQuantity);
			totalPrice = totalPrice + (searchResult.unitPrice * quantityToBuy);
			totalQuantity = totalQuantity + quantityToBuy;
			remainingQuantity = remainingQuantity - quantityToBuy;
			if remainingQuantity <= 0 then
				break;
			end
		end
	end

	return totalQuantity, totalPrice, numResultsAggregated;
end

function AuctionHouseUtil.AggregateCommoditySearchResultsByMaxPrice(itemID, maxPrice)
	local totalQuantity = 0;
	local totalPrice = 0;
	for searchResultIndex = 1, C_AuctionHouse.GetNumCommoditySearchResults(itemID) do
		local searchResult = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, searchResultIndex);
		if not searchResult or searchResult.unitPrice > maxPrice then
			break;
		end

		local quantityAvailable = searchResult.quantity - searchResult.numOwnerItems;
		totalPrice = totalPrice + (searchResult.unitPrice * quantityAvailable);
		totalQuantity = totalQuantity + quantityAvailable;
	end
	
	return totalQuantity, totalPrice;
end

function AuctionHouseUtil.GetTimeLeftBandText(timeLeftBand)
	if timeLeftBand == Enum.AuctionHouseTimeLeftBand.Short then
		return RED_FONT_COLOR:WrapTextInColorCode(TIME_LEFT_SHORT);
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.Medium then
		return GRAY_FONT_COLOR:WrapTextInColorCode(TIME_LEFT_MEDIUM);
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.Long then
		return GRAY_FONT_COLOR:WrapTextInColorCode(TIME_LEFT_LONG);
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.VeryLong then
		return GRAY_FONT_COLOR:WrapTextInColorCode(TIME_LEFT_VERY_LONG);
	end

	return "";
end

function AuctionHouseUtil.GetTooltipTimeLeftBandText(timeLeftBand)
	if timeLeftBand == Enum.AuctionHouseTimeLeftBand.Short then
		return AUCTION_HOUSE_TOOLTIP_TIME_LEFT_SHORT;
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.Medium then
		return AUCTION_HOUSE_TOOLTIP_TIME_LEFT_MEDIUM;
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.Long then
		return AUCTION_HOUSE_TOOLTIP_TIME_LEFT_LONG;
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.VeryLong then
		return AUCTION_HOUSE_TOOLTIP_TIME_LEFT_VERY_LONG;
	end

	return "";
end

function AuctionHouseUtil.AddSellersToTooltip(tooltip, sellers)
	local sellersString = sellers[1] == "player" and GREEN_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_SELLER_YOU) or sellers[1];
	local numSellers = #sellers;
	if numSellers > 1 then
		sellersString = sellersString..HIGHLIGHT_FONT_COLOR_CODE;
		for i = 2, numSellers do
			sellersString = sellersString..PLAYER_LIST_DELIMITER..sellers[i];
		end
		sellersString = sellersString..FONT_COLOR_CODE_CLOSE;

		tooltip:AddLine(AUCTION_HOUSE_TOOLTIP_MULTIPLE_SELLERS_FORMAT:format(sellersString));
	elseif numSellers > 0 then
		tooltip:AddLine(AUCTION_HOUSE_TOOLTIP_SELLER_FORMAT:format(sellersString));
	end
end

function AuctionHouseUtil.AddAuctionHouseTooltipInfo(tooltip, sellers, timeLeft, bidStatus)
	GameTooltip_AddBlankLineToTooltip(tooltip);

	AuctionHouseUtil.AddSellersToTooltip(tooltip, sellers);

	tooltip:AddLine(AUCTION_HOUSE_TOOLTIP_DURATION_FORMAT:format(AuctionHouseUtil.GetTooltipTimeLeftBandText(timeLeft)));

	if bidStatus and (bidStatus == AuctionHouseBidStatus.PlayerBid or bidStatus == AuctionHouseBidStatus.PlayerOutbid) then
		tooltip:AddLine(AuctionHouseUtil.GetBidTextFromStatus(bidStatus));
	end
end

function AuctionHouseUtil.GetItemDisplayTextFromItemKey(itemKey, itemKeyInfo)
	local itemDisplayText = itemKeyInfo.isEquipment and AUCTION_HOUSE_EQUIPMENT_RESULT_FORMAT:format(itemKeyInfo.itemName, itemKey.itemLevel) or itemKeyInfo.itemName;
	local itemQualityColor = ITEM_QUALITY_COLORS[itemKeyInfo.quality];
	return itemQualityColor.color:WrapTextInColorCode(itemDisplayText);
end

function AuctionHouseUtil.GetDisplayTextFromOwnedAuctionData(ownedAuctionData, itemKeyInfo)
	local itemKey = ownedAuctionData.itemKey;
	local itemDisplayText = itemKeyInfo.isEquipment and AUCTION_HOUSE_EQUIPMENT_RESULT_FORMAT:format(itemKeyInfo.itemName, itemKey.itemLevel) or itemKeyInfo.itemName;
	local itemQualityColor = ITEM_QUALITY_COLORS[itemKeyInfo.quality];
	local itemColor = itemQualityColor.color;

	if ownedAuctionData.quantity > 1 then
		itemDisplayText = AUCTION_HOUSE_ITEM_WITH_QUANTITY_FORMAT:format(itemDisplayText, ownedAuctionData.quantity);
	end

	if ownedAuctionData.status == Enum.AuctionStatus.Sold then
		itemColor = GRAY_FONT_COLOR;
	end
	
	return itemColor:WrapTextInColorCode(itemDisplayText);
end

function AuctionHouseUtil.GetSellersString(rowData)
	local sellers = rowData.owners;
	if #sellers == 0 then
		return "";
	elseif #sellers == 1 then
		return rowData.containsOwnerItem and WHITE_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_SELLER_YOU) or sellers[1];
	else
		return AUCTION_HOUSE_NUM_SELLERS:format(#sellers);
	end
end

AuctionHouseUtil.TimeLeftTooltipFormatter = CreateFromMixins(SecondsFormatterMixin);
AuctionHouseUtil.TimeLeftTooltipFormatter:Init(0, SecondsFormatter.Abbreviation.Truncate, true);

function AuctionHouseUtil.FormatTimeLeftTooltip(timeLeftSeconds, status)
	local sold = status == Enum.AuctionStatus.Sold;
	local timeLeftMinutes = math.ceil(timeLeftSeconds / 60);
	local color = (timeLeftMinutes >= RED_TEXT_MINUTES_THRESHOLD or sold) and WHITE_FONT_COLOR or RED_FONT_COLOR;
	local text = color:WrapTextInColorCode(AuctionHouseUtil.TimeLeftTooltipFormatter:Format(timeLeftSeconds));
	return sold and AUCTION_HOUSE_TIME_LEFT_FORMAT_SOLD:format(text) or AUCTION_HOUSE_TIME_LEFT_FORMAT_ACTIVE:format(text);
end

AuctionHouseUtil.TimeLeftFormatter = CreateFromMixins(SecondsFormatterMixin);
AuctionHouseUtil.TimeLeftFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, true);
AuctionHouseUtil.TimeLeftFormatter:SetStripIntervalWhitespace(true);

function AuctionHouseUtil.TimeLeftFormatter:GetDesiredUnitCount(seconds)
	return 1;
end

function AuctionHouseUtil.TimeLeftFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Minutes;
end

function AuctionHouseUtil.FormatTimeLeft(timeLeftSeconds, status)
	local timeLeftMinutes = math.ceil(timeLeftSeconds / 60);
	local color = (timeLeftMinutes >= RED_TEXT_MINUTES_THRESHOLD or status == Enum.AuctionStatus.Sold) and GRAY_FONT_COLOR or RED_FONT_COLOR;
	local text = AuctionHouseUtil.TimeLeftFormatter:Format(timeLeftSeconds);
	return color:WrapTextInColorCode(text);
end

function AuctionHouseUtil.SetBidsFrameBidTextColor(moneyFrame, bidStatus)
	if bidStatus == AuctionHouseBidStatus.PlayerBid then
		moneyFrame:SetFontObject(Number14FontGreen);
	elseif bidStatus == AuctionHouseBidStatus.PlayerOutbid then
		moneyFrame:SetFontObject(Number14FontRed);
	else
		moneyFrame:SetFontObject(Number14FontGray);
	end
end

function AuctionHouseUtil.SetOwnedAuctionBidTextColor(moneyFrame, ownedAuctionInfo)
	moneyFrame:SetFontObject(ownedAuctionInfo.bidder and Number14FontGreen or Number14FontGray);
end

function AuctionHouseUtil.ConvertBidStatusToText(bidStatus)
	if bidStatus == AuctionHouseBidStatus.PlayerBid then
		return AUCTION_HOUSE_HIGHEST_BIDDER;
	elseif bidStatus == AuctionHouseBidStatus.PlayerOutbid then
		return AUCTION_HOUSE_OUTBID;
	else
		return "";
	end
end

function AuctionHouseUtil.GetBidTextFromStatus(bidStatus)
	local highestBidder = bidStatus == AuctionHouseBidStatus.PlayerBid;
	local color = highestBidder and GREEN_FONT_COLOR or RED_FONT_COLOR;
	local text = AuctionHouseUtil.ConvertBidStatusToText(bidStatus);
	return color:WrapTextInColorCode(text);
end

function AuctionHouseUtil.GetHeaderNameFromSortOrder(sortOrder)
	if sortOrder == Enum.AuctionHouseSortOrder.Price then
		return AUCTION_HOUSE_BROWSE_HEADER_PRICE;
	elseif sortOrder == Enum.AuctionHouseSortOrder.Name then
		return AUCTION_HOUSE_HEADER_ITEM;
	elseif sortOrder == Enum.AuctionHouseSortOrder.Quantity then
		return AUCTION_HOUSE_BROWSE_HEADER_QUANTITY;
	elseif sortOrder == Enum.AuctionHouseSortOrder.Bid then
		return AUCTION_HOUSE_HEADER_BID_PRICE;
	elseif sortOrder == Enum.AuctionHouseSortOrder.Buyout then
		return AUCTION_HOUSE_HEADER_BUYOUT_PRICE;
	-- Note: Level is contextual and must be set manually.
	-- elseif sortOrder == Enum.AuctionHouseSortOrder.Level then
	end

	return "";
end

function AuctionHouseUtil.ConvertItemSellItemKey(itemKey)
	if itemKey == nil then
		return itemKey;
	end

	local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
	if itemKeyInfo and itemKeyInfo.isEquipment then
		-- Item keys for equipment you're selling have no item level so you can compare to similar items that have a different item level.
		itemKey.itemLevel = 0;
		return itemKey;
	end

	return itemKey;
end

function AuctionHouseUtil.SetAuctionHouseTooltip(owner, rowData)
	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT");

	if rowData.itemLink then
		local hideVendorPrice = true;
		GameTooltip:SetHyperlink(rowData.itemLink, nil, nil, nil, hideVendorPrice);
	else
		GameTooltip:SetItemKey(rowData.itemKey.itemID, rowData.itemKey.itemLevel, rowData.itemKey.itemSuffix);
	end

	local methodFound, auctionHouseFrame = CallMethodOnNearestAncestor(owner, "GetAuctionHouseFrame");
	local bidStatus = auctionHouseFrame and auctionHouseFrame:GetBidStatus(rowData) or nil;
	AuctionHouseUtil.AddAuctionHouseTooltipInfo(GameTooltip, rowData.owners, rowData.timeLeft, bidStatus);
	
	GameTooltip:Show();
end

function AuctionHouseUtil.LineOnUpdate(line)
	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function AuctionHouseUtil.LineOnEnterCallback(line, rowData)
	line:SetScript("OnUpdate", AuctionHouseUtil.LineOnUpdate);

	if rowData.itemLink then
		GameTooltip:SetOwner(line, "ANCHOR_RIGHT");

		if not BattlePetToolTip_ShowLink(rowData.itemLink) then
			GameTooltip:SetHyperlink(rowData.itemLink);
		end

		GameTooltip:Show();
	elseif rowData.itemKey then
		local restrictQualityToFilter = true;
		local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(rowData.itemKey, restrictQualityToFilter);
		if itemKeyInfo and itemKeyInfo.battlePetLink then
			GameTooltip:SetOwner(line, "ANCHOR_RIGHT");
			BattlePetToolTip_ShowLink(itemKeyInfo.battlePetLink);
		else
			GameTooltip:SetOwner(line, "ANCHOR_RIGHT");
			GameTooltip:SetItemKey(rowData.itemKey.itemID, rowData.itemKey.itemLevel, rowData.itemKey.itemSuffix);
			GameTooltip:Show();
		end

		if IsModifiedClick("DRESSUP") then
			ShowInspectCursor();
		end
	end

	line.UpdateTooltip = function(self)
		AuctionHouseUtil.LineOnEnterCallback(self, rowData);
	end;
end

function AuctionHouseUtil.LineOnLeaveCallback(line, rowData)
	line:SetScript("OnUpdate", nil);

	ResetCursor();
	GameTooltip_Hide();
end

function AuctionHouseUtil.GenerateRowSelectedCallbackWithInspect(self, selectionCallback)
	local function RowSelectedCallback(rowData)
		if rowData and IsModifiedClick("DRESSUP") then
			DressUpLink(rowData.itemLink);
			return false;
		end

		selectionCallback(self, rowData);
		return true;
	end

	return RowSelectedCallback;
end

function AuctionHouseUtil.HasBidType(itemKey)
	for i = 1, C_AuctionHouse.GetNumBidTypes() do
		local bidItemKey = C_AuctionHouse.GetBidType(i);
		if bidItemKey == itemKey then
			return true;
		end
	end

	return false;
end

function AuctionHouseUtil.HasOwnedAuctionType(itemKey)
	for i = 1, C_AuctionHouse.GetNumOwnedAuctionTypes() do
		local ownedAuctionItemKey = C_AuctionHouse.GetOwnedAuctionType(i);
		if ownedAuctionItemKey == itemKey then
			return true;
		end
	end

	return false;
end

function AuctionHouseUtil.IsOwnedAuction(rowData)
	return (#rowData.owners == 1 and (rowData.containsOwnerItem or rowData.containsAccountItem)) or
			(#rowData.owners == 2 and (rowData.containsOwnerItem and rowData.containsAccountItem));
end
