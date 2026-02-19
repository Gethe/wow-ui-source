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
