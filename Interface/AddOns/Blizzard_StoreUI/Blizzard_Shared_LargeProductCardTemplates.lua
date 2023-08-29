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

--Imports
Import("bit");
Import("C_WowTokenPublic");
Import("math");
Import("table");
Import("ipairs");
Import("pairs");
Import("select");
Import("unpack");
Import("type");
Import("string");
Import("strtrim");
Import("PlaySound");
Import("SetPortraitToTexture");
Import("GetMouseFocus");
Import("Enum");
Import("SecureMixin");
Import("CreateFromSecureMixins");
Import("IsTrialAccount");
Import("IsVeteranTrialAccount");

local BATTLEPAY_SPLASH_BANNER_TEXT_FEATURED = 0;
local BATTLEPAY_SPLASH_BANNER_TEXT_DISCOUNT = 1;
local BATTLEPAY_SPLASH_BANNER_TEXT_NEW = 2;


--------------------------------------------------
-- VERTICAL LARGE STORE CARD MIXIN
VerticalLargeStoreCardMixin = CreateFromMixins(StoreCardMixin);
function VerticalLargeStoreCardMixin:OnLoad()
	StoreCardMixin.OnLoad(self);

	SecureMixin(self.ProductName, AutoScalingFontStringMixin);
	self.ProductName:SetFontObject("GameFontNormalMed3");
	self.ProductName:SetMinLineHeight(12);
	self.ProductName:SetSpacing(0);
end

function VerticalLargeStoreCardMixin:OnEnter()
	local disabled = not self:IsEnabled();
	local hasDisabledTooltip = disabled and self.disabledTooltip;
	local hasProductTooltip = not disabled and self.productTooltipTitle;
	if hasDisabledTooltip or hasProductTooltip then
		StoreTooltip:ClearAllPoints();
		if self.anchorRight then
			StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", -7, -6);
		else
			StoreTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 7, -6);
		end

		if hasDisabledTooltip then
			StoreTooltip_Show("", self.disabledTooltip);
		elseif hasProductTooltip then
			StoreTooltip_Show(self.productTooltipTitle, self.productTooltipDescription);
		end
	end

	if disabled then
		return;
	end

	if self.HighlightTexture then
		self.HighlightTexture:Show();
	end
	self:UpdateMagnifier();
end

function VerticalLargeStoreCardMixin:OnLeave()
	if GetMouseFocus() == self.Magnifier then
		return;
	end
	self.Magnifier:Hide();
	self.HighlightTexture:Hide();
	StoreTooltip:ClearAllPoints();
	StoreTooltip:Hide();
end

function VerticalLargeStoreCardMixin:ShowDiscount(discountText)
	StoreCardMixin.ShowDiscount(self, discountText);
	
	local normalWidth = self.NormalPrice:GetStringWidth();
	local totalWidth = normalWidth + self.SalePrice:GetStringWidth();
	self.NormalPrice:ClearAllPoints();
	self.NormalPrice:SetPoint("TOP", self.ProductName, "BOTTOM", (normalWidth - totalWidth) / 2, -12);
end

function VerticalLargeStoreCardMixin:GetCurrencyFormat(currencyInfo)
	return currencyInfo.formatLong;
end

function VerticalLargeStoreCardMixin:UpdateBannerText(discounted, discountPercentage, displayInfo)
	-- empty override
end

function VerticalLargeStoreCardMixin:UpdateState()
	-- we override the StoreCardMixin:UpdateState here to prevent "selected" functionality in LargeCards
end

function VerticalLargeStoreCardMixin:SetDisabledOverlayShown(showDisabledOverlay)
	--disabled overlay is currently only used by small cards
	self.DisabledOverlay:SetShown(false);
end

function VerticalLargeStoreCardMixin:ShouldShowIcon(entryInfo)
	return entryInfo.sharedData.overrideTexture or StoreCardMixin.ShouldShowIcon(self, entryInfo) and not entryInfo.sharedData.overrideBackground;
end

