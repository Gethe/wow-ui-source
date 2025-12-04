
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
