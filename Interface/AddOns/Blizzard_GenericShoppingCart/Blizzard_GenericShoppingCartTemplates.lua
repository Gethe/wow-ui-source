
ShoppingCartVisualServices = {
	SetCartFrameShown = "SetCartFrameShown",
	SetCartShown = "SetCartShown",
	OnCartItemInteraction = "OnCartItemInteraction",
};

ShoppingCartVisualsFrameMixin = CreateFromMixins(ShoppingCartServiceRegistrantMixin);

function ShoppingCartVisualsFrameMixin:OnLoad()
	self.itemList = {};
	self.maxItemsToShow = self.maxItemsToShow or 3;

	self.CartVisibleContainer.Header.HideCartButton.eventNamespace = self.eventNamespace;
	self.CartVisibleContainer.Footer.ClearCartButton.eventNamespace = self.eventNamespace;
	self.CartVisibleContainer.Footer.PurchaseCartButton = CreateFrame("BUTTON", nil, self.CartVisibleContainer.Footer, self.purchaseButtonTemplate);
	self.CartVisibleContainer.Footer.PurchaseCartButton:SetPoint("LEFT", self.CartVisibleContainer.Footer.ClearCartButton, "RIGHT", 16, 0);

	self.CartHiddenContainer.ViewCartButton.eventNamespace = self.eventNamespace;
	self.CartHiddenContainer.PurchaseCartButton = CreateFrame("BUTTON", nil, self.CartHiddenContainer, self.purchaseButtonTemplate);
	self.CartHiddenContainer.PurchaseCartButton:SetPoint("LEFT", self.CartHiddenContainer.ViewCartButton, "RIGHT", 16, 0);

	self.ScrollBox = self.CartVisibleContainer.ScrollBox;
	self.ScrollBar = self.CartVisibleContainer.ScrollBar;

	self:SetupScrollBox();
	self:SetupDataManager();
	self:SetupDividerPredicates();

	self:AddServiceEvents(ShoppingCartVisualServices);

	self:FullUpdate();
	self:SetCartShown(false);
end

function ShoppingCartVisualsFrameMixin:SetupScrollBox()
	local DefaultPad = 0;
	local DefaultSpacing = 1;
	local view = CreateScrollBoxListLinearView(DefaultPad, DefaultPad, DefaultPad, DefaultPad, DefaultSpacing);

	local function InitializeItem(button, elementData)
		button:InitItem(elementData);
		button:SetSelection(self.selectionBehavior:IsElementDataSelected(elementData));

		button:SetScript("OnClick", function(btn)
			self.selectionBehavior:ToggleSelect(btn);
			btn:SetSelection(self.selectionBehavior:IsElementDataSelected(elementData));
		end);
	end

	local GetElementInitInfo = self:GetElementInitInfoFunc();

	view:SetElementFactory(function(factory, elementData)
		local template, initFunc = GetElementInitInfo(elementData);
		factory(template, initFunc);
	end);

	if self.CustomElementExtentCalc then
		view:SetElementExtentCalculator(self.CustomElementExtentCalc);
	end

	local padding = view:GetPadding();
	local padSize = self.padSize or 12;
	self.spacingSize = self.spacingSize or 8;
	padding:SetTop(4);
	padding:SetLeft(padSize);
	padding:SetRight(padSize);
	padding:SetSpacing(self.spacingSize);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local function OnSelectionChanged(o, elementData, selected)
		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelection(selected);
		end
	end;

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox, SelectionBehaviorFlags.MultiSelect, SelectionBehaviorFlags.Intrusive);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);

	local dataProvider = CreateDataProvider();
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function ShoppingCartVisualsFrameMixin:RefreshScrollElements()
	self.ScrollBox:ForEachFrame(function(element, elementData)
		if element.Refresh then
			element:Refresh();
		end
	end);
end

