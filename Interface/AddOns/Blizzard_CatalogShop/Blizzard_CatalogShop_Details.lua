
----------------------------------------------------------------------------------
-- CatalogShopProductBYOBContainerFrameMixin
----------------------------------------------------------------------------------
CatalogShopProductBYOBContainerFrameMixin = {};

function CatalogShopProductBYOBContainerFrameMixin:Init()
	self.BYOBProductContainerFrame:Init();
	self.BYOBPurchaseButton:SetEnabled(false);

	EventRegistry:RegisterCallback("BYOBSelectionGroup.AllChoicesMade", self.AllChoicesMade, self);
end

function CatalogShopProductBYOBContainerFrameMixin:AllChoicesMade(isFinished)
	if isFinished then
		-- ALL choices across all selectionGroups are done
		-- enable the BYOB Purchase Button
		self.BYOBPurchaseButton:SetEnabled(true);
	else
		-- disable the BYOB Purchase Button
		self.BYOBPurchaseButton:SetEnabled(false);
	end

	-- Cards are dimmed/disabled per selection group via BYOBInterface.IsProductChoiceEnabled.
	local scrollBox = self.BYOBProductContainerFrame.ProductsScrollBoxContainer.ScrollBox;
	scrollBox:ForEachFrame(function(frame)
		if frame.UpdateChoiceState then
			frame:UpdateChoiceState();
		end
	end);
end

function CatalogShopProductBYOBContainerFrameMixin:OnShow()
	local selectedProductInfo = CatalogShopFrame:GetSelectedProductInfo();
	if selectedProductInfo then
		self.BYOBPurchaseButton:SetText(selectedProductInfo.price);
	end
end

function CatalogShopProductBYOBContainerFrameMixin:OnHide()
	local dataProvider = CreateDataProvider();
	self.BYOBProductContainerFrame.ProductsScrollBoxContainer.ScrollBox:SetDataProvider(dataProvider);
	BYOBInterface.ResetData();
end

function CatalogShopProductBYOBContainerFrameMixin:UpdateProductInfo(productInfo)
	self.productInfo = productInfo;
	self.BYOBProductContainerFrame:UpdateProductInfo(productInfo);
end


----------------------------------------------------------------------------------
-- CatalogShopProductDetailsContainerFrameMixin
----------------------------------------------------------------------------------
CatalogShopProductDetailsContainerFrameMixin = {};
function CatalogShopProductDetailsContainerFrameMixin:OnLoad()
	--RaceButton:SetDialog(CatalogShopFrame.ProductDetailsContainerFrame.RaceChoiceDialog);
end

function CatalogShopProductDetailsContainerFrameMixin:Init()
	self.DetailsProductContainerFrame:Init();
end

function CatalogShopProductDetailsContainerFrameMixin:UpdateSpecificProduct(productID)
	self.DetailsProductContainerFrame:UpdateSpecificProduct(productID);
end

function CatalogShopProductDetailsContainerFrameMixin:OnShow()
end

function CatalogShopProductDetailsContainerFrameMixin:OnHide()
	-- when we hide the Details Frame, we need to clear that ScrollBox
	local dataProvider = CreateDataProvider();
	self.DetailsProductContainerFrame.ProductsScrollBoxContainer.ScrollBox:SetDataProvider(dataProvider);
end

function CatalogShopProductDetailsContainerFrameMixin:OnEvent(event, ...)
	-- TODO handle events here
end

function CatalogShopProductDetailsContainerFrameMixin:OnEnter()
end

function CatalogShopProductDetailsContainerFrameMixin:OnLeave()
end

function CatalogShopProductDetailsContainerFrameMixin:UpdateProductInfo(productInfo)
	self.productInfo = productInfo;
	self.DetailsProductContainerFrame:UpdateProductInfo(productInfo);
end




-----------------------------------------------------------------------------------
--- DetailsProductContainerFrameMixin
-----------------------------------------------------------------------------------
DetailsProductContainerFrameMixin = CreateFromMixins(ProductContainerFrameMixin);
function DetailsProductContainerFrameMixin:OnLoad()
	CatalogShopProductContainerFrameMixin.OnLoad(self);
end

function DetailsProductContainerFrameMixin:Init()
	self:InitProductContainer();
end

