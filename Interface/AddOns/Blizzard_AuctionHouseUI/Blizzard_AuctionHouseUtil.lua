
local AUCTIONABLE_TOKEN_ITEM_ID = 122270;

local WOW_TOKEN_TIME_LEFT_TOOLTIP_FORMAT = WHITE_FONT_COLOR:WrapTextInColorCode(ESTIMATED_TIME_TO_SELL_LABEL).."%s";

local RED_TEXT_MINUTES_THRESHOLD = 60;

local TIME_LEFT_ATLAS_MARKUP = CreateAtlasMarkup("auctionhouse-icon-clock", 16, 16, 2, -2);

local function GetQualityFilterString(itemQuality)
	local hex = select(4, C_Item.GetItemQualityColor(itemQuality));
	local text = _G["ITEM_QUALITY"..itemQuality.."_DESC"];
	return "|c"..hex..text.."|r";
end

AUCTION_HOUSE_FILTER_STRINGS = {
	[Enum.AuctionHouseFilter.UncollectedOnly] = AUCTION_HOUSE_FILTER_UNCOLLECTED_ONLY,
	[Enum.AuctionHouseFilter.UsableOnly] = AUCTION_HOUSE_FILTER_USABLE_ONLY,
	[Enum.AuctionHouseFilter.UpgradesOnly] = AUCTION_HOUSE_FILTER_UPGRADES_ONLY,
	[Enum.AuctionHouseFilter.PoorQuality] = GetQualityFilterString(Enum.ItemQuality.Poor),
	[Enum.AuctionHouseFilter.CommonQuality] = GetQualityFilterString(Enum.ItemQuality.Common),
	[Enum.AuctionHouseFilter.UncommonQuality] = GetQualityFilterString(Enum.ItemQuality.Uncommon),
	[Enum.AuctionHouseFilter.RareQuality] = GetQualityFilterString(Enum.ItemQuality.Rare),
	[Enum.AuctionHouseFilter.EpicQuality] = GetQualityFilterString(Enum.ItemQuality.Epic),
	[Enum.AuctionHouseFilter.LegendaryQuality] = GetQualityFilterString(Enum.ItemQuality.Legendary),
	[Enum.AuctionHouseFilter.ArtifactQuality] = GetQualityFilterString(Enum.ItemQuality.Artifact),
	[Enum.AuctionHouseFilter.LegendaryCraftedItemOnly] = AUCTION_HOUSE_FILTER_RUNECARVING,
};

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
	if self:GetBuyoutAmount() ~= 0 and bidAmount >= self:GetBuyoutAmount() then
		self:BuyoutItem();
	elseif bidAmount < self.minBid then
		UIErrorsFrame:AddExternalErrorMessage(AUCTION_HOUSE_BID_AMOUNT_IS_TOO_LOW);
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

function AuctionHouseBuySystemMixin:SetPrice(minBid, buyoutPrice, isOwnerItem, isPlayerHighBid)
	minBid = minBid or 0;
	buyoutPrice = buyoutPrice or 0;

	self.minBid = minBid;
	self.BidFrame:SetPrice(minBid, isOwnerItem, isPlayerHighBid);
	self.BuyoutFrame:SetPrice(buyoutPrice, isOwnerItem);
end

function AuctionHouseBuySystemMixin:SetAuction(auctionID, minBid, buyoutPrice, isOwnerItem, bidder)
	local isPlayerHighBid = bidder == UnitGUID("player");
	self:SetAuctionID(auctionID);
	self:SetPrice(minBid, buyoutPrice, isOwnerItem, isPlayerHighBid);
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

	return AuctionHouseSearchContext.BrowseAll;
end

function AuctionHouseUtil.AggregateSearchResultsByQuantity(itemID, quantity)
	local remainingQuantity = quantity;
	local totalQuantity = 0;
	local totalPrice = 0;
	local numResultsAggregated = 0;
	local partiallyPurchased = false;
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
				partiallyPurchased = quantityToBuy ~= quantityAvailable;
				break;
			end
		end
	end
	
	return totalQuantity, totalPrice, numResultsAggregated, partiallyPurchased;
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

