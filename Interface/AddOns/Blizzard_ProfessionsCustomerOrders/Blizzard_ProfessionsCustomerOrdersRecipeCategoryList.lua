
local function GetFieldFromCategoryType(type)
	if type == Enum.CraftingOrderCustomerCategoryType.Primary then
		return "primaryCategoryID";
	elseif type == Enum.CraftingOrderCustomerCategoryType.Secondary then
		return "secondaryCategoryID";
	elseif type == Enum.CraftingOrderCustomerCategoryType.Tertiary then
		return "tertiaryCategoryID";
	end
end

local function GetChildCategoryType(type)
	if type == Enum.CraftingOrderCustomerCategoryType.Primary then
		return Enum.CraftingOrderCustomerCategoryType.Secondary
	elseif type == Enum.CraftingOrderCustomerCategoryType.Secondary then
		return Enum.CraftingOrderCustomerCategoryType.Tertiary;
	end
end

local function IsCategorySelected(categoryInfo, categoryFilters)
	if not categoryInfo then
		return false;
	end
	
	if categoryInfo.type == Enum.CraftingOrderCustomerCategoryType.Primary then
		return categoryInfo.categoryID == categoryFilters.primaryCategoryID;
	elseif categoryInfo.type == Enum.CraftingOrderCustomerCategoryType.Secondary then
		return categoryInfo.categoryID == categoryFilters.secondaryCategoryID;
	elseif categoryInfo.type == Enum.CraftingOrderCustomerCategoryType.Tertiary then
		return categoryInfo.categoryID == categoryFilters.tertiaryCategoryID;
	end
end


-- Largely copied from AuctionHouseFilterButton
ProfessionsCustomerOrdersCategoryButtonMixin = {};

function ProfessionsCustomerOrdersCategoryButtonMixin:OnLoad()
	self:SetPushedTextOffset(0, 0);
end

function ProfessionsCustomerOrdersCategoryButtonMixin:OnMouseDown()
	self.Text:AdjustPointsOffset(1, -1);
end

function ProfessionsCustomerOrdersCategoryButtonMixin:OnMouseUp()
	self.Text:AdjustPointsOffset(-1, 1);
end

function ProfessionsCustomerOrdersCategoryButtonMixin:OnEnter()
	TruncatedTooltipScript_OnEnter(self);

	if not self.isSpacer then
		self.HighlightTexture:Show();
	end
end

function ProfessionsCustomerOrdersCategoryButtonMixin:OnLeave()
	TruncatedTooltipScript_OnLeave(self);

	self.HighlightTexture:Hide();
end

function ProfessionsCustomerOrdersCategoryButtonMixin:Init(categoryInfo, categoryFilters, isRecraftCategory, isSpacer)
	self.categoryInfo = categoryInfo;
	-- Reference to the category filters set on the parent
	self.categoryFilters = categoryFilters;
	self.isSpacer = isSpacer;

	for _, region in ipairs(self.buttonRegions) do
		region:SetShown(not isSpacer);
	end
	for _, region in ipairs(self.spacerRegions) do
		region:SetShown(isSpacer);
	end

	if isSpacer then
		return;
	end

	local normalText = self.Text;
	local normalTexture = self.NormalTexture;
	local line = self.Lines;

	if isRecraftCategory or categoryInfo.type == Enum.CraftingOrderCustomerCategoryType.Primary then
		self:SetNormalFontObject(GameFontNormalSmall);
		self.NormalTexture:SetAtlas("auctionhouse-nav-button", false);
		self.NormalTexture:SetSize(136,32);
		self.NormalTexture:ClearAllPoints();
		self.NormalTexture:SetPoint("TOPLEFT", -2, 0);
		self.SelectedTexture:SetAtlas("auctionhouse-nav-button-select", false);
		self.SelectedTexture:SetSize(132,21);
		self.SelectedTexture:ClearAllPoints();
		self.SelectedTexture:SetPoint("LEFT");
		self.HighlightTexture:SetAtlas("auctionhouse-nav-button-highlight", false);
		self.HighlightTexture:SetSize(132,21);
		self.HighlightTexture:ClearAllPoints();
		self.HighlightTexture:SetPoint("LEFT");
		self.HighlightTexture:SetBlendMode("BLEND");
		normalText:SetPoint("LEFT", self, "LEFT", 8, 0);
		normalTexture:SetAlpha(1.0);
		line:Hide();
	elseif categoryInfo.type == Enum.CraftingOrderCustomerCategoryType.Secondary then
		self:SetNormalFontObject(GameFontHighlightSmall);
		self.NormalTexture:SetAtlas("auctionhouse-nav-button-secondary", false);
		self.NormalTexture:SetSize(133,32);
		self.NormalTexture:ClearAllPoints();
		self.NormalTexture:SetPoint("TOPLEFT", 1, 0);
		self.SelectedTexture:SetAtlas("auctionhouse-nav-button-secondary-select", false);
		self.SelectedTexture:SetSize(122,21);
		self.SelectedTexture:ClearAllPoints();
		self.SelectedTexture:SetPoint("TOPLEFT", 10, 0);
		self.HighlightTexture:SetAtlas("auctionhouse-nav-button-secondary-highlight", false);
		self.HighlightTexture:SetSize(122,21);
		self.HighlightTexture:ClearAllPoints();
		self.HighlightTexture:SetPoint("TOPLEFT", 10, 0);
		self.HighlightTexture:SetBlendMode("BLEND");
		normalText:SetPoint("LEFT", self, "LEFT", 18, 0);
		normalTexture:SetAlpha(1.0);
		line:Hide();
	elseif categoryInfo.type == Enum.CraftingOrderCustomerCategoryType.Tertiary then
		self:SetNormalFontObject(GameFontHighlightSmall);
		self.NormalTexture:ClearAllPoints();
		self.NormalTexture:SetPoint("TOPLEFT", 10, 0);
		self.SelectedTexture:SetAtlas("auctionhouse-ui-row-select", false);
		self.SelectedTexture:SetSize(116,18);
		self.SelectedTexture:ClearAllPoints();
		self.SelectedTexture:SetPoint("TOPRIGHT",0,-2);	
		self.HighlightTexture:SetAtlas("auctionhouse-ui-row-highlight", false);
		self.HighlightTexture:SetSize(116,18);
		self.HighlightTexture:ClearAllPoints();
		self.HighlightTexture:SetPoint("TOPRIGHT",0,-2);
		self.HighlightTexture:SetBlendMode("ADD");
		normalText:SetPoint("LEFT", self, "LEFT", 26, 0);
		normalTexture:SetAlpha(0.0);
		line:Show();
	end
	self:UpdateSelected();

	self:SetText(isRecraftCategory and PROFESSIONS_START_RECRAFTING_ORDER or categoryInfo.categoryName);
