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
