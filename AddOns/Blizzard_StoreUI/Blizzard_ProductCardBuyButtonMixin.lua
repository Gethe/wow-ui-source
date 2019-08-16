--------------------------------------------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

Import("IsOnGlueScreen");

if ( tbl.IsOnGlueScreen() ) then
	tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	Import("C_StoreGlue");
end

setfenv(1, tbl);
--------------------------------------------------

--------------------------------------------------
-- PRODUCT CARD BUY BUTTON MIXIN
ProductCardBuyButtonMixin = {};

function ProductCardBuyButtonMixin:UpdatePricing(currencyInfo, entryInfo, currencyFormat)
	self.NormalPrice:Hide();
	self.SalePrice:Hide();
	self.CurrentPrice:Hide();
	self.Strikethrough:Hide();
	self.BuyButton.Strikethrough:Hide();
end

function ProductCardBuyButtonMixin:UpdateBuyButton(currencyInfo, entryInfo, currencyFormat)
	local discounted, discountPercentage = StoreFrame_GetDiscountInformation(entryInfo.sharedData);
	local currentPrice = StoreFrame_GetProductPriceText(entryInfo, currencyFormat);
	self.NormalPrice:SetText(currencyFormat(entryInfo.sharedData.normalDollars, entryInfo.sharedData.normalCents));

	if bit.band(entryInfo.sharedData.flags, Enum.BattlepayDisplayFlag.HiddenPrice) == Enum.BattlepayDisplayFlag.HiddenPrice then
		local text = info.browseBuyButtonText or BLIZZARD_STORE_BUY;
		self.BuyButton:SetText(text);
		self.BuyButton.RightText:Hide();
		self.BuyButton.LeftText:Hide();
		self.BuyButton.Strikethrough:Hide();
	elseif discounted then
		self.BuyButton:SetText("");

		self.BuyButton.RightText:SetText(currentPrice);
		self.BuyButton.RightText:SetTextColor(0.1, 1, 0.1);
		self.BuyButton.RightText:Show();

		local normalPrice = currencyFormat(entryInfo.sharedData.normalDollars, entryInfo.sharedData.normalCents);
		self.BuyButton.LeftText:SetText(normalPrice);
		self.BuyButton.LeftText:SetTextColor(0.5, 0.5, 0.5);
		self.BuyButton.LeftText:Show();

		self.BuyButton.Strikethrough:ClearAllPoints();
		self.BuyButton.Strikethrough:SetPoint("LEFT", self.BuyButton.LeftText, "LEFT", 0, 0);
		self.BuyButton.Strikethrough:SetPoint("RIGHT", self.BuyButton.LeftText, "RIGHT", 0, 0);
		self.BuyButton.Strikethrough:Show();
	else
		self.BuyButton:SetText(currentPrice);
		self.NormalPrice:Hide();
		self.SalePrice:Hide();
		self.BuyButton.Strikethrough:Hide();
	end

	self.BuyButton:SetEnabled(self:ShouldEnableBuyButton(entryInfo));
end

--------------------------------------------------
-- STORE BUY BUTTON MIXIN
StoreBuyButtonMixin = CreateFromMixins(StoreButtonMixin);

function StoreBuyButtonMixin:OnMouseDown()
	StoreButtonMixin.OnMouseDown(self);
	self.LeftText:SetPoint("LEFT", 11, -1);
end

function StoreBuyButtonMixin:OnMouseUp()
	StoreButtonMixin.OnMouseUp(self);
	self.LeftText:SetPoint("LEFT", 10, -1);
end
