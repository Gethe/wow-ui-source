local timeRemainingFormatter = CreateFromMixins(SecondsFormatterMixin);
timeRemainingFormatter:Init(
	SecondsFormatterConstants.ZeroApproximationThreshold,
	SecondsFormatter.Abbreviation.OneLetter,
	SecondsFormatterConstants.DontRoundUpLastUnit,
	SecondsFormatterConstants.ConvertToLower,
	SecondsFormatterConstants.RoundUpIntervals);
timeRemainingFormatter:SetDesiredUnitCount(1);
timeRemainingFormatter:SetMinInterval(SecondsFormatter.Interval.Minutes);
timeRemainingFormatter:SetStripIntervalWhitespace(true);

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
-- CATALOG SHOP DEFAULT PRODUCT CARD MIXIN
CatalogShopDefaultProductCardMixin = {};
function CatalogShopDefaultProductCardMixin:OnLoad()
	-- set the tooltip here
	-- set any override fonts

	self.ModelScene:SetScript("OnMouseWheel", nil);

	EventRegistry:RegisterCallback("CatalogShop.OnProductInfoChanged", self.OnProductInfoChanged, self);

	local container = self.ForegroundContainer;
	local texture = self.hoverFrameTexture;
	container.HoverTexture:SetAtlas(texture);

	--self:Layout();
end

function CatalogShopDefaultProductCardMixin:Init()
end

function CatalogShopDefaultProductCardMixin:OnShow()
	self:UpdateState();
end

function CatalogShopDefaultProductCardMixin:OnEnter()
	self.ForegroundContainer.HoverTexture:Show();
end

function CatalogShopDefaultProductCardMixin:OnLeave()
	self.ForegroundContainer.HoverTexture:Hide();
end

function CatalogShopDefaultProductCardMixin:IsSameProduct(productInfo)
	return self.productInfo and self.productInfo.catalogShopProductID == productInfo.catalogShopProductID;
end

function CatalogShopDefaultProductCardMixin:OnProductInfoChanged(productInfo)
	if not self:IsSameProduct(productInfo) then
		return;
	end

	self:SetProductInfo(productInfo);
end

function CatalogShopDefaultProductCardMixin:OnClick()
	--... handle click
end

function CatalogShopDefaultProductCardMixin:OnMouseDown(...)
	self.ModelScene:OnMouseDown(...);
end

function CatalogShopDefaultProductCardMixin:OnMouseUp(...)
	self.ModelScene:OnMouseUp(...);
end

function CatalogShopDefaultProductCardMixin:UpdateState()
	if (not self:IsShown()) then
		return;
	end

	--... handle state
end

function CatalogShopDefaultProductCardMixin:SetProductInfo(productInfo)
	self.productInfo = productInfo;
	self:Layout();
end

function CatalogShopDefaultProductCardMixin:SetSelected(selected)
	local container = self.SelectedContainer;
	local texture = selected and self.selectedFrameTexture or self.defaultFrameTexture;
	container.FrameBackground:SetAtlas(texture);

	self.isSelected = selected;
	if selected then
		if self.ModelScene:IsShown() then
			CatalogShopFrame:SetCurrentCardModelSceneData(self.ModelScene, self.defaultCardModelSceneID, self.overrideCardModelSceneID);
		else
			CatalogShopFrame:SetCurrentCardModelSceneData(nil, nil, nil);
		end
	end
end

function CatalogShopDefaultProductCardMixin:IsSelected()
	return self.isSelected;
end

