NUM_BROWSE_TO_DISPLAY = 8;
NUM_AUCTION_ITEMS_PER_PAGE = 50;
NUM_FILTERS_TO_DISPLAY = 20;
BROWSE_FILTER_HEIGHT = 20;
NUM_BIDS_TO_DISPLAY = 9;
NUM_AUCTIONS_TO_DISPLAY = 9;
AUCTIONS_BUTTON_HEIGHT = 37;
CLASS_FILTERS = {};
AUCTION_TIMER_UPDATE_DELAY = 0.3;
MAXIMUM_BID_PRICE = 99999999999;
AUCTION_CANCEL_COST =  5;	--5% of the current bid
NUM_TOKEN_LOGS_TO_DISPLAY = 14;


AuctionCategories = {};

local function FindDeepestCategory(categoryIndex, ...)
	local categoryInfo = AuctionCategories[categoryIndex];
	for i = 1, select("#", ...) do
		local subCategoryIndex = select(i, ...);
		if categoryInfo and categoryInfo.subCategories and categoryInfo.subCategories[subCategoryIndex] then
			categoryInfo = categoryInfo.subCategories[subCategoryIndex];
		else
			break;
		end
	end
	return categoryInfo;
end

function AuctionFrame_GetDetailColumnString(categoryIndex, subCategoryIndex)
	local categoryInfo = FindDeepestCategory(categoryIndex, subCategoryIndex);
	return categoryInfo and categoryInfo:GetDetailColumnString() or REQ_LEVEL_ABBR;
end

function AuctionFrame_GetDetailColumnStringUnsafe(categoryIndex, subCategoryIndex)
	local categoryInfo = FindDeepestCategory(categoryIndex, subCategoryIndex);
	return categoryInfo and categoryInfo:GetDetailColumnStringUnsafe() or nil;
end

function AuctionFrame_DoesCategoryHaveFlag(flag, categoryIndex, subCategoryIndex, subSubCategoryIndex)
	local categoryInfo = FindDeepestCategory(categoryIndex, subCategoryIndex, subSubCategoryIndex);
	if categoryInfo then
		return categoryInfo:HasFlag(flag);
	end
	return false;
end

