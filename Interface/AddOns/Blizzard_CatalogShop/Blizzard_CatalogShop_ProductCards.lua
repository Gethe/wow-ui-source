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
	--self:ShowTooltip();
end

function CatalogShopDefaultProductCardMixin:OnLeave()
	self.ForegroundContainer.HoverTexture:Hide();
	--self:HideTooltip();
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
	local container = self.BackgroundContainer;
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

function CatalogShopDefaultProductCardMixin:SetModelScene(productInfo, forceSceneChange, displayInfo, cardType)
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


	if cardType == CatalogShopConstants.ProductType.Bundle then
		local forceHidePlayer = false;
		CatalogShopUtil.SetupModelSceneForBundle(self.ModelScene, defaultCardModelSceneID, displayData, modelLoadedCB, forceHidePlayer);
	elseif cardType == CatalogShopConstants.ProductType.Mount then
		local forceHidePlayer = true;
		CatalogShopUtil.SetupModelSceneForMounts(self.ModelScene, defaultCardModelSceneID, displayData, modelLoadedCB, forceSceneChange, forceHidePlayer);
	elseif cardType == CatalogShopConstants.ProductType.Pet then
		CatalogShopUtil.SetupModelSceneForPets(self.ModelScene, defaultCardModelSceneID, displayData, modelLoadedCB, forceSceneChange);
		mainActor = self.ModelScene:GetActorByTag(CatalogShopConstants.DefaultActorTag.Pet);
	elseif cardType == CatalogShopConstants.ProductType.Transmog then
		CatalogShopUtil.SetupModelSceneForTransmogs(self.ModelScene, defaultCardModelSceneID, displayData, modelLoadedCB, forceSceneChange);
	elseif cardType == CatalogShopConstants.ProductType.Decor then
		CatalogShopUtil.SetupModelSceneForDecor(self.ModelScene, defaultCardModelSceneID, displayData, modelLoadedCB, forceSceneChange);
	else
		--error("Invalid Cateogry Type");
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
	local cardType = displayInfo.productType;
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
		container.RectIcon:SetSize(88.0,88.0);		-- Adjust the icon size to fight aliasing.
		CatalogShopUtil.SetAlternateProductIcon(container.RectIcon, displayInfo);
	else
		self.ModelScene:Show();
		self.ModelScene:ClearAllPoints();
		self.ModelScene:SetPoint("TOPLEFT", 13, -13);
		self.ModelScene:SetPoint("BOTTOMRIGHT", -13, 10);
		self.ModelScene:SetViewInsets(0, 0, 0, 0);
		self:SetModelScene(self.productInfo, true, displayInfo, cardType);
	end
	
	container.Name:SetText(self.productInfo.name);
	container.Price:SetText(self.productInfo.price);
	container.PurchasedIcon:SetShown(self.productInfo.isFullyOwned);
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
	divider:SetPoint("TOP", container, "BOTTOM", 0, 100);
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

	local priceElement = container.Price;
	priceElement:ClearAllPoints();
	priceElement:SetSize(0, 20);
	priceElement:SetJustifyH("CENTER");
	priceElement:SetPoint("BOTTOM", 0, 20);
	priceElement:SetPoint("LEFT", 15, 0);
	priceElement:SetPoint("RIGHT", -15, 0);

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
-- SMALL CATALOG SHOP SUBSCRIPTION AND GAME TIME CARD MIXIN
SmallCatalogShopSubscriptionCardMixin = {};
function SmallCatalogShopSubscriptionCardMixin:OnLoad()
	SmallCatalogShopProductCardMixin.OnLoad(self);
end

local function SubscriptionGameTimeCardLayout(card)
	local container = card.ForegroundContainer;
	container.RectIcon:ClearAllPoints();
	container.RectIcon:SetPoint("CENTER", 0, 40);

	local licenseTermType = card.productInfo.licenseTermType;
	local licenseTermDuration = card.productInfo.licenseTermDuration;
	local subTexture;
	if licenseTermType == CatalogShopConstants.LicenseTermTypes.Months then
		subTexture = "wow-sub-"..licenseTermDuration.."mo";
		container.RectIcon:SetSize(135, 120);
	elseif licenseTermType == CatalogShopConstants.LicenseTermTypes.Days then
		subTexture = "wow-sub-"..licenseTermDuration.."day";
		-- the days icons is a different aspect ratio
		container.RectIcon:SetSize(135, 150);
	end

	if subTexture then
		container.RectIcon:Show();
		container.RectIcon:SetAtlas(subTexture);
	else
		container.RectIcon:Hide();
	end
