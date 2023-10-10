
local securecallfunction = securecallfunction;

local g_selectionBehavior;

local function CreateHeaderInitializer(label, headerIndex)
	local initializer = CreateFromMixins(ScrollBoxFactoryInitializerMixin);
	initializer:Init("SettingsCategoryListHeaderTemplate");
	initializer.data = { label = label, headerIndex = headerIndex };
	return initializer;
end

local function CreateSpacerInitializer()
	local initializer = CreateFromMixins(ScrollBoxFactoryInitializerMixin);
	initializer:Init("SettingsCategoryListSpacerTemplate");
	return initializer;
end

local CategoryButtonInitializerMixin = CreateFromMixins(ScrollBoxFactoryInitializerMixin);

local function CreateCategoryButtonInitializer(category, indent)
	local initializer = CreateFromMixins(CategoryButtonInitializerMixin);
	initializer:Init("SettingsCategoryListButtonTemplate");
	initializer.data = { category = category, indent = indent or 0 };
	return initializer;
end

SettingsCategoryListHeaderMixin = {};

function SettingsCategoryListHeaderMixin:Init(initializer)
	self.Label:SetText(initializer.data.label);
	local atlas = string.format("Options_CategoryHeader_%d", initializer.data.headerIndex);
	self.Background:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

SettingsCategoryListButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function SettingsCategoryListButtonMixin:OnLoad()
	self.Toggle:SetScript("OnClick", function(button, buttonName, down)
		local initializer = self:GetElementData();
		local category = initializer.data.category;
		self:SetExpanded(not category.expanded);
	end);
end

function SettingsCategoryListButtonMixin:OnEnter()
	if ButtonStateBehaviorMixin.OnEnter(self) then
		self:UpdateState();
	end
end

function SettingsCategoryListButtonMixin:OnLeave()
	if ButtonStateBehaviorMixin.OnLeave(self) then
		self:UpdateState();
	end
end

function SettingsCategoryListButtonMixin:UpdateStateInternal(selected)
	if selected then
		self.Label:SetFontObject("GameFontHighlight");
		self.Texture:SetAtlas("Options_List_Active", TextureKitConstants.UseAtlasSize);
		self.Texture:Show();
	else
		local initializer = self:GetElementData();
		local category = initializer.data.category;
		local fontObject;
		if category:HasParentCategory() then
			fontObject = "GameFontHighlight";
		else
			fontObject = "GameFontNormal";
		end

		self.Label:SetFontObject(fontObject);
		if self.over then
			self.Texture:SetAtlas("Options_List_Hover", TextureKitConstants.UseAtlasSize);
			self.Texture:Show();
		else
			self.Texture:Hide();
		end
	end
end

function SettingsCategoryListButtonMixin:UpdateState()
	self:UpdateStateInternal(g_selectionBehavior:IsSelected(self));
end

function SettingsCategoryListButtonMixin:Init(initializer)
	local category = initializer.data.category;

	self.Label:SetText(category:GetName());
	self.Toggle:SetShown(category:HasSubcategories());
	
	local anyNew = false;
	local layout = SettingsPanel:GetLayout(category);
	if layout and layout:IsVerticalLayout() then
		for _, initializer in layout:EnumerateInitializers() do
			local setting = initializer.data.setting;
			if setting and IsNewSettingInCurrentVersion(setting:GetVariable()) then
				anyNew = true;
				break;
			end
		end
	end

	self.NewFeature:SetShown(anyNew);

	self:SetExpanded(category.expanded);
	self:SetSelected(g_selectionBehavior:IsSelected(self));
end

function SettingsCategoryListButtonMixin:SetSelected(selected)
	self:UpdateStateInternal(selected);
end

function SettingsCategoryListButtonMixin:SetExpanded(expanded)
	local initializer = self:GetElementData();
	initializer.data.category.expanded = expanded;
	
	if expanded then
		self.Toggle:SetNormalTexture("common-button-dropdown-open");
		self.Toggle:SetPushedTexture("common-button-dropdown-openpressed");
	else
		self.Toggle:SetNormalTexture("common-button-dropdown-closed");
		self.Toggle:SetPushedTexture("common-button-dropdown-closedpressed");
	end
end

SettingsCategoryListMixin = CreateFromMixins(CallbackRegistryMixin);

SettingsCategoryListMixin:GenerateCallbackEvents(
	{
		"OnCategorySelected",
	}
);

function SettingsCategoryListMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.allCategories = {};
	self.groups = {};
	self.categorySet = Settings.CategorySet.Game;

	local function Factory(factory, elementData)
		local function Initializer(button, elementData)
			elementData:InitFrame(button);

			if elementData:IsTemplate("SettingsCategoryListButtonTemplate") then
				button:SetScript("OnClick", function(button, buttonName, down)
					g_selectionBehavior:Select(button);
					self:TriggerEvent(SettingsCategoryListMixin.Event.OnCategorySelected, elementData.data.category);
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
				end);
				
				local function OnToggle(button, buttonName, down)
					self:CreateCategories();
				end;
				
				button.Toggle:RegisterCallback("OnClick", OnToggle, self);
			end
		end
	
		elementData:Factory(factory, Initializer);
	end

	local function IndentCalculator(elementData)
		return elementData.data and elementData.data.indent or 0;
	end

	-- The scroll box is anchored -50 so that the "new" label can appear without
	-- being clipped. This offset moves the contents back into the desired position.
	local leftPad = 50;

	local pad = 0;
	local spacing = 2;
	local view = CreateScrollBoxListLinearView(pad, pad, leftPad, pad, spacing);
	view:SetElementFactory(Factory);
	view:SetElementIndentCalculator(IndentCalculator);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local scrollBoxAnchorsWithBar = 
	{
		CreateAnchor("TOPLEFT", -leftPad, 0),
		CreateAnchor("BOTTOMRIGHT", -16, 0);
	};
	local scrollBoxAnchorsWithoutBar = 
	{
		scrollBoxAnchorsWithBar[1],
		CreateAnchor("BOTTOMRIGHT", 0, 0);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);

	local function OnSelectionChanged(o, elementData, selected)
		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end

		if selected then
			self.ScrollBox:ScrollToElementData(elementData, ScrollBoxConstants.AlignNearest);
		end
	end;

	g_selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
	g_selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);
