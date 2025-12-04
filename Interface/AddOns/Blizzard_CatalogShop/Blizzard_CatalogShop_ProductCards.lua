--------------------------------------------------
-- CATALOG SHOP SECTION HEADER MIXIN
CatalogShopSectionHeaderMixin = {};
function CatalogShopSectionHeaderMixin:OnLoad()
end

function CatalogShopSectionHeaderMixin:Init()
end

function CatalogShopSectionHeaderMixin:SetHeaderText(elementData)
	if not elementData then
		return;
	end
	local sectionInfo = C_CatalogShop.GetCategorySectionInfo(elementData.categoryID, elementData.sectionID);
	if not sectionInfo then
		return;
	end
	self.headerText:SetText(sectionInfo.displayName);
end
function CatalogShopSectionHeaderMixin:UpdateTimeRemaining()
	-- Currently nothing to do for headers with time remaining.
end

--------------------------------------------------
-- SMALL CATALOG SHOP SERVICES CARD MIXIN
SmallCatalogShopServicesCardMixin = {};
function SmallCatalogShopServicesCardMixin:OnLoad()
	SmallCatalogShopProductCardMixin.OnLoad(self);
end

local function ServicesCardLayout(card)
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(card.productInfo.catalogShopProductID);

	-- Skip services-specific display for unknown (cross-game) licenses
	if displayInfo.hasUnknownLicense then
		return;
	end

	local container = card.ForegroundContainer;

	container.CircleIcon:Show();
	CatalogShopUtil.SetServicesContainerIcon(container.CircleIcon, displayInfo);
	container.CircleIconBorder:Show();

	if card.productInfo.bundleChildrenSize > 1 then
		container.ProductCounter:Show();
		container.ProductCounterText:Show();
		container.ProductCounterText:SetText(card.productInfo.bundleChildrenSize);
	end
end

function SmallCatalogShopServicesCardMixin:Layout()
	SmallCatalogShopProductCardMixin.Layout(self);
	ServicesCardLayout(self);
end


--------------------------------------------------
-- SMALL CATALOG SHOP SUBSCRIPTION CARD MIXIN
-- Both sub time and game time have the same display type, but their Atlases are distinct
SmallCatalogShopSubscriptionCardMixin = {};
function SmallCatalogShopSubscriptionCardMixin:OnLoad()
	SmallCatalogShopProductCardMixin.OnLoad(self);
end

local function SubTimeAndGameTimeCardLayout(card)
	local container = card.ForegroundContainer;
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(card.productInfo.catalogShopProductID);

	-- Skip time-specific display for unknown (cross-game) licenses
	if displayInfo.hasUnknownLicense then
		container.RectIcon:Hide();
		return;
	end

	local atlasWidth = 140;
	local atlasHeight = 140;

	container.RectIcon:ClearAllPoints();
	container.RectIcon:SetPoint("CENTER", 0, 40);
	container.RectIcon:SetSize(atlasWidth, atlasHeight);

	local timeTexture = CatalogShopUtil.GetTimeTexture(card.productInfo, card.productInfo.cardDisplayData.productType);
	if timeTexture then
		container.RectIcon:Show();
		container.RectIcon:SetAtlas(timeTexture);
	else
		container.RectIcon:Hide();
	end
end

function SmallCatalogShopSubscriptionCardMixin:Layout()
	SmallCatalogShopProductCardMixin.Layout(self);
	SubTimeAndGameTimeCardLayout(self);
end


--------------------------------------------------
-- SMALL CATALOG SHOP GAME TIME CARD MIXIN
-- Both sub time and game time have the same display type, but their Atlases are distinct
SmallCatalogShopGameTimeCardMixin = {};
function SmallCatalogShopGameTimeCardMixin:OnLoad()
	SmallCatalogShopProductCardMixin.OnLoad(self);
end

function SmallCatalogShopGameTimeCardMixin:Layout()
	SmallCatalogShopProductCardMixin.Layout(self);
	SubTimeAndGameTimeCardLayout(self);
end


--------------------------------------------------
-- SMALL CATALOG SHOP TENDER CARD MIXIN
SmallCatalogShopTenderCardMixin = {};
function SmallCatalogShopTenderCardMixin:OnLoad()
	SmallCatalogShopProductCardMixin.OnLoad(self);
end

local function TenderCardLayout(card)
	local container = card.ForegroundContainer;
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(card.productInfo.catalogShopProductID);
	local quantity = displayInfo and displayInfo.quantity or nil;

	-- Skip tender-specific display for unknown (cross-game) licenses or if the quantity is missing
	if displayInfo.hasUnknownLicense or (not quantity) then
		container.RectIcon:Hide();
		return;
	end

	container.RectIcon:ClearAllPoints();
	container.RectIcon:SetPoint("CENTER", 0, 40);

	local subTexture;
	subTexture = "tender-"..quantity;
	local atlasWidth = 140;
	local atlasHeight = 140;
	container.RectIcon:SetSize(atlasWidth, atlasHeight);

	if subTexture then
		container.RectIcon:Show();
		container.RectIcon:SetAtlas(subTexture);
	else
		container.RectIcon:Hide();
	end