function AuctionHouseUtil.GetTooltipTimeLeftBandText(rowData)
	local isToken = AuctionHouseUtil.RowDataIsWoWToken(rowData);
	local timeLeftFormat = isToken and WOW_TOKEN_TIME_LEFT_TOOLTIP_FORMAT or "%s";

	local timeLeftBand = rowData.timeLeft;
	if timeLeftBand == Enum.AuctionHouseTimeLeftBand.Short then
		return timeLeftFormat:format(AUCTION_HOUSE_TOOLTIP_TIME_LEFT_SHORT);
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.Medium then
		return timeLeftFormat:format(AUCTION_HOUSE_TOOLTIP_TIME_LEFT_MEDIUM);
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.Long then
		return timeLeftFormat:format(AUCTION_HOUSE_TOOLTIP_TIME_LEFT_LONG);
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.VeryLong then
		return timeLeftFormat:format(AUCTION_HOUSE_TOOLTIP_TIME_LEFT_VERY_LONG);
	end

	return "";
end

function AuctionHouseUtil.AddSellersToTooltip(tooltip, sellers, totalNumberOfSellers)
	local sellersString = sellers[1] == "player" and GREEN_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_SELLER_YOU) or sellers[1];
	local numSellers = #sellers;
	if numSellers > 1 then
		for i = 2, numSellers do
			sellersString = sellersString..PLAYER_LIST_DELIMITER..sellers[i];
		end

		local wrap = true;
		if totalNumberOfSellers > numSellers then
			GameTooltip_AddNormalLine(tooltip, AUCTION_HOUSE_TOOLTIP_OVERFLOW_SELLERS_FORMAT:format(sellersString, totalNumberOfSellers - numSellers), wrap);
		else
			GameTooltip_AddNormalLine(tooltip, AUCTION_HOUSE_TOOLTIP_MULTIPLE_SELLERS_FORMAT:format(sellersString), wrap);
		end
	elseif numSellers > 0 then
		local wrap = true;
		GameTooltip_AddNormalLine(tooltip, AUCTION_HOUSE_TOOLTIP_SELLER_FORMAT:format(sellersString), wrap);
	end
end

function AuctionHouseUtil.AddAuctionHouseTooltipInfo(tooltip, rowData, bidStatus)
	GameTooltip_AddBlankLineToTooltip(tooltip);

	AuctionHouseUtil.AddSellersToTooltip(tooltip, rowData.owners, rowData.totalNumberOfOwners);

	tooltip:AddLine(AUCTION_HOUSE_TOOLTIP_DURATION_FORMAT:format(AuctionHouseUtil.GetTooltipTimeLeftBandText(rowData)));

	if bidStatus and (bidStatus == AuctionHouseBidStatus.PlayerBid or bidStatus == AuctionHouseBidStatus.PlayerOutbid) then
		tooltip:AddLine(AuctionHouseUtil.GetBidTextFromStatus(bidStatus));
	end
end

function AuctionHouseUtil.GetItemDisplayText(itemName, itemLevel)
	if itemLevel then
		return AUCTION_HOUSE_EQUIPMENT_RESULT_FORMAT:format(itemName, itemLevel);
	end

	return itemName;
end

function AuctionHouseUtil.GetItemDisplayTextFromItemKey(itemKey, itemKeyInfo, hideItemLevel)
	local shouldDisplayItemLevel = itemKeyInfo.isEquipment and itemKey.itemLevel and not hideItemLevel;
	local itemDisplayText = AuctionHouseUtil.GetItemDisplayText(itemKeyInfo.itemName, shouldDisplayItemLevel and itemKey.itemLevel or nil);
	local itemQuality = itemKeyInfo.quality;
	local itemQualityColor = ITEM_QUALITY_COLORS[itemQuality];

	return itemQualityColor.color:WrapTextInColorCode(itemDisplayText);
