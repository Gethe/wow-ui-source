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

local SEE_YOU_LATER_BUNDLE_PRODUCT_ID = 488;


--------------------------------------------------
-- SMALL STORE CARD MIXIN
SmallStoreCardMixin = CreateFromMixins(StoreCardMixin);

function SmallStoreCardMixin:ShowDiscount(discountText)
	StoreCardMixin.ShowDiscount(self, discountText);

	local width = self.NormalPrice:GetStringWidth() + self.SalePrice:GetStringWidth();

	self.NormalPrice:ClearAllPoints();
	self.SalePrice:ClearAllPoints();

	if ((width + 20 + (self:GetWidth()/8)) > self:GetWidth()) then
		self.NormalPrice:SetJustifyH("CENTER");
		self.NormalPrice:SetPoint(unpack(self.basePoint));

		self.SalePrice:SetJustifyH("CENTER");
		self.SalePrice:SetPoint("TOP", self.NormalPrice, "BOTTOM", 0, -4);		
	else
		local diff = self.NormalPrice:GetStringWidth() - self.SalePrice:GetStringWidth();
		local yOffset = select(5, unpack(self.basePoint));

		self.NormalPrice:SetJustifyH("RIGHT");
		self.NormalPrice:SetPoint("BOTTOMRIGHT", self, "BOTTOM", diff/2, yOffset);

		self.SalePrice:SetJustifyH("LEFT");
		self.SalePrice:SetPoint("BOTTOMLEFT", self.NormalPrice, "BOTTOMRIGHT", 4, -1);
	end
end

function SmallStoreCardMixin:Layout()	
	self.Card:ClearAllPoints();
	self.Card:SetPoint("CENTER");
	
	self.Shadows:ClearAllPoints();
	self.Shadows:SetPoint("CENTER");
	
	self.Icon:ClearAllPoints();
	self.Icon:SetSize(63, 63);
	self.Icon:SetPoint("CENTER", self, "TOP", 0, -69);
	
	self.IconBorder:ClearAllPoints();
	self.IconBorder:SetPoint("CENTER", self.Icon, "CENTER", 0, -5);
	
	self.CurrentMarketPrice:Hide();
	
	self.CurrentPrice:ClearAllPoints();
	self.CurrentPrice:SetPoint("BOTTOM", 0, 32);
	
	self.NormalPrice:ClearAllPoints();
	self.NormalPrice:SetPoint("BOTTOM", 0, 32);

	self.SalePrice:ClearAllPoints();
	self.SalePrice:SetPoint("BOTTOM", 0, 18);
	self.SalePrice:SetTextColor(0.1, 1, 0.1);
	
	self.ProductName:ClearAllPoints();
	self.ProductName:SetSize(120, 40);
	self.ProductName:SetPoint("BOTTOM", 0, 42);
	self.ProductName:SetTextColor(1, 1, 1);
	
	self.SelectedTexture:ClearAllPoints();
	self.SelectedTexture:SetPoint("CENTER", self, "CENTER", 0, 0);

	self.UpgradeArrow:ClearAllPoints();
	self.UpgradeArrow:SetPoint("BOTTOMRIGHT", self.IconBorder, "BOTTOMRIGHT", -3, 4);

	self.HighlightTexture:ClearAllPoints();
	self.HighlightTexture:SetPoint("CENTER", self, "CENTER", 0, 0);

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
	self.DiscountText:SetTextColor(1, 1, 1);
	
	self.Strikethrough:ClearAllPoints();
	self.Strikethrough:SetPoint("TOPLEFT", self.NormalPrice, "TOPLEFT", -2, 0);
	self.Strikethrough:SetPoint("BOTTOMRIGHT", self.NormalPrice, "BOTTOMRIGHT", -2, 0);
	
	self.GlowSpin:Hide();	
	self.GlowPulse:Hide();
	self.BannerFadeIn:Hide();
	
	self.ModelScene:ClearAllPoints();
	self.ModelScene:SetPoint("TOPLEFT", 8, -8);
	self.ModelScene:SetPoint("BOTTOMRIGHT", -8, 8);
	self.ModelScene:SetViewInsets(15, 15, 17, 77);
	
	self.Magnifier:ClearAllPoints();
	self.Magnifier:SetSize(31, 35);
	self.Magnifier:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8);
	
	self.InvisibleMouseOverFrame:Hide();
	
	self.Checkmark:ClearAllPoints();
	self.Checkmark:SetSize(27, 27);
	self.Checkmark:SetPoint("TOPRIGHT", -7, -10);	
end


--------------------------------------------------
-- MEDIUM STORE CARD MIXIN
MediumStoreCardMixin = CreateFromMixins(SmallStoreCardMixin);

function MediumStoreCardMixin:ShowDiscount(discountText)
	StoreCardMixin.ShowDiscount(self, discountText);
	
	local yOffset = 23;
	local diff = self.NormalPrice:GetStringWidth() - self.SalePrice:GetStringWidth();
	
	self.NormalPrice:ClearAllPoints();
	self.NormalPrice:SetJustifyH("RIGHT");
	self.NormalPrice:SetPoint("BOTTOMRIGHT", self, "BOTTOM", diff/2, yOffset);
	self.SalePrice:ClearAllPoints();
	self.SalePrice:SetJustifyH("LEFT");
	self.SalePrice:SetPoint("BOTTOMLEFT", self.NormalPrice, "BOTTOMRIGHT", 4, -1);	
end

function MediumStoreCardMixin:SetDiscountText(discountPercentage)
	self.DiscountText:SetWidth(200);
	self.DiscountText:SetText(BLIZZARD_STORE_BUNDLE_DISCOUNT_BANNER:format(discountPercentage));
end

function MediumStoreCardMixin:ShowIcon(displayData)
	StoreCardMixin.ShowIcon(self, displayData)
	
	if displayData.overrideTexture then
		self.Icon:ClearAllPoints();
		self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT");	
	end
end

function MediumStoreCardMixin:ShouldAddDiscountInformationToTooltip(entryInfo)
	if not StoreFrame_HasPriceData(entryInfo.productID) then
		return false;
	end
	
	if entryInfo.productID == SEE_YOU_LATER_BUNDLE_PRODUCT_ID then
		return false;
	end
	
	return true; -- For now, all bundles are medium and there are no other medium cards.
end

function MediumStoreCardMixin:Layout()
	SmallStoreCardMixin.Layout(self);

	self:SetWidth(146 * 2);
	self.Card:SetAtlas("shop-card-bundle", true);
	self.Card:SetTexCoord(0, 1, 0, 1);

	self.HighlightTexture:SetAtlas("shop-card-bundle-hover", true);
	self.HighlightTexture:SetTexCoord(0, 1, 0, 1);

	self.SelectedTexture:SetAtlas("shop-card-bundle-selected", true);
	self.SelectedTexture:SetTexCoord(0, 1, 0, 1);

	self.ProductName:SetWidth(146 * 2 - 30);
	self.ProductName:ClearAllPoints();
	self.ProductName:SetPoint("BOTTOM", 0, 33);

	self.CurrentPrice:ClearAllPoints();
	self.CurrentPrice:SetPoint("BOTTOM", 0, 23);
end
