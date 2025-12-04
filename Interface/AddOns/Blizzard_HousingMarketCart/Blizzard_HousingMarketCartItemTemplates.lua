
HousingMarketCartBraceMixin = {};

function HousingMarketCartBraceMixin:InitBraces(hasTopBrace, hasBottomBrace)
	self.TopBrace:SetShown(not not hasTopBrace);
	self.Title:SetShown(not not hasTopBrace);
	self.BottomBrace:SetShown(not not hasBottomBrace);

	if self.VisualContainer then
		-- Since Left is Vertically centered, we only want to offset by half of what we're doing to the bottom to preserve sizing
		self.VisualContainer:SetPoint("LEFT", self, "LEFT", 0, self.elementData and (self.elementData.bottomBraceOffset / 2) or 0);
		self.VisualContainer:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, self.elementData and self.elementData.bottomBraceOffset or 0);
	end
end

HousingMarketCartPriceMixin = {};

function HousingMarketCartPriceMixin:GetCurrencyInfo()
	local hearthsteelBalance = tonumber(C_CatalogShop.GetVirtualCurrencyBalance(Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE));
	local hearthsteelIcon = "hearthsteel-icon-32x32";
	local iconIsAtlas = true;

	return hearthsteelBalance, hearthsteelIcon, iconIsAtlas;
end

function HousingMarketCartPriceMixin:GetPriceText(price, salePrice, playerCurrencyAmount)
	local itemOnSale = salePrice and salePrice < price;
	local priceText = "";
	local salePriceText = "";
	if playerCurrencyAmount then
		if itemOnSale then
			priceText = GRAY_FONT_COLOR:WrapTextInColorCode(price);
			salePriceText = GREEN_FONT_COLOR:WrapTextInColorCode(salePrice);
		else
			priceText = WHITE_FONT_COLOR:WrapTextInColorCode(price);
		end
	end

	return priceText, salePriceText;
end


local function GetPreviewAtlasName(elementData, hovered, enabled)
	if not enabled then
		return "perks-previewoff";
	end

	if not elementData.selected then
		-- Only respond to hover if not selected when there's a decorGUID to preview toggle on and off.
		if hovered and elementData.decorGUID then
			return "Perks-PreviewOn-Gray"
		end

		return "perks-previewoff";
	end

	if elementData.selected and hovered then
		return "Perks-PreviewOn";
	end

	return nil;
end

PlaceInWorldButtonMixin = {};

function PlaceInWorldButtonMixin:OnEnter()
	self.HighlightIcon:Show();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local wrap = true;
	GameTooltip_AddHighlightLine(GameTooltip, HOUSING_DECOR_PLACE_IN_WORLD_TOOLTIP_DESC, wrap);
	GameTooltip_AddColoredLine(GameTooltip, HOUSING_DECOR_PLACE_IN_WORLD_TOOLTIP_INSTRUCTIONS, GREEN_FONT_COLOR, wrap);
	GameTooltip:Show();
end

function PlaceInWorldButtonMixin:OnLeave()
	self.HighlightIcon:Hide();

	GameTooltip_Hide();
end

HousingMarketCartItemMixin = {};

function HousingMarketCartItemMixin:OnLoad()
	local removeFromCartButton = self.RemoveFromCartButtonContainer.RemoveFromListButton;
	removeFromCartButton.eventNamespace = HOUSING_MARKET_EVENT_NAMESPACE;
	removeFromCartButton.GetEventData = function(_btn)
		return self.elementData;
	end;

	self.PlaceInWorldButton.GetEventData = function (_btn)
		return self:GetPlaceInWorldData();
	end

	self.selected = false;
	self:Refresh();
end

function HousingMarketCartItemMixin:GetPlaceInWorldData()
	return { cartID = self.elementData.cartID, decorID = self.elementData.decorID, bundleCatalogShopProductID = self.elementData.bundleCatalogShopProductID };
end

function HousingMarketCartItemMixin:InitItem(elementData)
	self.elementData = elementData;
	self:Refresh();
