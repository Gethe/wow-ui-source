
local function IsElementDataItemInfo(elementData)
	-- Header type elements are not items (can't be selected))
	return (elementData and (elementData.elementType ~= CatalogShopConstants.ScrollViewElementType.Header)) or false;
end

-----------------------------------------------------------------------------------
--- CatalogShopProductContainerFrameMixin
-----------------------------------------------------------------------------------

CatalogShopProductContainerFrameMixin = {};
function CatalogShopProductContainerFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("CatalogShop.AllDataRefresh", self.AllDataRefresh, self);
end

function CatalogShopProductContainerFrameMixin:Init()
	self.usesScrollBox = true;
	self.selectionWasAutomatic = false;		-- Initialize the variable
end

function CatalogShopProductContainerFrameMixin:SetupProductHeaderFrame(headerData)
	-- Set up ProductsHeader
	if headerData.Name then
		self.ProductsHeader.ProductName:Show();
		self.ProductsHeader.ProductName:SetText(headerData.Name);
	else
		self.ProductsHeader.ProductName:Hide();
	end
	if headerData.Type then
		self.ProductsHeader.ProductType:Show();
		self.ProductsHeader.ProductType:SetText(headerData.Type);
	else
		self.ProductsHeader.ProductType:Hide();
	end
	if headerData.Description then
		self.ProductsHeader.ProductDescription:Show();
		self.ProductsHeader.ProductDescription:SetText(headerData.Description);
	else
		self.ProductsHeader.ProductDescription:Hide();
	end
	self.ProductsHeader.LegalDisclaimerText:SetShown(headerData.showLegal or false);

end

function CatalogShopProductContainerFrameMixin:SetupScrollView(elementFactory)
	local scrollContainer = self.ProductsScrollBoxContainer;

	local view;
	local topPadding = 0;
	local bottomPadding = 0;
	local leftPadding = 0;
	local rightPadding = 0;
	local horizontalSpacing = -14;
	local verticalSpacing = -12;
	view = CreateScrollBoxListSequenceView(topPadding, bottomPadding, leftPadding, rightPadding, horizontalSpacing, verticalSpacing);
	view:SetElementFactory(elementFactory);

	ScrollUtil.InitScrollBoxListWithScrollBar(scrollContainer.ScrollBox, scrollContainer.ScrollBar, view);

	local function OnSelectionChanged(o, elementData, selected)
		-- Cannot select, or it's meaningless to select a Header element
		if not IsElementDataItemInfo(elementData) then
			return;
		end

		if selected then
			self:OnProductSelected(elementData);
		end

		local button = scrollContainer.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end
	end;
	scrollContainer.selectionBehavior = ScrollUtil.AddSelectionBehavior(scrollContainer.ScrollBox);
	scrollContainer.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);
end


function CatalogShopProductContainerFrameMixin:AllDataRefresh(resetSelection)
	self:UpdateProducts(resetSelection);
end

function CatalogShopProductContainerFrameMixin:UpdateSpecificProduct(productID)
	-- All code below this handles updating the scroll box
	local updateScrollBox = self.usesScrollBox or false;
	if (not self:IsShown()) or (not updateScrollBox) then
		return;
	end

	local productInfo = CatalogShopFrame:GetProductInfo(productID);
	if not productInfo then
		assert(false, "No productInfo for productID " .. productID);
		return;
	end

	local scrollBox = self.ProductsScrollBoxContainer.ScrollBox;
	local _, foundElementData = scrollBox:FindByPredicate(function(elementData)
		return elementData.catalogShopProductID == productID;
	end);

	if foundElementData then
		MergeTable(foundElementData, productInfo);

		EventRegistry:TriggerEvent("CatalogShop.OnProductInfoChanged", foundElementData);

		local selectedProductInfo = self:GetSelectedProductInfo();
		local selectedProductIsUpdating = selectedProductInfo and selectedProductInfo.catalogShopProductID == foundElementData.catalogShopProductID;

		-- Retrigger selection behavior because the selected product was incomplete
		if selectedProductIsUpdating then
			self:OnProductSelected(foundElementData);
		end
	end
end

