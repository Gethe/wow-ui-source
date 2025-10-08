
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

local bundleRefCount = 0;

function HousingMarketCartFrameMixin:AddItemToList(item)
	if item.id then
		-- TODO: Assess if the copy is needed here or if we're passing along a full elementData
		--local elementData = {
		--	isBundleParent = item.isBundleParent,
		--	isBundleChild = item.isBundleChild,
		--
		--	id = item.id,
		--    name = item.name,
		--    icon = item.icon,
		--    price = item.price,
		--    salePrice = item.salePrice,
		--};

		local dataProvider = self.ScrollBox:GetDataProvider();
		dataProvider:Insert(item);

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
				dataProvider:Insert(subItem);
			end

			bundleRefCount = bundleRefCount + 1;
		else
			item.bundleRef = nil;
		end
	end
end

function HousingMarketCartFrameMixin:RemoveItemFromList(itemIndex, item)
	if item.id then
		local dataProvider = self.ScrollBox:GetDataProvider();
		local dataProviderIndex = dataProvider:FindIndex(item);
		dataProvider:RemoveIndex(dataProviderIndex);

		if item.bundleRef ~= nil then
			local numRemovedItems = 0;
			local totalItems = dataProvider:GetSize();
			for index = 1, totalItems do
				local currElementData = dataProvider:Find(index - numRemovedItems);
				if currElementData and currElementData.bundleRef == item.bundleRef then
					dataProvider:RemoveIndex(index - numRemovedItems);
					numRemovedItems = numRemovedItems + 1;
				end
			end
		end

		if item.decorGUID then
			C_HousingCatalog.DeletePreviewCartDecor(item.decorGUID);
		end
	end
end

function HousingMarketCartFrameMixin:UpdateNumItemsInCart()
	local numItemsInCart = self.CartDataManager:GetNumItemsInCart();
	self.CartVisibleContainer.Header.Title:SetText(string.format(GENERIC_CART_PREVIEW_TITLE, numItemsInCart));
	self.CartHiddenContainer.ViewCartButton:UpdateNumItemsInCart(numItemsInCart);
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

function HousingMarketCartDataManagerMixin:PlaceInWorld(placeItemData)
	self.pendingPlaceCartID = placeItemData.cartID;

	C_HousingBasicMode.StartPlacingPreviewDecor(placeItemData.decorEntryID);

	if self.PlaceInWorldCallback then
		self.PlaceInWorldCallback(placeItemData);
	end
end

function HousingMarketCartDataManagerMixin:SetPlaceInWorldCallback(placeInWorldCallback)
	self.PlaceInWorldCallback = placeInWorldCallback;
end