function AuctionFrame_CreateCategory(name)
	local category = CreateFromMixins(AuctionCategoryMixin);
	category.name = name;
	AuctionCategories[#AuctionCategories + 1] = category;
	return category;
end

AuctionCategoryMixin = {};

function AuctionCategoryMixin:SetDetailColumnString(detailColumnString)
	self.detailColumnString = detailColumnString;
end

function AuctionCategoryMixin:GetDetailColumnString()
	if self.detailColumnString then
		return self.detailColumnString;
	end
	if self.parent then
		return self.parent:GetDetailColumnString();
	end
	return REQ_LEVEL_ABBR;
end

function AuctionCategoryMixin:GetDetailColumnStringUnsafe()
	if self.detailColumnString then
		return self.detailColumnString;
	end
	if self.parent then
		return self.parent:GetDetailColumnStringUnsafe();
	end
	return nil;
end

function AuctionCategoryMixin:CreateSubCategory(classID, subClassID, inventoryType, implicitFilter)
	local name = "";
	if implicitFilter then
		name = AUCTION_HOUSE_FILTER_STRINGS[implicitFilter];
	elseif inventoryType then
		name = GetItemInventorySlotInfo(inventoryType);
	elseif classID and subClassID then
		name = GetItemSubClassInfo(classID, subClassID);
	elseif classID then
		name = GetItemClassInfo(classID);
	end
	return self:CreateNamedSubCategory(name);
end

function AuctionCategoryMixin:CreateNamedSubCategory(name)
	self.subCategories = self.subCategories or {};

	local subCategory = CreateFromMixins(AuctionCategoryMixin);
	self.subCategories[#self.subCategories + 1] = subCategory;

	assert(name and #name > 0);
	subCategory.name = name;
	subCategory.parent = self;
	subCategory.sortIndex = #self.subCategories;
	return subCategory;
end

function AuctionCategoryMixin:CreateNamedSubCategoryAndFilter(name, classID, subClassID, inventoryType, implicitFilter, useParentFilters)
	local category = self:CreateNamedSubCategory(name);

	if useParentFilters then
		self.filters = self.filters or {};
		category:SetFilters(self.filters);
	else
		category:AddFilter(classID, subClassID, inventoryType, implicitFilter);
	end

	return category;
end

function AuctionCategoryMixin:CreateSubCategoryAndFilter(classID, subClassID, inventoryType, implicitFilter, useParentFilters)
	local category = self:CreateSubCategory(classID, subClassID, inventoryType, implicitFilter);

	if useParentFilters then
		self.filters = self.filters or {};
		category:SetFilters(self.filters);
		category.implicitFilter = implicitFilter;
	else
		category:AddFilter(classID, subClassID, inventoryType, implicitFilter);
	end

	return category;
end

function AuctionCategoryMixin:AddBulkInventoryTypeCategories(classID, subClassID, inventoryTypes)
	local inventoryType = nil;
	local useParentFilters = true;
	self:CreateSubCategoryAndFilter(classID, subClassID, inventoryType, Enum.AuctionHouseFilter.LegendaryCraftedItemOnly, useParentFilters);

	for i, inventoryType in ipairs(inventoryTypes) do
		self:CreateSubCategoryAndFilter(classID, subClassID, inventoryType);
	end
end

function AuctionCategoryMixin:AddFilter(classID, subClassID, inventoryType, implicitFilter)
	if not classID and not subClassID and not inventoryType and not implicitFilter then
		return;
	end

	self.filters = self.filters or {};
	self.filters[#self.filters + 1] = { classID = classID, subClassID = subClassID, inventoryType = inventoryType, };

	self.implicitFilter = implicitFilter;

	if self.parent then
		self.parent:AddFilter(classID, subClassID, inventoryType, implicitFilter);
	end
end

function AuctionCategoryMixin:SetFilters(filters)
	self.filters = filters;
end

do
	local function GenerateSubClassesHelper(self, classID, subClasses)
		for i = 1, #subClasses do
			local subClassID = subClasses[i];
			self:CreateSubCategoryAndFilter(classID, subClassID);
		end
	end

	function AuctionCategoryMixin:GenerateSubCategoriesAndFiltersFromSubClass(classID)
		GenerateSubClassesHelper(self, classID, C_AuctionHouse.GetAuctionItemSubClasses(classID));
	end
end

function AuctionCategoryMixin:FindSubCategoryByName(name)
	if self.subCategories then
		for i, subCategory in ipairs(self.subCategories) do
			if subCategory.name == name then
				return subCategory;
			end
		end
	end
end

function AuctionCategoryMixin:SortSubCategories()
	if self.subCategories then
		table.sort(self.subCategories, function(left, right)
			return left.sortIndex < right.sortIndex;
		end)
	end
end

function AuctionCategoryMixin:SetSortIndex(sortIndex)
	self.sortIndex = sortIndex
end

function AuctionCategoryMixin:SetFlag(flag)
	self.flags = self.flags or {};
	self.flags[flag] = true;
end

function AuctionCategoryMixin:ClearFlag(flag)
	if self.flags then
		self.flags[flag] = nil;
	end
end

function AuctionCategoryMixin:HasFlag(flag)
	return not not (self.flags and self.flags[flag]);
end

do -- Weapons
	local weaponsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_WEAPONS);
	weaponsCategory:SetDetailColumnString(ITEM_LEVEL_ABBR);

	local oneHandedCategory = weaponsCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_ONE_HANDED);
	oneHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H);
	oneHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H);
	oneHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H);

	oneHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_WARGLAIVE);
	oneHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER);
	oneHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED);
	oneHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_WAND);

	local twoHandedCategory = weaponsCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_TWO_HANDED);
	twoHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H);
	twoHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H);
	twoHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD2H);

	twoHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM);
	twoHandedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF);

	local rangedCategory = weaponsCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_RANGED);
	rangedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_BOWS);
	rangedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_CROSSBOW);
	rangedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_GUNS);
	rangedCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_THROWN);
	
	local miscCategory = weaponsCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_MISCELLANEOUS);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_FISHINGPOLE);

	local otherCategory = miscCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_OTHER);
	otherCategory:AddFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_GENERIC);
end

