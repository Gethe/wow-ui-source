-----------------------------------------------------------------------------------
--- NavigationBarButtonMixin
-----------------------------------------------------------------------------------
NavigationBarButtonMixin = {};
function NavigationBarButtonMixin:Init(sectionInfo, isSelected)
	self:UpdateVisuals();
	self.Label:SetText(sectionInfo.label);
	self.sectionInfo = sectionInfo;
	self:SetSelected(isSelected);
end

function NavigationBarButtonMixin:UpdateVisuals()
	local highlightTexture = "shop-header-menu-selected-middle";
	local pushedTexture = "shop-header-menu-selected-middle";
	local selectedTexture = "shop-header-menu-selected-middle";
	local selectedBottomTexture = "shop-header-menu-selected-line-middle";
	local flipDivider = false;
	local xOffset, yOffset = 1, 0;
	local elementData = self:GetElementData();

	if elementData.isFirstButton then
		highlightTexture = "shop-header-menu-selected-left";
		pushedTexture = "shop-header-menu-selected-left";
		selectedTexture = "shop-header-menu-selected-left";
		selectedBottomTexture = "shop-header-menu-selected-line-left";
		xOffset = 1;
	elseif elementData.isLastButton then
		highlightTexture = "shop-header-menu-selected-right";
		pushedTexture = "shop-header-menu-selected-right";
		selectedTexture = "shop-header-menu-selected-right";
		selectedBottomTexture = "shop-header-menu-selected-line-right";
		flipDivider = true;
		xOffset = -1;
	end

	self.HighlightTexture:SetAtlas(highlightTexture);
	self.PushedTexture:SetAtlas(pushedTexture);
	self.Selected:SetAtlas(selectedTexture);
	self.SelectedBottom:SetAtlas(selectedBottomTexture);
	local anchor = flipDivider and "LEFT" or "RIGHT";
	self.NormalTexture:ClearAllPoints();
	self.NormalTexture:SetPoint(anchor, xOffset, yOffset);
end

function NavigationBarButtonMixin:SetSelected(newSelected)
	if (newSelected) then
		PlaySound(SOUNDKIT.CATALOG_SHOP_SELECT_NAV_MENU);
	end
	self.Selected:SetShown(newSelected);
	self.SelectedBottom:SetShown(newSelected);
end

function NavigationBarButtonMixin:OnEnter()
	--tooltips
end

function NavigationBarButtonMixin:OnLeave()
	--tooltips
end

-----------------------------------------------------------------------------------
--- NavigationBarNavigationButtonMixin
-----------------------------------------------------------------------------------
NavigationBarNavigationButtonMixin = {};
function NavigationBarNavigationButtonMixin:OnLoad()
	if self.atlas then
		self.Arrow:SetAtlas(self.atlas, true);
		local uvLeft, uvRight, uvBottom, uvTop = 0, 1, 1, 0;
		if self.direction then
			uvLeft = self.direction == "backwards" and 0 or 1;
			uvRight = self.direction == "backwards" and 1 or 0;
		end
		self.Arrow:SetTexCoord(uvLeft, uvRight, uvBottom, uvTop);
	end
end

function NavigationBarNavigationButtonMixin:OnClick()
	PlaySound(SOUNDKIT.CATALOG_SHOP_SELECT_NAV_MENU);
	if self.OnClickNavigate then
		self:GetParent()[self.OnClickNavigate](self:GetParent());
	end
end

function NavigationBarNavigationButtonMixin:OnEnter()
	--tooltips
end

function NavigationBarNavigationButtonMixin:OnLeave()
	--tooltips
end


-----------------------------------------------------------------------------------
--- NavigationBarMixin
-----------------------------------------------------------------------------------
local function IsElementDataSectionInfo(elementData)
	return true;
end

