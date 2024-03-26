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
Import("C_StoreSecure");
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

local SEE_YOU_LATER_BUNDLE_PRODUCT_ID = 488;


--------------------------------------------------
-- FULL STORE CARD MIXIN
FullStoreCardMixin = CreateFromMixins(StoreCardMixin);

function FullStoreCardMixin:OnLoad()
	StoreCardMixin.OnLoad(self);
	
	self.SplashBannerText:SetShadowColor(0, 0, 0, 0);

	self.ProductName:SetSpacing(0);
	self.Description:SetSpacing(2);	
end

function FullStoreCardMixin:OnEnter()
	self:ShowTooltip();
end

function FullStoreCardMixin:ShowTooltip()
	if self.productTooltipTitle then
		StoreTooltip:ClearAllPoints();
		if self.anchorRight then
			StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", -7, -6);
		else
			StoreTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 7, -6);
		end
		
		local entryInfo = self:GetEntryInfo();
		local description = self:AppendBundleInformationToTooltipDescription(entryInfo, self.productTooltipDescription);
		description = strtrim(description, "\n\r"); -- Ensure we don't end the description with a new line.		
		StoreTooltip_Show(self.productTooltipTitle, description);
	end
end

function FullStoreCardMixin:OnLeave()
	self.HighlightTexture:Hide();
	StoreTooltip:Hide();
end

function FullStoreCardMixin:OnClick()
	StoreProductCard_CheckShowStorePreviewOnClick(self);
end

function FullStoreCardMixin:GetCurrencyFormat(currencyInfo)
	return currencyInfo.formatLong;
end

function FullStoreCardMixin:UpdateBannerText(discounted, discountPercentage, displayInfo)
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

function FullStoreCardMixin:ShowDiscount(discountText)
	StoreCardMixin.ShowDiscount(self, discountText);

	local width = self.NormalPrice:GetStringWidth() + self.SalePrice:GetStringWidth();

	if (width + 120 + (self:GetWidth()/8)) > self:GetWidth() then
		self.SalePrice:ClearAllPoints();
		self.SalePrice:SetPoint("TOPLEFT", self.NormalPrice, "BOTTOMLEFT", 0, -4);
	else
		self.SalePrice:ClearAllPoints();
		self.SalePrice:SetPoint("BOTTOMLEFT", self.NormalPrice, "BOTTOMRIGHT", 4, 0);
	end
end

function FullStoreCardMixin:SetupWoWToken(entryInfo)
	if entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.WoWToken then
		local price = C_WowTokenPublic.GetCurrentMarketPrice();
		if (price) then
			self.CurrentMarketPrice:SetText(string.format(TOKEN_CURRENT_AUCTION_VALUE, GetSecureMoneyString(price, true)));
		else
			self.CurrentMarketPrice:SetText(string.format(TOKEN_CURRENT_AUCTION_VALUE, TOKEN_MARKET_PRICE_NOT_AVAILABLE));
		end
		self.CurrentPrice:ClearAllPoints();
		self.CurrentPrice:SetPoint("TOPLEFT", self.CurrentMarketPrice, "BOTTOMLEFT", 0, -28);
		self.NormalPrice:ClearAllPoints();
		self.NormalPrice:SetPoint("TOPLEFT", self.CurrentMarketPrice, "BOTTOMLEFT", 0, -28);
		self.CurrentMarketPrice:Show();
	else
		self.CurrentMarketPrice:Hide();
	end
end

function FullStoreCardMixin:SetupDescription(entryInfo)
	local description = entryInfo.sharedData.description;
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

function FullStoreCardMixin:ShouldModelShowShadows()
	return false;
end

function FullStoreCardMixin:InitMagnifier()
	self.Magnifier:SetShown(self:ShouldShowMagnifyingGlass());
end

function FullStoreCardMixin:SetDefaultCardTexture()
	self.Card:SetPoint("TOPLEFT");
	self.Card:SetPoint("BOTTOMRIGHT");
	self.Card:SetSize(576, 471);
	self.Card:SetTexture("Interface\\Store\\Store-Main");
	self.Card:SetTexCoord(0.00097656, 0.56347656, 0.00097656, 0.46093750);
