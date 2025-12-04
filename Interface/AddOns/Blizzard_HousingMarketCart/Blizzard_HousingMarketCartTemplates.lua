
HOUSING_MARKET_EVENT_NAMESPACE = "HousingMarketEvents";

HousingMarketCartFrameMixin = CreateFromMixins(ShoppingCartVisualsFrameMixin);

function HousingMarketCartFrameMixin:OnLoad()
	C_CatalogShop.RefreshVirtualCurrencyBalance(Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE);

	self.CustomElementExtentCalc = function(dataIndex, elementData)
		local GetElementInitInfo = self:GetElementInitInfoFunc();
		local template, _ = GetElementInitInfo(elementData);
		local templateInfo = C_XMLUtil.GetTemplateInfo(template);
		local height = templateInfo.height;

		if elementData.showBottomBrace then
			-- Value is mirrored in 
			height = height + elementData.bottomBraceOffset;
		end

		return height;
	end;

	ShoppingCartVisualsFrameMixin.OnLoad(self);

	local function ResetAnim()
		self.isPendingAddedToCartAnim = false;
		self.CartUpdatedFlipbookTexture:Hide();
	end

	self.CartUpdatedFlipbookAnim:SetScript("OnFinished", ResetAnim);

	self.PlayerTotalCurrencyDisplay.tooltipTitle = HOUSING_MARKET_HEARTHSTEEL_TOOLTIP;
	self.PlayerTotalCurrencyDisplay.tooltip = HOUSING_MARKET_HEARTHSTEEL_TOOLTIP_DESC;
end

local HousingMarketCartDynamicEvents = {
	"CATALOG_SHOP_VIRTUAL_CURRENCY_BALANCE_UPDATE",
};

function HousingMarketCartFrameMixin:OnShow()
	ShoppingCartVisualsFrameMixin.OnShow(self);

	if self.isPendingAddedToCartAnim and not self.CartVisibleContainer:IsShown() then
		self.CartUpdatedFlipbookTexture:Show();
		self.CartUpdatedFlipbookAnim:Play();
	else
		self.isPendingAddedToCartAnim = false;
	end

	FrameUtil.RegisterFrameForEvents(self, HousingMarketCartDynamicEvents);

	-- Force a full update on show if anything has gone stale since the
	-- last time we had the cart shown
	self:FullUpdate();

	local currencyRefreshTickTime = 20;
	self.CurrencyRefreshTicker = C_Timer.NewTicker(currencyRefreshTickTime, function()
		C_CatalogShop.RefreshVirtualCurrencyBalance(Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE);
	end);
end

function HousingMarketCartFrameMixin:OnHide()
	ShoppingCartVisualsFrameMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, HousingMarketCartDynamicEvents);

	if self.CurrencyRefreshTicker then
		self.CurrencyRefreshTicker:Cancel();
		self.CurrencyRefreshTicker = nil;
	end
end

function HousingMarketCartFrameMixin:OnEvent(event, ...)
	if event == "CATALOG_SHOP_VIRTUAL_CURRENCY_BALANCE_UPDATE" then
		local vcCode, _balance = ...;
		if vcCode == Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE then
			self:UpdateCurrencyTotal();
		end
	end
end

function HousingMarketCartFrameMixin:GetEventNamespace()
	return HOUSING_MARKET_EVENT_NAMESPACE;
end

function HousingMarketCartFrameMixin:SetCartShown(isShown)
	if isShown then
		PlaySound(SOUNDKIT.HOUSING_MARKET_MAXIMIZE_CART);
	else
		PlaySound(SOUNDKIT.HOUSING_MARKET_MINIMIZE_CART);
	end

	ShoppingCartVisualsFrameMixin.SetCartShown(self, isShown);
end