NavigationBarMixin = {
	NavBarButtonWidthBuffer = 70,
};
function NavigationBarMixin:SetupNavigationScrollView()
	local DefaultPad = 0;
	local DefaultSpacing = 0;

	local function InitializeButton(button, sectionInfo)
		local isSelected = self.selectionBehavior:IsElementDataSelected(sectionInfo);
		button:Init(sectionInfo, isSelected);
		button:SetScript("OnClick", function(button, buttonName)
			self.selectionBehavior:ToggleSelect(button);
		end);
	end

	local view = CreateScrollBoxListLinearView(DefaultPad, DefaultPad, DefaultPad, DefaultPad, -0.05);
	view:SetVirtualized(false);
	view:SetHorizontal(true);	
	view:SetElementInitializer("NavigationBarButtonTemplate", InitializeButton);
	view:SetElementExtentCalculator(function(dataIndex, sectionInfo)
		return (#sectionInfo.label * 10) + 50;
	end);
	self.NavButtonScrollBox:Init(view);

	local function OnSelectionChanged(o, elementData, selected)
		if selected then
			self:OnCategorySelected(elementData);
		end

		local button = self.NavButtonScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end
	end;

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.NavButtonScrollBox);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);
end

function NavigationBarMixin:SelectNextNavButton()
	local selectedElementData, index = self.selectionBehavior:SelectNextElementData(IsElementDataSectionInfo);
	if selectedElementData then
		self.NavButtonScrollBox:ScrollToNearest(index);
	end
end

function NavigationBarMixin:SelectPreviousNavButton()
	local selectedElementData, index = self.selectionBehavior:SelectPreviousElementData(IsElementDataSectionInfo);
	if selectedElementData then
		self.NavButtonScrollBox:ScrollToNearest(index);
	end
end

local function SectionSortComparator(lhs, rhs)
	-- Category ID is orderInPage (see CGCatalogShop_C::GetCategoryInfo)
	return lhs.ID < rhs.ID;
end

function NavigationBarMixin:SetupNavigationData(buttonInfos)
	local dataProvider = CreateDataProvider();

	for i, buttonInfo in ipairs(buttonInfos) do
		dataProvider:Insert(buttonInfo);
	end

	dataProvider:SetSortComparator(SectionSortComparator);
	self.NavButtonScrollBox:SetDataProvider(dataProvider);

	local leftmostElement = dataProvider:Find(1);
	if leftmostElement then
		leftmostElement.isFirstButton = true;
		local leftmostButton = self.NavButtonScrollBox:FindFrame(leftmostElement);
		if leftmostButton then
			leftmostButton:UpdateVisuals();
		end
	end

	local numButtons = dataProvider:GetSize();
	local rightmostElement = dataProvider:Find(numButtons);
	if rightmostElement then
		rightmostElement.isLastButton = true;
		local rightmostButton = self.NavButtonScrollBox:FindFrame(rightmostElement);
		if rightmostButton then
			rightmostButton:UpdateVisuals();
		end
	end
end

function NavigationBarMixin:OnUpdate()
	local backEnabled = not self.selectionBehavior:IsFirstElementDataSelected();
	local forwardEnabled = not self.selectionBehavior:IsLastElementDataSelected();
	self.ScrollBackwards:SetEnabled(backEnabled);
	self.ScrollForwards:SetEnabled(forwardEnabled);
end

function NavigationBarMixin:SetupScrolling()
	local hasScrollableExtent = self.NavButtonScrollBox:HasScrollableExtent();
	if hasScrollableExtent then
		self:SetScript("OnUpdate", GenerateClosure(self.OnUpdate, self));

		self.ScrollBackwards:ClearAllPoints();
		self.ScrollBackwards:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -2);
		self.ScrollBackwards:SetShown(true);

		self.ScrollForwards:ClearAllPoints();
		self.ScrollForwards:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -2);
		self.ScrollForwards:SetShown(true);

		self.NavButtonScrollBox:ClearAllPoints();
		self.NavButtonScrollBox:SetPoint("TOPLEFT", self.ScrollBackwards, "TOPRIGHT", 0, 0);
		self.NavButtonScrollBox:SetPoint("BOTTOMRIGHT", self.ScrollForwards, "BOTTOMLEFT", 0, 0);

	else
		self:SetScript("OnUpdate", nil);
		self.ScrollBackwards:SetShown(false);
		self.ScrollForwards:SetShown(false);

		self.NavButtonScrollBox:ClearAllPoints();
		self.NavButtonScrollBox:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
		self.NavButtonScrollBox:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
	end
end

