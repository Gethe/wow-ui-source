local VALID_VC_CURRENCY_CODES = {
	[Constants.CatalogShopVirtualCurrencyConstants.TALEBOUND_VC_CURRENCY_CODE] = true,
	[Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE] = true,
}
function CatalogShopUtil.IsValidVC(currencyCode)
	return currencyCode and not not VALID_VC_CURRENCY_CODES[currencyCode];
end

local VC_TO_ATLAS = {
	[Constants.CatalogShopVirtualCurrencyConstants.TALEBOUND_VC_CURRENCY_CODE] = CatalogShopConstants.VCIcon.Talebound,
	[Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE] = CatalogShopConstants.VCIcon.Hearthsteel,
}
function CatalogShopUtil.GetAtlasByCurrencyCode(currencyCode)
	if not currencyCode then
		return CatalogShopConstants.VCIcon.Default;
	end

	local atlas = VC_TO_ATLAS[currencyCode];
	return atlas or CatalogShopConstants.VCIcon.Default;
end

local DefaultAtlasMarkup = CreateAtlasMarkup(CatalogShopConstants.VCIcon.Default, 16, 16);
local VC_ATLAS_MARKUP_MAP = {
	[Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE] = CreateAtlasMarkup(CatalogShopConstants.VCIcon.Hearthsteel, 16, 16, 0, -1),
	[Constants.CatalogShopVirtualCurrencyConstants.TALEBOUND_VC_CURRENCY_CODE] = CreateAtlasMarkup(CatalogShopConstants.VCIcon.Talebound, 16, 16),
}

function CatalogShopUtil.GetVCMarkupByCurrencyCode(currencyCode)
	if not currencyCode then
		return DefaultAtlasMarkup;
	end

	local markup = VC_ATLAS_MARKUP_MAP[currencyCode];
	return markup or DefaultAtlasMarkup;
end

function CatalogShopUtil.GetVCMarkupByProductInfo(productInfo)
	if not productInfo then
		return DefaultAtlasMarkup;
	end

	return CatalogShopUtil.GetVCMarkupByCurrencyCode(productInfo.vcCurrencyCode);
end

local VC_TOP_UP_ENABLED_CONFIG = {
	[Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE] = true,
	[Constants.CatalogShopVirtualCurrencyConstants.TALEBOUND_VC_CURRENCY_CODE] = false
}
function CatalogShopUtil.VCTopUpFrameEnabled(currencyCode)
	return VC_TOP_UP_ENABLED_CONFIG[currencyCode];
end

function CatalogShopUtil.GetSelectedCurrencyCode()
	if not CatalogShopFrame then
		return nil;
	end
	local selectedProductInfo = CatalogShopFrame:GetSelectedProductInfo();
	if selectedProductInfo and selectedProductInfo.isVCProduct and selectedProductInfo.vcCurrencyCode then
		return selectedProductInfo.vcCurrencyCode;
	end
	return nil;
end