function ShoppingCartVisualsFrameMixin:RefreshDividers()
	local dataProvider = self.ScrollBox:GetDataProvider();

	local indicesToRemove = {};
	for index, currElementData in dataProvider:EnumerateEntireRange() do
		if currElementData.isFooter or currElementData.isHeader then
			table.insert(indicesToRemove, index);
		end
	end

	local numIndicesRemoved = 0;
	for index, indexToRemove in ipairs(indicesToRemove) do
		-- Need to add the offset since indices update as we remove
		dataProvider:RemoveIndex(indexToRemove - numIndicesRemoved);
		numIndicesRemoved = numIndicesRemoved + 1;
	end

	local dataProviderSize = dataProvider:GetSize();
	if dataProviderSize > 1 then
		local prevElementData = nil;
		local elementsToAdd = {};
		for index, currElementData in dataProvider:EnumerateEntireRange() do
			if self.HeaderInsertionPredicate and self.HeaderInsertionPredicate(prevElementData, currElementData) then
				local headerElementData = {
					isHeader = true,
					title = currElementData.name,
					bundleRef = currElementData.bundleRef,
				};

				table.insert(elementsToAdd, { indexToInsertAt = index, elementData = headerElementData });
			end

			if self.FooterInsertionPredicate and self.FooterInsertionPredicate(prevElementData, currElementData) then
				local footerElementData = {
					isFooter = true,
					bundleRef = prevElementData.bundleRef,
				}

				table.insert(elementsToAdd, { indexToInsertAt = index, elementData = footerElementData });
			end

			prevElementData = currElementData;
		end

		local numItemsAdded = 0; 
		for index, elementToAdd in ipairs(elementsToAdd) do
			dataProvider:InsertAtIndex(elementToAdd.elementData, elementToAdd.indexToInsertAt + numItemsAdded);
			numItemsAdded = numItemsAdded + 1;
		end
	end
end

function ShoppingCartVisualsFrameMixin:GetCartCurrencyInfo()
	-- Override in child mixin
	local currencyAmount = GetMoney();
	local icon = "Interface\\Icons\\inv_misc_coin_01";
	local iconIsAtlas = false;

	return currencyAmount, icon, iconIsAtlas;
end

function ShoppingCartVisualsFrameMixin:FullUpdate()
	self:UpdateScrollBar();
	self:RefreshScrollElements();

	local retainScrollPosition = true;
	self.ScrollBox:Rebuild(retainScrollPosition);

	self:UpdateNumItemsInCart();
	self:UpdateCurrencyTotal();

	self:RefreshDividers();
end

function ShoppingCartVisualsFrameMixin:UpdateCurrencyTotal()
	local playerCurrencyAmount, currencyIcon, iconIsAtlas = self:GetCartCurrencyInfo();
	if iconIsAtlas then
		self.PlayerTotalCurrencyDisplay.CurrencyIcon:SetAtlas(currencyIcon);
	else
		self.PlayerTotalCurrencyDisplay.CurrencyIcon:SetTexture(currencyIcon);
	end

	self.PlayerTotalCurrencyDisplay.CurrencyTotal:SetText(playerCurrencyAmount);
	
	self.PlayerTotalCurrencyDisplay:SetPoint("BOTTOMLEFT", self.CartVisibleContainer:IsShown() and self.CartVisibleContainer or self.CartHiddenContainer, "TOPLEFT", 40, 8);
	self.PlayerTotalCurrencyDisplay:SetPoint("BOTTOMRIGHT", self.CartVisibleContainer:IsShown() and self.CartVisibleContainer or self.CartHiddenContainer, "TOPRIGHT", -40, 8);
end

function ShoppingCartVisualsFrameMixin:UpdateScrollBar()
	local itemCount = self.ScrollBox:GetDataProvider():GetSize();
	local itemHeight = 32;
	if self.sizingItemTemplate then
		local templateInfo = C_XMLUtil.GetTemplateInfo(self.sizingItemTemplate);
		itemHeight = templateInfo and templateInfo.height or itemHeight;
	end

	local totalHeight = itemCount * itemHeight + (itemCount - 1) * (self.spacingSize or 8) + 4;
	local maxHeight = (self.maxItemsToShow or 3) * itemHeight + ((self.maxItemsToShow or 3) - 1) * (self.spacingSize or 8) + 4;

	self.ScrollBox:SetHeight(math.min(totalHeight, maxHeight));
	if itemCount > (self.maxItemsToShow or 3) then
		self.ScrollBar:Show();
		self.ScrollBox:SetPoint("TOPLEFT", self.CartVisibleContainer.Header, "BOTTOMLEFT", 16, -16);
	else
		self.ScrollBar:Hide();
		self.ScrollBox:SetPoint("TOPLEFT", self.CartVisibleContainer.Header, "BOTTOMLEFT", 20, -16);
	end

	if self.CartVisibleContainer:IsShown() then
		local layoutSpacingTotal = 84;
		self.CartVisibleContainer:SetHeight(self.CartVisibleContainer.Header:GetHeight() + self.ScrollBox:GetHeight() + self.CartVisibleContainer.Footer:GetHeight() + layoutSpacingTotal);
	elseif self.CartHiddenContainer:IsShown() then
		self:SetHeight(self.CartHiddenContainer:GetHeight());
	end
