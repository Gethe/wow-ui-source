--------------------------------------------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

Import("IsOnGlueScreen");
Import("BLIZZARD_STORE_PURCHASED");
Import("GetUnscaledFrameRect");
Import("BLIZZARD_STORE_EXTERNAL_LINK_BUTTON_TEXT");

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
	self.BuyButton.Discount:Hide();
end

function ProductCardBuyButtonMixin:UpdateBuyButton(currencyInfo, entryInfo, currencyFormat)
	local discounted, discountPercentage = StoreFrame_GetDiscountInformation(entryInfo.sharedData);
	local currentPrice = StoreFrame_GetProductPriceText(entryInfo, currencyFormat);
	self.NormalPrice:SetText(currencyFormat(entryInfo.sharedData.normalDollars, entryInfo.sharedData.normalCents));

	local completelyOwned = StoreFrame_IsCompletelyOwned(entryInfo);
	
	self:SetOriginalSize();
	if bit.band(entryInfo.sharedData.flags, Enum.BattlepayDisplayFlag.HiddenPrice) == Enum.BattlepayDisplayFlag.HiddenPrice then
		local text = entryInfo.browseBuyButtonText or BLIZZARD_STORE_BUY;
		self.BuyButton:Show();
		self.BuyButton:SetText(text);

		self.BuyButton.Discount:Hide();
		self.PurchasedText:Hide();
		self.PurchasedMark:Hide();
	elseif completelyOwned then
		self.BuyButton:Hide();
		self.BuyButton.Discount:Hide();
		self.PurchasedText:Show();
		self.PurchasedMark:Show();
	elseif discounted then
		self.BuyButton:Show();
		local DiscountContainer = self.BuyButton.Discount;

		self.BuyButton:SetText("");
		DiscountContainer.RightText:SetText(currentPrice);
		DiscountContainer.RightText:SetTextColor(0.1, 1, 0.1);

		local normalPrice = currencyFormat(entryInfo.sharedData.normalDollars, entryInfo.sharedData.normalCents);
		DiscountContainer.LeftText:SetText(normalPrice);
		DiscountContainer.LeftText:SetTextColor(0.5, 0.5, 0.5);

		self:SetDiscountedSize();
		DiscountContainer:Show();
		self.PurchasedText:Hide();
		self.PurchasedMark:Hide();
	else
		self.BuyButton:Show();
		self.BuyButton:SetText(currentPrice);

		self.NormalPrice:Hide();
		self.SalePrice:Hide();
		self.BuyButton.Discount.Strikethrough:Hide();
		self.PurchasedText:Hide();
		self.PurchasedMark:Hide();
	end

	self.BuyButton:SetEnabled(self:ShouldEnableBuyButton(entryInfo));
end

function ProductCardBuyButtonMixin:SetOriginalSize()
	self.BuyButton:SetSize(self:GetMinSize(), 35);
end

function ProductCardBuyButtonMixin:GetMinSize()
	return 146;
end

local WIDTH_PADDING = 50;
local GAP_BETWEEN = 7;
function ProductCardBuyButtonMixin:SetDiscountedSize()
	local DiscountContainer = self.BuyButton.Discount;
	local buttonSize = DiscountContainer.LeftText:GetStringWidth() + GAP_BETWEEN + DiscountContainer.RightText:GetStringWidth() + WIDTH_PADDING;

	if buttonSize < self:GetMinSize() then
		buttonSize = self:GetMinSize();
	end
	self.BuyButton:SetSize(buttonSize, 35);
end

--------------------------------------------------
-- LARGE PRODUCT CARD BUY BUTTON MIXIN
LargeProductCardBuyButtonMixin = CreateFromMixins(ProductCardBuyButtonMixin);
function LargeProductCardBuyButtonMixin:SetOriginalSize()
	self.BuyButton:SetSize(self:GetMinSize(), 35);
end

function LargeProductCardBuyButtonMixin:GetMinSize()
	return 210;
end


--------------------------------------------------
-- STORE BUY BUTTON MIXIN
StoreBuyButtonMixin = CreateFromMixins(StoreButtonMixin);

function StoreBuyButtonMixin:OnMouseDown()
	StoreButtonMixin.OnMouseDown(self);
	self.Discount:SetPoint("CENTER", 1, -1);
end

function StoreBuyButtonMixin:OnMouseUp()
	StoreButtonMixin.OnMouseUp(self);
	self.Discount:SetPoint("CENTER", 0, 0);
end

--------------------------------------------------
-- STORE BUY BUTTON MIXIN
StoreNydusLinkButtonMixin = CreateFromMixins(StoreButtonMixin);

function StoreNydusLinkButtonMixin:OnClick()
	local parent = self:GetParent();
	local entryID = parent:GetID();

	C_StoreSecure.OpenNydusLink(entryID);
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON);
end