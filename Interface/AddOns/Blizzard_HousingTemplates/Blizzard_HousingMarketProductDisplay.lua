
-- Shared behavior for product displays that have a "Contents" child based on a CatalogShop template.
HousingMarketProductDisplayMixin = {};

function HousingMarketProductDisplayMixin:OnLoad()
	-- In the housing market, products never display as selected.
	self.Contents:SetSelected(false);
end

function HousingMarketProductDisplayMixin:OnEnter()
	self.Contents:OnEnter();

	PlaySound(self.hoverSound or SOUNDKIT.HOUSING_MARKET_CATALOG_BUNDLE_HOVER);

	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:AddTooltipTitle(tooltip);
	self:AddTooltipLines(tooltip);

	local instructionText = (self.elementData.canPreview and self.instructionText) or HOUSING_BUNDLE_CLICK_TO_VIEW_IN_SHOP;
	GameTooltip_AddInstructionLine(tooltip, instructionText);

	tooltip:Show();
end

function HousingMarketProductDisplayMixin:OnLeave()
	self.Contents:OnLeave();
	GameTooltip_Hide();
end

function HousingMarketProductDisplayMixin:OnClick(button)
	if button == "RightButton" then
		self:ShowContextMenu();
	elseif self.elementData.canPreview then
		self:StartPreview();
	else
		-- Open non-previewable products in the shop
		C_HousingCatalog.HousingMarketActionViewInStore(self.elementData.productID);
		Blizzard_HousingCatalogUtil.OpenCatalogShopForProduct(self.elementData.productID);
	end
end

function HousingMarketProductDisplayMixin:Init(elementData)
	self.elementData = elementData;
	local productID = elementData.productID;
	self.Contents:SetProductInfo(CatalogShopUtil.GetProductInfo(productID));
end

function HousingMarketProductDisplayMixin:Reset()
	self.elementData = nil;
end

function HousingMarketProductDisplayMixin:AddTooltipTitle(tooltip)
	GameTooltip_SetTitle(tooltip, self.Contents:GetProductInfo().name);
end

function HousingMarketProductDisplayMixin:AddTooltipLines(tooltip)
	self:AddTooltipPrice(tooltip);
end

function HousingMarketProductDisplayMixin:AddTooltipPrice(tooltip)
	GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_PRICE_FORMAT:format(self.Contents:GetCurrentPrice()));
end

function HousingMarketProductDisplayMixin:ShowContextMenu()
	if not self.elementData then
		return;
	end

	MenuUtil.CreateContextMenu(self, function(_owner, rootDescription)
		rootDescription:SetTag("MENU_HOUSING_MARKET_PRODUCT");

		-- Items that cannot be previewed must be purchased directly from the shop and can't be added to the cart.
		if self.elementData.canPreview then
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

			local canAddToCart, errorText = self:CanAddToCart();
			addToCartButton:SetEnabled(canAddToCart);
			if not canAddToCart and errorText then
				addToCartButton:SetTooltip(function(tooltip, _elementDescription)
					GameTooltip_AddErrorLine(tooltip, errorText);
				end);
			end
		end

		if self.elementData.productID then
			rootDescription:CreateButton(HOUSING_MARKET_VIEW_IN_SHOP, function()
				C_HousingCatalog.HousingMarketActionViewInStore(self.elementData.productID);
				Blizzard_HousingCatalogUtil.OpenCatalogShopForProduct(self.elementData.productID);
			end);
		end
	end);
end

function HousingMarketProductDisplayMixin:CanAddToCart()
	-- Override in your derived Mixin.

	-- Returns whether the item can be added to the cart, and an optional error message if it can't.
	return true, nil;
end

function HousingMarketProductDisplayMixin:StartPreview()
	-- Override in your derived Mixin.
end

HousingMarketSmallProductDisplayMixin = {};

local function CreateContentsFrame(parent, contentsTemplate)
	local frame = CreateFrame("Button", nil, parent, contentsTemplate);
	frame:SetAsNonInteractive(true);

	-- Scale down to fit with the house chest size.
	frame:SetScale(0.717);
	frame:SetPoint("CENTER");

	-- In the housing market, products never display as selected.
	frame:SetSelected(false);
	return frame;
end

function HousingMarketSmallProductDisplayMixin:OnLoad()
	-- Overrides HousingMarketProductDisplayMixin.

	self.templateToContentsFrame = {};
