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

----------------------------------------------------------------------------------
-- InvisibleMouseOverFrameMixin
----------------------------------------------------------------------------------
InvisibleMouseOverFrameMixin = {};
function InvisibleMouseOverFrameMixin:OnEnter()
end

function InvisibleMouseOverFrameMixin:OnLeave()
end

--------------------------------------------------
-- CATALOG SHOP DEFAULT PRODUCT CARD MIXIN
CatalogShopDefaultProductCardMixin = {};
function CatalogShopDefaultProductCardMixin:OnLoad()
	-- set the tooltip here
	-- set any override fonts

	self.ModelScene:SetScript("OnMouseWheel", nil);

	local container = self.ForegroundContainer;
	local texture = self.hoverFrameTexture;
	container.HoverTexture:SetAtlas(texture);

	if self.nonInteractive then
		self:SetAsNonInteractive();
	end
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

	local function NonSecureWrapper(productId)
		SavedSetsUtil.Check(SavedSetsUtil.RegisteredSavedSets.SeenShopCatalogProductIDs, productId)
	end

	local function NonSecureSet(productId)
		SavedSetsUtil.Set(SavedSetsUtil.RegisteredSavedSets.SeenShopCatalogProductIDs, productId);
	end

	local checkfunction = SavedSetsUtil and NonSecureWrapper or CatalogShopOutbound.SavedSet_Check
	local setFunction = SavedSetsUtil and NonSecureSet or CatalogShopOutbound.SavedSet_Set

	if not checkfunction(self.productInfo.catalogShopProductID) then
		setFunction(self.productInfo.catalogShopProductID);
		self:HideNotification();
	end
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

-- We use product card templates outside of the catalog shop in display-only contexts.
function CatalogShopDefaultProductCardMixin:SetAsNonInteractive()
	self:EnableMouseMotion(false);
	self:SetMouseClickEnabled(false);

	self.ModelScene:EnableMouseMotion(false);
	self.ModelScene:SetMouseClickEnabled(false);
end

function CatalogShopDefaultProductCardMixin:UpdateState()
	if (not self:IsShown()) then
		return;
	end

	--... handle state
end

function CatalogShopDefaultProductCardMixin:ShowNotification()
	if CatalogShopOutbound and not CatalogShopOutbound.SavedSet_Check(self.productInfo.catalogShopProductID) and not self.notificationFrame then
		self.notificationFrame = CatalogShopOutbound.NotificationUtil_AcquireLargeNotification("TOPRIGHT", self.SelectedContainer, "TOPRIGHT", 0, 0);
	elseif not CatalogShopOutbound and not SavedSetsUtil.Check(SavedSetsUtil.RegisteredSavedSets.SeenShopCatalogProductIDs, self.productInfo.catalogShopProductID) and not self.notificationFrame then
		self.notificationFrame = NotificationUtil.AcquireLargeNotification("TOPRIGHT", self.SelectedContainer, "TOPRIGHT", 0, 0);
	end
end

function CatalogShopDefaultProductCardMixin:HideNotification()
	if self.notificationFrame then
		if CatalogShopOutbound then
			CatalogShopOutbound.NotificationUtil_ReleaseNotification(self.notificationFrame);
		else
			NotificationUtil.ReleaseNotification(self.notificationFrame);
		end
		self.notificationFrame = nil;
	end
end

function CatalogShopDefaultProductCardMixin:SetProductInfo(productInfo)
	self.productInfo = productInfo;
	self:Layout();
end

function CatalogShopDefaultProductCardMixin:GetProductInfo()
	return self.productInfo;
end