function CatalogShopProductContainerFrameMixin:UpdateProducts(resetSelection)
	-- All code below this handles updating the scroll box
	local updateScrollBox = self.usesScrollBox or false;
	if (not self:IsShown()) or (not updateScrollBox) then
		return;
	end

	local previouslySelectedProductInfo = self:GetSelectedProductInfo();

	local scrollContainer = self.ProductsScrollBoxContainer;
	scrollContainer.selectionBehavior:ClearSelections();

	local hasExpirableItems = false;
	local dataProvider = self.getDataProviderFunc();
	scrollContainer.ScrollBox:SetDataProvider(dataProvider);

	if self.NoSearchResults then
		if dataProvider:IsEmpty() then
			self.NoSearchResults:Show();
			EventRegistry:TriggerEvent("CatalogShop.OnNoProductsSelected");
			return;
		else
			self.NoSearchResults:Hide();
		end
	end

	-- Try to preserve selection. If not select first product
	if resetSelection or not previouslySelectedProductInfo or not self:TrySelectProduct(previouslySelectedProductInfo) then
		self.selectionWasAutomatic = true;		-- The selection is being reset, keep track for later telemetry
		self:SelectFirstProductSilent();
	end
end

function CatalogShopProductContainerFrameMixin:TrySelectProduct(productInfo)
	local scrollContainer = self.ProductsScrollBoxContainer;
	local scrollBox = scrollContainer.ScrollBox;
	local _, foundElementData = scrollBox:FindByPredicate(function(elementData)
		return elementData.catalogShopProductID == productInfo.catalogShopProductID;
	end);
	if foundElementData then
		scrollContainer.selectionBehavior:SelectElementData(foundElementData);
		return true;
	end

	return false;
end

function CatalogShopProductContainerFrameMixin:OnShow()
	local resetSelection = true;

	local selectedProductInfo = self:GetSelectedProductInfo();
	if selectedProductInfo then
		local scrollBox = self.ProductsScrollBoxContainer.ScrollBox;
		local _, foundElementData = scrollBox:FindByPredicate(function(elementData)
			return elementData.catalogShopProductID == selectedProductInfo.catalogShopProductID;
		end);
		if foundElementData then
			self:OnProductSelected(foundElementData);
		end
	end
end

function CatalogShopProductContainerFrameMixin:OnHide()
end

function CatalogShopProductContainerFrameMixin:OnEvent(event, ...)
	-- TODO handle events here
end

function ModelSceneShouldAllowRotation(modelSceneID)
	local _, _, _, flags = C_ModelInfo.GetModelSceneInfoByID(modelSceneID);
	-- If the modelSceneID is invalid or not found, flags is returned as nil, so don't try the bit and
	if flags == nil then
		return false;
	end
	local noCameraSpin = bit.band(flags, Enum.UIModelSceneFlags.NoCameraSpin) == Enum.UIModelSceneFlags.NoCameraSpin;
	return (noCameraSpin == false);
end