function VerticalLargeStoreCardMixin:SetupDescription(entryInfo)
	local description = entryInfo.sharedData.description;

	if not description then
		return;
	end

	self.ProductName:SetPoint("BOTTOM", self, "CENTER", 0, -41);

	self.Description:ClearAllPoints();
	self.Description:SetPoint("TOP", self.ProductName, "BOTTOM", 0, -10);
	self.Description:Show();

	if entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.WoWToken then
		description = BLIZZARD_STORE_TOKEN_DESC_30_DAYS;
	end

	local baseDescription, bullets = description:match("(.-)$bullet(.*)");
	if not bullets then
		self.Description:SetText(description);
	else
		local bulletPoints = {};
		while bullets ~= nil and bullets ~= "" do
			local bullet = bullets:match("(.-)$bullet") or bullets;
			bullet = strtrim(bullet, "\n\r");
			bullets = bullets:match("$bullet(.*)");
			table.insert(bulletPoints, bullet);
		end

		self.Description:SetJustifyH("LEFT");

		if baseDescription ~= "" then
			self.Description:SetText(strtrim(baseDescription, "\n\r"));
			self.Description:Show();
			self.DescriptionBulletPointContainer:SetPoint("TOP", self.Description, "BOTTOM", 0, -3);
		else
			self.Description:Hide();
			self.DescriptionBulletPointContainer:SetPoint("TOP", self.Description, "TOP");
		end

		self.DescriptionBulletPointContainer:SetContents(bulletPoints);
	end
end

function VerticalLargeStoreCardMixin:SetDefaultCardTexture()
	self.Card:ClearAllPoints();
	self.Card:SetTexture("Interface\\Store\\Store-Main");
	self.Card:SetTexCoord(0.00097656, 0.56347656, 0.00097656, 0.46093750);	
	self.Card:SetAllPoints(self);
end

function VerticalLargeStoreCardMixin:ShouldModelShowShadows()
	return false;
end

function VerticalLargeStoreCardMixin:ShowIcon(displayData)
	local overrideTexture = displayData.overrideTexture;

	if overrideTexture then
		self.IconBorder:Hide();
		self.Icon:SetAtlas(overrideTexture, true);
		self.Icon:SetPoint("TOPLEFT", 4, -4);
	else
		self.Icon:ClearAllPoints();
		self.Icon:SetSize(63, 63);
		self.Icon:SetPoint("CENTER", self, "TOP", 0, -69);
	
		self.IconBorder:ClearAllPoints();
		self.IconBorder:SetPoint("CENTER", self.Icon, "CENTER", 0, -5);
		self.IconBorder:Show();
	end
	self.Icon:Show();
end

