
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

local function GetPreviewAtlasName(selected, hovered, enabled)
	if not enabled then
		return "perks-previewoff";
	end 

	if not selected then
		if hovered then
			return "Perks-PreviewOn-Gray"
		end

		return "perks-previewoff";
	end
	
	if selected and hovered then
		return "Perks-PreviewOn";
	end

	return nil;
end

HousingMarketCartItemMixin = {};

function HousingMarketCartItemMixin:OnLoad()
	local removeFromCartButton = self.RemoveFromCartButtonContainer.RemoveFromListButton;
	removeFromCartButton.eventNamespace = HOUSING_MARKET_EVENT_NAMESPACE;
	removeFromCartButton.GetEventData = function(_btn)
		return self.elementData;
	end;

	self.PlaceInWorldButton.GetEventData = function (_btn)
		return { cartID = self.elementData.cartID, decorID = self.elementData.decorID, bundleCatalogShopProductID = self.elementData.bundleCatalogShopProductID };
	end

	self.selected = false;
	self:Refresh();
end

function HousingMarketCartItemMixin:InitItem(elementData)
	self.elementData = elementData;
	self:Refresh();
end

function HousingMarketCartItemMixin:Refresh()
	if not self.elementData then
		return;
	end

	self:SetEnabled(self.elementData.decorGUID);
	self.PlaceInWorldButton:SetShown(not self.elementData.decorGUID);

	self.ItemName:SetText(self.elementData.name or "");
	self.Icon:SetTexture(self.elementData.icon or nil);
	self.PriceContainer:SetPrice(self.elementData.price or 0, self.elementData.salePrice);

	self:UpdatePreviewStatusIcon();
end

function HousingMarketCartItemMixin:SetSelection(selected)
	self:Refresh();
end

function HousingMarketCartItemMixin:OnEnter()
	self.mouseHovered = true;

	if not self:IsEnabled() then
		return;
	end

	self.HighlightTexture:Show();
	self:UpdatePreviewStatusIcon();
end

function HousingMarketCartItemMixin:OnLeave()
	self.mouseHovered = false;

	if not self:IsEnabled() then
		return;
	end

	self.HighlightTexture:Hide();
	self:UpdatePreviewStatusIcon();
end

function HousingMarketCartItemMixin:UpdatePreviewStatusIcon()
	self.enabled = self:IsEnabled();
	self.IconVignette:SetShown(not self.enabled or self.mouseHovered or not self.elementData.selected);
	
	self.PreviewStatusIcon:SetAtlas(GetPreviewAtlasName(self.elementData.selected, self.mouseHovered, self.enabled), TextureKitConstants.UseAtlasSize);

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
		return { cartID = self.elementData.cartID, decorID = self.elementData.decorID, bundleCatalogShopProductID = self.elementData.bundleCatalogShopProductID };
	end

	-- These items don't have the remove button on them
	self.selected = false;
	self:Refresh();
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
	self.enabled = self:IsEnabled();
	self.VisualContainer.IconVignette:SetShown(not self.enabled or self.mouseHovered or not self.elementData.selected);
	
	self.VisualContainer.PreviewStatusIcon:SetAtlas(GetPreviewAtlasName(self.elementData.selected, self.mouseHovered, self.enabled), TextureKitConstants.UseAtlasSize);

	local showGoldBorder = self.enabled and (self.elementData.selected);
	self.VisualContainer.IconBorder:SetAtlas(showGoldBorder and "perks-border-square-gold" or "perks-border-square-gray");
end
