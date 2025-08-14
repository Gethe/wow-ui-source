
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

function CatalogShopProductDetailsContainerFrameMixin:SetupBundleProductData()

	local function bundleChildSortComparator(lhs, rhs)
		local lhsChild = lhs.displayOrder or 999;
		local rhsChild = rhs.displayOrder or 999;
		return lhsChild < rhsChild;
	end

	local function detailContainerDataProvider()
		local dataProvider = CreateDataProvider();
		for _, childInfo in ipairs(self.DetailsProductContainerFrame.bundleChildInfo) do
			local productInfo = CatalogShopFrame:GetProductInfo(childInfo.childProductID);
			if productInfo then
				productInfo.elementType = CatalogShopConstants.ScrollViewElementType.Product;
				productInfo.isBundleChild = true;
				productInfo.displayOrder = childInfo.displayOrder;
				dataProvider:Insert(productInfo);
			end
		end
		dataProvider:SetSortComparator(bundleChildSortComparator);
		return dataProvider;
	end

	local function InitializeButton(frame, productInfo)
		local scrollContainer = self.DetailsProductContainerFrame.ProductsScrollBoxContainer;
		local isSelected = scrollContainer.selectionBehavior:IsElementDataSelected(productInfo);

		frame:Init();
		frame:SetProductInfo(productInfo);
		frame:SetSelected(isSelected);
		frame:SetScript("OnClick", function(button, buttonName)
			scrollContainer.selectionBehavior:ToggleSelect(button);
		end);
	end

	local function detailContainerElementFactory(factory, elementData)
		if elementData.cardDisplayData.productCardType == CatalogShopConstants.ProductCardType.Subscription then
			factory(CatalogShopConstants.CardTemplate.DetailsSubscriptionSmall, InitializeButton);
		else
			factory(CatalogShopConstants.CardTemplate.DetailsSmall, InitializeButton);
		end
	end

	local headerData = {
		Name = self.productInfo.name,
		Description = CatalogShopUtil.GetDescriptionText(self.productInfo, self.displayInfo)
	};
	local scrollBoxData = {
		ElementFactory = detailContainerElementFactory,
		GetDataProvider = detailContainerDataProvider
	};

	self.DetailsProductContainerFrame:Init();
	self.DetailsProductContainerFrame:SetData(headerData, scrollBoxData);
	self.DetailsProductContainerFrame:SetupScrollView();
end

function CatalogShopProductDetailsContainerFrameMixin:OnShow()
end

function CatalogShopProductDetailsContainerFrameMixin:OnHide()
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
	self.displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(self.productInfo.catalogShopProductID);

	self.DetailsProductContainerFrame.ProductsHeader:SetShown(true);
	self.DetailsProductContainerFrame.usesScrollBox = productInfo.isBundle or false;

	if productInfo.isBundle then
		self.DetailsProductContainerFrame.sectionData = nil;
		self.DetailsProductContainerFrame.bundleChildInfo = C_CatalogShop.GetProductIDsForBundle(productInfo.catalogShopProductID);
		self:SetupBundleProductData();
	else
		local headerData = {
			Name = self.productInfo.name,
			Type = self.displayInfo.productType,
			Description = CatalogShopUtil.GetDescriptionText(self.productInfo, self.displayInfo)
		};
		self.DetailsProductContainerFrame:SetData(headerData, nil);
		self.DetailsProductContainerFrame.bundleChildInfo = nil;
	end

	-- Only show the bundle container if our product is a bundle.
	self.DetailsProductContainerFrame:AllDataRefresh(true);
end
