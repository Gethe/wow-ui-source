local function GetQualityFilterString(itemQuality)
	local hex = select(4, C_Item.GetItemQualityColor(itemQuality));
	local text = _G["ITEM_QUALITY"..itemQuality.."_DESC"];
	return "|c"..hex..text.."|r";
end

AUCTION_HOUSE_FILTER_STRINGS = {
	[Enum.AuctionHouseFilter.UncollectedOnly] = AUCTION_HOUSE_FILTER_UNCOLLECTED_ONLY,
	[Enum.AuctionHouseFilter.UsableOnly] = AUCTION_HOUSE_FILTER_USABLE_ONLY,
	[Enum.AuctionHouseFilter.PoorQuality] = GetQualityFilterString(Enum.ItemQuality.Poor),
	[Enum.AuctionHouseFilter.CommonQuality] = GetQualityFilterString(Enum.ItemQuality.Standard),
	[Enum.AuctionHouseFilter.UncommonQuality] = GetQualityFilterString(Enum.ItemQuality.Good),
	[Enum.AuctionHouseFilter.RareQuality] = GetQualityFilterString(Enum.ItemQuality.Rare),
	[Enum.AuctionHouseFilter.EpicQuality] = GetQualityFilterString(Enum.ItemQuality.Epic),
	[Enum.AuctionHouseFilter.LegendaryQuality] = GetQualityFilterString(Enum.ItemQuality.Legendary),
};

AUCTION_HOUSE_DEFAULT_FILTERS = {
	[Enum.AuctionHouseFilter.UncollectedOnly] = false,
	[Enum.AuctionHouseFilter.UsableOnly] = false,
	[Enum.AuctionHouseFilter.PoorQuality] = true,
	[Enum.AuctionHouseFilter.CommonQuality] = true,
	[Enum.AuctionHouseFilter.UncommonQuality] = true,
	[Enum.AuctionHouseFilter.RareQuality] = true,
	[Enum.AuctionHouseFilter.EpicQuality] = true,
	[Enum.AuctionHouseFilter.LegendaryQuality] = true,
};

local AUCTION_HOUSE_FILTER_CATEGORY_STRINGS = {
	[Enum.AuctionHouseFilterCategory.Uncategorized] = "",
	[Enum.AuctionHouseFilterCategory.Rarity] = AUCTION_HOUSE_FILTER_CATEGORY_RARITY,
};

function GetAHFilterCategoryName(category)
	return AUCTION_HOUSE_FILTER_CATEGORY_STRINGS[category] or "";
end

function AuctionHouseUtil.GetItemDisplayCraftingQualityIconFromItemKey(itemKey)
	--Classic does not have this concept
	return nil;
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

function AuctionHouseUtil.ApplyClassicBackgroundTexture(frame)
	local textureWidth = frame.textureWidthClassic or 0;
	local textureHeight = frame.textureHeightClassic or 0;
	frame.Background:SetSize(textureWidth, textureHeight);

	if (frame.backgroundTextureClassic) then
		frame.Background:SetTexture(frame.backgroundTextureClassic);
	end
end

function AuctionHouseUtil.ApplyClassicBackgroundOffset(frame)
	local textureXOffset = frame.textureXOffsetClassic or 0;
	local textureYOffset = frame.textureYOffsetClassic or 0;
	local xOffset = frame.backgroundXOffset or 0;
	local yOffset = frame.backgroundYOffset or 0;

	frame.Background:SetPoint("TOPLEFT", textureXOffset + xOffset, textureYOffset + yOffset );
end

function AuctionHouseUtil.ApplyClassicScrollbarOffset(frame)
	if(frame.scrollbarYOffsetClassic) then
		local point, relativeFrame, relativePoint, offsetX, offsetY = frame.ScrollBar:GetPoint();
		frame.ScrollBar:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY + frame.scrollbarYOffsetClassic);
	end
end