end

function ShoppingCartVisualsFrameMixin:SetCartFrameShown(isShown, preserveCartState)
	if not preserveCartState and not self:IsShown() and isShown then
		self:SetCartShown(false);
	end

	self:SetShown(isShown);
end

function ShoppingCartVisualsFrameMixin:SetCartShown(isShown)
	self.CartVisibleContainer:SetShown(isShown);
	self.CartHiddenContainer:SetShown(not isShown);

	self:FullUpdate();
end

function ShoppingCartVisualsFrameMixin:OnCartItemInteraction()
	-- TODO: Implement placing in world from here
end

function ShoppingCartVisualsFrameMixin:UpdateCartTotal(cartList)
	local totalPrice = self:GetTotalPrice(cartList);

	-- Only show the total after sales on the buttons
	self.CartVisibleContainer.Footer.PurchaseCartButton.PriceContainer:SetPrice(totalPrice, nil);
	self.CartHiddenContainer.PurchaseCartButton.PriceContainer:SetPrice(totalPrice, nil);
end

function ShoppingCartVisualsFrameMixin:GetEventNamespace()
	-- implement in derived mixin
end

function ShoppingCartVisualsFrameMixin:GetElementInitInfoFunc()
	-- implement in derived mixin
end

function ShoppingCartVisualsFrameMixin:SetupDataManager()
	-- implement in derived mixin
end

function ShoppingCartVisualsFrameMixin:GetTotalPrice(cartList)
	-- implement in derived mixin
end

function ShoppingCartVisualsFrameMixin:GetNumItemsInCart()
	-- implement in derived mixin

	return 0;
end

function ShoppingCartVisualsFrameMixin:AddItemToList(item)
	-- override in derived mixin
	local dataProvider = self.ScrollBox:GetDataProvider();
	dataProvider:Insert(item);
end

function ShoppingCartVisualsFrameMixin:RemoveItemFromList(itemIndex, _item)
	-- override in derived mixin
	local dataProvider = self.ScrollBox:GetDataProvider();
	dataProvider:RemoveIndex(itemIndex);
end

function ShoppingCartVisualsFrameMixin:UpdateNumItemsInCart()
	-- extend in derived mixin
	local itemsInCart = self:GetNumItemsInCart() ~= 0;
	self:SetPurchaseButtonsEnabled(itemsInCart);

	local cartIsShown = self.CartVisibleContainer:IsShown();
	if not itemsInCart and cartIsShown then
		-- If there's no items in the cart, force it hidden
		self:SetCartShown(false);
	end
end

function ShoppingCartVisualsFrameMixin:SetPurchaseButtonsEnabled(buttonsEnabled)
	self.CartVisibleContainer.Footer.PurchaseCartButton:SetEnabled(buttonsEnabled);
	self.CartHiddenContainer.PurchaseCartButton:SetEnabled(buttonsEnabled);
end

function ShoppingCartVisualsFrameMixin:SetupDividerPredicates()
	-- implement in derived mixin
	self.HeaderInsertionPredicate = nil;
	self.FooterInsertionPredicate = nil;
end

ShoppingCartPriceContainerMixin = {};

function ShoppingCartPriceContainerMixin:OnLoad()
	self.Price = self.PriceContainer.Price;
	self.SalePrice = self.PriceContainer.SalePrice;

	local fontObject = GameFontNormalMed3;
	if self.isLarge then
		fontObject = GameFontNormalLarge;
	end

	self.Price:SetFontObject(fontObject);
	self.SalePrice:SetFontObject(fontObject);

	self:SetPrice(0, nil);
end