function CatalogShopProductContainerFrameMixin:OnProductSelected(productInfo)
	self:SetSelectedProductInfo(productInfo);
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(self.selectedProductInfo.catalogShopProductID);
	local productType = productInfo.sceneDisplayData.productType;

	-- Skip telemetry if this product is a bundle child (we dont track those)
	if not self.selectedProductInfo.isBundleChild then
		C_CatalogShop.ProductSelectedTelemetry(self.selectedProductInfo.categoryID, self.selectedProductInfo.sectionID, self.selectedProductInfo.catalogShopProductID, self.selectionWasAutomatic);
	end
	self.selectionWasAutomatic = false;			-- Reset the variable.

	CatalogShopFrame:HidePreviewFrames();

	-- RNM : Check the preview model scenes to see if we want to disallow camera rotation.
	local modelSceneAllowsRotation = true;
	if displayInfo.overridePreviewModelSceneID then
		modelSceneAllowsRotation = ModelSceneShouldAllowRotation(displayInfo.overridePreviewModelSceneID);
	elseif displayInfo.defaultPreviewModelSceneID then
		modelSceneAllowsRotation = ModelSceneShouldAllowRotation(displayInfo.defaultPreviewModelSceneID);
	end
	-- Additionally, never allow camera rotation for a Bundle type product
	local canRotateModelScene = modelSceneAllowsRotation and (productType ~= CatalogShopConstants.ProductType.Bundle);
	if canRotateModelScene then
		CatalogShopFrame.ModelSceneContainerFrame.MainModelScene:SetScript("OnMouseDown", CatalogShopFrame.CachedModelSceneOnMouseDownFunc);
		CatalogShopFrame.ModelSceneContainerFrame.MainModelScene:SetScript("OnMouseUp", CatalogShopFrame.CachedModelSceneOnMouseUpFunc);
	else
		CatalogShopFrame.ModelSceneContainerFrame.MainModelScene:SetScript("OnMouseDown", nil);
		CatalogShopFrame.ModelSceneContainerFrame.MainModelScene:SetScript("OnMouseUp", nil);
	end

	-- An Unknown License implies we have a product from Catalog that isn't known by our server (it was returned as a missing license)
	-- So in this case we are currently assuming this means the product is for another game (which could be another flavor of WoW)
	if displayInfo.hasUnknownLicense then
		CatalogShopFrame.CrossGameContainerFrame:Show();
		CatalogShopFrame.CrossGameContainerFrame:SetDisplayInfo(displayInfo);
	elseif productType == CatalogShopConstants.ProductType.Token then
		CatalogShopFrame.WoWTokenContainerFrame:Show();
	elseif productType == CatalogShopConstants.ProductType.Toy then
		CatalogShopFrame.ToyContainerFrame:Show();
		CatalogShopFrame.ToyContainerFrame.AnimContainer.ToyIconFrame.Icon:SetTexture(displayInfo.iconFileDataID);
	elseif productType == CatalogShopConstants.ProductType.Services then
		CatalogShopFrame.ServicesContainerFrame:Show();

		local iconFrame = CatalogShopFrame.ServicesContainerFrame.AnimContainer.ServicesIconFrame;
		CatalogShopUtil.SetServicesContainerIcon(iconFrame.Icon, displayInfo);
		iconFrame.IconBorder:Show();
		if self.selectedProductInfo.bundleChildrenSize > 1 then
			iconFrame.ProductCounter:Show();
			iconFrame.ProductCounterText:Show();
			iconFrame.ProductCounterText:SetText(self.selectedProductInfo.bundleChildrenSize);
		else
			iconFrame.ProductCounter:Hide();
			iconFrame.ProductCounterText:Hide();
		end
		iconFrame.Icon:SetSize(224, 224);
	elseif productType == CatalogShopConstants.ProductType.Subscription or productType == CatalogShopConstants.ProductType.GameTime then
		-- Both sub time and game time have the same display type, but their Atlases are distinct
		CatalogShopFrame.ServicesContainerFrame:Show();
		local iconFrame = CatalogShopFrame.ServicesContainerFrame.AnimContainer.ServicesIconFrame;
		iconFrame.ProductCounter:Hide();
		iconFrame.ProductCounterText:Hide();
		iconFrame.IconBorder:Hide();
		iconFrame.Icon:SetSize(320, 320);

		local timeTexture = CatalogShopUtil.GetTimeTexture(self.selectedProductInfo, productType);
		if timeTexture then
			iconFrame.Icon:SetAtlas(timeTexture);
		end
	elseif productType == CatalogShopConstants.ProductType.TradersTenders then
		CatalogShopFrame.ServicesContainerFrame:Show();
		local iconFrame = CatalogShopFrame.ServicesContainerFrame.AnimContainer.ServicesIconFrame;
		iconFrame.ProductCounter:Hide();
		iconFrame.ProductCounterText:Hide();
		iconFrame.IconBorder:Hide();

		local quantity = displayInfo and displayInfo.quantity or nil;
		if quantity then
			local subTexture;
			subTexture = "tender-"..quantity;
			local atlasWidth = 320;
			local atlasHeight = 320;
			iconFrame.Icon:SetSize(atlasWidth, atlasHeight);
			iconFrame.Icon:SetAtlas(subTexture);
		end
	elseif productType == CatalogShopConstants.ProductType.Access then
		CatalogShopFrame.ServicesContainerFrame:Show();
		local iconFrame = CatalogShopFrame.ServicesContainerFrame.AnimContainer.ServicesIconFrame;
		iconFrame.ProductCounter:Hide();
		iconFrame.ProductCounterText:Hide();
		iconFrame.IconBorder:Hide();
		iconFrame.Icon:SetSize(320, 320);

		if productInfo.previewIconTexture then
			iconFrame.Icon:SetAtlas(productInfo.previewIconTexture);
		end
	else
		CatalogShopFrame.ModelSceneContainerFrame:Show();
	end

	EventRegistry:TriggerEvent("CatalogShop.OnProductSelected", productInfo);

	if not self.silenceSelectionSounds then
		PlaySound(SOUNDKIT.CATALOG_SHOP_SELECT_SHOP_ITEM);
	end
end

function CatalogShopProductContainerFrameMixin:OnEnter()
end

function CatalogShopProductContainerFrameMixin:OnLeave()
end