end

function SmallCatalogShopSubscriptionCardMixin:Layout()
	SmallCatalogShopProductCardMixin.Layout(self);
	SubscriptionGameTimeCardLayout(self);
end

--------------------------------------------------
-- SMALL CATALOG SHOP TENDER CARD MIXIN
SmallCatalogShopTenderCardMixin = {};
function SmallCatalogShopTenderCardMixin:OnLoad()
	SmallCatalogShopProductCardMixin.OnLoad(self);
end

function SmallCatalogShopTenderCardMixin:Layout()
	SmallCatalogShopProductCardMixin.Layout(self);
end


--------------------------------------------------
-- SMALL CATALOG SHOP TOYS CARD MIXIN
SmallCatalogShopToysCardMixin = {};
function SmallCatalogShopToysCardMixin:OnLoad()
	SmallCatalogShopProductCardMixin.OnLoad(self);
end

local function ToysCardLayout(card)
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(card.productInfo.catalogShopProductID);

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
	divider:SetPoint("TOP", container, "BOTTOM", 0, 100);
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

	local priceElement = container.Price;
	priceElement:Hide();

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
	SubscriptionGameTimeCardLayout(self);
end

--------------------------------------------------
-- DETAILS CATALOG SHOP TENDER CARD MIXIN
DetailsCatalogShopTenderCardMixin = {};
function DetailsCatalogShopTenderCardMixin:OnLoad()
	DetailsCatalogShopProductCardMixin.OnLoad(self);
end

function DetailsCatalogShopTenderCardMixin:Layout()
	DetailsCatalogShopProductCardMixin.Layout(self);
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
	divider:SetPoint("TOP", container, "BOTTOM", 0, 100);
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

	local priceElement = container.Price;
	priceElement:ClearAllPoints();
	priceElement:SetSize(0, 20);
	priceElement:SetJustifyH("CENTER");
	priceElement:SetPoint("BOTTOM", 0, 20);
	priceElement:SetPoint("LEFT", 15, 0);
	priceElement:SetPoint("RIGHT", -15, 0);

	local timeRemaining = container.TimeRemaining;
	timeRemaining:ClearAllPoints();
	timeRemaining:SetPoint("CENTER", container.TimeRemainingIcon, "CENTER", 0, 0);
	timeRemaining:SetPoint("LEFT", container.TimeRemainingIcon, "RIGHT", 3, 0);

	local background = self.BackgroundContainer.Background;
	background:ClearAllPoints();
	background:SetPoint("TOPLEFT", 12, -12);
	background:SetPoint("BOTTOMRIGHT", -13, 11);

	-- based on values in productInfo we need to set a correct background
	local backgroundTexture = self.productInfo and self.productInfo.optionalWideCardBackgroundTexture or self.defaultBackground;
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

	local container = self.ForegroundContainer;
	container.RectIcon:ClearAllPoints();
	container.RectIcon:SetPoint("CENTER", 0, 40);

	local subTexture;
	local licenseTermType = self.productInfo.licenseTermType;
	local licenseTermDuration = self.productInfo.licenseTermDuration;
	if licenseTermType == CatalogShopConstants.LicenseTermTypes.Months then
		subTexture = "wow-sub-"..licenseTermDuration.."mo";
		container.RectIcon:SetSize(162, 144);
	else
		subTexture = "wow-sub-"..licenseTermDuration.."day";
		-- the days icons is a different aspect ratio
		container.RectIcon:SetSize(162, 180);
	end

	if subTexture then
		container.RectIcon:Show();
		container.RectIcon:SetAtlas(subTexture);
	else
		container.RectIcon:Hide();
	end
end

--------------------------------------------------
-- WOW TOKEN CATALOG SHOP CARD MIXIN
WideWoWTokenCatalogShopCardMixin = {};
function WideWoWTokenCatalogShopCardMixin:OnLoad()
	WideCatalogShopProductCardMixin.OnLoad(self);
end

function WideWoWTokenCatalogShopCardMixin:Layout()
	WideCatalogShopProductCardMixin.Layout(self);
	self:UpdateTimeRemaining();

	local animContainer = self.AnimContainer;
	animContainer:SetShown(true);

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
	divider:SetPoint("TOP", container, "BOTTOM", 0, 80);
	divider:SetPoint("LEFT", 0, 0);
	divider:SetPoint("RIGHT", 0, 0);
end
