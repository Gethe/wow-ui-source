
CatalogShopProductDetailsContainerFrameMixin = {};
function CatalogShopProductDetailsContainerFrameMixin:OnLoad()
	--RaceButton:SetDialog(CatalogShopFrame.ProductDetailsContainerFrame.RaceChoiceDialog);
end

function CatalogShopProductDetailsContainerFrameMixin:Init()
	self.DetailsProductContainerFrame:Init();
	--self:SetupProductDetailsContainerHelpers();	
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
		return lhsChild < rhsChild;
	end

	local function GetDetailContainerDataProvider()
		local dataProvider = CreateDataProvider();
		for _, childInfo in ipairs(self.bundleChildInfo) do
			local productInfo = CatalogShopFrame:GetProductInfo(childInfo.childProductID);
			if productInfo and (not productInfo.isHidden) then
				productInfo.elementType = CatalogShopConstants.ScrollViewElementType.Product;
				productInfo.isBundleChild = true;
				productInfo.displayOrder = childInfo.displayOrder;
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
		frame:SetScript("OnClick", function(button, buttonName)
			scrollContainer.selectionBehavior:ToggleSelect(button);
			EventRegistry:TriggerEvent("CatalogShop.OnBundleChildSelected", productInfo);
		end);
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
		elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.TradersTenders then
			-- Trader's Tender
			factory(CatalogShopConstants.CardTemplate.DetailsTender, InitializeButton);
		elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Services then
			-- Services
			factory(CatalogShopConstants.CardTemplate.DetailsServices, InitializeButton);
		elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Access then
			-- Access
			factory(CatalogShopConstants.CardTemplate.DetailsAccess, InitializeButton);
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
	if productInfo.isBundle then
		self.sectionData = nil;
		self.bundleChildInfo = C_CatalogShop.GetProductIDsForBundle(productInfo.catalogShopProductID);
		local headerData = {
			Name = self.productInfo.name,
			Description = desc,
			showLegal = true,
		};
		self.ProductsHeader:Init(headerData);
	else
		local headerData = {
			Name = self.productInfo.name,
			Type = self.displayInfo.productType,
			Description = desc,
			showLegal = true,
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
end