end

function HousingMarketCartItemMixin:Refresh()
	if not self.elementData then
		return;
	end

	-- Can't actually disable enable here since we need on click in the disabled state for drag
	self.enabled = not not self.elementData.decorGUID;
	self.PlaceInWorldButton:SetShown(not self.elementData.decorGUID);

	self.ItemName:SetText(self.elementData.name or "");
	self.Icon:SetTexture(self.elementData.icon or nil);
	self.PriceContainer:SetPrice(self.elementData.price or 0, self.elementData.salePrice);

	self:UpdatePreviewStatusIcon();
end

function HousingMarketCartItemMixin:OnDragStart()
	if not self.elementData.decorGUID then
		EventRegistry:TriggerEvent(HOUSING_MARKET_EVENT_NAMESPACE .. "." .. HousingMarketCartDataServiceEvents.PlaceInWorld, self:GetPlaceInWorldData());
	end
end

function HousingMarketCartItemMixin:SetSelection(selected)
	self:Refresh();
end

function HousingMarketCartItemMixin:OnEnter()
	self.mouseHovered = true;

	if not self.enabled then
		return;
	end

	self.HighlightTexture:Show();
	self:UpdatePreviewStatusIcon();
end

function HousingMarketCartItemMixin:OnLeave()
	self.mouseHovered = false;
	self.HighlightTexture:Hide();
	self:UpdatePreviewStatusIcon();
end

function HousingMarketCartItemMixin:UpdatePreviewStatusIcon()
	self.IconVignette:SetShown(not self.enabled or self.mouseHovered or not self.elementData.selected);
	
	self.PreviewStatusIcon:SetAtlas(GetPreviewAtlasName(self.elementData, self.mouseHovered, self.enabled), TextureKitConstants.UseAtlasSize);

	local showGoldBorder = self.enabled and (self.elementData.selected);
	self.IconBorder:SetAtlas(showGoldBorder and "perks-border-square-gold" or "perks-border-square-gray");
end

HousingRemoveInlineItemFromCartServiceMixin = {};

function HousingRemoveInlineItemFromCartServiceMixin:GetEventData()
	return self:GetParent().elementData;
end

HousingMarketCartBundleRegistrant = {};

function HousingMarketCartBundleRegistrant:IsRegisteredToBundle(bundleRef)
	if not self.elementData or not self.elementData.bundleRef then
		return false;
	end

	return self.elementData.bundleRef == bundleRef;
end

HousingMarketCartBundleHeaderMixin = CreateFromMixins(HousingMarketCartBundleRegistrant);

function HousingMarketCartBundleHeaderMixin:Init(elementData)
	self.elementData = elementData;
	self:Refresh();
end

function HousingMarketCartBundleHeaderMixin:Refresh()
	if not self.elementData then
		return;
	end

	self.Title:SetText(self.elementData.title or "");
end

HousingMarketCartBundleFooterMixin = CreateFromMixins(HousingMarketCartBundleRegistrant);

function HousingMarketCartBundleFooterMixin:Init(elementData)
	self.elementData = elementData;
end

HousingMarketCartBundleMixin = CreateFromMixins(HousingMarketCartBundleRegistrant);

function HousingMarketCartBundleMixin:OnLoad()
	local removeFromCartButton = self.RemoveFromCartButtonContainer.RemoveFromListButton;
	removeFromCartButton.eventNamespace = HOUSING_MARKET_EVENT_NAMESPACE;
	removeFromCartButton.GetEventData = function(_btn)
		return self.elementData;
	end;

	self.selected = false;

	self:AddDynamicEventMethod(EventRegistry, "HousingMarketCart.BundleHovered", self.OnBundleHovered);
	self:AddDynamicEventMethod(EventRegistry, "HousingMarketCart.BundleLeft", self.OnBundleLeft);
end

function HousingMarketCartBundleMixin:OnBundleHovered(catalogShopProductID)
	if catalogShopProductID == self.elementData.bundleCatalogShopProductID then
		self.RemoveFromCartButtonContainer.RemoveFromListButton:Show();
	end