end

function SmallCatalogShopTenderCardMixin:Layout()
	SmallCatalogShopProductCardMixin.Layout(self);
	TenderCardLayout(self);
end


--------------------------------------------------
-- SMALL CATALOG SHOP TOYS CARD MIXIN
SmallCatalogShopToysCardMixin = {};
function SmallCatalogShopToysCardMixin:OnLoad()
	SmallCatalogShopProductCardMixin.OnLoad(self);
end

local function ToysCardLayout(card)
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(card.productInfo.catalogShopProductID);

	-- Skip toy-specific display for unknown (cross-game) licenses
	if displayInfo.hasUnknownLicense then
		return;
	end

	local container = card.ForegroundContainer;
	container.RectIcon:ClearAllPoints();
	container.RectIcon:SetPoint("CENTER", 0, 40);
	container.RectIcon:SetSize(85, 85);

	container.RectIcon:Show();
	container.RectIcon:SetTexture(displayInfo.iconFileDataID);
	container.SquareIconBorder:Show();
end

function SmallCatalogShopToysCardMixin:Layout()
	SmallCatalogShopProductCardMixin.Layout(self);
	ToysCardLayout(self);
end


--------------------------------------------------
-- SMALL CATALOG SHOP ACCESS CARD MIXIN
SmallCatalogShopAccessCardMixin = {};
function SmallCatalogShopAccessCardMixin:OnLoad()
	SmallCatalogShopProductCardMixin.OnLoad(self);
end

local function AccessCardLayout(card)
	local container = card.ForegroundContainer;
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(card.productInfo.catalogShopProductID);

	-- Skip access-specific display for unknown (cross-game) licenses
	if displayInfo.hasUnknownLicense then
		container.RectIcon:Hide();
		return;
	end

	local atlasWidth = 140;
	local atlasHeight = 140;

	container.RectIcon:ClearAllPoints();
	container.RectIcon:SetPoint("CENTER", 0, 40);
	container.RectIcon:SetSize(atlasWidth, atlasHeight);

	if card.productInfo.previewIconTexture then
		container.RectIcon:Show();
		container.RectIcon:SetAtlas(card.productInfo.previewIconTexture);
	else
		container.RectIcon:Hide();
	end
end

function SmallCatalogShopAccessCardMixin:Layout()
	SmallCatalogShopProductCardMixin.Layout(self);
	AccessCardLayout(self);
end


--------------------------------------------------
-- DETAILS DEFAULT CATALOG SHOP PRODUCT CARD MIXIN
DetailsCatalogShopProductCardMixin = {};
function DetailsCatalogShopProductCardMixin:OnLoad()
	SmallCatalogShopProductCardMixin.OnLoad(self);
end

function DetailsCatalogShopProductCardMixin:Layout()
	SmallCatalogShopProductCardMixin.Layout(self);

	local container = self.ForegroundContainer;

	local divider = container.DividerTop;
	divider:SetShown(true);
	divider:ClearAllPoints();
	divider:SetPoint("TOP", container, "BOTTOM", 0, 83);
	divider:SetPoint("LEFT", 0, 0);
	divider:SetPoint("RIGHT", 0, 0);

	local nameElement = container.Name;
	nameElement:ClearAllPoints();
	nameElement:SetJustifyH("CENTER");
	nameElement:SetJustifyV("MIDDLE");
	nameElement:SetPoint("TOP", divider, "TOP", 0, -6);
	nameElement:SetPoint("LEFT", 15, 0);
	nameElement:SetPoint("RIGHT", -15, 0);
	nameElement:SetPoint("BOTTOM", 0, 25);

	container.Price:Hide();
	container.DiscountSaleTag:Hide();
	container.DiscountAmount:Hide();
	container.DiscountPrice:Hide();
	container.OriginalPrice:Hide();
	container.Strikethrough:Hide();

	local timeRemaining = container.TimeRemaining;
	timeRemaining:Hide();

	local background = self.BackgroundContainer.Background;
	background:ClearAllPoints();
	background:SetPoint("TOPLEFT", 12, -12);
	background:SetPoint("BOTTOMRIGHT", -13, 11);
end

--------------------------------------------------
-- DETAILS CATALOG SHOP SERVICES CARD MIXIN
DetailsCatalogShopServicesCardMixin = {};
function DetailsCatalogShopServicesCardMixin:OnLoad()
	DetailsCatalogShopProductCardMixin.OnLoad(self);
end

function DetailsCatalogShopServicesCardMixin:Layout()
	DetailsCatalogShopProductCardMixin.Layout(self);
	ServicesCardLayout(self);
end

--------------------------------------------------
-- DETAILS CATALOG SHOP SUBSCRIPTION CARD MIXIN
DetailsCatalogShopSubscriptionCardMixin = {};
function DetailsCatalogShopSubscriptionCardMixin:OnLoad()
	DetailsCatalogShopProductCardMixin.OnLoad(self);