function CatalogShopDefaultProductCardMixin:SetModelScene(productInfo, forceSceneChange, displayInfo, productType)
	local isBundleChild = productInfo.isBundleChild or false;
	local scrollViewSize = 3;
	if not isBundleChild then
		local sectionInfo = C_CatalogShop.GetCategorySectionInfo(productInfo.categoryID, productInfo.sectionID);
		scrollViewSize = sectionInfo.scrollGridSize or 3;
	end
	--local scrollViewSize = CatalogShopFrame:GetScrollViewSize();
	local useWideCardSettings = scrollViewSize == 1;
	local defaultCardModelSceneID = useWideCardSettings and displayInfo.defaultWideCardModelSceneID or displayInfo.defaultCardModelSceneID;
	local displayData = useWideCardSettings and productInfo.wideCardDisplayData or productInfo.cardDisplayData;
	local mainActor;
	local modelLoadedCB = nil;

	self.defaultCardModelSceneID = defaultCardModelSceneID;
	self.overrideCardModelSceneID = useWideCardSettings and displayInfo.overrideWideCardModelSceneID or displayInfo.overrideCardModelSceneID;
	CatalogShopUtil.ClearSpecialActors(self.ModelScene);

	displayData.modelSceneContext = useWideCardSettings and CatalogShopConstants.ModelSceneContext.WideCard or CatalogShopConstants.ModelSceneContext.SmallCard;
	if productType == CatalogShopConstants.ProductType.Bundle then
		local forceHidePlayer = false;
		self.ModelScene:ClearScene(); -- because the Cards are pulled from a pool, bundles ALWAYS need to clear the model scene because they might not use it
		CatalogShopUtil.SetupModelSceneForBundle(self.ModelScene, defaultCardModelSceneID, displayData, modelLoadedCB, forceHidePlayer);
	elseif productType == CatalogShopConstants.ProductType.Mount then
		local forceHidePlayer = true;
		CatalogShopUtil.SetupModelSceneForMounts(self.ModelScene, defaultCardModelSceneID, displayData, modelLoadedCB, forceSceneChange, forceHidePlayer);
	elseif productType == CatalogShopConstants.ProductType.Pet then
		CatalogShopUtil.SetupModelSceneForPets(self.ModelScene, defaultCardModelSceneID, displayData, modelLoadedCB, forceSceneChange);
		mainActor = self.ModelScene:GetActorByTag(CatalogShopConstants.DefaultActorTag.Pet);
	elseif productType == CatalogShopConstants.ProductType.Transmog then		
		CatalogShopUtil.SetupModelSceneForTransmogs(self.ModelScene, defaultCardModelSceneID, displayData, modelLoadedCB, forceSceneChange);
	elseif productType == CatalogShopConstants.ProductType.Decor then
		CatalogShopUtil.SetupModelSceneForDecor(self.ModelScene, defaultCardModelSceneID, displayData, modelLoadedCB, forceSceneChange);
	else
		self.ModelScene:ClearScene();
	end

	if CatalogShopUtil.HasSpecialActors(displayData) then
		CatalogShopUtil.SetupSpecialActors(displayData, self.modelScene);
	end

	if mainActor then
		mainActor:StopAnimationKit();
		mainActor:SetSpellVisualKit(nil);
		mainActor:SetAnimation(0, 0, 1.0);
	end
end

function CatalogShopDefaultProductCardMixin:UpdateTimeRemaining()
	if not self.GetElementData then
		return;
	end

	local productInfo = self:GetElementData();
	local container = self.ForegroundContainer;

	local shouldShowTimeRemaining = productInfo.hasTimeRemaining and not productInfo.isFullyOwned;
	if shouldShowTimeRemaining then
		local timeRemainingSecs = C_CatalogShop.GetProductAvailabilityTimeRemainingSecs(productInfo.catalogShopProductID);

		-- Subtract the refresh interval so the displayed time remaining is never an overestimate. This avoids the issue where
		-- a boundary is crossed but the displayed time remaining is an overestimate for (at most) the refresh interval (exclusive).
		timeRemainingSecs = timeRemainingSecs - CatalogShopProductContainerFrameMixin.INTERVAL_UPDATE_SECONDS_TIME;

		container.TimeRemaining:SetText(timeRemainingFormatter:Format(timeRemainingSecs));
	end
	container.TimeRemainingIcon:SetShown(shouldShowTimeRemaining);
	container.TimeRemaining:SetShown(shouldShowTimeRemaining);
end

function CatalogShopDefaultProductCardMixin:HideCardVisuals()
	local container = self.ForegroundContainer;
	container.RectIcon:Hide();
	container.SquareIconBorder:Hide();
	container.CircleIcon:Hide();
	container.CircleIconBorder:Hide();
	container.ProductCounter:Hide();
	container.ProductCounterText:Hide();

	self.ModelScene:Hide();
end