function VerticalLargeStoreCardMixin:Layout()
	local width, height = StoreFrame_GetCellPixelSize("VerticalLargeStoreCardTemplate");
	self:SetSize(width, height);

	self:SetDefaultCardTexture();
	
	self.CurrentMarketPrice:Hide();
	
	self.CurrentPrice:ClearAllPoints();
	self.CurrentPrice:SetPoint("TOP", self.ProductName, "BOTTOM", 0, -8);
	self.CurrentPrice:SetTextColor(1, 0.82, 0);
	
	self.NormalPrice:ClearAllPoints();
	self.NormalPrice:SetPoint("TOP", self.ProductName, "BOTTOM", 6, -2);
	self.NormalPrice:SetFontObject("GameFontNormal");
	self.NormalPrice:SetTextColor(0.8, 0.66, 0);

	self.SalePrice:ClearAllPoints();
	self.SalePrice:SetPoint("BOTTOMLEFT", self.NormalPrice, "BOTTOMRIGHT", 6, -2);
	self.SalePrice:SetFontObject("GameFontNormalLarge2");
	
	self.ProductName:ClearAllPoints();
	self.ProductName:SetPoint("BOTTOM", self, "CENTER", 0, -156);
	self.ProductName:SetSize(250, 50);
	self.ProductName:SetFontObject("GameFontNormalLarge");
	self.ProductName:SetJustifyH("CENTER");
	self.ProductName:SetJustifyV("BOTTOM");
	self.ProductName:SetTextColor(1, 1, 1);
	self.ProductName:SetShadowColor(0, 0, 0, 1);
	self.ProductName:SetShadowOffset(1, -1);

	self.Description:SetFontObject("GameFontNormalMed1");
	self.Description:SetWidth(245);
	self.Description:SetJustifyH("CENTER");
	self.Description:Hide();
	
	self.SelectedTexture:Hide();

	self.UpgradeArrow:ClearAllPoints();
	self.UpgradeArrow:SetPoint("BOTTOMRIGHT", self.IconBorder, "BOTTOMRIGHT", -3, 4);

	self.HighlightTexture:ClearAllPoints();
	self.HighlightTexture:SetAtlas("shop-card-half-hover", true);
	self.HighlightTexture:SetTexCoord(0, 1, 0, 1);	
	self.HighlightTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -3);
	self.HighlightTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 3);

	self.CurrentPrice:ClearAllPoints();
	self.CurrentPrice:SetPoint("BOTTOM", 0, 20);

	self.NormalPrice:ClearAllPoints();
	self.NormalPrice:SetPoint("BOTTOM", 0, 20);

	self.DiscountRight:ClearAllPoints();
	self.DiscountRight:SetPoint("BOTTOM", -40, 20);

	self.DiscountLeft:ClearAllPoints();
	self.DiscountLeft:SetPoint("RIGHT", self.DiscountRight, "LEFT", -40, 0);

	self.DiscountMiddle:ClearAllPoints();
	self.DiscountMiddle:SetPoint("LEFT", self.DiscountLeft, "RIGHT", 0, 0);
	self.DiscountMiddle:SetPoint("RIGHT", self.DiscountRight, "LEFT", 0, 0);
	
	self.DiscountText:ClearAllPoints();
	self.DiscountText:SetSize(50, 30);
	self.DiscountText:SetPoint("CENTER", self.DiscountMiddle, "CENTER", 1, 2);
	
	self.Strikethrough:ClearAllPoints();
	self.Strikethrough:SetPoint("TOPLEFT", self.NormalPrice, "TOPLEFT", 0, 0);
	self.Strikethrough:SetPoint("BOTTOMRIGHT", self.NormalPrice, "BOTTOMRIGHT", 0, 0);
	
	self.ModelScene:ClearAllPoints();
	self.ModelScene:SetPoint("TOPLEFT", 6, -5);
	self.ModelScene:SetPoint("BOTTOMRIGHT", -7, 5);
	self.ModelScene:SetViewInsets(0, 0, 0, 0);
	
	self.Magnifier:ClearAllPoints();
	self.Magnifier:SetSize(31, 35);
	self.Magnifier:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8);
	
	self.InvisibleMouseOverFrame:Hide();
	
	self.Checkmark:ClearAllPoints();
	self.Checkmark:SetSize(27, 27);
	self.Checkmark:SetPoint("TOPRIGHT", -8, -8);		
	
	self.CurrentMarketPrice:SetSize(250, 0);
	self.CurrentMarketPrice:ClearAllPoints();
	self.CurrentMarketPrice:SetPoint("TOP", self.CurrentPrice, "BOTTOM", 0, -4);
	self.CurrentMarketPrice:SetTextColor(0.733, 0.588, 0.31);
	
	self.GlowSpin:Hide();
	self.GlowPulse:Hide();
	self.BannerFadeIn:Hide();	
end

--------------------------------------------------
-- VERTICAL LARGE STORE CARD WITH A BUY BUTTON MIXIN 
VerticalLargeStoreCardWithBuyButtonMixin = CreateFromMixins(VerticalLargeStoreCardMixin, ProductCardBuyButtonMixin, LargeProductCardBuyButtonMixin);

function VerticalLargeStoreCardWithBuyButtonMixin:OnLoad()
	VerticalLargeStoreCardMixin.OnLoad(self);

	self.SplashBannerText:SetShadowColor(0, 0, 0, 1);
end

function VerticalLargeStoreCardWithBuyButtonMixin:UpdateBannerText(discounted, discountPercentage, displayInfo)
	if displayInfo.bannerType == Enum.BattlepayBannerType.New then
		self.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_NEW);
	elseif displayInfo.bannerType == Enum.BattlepayBannerType.Discount then
		if discounted then
			self.SplashBannerText:SetText(string.format(BLIZZARD_STORE_SPLASH_BANNER_DISCOUNT_FORMAT, discountPercentage));
		else
			self.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FEATURED);
		end
	elseif displayInfo.bannerType == Enum.BattlepayBannerType.Featured then
		self.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FEATURED);
	end	
end

function VerticalLargeStoreCardWithBuyButtonMixin:SetupDescription(entryInfo)
	VerticalLargeStoreCardMixin.SetupDescription(self, entryInfo);
end

