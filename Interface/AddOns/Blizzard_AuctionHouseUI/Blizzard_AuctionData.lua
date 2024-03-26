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
		name = C_Item.GetItemInventorySlotInfo(inventoryType);
	elseif classID and subClassID then
		name = C_Item.GetItemSubClassInfo(classID, subClassID);
	elseif classID then
		name = C_Item.GetItemClassInfo(classID);
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
	oneHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Axe1H);
	oneHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Mace1H);
	oneHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Sword1H);

	oneHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Warglaive);
	oneHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Dagger);
	oneHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Unarmed);
	oneHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Wand);

	local twoHandedCategory = weaponsCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_TWO_HANDED);
	twoHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Axe2H);
	twoHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Mace2H);
	twoHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Sword2H);

	twoHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Polearm);
	twoHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Staff);

	local rangedCategory = weaponsCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_RANGED);
	rangedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Bows);
	rangedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Crossbow);
	rangedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Guns);
	rangedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Thrown);
	
	local miscCategory = weaponsCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_MISCELLANEOUS);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Fishingpole);

	local otherCategory = miscCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_OTHER);
	otherCategory:AddFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Generic);
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

	local plateCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Plate);
	plateCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Plate, ArmorInventoryTypes);

	local plateChestCategory = plateCategory:FindSubCategoryByName(C_Item.GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	plateChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Plate, Enum.InventoryType.IndexRobeType);

	local mailCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Mail);
	mailCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Mail, ArmorInventoryTypes);
	
	local mailChestCategory = mailCategory:FindSubCategoryByName(C_Item.GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	mailChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Mail, Enum.InventoryType.IndexRobeType);

	local leatherCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Leather);
	leatherCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Leather, ArmorInventoryTypes);

	local leatherChestCategory = leatherCategory:FindSubCategoryByName(C_Item.GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	leatherChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Leather, Enum.InventoryType.IndexRobeType);

	local clothCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth);
	clothCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth, ArmorInventoryTypes);

	local clothChestCategory = clothCategory:FindSubCategoryByName(C_Item.GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	clothChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth, Enum.InventoryType.IndexRobeType);

	local miscCategory = armorCategory:CreateSubCategory(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic);

	local useParentFilters = true;
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, nil, Enum.AuctionHouseFilter.LegendaryCraftedItemOnly, useParentFilters);

	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, Enum.InventoryType.IndexNeckType);

	miscCategory:CreateNamedSubCategoryAndFilter(AUCTION_SUBCATEGORY_CLOAK, Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth, Enum.InventoryType.IndexCloakType);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, Enum.InventoryType.IndexFingerType);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, Enum.InventoryType.IndexTrinketType);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, Enum.InventoryType.IndexHoldableType);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Shield);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, Enum.InventoryType.IndexBodyType);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, Enum.InventoryType.IndexHeadType);

	local cosmeticCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cosmetic);
end

do -- Containers
	local containersCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONTAINERS);
	containersCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_CONTAINER_SLOTS);
	containersCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Container);
end

do -- Gems
	local gemsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_GEMS);
	gemsCategory:SetDetailColumnString(ITEM_LEVEL_ABBR);
	gemsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Gem);
end

do -- Item Enhancement
	local itemEnhancementCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_ITEM_ENHANCEMENT);
	itemEnhancementCategory:SetDetailColumnString(ITEM_LEVEL_ABBR);
	itemEnhancementCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.ItemEnhancement);
end

do -- Consumables
	local consumablesCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONSUMABLES);
	consumablesCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_REQUIRED_LEVEL);
	consumablesCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Consumable);
end

do -- Glyphs
	local glyphsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_GLYPHS);
	glyphsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Glyph);
end

do -- Trade Goods
	local tradeGoodsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_TRADE_GOODS);
	tradeGoodsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Tradegoods);
end

do -- Recipes
	local recipesCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_RECIPES);
	recipesCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_RECIPE_SKILL);

	recipesCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Recipe);

	local bookCategory = recipesCategory:FindSubCategoryByName(C_Item.GetItemSubClassInfo(Enum.ItemClass.Recipe, Enum.ItemRecipeSubclass.Book));
	if bookCategory then
		bookCategory:SetSortIndex(100);
	end

	recipesCategory:SortSubCategories();
end

do -- Profession Equipment
	local professionEquipmentCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_PROFESSION_EQUIPMENT);
	professionEquipmentCategory:SetDetailColumnString(ITEM_LEVEL_ABBR);

	local ProfessionGearSubclasses = {
		Enum.ItemProfessionSubclass.Inscription,
		Enum.ItemProfessionSubclass.Tailoring,
		Enum.ItemProfessionSubclass.Leatherworking,
		Enum.ItemProfessionSubclass.Jewelcrafting,
		Enum.ItemProfessionSubclass.Alchemy,
		Enum.ItemProfessionSubclass.Blacksmithing,
		Enum.ItemProfessionSubclass.Engineering,
		Enum.ItemProfessionSubclass.Enchanting,
		Enum.ItemProfessionSubclass.Mining,
		Enum.ItemProfessionSubclass.Herbalism,
		Enum.ItemProfessionSubclass.Skinning,
		Enum.ItemProfessionSubclass.Cooking,
		Enum.ItemProfessionSubclass.Fishing,
	};

	for _, subclass in ipairs(ProfessionGearSubclasses) do
		local newCategory = professionEquipmentCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Profession, subclass);
		newCategory:CreateNamedSubCategoryAndFilter(AUCTION_SUBCATEGORY_PROFESSION_TOOLS, Enum.ItemClass.Profession, subclass, Enum.InventoryType.IndexProfessionToolType);
		newCategory:CreateNamedSubCategoryAndFilter(AUCTION_SUBCATEGORY_PROFESSION_ACCESSORIES, Enum.ItemClass.Profession, subclass, Enum.InventoryType.IndexProfessionGearType);
	end
end

do -- Battle Pets
	local battlePetsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_BATTLE_PETS);
	battlePetsCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_PET_LEVEL);

	battlePetsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Battlepet);
	battlePetsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.CompanionPet);
end

do -- Quest Items
	local questItemsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_QUEST_ITEMS);
	questItemsCategory:AddFilter(Enum.ItemClass.Questitem);
end

do -- Miscellaneous
	local miscellaneousCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_MISCELLANEOUS);
	miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.Junk);
	miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.Reagent);
	miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.Holiday);
	miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.Other);
	miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.Mount);
	miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.MountEquipment);
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