function HousingMarketCartFrameMixin:GetElementInitInfoFunc()
	local function InitializeItem(button, elementData)
		button:InitItem(elementData);

		if elementData.decorGUID then
			if C_HousingCatalog.IsPreviewCartItemShown(elementData.decorGUID) then
				self.selectionBehavior:Select(button);
			else
				self.selectionBehavior:Deselect(button);
			end
		end

		button:SetSelection(self.selectionBehavior:IsElementDataSelected(elementData));

		button:SetScript("OnClick", function(btn)
			if elementData.decorGUID then
				self.selectionBehavior:ToggleSelect(btn);

				local selected = self.selectionBehavior:IsElementDataSelected(elementData);
				btn:SetSelection(selected);
				if selected then
					PlaySound(SOUNDKIT.HOUSING_MARKET_SHOW_ITEM);
				else
					PlaySound(SOUNDKIT.HOUSING_MARKET_HIDE_ITEM);
				end
				C_HousingCatalog.SetPreviewCartItemShown(elementData.decorGUID, selected);
			end
		end);
	end

	local function InitializeBundleHeader(bundleHeader, elementData)
		bundleHeader:Init(elementData);
	end

	local function InitializeBundleFooter(bundleFooter, elementData)
		bundleFooter:Init(elementData);
	end

	local function InitializeBundle(bundleParent, elementData)
		bundleParent:InitItem(elementData);
	end

	return function(elementData)
		if elementData.isHeader then
			return "HousingMarketCartBundleHeaderTemplate", InitializeBundleHeader;
		elseif elementData.isFooter then
			return "HousingMarketCartBundleFooterTemplate", InitializeBundleFooter;
		elseif elementData.isBundleParent then
			return "HousingMarketCartBundleTemplate", InitializeBundle;
		elseif elementData.isBundleChild then
			return "HousingMarketCartBundleItemTemplate", InitializeItem;
		end

		return "HousingMarketCartItemTemplate", InitializeItem;
	end
end

local function HousingMarketPurchaseCartOnAccept(popup)
	C_CatalogShop.BulkPurchaseProducts(popup.data.productIDList);
	-- Start the timeout timer
	popup.data.timeoutCallback();
end

local function HousingMarketPurchaseCartOnEvent(popup, event, ...)
	return event == "BULK_PURCHASE_RESULT_RECEIVED";
end

StaticPopupDialogs["HOUSING_MARKET_PURCHASE_CONFIRMATION"] = {
	text = HOUSING_MARKET_PURCHASE_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = GenerateClosure(StaticPopup_OnAcceptWithSpinner, HousingMarketPurchaseCartOnAccept, HousingMarketPurchaseCartOnEvent, {"BULK_PURCHASE_RESULT_RECEIVED"}, 0),
	exclusive = 1,
	fullScreenCover = true,
};

StaticPopupDialogs["HOUSING_MARKET_SLOW_PURCHASE"] = {
	text = HOUSING_MARKET_PURCHASE_SLOW_DESC,
	button1 = ACCEPT,
	exclusive = 1,
	fullScreenCover = true,
	hideOnEscape = true,
};