function DetailsProductContainerFrameMixin:InitProductContainer()
	local function bundleChildSortComparator(lhs, rhs)
		local lhsChild = lhs.displayOrder or 999;
		local rhsChild = rhs.displayOrder or 999;
		-- Unknown licenses get a 100 element penalty to force them to show below those with known licenses
		if lhs.displayInfo and lhs.displayInfo.hasUnknownLicense then
			lhsChild = lhsChild + 100;
		end
		if rhs.displayInfo and rhs.displayInfo.hasUnknownLicense then
			rhsChild = rhsChild + 100;
		end
		return lhsChild < rhsChild;
	end

	local function GetDetailContainerDataProvider()
		local dataProvider = CreateDataProvider();
		for _, childInfo in ipairs(self.bundleChildInfo) do
			local productInfo = CatalogShopUtil.GetProductInfo(childInfo.childProductID);
			if productInfo and (not productInfo.isHidden) then
				productInfo.elementType = CatalogShopConstants.ScrollViewElementType.Product;
				productInfo.isBundleChild = true;
				productInfo.displayOrder = childInfo.displayOrder;
				productInfo.displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(childInfo.childProductID);
				productInfo.quantityInBundle = childInfo.quantityInBundle;
				dataProvider:Insert(productInfo);
			end
		end
		dataProvider:SetSortComparator(bundleChildSortComparator);
		return dataProvider;
	end
	self.getDataProviderFunc = GetDetailContainerDataProvider;

	local function InitializeButton(frame, productInfo)
		local scrollContainer = self.ProductsScrollBoxContainer;
		local isSelected = scrollContainer.selectionBehavior:IsElementDataSelected(productInfo);

		frame:Init();
		frame:SetProductInfo(productInfo);
		frame:SetSelected(isSelected);
		frame.selectionBehavior = scrollContainer.selectionBehavior;
		frame:SetScript("OnClick", function(button, buttonName)
			scrollContainer.selectionBehavior:ToggleSelect(button);
			EventRegistry:TriggerEvent("CatalogShop.OnBundleChildSelected", productInfo);
		end);

		EventRegistry:RegisterCallback("CatalogShop.OnProductInfoChanged", frame.OnProductInfoChanged, frame);
	end

	local function GetDetailContainerElementFactory(factory, elementData)
		if elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Subscription then
			-- Subscription
			factory(CatalogShopConstants.CardTemplate.DetailsSubscription, InitializeButton);
		elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.GameTime then
			-- Game Time
			factory(CatalogShopConstants.CardTemplate.DetailsGameTime, InitializeButton);
		elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Toy then
			-- Toy
			factory(CatalogShopConstants.CardTemplate.DetailsToys, InitializeButton);
		elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Decor then
			-- Decor
			factory(CatalogShopConstants.CardTemplate.DetailsDecor, InitializeButton);
		elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Room then
			-- Room
			factory(CatalogShopConstants.CardTemplate.DetailsRoom, InitializeButton);
		elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.TradersTenders then
			-- Trader's Tender
			factory(CatalogShopConstants.CardTemplate.DetailsTender, InitializeButton);
		elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Services then
			-- Services
			factory(CatalogShopConstants.CardTemplate.DetailsServices, InitializeButton);
		elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Access then
			-- Access
			factory(CatalogShopConstants.CardTemplate.DetailsAccess, InitializeButton);
		elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.HousingExteriorType then
			-- House exterior type
			factory(CatalogShopConstants.CardTemplate.DetailsExteriorType, InitializeButton);
		else
			factory(CatalogShopConstants.CardTemplate.Details, InitializeButton);
		end
	end
	self:SetupScrollView(GetDetailContainerElementFactory);
end