end

function AuctionHouseUtil.GetItemDisplayCraftingQualityIconFromItemKey(itemKey)
	local itemDisplayCraftingQuality = nil;
	local craftingQuality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemKey.itemID);

	if craftingQuality then
		itemDisplayCraftingQuality = C_Texture.GetCraftingReagentQualityChatIcon(craftingQuality);
	end

	return itemDisplayCraftingQuality;
end

function AuctionHouseUtil.GetItemQualityColorFromOwnedAuctionData(ownedAuctionData, itemKeyInfo)
	if ownedAuctionData.status == Enum.AuctionStatus.Sold then
		return GRAY_FONT_COLOR;
	end

	local itemQuality = itemKeyInfo.quality;
	local itemLink = ownedAuctionData.itemLink;
	if itemLink ~= nil then
		if LinkUtil.IsLinkType(itemLink, "battlepet") then
			itemQuality = select(3, BattlePetToolTip_UnpackBattlePetLink(itemLink)) or itemQuality;
		else
			itemQuality = select(3, C_Item.GetItemInfo(itemLink)) or itemQuality;
		end
	end

	local itemQualityColor = ITEM_QUALITY_COLORS[itemQuality];
	return itemQualityColor.color;
end

function AuctionHouseUtil.GetQuantityDisplayTextFromOwnedAuctionData(ownedAuctionData)
	local quantityDisplayText = nil;

	if ownedAuctionData.quantity and ownedAuctionData.quantity > 1 then
		quantityDisplayText = AUCTION_HOUSE_ITEM_QUANTITY_FORMAT:format(BreakUpLargeNumbers(ownedAuctionData.quantity));
	end
	
	return quantityDisplayText;
end

function AuctionHouseUtil.GetDisplayTextFromOwnedAuctionData(ownedAuctionData, itemKeyInfo, hideItemLevel)
	local itemKey = ownedAuctionData.itemKey;
	local shouldDisplayItemLevel = itemKeyInfo.isEquipment and itemKey.itemLevel and not hideItemLevel;
	local itemDisplayText = AuctionHouseUtil.GetItemDisplayText(itemKeyInfo.itemName, shouldDisplayItemLevel and itemKey.itemLevel or nil);

	local itemQualityColor = AuctionHouseUtil.GetItemQualityColorFromOwnedAuctionData(ownedAuctionData, itemKeyInfo);
	return itemQualityColor:WrapTextInColorCode(itemDisplayText);
end

function AuctionHouseUtil.GetSellersString(rowData)
	local sellers = rowData.owners;
	if #sellers == 0 then
		return "";
	elseif #sellers == 1 then
		return rowData.containsOwnerItem and WHITE_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_SELLER_YOU) or sellers[1];
	else
		return AUCTION_HOUSE_NUM_SELLERS:format(rowData.totalNumberOfOwners);
	end
end

AuctionHouseUtil.TimeLeftTooltipFormatter = CreateFromMixins(SecondsFormatterMixin);
AuctionHouseUtil.TimeLeftTooltipFormatter:Init(0, SecondsFormatter.Abbreviation.Truncate, true);

function AuctionHouseUtil.FormatTimeLeftTooltip(timeLeftSeconds, rowData)
	local useNormalFontColor = (rowData.status == Enum.AuctionStatus.Sold) or AuctionHouseUtil.RowDataIsWoWToken(rowData);
	local timeLeftMinutes = math.ceil(timeLeftSeconds / 60);
	local color = (useNormalFontColor or timeLeftMinutes >= RED_TEXT_MINUTES_THRESHOLD) and WHITE_FONT_COLOR or RED_FONT_COLOR;
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