function NavigationBarMixin:SelectCategoryByLinkTag(linkTag)
	if not linkTag then
		self.selectionBehavior:SelectFirstElementData(IsElementDataSectionInfo);
		return;
	end

	local dataProvider = self.NavButtonScrollBox:GetDataProvider();
	if not dataProvider then
		self.selectionBehavior:SelectFirstElementData(IsElementDataSectionInfo);
		return;
	end

	local elementData = dataProvider:FindElementDataByPredicate(function(elementData)
		return elementData.linkTag and elementData.linkTag == linkTag;
	end);

	if not elementData then
		--assertsafe(false, "ASSERT - Category Link Tag was specified but not found: "..linkTag);
		self.selectionBehavior:SelectFirstElementData(IsElementDataSectionInfo);
		return;
	end
	self.selectionBehavior:SelectElementData(elementData);
end

function NavigationBarMixin:Init(buttonInfos)
	self:SetupNavigationScrollView();
	self:SetupNavigationData(buttonInfos);
	local linkTag = CatalogShopFrame:GetCatalogShopLinkTag(); -- ok for this to be nil
	self:SelectCategoryByLinkTag(linkTag)
	self:SetupScrolling();
end

function NavigationBarMixin:OnCategorySelected(sectionInfo)
	local categoryID = sectionInfo.ID;
	EventRegistry:TriggerEvent("CatalogShop.OnCategorySelected", categoryID);
end


----------------------------------------------------------------------------------
-- CatalogShopButtonMixin
----------------------------------------------------------------------------------
CatalogShopButtonMixin = {};
function CatalogShopButtonMixin:OnClick()
	PlaySound(SOUNDKIT.CATALOG_SHOP_SELECT_GENERIC_UI_BUTTON);
	if self.catalogShopOnClickMethod then
		CatalogShopFrame[self.catalogShopOnClickMethod](CatalogShopFrame);
	end
end

function CatalogShopButtonMixin:OnEnter()
	-- Inheriting mixins should add a ShowTooltip method for showing their appropriate tooltip
end

function CatalogShopButtonMixin:OnLeave()
end


----------------------------------------------------------------------------------
-- CatalogShopPurchaseButtonMixin
----------------------------------------------------------------------------------
CatalogShopPurchaseButtonMixin = {};
function CatalogShopPurchaseButtonMixin:OnLoad()
end

function CatalogShopPurchaseButtonMixin:UpdateState()
	local selectedProductInfo  = CatalogShopFrame:GetSelectedProductInfo();
	-- update state based on product info
end


----------------------------------------------------------------------------------
-- CatalogShopDetailsButtonMixin
----------------------------------------------------------------------------------
CatalogShopDetailsButtonMixin = {};
function CatalogShopDetailsButtonMixin:OnLoad()
end

function CatalogShopDetailsButtonMixin:UpdateState()
	local selectedProductInfo  = CatalogShopFrame:GetSelectedProductInfo();
	-- update state based on product info
end

----------------------------------------------------------------------------------
-- CatalogShopErrorFrameMixin
----------------------------------------------------------------------------------
CatalogShopErrorFrameMixin = {};
function CatalogShopErrorFrameMixin:OnShow()
	-- TODO update whatever states are required
	self.ActiveURLIndex = nil;
end

function CatalogShopErrorFrameMixin:OnHide()
	-- TODO update whatever states are required
end

function CatalogShopErrorFrameMixin:ErrorNeedsAck()
	return self.ErrorNeedsAck;
end

function CatalogShopErrorFrameMixin:ShowError(title, desc, urlIndex, needsAck)
	local height = 180;
	self.Title:SetText(title);
	self.Title:Show();
	self.Description:SetText(desc);
	self.AcceptButton:SetText(OKAY);
	height = height + self.Description:GetHeight() + self.Title:GetHeight();

	if ( urlIndex ) then
		self.AcceptButton:ClearAllPoints();
		self.AcceptButton:SetPoint("BOTTOMRIGHT", self, "BOTTOM", -10, 20);
		self.WebsiteButton:ClearAllPoints();
		self.WebsiteButton:SetPoint("BOTTOMLEFT", self, "BOTTOM", 10, 20);
		self.WebsiteButton:Show();
		self.WebsiteButton:SetText(BLIZZARD_STORE_VISIT_WEBSITE);
		self.WebsiteWarning:Show();
		self.WebsiteWarning:SetText(BLIZZARD_STORE_VISIT_WEBSITE_WARNING);
		height = height + self.WebsiteWarning:GetHeight() + 8;
		self.ActiveURLIndex = urlIndex;
	else
		self.AcceptButton:ClearAllPoints();
		self.AcceptButton:SetPoint("BOTTOM", self, "BOTTOM", 0, 20);
		self.WebsiteButton:Hide();
		self.WebsiteWarning:Hide();
		self.ActiveURLIndex = nil;
	end
	self.ErrorNeedsAck = needsAck;

	self:Show();
	self:SetHeight(height);