end

function FullStoreCardMixin:GetTooltipOffsets()	
	local point = "RIGHT";
	local rpoint = "BOTTOMRIGHT";
	local x = self:GetLeft();
	local y = self:GetTop();
	return x, y, point, rpoint;
end

function FullStoreCardMixin:ShouldShowIcon(entryInfo)
	return StoreCardMixin.ShouldShowIcon(self, entryInfo) and (entryInfo.sharedData.texture or entryInfo.sharedData.overrideTexture) and entryInfo.productID ~= 1068;
end

function FullStoreCardMixin:ShowIcon(displayData)
	local icon = displayData.texture or self:GetDefaultIconName();
	local shouldShow = displayData.itemID ~= nil;
	self.InvisibleMouseOverFrame:SetShown(shouldShow);
	
	self.Icon:ClearAllPoints();
	
	local overrideTexture = displayData.overrideTexture;
	local useSquareBorder = bit.band(displayData.flags, Enum.BattlepayDisplayFlag.UseSquareIconBorder) == Enum.BattlepayDisplayFlag.UseSquareIconBorder;

	if overrideTexture then
		self.IconBorder:Hide();
		self.Icon:SetAtlas(overrideTexture, true);


		self.Icon:SetPoint("TOPLEFT", 4, -4);
	else			
		self.Icon:SetPoint("CENTER", self, "TOP", 0, -69);
		self.Icon:SetSize(64, 64);

		if useSquareBorder then -- square icon borders use atlases
			self.Icon:SetTexture(icon);

			self.IconBorder:ClearAllPoints();
			self.Icon:ClearAllPoints();
			self.Icon:SetPoint("TOPLEFT", 88, -99);

			self.IconBorder:SetAtlas("collections-itemborder-collected");
			self.IconBorder:SetTexCoord(0, 1, 0, 1);
			self.IconBorder:SetSize(80, 81);
			self.IconBorder:SetPoint("CENTER", self.Icon, "CENTER", 0, -3);
		else -- round icon borders use textures
			SetPortraitToTexture(self.Icon, icon);
			self.IconBorder:ClearAllPoints();

			self.Icon:ClearAllPoints();
			self.Icon:SetPoint("TOPLEFT", 88, -99);
			self.IconBorder:SetTexture("Interface\\Store\\Store-Splash");
			self.IconBorder:SetTexCoord(0.55957031, 0.79589844, 0.26269531, 0.51660156);
			self.IconBorder:SetSize(242, 260);
			self.IconBorder:SetPoint("TOPLEFT", 4, -4);
		end		
		self.IconBorder:Show();
	end
	self.Icon:Show();
	
	if self.GlowSpin and not overrideTexture then
		self.GlowSpin.SpinAnim:Play();
		self.GlowSpin:Show();
	elseif self.GlowSpin then
		self.GlowSpin.SpinAnim:Stop();
		self.GlowSpin:Hide();
	end

	if self.GlowPulse and not overrideTexture then
		self.GlowPulse.PulseAnim:Play();
		self.GlowPulse:Show();
	elseif self.GlowPulse then
		self.GlowPulse.PulseAnim:Stop();
		self.GlowPulse:Hide();
	end
end

