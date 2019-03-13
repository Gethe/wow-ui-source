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

Import("pairs");
Import("select");

function Mixin(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...);
		for k, v in pairs(mixin) do
			object[k] = v;
		end
	end

	return object;
end

function CreateFromMixins(...)
	return Mixin({}, ...)
end
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
Import("ShrinkUntilTruncateFontStringMixin");
Import("IsTrialAccount");
Import("IsVeteranTrialAccount");
Import("PortraitFrameTemplate_SetPortraitToAsset");
Import("BLIZZARD_STORE_BUY");

local BATTLEPAY_SPLASH_BANNER_TEXT_FEATURED = 0;
local BATTLEPAY_SPLASH_BANNER_TEXT_DISCOUNT = 1;
local BATTLEPAY_SPLASH_BANNER_TEXT_NEW = 2;


--------------------------------------------------
-- VERTICAL LARGE STORE CARD MIXIN
VerticalLargeStoreCardMixin = CreateFromMixins(StoreCardMixin);
function VerticalLargeStoreCardMixin:OnLoad()
	StoreCardMixin.OnLoad(self);

	self.SplashBannerText:SetShadowColor(0, 0, 0, 0);

	SecureMixin(self.ProductName, ShrinkUntilTruncateFontStringMixin);
	self.ProductName:SetFontObjectsToTry("GameFontNormalLarge2", "GameFontNormalLarge", "GameFontNormalMed3");
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

function VerticalLargeStoreCardMixin:SetupBuyButton(info, entryInfo)
	local text = info.browseBuyButtonText or BLIZZARD_STORE_BUY;
	self.BuyButton:SetText(text);
	self.BuyButton:SetEnabled(self:ShouldEnableBuyButton(entryInfo));
end

function VerticalLargeStoreCardMixin:SetupBannerText(discounted, discountPercentage, entryInfo)
	if entryInfo.bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_NEW then
		self.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_NEW);
	elseif entryInfo.bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_DISCOUNT then
		if discounted then
			self.SplashBannerText:SetText(string.format(BLIZZARD_STORE_SPLASH_BANNER_DISCOUNT_FORMAT, discountPercentage));
		else
			self.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FEATURED);
		end
	elseif entryInfo.bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_FEATURED then
		self.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FEATURED);
	end	
end

function VerticalLargeStoreCardMixin:UpdateState()
	-- we override the StoreCardMixin:UpdateState here to prevent "selected" functionality in LargeCards
end

function VerticalLargeStoreCardMixin:ShouldShowIcon(entryInfo)
	return StoreCardMixin.ShouldShowIcon(self, entryInfo) and not entryInfo.sharedData.overrideBackground;
end

function VerticalLargeStoreCardMixin:SetupDescription(entryInfo)
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