end

function SettingsCategoryListMixin:GetAllCategories()
	return self.allCategories;
end

function SettingsCategoryListMixin:GetOrCreateGroup(groupText, order)
	local index, tbl = FindInTableIf(self.groups, function(tbl)
		return tbl.groupText == groupText;
	end);

	if not index then
		tbl = {groupText=groupText, order=order or 10, categories={}};
		table.insert(self.groups, tbl);

		local function Sorter(lhs, rhs)
			return lhs.order < rhs.order;
		end
		table.sort(self.groups, Sorter);
	end
	return tbl;
end

function SettingsCategoryListMixin:GetCategory(categoryID)
	for index, tbl in ipairs(self.groups) do
		for index, category in ipairs(tbl.categories) do
			local id = securecallfunction(SettingsCategoryMixin.GetID, category);
			if id == categoryID then
				return category;
			end
		end
	end
	return nil;
end

local SETTING_GROUP_ADDONS = "AddOns";

function SettingsCategoryListMixin:AddCategoryInternal(category, group, addOn)
	local hasParentCategory = securecallfunction(SettingsCategoryMixin.HasParentCategory, category);
	if hasParentCategory then
		-- FIXME Will replace when we're not building the whole category list on insert/removal.
		self:CreateCategories();
		return;
	end

	local tbl = self:GetOrCreateGroup(group or SETTING_GROUP_ADDONS);
	tbl.categorySet = addOn and Settings.CategorySet.AddOns or Settings.CategorySet.Game;
	category:SetCategorySet(tbl.categorySet);

	local categories = tbl.categories;
	table.insert(categories, category);
	table.sort(categories, function(lhs, rhs)
		return lhs:GetOrder() < rhs:GetOrder();
	end);

	self.allCategories = {};
	for index, tbl in ipairs(self.groups) do
		tAppendAll(self.allCategories, tbl.categories);
	end

	self:CreateCategories();
end

function SettingsCategoryListMixin:AddCategory(category, groupText, addon)
	self:AddCategoryInternal(category, groupText, addon);
end

function SettingsCategoryListMixin:GetCurrentCategory()
	return self.currentCategory;
end

function SettingsCategoryListMixin:FindCategoryElementData(category)
	return self.ScrollBox:FindElementDataByPredicate(function(elementData)
		-- Spacer has no data.
		return elementData.data and (elementData.data.category == category);
	end);
end

function SettingsCategoryListMixin:SetCurrentCategory(category)
	self.currentCategory = category;

	-- Ensure that our current category list set contains the category, otherwise select the required set.
	self:SetCategorySet(category:GetCategorySet());

	-- We won't find the category if it is a subcategory whose parent is not expanded. Expand the parent
	-- if necessary, then regenerate the list.
	local parentCategory = category:GetParentCategory();
	if parentCategory and not parentCategory.expanded then
		parentCategory.expanded = true;
		self:CreateCategories();
	end

	-- Under normal circumstances we always expect the category to be found, however this can fail to be found
	-- when initializing the settings categories for the first time.
	local found = self:FindCategoryElementData(category);
	if found then
		g_selectionBehavior:SelectElementData(found);
	end

	return self:GetCategorySet();
end

function SettingsCategoryListMixin:SetCategorySet(categorySet)
	assert(EnumUtil.IsValid(Settings.CategorySet, categorySet));
	if self.categorySet ~= categorySet then
		self.categorySet = categorySet;
		self:CreateCategories();
	end
end

function SettingsCategoryListMixin:GetCategorySet()
	return self.categorySet;
end

function SettingsCategoryListMixin:GenerateElementList()
	local currentCategory = self:GetCurrentCategory();
	local headerCounter = CreateCounter();

	local function CreateSection(elementList, categories, indent)
		for index, category in ipairs(categories) do
			if not category.redirectCategory then
				local initializer = CreateCategoryButtonInitializer(category, indent);
				table.insert(elementList, initializer);
				
				if category == currentCategory then
					g_selectionBehavior:SelectElementData(initializer);
				end

				if category.expanded then
					CreateSection(elementList, category:GetSubcategories(), indent + 10);
				end
			end
		end
	end

	local function CreateGroup(elementList, categories, groupText)
		local indent = 0;
		if self:GetCategorySet() == Settings.CategorySet.Game then
			if groupText then
				local headerIndex = ((headerCounter() - 1) % 3) + 1;
				table.insert(elementList, CreateHeaderInitializer(groupText, headerIndex));
			end
		end

		CreateSection(elementList, categories, indent);
	end

	local elementList = {};

	local createSpacer = false;

	for index, tbl in ipairs(self.groups) do
		local groupText = tbl.groupText;

		if tbl.categorySet == self:GetCategorySet() then
			local categories = tbl.categories;
			if createSpacer then
				table.insert(elementList, CreateSpacerInitializer());
			end

			CreateGroup(elementList, categories, groupText);
			createSpacer = true;
		end
	end

	return elementList;
end

function SettingsCategoryListMixin:CreateCategories()
	self.elementList = self:GenerateElementList();
	local dataProvider = CreateDataProvider(self.elementList);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end