end

function DetailsCatalogShopSubscriptionCardMixin:Layout()
	DetailsCatalogShopProductCardMixin.Layout(self);
	SubTimeAndGameTimeCardLayout(self);
end

--------------------------------------------------
-- DETAILS CATALOG SHOP GAME TIME CARD MIXIN
DetailsCatalogShopGameTimeCardMixin = {};
function DetailsCatalogShopGameTimeCardMixin:OnLoad()
	DetailsCatalogShopProductCardMixin.OnLoad(self);
end

function DetailsCatalogShopGameTimeCardMixin:Layout()
	DetailsCatalogShopProductCardMixin.Layout(self);
	SubTimeAndGameTimeCardLayout(self);
end

--------------------------------------------------
-- DETAILS CATALOG SHOP TENDER CARD MIXIN
DetailsCatalogShopTenderCardMixin = {};
function DetailsCatalogShopTenderCardMixin:OnLoad()
	DetailsCatalogShopProductCardMixin.OnLoad(self);
end

function DetailsCatalogShopTenderCardMixin:Layout()
	DetailsCatalogShopProductCardMixin.Layout(self);
	TenderCardLayout(self);
end

--------------------------------------------------
-- DETAILS CATALOG SHOP TOYS CARD MIXIN
DetailsCatalogShopToysCardMixin = {};
function DetailsCatalogShopToysCardMixin:OnLoad()
	DetailsCatalogShopProductCardMixin.OnLoad(self);
end

function DetailsCatalogShopToysCardMixin:Layout()
	DetailsCatalogShopProductCardMixin.Layout(self);
	ToysCardLayout(self);
end

--------------------------------------------------
-- DETAILS CATALOG SHOP ACCESS CARD MIXIN
DetailsCatalogShopAccessCardMixin = {};
function DetailsCatalogShopAccessCardMixin:OnLoad()
	DetailsCatalogShopProductCardMixin.OnLoad(self);
end

function DetailsCatalogShopAccessCardMixin:Layout()
	DetailsCatalogShopProductCardMixin.Layout(self);
	AccessCardLayout(self);
end


--------------------------------------------------
-- WIDE CATALOG SHOP SUBSCRIPTION CARD MIXIN
WideSubscriptionCatalogShopCardMixin = {};
function WideSubscriptionCatalogShopCardMixin:OnLoad()
	WideCatalogShopProductCardMixin.OnLoad(self);
end

function WideSubscriptionCatalogShopCardMixin:Layout()
	WideCatalogShopProductCardMixin.Layout(self);
	self:UpdateTimeRemaining();
	SubTimeAndGameTimeCardLayout(self);
end

--------------------------------------------------
-- WIDE CATALOG SHOP GAME TIME CARD MIXIN
WideGameTimeCatalogShopCardMixin = {};
function WideGameTimeCatalogShopCardMixin:OnLoad()
	WideCatalogShopProductCardMixin.OnLoad(self);
end

function WideGameTimeCatalogShopCardMixin:Layout()
	WideCatalogShopProductCardMixin.Layout(self);
	self:UpdateTimeRemaining();
	SubTimeAndGameTimeCardLayout(self);
end

--------------------------------------------------
-- WOW TOKEN CATALOG SHOP CARD MIXIN
WideWoWTokenCatalogShopCardMixin = {};
function WideWoWTokenCatalogShopCardMixin:OnLoad()
	WideCatalogShopProductCardMixin.OnLoad(self);
end

function WideWoWTokenCatalogShopCardMixin:OnShow()
	CatalogShopDefaultProductCardMixin.OnShow(self);

	local animContainer = self.AnimContainer;
	animContainer:SetShown(true);
end

function WideWoWTokenCatalogShopCardMixin:Layout()
	WideCatalogShopProductCardMixin.Layout(self);
	self:UpdateTimeRemaining();

	local wowTokenFrame = self.WoWTokenFrame;
	local price = C_WowTokenPublic.GetCurrentMarketPrice();
	if (price) then
		wowTokenFrame.CurrentMarketPrice:SetText(string.format(TOKEN_CURRENT_AUCTION_VALUE, GetSecureMoneyString(price, true)));
	else
		wowTokenFrame.CurrentMarketPrice:SetText(string.format(TOKEN_CURRENT_AUCTION_VALUE, TOKEN_MARKET_PRICE_NOT_AVAILABLE));
	end
	wowTokenFrame.CurrentMarketPrice:ClearAllPoints();
	wowTokenFrame.CurrentMarketPrice:SetPoint("TOPLEFT", 0, -20);
	wowTokenFrame.CurrentMarketPrice:SetPoint("TOPRIGHT", 0, -20);

	local container = self.ForegroundContainer;
	local divider = container.DividerTop;
	divider:SetShown(true);
	divider:ClearAllPoints();
	divider:SetPoint("TOP", container, "BOTTOM", 0, 86);
	divider:SetPoint("LEFT", 0, 0);
	divider:SetPoint("RIGHT", 0, 0);
end