function VerticalLargeStoreCardMixin:Layout()
	self:SetSize(286, 471);
	self.Card:ClearAllPoints();
	self.Card:SetTexture("Interface\\Store\\Store-Main");
	self.Card:SetTexCoord(0.00097656, 0.56347656, 0.00097656, 0.46093750);	
	self.Card:SetAllPoints(self);
	
	self.Shadows:ClearAllPoints();
	self.Shadows:SetPoint("CENTER");
	
	self.Icon:ClearAllPoints();
	self.Icon:SetSize(63, 63);
	self.Icon:SetPoint("CENTER", self, "TOP", 0, -69);
	
	self.IconBorder:ClearAllPoints();
	self.IconBorder:SetPoint("CENTER", self.Icon, "CENTER", 0, -5);
	
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
	self.ProductName:SetSize(250, 50);
	self.ProductName:SetPoint("BOTTOM", self, "CENTER", 0, -22);
	self.ProductName:SetFontObject("GameFontNormalLarge");
	self.ProductName:SetJustifyH("CENTER");
	self.ProductName:SetJustifyV("BOTTOM");
	self.ProductName:SetTextColor(1, 1, 1);
	self.ProductName:SetShadowColor(0, 0, 0, 0);
	self.ProductName:SetShadowOffset(1, -1);
	
	self.Description:ClearAllPoints();
	self.Description:SetSize(250, 0);
	self.Description:SetPoint("LEFT", self.ProductName, "LEFT", 0, 0);
	self.Description:SetPoint("RIGHT", self.ProductName, "RIGHT", 0, 0);
	self.Description:SetPoint("TOP", self.CurrentPrice, "BOTTOM", 0, 0);
	
	self.SelectedTexture:Hide();

	self.UpgradeArrow:ClearAllPoints();
	self.UpgradeArrow:SetPoint("BOTTOMRIGHT", self.IconBorder, "BOTTOMRIGHT", -3, 4);

	self.HighlightTexture:ClearAllPoints();
	self.HighlightTexture:SetAtlas("shop-card-half-hover", true);
	self.HighlightTexture:SetTexCoord(0, 1, 0, 1);	
	self.HighlightTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4);

	self.DiscountRight:ClearAllPoints();
	self.DiscountRight:SetPoint("TOPRIGHT", 1, -2);

	self.DiscountLeft:ClearAllPoints();
	self.DiscountLeft:SetPoint("RIGHT", self.DiscountRight, "LEFT", -40, 0);

	self.DiscountMiddle:ClearAllPoints();
	self.DiscountMiddle:SetPoint("LEFT", self.DiscountLeft, "RIGHT", 0, 0);
	self.DiscountMiddle:SetPoint("RIGHT", self.DiscountRight, "LEFT", 0, 0);
	
	self.DiscountText:ClearAllPoints();
	self.DiscountText:SetSize(50, 30);
	self.DiscountText:SetPoint("CENTER", self.DiscountMiddle, "CENTER", 1, 2);
	
	self.SplashBanner:Hide();
	self.SplashBannerText:Hide();
	
	self.Strikethrough:ClearAllPoints();
	self.Strikethrough:SetPoint("TOPLEFT", self.NormalPrice, "TOPLEFT", 0, 0);
	self.Strikethrough:SetPoint("BOTTOMRIGHT", self.NormalPrice, "BOTTOMRIGHT", 0, 0);
	
	self.ModelScene:ClearAllPoints();
	self.ModelScene:SetPoint("TOPLEFT", 8, -8);
	self.ModelScene:SetPoint("BOTTOMRIGHT", -8, 8);
	self.ModelScene:SetViewInsets(20, 20, 20, 160);
	
	self.Magnifier:ClearAllPoints();
	self.Magnifier:SetSize(31, 35);
	self.Magnifier:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8);
	
	self.InvisibleMouseOverFrame:Hide();
	
	self.Checkmark:ClearAllPoints();
	self.Checkmark:SetSize(27, 27);
	self.Checkmark:SetPoint("TOPRIGHT", -8, -8);		
	
	self.CurrentMarketPrice:SetSize(250, 0);
	self.CurrentMarketPrice:ClearAllPoints();
	self.CurrentMarketPrice:SetPoint("TOP", self.ProductName, "BOTTOM", 0, -4);
	self.CurrentMarketPrice:SetTextColor(0.733, 0.588, 0.31);
	
	self.Description:ClearAllPoints();
	self.Description:SetSize(250, 0);
	self.Description:SetPoint("LEFT", self.ProductName, "LEFT");
	self.Description:SetPoint("RIGHT", self.ProductName, "RIGHT");
	self.Description:SetPoint("TOP", self.CurrentPrice, "BOTTOM", 0, -12);

	self.BuyButton:ClearAllPoints();
	self.BuyButton:SetSize(140, 30);
	self.BuyButton:SetPoint("BOTTOM", 0, 20);

	self.SplashBanner:Hide();
	self.SplashBannerText:Hide();
	
	self.GlowSpin:Hide();
	self.GlowPulse:Hide();
	self.BannerFadeIn:Hide();	
end


--------------------------------------------------
-- HORIZONTAL LARGE STORE CARD MIXIN
HorizontalLargeStoreCardMixin = CreateFromMixins(VerticalLargeStoreCardMixin);

function HorizontalLargeStoreCardMixin:OnLoad()
	StoreCardMixin.OnLoad(self);

	SecureMixin(self.ProductName, ShrinkUntilTruncateFontStringMixin);
	self.ProductName:SetFontObjectsToTry("GameFontNormalLarge2", "GameFontNormalLarge", "GameFontNormalMed3");
	self.ProductName:SetSpacing(0);
end

function HorizontalLargeStoreCardMixin:GetCurrencyFormat(currencyInfo)
	return currencyInfo.formatLong;
end
