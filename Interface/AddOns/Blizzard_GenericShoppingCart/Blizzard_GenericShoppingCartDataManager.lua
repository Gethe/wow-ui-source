ShoppingCartDataServices = {
	AddToCart = "AddToCart",
	RemoveFromCart = "RemoveFromCart",
	UpdateCart = "UpdateCart",
	ClearCart = "ClearCart",
	PurchaseCart = "PurchaseCart",
};

ShoppingCartDataManagerMixin = CreateFromMixins(ShoppingCartServiceRegistrantMixin);

function ShoppingCartDataManagerMixin:Init(eventNamespace)
	self.cartList = {};

	-- Default removal predicate just checks id field
	self.RemovalPredicate = function(cartItemToRemove, cartItemToCheck)
		return cartItemToRemove.id == cartItemToCheck.id;
	end

	-- Default cart callback are nil, and should be set by the consumer
	self.UpdateCartCallback = nil;
	self.AddToCartCallback = nil;
	self.RemoveFromCartCallback = nil;
	self.ClearCartCallback = nil;
	self.PurchaseCartCallback = nil;

	self.eventNamespace = eventNamespace;
	self:AddServiceEvents(ShoppingCartDataServices);
end

function ShoppingCartDataManagerMixin:SetRemovalPredicate(removalPredicate)
	self.RemovalPredicate = removalPredicate;
end

function ShoppingCartDataManagerMixin:SetUpdateCartCallback(updateCartCallback)
	self.UpdateCartCallback = updateCartCallback;
end

function ShoppingCartDataManagerMixin:SetAddToCartCallback(addToCartCallback)
	self.AddToCartCallback = addToCartCallback;
end

function ShoppingCartDataManagerMixin:SetRemoveFromCartCallback(removeFromCartCallback)
	self.RemoveFromCartCallback = removeFromCartCallback;
end

function ShoppingCartDataManagerMixin:SetClearCartCallback(clearCartCallback)
	self.ClearCartCallback = clearCartCallback;
end

function ShoppingCartDataManagerMixin:SetPurchaseCartCallback(purchaseCartCallback)
	self.PurchaseCartCallback = purchaseCartCallback;
end

local CartIDCounter = 0;

local function IncrementAndGetCurrCartID()
	CartIDCounter = CartIDCounter + 1;
	return CartIDCounter;
end

function ShoppingCartDataManagerMixin:AddToCart(cartItem)
	cartItem.cartID = IncrementAndGetCurrCartID();

	table.insert(self.cartList, cartItem);

	if self.AddToCartCallback then
		self.AddToCartCallback(cartItem);
	end

	self:UpdateCart();
end

function ShoppingCartDataManagerMixin:RemoveFromCartInternal(index, currCartItem)
	table.remove(self.cartList, index);

	if self.RemoveFromCartCallback then
		self.RemoveFromCartCallback(index, currCartItem)
	end
	
	self:UpdateCart();
	return index, currCartItem;
end

function ShoppingCartDataManagerMixin:RemoveFromCart(cartItemToRemove)
	if self.RemovalPredicate then
		for index, currCartItem in ipairs(self.cartList) do
			if self.RemovalPredicate(cartItemToRemove, currCartItem) then
				return self:RemoveFromCartInternal(index, currCartItem);
			end
		end
	end

	-- Default to checking the cart ID
	for index, currCartItem in ipairs(self.cartList) do
		if cartItemToRemove.cartID == currCartItem.cartID then
			return self:RemoveFromCartInternal(index, currCartItem);
		end
	end

	return nil, nil;
end

function ShoppingCartDataManagerMixin:ClearCart(_requiresConfirmation)
	self.cartList = {};

	if self.ClearCartCallback then
		self.ClearCartCallback();
	end

	self:UpdateCart();
end

function ShoppingCartDataManagerMixin:PurchaseCart()
	if self.PurchaseCartCallback then
		return self.PurchaseCartCallback(self.cartList);
	end
end

function ShoppingCartDataManagerMixin:UpdateCart()
	if self.UpdateCartCallback then
		return self.UpdateCartCallback(self.cartList);
	end
end

function ShoppingCartDataManagerMixin:GetNumItemsInCart()
	return #self.cartList;
end

ShoppingCartClearCartServiceMixin = {};

function ShoppingCartClearCartServiceMixin:GetEventData()
	local clearRequiresConfimation = true;
	return clearRequiresConfimation;
end