end

function ProfessionsCustomerOrdersCategoryButtonMixin:UpdateSelected()
	local selected = IsCategorySelected(self.categoryInfo, self.categoryFilters);
	self.SelectedTexture:SetShown(selected);
end


ProfessionsCustomerOrdersRecipeCategoryListMixin = {};

function ProfessionsCustomerOrdersRecipeCategoryListMixin:Init()
	local emptyProvider = CreateTreeDataProvider();
	self.ScrollBox:SetDataProvider(emptyProvider);

	self.categoryFilters = {};
end

function ProfessionsCustomerOrdersRecipeCategoryListMixin:OnLoad()
	local indent = 0;
	local topPad = 0;
	local bottomPad = 0;
	local leftPad = 3;
	local rightPad = 0;
	local spacing = 0;
	local view = CreateScrollBoxListTreeListView(indent, topPad, bottomPad, leftPad, rightPad, spacing);
	view:SetElementInitializer("ProfessionsCustomerOrdersCategoryButtonTemplate", function(button, node)
		local data = node:GetData();
		local categoryInfo = data.categoryInfo;
		button:Init(categoryInfo, self.categoryFilters, data.isRecraftCategory, data.isSpacer);

		if data.isSpacer then
			button:SetScript("OnClick", nil);
		else
			if data.isRecraftCategory then
				button:SetScript("OnClick", function()
					EventRegistry:TriggerEvent("ProfessionsCustomerOrders.RecraftCategorySelected");
				end);
			else
				button:SetScript("OnClick", function()
					local wasCollapsed = node:IsCollapsed();
					self:SetCategoryFilter(categoryInfo.type, wasCollapsed and categoryInfo.categoryID or nil);
				end);
			end
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function ProfessionsCustomerOrdersRecipeCategoryListMixin:OnDataLoadFinished()
    local categories = C_CraftingOrders.GetCustomerCategories();

	local idx = 1;
	local function InsertChildrenToTree(tree, childType)
		while idx <= #categories and categories[idx].type == childType do
			local currCategoryInfo = categories[idx];
			local newChild = tree:Insert({categoryInfo = currCategoryInfo, isRecraftCategory = false, isSpacer = false});
			idx = idx + 1;

			local subChildType = GetChildCategoryType(currCategoryInfo.type);
			InsertChildrenToTree(newChild, subChildType);
		end
	end

	local dataProvider = CreateTreeDataProvider();
	dataProvider:Insert({isRecraftCategory = true});
	dataProvider:Insert({isSpacer = true});
	InsertChildrenToTree(dataProvider, Enum.CraftingOrderCustomerCategoryType.Primary);
	dataProvider:CollapseAll();

	self.ScrollBox:SetDataProvider(dataProvider);
end

function ProfessionsCustomerOrdersRecipeCategoryListMixin:SetCategoryFilter(type, categoryID)
	local currType = type;
	while currType ~= nil do
		local fieldToUpdate = GetFieldFromCategoryType(currType);
		local newVal = (currType == type) and categoryID or nil;
		self.categoryFilters[fieldToUpdate] = newVal;
		currType = GetChildCategoryType(currType);
	end

	local function UpdateNodeExpanded(node)
		local elementData = node:GetData();
		local categoryInfo = elementData.categoryInfo;
		local collapsed = not IsCategorySelected(categoryInfo, self.categoryFilters);
		node:SetCollapsed(collapsed, TreeDataProviderConstants.RetainChildCollapse, TreeDataProviderConstants.SkipInvalidation);
	end

	local dataProvider = self.ScrollBox:GetDataProvider();
	dataProvider:ForEach(UpdateNodeExpanded, TreeDataProviderConstants.IncludeCollapsed);
	dataProvider:Invalidate();

	local function UpdateButtonSelected(button)
		button:UpdateSelected();
	end

	self.ScrollBox:ForEachFrame(UpdateButtonSelected);
end

function ProfessionsCustomerOrdersRecipeCategoryListMixin:GetCategoryFilters()
	return self.categoryFilters;
end