function DetailsProductContainerFrameMixin:UpdateProductInfo(productInfo)
	self.productInfo = productInfo;
	self.displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(self.productInfo.catalogShopProductID);

	self.ProductsHeader:SetShown(true);

	local desc = CatalogShopUtil.GetDescriptionText(self.productInfo);
	local showLegal = not productInfo.doNotShowWebString;
	if productInfo.isBundle then
		self.sectionData = nil;
		self.bundleChildInfo = C_CatalogShop.GetProductIDsForBundle(productInfo.catalogShopProductID);
		local headerData = {
			Name = self.productInfo.name,
			Description = desc,
			showLegal = showLegal,
		};
		self.ProductsHeader:Init(headerData);
	else
		local headerData = {
			Name = self.productInfo.name,
			Type = CatalogShopUtil.GetTypeText(productInfo),
			Description = desc,
			showLegal = showLegal,
		};
		self.ProductsHeader:Init(headerData);
		self.bundleChildInfo = nil;
	end

	local function onHyperlinkClicked(frame, link, text, button)
		C_CatalogShop.OnLegalDisclaimerClicked(self.productInfo.catalogShopProductID);
	end
	self.ProductsHeader:SetScript("OnHyperlinkClick", onHyperlinkClicked);

	-- Force the VerticalLayoutFrame to update the layout immediately. This allows the scrollbox to have accurate layout info from it's anchor.
	self.ProductsHeader:Layout();

	-- Init ProductsScrollBoxContainer AFTER the VerticalLayoutFrame has been built (via call to Layout)
	self.usesScrollBox = productInfo.isBundle or false;
	self.ProductsScrollBoxContainer:SetShown(self.usesScrollBox);
	self.ShadowLayer:SetShown(self.usesScrollBox);
	self:AllDataRefresh(true);

	-- Adding an Update to the scroll box with forceLayout set to true so the child elements will refresh after a product is selected.
	local forceLayout = true;
	self.ProductsScrollBoxContainer.ScrollBox:Update(forceLayout);
end

----------------------------------------------------------------------------------
-- BYOBProductContainerFrameMixin
----------------------------------------------------------------------------------
BYOBProductContainerFrameMixin = CreateFromMixins(DetailsProductContainerFrameMixin);
function BYOBProductContainerFrameMixin:OnLoad()
	DetailsProductContainerFrameMixin.OnLoad(self);
	BYOBInterface.ResetData();
	EventRegistry:RegisterCallback("BYOBSelectionGroup.UpdateProductChecked", self.UpdateProductChecked, self);
end

function BYOBProductContainerFrameMixin:OnShow()
	self.ProductsScrollBoxContainer:ClearAllPoints();
	self.ProductsScrollBoxContainer:SetPoint("TOPLEFT", self.ProductsHeader, "BOTTOMLEFT", 0, 0);
	self.ProductsScrollBoxContainer:SetPoint("BOTTOMRIGHT",self, 0, 100);
end

function BYOBProductContainerFrameMixin:OnHide()
end

function BYOBProductContainerFrameMixin:Init()
	self:InitProductContainer();
end

function BYOBProductContainerFrameMixin:UpdateProductChecked(selectionGroupIndex, productID, isChecked)
	BYOBInterface.SetProductChoiceChecked(selectionGroupIndex, productID, isChecked);
	EventRegistry:TriggerEvent("BYOBSelectionGroup.AllChoicesMade", BYOBInterface.AllChoicesCompleted());
end