function ShoppingCartPriceContainerMixin:SetPrice(price, salePrice)
	local itemOnSale = salePrice and salePrice < price;
	local playerCurrencyAmount, currencyIcon, iconIsAtlas = self:GetCurrencyInfo();
	playerCurrencyAmount = playerCurrencyAmount or 0;

	if iconIsAtlas then
		self.PriceIcon:SetAtlas(currencyIcon);
	else
		self.PriceIcon:SetTexture(currencyIcon);
	end

	local priceText, salePriceText = self:GetPriceText(price, SalePrice, playerCurrencyAmount);
	self.Price:SetText(priceText);
	self.Price:SetHeight(self.Price:GetStringHeight());

	if itemOnSale then
		self.SalePrice:SetText(salePriceText);
		self.SalePrice:SetHeight(self.SalePrice:GetStringHeight());
	else
		self.SalePrice:SetHeight(1);
	end

	self.SalePrice:SetShown(itemOnSale);

	self.PriceContainer:SetHeight(self.Price:GetHeight() + self.SalePrice:GetHeight());

	self.PriceContainer.PriceStrikethrough:SetShown(itemOnSale);
end

function ShoppingCartPriceContainerMixin:GetPriceText(price, salePrice, playerCurrencyAmount)
	local itemOnSale = salePrice and salePrice < price;
	local priceText = "";
	local salePriceText = "";
	if playerCurrencyAmount then
		if itemOnSale then
			priceText = GRAY_FONT_COLOR:WrapTextInColorCode(price);
			
			if salePrice > playerCurrencyAmount then
				salePriceText = ORANGE_FONT_COLOR:WrapTextInColorCode(salePrice);
			else
				salePriceText = GREEN_FONT_COLOR:WrapTextInColorCode(salePrice);
			end
		else
			if price > playerCurrencyAmount then
				priceText = GRAY_FONT_COLOR:WrapTextInColorCode(price);
			else
				priceText = WHITE_FONT_COLOR:WrapTextInColorCode(price);
			end
		end
	end

	return priceText, salePriceText;
end

function ShoppingCartPriceContainerMixin:GetCurrencyInfo()
	local playerCurrencyAmount = GetMoney();
	local currencyIcon = "Interface\\Icons\\inv_misc_coin_01";
	local iconIsAtlas = false;

	return playerCurrencyAmount, currencyIcon, iconIsAtlas;
end

ShoppingCartViewCartButtonMixin = {};

function ShoppingCartViewCartButtonMixin:UpdateNumItemsInCart(numItemsInCart)
	local buttonEnabled = numItemsInCart ~= 0;
	self.ItemCountBG:SetShown(buttonEnabled);

	self.ItemCountText:SetShown(buttonEnabled);
	self.ItemCountText:SetText(numItemsInCart);

	self:SetEnabled(buttonEnabled);
end

ShoppingCartShowCartServiceMixin = {};

function ShoppingCartShowCartServiceMixin:GetEventData()
	local shown = true;
	return shown;
end

ShoppingCartHideCartServiceMixin = {};

function ShoppingCartHideCartServiceMixin:GetEventData()
	local shown = false;
	return shown;
end

ShoppingCartRemoveFromCartItemButtonContainerMixin = {}

function ShoppingCartRemoveFromCartItemButtonContainerMixin:OnEnter()
	self.mouseOver = true;
	self.RemoveFromListButton:Show();
end

function ShoppingCartRemoveFromCartItemButtonContainerMixin:OnLeave()
	self.mouseOver = false;
	if not self.RemoveFromListButton.mouseOver then
		self.RemoveFromListButton:Hide();
	end
end

ShoppingCartRemoveFromCartItemButtonMixin = {}

function ShoppingCartRemoveFromCartItemButtonMixin:OnEnter()
	self.mouseOver = true;
end

function ShoppingCartRemoveFromCartItemButtonMixin:OnLeave()
	self.mouseOver = false;

	if not self:GetParent().mouseOver then
		self:Hide();
	end
end

ShoppingCartPlayerTotalCurrencyMixin = {};

function ShoppingCartPlayerTotalCurrencyMixin:OnEnter()
	if self.tooltip then
		local wrap = true;
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, self.tooltipTitle);
		GameTooltip_AddNormalLine(GameTooltip, self.tooltip, wrap);
		GameTooltip:Show();
	end
end

function ShoppingCartPlayerTotalCurrencyMixin:OnLeave()
	GameTooltip_Hide(GameTooltip);
end