end


----------------------------------------------------------------------------------
-- WoWTokenContainerFrameMixin
----------------------------------------------------------------------------------
WoWTokenContainerFrameMixin = {};
function WoWTokenContainerFrameMixin:OnLoad()
end

function WoWTokenContainerFrameMixin:OnShow()
	local animContainer = self.AnimContainer;
	animContainer:SetShown(true);
end

function WoWTokenContainerFrameMixin:OnHide()
	local animContainer = self.AnimContainer;
	animContainer:SetShown(false);
end


----------------------------------------------------------------------------------
-- ToyContainerFrameMixin
----------------------------------------------------------------------------------
ToyContainerFrameMixin = {};
function ToyContainerFrameMixin:OnLoad()
end

function ToyContainerFrameMixin:OnShow()
	local animContainer = self.AnimContainer;
	animContainer:SetShown(true);
end

function ToyContainerFrameMixin:OnHide()
	local animContainer = self.AnimContainer;
	animContainer:SetShown(false);
end


----------------------------------------------------------------------------------
-- ServicesContainerFrameMixin
----------------------------------------------------------------------------------
ServicesContainerFrameMixin = {};
function ServicesContainerFrameMixin:OnLoad()
end

function ServicesContainerFrameMixin:OnShow()
	local animContainer = self.AnimContainer;
	animContainer:SetShown(true);
end

function ServicesContainerFrameMixin:OnHide()
	local animContainer = self.AnimContainer;
	animContainer:SetShown(false);
end


----------------------------------------------------------------------------------
-- CrossGameContainerFrameMixin
----------------------------------------------------------------------------------
CrossGameContainerFrameMixin = {};
function CrossGameContainerFrameMixin:OnLoad()
end

function CrossGameContainerFrameMixin:OnShow()
end

function CrossGameContainerFrameMixin:OnHide()
end

local function SetAlternateProductURLImage(displayInfo)
	local texture = CatalogShopFrame.CrossGameContainerFrame.PMTImageForNoModel;

	if displayInfo and displayInfo.otherProductPMTURL then
		C_Texture.SetURLTexture(texture, displayInfo.otherProductPMTURL);
	end
end

-- TODO: Add support for correct localized flavor based on PMT attribute [WOW11-145789]
local function SetMissingLicenseCaptionText(displayInfo)
	local text = CatalogShopFrame.CrossGameContainerFrame.OtherProductWarningText;

	if not displayInfo then
		text:SetText("");
		return;
	end

	local secureEnv = GetCurrentEnvironment();

	if displayInfo.otherProductGameTitleBaseTag then
		local gameNameStr = nil;
		if displayInfo.otherProductGameType == CatalogShopConstants.GameTypes.Classic then
			gameNameStr = CatalogShopConstants.GameTypeGlobalStringTag.Classic;
		elseif displayInfo.otherProfuctGameType == CatalogShopConstants.GameTypes.Modern then
			gameNameStr = CatalogShopConstants.GameTypeGlobalStringTag.Modern;
		end
		-- At this point gameNameStr should be nil (no special name format), "%s Classic", or "World of Warcraft: %s"

		if gameNameStr then
			local gameTitleStr = secureEnv[displayInfo.otherProductGameTitleBaseTag];
			gameNameStr = gameNameStr:format(gameTitleStr);
		else
			gameNameStr = secureEnv[displayInfo.otherProductGameTitleBaseTag];
		end
		-- At this point gameNameStr is a fully described game title "Mists of Pandaria Classic" or "World of Warcraft: The War Within"

		gameNameStr = CatalogShopConstants.ShopGlobalStringTag.MissingLicenseCaptionText:format(gameNameStr);
		-- At this point the text is complete and holds something like "This product is available in Mists of Pandaria Classic"

		text:SetText(gameNameStr);
	else
		text:SetText("");
	end
end