function VerticalLargeStoreCardWithBuyButtonMixin:OnEnter()
	local disabled = not self:IsEnabled();
	local hasDisabledTooltip = disabled and self.disabledTooltip;
	local hasProductTooltip = not disabled and self.productTooltipTitle;
	if hasDisabledTooltip or hasProductTooltip then
		StoreTooltip:ClearAllPoints();
		if self.anchorRight then
			StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);
		else
			StoreTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 0);
		end

		if hasDisabledTooltip then
			StoreTooltip_Show("", self.disabledTooltip);
		elseif hasProductTooltip then
			StoreTooltip_Show(self.productTooltipTitle, self.productTooltipDescription);
		end
	end

	if disabled then
		return;
	end

	if self.HighlightTexture then
		self.HighlightTexture:Hide();
	end
	self:UpdateMagnifier();
end

function VerticalLargeStoreCardWithBuyButtonMixin:Layout()
	VerticalLargeStoreCardMixin.Layout(self);

	local width, height = StoreFrame_GetCellPixelSize("VerticalLargeStoreCardWithBuyButtonTemplate");
	self:SetSize(width, height);

	self.SplashBanner:Hide();
	self.SplashBannerText:Hide();

	self.BuyButton:ClearAllPoints();
	self.BuyButton:SetSize(146, 35);
	self.BuyButton:SetPoint("BOTTOM", 0, 22);

	self.PurchasedText:SetText(BLIZZARD_STORE_PURCHASED);
	self.PurchasedText:ClearAllPoints();
	self.PurchasedText:SetPoint("BOTTOM", 0, 22);
	self.PurchasedText:Hide();

	self.PurchasedMark:Hide();
end

--------------------------------------------------
-- VERTICAL LARGE PAGEABLE STORE CARD WITH A BUY BUTTON MIXIN
VerticalLargePageableStoreCardWithBuyButtonMixin = CreateFromMixins(VerticalLargeStoreCardWithBuyButtonMixin);

function VerticalLargePageableStoreCardWithBuyButtonMixin:Layout()
	VerticalLargeStoreCardWithBuyButtonMixin.Layout(self);

	local width, height = StoreFrame_GetCellPixelSize("VerticalLargePageableStoreCardWithBuyButtonTemplate");
	self:SetSize(width, height);

	self.ProductName:SetPoint("BOTTOM", self, "CENTER", 0, -138);

	self.Description:ClearAllPoints();
	self.Description:Hide();
end

function VerticalLargePageableStoreCardWithBuyButtonMixin:SetDefaultCardTexture()
	self.Card:SetAtlas("store-card-transmog", true);
	self.Card:SetTexCoord(0, 1, 0, 1);
end

function VerticalLargePageableStoreCardWithBuyButtonMixin:SetupDescription(entryInfo)
	-- do nothing
end

--------------------------------------------------
-- HORIZONTAL LARGE STORE CARD MIXIN
HorizontalLargeStoreCardMixin = CreateFromMixins(VerticalLargeStoreCardMixin);

function HorizontalLargeStoreCardMixin:OnLoad()
	StoreCardMixin.OnLoad(self);

	SecureMixin(self.ProductName, AutoScalingFontStringMixin);
	self.ProductName:SetFontObject("GameFontNormalMed3");
	self.ProductName:SetMinLineHeight(12);
	self.ProductName:SetSpacing(0);
end

function HorizontalLargeStoreCardMixin:GetCurrencyFormat(currencyInfo)
	return currencyInfo.formatLong;
end

