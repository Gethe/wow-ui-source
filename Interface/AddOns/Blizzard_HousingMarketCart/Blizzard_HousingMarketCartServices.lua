
local TEST_TEMP_ITEMS = {
	66944,
	181354,
	128668,
	181354,
	169124,
	236666,
};

HousingMarketAddToCartServiceMixin = {};

function HousingMarketAddToCartServiceMixin:GetEventData()
	local continuableContainer = ContinuableContainer:Create();
	local itemID = TEST_TEMP_ITEMS[math.random(1, #TEST_TEMP_ITEMS)];
	local item = Item:CreateFromItemID(itemID);
	continuableContainer:AddContinuable(item);

	local temp = {
		isBundleParent = false,
		isBundleChild = false,

		id = itemID,
		name = C_Item.GetItemNameByID(itemID),
		icon = C_Item.GetItemIconByID(itemID);
		price = 100,
		salePrice = 50,
	};

	local tempBundle = {
		isBundleParent = true,
		isBundleChild = false,

		bundleChildren = {
			{
				isBundleParent = false,
				isBundleChild = true,

				id = itemID,
				name = C_Item.GetItemNameByID(itemID),
				icon = C_Item.GetItemIconByID(itemID);
			},
			{
				isBundleParent = false,
				isBundleChild = true,

				id = itemID,
				name = C_Item.GetItemNameByID(itemID),
				icon = C_Item.GetItemIconByID(itemID);
			},
			{
				isBundleParent = false,
				isBundleChild = true,

				id = itemID,
				name = C_Item.GetItemNameByID(itemID),
				icon = C_Item.GetItemIconByID(itemID);
			},
		},

		id = itemID,
		name = C_Item.GetItemNameByID(itemID),
		icon = C_Item.GetItemIconByID(itemID);
		price = 100,
		salePrice = 50,
	};

	return not self.bundleButton and temp or tempBundle;
end

HousingMarketViewCartButtonMixin = {};

function HousingMarketViewCartButtonMixin:UpdateNumItemsInCart(numItemsInCart)
	self.ItemCountText:SetText(numItemsInCart);
end

HousingMarketShowCartServiceMixin = {};

function HousingMarketShowCartServiceMixin:GetEventData()
	local shown = true;
	return shown;
end

HousingMarketHideCartServiceMixin = {};

function HousingMarketHideCartServiceMixin:GetEventData()
	local shown = false;
	return shown;
end