function BYOBProductContainerFrameMixin:InitProductContainer()
	local function BYOBChildSortComparator(lhs, rhs)
		-- If both elements are the same, just return false (not less-than)
		if lhs == rhs then
			return false;
		end

		-- If both are headers they are equal. (by this point they are the same section)
		if lhs.elementType == CatalogShopConstants.ScrollViewElementType.Header and rhs.elementType == CatalogShopConstants.ScrollViewElementType.Header then
			return lhs.displayOrder < rhs.displayOrder;
		end

		local lhsOrder = lhs.displayOrder;
		local rhsOrder = rhs.displayOrder;

		-- Add 100 to any product's order value if it's 'owned'. We want to sort owned products to the bottom of their Sections
		local lhsOwned = lhs.isFullyOwned or false;
		if lhsOwned then
			lhsOrder = lhsOrder + 100;
		end
		local rhsOwned = rhs.isFullyOwned or false;
		if rhsOwned then
			rhsOrder = rhsOrder + 100;
		end
		return lhsOrder < rhsOrder;
	end

	local function addSectionToDataProvider(dataProvider, selectionGroupInfo, selectionGroupSortOffset)
		local sectionInfo = {};
		sectionInfo.elementType = CatalogShopConstants.ScrollViewElementType.Header;
		sectionInfo.displayOrder = selectionGroupSortOffset;
		sectionInfo.requiredQuantity = selectionGroupInfo.quantity or 0;
		sectionInfo.isBundleChild = false;
		dataProvider:Insert(sectionInfo);
	end

	local function GetDetailContainerDataProvider()
		local dataProvider = CreateDataProvider();
		local selectionGroupSortOffset = 1;

		BYOBInterface.ResetData();

		local selectionGroupInfos = self.productInfo.selectionGroupInfos
		for selectionGroupIndex, selectionGroupInfo in ipairs(selectionGroupInfos) do
			addSectionToDataProvider(dataProvider, selectionGroupInfo, selectionGroupSortOffset);
			local childrenProducts = selectionGroupInfo.products;

			BYOBInterface.SetSelectionGroupChoiceRequiredQuantity(selectionGroupIndex, selectionGroupInfo.quantity);

			for _, childInfo in ipairs(childrenProducts) do
				local productInfo = CatalogShopUtil.GetProductInfo(childInfo.childProductID);
				if productInfo and (not productInfo.isHidden) then

					BYOBInterface.SetProductChoiceChecked(selectionGroupIndex, productInfo.catalogShopProductID, false);
					productInfo.selectionGroupIndex = selectionGroupIndex;
					productInfo.elementType = CatalogShopConstants.ScrollViewElementType.Product;
					productInfo.isBundleChild = true;

					productInfo.displayOrder = childInfo.displayOrder + selectionGroupSortOffset;
					productInfo.displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(childInfo.childProductID);
					productInfo.quantityInBundle = childInfo.quantityInBundle;
					dataProvider:Insert(productInfo);
				end
			end
			selectionGroupSortOffset = selectionGroupSortOffset + 1000;
		end
		dataProvider:SetSortComparator(BYOBChildSortComparator);
		return dataProvider;
	end
	self.getDataProviderFunc = GetDetailContainerDataProvider;

	local function InitializeSection(frame, elementData)
		frame:Init();
		local sectionHeader = string.format(CATALOG_SHOP_BYOB_SECTION_HEADER, elementData.requiredQuantity);
		frame.headerText:SetText(sectionHeader);
	end

	local function InitializeButton(frame, productInfo)
		local scrollContainer = self.ProductsScrollBoxContainer;
		local isSelected = scrollContainer.selectionBehavior:IsElementDataSelected(productInfo);

		frame:Init();
		frame:SetProductInfo(productInfo);
		frame:SetSelected(isSelected);
		frame:SetScript("OnClick", function(button, buttonName)
			scrollContainer.selectionBehavior:ToggleSelect(button);
			EventRegistry:TriggerEvent("CatalogShop.OnBundleChildSelected", productInfo);
		end);

		EventRegistry:RegisterCallback("CatalogShop.OnProductInfoChanged", frame.OnProductInfoChanged, frame);
	end

	local function GetBYOBContainerElementFactory(factory, elementData)
		if elementData.elementType == CatalogShopConstants.ScrollViewElementType.Header then
			factory(CatalogShopConstants.CardTemplate.HeaderSectionGroupBYOB, InitializeSection);
		else
			factory(CatalogShopConstants.CardTemplate.SmallBYOB, InitializeButton);
		end
	end
	self:SetupScrollView(GetBYOBContainerElementFactory);
end

function BYOBProductContainerFrameMixin:UpdateProductInfo(productInfo)
	self.productInfo = productInfo;
	self.displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(self.productInfo.catalogShopProductID);

	-- update this with whatever BYOB data we need above the product list
	self.ProductsHeader:SetShown(true);
	local desc = CatalogShopUtil.GetDescriptionText(self.productInfo);
	local headerData = {
		Name = self.productInfo.name,
		Description = desc,
		showLegal = not productInfo.doNotShowWebString,
	};
	self.ProductsHeader:Init(headerData);

	local function onHyperlinkClicked(frame, link, text, button)
		C_CatalogShop.OnLegalDisclaimerClicked(self.productInfo.catalogShopProductID);
	end
	self.ProductsHeader:SetScript("OnHyperlinkClick", onHyperlinkClicked);

	-- Force the VerticalLayoutFrame to update the layout immediately. This allows the scrollbox to have accurate layout info from it's anchor.
	self.ProductsHeader:Layout();

	-- Init ProductsScrollBoxContainer AFTER the VerticalLayoutFrame has been built (via call to Layout)
	self.usesScrollBox = productInfo.isBundle or false;
	self.ProductsScrollBoxContainer:SetShown(self.usesScrollBox);
	self.ShadowLayer:SetShown(self.usesScrollBox);
	self:AllDataRefresh(true);

	-- Adding an Update to the scroll box with forceLayout set to true so the child elements will refresh after a product is selected.
	local forceLayout = true;
	self.ProductsScrollBoxContainer.ScrollBox:Update(forceLayout);
end
