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

function SettingsCategoryMixin:GetQualifiedName()
	local parentCategory = self:GetParentCategory();
	if parentCategory then
		return SETTINGS_SUBCATEGORY_FMT:format(self:GetName(), parentCategory:GetName());
	end
	return self:GetName();
end

function SettingsCategoryMixin:GetParentCategory()
	return self.parentCategory;
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

function SettingsCategoryMixin:GetCategorySet()
	if self.categorySet then
		return self.categorySet;
	end

	local parentCategory = self:GetParentCategory();
	if parentCategory then
		return parentCategory:GetCategorySet();
	end
end

function SettingsCategoryMixin:GetSubcategories()
	return self.subcategories;
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