function FullStoreCardMixin:Layout()
	self.Shadows:ClearAllPoints();
	self.Shadows:SetTexture("Interface\\Store\\Store-Main");
	self.Shadows:SetTexCoord(0.84375000, 0.97851563, 0.29980469, 0.37011719);
	self.Shadows:SetSize(138, 72);
	self.Shadows:SetPoint("TOPLEFT", 4, -4);

	self.Icon:ClearAllPoints();
	self.Icon:SetSize(68, 68);
	self.Icon:SetPoint("TOPLEFT", 88, -99);

	self.IconBorder:ClearAllPoints();
	self.IconBorder:SetTexture("Interface\\Store\\Store-Splash");
	self.IconBorder:SetTexCoord(0.55957031, 0.79589844, 0.26269531, 0.51660156);
	self.IconBorder:SetSize(242, 260);
	self.IconBorder:SetPoint("TOPLEFT", 4, -4);

	self.UpgradeArrow:ClearAllPoints();
	self.UpgradeArrow:SetPoint("CENTER", self.IconBorder, "CENTER", 18, -26);

	self.ProductName:ClearAllPoints();
	self.ProductName:SetFontObject("GameFontNormalWTF2");
	self.ProductName:SetJustifyV("TOP");
	self.ProductName:SetShadowOffset(1, -1);
	self.ProductName:SetShadowColor(0, 0, 0, 1);

	self.Description:ClearAllPoints();
	self.Description:SetFontObject("GameFontNormalLarge");
	self.Description:SetJustifyH("LEFT");
	self.Description:SetJustifyV("TOP");
	self.Description:SetTextColor(1, 0.84, 0.55);

	self.CurrentMarketPrice:ClearAllPoints();
	self.CurrentMarketPrice:SetSize(340, 0);
	self.CurrentMarketPrice:SetFontObject("GameFontNormalMed2");
	self.CurrentMarketPrice:SetJustifyH("LEFT");
	self.CurrentMarketPrice:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", 0, -28);
	self.CurrentMarketPrice:SetTextColor(0.733, 0.588, 0.31);

	self.SplashBanner:ClearAllPoints();
	self.SplashBanner:SetSize(374, 77);
	self.SplashBanner:SetPoint("TOP", 3, 2);
	
	self.SplashBannerText:ClearAllPoints();
	self.SplashBannerText:SetPoint("CENTER", self.SplashBanner, "CENTER", 0, 16);
	self.SplashBannerText:SetTextColor(0.36, 0.18, 0.05);

	self.Strikethrough:ClearAllPoints();
	self.Strikethrough:SetPoint("TOPLEFT", self.NormalPrice, "TOPLEFT", 0, 0);
	self.Strikethrough:SetPoint("BOTTOMRIGHT", self.NormalPrice, "BOTTOMRIGHT", 0, 0);

	self.GlowSpin:ClearAllPoints();
	self.GlowSpin:SetSize(253, 256);
	self.GlowSpin:SetPoint("CENTER", self.IconBorder, "CENTER", 0, 0);

	self.GlowPulse:ClearAllPoints();
	self.GlowPulse:SetSize(145, 138);
	self.GlowPulse:SetPoint("CENTER", self.IconBorder, "CENTER", 0, 0);

	self.BannerFadeIn:ClearAllPoints();
	self.BannerFadeIn:SetSize(374, 77);
	self.BannerFadeIn:SetPoint("TOP", 3, 2);

	self.InvisibleMouseOverFrame:ClearAllPoints();
	self.InvisibleMouseOverFrame:SetSize(68, 68);
	self.InvisibleMouseOverFrame:SetPoint("TOPLEFT", 86, -96);

	self.Magnifier:ClearAllPoints();
	self.Magnifier:SetSize(31, 35);
	self.Magnifier:SetPoint("TOPLEFT", self.Card, "TOPLEFT", 8, -8);

	self.Checkmark:SetSize(27, 27);
	self.Checkmark:ClearAllPoints();
	self.Checkmark:SetPoint("LEFT", self.Magnifier, "RIGHT", 9, 0);
	self.Checkmark:Hide();
end

function FullStoreCardMixin:SetStyle(entryInfo)
	self.Card:ClearAllPoints();

	local displayInfo =  entryInfo.sharedData;
	if displayInfo.bannerType == Enum.BattlepayBannerType.None then
		self.SplashBanner:Hide();
		self.SplashBannerText:Hide();
	else
		self.SplashBanner:Show();
		self.SplashBannerText:Show();
	end
	
	self.DiscountMiddle:Hide();
	self.DiscountLeft:Hide();
	self.DiscountRight:Hide();
	self.DiscountText:Hide();
	
	local overrideBackground = entryInfo.sharedData.overrideBackground;
	if overrideBackground then
		self.Card:SetPoint("CENTER");
		self.Card:SetAtlas(overrideBackground, true);
		self.Card:SetTexCoord(0, 1, 0, 1);
	else
		self:SetDefaultCardTexture();
	end
