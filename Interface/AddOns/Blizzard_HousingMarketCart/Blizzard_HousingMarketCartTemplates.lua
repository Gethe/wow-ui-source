
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
end

function HousingMarketCartFrameMixin:GetEventNamespace()
	return HOUSING_MARKET_EVENT_NAMESPACE;
end

function HousingMarketCartFrameMixin:GetElementInitInfoFunc()
	local function InitializeItem(button, elementData)
		button:InitItem(elementData);
		button:SetSelection(self.selectionBehavior:IsElementDataSelected(elementData));

		button:SetScript("OnClick", function(btn)
			self.selectionBehavior:ToggleSelect(btn);
			btn:SetSelection(self.selectionBehavior:IsElementDataSelected(elementData));
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
		button:SetSelection(self.selectionBehavior:IsElementDataSelected(elementData));

		button:SetScript("OnClick", function(btn)
			self.selectionBehavior:ToggleSelect(btn);
			btn:SetSelection(self.selectionBehavior:IsElementDataSelected(elementData));
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
	self.CartDataManager = CreateFromMixins(ShoppingCartDataManagerMixin);
	self.CartDataManager:Init(self.eventNamespace);
	self.CartDataManager:SetRemovalPredicate(function(itemToRemove, itemToCheck)
		-- Need to compare something more unique
		return itemToRemove.id == itemToCheck.id;
	end);

	self.CartDataManager:SetUpdateCartCallback(function(cartList)
		if self:IsShown() then
			self:FullUpdate();
		end

		self:UpdateCartTotal(cartList);
	end);

	self.CartDataManager:SetAddToCartCallback(function(cartItem)
		self:AddItemToList(cartItem);
	end);

	self.CartDataManager:SetRemoveFromCartCallback(function(itemIndex, cartItem)
		self:RemoveItemFromList(itemIndex, cartItem);
	end);

	self.CartDataManager:SetClearCartCallback(function()
		local dataProvider = CreateDataProvider();
		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
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

function HousingMarketCartFrameMixin:RemoveItemFromList(_itemIndex, item)
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
	end
end

function HousingMarketCartFrameMixin:UpdateNumItemsInCart()
	local numItemsInCart = self.CartDataManager:GetNumItemsInCart();
	self.CartVisibleContainer.Header.Title:SetText(string.format(GENERIC_CART_PREVIEW_TITLE, numItemsInCart));
	self.CartHiddenContainer.ViewCartButton:UpdateNumItemsInCart(numItemsInCart);
end