function CatalogShopDefaultProductCardMixin:Layout()
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(self.productInfo.catalogShopProductID);
	local productType = displayInfo.productType;
	local container = self.ForegroundContainer;

	-- Skip telemetry if this product is a bundle child (we dont track those)
	if not self.productInfo.isBundleChild then
		C_CatalogShop.ProductDisplayedTelemetry(self.productInfo.categoryID, self.productInfo.sectionID, self.productInfo.catalogShopProductID);
	end

	-- based on values in productInfo we need to set a correct background
	self.BackgroundContainer.Background:SetAtlas(self.defaultBackground);

	self:HideCardVisuals();
	container.RectIcon:SetSize(85.0,85.0);		-- Resetting the size since certain element types want to change it

	-- An unknown license implies a product from another Game (Classic, etc.)
	if displayInfo.hasUnknownLicense then
		container.RectIcon:Show();
		container.RectIcon:SetSize(140, 140);
		CatalogShopUtil.SetAlternateProductIcon(container.RectIcon, displayInfo);
	else
		self.ModelScene:Show();
		self.ModelScene:ClearAllPoints();
		self.ModelScene:SetPoint("TOPLEFT", 13, -13);
		self.ModelScene:SetPoint("BOTTOMRIGHT", -13, 15);
		self.ModelScene:SetViewInsets(0, 0, 0, 0);
		self:SetModelScene(self.productInfo, true, displayInfo, productType);
	end

	local isFullyOwned = self.productInfo.isFullyOwned;
	local discountPercentage = self.productInfo.discountPercentage or 0;
	if discountPercentage > 0 and not isFullyOwned then
		local priceElement = container.OriginalPrice;
		priceElement:ClearAllPoints();
		priceElement:SetSize(0, 20);
		priceElement:SetPoint("BOTTOM", 0, 20);
		priceElement:SetPoint("RIGHT", self, "CENTER", -5, 0);
		priceElement:SetText(self.productInfo.originalPrice);

		local discountPriceElement = container.DiscountPrice;
		discountPriceElement:ClearAllPoints();
		discountPriceElement:SetSize(0, 20);
		discountPriceElement:SetPoint("BOTTOM", 0, 20);
		discountPriceElement:SetPoint("LEFT", self, "CENTER", 5, 0);
		discountPriceElement:SetText(self.productInfo.price);

		--DrawLine(self, parent, self.startX - x, self.startY - y, self.endX - x, self.endY - y, self.thickness or 32, 1);
		local strikeThrough = container.Strikethrough;
		strikeThrough:ClearAllPoints();
		strikeThrough:SetPoint("LEFT", priceElement, "LEFT", 0, 0);
		strikeThrough:SetPoint("RIGHT", priceElement, "RIGHT", 0, 0);
		strikeThrough:Show();

		container.DiscountAmount:SetText(string.format(CATALOG_SHOP_DISCOUNT_FORMAT, discountPercentage));
		container.DiscountAmount:Show();

		container.DiscountSaleTag:Show();
		container.DiscountPrice:Show();
		container.OriginalPrice:Show();
		container.Strikethrough:Show();
		container.Price:Hide();
	else
		local priceElement = container.Price;
		priceElement:ClearAllPoints();
		priceElement:SetSize(0, 20);
		priceElement:SetJustifyH("CENTER");
		priceElement:SetPoint("BOTTOM", 0, 20);
		priceElement:SetPoint("LEFT", 15, 0);
		priceElement:SetPoint("RIGHT", -15, 0);
		priceElement:SetText(self.productInfo.price);
		priceElement:Show();

		container.DiscountSaleTag:Hide();
		container.DiscountAmount:Hide();
		container.DiscountPrice:Hide();
		container.OriginalPrice:Hide();
		container.Strikethrough:Hide();				
	end

	container.Name:SetText(self.productInfo.name);	
	container.PurchasedIcon:SetShown(isFullyOwned);
end


--------------------------------------------------
-- SMALL CATALOG SHOP PRODUCT CARD MIXIN
SmallCatalogShopProductCardMixin = {};
function SmallCatalogShopProductCardMixin:OnLoad()
	CatalogShopDefaultProductCardMixin.OnLoad(self);
end

function SmallCatalogShopProductCardMixin:Layout()
	CatalogShopDefaultProductCardMixin.Layout(self);

	local container = self.ForegroundContainer;

	local divider = container.DividerTop;
	divider:SetShown(true);
	divider:ClearAllPoints();
	divider:SetPoint("TOP", container, "BOTTOM", 0, 82);
	divider:SetPoint("LEFT", 0, 0);
	divider:SetPoint("RIGHT", 0, 0);

	local nameElement = container.Name;
	nameElement:ClearAllPoints();
	nameElement:SetJustifyH("CENTER");
	nameElement:SetJustifyV("MIDDLE");
	nameElement:SetPoint("TOP", divider, "TOP", 0, -4);
	nameElement:SetPoint("LEFT", 15, 0);
	nameElement:SetPoint("RIGHT", -15, 0);
	nameElement:SetPoint("BOTTOM", 0, 40);

	local timeRemaining = container.TimeRemaining;
	timeRemaining:ClearAllPoints();
	timeRemaining:SetPoint("CENTER", container.TimeRemainingIcon, "CENTER", 0, 0);
	timeRemaining:SetPoint("LEFT", container.TimeRemainingIcon, "RIGHT", 3, 0);

	local background = self.BackgroundContainer.Background;
	background:ClearAllPoints();
	background:SetPoint("TOPLEFT", 12, -12);
	background:SetPoint("BOTTOMRIGHT", -13, 11);

	self:UpdateTimeRemaining();
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
-- WIDE CATALOG SHOP PRODUCT CARD MIXIN
WideCatalogShopProductCardMixin = {};
function WideCatalogShopProductCardMixin:OnLoad()
	CatalogShopDefaultProductCardMixin.OnLoad(self);
end

function WideCatalogShopProductCardMixin:Layout()
	CatalogShopDefaultProductCardMixin.Layout(self);

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
	nameElement:SetPoint("BOTTOM", 0, 50);

	local timeRemaining = container.TimeRemaining;
	timeRemaining:ClearAllPoints();
	timeRemaining:SetPoint("CENTER", container.TimeRemainingIcon, "CENTER", 0, 0);
	timeRemaining:SetPoint("LEFT", container.TimeRemainingIcon, "RIGHT", 3, 0);

	local background = self.BackgroundContainer.Background;
	background:ClearAllPoints();
	background:SetPoint("TOPLEFT", 12, -12);
	background:SetPoint("BOTTOMRIGHT", -13, 11);

	-- based on values in productInfo we need to set a correct background
	local backgroundTexture = self.productInfo and self.productInfo.wideCardBGTexture or self.defaultBackground;
	if backgroundTexture then
		self.BackgroundContainer.Background:SetAtlas(backgroundTexture);
	end

	self:UpdateTimeRemaining();
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