function HousingMarketCartFrameMixin:SetupDataManager()
	self.CartDataManager = CreateFromMixins(HousingMarketCartDataManagerMixin);
	self.CartDataManager:Init(self.eventNamespace);
	self.CartDataManager:SetRemovalPredicate(function(itemToRemove, itemToCheck)
		-- Need to compare something more unique
		return itemToRemove.decorGUID and itemToRemove.decorGUID == itemToCheck.decorGUID;
	end);

	self.CartDataManager:SetUpdateCartCallback(function(cartList)
		if self:IsShown() then
			self:FullUpdate();
		end

		self:UpdateCartTotal(cartList);

		-- Clear the purchase popup since it could've changed
		StaticPopup_Hide("HOUSING_MARKET_PURCHASE_CONFIRMATION");

		EventRegistry:TriggerEvent(HOUSING_MARKET_EVENT_NAMESPACE .. ".CartUpdated");
	end);

	self.CartDataManager:SetAddToCartCallback(function(cartItem)
		if cartItem.bundleCatalogShopProductID then
			PlaySound(SOUNDKIT.HOUSING_MARKET_ADD_BUNDLE_TO_CART);
		else
			PlaySound(SOUNDKIT.HOUSING_MARKET_ADD_SINGLE_ITEM_TO_CART);
		end

		self:AddItemToList(cartItem);

		RunNextFrame(function()
			-- Frame doesn't get hidden until after adding to the list upon pulling from the catalog
			self.isPendingAddedToCartAnim = not self:IsShown();

			if not self.isPendingAddedToCartAnim then
				self.CartUpdatedFlipbookTexture:Show();
				self.CartUpdatedFlipbookAnim:Play();
			end
		end);
	end);

	self.CartDataManager:SetRemoveFromCartCallback(function(itemIndex, cartItem)
		PlaySound(SOUNDKIT.HOUSING_MARKET_REMOVE_SINGLE_ITEM_FROM_CART);
		self:RemoveItemFromList(itemIndex, cartItem);
	end);

	self.CartDataManager:SetClearCartCallback(function()
		PlaySound(SOUNDKIT.HOUSING_MARKET_REMOVE_ALL_ITEMS_ACTION);

		local dataProvider = CreateDataProvider();
		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	end);

	self.CartDataManager:SetPlaceInWorldCallback(function(_placeItemData)
		self:FullUpdate();
	end);

	self.CartDataManager:SetPurchaseCartCallback(function(purchaseList)
		PlaySound(SOUNDKIT.HOUSING_MARKET_PURCHASE_BUTTON);

		local productIDList = {};
		local totalPrice = 0;

		for _, item in ipairs(purchaseList) do
			local productID = nil;
			if item.productID and item.productID ~= 0 then
				productID = item.productID;
			elseif item.isBundleParent and item.bundleCatalogShopProductID and item.bundleCatalogShopProductID ~= 0 then
				productID = item.bundleCatalogShopProductID;
			end

			if productID then
				table.insert(productIDList, productID);
				totalPrice = totalPrice + (item.salePrice or item.price);
			end
		end

		local function PurchaseTimeoutCB()
			self.CartDataManager.timedout = false;

			local timeoutTime = 20;
			self.CartDataManager.timeoutTimer = C_Timer.NewTimer(timeoutTime, function()
				StaticPopup_Hide("HOUSING_MARKET_PURCHASE_CONFIRMATION");
				StaticPopup_Show("HOUSING_MARKET_SLOW_PURCHASE");

				self.CartDataManager.timeoutTimer = nil;
				self.CartDataManager.timedout = true;
			end);
		end

		local popupData = {};
		popupData.productIDList = productIDList;
		popupData.timeoutCallback = PurchaseTimeoutCB;

		local hearthsteelBalance, _icon, _iconIsAtlas = self:GetCartCurrencyInfo();
		if totalPrice > hearthsteelBalance then
			CatalogShopTopUpFlowInboundInterface.SetDesiredQuantity(totalPrice - hearthsteelBalance);
			CatalogShopTopUpFlowInboundInterface.SetShown(true, self:GetParent());
		else
			if #productIDList > 1 then
				StaticPopup_Show("HOUSING_MARKET_PURCHASE_CONFIRMATION", Blizzard_HousingCatalogUtil.FormatPrice(totalPrice), nil, popupData);
			end
		end
	end);
end

function HousingMarketCartFrameMixin:SetupDividerPredicates()
	-- We're using the bundle braces here so no need to use the dividers
	self.HeaderInsertionPredicate = nil;
	self.FooterInsertionPredicate = nil;
end

function HousingMarketCartFrameMixin:GetTotalPrice(cartList)
	local totalPrice = 0;
	for _, item in ipairs(cartList) do
		totalPrice = totalPrice + (item.salePrice or item.price);
	end

	return totalPrice;
end

function HousingMarketCartFrameMixin:GetNumItemsInCart()
	return self.CartDataManager:GetNumItemsInCart();
end

function HousingMarketCartFrameMixin:AddItemToList(item)
	local dataProvider = self.ScrollBox:GetDataProvider();
	dataProvider:Insert(item);
end

function HousingMarketCartFrameMixin:RemoveItemFromList(_itemIndex, item)
	local dataProvider = self.ScrollBox:GetDataProvider();
	local dataProviderIndex = dataProvider:FindIndex(item);
	dataProvider:RemoveIndex(dataProviderIndex);

	if item.decorGUID then
		C_HousingCatalog.DeletePreviewCartDecor(item.decorGUID);
	end
