
CatalogShopHeaderFrameMixin = {};
function CatalogShopHeaderFrameMixin:OnLoad()
end

function CatalogShopHeaderFrameMixin:SetCategories(...)
	local catalogShopCategoryIDs = ...;

	local function CreateCategoryButtonInfo(categoryID)
		local categoryInfo = C_CatalogShop.GetCategoryInfo(categoryID);
		if categoryInfo then
			return { ID = categoryID, label = categoryInfo.displayName, linkTag = categoryInfo.linkTag };
		end
	end

	local categoryButtonInfos = {};
	for i, categoryID in ipairs(catalogShopCategoryIDs) do
		local categoryButtonInfo = CreateCategoryButtonInfo(categoryID);
		if categoryButtonInfo then
			table.insert(categoryButtonInfos, categoryButtonInfo);
		end
	end

	self.CatalogShopNavBar:Init(categoryButtonInfos);
end

function CatalogShopHeaderFrameMixin:Init(...)
	self:SetCategories(...);
end
