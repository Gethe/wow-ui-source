
HousingCatalogBundleDisplayMixin = {};

function HousingCatalogBundleDisplayMixin:OnLoad()
	-- In the HousingCatalog bundles never display as selected.
	self.Contents:SetSelected(false);
end

function HousingCatalogBundleDisplayMixin:OnEnter()
	self.Contents:OnEnter();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.Contents:GetProductInfo().name);

	local decorListString = "";
	for index, decorEntry in ipairs(self.elementData.decorEntries) do
		local decorInfo = C_HousingCatalog.GetBasicDecorInfo(decorEntry.decorID);
		if decorInfo then
			local entryString = HOUSING_BUNDLE_DECOR_ENTRY_FORMAT:format(decorInfo.name, decorEntry.quantity);
			if index == 1 then
				decorListString = entryString;
			else
				decorListString = decorListString .. ", " .. entryString;
			end
		end
	end

	GameTooltip_AddNormalLine(GameTooltip, HOUSING_BUNDLE_CONTENTS_FORMAT:format(decorListString));

	local priceText = Blizzard_HousingCatalogUtil.FormatPrice(self.elementData.price);
	GameTooltip_AddHighlightLine(GameTooltip, HOUSING_DECOR_PRICE_FORMAT:format(priceText));

	GameTooltip_AddInstructionLine(GameTooltip, HOUSING_BUNDLE_CLICK_TO_VIEW);

	GameTooltip:Show();
end

function HousingCatalogBundleDisplayMixin:OnLeave()
	self.Contents:OnLeave();
	GameTooltip_Hide();
end

function HousingCatalogBundleDisplayMixin:OnClick()
	EventRegistry:TriggerEvent("HousingMarket.BundleSelected", self.elementData);
end

function HousingCatalogBundleDisplayMixin:Init(elementData)
	self.elementData = elementData;
	local productID = elementData.productID;
	self.Contents:SetProductInfo(CatalogShopUtil.GetProductInfo(productID));
end

function HousingCatalogBundleDisplayMixin.Reset(framePool, self)
	Pool_HideAndClearAnchors(framePool, self);
	self.elementData = nil;
end
