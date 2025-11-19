
TestProductIDs = {
	{productID=2023436},
	{productID=2023431},
	{productID=2023432},
	{productID=2023435},
	{productID=2023434},
	{productID=2023433},
};

local SmallCardWidth = 195;

local function IsElementDataItemInfo(elementData)
	return (elementData and (elementData.elementType ~= CatalogShopConstants.ScrollViewElementType.Header)) or false;
end

----------------------------------------------------------------------------------
-- TopUpProductContainerFrameMixin
----------------------------------------------------------------------------------
TopUpProductContainerFrameMixin = {};
function TopUpProductContainerFrameMixin:OnLoad()
end

function TopUpProductContainerFrameMixin:Init()
	self:InitProductContainer();
end

function TopUpProductContainerFrameMixin:SetSelectedProductInfo(productInfo)
	self.selectedProductInfo = productInfo;
end

function TopUpProductContainerFrameMixin:InitProductContainer()
	local function addProductToDataProvider(dataProvider, productID)
		local productInfo = CatalogShopUtil.GetProductInfo(productID);
		if not productInfo then
			return false;
		end

		-- If the product is hidden, skip it
		if productInfo.isHidden then
			return false;
		end

		productInfo.elementType = CatalogShopConstants.ScrollViewElementType.Product;
		productInfo.categoryID = categoryID;
		productInfo.sectionID = sectionID;
		dataProvider:Insert(productInfo);
		return true;
	end
	
	local function InitializeButton(frame, productInfo)
		local isSelected = self.selectionBehavior:IsElementDataSelected(productInfo);

		frame:Init();
		frame:SetProductInfo(productInfo);
		frame:SetSelected(isSelected);
		frame:SetScript("OnClick", function(button, buttonName)
			self.selectionBehavior:ToggleSelect(button);
		end);
	end

	local function GetProductContainerElementFactory(factory, elementData)
		factory("SmallCatalogShopProductWithBuyButtonCardTemplate", InitializeButton)
	end
	self:SetupScrollView(GetProductContainerElementFactory);

	local dataProvider = CreateDataProvider();
	for _, product in ipairs(TestProductIDs) do
		local productID = product.productID;
		local productAdded = addProductToDataProvider(dataProvider, productID);
	end
	self.ScrollBox:SetDataProvider(dataProvider);
end

function TopUpProductContainerFrameMixin:OnProductSelected(productInfo)
	self:SetSelectedProductInfo(productInfo);
end

function TopUpProductContainerFrameMixin:SetupScrollView(elementFactory)
	local topPadding = 0;
	local bottomPadding = 0;
	local leftPadding = 0;
	local rightPadding = 0;
	local horizontalSpacing = 0;
	local verticalSpacing = 0;

	local view = CreateScrollBoxListLinearView(DefaultPad, DefaultPad, DefaultPad, DefaultPad, -0.05);
	view:SetVirtualized(false);
	view:SetHorizontal(true);
	view:SetElementFactory(elementFactory);
	view:SetElementExtentCalculator(function()
		return SmallCardWidth;
	end);
	self.ScrollBox:Init(view);
	--ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local function OnSelectionChanged(o, elementData, selected)
		-- Cannot select, or it's meaningless to select a Header element
		if not IsElementDataItemInfo(elementData) then
			return;
		end

		if selected then
			self:OnProductSelected(elementData);
		end

		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end
	end;
	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);
end