do -- Armor
	local ArmorInventoryTypes = {
		Enum.InventoryType.IndexHeadType,
		Enum.InventoryType.IndexShoulderType,
		Enum.InventoryType.IndexChestType,
		Enum.InventoryType.IndexWaistType,
		Enum.InventoryType.IndexLegsType,
		Enum.InventoryType.IndexFeetType,
		Enum.InventoryType.IndexWristType,
		Enum.InventoryType.IndexHandType,
	};

	local armorCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_ARMOR);
	armorCategory:SetDetailColumnString(ITEM_LEVEL_ABBR);

	local plateCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE);
	plateCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE, ArmorInventoryTypes);

	local plateChestCategory = plateCategory:FindSubCategoryByName(GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	plateChestCategory:AddFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE, Enum.InventoryType.IndexRobeType);

	local mailCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL);
	mailCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL, ArmorInventoryTypes);
	
	local mailChestCategory = mailCategory:FindSubCategoryByName(GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	mailChestCategory:AddFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL, Enum.InventoryType.IndexRobeType);

	local leatherCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER);
	leatherCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER, ArmorInventoryTypes);

	local leatherChestCategory = leatherCategory:FindSubCategoryByName(GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	leatherChestCategory:AddFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER, Enum.InventoryType.IndexRobeType);

	local clothCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH);
	clothCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH, ArmorInventoryTypes);

	local clothChestCategory = clothCategory:FindSubCategoryByName(GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	clothChestCategory:AddFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH, Enum.InventoryType.IndexRobeType);

	local miscCategory = armorCategory:CreateSubCategory(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC);

	local useParentFilters = true;
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, nil, Enum.AuctionHouseFilter.LegendaryCraftedItemOnly, useParentFilters);

	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexNeckType);

	miscCategory:CreateNamedSubCategoryAndFilter(AUCTION_SUBCATEGORY_CLOAK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH, Enum.InventoryType.IndexCloakType);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexFingerType);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexTrinketType);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexHoldableType);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_SHIELD);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexBodyType);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexHeadType);

	local cosmeticCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_COSMETIC);
end

do -- Containers
	local containersCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONTAINERS);
	containersCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_CONTAINER_SLOTS);
	containersCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_CONTAINER);
end

do -- Gems
	local gemsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_GEMS);
	gemsCategory:SetDetailColumnString(ITEM_LEVEL_ABBR);
	gemsCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_GEM);
end

do -- Item Enhancement
	local itemEnhancementCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_ITEM_ENHANCEMENT);
	itemEnhancementCategory:SetDetailColumnString(ITEM_LEVEL_ABBR);
	itemEnhancementCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_ITEM_ENHANCEMENT);
end

do -- Consumables
	local consumablesCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONSUMABLES);
	consumablesCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_REQUIRED_LEVEL);
	consumablesCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_CONSUMABLE);
end

do -- Glyphs
	local glyphsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_GLYPHS);
	glyphsCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_GLYPH);
end

do -- Trade Goods
	local tradeGoodsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_TRADE_GOODS);
	tradeGoodsCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_TRADEGOODS);
end

do -- Recipes
	local recipesCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_RECIPES);
	recipesCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_RECIPE_SKILL);

	recipesCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_RECIPE);

	local bookCategory = recipesCategory:FindSubCategoryByName(GetItemSubClassInfo(LE_ITEM_CLASS_RECIPE, LE_ITEM_RECIPE_BOOK));
	if bookCategory then
		bookCategory:SetSortIndex(100);
	end

	recipesCategory:SortSubCategories();
end

do -- Battle Pets
	local battlePetsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_BATTLE_PETS);
	battlePetsCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_PET_LEVEL);

	battlePetsCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_BATTLEPET);
	battlePetsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_COMPANION_PET);
end

do -- Quest Items
	local questItemsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_QUEST_ITEMS);
	questItemsCategory:AddFilter(LE_ITEM_CLASS_QUESTITEM);
end

do -- Miscellaneous
	local miscellaneousCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_MISCELLANEOUS);
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_JUNK);
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_REAGENT);
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_HOLIDAY);
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_OTHER);
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_MOUNT);
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_MOUNT_EQUIPMENT);
end

do -- WoW Token
	local wowTokenCategory = AuctionFrame_CreateCategory(TOKEN_FILTER_LABEL);
	wowTokenCategory:AddFilter(ITEM_CLASS_WOW_TOKEN);
	wowTokenCategory:SetFlag("WOW_TOKEN_FLAG");
end

function AuctionHouseCategory_FindDeepest(categoryIndex, ...)
	local categoryInfo = AuctionCategories[categoryIndex];
	for i = 1, select("#", ...) do
		local subCategoryIndex = select(i, ...);
		if categoryInfo and categoryInfo.subCategories and categoryInfo.subCategories[subCategoryIndex] then
			categoryInfo = categoryInfo.subCategories[subCategoryIndex];
		else
			break;
		end
	end
	return categoryInfo;
end
