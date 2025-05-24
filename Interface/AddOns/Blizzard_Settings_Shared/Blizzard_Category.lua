SettingsCategoryMixin = {};

local idCounter = CreateCounter();

local securecallfunction = securecallfunction;
function SettingsCategoryMixin:Init(name)
	self.subcategories = {};
	self.ID = idCounter();
	self.order = self.ID;
	self:SetName(name);
end

function SettingsCategoryMixin:GetID()
	return self.ID;
end

function SettingsCategoryMixin:GetName()
	return self.name;
end

function SettingsCategoryMixin:SetName(name)
	self.name = name;
end

function SettingsCategoryMixin:GetOrder()
	return self.order;
end

function SettingsCategoryMixin:SetOrder(order)
	self.order = order;
end

local function SecureGetQualifiedName(category)
	local parentCategory = category:GetParentCategory();
	if parentCategory then
		return SETTINGS_SUBCATEGORY_FMT:format(category:GetName(), parentCategory:GetName());
	end
	return category:GetName();
end

function SettingsCategoryMixin:GetQualifiedName()
	return securecallfunction(SecureGetQualifiedName, self);
end

local function SecureGetParentCategory(category)
	return category.parentCategory;
end

function SettingsCategoryMixin:GetParentCategory()
	return securecallfunction(SecureGetParentCategory, self);
end

function SettingsCategoryMixin:SetParentCategory(category)
	self.parentCategory = category;
end

function SettingsCategoryMixin:HasParentCategory()
	return self:GetParentCategory() ~= nil;
end

function SettingsCategoryMixin:SetCategorySet(categorySet)
	self.categorySet = categorySet;
end

local function SecureGetCategorySet(category)
	if category.categorySet then
		return category.categorySet;
	end

	local parentCategory = category:GetParentCategory();
	if parentCategory then
		return parentCategory:GetCategorySet();
	end
end

function SettingsCategoryMixin:GetCategorySet()
	return securecallfunction(SecureGetCategorySet, self);
end

local function SecureGetSubcategories(category)
	return category.subcategories;
end

function SettingsCategoryMixin:GetSubcategories()
	return securecallfunction(SecureGetSubcategories, self);
end

function SettingsCategoryMixin:HasSubcategories()
	return #self.subcategories > 0;
end

function SettingsCategoryMixin:CreateSubcategory(name, description)
	local subcategory = Settings.CreateCategory(name, description);
	subcategory:SetParentCategory(self);
	table.insert(self.subcategories, subcategory);
	return subcategory;
end

function SettingsCategoryMixin:SetCategoryTutorialInfo(tooltip, callback)
	self.tutorial = {
		tooltip = tooltip,
		callback = callback,
	};
end

local function SecureGetCategoryTutorialInfo(category)
	return category.tutorial;
end

function SettingsCategoryMixin:GetCategoryTutorialInfo()
	return securecallfunction(SecureGetCategoryTutorialInfo, self);
end

function SettingsCategoryMixin:SetExpanded(expanded)
	self.expanded = expanded;
end

local function SecureIsExpanded(category)
	return category.expanded;
end

function SettingsCategoryMixin:IsExpanded()
	return securecallfunction(SecureIsExpanded, self);
end

local function SecureShouldSortAlphabetically(category)
	return category.shouldSortAlphabetically;
end

function SettingsCategoryMixin:ShouldSortAlphabetically()
	return securecallfunction(SecureShouldSortAlphabetically, self);
end

function SettingsCategoryMixin:SetShouldSortAlphabetically(should)
	self.shouldSortAlphabetically = should;
end