end

function HousingMarketCartFrameMixin:UpdateNumItemsInCart()
	local numItemsInCart = self.CartDataManager:GetNumItemsInCart();
	self.CartVisibleContainer.Header.Title:SetText(string.format(GENERIC_CART_PREVIEW_TITLE, numItemsInCart));
	self.CartHiddenContainer.ViewCartButton:UpdateNumItemsInCart(numItemsInCart);

	ShoppingCartVisualsFrameMixin.UpdateNumItemsInCart(self);
end

function HousingMarketCartFrameMixin:IsBundleInCart(bundleCatalogShopProductID)
	return self.CartDataManager:IsBundleInCart(bundleCatalogShopProductID);
end

function HousingMarketCartFrameMixin:GetNumDecorPlaced(bundleCatalogShopProductID, decorID)
	return self.CartDataManager:GetNumDecorPlaced(bundleCatalogShopProductID, decorID);
end

function HousingMarketCartFrameMixin:GetCartCurrencyInfo()
	local hearthsteelBalance = tonumber(C_CatalogShop.GetVirtualCurrencyBalance(Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE));
	local hearthsteelIcon = "hearthsteel-icon-32x32";
	local iconIsAtlas = true;

	return hearthsteelBalance, hearthsteelIcon, iconIsAtlas;
end

HousingMarketCartDataServiceEvents = {
	PlaceInWorld = "PlaceInWorld",
};

HousingMarketCartDataManagerMixin = CreateFromMixins(ShoppingCartDataManagerMixin);

function HousingMarketCartDataManagerMixin:Init(eventNamespace)
	ShoppingCartDataManagerMixin.Init(self, eventNamespace);

	Dispatcher:RegisterEvent("BULK_PURCHASE_RESULT_RECEIVED", self);
	Dispatcher:RegisterEvent("HOUSING_DECOR_PREVIEW_LIST_UPDATED", self);
	Dispatcher:RegisterEvent("HOUSING_DECOR_ADD_TO_PREVIEW_LIST", self);
	Dispatcher:RegisterEvent("HOUSING_DECOR_PREVIEW_LIST_REMOVE_FROM_WORLD", self);

	self:AddServiceEvents(HousingMarketCartDataServiceEvents);
end

function HousingMarketCartDataManagerMixin:GetNumItemsInCart()
	local count = 0;
	for _i, cartItem in ipairs(self.cartList) do
		-- Bundles count once, from the isBundleParent entry.
		if not cartItem.isBundleChild then
			count = count + 1;
		end
	end

	return count;
end

function HousingMarketCartDataManagerMixin:IsBundleInCart(bundleCatalogShopProductID)
	for _i, cartItem in ipairs(self.cartList) do
		if cartItem.bundleCatalogShopProductID == bundleCatalogShopProductID then
			return true;
		end
	end

	return false;
end

function HousingMarketCartDataManagerMixin:GetNumDecorPlaced(bundleCatalogShopProductID, decorID)
	local numPlaced = 0;
	for _i, cartItem in ipairs(self.cartList) do
		if (cartItem.decorID == decorID) and (cartItem.bundleCatalogShopProductID == bundleCatalogShopProductID) and cartItem.decorGUID then
			numPlaced = numPlaced + 1;
		end
	end

	return numPlaced;
end

local bundleRefCount = 0;