function CatalogShopDefaultProductCardMixin:SetSelected(selected)
	local container = self.SelectedContainer;
	local texture = selected and self.selectedFrameTexture or self.defaultFrameTexture;
	container.FrameBackground:SetAtlas(texture);

	self.isSelected = selected;

	-- This is only for integration with the model scene tool which will only happen inside the catalog shop for now.
	if selected and CatalogShopFrame then
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
	local useWideCardSettings = self.useWideCardSettings;
	local defaultCardModelSceneID = useWideCardSettings and displayInfo.defaultWideCardModelSceneID or displayInfo.defaultCardModelSceneID;
	local displayData = useWideCardSettings and productInfo.wideCardDisplayData or productInfo.cardDisplayData;
	local mainActor;
	local modelLoadedCB = nil;

	self.defaultCardModelSceneID = defaultCardModelSceneID;
	self.overrideCardModelSceneID = useWideCardSettings and displayInfo.overrideWideCardModelSceneID or displayInfo.overrideCardModelSceneID;
	CatalogShopUtil.ClearSpecialActors(self.ModelScene);

	self.ModelScene:ClearScene(); -- because the Cards are pulled from a pool, clear the model scene because products may not use it

	displayData.modelSceneContext = useWideCardSettings and CatalogShopConstants.ModelSceneContext.WideCard or CatalogShopConstants.ModelSceneContext.SmallCard;
	if productType == CatalogShopConstants.ProductType.Bundle then
		local forceHidePlayer = false;
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

	local timeRemainingSecs = C_CatalogShop.GetProductAvailabilityTimeRemainingSecs(productInfo.catalogShopProductID);
	local shouldShowTimeRemaining = timeRemainingSecs and (not productInfo.isFullyOwned);
	if shouldShowTimeRemaining then
		-- Subtract the refresh interval so the displayed time remaining is never an overestimate. This avoids the issue where
		-- a boundary is crossed but the displayed time remaining is an overestimate for (at most) the refresh interval (exclusive).
		timeRemainingSecs = timeRemainingSecs - CatalogShopUtil.INTERVAL_UPDATE_SECONDS_TIME;

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
	self:HideNotification();
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(self.productInfo.catalogShopProductID);
	local productType = displayInfo.productType;
	local container = self.ForegroundContainer;

	-- Skip telemetry if this product is a bundle child (we dont track those)
	if not self.productInfo.isBundleChild and self.productInfo.categoryID then
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
	container.Name:SetText(self.productInfo.name);

	local isFullyOwned = self.productInfo.isFullyOwned;
	container.PurchasedIcon:SetShown(isFullyOwned);

	local discountPercentage = self.productInfo.discountPercentage or 0;
	local shouldShowDiscountPercentage = (not isFullyOwned) and discountPercentage > 0;
	container.DiscountSaleTag:SetShown(shouldShowDiscountPercentage);
	container.DiscountAmount:SetShown(shouldShowDiscountPercentage);
	container.DiscountAmount:SetText(string.format(CATALOG_SHOP_DISCOUNT_FORMAT, discountPercentage));

	local consumableQuantity = self.productInfo.consumableQuantity;
	local shouldShowConsumableQuantity = (not shouldShowDiscountPercentage) and consumableQuantity;
	container.ConsumableQuantityBackground:SetShown(shouldShowConsumableQuantity);
	container.ConsumableQuantityText:SetShown(shouldShowConsumableQuantity);
	container.ConsumableQuantityText:SetText(consumableQuantity);
	self:ShowNotification();
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
	nameElement:SetPoint("TOP", divider, "TOP", 0, -3);
	nameElement:SetPoint("LEFT", 15, 0);
	nameElement:SetPoint("RIGHT", -15, 0);
	nameElement:SetPoint("BOTTOM", 0, 42);

	local timeRemaining = container.TimeRemaining;
	timeRemaining:ClearAllPoints();
	timeRemaining:SetPoint("CENTER", container.TimeRemainingIcon, "CENTER", 0, 0);
	timeRemaining:SetPoint("LEFT", container.TimeRemainingIcon, "RIGHT", 3, 0);

	if self.productInfo.shouldShowOriginalPrice then
		local priceElement = container.OriginalPrice;
		priceElement:ClearAllPoints();
		priceElement:SetPoint("TOP", container, "BOTTOM", 0, 27);
		priceElement:SetPoint("LEFT", 15, 0);
		priceElement:SetPoint("RIGHT", -15, 0);
		priceElement:SetPoint("BOTTOM", 0, 13);
		priceElement:SetText(self.productInfo.originalPrice);

		local strikeThrough = container.Strikethrough;
		local strikeThroughLength = priceElement:GetStringWidth() * 0.5;
		strikeThrough:ClearAllPoints();
		strikeThrough:SetPoint("LEFT", priceElement, "CENTER", -strikeThroughLength, 0);
		strikeThrough:SetPoint("RIGHT", priceElement, "CENTER", strikeThroughLength, 0);
		strikeThrough:Show();

		local discountPriceElement = container.DiscountPrice;
		discountPriceElement:ClearAllPoints();
		discountPriceElement:SetPoint("BOTTOM", priceElement, "TOP", 0, 1);
		discountPriceElement:SetPoint("TOP", priceElement, "TOP", 0, 15);
		discountPriceElement:SetPoint("LEFT", 15, 0);
		discountPriceElement:SetPoint("RIGHT", -15, 0);
		discountPriceElement:SetText(self.productInfo.price);

		container.DiscountPrice:Show();
		container.OriginalPrice:Show();
		container.Strikethrough:Show();
		container.Price:Hide();
	else
		local priceElement = container.Price;
		priceElement:ClearAllPoints();
		priceElement:SetSize(0, 20);
		priceElement:SetJustifyH("CENTER");
		priceElement:SetPoint("BOTTOM", 0, 17);
		priceElement:SetPoint("LEFT", 15, 0);
		priceElement:SetPoint("RIGHT", -15, 0);
		priceElement:SetText(self.productInfo.price);
		priceElement:Show();

		container.DiscountPrice:Hide();
		container.OriginalPrice:Hide();
		container.Strikethrough:Hide();
	end

	local background = self.BackgroundContainer.Background;
	background:ClearAllPoints();
	background:SetPoint("TOPLEFT", 12, -12);
	background:SetPoint("BOTTOMRIGHT", -13, 11);

	self:UpdateTimeRemaining();