function CrossGameContainerFrameMixin:SetDisplayInfo(displayInfo)
	CatalogShopUtil.SetAlternateProductIcon(self.WatermarkLogoTexture, displayInfo);
	SetAlternateProductURLImage(displayInfo);
	SetMissingLicenseCaptionText(displayInfo);
end


----------------------------------------------------------------------------------
-- CatalogShopDetailsRaceButtonMixin
----------------------------------------------------------------------------------
CatalogShopDetailsRaceButtonMixin = {};


----------------------------------------------------------------------------------
-- RaceChoiceMixin
----------------------------------------------------------------------------------
CatalogShopRaceChoiceMixin = {};

function CatalogShopRaceChoiceMixin:OnLoad()
end

function CatalogShopRaceChoiceMixin:OnShow()
end

function CatalogShopRaceChoiceMixin:OnHide()
end

function CatalogShopRaceChoiceMixin:OnEvent()
end

----------------------------------------------------------------------------------
-- GlowPulseAnimContainerMixin
----------------------------------------------------------------------------------
GlowPulseAnimContainerMixin = {};
function GlowPulseAnimContainerMixin:OnLoad()
	if self.playLoopingSoundFX == true then
		self.loopingSoundEmitter = self:CreateLoopingSoundFX();
	else
		self.loopingSoundEmitter = nil;
	end
end

function GlowPulseAnimContainerMixin:CreateLoopingSoundFX()
	local startingSound = SOUNDKIT.CATALOG_SHOP_GOLD_SHIMMER_START;
	local loopingSound = SOUNDKIT.CATALOG_SHOP_GOLD_SHIMMER_LOOP;
	local endingSound = SOUNDKIT.CATALOG_SHOP_GOLD_SHIMMER_END;

	local loopStartDelay = 0.3; -- Delay before the looping sound starts
	local loopEndDelay = 0.3; -- Delay before the looping sound ends
	local loopFadeTime = 0.3; -- Time to fade out the looping sound

	return CreateLoopingSoundEffectEmitter(startingSound, loopingSound, endingSound, loopStartDelay, loopEndDelay, loopFadeTime);
end

function GlowPulseAnimContainerMixin:OnShow()
	self.ShopRays.RayAnim:Play();
	if self.loopingSoundEmitter then
		self.loopingSoundEmitter:StartLoopingSound();
	end
end

function GlowPulseAnimContainerMixin:OnHide()
	self.ShopRays.RayAnim:Stop();
	if self.loopingSoundEmitter then
		self.loopingSoundEmitter:CancelLoopingSound();
	end
end

----------------------------------------------------------------------------------
-- CatalogShopLoadingScreenMixin
----------------------------------------------------------------------------------
CatalogShopLoadingScreenMixin = {};
function CatalogShopLoadingScreenMixin:OnLoad()
	local startingSound = SOUNDKIT.CATALOG_SHOP_OPEN_LOADING_SCREEN;
	local loopingSound = SOUNDKIT.CATALOG_SHOP_LOADING_SCREEN_LOOP;
	local endingSound = SOUNDKIT.CATALOG_SHOP_OPEN_SHOP_AFTER_LOAD;

	local loopStartDelay = 0.3; -- Delay before the looping sound starts
	local loopEndDelay = 0.3; -- Delay before the looping sound ends
	local loopFadeTime = 0.3; -- Time to fade out the looping sound

	self.loopingSoundEmitter = CreateLoopingSoundEffectEmitter(startingSound, loopingSound, endingSound, loopStartDelay, loopEndDelay, loopFadeTime);
end

function CatalogShopLoadingScreenMixin:OnShow()
	self.loopingSoundEmitter:StartLoopingSound();
end

function CatalogShopLoadingScreenMixin:StopLoopingSound()
	self.loopingSoundEmitter:CancelLoopingSound();
end

function CatalogShopLoadingScreenMixin:OnHide()
	self:StopLoopingSound();
end


----------------------------------------------------------------------------------
-- CatalogShopUnavailableScreenMixin
----------------------------------------------------------------------------------
CatalogShopUnavailableScreenMixin = {};
function CatalogShopUnavailableScreenMixin:OnLoad()
end

function CatalogShopUnavailableScreenMixin:OnShow()
end

function CatalogShopUnavailableScreenMixin:OnHide()
end


