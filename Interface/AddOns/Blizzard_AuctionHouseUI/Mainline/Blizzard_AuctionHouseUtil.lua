local function GetQualityFilterString(itemQuality)
	local hex = select(4, C_Item.GetItemQualityColor(itemQuality));
	local text = _G["ITEM_QUALITY"..itemQuality.."_DESC"];
	return "|c"..hex..text.."|r";
end

AUCTION_HOUSE_FILTER_STRINGS = {
	[Enum.AuctionHouseFilter.UncollectedOnly] = AUCTION_HOUSE_FILTER_UNCOLLECTED_ONLY,
	[Enum.AuctionHouseFilter.UsableOnly] = AUCTION_HOUSE_FILTER_USABLE_ONLY,
	[Enum.AuctionHouseFilter.CurrentExpansionOnly] = AUCTION_HOUSE_FILTER_CURRENTEXPANSION_ONLY,
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

AUCTION_HOUSE_DEFAULT_FILTERS = {
	[Enum.AuctionHouseFilter.UncollectedOnly] = false,
	[Enum.AuctionHouseFilter.UsableOnly] = false,
	[Enum.AuctionHouseFilter.CurrentExpansionOnly] = false,
	[Enum.AuctionHouseFilter.UpgradesOnly] = false,
	[Enum.AuctionHouseFilter.PoorQuality] = true,
	[Enum.AuctionHouseFilter.CommonQuality] = true,
	[Enum.AuctionHouseFilter.UncommonQuality] = true,
	[Enum.AuctionHouseFilter.RareQuality] = true,
	[Enum.AuctionHouseFilter.EpicQuality] = true,
	[Enum.AuctionHouseFilter.LegendaryQuality] = true,
	[Enum.AuctionHouseFilter.ArtifactQuality] = true,
};

local AUCTION_HOUSE_FILTER_CATEGORY_STRINGS = {
	[Enum.AuctionHouseFilterCategory.Uncategorized] = "",
	[Enum.AuctionHouseFilterCategory.Equipment] = AUCTION_HOUSE_FILTER_CATEGORY_EQUIPMENT,
	[Enum.AuctionHouseFilterCategory.Rarity] = AUCTION_HOUSE_FILTER_CATEGORY_RARITY,
};

function GetAHFilterCategoryName(category)
	return AUCTION_HOUSE_FILTER_CATEGORY_STRINGS[category] or "";
end

local AuctionHouseTooltipType = {
	BucketPetLink = 1,
	ItemLink = 2,
	ItemKey = 3,
	SpecificPetLink = 4,
};

function AuctionHouseUtil.GetItemDisplayCraftingQualityIconFromItemKey(itemKey)
	local itemDisplayCraftingQuality = nil;
	local craftingQuality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemKey.itemID);

	if craftingQuality then
		itemDisplayCraftingQuality = C_Texture.GetCraftingReagentQualityChatIcon(craftingQuality);
	end

	return itemDisplayCraftingQuality;
end

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