end


--------------------------------------------------
-- SMALL CATALOG SHOP HOUSING CURRENCY CARD MIXIN
SmallCatalogShopHousingCurrencyCardMixin = {};
function SmallCatalogShopHousingCurrencyCardMixin:OnLoad()
	SmallCatalogShopProductCardMixin.OnLoad(self);
end

local CurrencyBreakpoints = {
	[100] = "hearthsteel-icon-xs",
	[500] = "hearthsteel-icon-sm",
	[1000] = "hearthsteel-icon-md",
	[2500] = "hearthsteel-icon-lg",
	[5000] = "hearthsteel-icon-xl",
	[10000] = "hearthsteel-icon-xxl",
};

local function BuyButtonCardLayout(card)
	local container = card.ForegroundContainer;
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(card.productInfo.catalogShopProductID);

	local virtualCurrencyInfo = card.productInfo.virtualCurrencies[1];
	if virtualCurrencyInfo then
		local amount = virtualCurrencyInfo.amount;
		container.Name:SetText(string.format(HOUSING_VC_QUANTITY, amount));
		local textureAtlas = CurrencyBreakpoints[amount] or "hearthsteel-icon-single";
		container.RectIcon:SetAtlas(textureAtlas);
	end

	local divider = container.DividerTop;
	divider:SetShown(true);
	divider:ClearAllPoints();
	divider:SetPoint("TOP", container, "BOTTOM", 0, 145);
	divider:SetPoint("LEFT", 0, 0);
	divider:SetPoint("RIGHT", 0, 0);

	local nameElement = container.Name;
	nameElement:ClearAllPoints();
	nameElement:SetJustifyH("CENTER");
	nameElement:SetJustifyV("MIDDLE");
	nameElement:SetPoint("TOP", divider, "TOP", 0, -3);
	nameElement:SetPoint("LEFT", 20, 0);
	nameElement:SetPoint("RIGHT", -22, 0);
	nameElement:SetPoint("BOTTOM", 0, 94);

	local priceElement = container.Price;
	priceElement:Hide();

	local atlasWidth = 240;
	local atlasHeight = 240;

	local purchaseButton = card.PurchaseButton;
	purchaseButton:SetText(card.productInfo.price);
	purchaseButton:ClearAllPoints();
	purchaseButton:SetPoint("BOTTOM", 0, 30);

	container.RectIcon:ClearAllPoints();
	container.RectIcon:SetPoint("CENTER", 0, 30);
	container.RectIcon:SetSize(atlasWidth, atlasHeight);
	container.RectIcon:Show();

	local background = card.BackgroundContainer.Background;
	background:ClearAllPoints();
	background:SetPoint("TOPLEFT", 20, -20);
	background:SetPoint("BOTTOMRIGHT", -21, 21);