CatalogShopProductContainerFrameMixin.INTERVAL_UPDATE_SECONDS_TIME = 15.0;
local currentInterval = 0.0;
function CatalogShopProductContainerFrameMixin:OnUpdate(deltaTime)
	local usesScrollBox = self.usesScrollBox or false;
	if not usesScrollBox then
		return;
	end
	-- Scrollbox updates below this point
	currentInterval = currentInterval + deltaTime;
	if currentInterval >= CatalogShopProductContainerFrameMixin.INTERVAL_UPDATE_SECONDS_TIME then
		self.ProductsScrollBoxContainer.ScrollBox:ForEachFrame(function(frame)
			frame:UpdateTimeRemaining();
		end);
		currentInterval = 0.0;
	end
end

function CatalogShopProductContainerFrameMixin:SelectFirstProduct()
	self.ignoreNextSelectionForTelemetry = true;
	self.ProductsScrollBoxContainer.selectionBehavior:SelectFirstElementData(IsElementDataItemInfo);
end

function CatalogShopProductContainerFrameMixin:SelectFirstProductSilent()
	self.silenceSelectionSounds = true;
	self:SelectFirstProduct();
	self.silenceSelectionSounds = false;
end

function CatalogShopProductContainerFrameMixin:SetSelectedProductInfo(productInfo)
	self.selectedProductInfo = productInfo;
end

function CatalogShopProductContainerFrameMixin:GetSelectedProductInfo()
	return self.selectedProductInfo;
end

-----------------------------------------------------------------------------------
--- ProductContainerFrameMixin
-----------------------------------------------------------------------------------
ProductContainerFrameMixin = CreateFromMixins(CatalogShopProductContainerFrameMixin);
function ProductContainerFrameMixin:OnLoad()
	CatalogShopProductContainerFrameMixin.OnLoad(self);
	self.NoSearchResults:SetText(self.noSearchResultsText);
end

function ProductContainerFrameMixin:Init()
	self.usesScrollBox = true;
	self:InitProductContainer();	
end