end


--------------------------------------------------
-- HORIZONTAL FULL STORE CARD MIXIN
HorizontalFullStoreCardMixin = CreateFromMixins(FullStoreCardMixin, ProductCardBuyButtonMixin);

function HorizontalFullStoreCardMixin:Layout()
	FullStoreCardMixin.Layout(self);

	local width, height = StoreFrame_GetCellPixelSize("HorizontalFullStoreCardWithBuyButtonTemplate");
	self:SetSize(width, height);
end

function HorizontalFullStoreCardMixin:SetStyle(entryInfo)
	FullStoreCardMixin.SetStyle(self, entryInfo);

	self.ModelScene:ClearAllPoints();
	self.ModelScene:SetPoint("TOPLEFT", 4, -4);
	self.ModelScene:SetPoint("BOTTOMRIGHT", -4, 4);
	self.ModelScene:SetViewInsets(0, 0, 0, 0);

	self.ProductName:ClearAllPoints();
	self.CurrentPrice:ClearAllPoints();
	self.NormalPrice:ClearAllPoints();
	self.Description:ClearAllPoints();

	if not self.ProductName.SetFontObjectsToTry then
		SecureMixin(self.ProductName, AutoScalingFontStringMixin);
	end
	self.ProductName:SetWidth(535);
	self.ProductName:SetMaxLines(1);
	self.ProductName:SetPoint("CENTER", 0, -63);
	self.ProductName:SetJustifyH("CENTER");
	self.ProductName:SetFontObject("Game30Font");
	self.ProductName:SetMinLineHeight(18);
	self.ProductName:SetShadowOffset(1, -1);
	self.ProductName:SetShadowColor(0, 0, 0, 1);

	self.CurrentPrice:SetPoint("TOP", self.ProductName, "BOTTOM", 0, -6);

	local normalWidth = self.NormalPrice:GetStringWidth();
	local totalWidth = normalWidth + self.SalePrice:GetStringWidth();
	self.NormalPrice:SetPoint("TOP", self.ProductName, "BOTTOM", (normalWidth - totalWidth) / 2, -9);

	self.Description:SetPoint("TOP", self.ProductName, "BOTTOM", 0, -10);
	self.Description:SetFontObject("GameFontNormalMed1");
	self.Description:SetWidth(490);
	self.Description:SetJustifyH("CENTER");

	self.SalePrice:SetFontObject("GameFontNormalLarge2");

	self.PurchasedText:SetText(BLIZZARD_STORE_PURCHASED);
	self.PurchasedText:ClearAllPoints();
	self.PurchasedText:SetPoint("BOTTOM", 0, 33);
	self.PurchasedText:Hide();

	self.PurchasedMark:Hide();

	self.BuyButton:ClearAllPoints();
	self.BuyButton:SetPoint("BOTTOM", 0, 33);
end

--------------------------------------------------
-- HORIZONTAL FULL STORE CARD WITH NYDUS LINK MIXIN 
HorizontalFullStoreCardWithNydusLinkMixin = CreateFromMixins(FullStoreCardMixin);

function HorizontalFullStoreCardWithNydusLinkMixin:Layout()
	FullStoreCardMixin.Layout(self);

	local width, height = StoreFrame_GetCellPixelSize("HorizontalFullStoreCardWithBuyButtonTemplate");
	self:SetSize(width, height);
end

