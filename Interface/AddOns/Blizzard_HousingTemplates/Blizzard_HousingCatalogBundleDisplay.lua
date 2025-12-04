
HousingCatalogBundleDisplayMixin = {};

function HousingCatalogBundleDisplayMixin:OnLoad()
	-- In the HousingCatalog bundles never display as selected.
	self.Contents:SetSelected(false);
end

function HousingCatalogBundleDisplayMixin:OnEnter()
	self.Contents:OnEnter();

	PlaySound(SOUNDKIT.HOUSING_MARKET_CATALOG_BUNDLE_HOVER);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.Contents:GetProductInfo().name);

	local tryGetOwnedInfo = false;
	local decorListString = "";
	for index, decorEntry in ipairs(self.elementData.decorEntries) do
		local decorInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(Enum.HousingCatalogEntryType.Decor, decorEntry.decorID, tryGetOwnedInfo);
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

	if self:IsBundleInCart() then
		GameTooltip_AddHighlightLine(GameTooltip, HOUSING_BUNDLE_IN_CART);
	end

	GameTooltip_AddInstructionLine(GameTooltip, HOUSING_BUNDLE_CLICK_TO_VIEW);

	GameTooltip:Show();
end

function HousingCatalogBundleDisplayMixin:OnLeave()
	self.Contents:OnLeave();
	GameTooltip_Hide();
end

function HousingCatalogBundleDisplayMixin:OnClick(button)
	if button == "RightButton" then
		self:ShowContextMenu();
	else
		PlaySound(SOUNDKIT.HOUSING_MARKET_SELECT_BUNDLE);
		EventRegistry:TriggerEvent("HousingMarket.BundleSelected", self.elementData);
	end
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

function HousingCatalogBundleDisplayMixin:IsBundleInCart()
	-- TODO:: Replace this global access pattern.
	return HouseEditorFrame.MarketShoppingCartFrame:IsBundleInCart(self.elementData.productID);
end

function HousingCatalogBundleDisplayMixin:ShowContextMenu()
	if not self.elementData then
		return;
	end

	MenuUtil.CreateContextMenu(self, function(_owner, rootDescription)
		rootDescription:SetTag("MENU_HOUSING_CATALOG_BUNDLE");

		local isInCart = self:IsBundleInCart();

		local addToCartButton = rootDescription:CreateButton(HOUSING_MARKET_ADD_TO_CART, function()
			local elementData = {
				bundleCatalogShopProductID = self.elementData.productID,
			};

			EventRegistry:TriggerEvent(string.format("%s.%s", HOUSING_MARKET_EVENT_NAMESPACE, ShoppingCartDataServices.AddToCart), elementData);

			local cartShownEvent = string.format("%s.%s", HOUSING_MARKET_EVENT_NAMESPACE, ShoppingCartVisualServices.SetCartShown);
			local shown = true;
			local preserveCartState = true;
			EventRegistry:TriggerEvent(cartShownEvent, shown, preserveCartState);
		end);

		addToCartButton:SetEnabled(not isInCart);
		if isInCart then
			addToCartButton:SetTooltip(function(tooltip, _elementDescription)
				GameTooltip_AddErrorLine(tooltip, HOUSING_BUNDLE_IN_CART);
			end);
		end
	end);
end