end

function HousingMarketCartBundleMixin:OnBundleLeft(catalogShopProductID)
	if catalogShopProductID == self.elementData.bundleCatalogShopProductID then
		self.RemoveFromCartButtonContainer.RemoveFromListButton:Hide();
	end
end

function HousingMarketCartBundleMixin:InitItem(elementData)
	self.elementData = elementData;
	self.elementData.showTopBrace = true;
	self.elementData.showBottomBrace = false;
	self:Refresh();
end

function HousingMarketCartBundleMixin:Refresh()
	if not self.elementData then
		return;
	end

	self.BundleName:SetText(self.elementData.name or "");
	self.PriceContainer:SetPrice(self.elementData.price or 0, self.elementData.salePrice or 0);

	self:InitBraces(self.elementData.showTopBrace, self.elementData.showBottomBrace)
end

HousingMarketCartBundleItemMixin = CreateFromMixins(HousingMarketCartBundleRegistrant);

function HousingMarketCartBundleItemMixin:OnLoad()
	self.PlaceInWorldButton.GetEventData = function (_btn)
		return self:GetPlaceInWorldData();
	end

	-- These items don't have the remove button on them
	self.selected = false;
	self:Refresh();
end

function HousingMarketCartBundleItemMixin:GetPlaceInWorldData()
	return { cartID = self.elementData.cartID, decorID = self.elementData.decorID, bundleCatalogShopProductID = self.elementData.bundleCatalogShopProductID };
end

function HousingMarketCartBundleItemMixin:OnDragStart()
	if not self.elementData.decorGUID then
		EventRegistry:TriggerEvent(HOUSING_MARKET_EVENT_NAMESPACE .. "." .. HousingMarketCartDataServiceEvents.PlaceInWorld, self:GetPlaceInWorldData());
	end
end

function HousingMarketCartBundleItemMixin:InitItem(elementData)
	self.elementData = elementData;
	self:Refresh();
end

function HousingMarketCartBundleItemMixin:Refresh()
	if not self.elementData then
		return;
	end

	self.PlaceInWorldButton:SetShown(not self.elementData.decorGUID);

	self.VisualContainer.ItemName:SetText(self.elementData.name or "");
	self.VisualContainer.Icon:SetTexture(self.elementData.icon or nil);

	self:UpdatePreviewStatusIcon();

	self:InitBraces(self.elementData.showTopBrace, self.elementData.showBottomBrace)
end

function HousingMarketCartBundleItemMixin:SetSelection(selected)
	self:Refresh();
end

function HousingMarketCartBundleItemMixin:OnEnter()
	EventRegistry:TriggerEvent("HousingMarketCart.BundleHovered", self.elementData.bundleCatalogShopProductID);
	self.VisualContainer.HighlightTexture:Show();
	self.mouseHovered = true;
	self:UpdatePreviewStatusIcon();
end

function HousingMarketCartBundleItemMixin:OnLeave()
	EventRegistry:TriggerEvent("HousingMarketCart.BundleLeft", self.elementData.bundleCatalogShopProductID);
	self.VisualContainer.HighlightTexture:Hide();
	self.mouseHovered = false;
	self:UpdatePreviewStatusIcon();
end

function HousingMarketCartBundleItemMixin:UpdatePreviewStatusIcon()
	self.enabled = not not self.elementData.decorGUID;
	self.VisualContainer.IconVignette:SetShown(not self.enabled or self.mouseHovered or not self.elementData.selected);
	
	self.VisualContainer.PreviewStatusIcon:SetAtlas(GetPreviewAtlasName(self.elementData, self.mouseHovered, self.enabled), TextureKitConstants.UseAtlasSize);

	local showGoldBorder = self.enabled and (self.elementData.selected);
	self.VisualContainer.IconBorder:SetAtlas(showGoldBorder and "perks-border-square-gold" or "perks-border-square-gray");
end