function HorizontalFullStoreCardWithNydusLinkMixin:SetStyle(entryInfo)
	FullStoreCardMixin.SetStyle(self, entryInfo);

	self.ModelScene:ClearAllPoints();
	self.ModelScene:SetPoint("TOPLEFT", 4, -4);
	self.ModelScene:SetPoint("BOTTOMRIGHT", -4, 4);
	self.ModelScene:SetViewInsets(0, 0, 0, 0);

	self.ProductName:ClearAllPoints();
	self.CurrentPrice:ClearAllPoints();
	self.NormalPrice:ClearAllPoints();
	self.Description:ClearAllPoints();

	if not self.ProductName.SetFontObjectsToTry then
		SecureMixin(self.ProductName, AutoScalingFontStringMixin);
	end
	self.ProductName:SetWidth(535);
	self.ProductName:SetMaxLines(1);
	self.ProductName:SetPoint("CENTER", 0, -63);
	self.ProductName:SetJustifyH("CENTER");
	self.ProductName:SetFontObject("Game30Font");
	self.ProductName:SetMinLineHeight(18);
	self.ProductName:SetShadowOffset(1, -1);
	self.ProductName:SetShadowColor(0, 0, 0, 1);

	self.CurrentPrice:Hide();
	self.NormalPrice:Hide();

	self.Description:SetPoint("TOP", self.ProductName, "BOTTOM", 0, -10);
	self.Description:SetFontObject("GameFontNormalMed1");
	self.Description:SetWidth(490);
	self.Description:SetJustifyH("CENTER");

	self.SalePrice:Hide();

	self.PurchasedText:SetText(BLIZZARD_STORE_PURCHASED);
	self.PurchasedText:ClearAllPoints();
	self.PurchasedText:SetPoint("BOTTOM", 0, 33);
	self.PurchasedText:Hide();

	self.PurchasedMark:Hide();

	self.NydusLinkButton:ClearAllPoints();
	self.NydusLinkButton:SetPoint("BOTTOM", 0, 33);
	self.NydusLinkButton:SetText(BLIZZARD_STORE_EXTERNAL_LINK_BUTTON_TEXT);
end

--------------------------------------------------
-- VERTICAL FULL STORE CARD MIXIN
VerticalFullStoreCardMixin = CreateFromMixins(FullStoreCardMixin, ProductCardBuyButtonMixin);

function VerticalFullStoreCardMixin:Layout()
	FullStoreCardMixin.Layout(self);

	local width, height = StoreFrame_GetCellPixelSize("VerticalFullStoreCardWithBuyButtonTemplate");
	self:SetSize(width, height);
end

function VerticalFullStoreCardMixin:SetStyle(entryInfo)
	FullStoreCardMixin.SetStyle(self, entryInfo);

	self.ProductName:ClearAllPoints();
	self.CurrentPrice:ClearAllPoints();
	self.NormalPrice:ClearAllPoints();
	self.Description:ClearAllPoints();

	if not self.ProductName.SetFontObjectsToTry then
		SecureMixin(self.ProductName, AutoScalingFontStringMixin);
	end
	self.ProductName:SetWidth(300);
	self.ProductName:SetMaxLines(1);
	self.ProductName:SetPoint("TOPLEFT", self, "TOP", -83, -70);
	self.ProductName:SetJustifyH("LEFT");
	self.ProductName:SetFontObject("GameFontNormalWTF2");
	self.ProductName:SetMinLineHeight(25);

	self.CurrentPrice:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", 0, -28);

	self.NormalPrice:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", 0, -28);

	self.Description:SetPoint("TOPLEFT", self.ProductName, "BOTTOMLEFT", 0, -16);
	self.Description:SetFontObject("GameFontNormalLarge");
	self.Description:SetWidth(340);
	self.Description:SetJustifyH("LEFT");

	self.SalePrice:SetFontObject("GameFontNormalLarge2");

	self.ModelScene:ClearAllPoints();
	self.ModelScene:SetPoint("TOPLEFT", 6, -6);
	self.ModelScene:SetPoint("BOTTOM", -6, 6);
	self.ModelScene:SetPoint("RIGHT", self.Description, "LEFT", 0, 8);
	self.ModelScene:SetViewInsets(0, 0, 0, 0);

	self.PurchasedText:SetText(BLIZZARD_STORE_PURCHASED);
	self.PurchasedText:ClearAllPoints();
	self.PurchasedText:SetPoint("TOPLEFT", self.CurrentPrice, "BOTTOMLEFT", 0, -20);
	self.PurchasedText:Hide();

	self.PurchasedMark:Hide();

	self.BuyButton:ClearAllPoints();
	self.BuyButton:SetPoint("TOPLEFT", self.CurrentPrice, "BOTTOMLEFT", 0, -20);
end