----------------------------------------------------------------------------------
-- CarouselControlMixin
----------------------------------------------------------------------------------
CarouselControlMixin = {};
function CarouselControlMixin:OnLoad()
	EventRegistry:RegisterCallback("CatalogShopModel.TransmogLoaded.CheckCarousel", self.CheckCarousel, self);
	EventRegistry:RegisterCallback("CatalogShopModel.TransmogLoaded.HideCarousel", self.HideCarousel, self);

	local function OnCarouselButtonClick(button, buttonName, down)
		PlaySound(SOUNDKIT.CATALOG_SHOP_SELECT_GENERIC_UI_BUTTON);
		self.carouselIndex = self.carouselIndex + button.incrementAmount;
		self.carouselIndex = Clamp(self.carouselIndex, 1, #self.items);
		self:UpdateCarousel();

		self.currentItem = self.items[self.carouselIndex];

		if self.actor then
			CatalogShopUtil.CatalogShopTryOn(self.actor, self.currentItem);
			-- TODO do we need to notify any other UI elements of what happened here
			--EventRegistry:TriggerEvent("CatalogShop.Carousel.TransmogChanged", self.currentItem);
		end
	end

	local leftButton = self.CarouselLeftButton;
	leftButton.incrementAmount = -1;
	leftButton:SetScript("OnClick", OnCarouselButtonClick );

	local rightButton = self.CarouselRightButton;
	rightButton.incrementAmount = 1;
	rightButton:SetScript("OnClick", OnCarouselButtonClick );
end

function CarouselControlMixin:HideCarousel()
	self:Hide();
end

function CarouselControlMixin:CheckCarousel(modelScene, actor, playerData)
	if not playerData or C_Glue.IsOnGlueScreen() then
		self:Hide();
		return;
	end
	local itemModifiedAppearanceIDs = playerData.itemModifiedAppearanceIDs;
	self:SetCarouselItems(modelScene, actor, itemModifiedAppearanceIDs);
end

function CarouselControlMixin:UpdateCarouselText()
	local carouselText = format(CATALOG_SHOP_CAROUSEL_INDEX, self.carouselIndex, #self.items);
	self.CarouselLabelContainer.Label:SetText(carouselText);
end

function CarouselControlMixin:UpdateCarouselButtons()
	local count = #self.items;
	local enablePreviousButton = self.carouselIndex > 1;
	local enableNextButton = self.carouselIndex < count;
	self.CarouselLeftButton:SetEnabled(enablePreviousButton);
	self.CarouselRightButton:SetEnabled(enableNextButton);
end

function CarouselControlMixin:UpdateCarousel()
	self:UpdateCarouselText();
	self:UpdateCarouselButtons();
end

function CarouselControlMixin:SetCarouselItems(modelScene, actor, itemModifiedAppearanceIDs)
	self.carouselIndex = 1;
	self.actor = actor;
	self.modelScene = modelScene;
	self.items = itemModifiedAppearanceIDs;
	local count = self.items and #self.items or 0;
	local allSameType = CatalogShopUtil.ItemAppearancesHaveSameCategory(self.items);
	local showCarousel = count > 1 and allSameType;
	if showCarousel then
		self:UpdateCarousel();
	end
	self:SetShown(showCarousel);	
end

ProductsHeaderMixin = {};
function ProductsHeaderMixin:Init(headerData)
	self.headerData = headerData;
	-- Set up ProductsHeader
	if headerData.Name then
		self.ProductName:Show();
		self.ProductName:SetText(headerData.Name);
	else
		self.ProductName:Hide();
	end
	if headerData.Type then
		self.ProductType:Show();
		self.ProductType:SetText(headerData.Type);
	else
		self.ProductType:Hide();
	end
	if headerData.Description and headerData.Description ~= "" then
		self.ProductDescription:Show();
		self.ProductDescription:SetText(headerData.Description);
	else
		self.ProductDescription:Hide();
	end
	self.LegalDisclaimerText:SetShown(headerData.showLegal or false);
end

ProductDescriptionMixin = {};
function ProductDescriptionMixin:OnEnter()
	local parent = self:GetParent();
	if parent.headerData and self:IsShown() then
		CatalogShopFrame:ShowTooltip(self, parent.headerData.Name, parent.headerData.Description);
	end
end

function ProductDescriptionMixin:OnLeave()
	CatalogShopFrame:HideTooltip();
end
