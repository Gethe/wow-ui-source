
HOUSING_MARKET_EVENT_NAMESPACE = "HousingMarketEvents";

HousingMarketCartFrameMixin = CreateFromMixins(ShoppingCartVisualsFrameMixin);

function HousingMarketCartFrameMixin:OnLoad()
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
end

function HousingMarketCartFrameMixin:OnShow()
	ShoppingCartVisualsFrameMixin.OnShow(self);

	if self.isPendingAddedToCartAnim then
		self.CartUpdatedFlipbookTexture:Show();
		self.CartUpdatedFlipbookAnim:Play();
	end
end

function HousingMarketCartFrameMixin:GetEventNamespace()
	return HOUSING_MARKET_EVENT_NAMESPACE;
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
			self.selectionBehavior:ToggleSelect(btn);
			local selected = self.selectionBehavior:IsElementDataSelected(elementData);
			btn:SetSelection(selected);

			if elementData.decorGUID then
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

	local function InitializeBundleSubItem(button, elementData)
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
			self.selectionBehavior:ToggleSelect(btn);

			local selected = self.selectionBehavior:IsElementDataSelected(elementData);
			btn:SetSelection(selected);

			if elementData.decorGUID then
				C_HousingCatalog.SetPreviewCartItemShown(elementData.decorGUID, selected);
			end
		end);
	end

	return function(elementData)
		if elementData.isHeader then
			return "HousingMarketCartBundleHeaderTemplate", InitializeBundleHeader;
		elseif elementData.isFooter then
			return "HousingMarketCartBundleFooterTemplate", InitializeBundleFooter;
		elseif elementData.isBundleParent then
			return "HousingMarketCartBundleTemplate", InitializeBundle;
		elseif elementData.isBundleChild then
			return "HousingMarketCartBundleItemTemplate", InitializeBundleSubItem;
		end

		return "HousingMarketCartItemTemplate", InitializeItem;
	end
end

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

		EventRegistry:TriggerEvent(HOUSING_MARKET_EVENT_NAMESPACE .. ".CartUpdated");
	end);

	self.CartDataManager:SetAddToCartCallback(function(cartItem)
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
		self:RemoveItemFromList(itemIndex, cartItem);
	end);

	self.CartDataManager:SetClearCartCallback(function()
		local dataProvider = CreateDataProvider();
		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	end);

	self.CartDataManager:SetPlaceInWorldCallback(function(_placeItemData)
		self:FullUpdate();
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
end

function HousingMarketCartFrameMixin:GetNumDecorPlaced(bundleCatalogShopProductID, decorID)
	return self.CartDataManager:GetNumDecorPlaced(bundleCatalogShopProductID, decorID);
end

HousingMarketCartDataServiceEvents = {
	PlaceInWorld = "PlaceInWorld",
};

HousingMarketCartDataManagerMixin = CreateFromMixins(ShoppingCartDataManagerMixin);

function HousingMarketCartDataManagerMixin:Init(eventNamespace)
	ShoppingCartDataManagerMixin.Init(self, eventNamespace);

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

	if item.id then
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
				local decorInfo = C_HousingCatalog.GetBasicDecorInfo(decorID);
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

function HousingMarketCartDataManagerMixin:ClearCart()
	for _i, cartItem in ipairs(self.cartList) do
		if cartItem.decorGUID then
			C_HousingCatalog.DeletePreviewCartDecor(cartItem.decorGUID);
		end
	end

	ShoppingCartDataManagerMixin.ClearCart(self);
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
