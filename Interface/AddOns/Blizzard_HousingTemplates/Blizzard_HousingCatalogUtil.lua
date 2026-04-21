local HearthsteelAtlasMarkup = CreateAtlasMarkup("hearthsteel-icon-32x32", 16, 16, 0, -1);

local RefundTimeFormatter = CreateFromMixins(SecondsFormatterMixin);
RefundTimeFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, SecondsFormatter.Interval.Minutes, true, true);
RefundTimeFormatter:SetStripIntervalWhitespace(true);
RefundTimeFormatter:SetMinInterval(SecondsFormatter.Interval.Minutes);

Blizzard_HousingCatalogUtil = {};

function Blizzard_HousingCatalogUtil.FormatPrice(price)
	return price .. HearthsteelAtlasMarkup;
end

function Blizzard_HousingCatalogUtil.FormatRefundTime(refundTimeStamp)
	return HOUSING_DECOR_REFUND_TIME_REMAINING:format(RefundTimeFormatter:Format(refundTimeStamp - GetTime()));
end

function Blizzard_HousingCatalogUtil.OpenCatalogShopForProduct(productID)
	if not productID then
		return;
	end

	local function OpenShop()
		if C_HouseEditor.IsHouseEditorActive() then
			C_HouseEditor.LeaveHouseEditor();
		end

		CatalogShopInboundInterface.SelectSpecificProduct(productID);
		CatalogShopInboundInterface.SetShown(true);
	end

	-- Check if player is in preview mode and needs to confirm leaving
	if C_HousingDecor.IsPreviewState() and (C_HousingDecor.GetNumPreviewDecor() > 0) then
		StaticPopup_Show("CONFIRM_DESTROY_PREVIEW_DECOR", nil, nil, OpenShop);
	else
		OpenShop();
	end
end

function Blizzard_HousingCatalogUtil.GetInsideAndIsInvalidIndoorsOutdoors(catalogEntryType, decorID, tryGetOwnedInfo)
	local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(catalogEntryType, decorID, tryGetOwnedInfo);
	local currentlyIndoors = C_Housing.IsInsideHouse();
	local invalidIndoors = currentlyIndoors and not entryInfo.isAllowedIndoors;
	local invalidOutdoors = not currentlyIndoors and not entryInfo.isAllowedOutdoors;

	return currentlyIndoors, invalidIndoors, invalidOutdoors;
end

-- Need to deep compare the compound identifier
function Blizzard_HousingCatalogUtil.CompareCatalogEntryVariantIDs(entryVariantID, otherEntryVariantID)
	return entryVariantID.recordID == otherEntryVariantID.recordID and
		entryVariantID.entryType == otherEntryVariantID.entryType and
		entryVariantID.variantIdentifier == otherEntryVariantID.variantIdentifier;
end

-- Quantity goes by variantInfo (if applicable). This is equivalent to numStored when there are no variants.
function Blizzard_HousingCatalogUtil.GetEntryQuantity(entryInfo, variantInfo)
	-- We can only count remainingRedeemable if we're looking at a base variant since
	-- redemptions always give you the base variant.
	local remainingRedeemable = (not variantInfo or (variantInfo.entryVariantID.variantIdentifier == 0)) and entryInfo.remainingRedeemable or 0;
	local numStored = variantInfo and variantInfo.numStored or entryInfo.totalNumStored;
	return numStored + remainingRedeemable;
end

function Blizzard_HousingCatalogUtil.GetEntryNumStored(entryInfo)
	-- For storage counts we count all variants of the decor.
	return entryInfo.totalNumStored + entryInfo.remainingRedeemable;
end

function Blizzard_HousingCatalogUtil.GetEntryTotalOwned(entryInfo)
	return entryInfo.totalNumStored + entryInfo.remainingRedeemable + entryInfo.totalNumPlaced;
end

function Blizzard_HousingCatalogUtil.AddDecorEntryTooltipTitle(tooltip, entryInfo, variantInfo)
	local isDyed = false;
	local dyeSlots = variantInfo and variantInfo.dyeSlots or {};
	for index, dyeSlotEntry in ipairs(dyeSlots) do
		if dyeSlotEntry.dyeColorID then
			isDyed = true;
			break;
		end
	end

	local name = isDyed and HOUSING_DECOR_DYED_NAME_FORMAT:format(entryInfo.name) or entryInfo.name;
	local placementCost = HOUSING_DECOR_PLACEMENT_COST_FORMAT:format(entryInfo.placementCost);
	local itemQualityColor = ColorManager.GetColorDataForItemQuality(entryInfo.quality or Enum.ItemQuality.Common).color;
	local wrap = false;
	GameTooltip_AddColoredDoubleLine(tooltip, name, placementCost, itemQualityColor, HIGHLIGHT_FONT_COLOR, wrap);
end