end

function SmallCatalogShopHousingCurrencyCardMixin:Layout()
	SmallCatalogShopProductCardMixin.Layout(self);
	BuyButtonCardLayout(self);
end


EmbeddedPurchaseButtonMixin = {};
function EmbeddedPurchaseButtonMixin:OnLoad()
--embeddedPurchaseButtonOnClickMethod
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

	if self.productInfo.shouldShowOriginalPrice then
		local priceElement = container.OriginalPrice;
		priceElement:ClearAllPoints();
		priceElement:SetSize(175, 20);
		priceElement:SetPoint("BOTTOM", 0, 30);
		priceElement:SetPoint("RIGHT", self, "CENTER", -5, 0);
		priceElement:SetJustifyH("RIGHT");
		priceElement:SetText(self.productInfo.originalPrice);

		local strikeThrough = container.Strikethrough;
		local strikeThroughLength = priceElement:GetStringWidth();
		strikeThrough:ClearAllPoints();
		strikeThrough:SetPoint("LEFT", priceElement, "RIGHT", -strikeThroughLength, 0);
		strikeThrough:SetPoint("RIGHT", priceElement, "RIGHT", 0, 0);
		strikeThrough:Show();

		local discountPriceElement = container.DiscountPrice;
		discountPriceElement:ClearAllPoints();
		discountPriceElement:SetSize(175, 20);
		discountPriceElement:SetPoint("BOTTOM", 0, 30);
		discountPriceElement:SetPoint("LEFT", self, "CENTER", 5, 0);
		discountPriceElement:SetJustifyH("LEFT");
		discountPriceElement:SetText(self.productInfo.price);

		container.DiscountPrice:Show();
		container.OriginalPrice:Show();
		container.Strikethrough:Show();
		container.Price:Hide();
	else
		local priceElement = container.Price;
		priceElement:ClearAllPoints();
		priceElement:SetSize(0, 20);
		priceElement:SetJustifyH("CENTER");
		priceElement:SetPoint("TOP", nameElement, "BOTTOM", 0, 0);
		priceElement:SetPoint("BOTTOM", 0, 30);
		priceElement:SetPoint("LEFT", 15, 0);
		priceElement:SetPoint("RIGHT", -15, 0);
		priceElement:SetText(self.productInfo.price);
		priceElement:Show();

		container.DiscountPrice:Hide();
		container.OriginalPrice:Hide();
		container.Strikethrough:Hide();
	end

	local background = self.BackgroundContainer.Background;
	background:ClearAllPoints();
	background:SetPoint("TOPLEFT", 12, -12);
	background:SetPoint("BOTTOMRIGHT", -13, 11);

	-- Any product can use the PMT background feature if wideCardBGOverrideProductURL is set
	if self.productInfo and self.productInfo.wideCardBGOverrideProductURL then
		C_Texture.SetURLTexture(self.BackgroundContainer.Background, self.productInfo.wideCardBGOverrideProductURL);
	else
		-- based on values in productInfo we need to set a correct background
		local backgroundTexture = self.productInfo and self.productInfo.wideCardBGTexture or self.defaultBackground;
		if backgroundTexture then
			self.BackgroundContainer.Background:SetAtlas(backgroundTexture);
		end
	end

	self:UpdateTimeRemaining();
end