function AuctionHouseUtil.FormatTimeLeft(timeLeftSeconds, rowData)
	local useNormalFontColor = (rowData.status == Enum.AuctionStatus.Sold) or AuctionHouseUtil.RowDataIsWoWToken(rowData);
	local timeLeftMinutes = math.ceil(timeLeftSeconds / 60);
	local color = (useNormalFontColor or timeLeftMinutes >= RED_TEXT_MINUTES_THRESHOLD) and GRAY_FONT_COLOR or RED_FONT_COLOR;
	local text = AuctionHouseUtil.TimeLeftFormatter:Format(timeLeftSeconds);
	return color:WrapTextInColorCode(text);
end

function AuctionHouseUtil.SetBidsFrameBidTextColor(moneyFrame, bidStatus)
	if bidStatus == AuctionHouseBidStatus.PlayerBid then
		moneyFrame:SetFontObject(PriceFontGreen);
	elseif bidStatus == AuctionHouseBidStatus.PlayerOutbid then
		moneyFrame:SetFontObject(PriceFontRed);
	else
		moneyFrame:SetFontObject(PriceFontGray);
	end
end

function AuctionHouseUtil.SetOwnedAuctionBidTextColor(moneyFrame, ownedAuctionInfo)
	moneyFrame:SetFontObject(ownedAuctionInfo.bidder and PriceFontGreen or PriceFontGray);
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
	elseif sortOrder == Enum.AuctionHouseSortOrder.TimeRemaining then
		return TIME_LEFT_ATLAS_MARKUP;
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
		-- Item keys for equipment you're selling have no item level or suffix so you can compare to similar items.
		itemKey.itemLevel = 0;
		itemKey.itemSuffix = 0;
		return itemKey;
	end

	return itemKey;
end

local AuctionHouseTooltipType = {
	BucketPetLink = 1,
	ItemLink = 2,
	ItemKey = 3,
	SpecificPetLink = 4,
};

local function GetAuctionHouseTooltipType(rowData)
	if rowData.itemLink then
		local linkType = LinkUtil.ExtractLink(rowData.itemLink);
		if linkType == "battlepet" then
			return AuctionHouseTooltipType.SpecificPetLink, rowData.itemLink;
		elseif linkType == "item" then
			return AuctionHouseTooltipType.ItemLink, rowData.itemLink;
		end
	elseif rowData.itemKey then
		local restrictQualityToFilter = true;
		local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(rowData.itemKey, restrictQualityToFilter);
		if itemKeyInfo and itemKeyInfo.battlePetLink then
			return AuctionHouseTooltipType.BucketPetLink, itemKeyInfo.battlePetLink;
		end

		return AuctionHouseTooltipType.ItemKey, rowData.itemKey;
	end

	return nil;
end

function AuctionHouseUtil.AppendBattlePetVariationLines(tooltip)
	GameTooltip_AddBlankLineToTooltip(tooltip);

	local wrap = true;
	GameTooltip_AddNormalLine(tooltip, AUCTION_HOUSE_BUCKET_VARIATION_PET_TOOLTIP, wrap);
end

function AuctionHouseUtil.SetAuctionHouseTooltip(owner, rowData)
	GameTooltip_Hide();

	local tooltip = nil;

	local tooltipType, data = GetAuctionHouseTooltipType(rowData);
	if not tooltipType then
		return;
	end

	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT");
	
	if tooltipType == AuctionHouseTooltipType.BucketPetLink or tooltipType == AuctionHouseTooltipType.SpecificPetLink then
		BattlePetToolTip_ShowLink(data);
		tooltip = BattlePetTooltip;
	else
		tooltip = GameTooltip;
		if tooltipType == AuctionHouseTooltipType.ItemLink then
			local hideVendorPrice = true;
			GameTooltip:SetHyperlink(rowData.itemLink, nil, nil, hideVendorPrice);
		elseif tooltipType == AuctionHouseTooltipType.ItemKey then
			GameTooltip:SetItemKey(data.itemID, data.itemLevel, data.itemSuffix, C_AuctionHouse.GetItemKeyRequiredLevel(data));
		end
	end

	if rowData.owners then
		local methodFound, auctionHouseFrame = CallMethodOnNearestAncestor(owner, "GetAuctionHouseFrame");
		local bidStatus = auctionHouseFrame and auctionHouseFrame:GetBidStatus(rowData) or nil;
		AuctionHouseUtil.AddAuctionHouseTooltipInfo(tooltip, rowData, bidStatus);
	end

	if tooltipType == AuctionHouseTooltipType.BucketPetLink then
		AuctionHouseUtil.AppendBattlePetVariationLines(tooltip);
	end

	if tooltip == GameTooltip then
		GameTooltip:Show();
	end
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

	AuctionHouseUtil.SetAuctionHouseTooltip(line, rowData);

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
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