function HousingMarketCartDataManagerMixin:AddToCart(item)
	local bundleCatalogShopProductID = item.bundleCatalogShopProductID;
	if bundleCatalogShopProductID then
		local bundleAlreadyAdded = false;
		for _i, cartItem in ipairs(self.cartList) do
			if cartItem.bundleCatalogShopProductID == bundleCatalogShopProductID then
				bundleAlreadyAdded = true;

				if (cartItem.decorID == item.decorID) and not cartItem.decorGUID then
					-- Update the decorGUID for the existing item in the bundle
					cartItem.decorGUID = item.decorGUID;
					self:UpdateCart();
					return;
				end
			end
		end

		if bundleAlreadyAdded then
			-- This is a bundle and already in the cart. Nothing to do here.
			return;
		end
	end

	if bundleCatalogShopProductID or item.id then
		if bundleCatalogShopProductID then
			local shopInfo = CatalogShopUtil.GetProductInfo(bundleCatalogShopProductID);
			if not shopInfo then
				return;
			end

			local bundleInfo = C_HousingCatalog.GetBundleInfo(bundleCatalogShopProductID);
			if not bundleInfo then
				return;
			end

			local bundleParentInfo = {
				name = shopInfo.name,
				price = bundleInfo.originalPrice or bundleInfo.price,
				salePrice = bundleInfo.price,
				isBundleParent = true,
				bundleCatalogShopProductID = bundleCatalogShopProductID,
			};

			bundleParentInfo.bundleChildren = {};

			for _i, decorEntry in ipairs(bundleInfo.decorEntries) do
				local decorID = decorEntry.decorID;
				local tryGetOwnedInfo = false;
				local decorInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(Enum.HousingCatalogEntryType.Decor, decorID, tryGetOwnedInfo);
				if decorInfo then
					local itemID = decorInfo.itemID;

					local itemInstance = Item:CreateFromItemID(itemID);
					if not itemInstance:IsRecordDataCached() then
						itemInstance:ContinueOnItemLoad(function()
							self:OnUpdateItemInfo(itemID);
						end);
					end

					local childItem = {
						id = itemID,
						isBundleChild = true,
						name = C_Item.GetItemNameByID(itemID),
						icon = C_Item.GetItemIconByID(itemID),
						decorID = decorID,
						bundleCatalogShopProductID = bundleCatalogShopProductID,
						price = 0,
					};

					for _j = 1, decorEntry.quantity do
						if item.decorGUID and (item.decorID == decorID) then
							local bundleChild = CopyTable(childItem);
							bundleChild.decorGUID = item.decorGUID;
							table.insert(bundleParentInfo.bundleChildren, bundleChild);
							item.decorGUID = nil;
						else
							table.insert(bundleParentInfo.bundleChildren, CopyTable(childItem));
						end
					end
				end
			end

			item = bundleParentInfo;
		end

		ShoppingCartDataManagerMixin.AddToCart(self, item);

		if item.isBundleParent then
			item.bundleRef = bundleRefCount;

			for index, subItem in ipairs(item.bundleChildren) do
				subItem.bundleRef = item.bundleRef;
				if index == #(item.bundleChildren) then
					subItem.showBottomBrace = true;
					subItem.bottomBraceOffset = 15;
				else
					subItem.showBottomBrace = false;
					subItem.bottomBraceOffset = 0;
				end

				subItem.showTopBrace = false;
				ShoppingCartDataManagerMixin.AddToCart(self, subItem);
			end

			bundleRefCount = bundleRefCount + 1;
		else
			item.bundleRef = nil;
		end
	end
end

function HousingMarketCartDataManagerMixin:RemoveFromCartInternal(index, currCartItem)
	index, currCartItem = ShoppingCartDataManagerMixin.RemoveFromCartInternal(self, index, currCartItem);

	if currCartItem.isBundleParent then
		-- Remove all the bundle children as well
		local numRemovedItems = 0;
		local totalItems = #self.cartList;
		for i = 1, totalItems do
			local elementIndex = i - numRemovedItems;
			local currElementData = self.cartList[elementIndex];
			if not currElementData then
				break;
			end

			if currElementData.bundleCatalogShopProductID == currCartItem.bundleCatalogShopProductID then
				index, currCartItem = ShoppingCartDataManagerMixin.RemoveFromCartInternal(self, elementIndex, currElementData);
				numRemovedItems = numRemovedItems + 1;
			end
		end
	end

	return index, currCartItem;
end

StaticPopupDialogs["HOUSING_MARKET_CLEAR_CART_CONFIRMATION"] = {
	text = HOUSING_CATALOG_CART_WARNING,
	button1 = ACCEPT,
	button2 = CANCEL,
	--OnAccept set in ClearCart,
};