end

function HousingMarketSmallProductDisplayMixin:Init(elementData)
	-- Overrides HousingMarketProductDisplayMixin.

	self.elementData = elementData;

	if self.Contents then
		self.Contents:Hide();
	end

	local productID = elementData.productID;
	local productInfo = CatalogShopUtil.GetProductInfo(productID);
	if not productInfo then
		return;
	end

	local useWideCard = false;
	local contentsTemplate = CatalogShopUtil.GetCardTemplate(useWideCard, productInfo.cardDisplayData.productType);
	self.Contents = GetOrCreateTableEntryByCallback(self.templateToContentsFrame, contentsTemplate, GenerateClosure(CreateContentsFrame, self));
	self.Contents:SetProductInfo(productInfo);
	self.Contents:Show();
end

function HousingMarketSmallProductDisplayMixin:OnDragStart()
	if self.elementData.canPreview then
		self:StartPreview();
	end
end

function HousingMarketSmallProductDisplayMixin:AddTooltipTitle(tooltip)
	-- Overrides HousingMarketProductDisplayMixin.

	local entryVariantID = self.elementData.entryVariantID;
	if entryVariantID and (entryVariantID.entryType == Enum.HousingCatalogEntryType.Decor) then
		local entryInfo = C_HousingCatalog.GetCatalogEntryInfo(self.elementData.entryVariantID);
		Blizzard_HousingCatalogUtil.AddDecorEntryTooltipTitle(tooltip, entryInfo);
	else
		HousingMarketProductDisplayMixin.AddTooltipTitle(self, tooltip);
	end
end

function HousingMarketSmallProductDisplayMixin:AddTooltipLines(tooltip)
	-- Overrides HousingMarketProductDisplayMixin.

	self:AddTooltipPrice(tooltip);

	if C_CatalogShop.IsProductIncludedInAnyBundle(self.elementData.productID) then
		GameTooltip_AddColoredLine(tooltip, HOUSING_DECOR_BUNDLE_DISCLAIMER, DISCLAIMER_TOOLTIP_COLOR);
	end
end

function HousingMarketSmallProductDisplayMixin:StartPreview()
	if self.elementData.canPreview then
		local entryVariantID = self.elementData.entryVariantID;
		if entryVariantID and (entryVariantID.entryType == Enum.HousingCatalogEntryType.Decor) then
			C_HousingBasicMode.StartPlacingPreviewDecor(entryVariantID.recordID);
		end
	end
end

HousingMarketBundleDisplayMixin = {};

function HousingMarketBundleDisplayMixin:AddTooltipLines(tooltip)
	-- Overrides HousingMarketProductDisplayMixin.

	local decorListString = "";
	for _i, decorEntry in ipairs(self.elementData.decorEntries) do
		local decorInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(Enum.HousingCatalogEntryType.Decor, decorEntry.decorID);
		if decorInfo then
			local entryString = HOUSING_BUNDLE_DECOR_ENTRY_FORMAT:format(decorInfo.name, decorEntry.quantity);
			decorListString = decorListString .. "|n- " .. entryString;
		end
	end

	for _i, productID in ipairs(self.elementData.nonDecorProducts) do
		local productInfo = CatalogShopUtil.GetProductInfo(productID);
		if productInfo then
			decorListString = decorListString .. "|n- " .. productInfo.name;
		end
	end

	GameTooltip_AddNormalLine(tooltip, HOUSING_BUNDLE_CONTENTS_FORMAT:format(decorListString));

	HousingMarketProductDisplayMixin.AddTooltipLines(self, tooltip);
end

function HousingMarketBundleDisplayMixin:StartPreview()
	-- Overrides HousingMarketProductDisplayMixin.
	C_HousingCatalog.HousingMarketActionViewBundle(self.elementData.productID);

	PlaySound(SOUNDKIT.HOUSING_MARKET_SELECT_BUNDLE);
	EventRegistry:TriggerEvent("HousingMarket.BundleSelected", self.elementData);
end

function HousingMarketBundleDisplayMixin:CanAddToCart()
	-- TODO:: Replace this global access pattern.
	if HouseEditorFrame.MarketShoppingCartFrame:IsBundleInCart(self.elementData.productID) then
		return false, HOUSING_BUNDLE_IN_CART;
	end

	return true, nil;
end