function AuctionHouseUtil.GetItemLinkFromRowData(rowData)
	if rowData.itemLink then
		return rowData.itemLink;
	else
		local itemID = rowData.itemID or rowData.itemKey.itemID;
		if itemID ~= nil then
			local itemLink = select(2, C_Item.GetItemInfo(itemID));
			return itemLink;
		end
	end

	return nil;
end

function AuctionHouseUtil.GenerateRowSelectedCallbackWithInspect(self, selectionCallback)
	local function RowSelectedCallback(rowData)
		if rowData and IsModifiedClick("DRESSUP") then
			local itemLink = AuctionHouseUtil.GetItemLinkFromRowData(rowData);
			if itemLink ~= nil then
				DressUpLink(itemLink);
				return false;
			end
		elseif rowData and IsModifiedClick("CHATLINK") then
			local itemLink = AuctionHouseUtil.GetItemLinkFromRowData(rowData);
			if itemLink ~= nil then
				ChatEdit_InsertLink(itemLink);
				return false;
			end
		end

		selectionCallback(self, rowData);
		return true;
	end

	return RowSelectedCallback;
end

function AuctionHouseUtil.GenerateRowSelectedCallbackWithLink(self, selectionCallback)
	local function RowSelectedCallback(rowData)
		if rowData and IsModifiedClick("CHATLINK") then
			ChatEdit_InsertLink(AuctionHouseUtil.GetItemLinkFromRowData(rowData));
			return false;
		end

		selectionCallback(self, rowData);
		return true;
	end

	return RowSelectedCallback;
end

function AuctionHouseUtil.CompareItemKeys(lhsItemKey, rhsItemKey)
	return tCompare(lhsItemKey, rhsItemKey);
end

function AuctionHouseUtil.HasBidType(itemKey)
	for i = 1, C_AuctionHouse.GetNumBidTypes() do
		local bidItemKey = C_AuctionHouse.GetBidType(i);
		if AuctionHouseUtil.CompareItemKeys(bidItemKey, itemKey) then
			return true, i;
		end
	end

	return false;
end

function AuctionHouseUtil.HasOwnedAuctionType(itemKey)
	for i = 1, C_AuctionHouse.GetNumOwnedAuctionTypes() do
		local ownedAuctionItemKey = C_AuctionHouse.GetOwnedAuctionType(i);
		if AuctionHouseUtil.CompareItemKeys(ownedAuctionItemKey, itemKey) then
			return true, i;
		end
	end

	return false;
end