function HousingMarketCartDataManagerMixin:ClearCartInternal()
	for _i, cartItem in ipairs(self.cartList) do
		if cartItem.decorGUID then
			C_HousingCatalog.DeletePreviewCartDecor(cartItem.decorGUID);
		end
	end

	ShoppingCartDataManagerMixin.ClearCart(self);
end

function HousingMarketCartDataManagerMixin:ClearCart(requiresConfirmation)
	PlaySound(SOUNDKIT.HOUSING_MARKET_REMOVE_ALL_ITEMS_BUTTON);

	if #self.cartList < 1 then
		return;
	end

	if requiresConfirmation then
		local function ClearCartCB(_dialog, _data)
			self:ClearCartInternal();
		end

		StaticPopupDialogs["HOUSING_MARKET_CLEAR_CART_CONFIRMATION"].OnAccept = ClearCartCB;
		StaticPopup_Show("HOUSING_MARKET_CLEAR_CART_CONFIRMATION");
	else
		self:ClearCartInternal();
	end
end

StaticPopupDialogs["HOUSING_MARKET_PURCHASE_FAILURE"] = {
	text = HOUSING_MARKET_PURCHASE_FAILURE,
	button1 = ACCEPT,
	exclusive = 1,
	fullScreenCover = true,
};

function HousingMarketCartDataManagerMixin:BULK_PURCHASE_RESULT_RECEIVED(...)
	C_CatalogShop.RefreshVirtualCurrencyBalance(Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE);

	if self.timeoutTimer then
		self.timeoutTimer:Cancel();
		self.timeoutTimer = nil;
	end

	if self.timedout then
		self.timedout = false;
		return;
	end

	local wasSuccess = ...;
	if wasSuccess then
		PlaySound(SOUNDKIT.HOUSING_MARKET_PURCHASE_CELEBRATION);
	
		-- Clear the cart on a successful purchase
		local requiresConfirmation = false;
		self:ClearCart(requiresConfirmation);
	else
		StaticPopup_Show("HOUSING_MARKET_PURCHASE_FAILURE");
	end
end

function HousingMarketCartDataManagerMixin:HOUSING_DECOR_PREVIEW_LIST_UPDATED()
	
end

function HousingMarketCartDataManagerMixin:HOUSING_DECOR_ADD_TO_PREVIEW_LIST(...)
	local itemToAdd = ...;
	if self.pendingPlaceCartID then
		for _i, cartItem in ipairs(self.cartList) do
			if itemToAdd.id == cartItem.id and cartItem.cartID == self.pendingPlaceCartID then
				cartItem.decorGUID = itemToAdd.decorGUID;
				self.pendingPlaceCartID = nil;
				break;
			end
		end
	else
		self:AddToCart(itemToAdd);
	end
end

function HousingMarketCartDataManagerMixin:HOUSING_DECOR_PREVIEW_LIST_REMOVE_FROM_WORLD(...)
	local decorGUID = ...;
	
	for _i, cartItem in ipairs(self.cartList) do
		if cartItem.decorGUID == decorGUID then
			cartItem.decorGUID = nil;
			self:UpdateCart();
			break;
		end
	end
end

function HousingMarketCartDataManagerMixin:OnUpdateItemInfo(itemID)
	for _i, cartItem in ipairs(self.cartList) do
		if cartItem.id == itemID then
			cartItem.name = C_Item.GetItemNameByID(itemID);
			cartItem.icon = C_Item.GetItemIconByID(itemID);
		end
	end

	self:UpdateCart();
end

function HousingMarketCartDataManagerMixin:PlaceInWorld(placeItemData)
	-- Catalog shop bundle items are managed by product ID so only set pending place for non-bundle items
	if not placeItemData.bundleCatalogShopProductID then
		self.pendingPlaceCartID = placeItemData.cartID;
	end

	C_HousingBasicMode.StartPlacingPreviewDecor(placeItemData.decorID, placeItemData.bundleCatalogShopProductID);

	if self.PlaceInWorldCallback then
		self.PlaceInWorldCallback(placeItemData);
	end
end

function HousingMarketCartDataManagerMixin:SetPlaceInWorldCallback(placeInWorldCallback)
	self.PlaceInWorldCallback = placeInWorldCallback;
end