function HorizontalLargeStoreCardMixin:Layout()
	local width, height = StoreFrame_GetCellPixelSize("HorizontalLargeStoreCardTemplate");
	self:SetSize(width, height);

	self.Checkmark:ClearAllPoints();
	self.Checkmark:SetSize(27, 27);
	self.Checkmark:SetPoint("TOPRIGHT", -8, -8);		
	
	self.NormalPrice:Hide();
	self.SalePrice:Hide();
	self.CurrentPrice:Hide();
	self.Strikethrough:Hide();

	self.Description:Hide();

	self.DiscountRight:ClearAllPoints();
	self.DiscountRight:SetPoint("TOPRIGHT", 5, 2);

	self.DiscountLeft:ClearAllPoints();
	self.DiscountLeft:SetPoint("RIGHT", self.DiscountRight, "LEFT", -40, 0);

	self.DiscountMiddle:ClearAllPoints();
	self.DiscountMiddle:SetPoint("LEFT", self.DiscountLeft, "RIGHT", 0, 0);
	self.DiscountMiddle:SetPoint("RIGHT", self.DiscountRight, "LEFT", 0, 0);
	
	self.DiscountText:ClearAllPoints();
	self.DiscountText:SetSize(50, 30);
	self.DiscountText:SetPoint("CENTER", self.DiscountMiddle, "CENTER", 1, 2);

	self.ProductName:ClearAllPoints();
	self.ProductName:SetSize(184, 50);
	self.ProductName:SetPoint("BOTTOM", self.BuyButton, "CENTER", 0, 15);
	self.ProductName:SetFontObject("GameFontNormalMed2");
	self.ProductName:SetJustifyH("CENTER");
	self.ProductName:SetJustifyV("TOP");
	self.ProductName:SetTextColor(1, 1, 1);
	self.ProductName:SetShadowColor(0, 0, 0, 1);
	self.ProductName:SetShadowOffset(1, -1);

	self.ModelScene:ClearAllPoints();
	self.ModelScene:SetPoint("TOPLEFT", 2, -2);
	self.ModelScene:SetPoint("BOTTOMRIGHT", -2, 2);
	self.ModelScene:SetViewInsets(0, 0, 0, 0);
	
	self.Magnifier:ClearAllPoints();
	self.Magnifier:SetSize(31, 35);
	self.Magnifier:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8);

	self.Card:ClearAllPoints();	
	self.Card:SetAllPoints(self);
end

--------------------------------------------------
-- HORIZONTAL LARGE STORE CARD WITH A BUY BUTTON MIXIN 
HorizontalLargeStoreCardWithBuyButtonMixin = CreateFromMixins(VerticalLargeStoreCardWithBuyButtonMixin);

function HorizontalLargeStoreCardWithBuyButtonMixin:SetDefaultCardTexture()
	self.Card:SetAtlas("store-card-horizontalfull", true);
	self.Card:SetTexCoord(0, 1, 0, 1);
end

function HorizontalLargeStoreCardWithBuyButtonMixin:Layout()
	HorizontalLargeStoreCardMixin.Layout(self);

	local width, height = StoreFrame_GetCellPixelSize("HorizontalLargeStoreCardWithBuyButtonTemplate");
	self:SetSize(width, height);

	self:SetDefaultCardTexture();

	self.PurchasedText:SetText(BLIZZARD_STORE_PURCHASED);
	self.PurchasedText:ClearAllPoints();
	self.PurchasedText:SetPoint("CENTER", self.BuyButton, "CENTER", 8, 0);
	self.PurchasedText:Hide();

	self.PurchasedMark:Hide();

	self.DisclaimerText:ClearAllPoints();
	self.DisclaimerText:SetWidth(300);
	self.DisclaimerText:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 15, 15);

	self.SplashBanner:Hide();
	self.SplashBannerText:Hide();

	self.BuyButton:ClearAllPoints();
	self.BuyButton:SetPoint("BOTTOMRIGHT", -30, 7);
end

function HorizontalLargeStoreCardWithBuyButtonMixin:ShouldModelShowShadows()
	return false;
end

function HorizontalLargeStoreCardWithBuyButtonMixin:SetDisclaimerText(entryInfo)
	if entryInfo.sharedData.disclaimer then
		self.DisclaimerText:SetText(entryInfo.sharedData.disclaimer);
		self.DisclaimerText:Show();
	else
		self.DisclaimerText:Hide();
	end
end

function HorizontalLargeStoreCardWithBuyButtonMixin:SetupDescription(entryInfo)
	local description = entryInfo.sharedData.description;
	if not description then
		self.Description:Hide();
		return;
	end

	self.Description:SetText(description);
	self.Description:SetSize(184, 0);
	self.Description:ClearAllPoints();
	self.Description:SetPoint("BOTTOM", self.BuyButton, "TOP", 0, 0);
	self.Description:Show();

	self.Description:SetJustifyH("CENTER");
	self.Description:SetJustifyV("BOTTOM");
	
	self.ProductName:ClearAllPoints();
	self.ProductName:SetSize(184, 50);
	self.ProductName:SetJustifyH("CENTER");
	self.ProductName:SetJustifyV("BOTTOM");
	self.ProductName:SetPoint("BOTTOM", self.Description, "TOP", 0, 0);
end
