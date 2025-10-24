local HearthsteelAtlasMarkup = CreateAtlasMarkup("hearthsteel-icon-32x32", 16, 16, 0, -1);

Blizzard_HousingCatalogUtil = {};

function Blizzard_HousingCatalogUtil.FormatPrice(price)
	return price .. HearthsteelAtlasMarkup;
end