function ProductContainerFrameMixin:InitProductContainer()
	local function sectionProductSortComparator(lhs, rhs)
		-- If the section IDs aren't the same, then use that as sort orderInPage
		if lhs.sectionID ~= rhs.sectionID then
			return lhs.sectionID < rhs.sectionID;
		end
		-- Sort section headers above their products
		if lhs.elementType ~= rhs.elementType then
			return lhs.elementType == CatalogShopConstants.ScrollViewElementType.Header;
		end
		-- (We have 2 products) Look for the collection sort order
		local lhsOrder = C_CatalogShop.GetProductSortOrder(lhs.categoryID, lhs.sectionID, lhs.catalogShopProductID) or 999;
		local rhsOrder = C_CatalogShop.GetProductSortOrder(rhs.categoryID, rhs.sectionID, rhs.catalogShopProductID) or 999;
		return lhsOrder < rhsOrder;
	end

	local function addSectionToDataProvider(dataProvider, categoryID, sectionID)
		local sectionInfo = {};
		sectionInfo.elementType = CatalogShopConstants.ScrollViewElementType.Header;
		sectionInfo.categoryID = categoryID;
		sectionInfo.sectionID = sectionID;
		sectionInfo.isBundleChild = false;
		dataProvider:Insert(sectionInfo);
	end

	local function addProductToDataProvider(dataProvider, categoryID, sectionID, productID)
		local productInfo = CatalogShopFrame:GetProductInfo(productID);
		if not productInfo then
			return false;
		end

		-- If the product is hidden, skip it
		if productInfo.isHidden then
			return false;
		end

		local searchText = CatalogShopFrame.HeaderFrame.SearchBox:GetText();
		if string.len(searchText) > 0 then
			local productName = productInfo.name;
			-- skip items that don't match the search text
			if not strfind(productName:lower(), searchText:lower(), 1, true) then
				return false;
			end
		end
		productInfo.elementType = CatalogShopConstants.ScrollViewElementType.Product;
		productInfo.categoryID = categoryID;
		productInfo.sectionID = sectionID;
		productInfo.isBundleChild = false;
		dataProvider:Insert(productInfo);
		return true;
	end

	local function GetProductContainerDataProvider()
		local dataProvider = CreateDataProvider();

		for _, sectionData in ipairs(self.sectionData) do
			local sectionID = sectionData.ID;
			if sectionData.productIDs then
				local atLeastOneProductAdded = false;
				-- Add all other items
				for _, productID in ipairs(sectionData.productIDs) do
					local productAdded = addProductToDataProvider(dataProvider, self.categoryID, sectionID, productID);
					atLeastOneProductAdded = atLeastOneProductAdded or productAdded;
				end
				-- Only add a header section if we added atleast one product for this Section (filtering can cause this to be 0)
				-- Additionally only add a header if the section name has a valid string
				local headerIsBlank = (not sectionData.sectionDisplayName) or (sectionData.sectionDisplayName == "");
				if (not headerIsBlank) and atLeastOneProductAdded then
					-- Add our section header element if we have products to Show
					addSectionToDataProvider(dataProvider, self.categoryID, sectionID);
				end
			end
		end
		dataProvider:SetSortComparator(sectionProductSortComparator);
		return dataProvider;
	end
	self.getDataProviderFunc = GetProductContainerDataProvider;

	local function InitializeSection(frame, elementData)
		frame:Init();
		frame:SetHeaderText(elementData);
	end

	local function InitializeButton(frame, productInfo)
		local scrollContainer = self.ProductsScrollBoxContainer;
		local isSelected = scrollContainer.selectionBehavior:IsElementDataSelected(productInfo);

		frame:Init();
		frame:SetProductInfo(productInfo);
		frame:SetSelected(isSelected);
		frame:SetScript("OnClick", function(button, buttonName)
			scrollContainer.selectionBehavior:ToggleSelect(button);
		end);
	end

	local function GetProductContainerElementFactory(factory, elementData)
		if elementData.elementType == CatalogShopConstants.ScrollViewElementType.Header then
			factory(CatalogShopConstants.CardTemplate.Header, InitializeSection)
		elseif elementData.elementType == CatalogShopConstants.ScrollViewElementType.Product then
			local sectionInfo = C_CatalogShop.GetCategorySectionInfo(elementData.categoryID, elementData.sectionID);
			
			local scrollViewSize = sectionInfo.scrollGridSize or 3;-- How many children per row
			if scrollViewSize == 1 then
				if elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Token then
					factory(CatalogShopConstants.CardTemplate.WideCardToken, InitializeButton);
				elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Subscription then
					factory(CatalogShopConstants.CardTemplate.WideCardSubscription, InitializeButton);
				elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.GameTime then
					factory(CatalogShopConstants.CardTemplate.WideCardGameTime, InitializeButton);
				else
					factory(CatalogShopConstants.CardTemplate.Wide, InitializeButton);
				end
			else
				if elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Services then
					factory(CatalogShopConstants.CardTemplate.SmallServices, InitializeButton);
				elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Subscription then
					factory(CatalogShopConstants.CardTemplate.SmallSubscriptions, InitializeButton);
				elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.GameTime then
					factory(CatalogShopConstants.CardTemplate.SmallGameTime, InitializeButton);
				elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Tender then
					factory(CatalogShopConstants.CardTemplate.SmallTender, InitializeButton);
				elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Toy then
					factory(CatalogShopConstants.CardTemplate.SmallToys, InitializeButton);
				elseif elementData.cardDisplayData.productType == CatalogShopConstants.ProductType.Access then
					factory(CatalogShopConstants.CardTemplate.SmallAccess, InitializeButton);
				else
					factory(CatalogShopConstants.CardTemplate.Small, InitializeButton);
				end
			end
		end
	end
	self:SetupScrollView(GetProductContainerElementFactory);
end

function ProductContainerFrameMixin:OnCategorySelected(categoryID)
	local categoryInfo = C_CatalogShop.GetCategoryInfo(categoryID);
	local resetSelection = true;
	self.categoryID = categoryID;
	self.sectionData = {};
	local sectionIDs = C_CatalogShop.GetSectionIDsForCategory(categoryID);
	for _, sectionID in ipairs(sectionIDs) do
		local data = {ID = sectionID, productIDs = {}};
		local sectionInfo = C_CatalogShop.GetCategorySectionInfo(categoryID, sectionID);
		data.sectionDisplayName = sectionInfo.displayName;
		local sectionProductIDs = C_CatalogShop.GetProductIDsForCategorySection(categoryID, sectionID);
		for _, productID in ipairs(sectionProductIDs) do
			table.insert(data.productIDs, productID);
		end
		table.insert(self.sectionData, data);
	end	
	self:AllDataRefresh(resetSelection);

	-- Init ProductsScrollBoxContainer
	self.ProductsScrollBoxContainer:SetShown(self.usesScrollBox);
	self.ShadowLayer:SetShown(self.usesScrollBox);

	local headerData = {
		Name = categoryInfo.displayName,
		showLegal = false,
	};
	self.ProductsHeader:Init(headerData);
end