function AuctionHouseUtil.IsOwnedAuction(rowData)
	return (#rowData.owners == 1 and (rowData.containsOwnerItem or rowData.containsAccountItem)) or
			(#rowData.owners == 2 and (rowData.containsOwnerItem and rowData.containsAccountItem));
end

function AuctionHouseUtil.SanitizeAuctionHousePrice(rawPrice)
	return math.ceil(rawPrice / COPPER_PER_SILVER) * COPPER_PER_SILVER;
end

function AuctionHouseUtil.RowDataIsWoWToken(rowData)
	return (rowData.itemID == AUCTIONABLE_TOKEN_ITEM_ID) or (rowData.itemKey and rowData.itemKey.itemID == AUCTIONABLE_TOKEN_ITEM_ID);
end

function AuctionHouseUtil.CreateVirtualRowData(virtualEntryText, isSelectedVirtualEntry)
	return { isVirtualEntry = true, virtualEntryText = virtualEntryText, isSelectedVirtualEntry = isSelectedVirtualEntry, };
end

local AuctionHouseErrorToErrorText = {
	[Enum.AuctionHouseError.NotEnoughMoney] = ERR_NOT_ENOUGH_MONEY,
	[Enum.AuctionHouseError.HigherBid] = ERR_AUCTION_HIGHER_BID,
	[Enum.AuctionHouseError.BidIncrement] = ERR_AUCTION_BID_INCREMENT,
	[Enum.AuctionHouseError.BidOwn] = ERR_AUCTION_BID_OWN,
	[Enum.AuctionHouseError.ItemNotFound] = ERR_ITEM_NOT_FOUND,
	[Enum.AuctionHouseError.RestrictedAccountTrial] = ERR_RESTRICTED_ACCOUNT_TRIAL,
	[Enum.AuctionHouseError.HasRestriction] = ERR_HAS_RESTRICTION,
	[Enum.AuctionHouseError.IsBusy] = ERR_AUCTION_HOUSE_BUSY,
	[Enum.AuctionHouseError.Unavailable] = ERR_AUCTION_HOUSE_UNAVAILABLE,
	[Enum.AuctionHouseError.ItemHasQuote] = ERR_AUCTION_ITEM_HAS_QUOTE,
	[Enum.AuctionHouseError.DatabaseError] = ERR_AUCTION_DATABASE_ERROR,
	[Enum.AuctionHouseError.MinBid] = ERR_AUCTION_MIN_BID,
	[Enum.AuctionHouseError.NotEnoughItems] = ERR_AUCTION_ENOUGH_ITEMS,
	[Enum.AuctionHouseError.RepairItem] = ERR_AUCTION_REPAIR_ITEM,
	[Enum.AuctionHouseError.UsedCharges] = ERR_AUCTION_USED_CHARGES,
	[Enum.AuctionHouseError.QuestItem] = ERR_AUCTION_QUEST_ITEM,
	[Enum.AuctionHouseError.BoundItem] = ERR_AUCTION_BOUND_ITEM,
	[Enum.AuctionHouseError.ConjuredItem] = ERR_AUCTION_CONJURED_ITEM,
	[Enum.AuctionHouseError.LimitedDurationItem] = ERR_AUCTION_LIMITED_DURATION_ITEM,
	[Enum.AuctionHouseError.IsBag] = ERR_AUCTION_BAG,
	[Enum.AuctionHouseError.EquippedBag] = ERR_AUCTION_EQUIPPED_BAG,
	[Enum.AuctionHouseError.WrappedItem] = ERR_AUCTION_WRAPPED_ITEM,
	[Enum.AuctionHouseError.LootItem] = ERR_AUCTION_LOOT_ITEM,
	[Enum.AuctionHouseError.DoubleBid] = ERR_AUCTION_DOUBLE_BID,
};

function AuctionHouseUtil.GetErrorText(auctionHouseError)
	return AuctionHouseErrorToErrorText[auctionHouseError] or "";
end

local UniqueShadowlandsCraftedLimitCategoryID = 481;
function AuctionHouseUtil.IsAuctionIDUniqueShadowlandsCrafted(auctionID)
	local auctionInfo = C_AuctionHouse.GetAuctionInfoByID(auctionID);
	local itemLink = (auctionInfo ~= nil) and auctionInfo.itemLink or nil;
	if itemLink == nil then
		return false;
	end

	local categoryName, categoryCount, uniqueLimitCategory = select(2, C_Item.GetItemUniquenessByID(itemLink));
	categoryName = ((categoryName ~= nil) and (categoryCount ~= nil)) and ITEM_LIMIT_CATEGORY_MULTIPLE:format(categoryName, categoryCount) or categoryName;
	local isUniqueShadowlandsCrafted = uniqueLimitCategory == UniqueShadowlandsCraftedLimitCategoryID;
	return isUniqueShadowlandsCrafted, categoryName;
end
