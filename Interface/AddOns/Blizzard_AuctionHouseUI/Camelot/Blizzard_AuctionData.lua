PRICE_DISPLAY_WIDTH = 120;
PRICE_DISPLAY_WITH_CHECKMARK_WIDTH = 140;

function AuctionCategoryMixin:AddBulkInventoryTypeCategories(classID, subClassID, inventoryTypes)
	local inventoryTypeNone = nil;
	local useParentFilters = true;

	for _, inventoryType in ipairs(inventoryTypes) do
		self:CreateSubCategoryAndFilter(classID, subClassID, inventoryType);
	end
end

do -- Weapons
	local weaponsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_WEAPONS);
	weaponsCategory:SetDetailColumnString(ITEM_LEVEL_ABBR);

	local oneHandedCategory = weaponsCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_ONE_HANDED);
	oneHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Axe1H);
	oneHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Mace1H);
	oneHandedCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Sword1H);

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
		Enum.InventoryType.IndexRelicType,
	};

	local RelicInventoryTypes = {
		Enum.InventoryType.IndexRelicType
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

	local relicCategory = armorCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_RELIC);
	relicCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Idol);
	relicCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Libram);
	relicCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Totem);

	local miscCategory = armorCategory:CreateSubCategory(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic);

	local useParentFilters = true;
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, Enum.InventoryType.IndexNeckType);

	miscCategory:CreateNamedSubCategoryAndFilter(AUCTION_SUBCATEGORY_CLOAK, Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth, Enum.InventoryType.IndexCloakType);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, Enum.InventoryType.IndexFingerType);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, Enum.InventoryType.IndexTrinketType);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, Enum.InventoryType.IndexHoldableType);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Shield);
	miscCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, Enum.InventoryType.IndexBodyType);

	
end

do -- Containers

	local function CreatePair(classID, subClassID)
		return {
			["classID"] = classID,
			["subClassID"] = subClassID
		};
	end

	local containersCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONTAINERS);
	containersCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_CONTAINER_SLOTS);

	local StandardContainers = {
		CreatePair(Enum.ItemClass.Container, Enum.ItemContainerSubclass.Bag),
		CreatePair(Enum.ItemClass.Container, Enum.ItemContainerSubclass.Soul),
	};

	local AmmoContainers = {
		CreatePair(Enum.ItemClass.Quiver,    Enum.ItemQuiverSubclass.Quiver),
		CreatePair(Enum.ItemClass.Quiver,    Enum.ItemQuiverSubclass.Ammopouch),
	};

	local ReagentContainers = {
		CreatePair(Enum.ItemClass.Container, Enum.ItemContainerSubclass.Herb),
		CreatePair(Enum.ItemClass.Container, Enum.ItemContainerSubclass.Enchanting),
		CreatePair(Enum.ItemClass.Container, Enum.ItemContainerSubclass.Engineering),
		CreatePair(Enum.ItemClass.Container, Enum.ItemContainerSubclass.Mining),
		CreatePair(Enum.ItemClass.Container, Enum.ItemContainerSubclass.Leatherworking),
		CreatePair(Enum.ItemClass.Container, Enum.ItemContainerSubclass.Tacklebox),
		CreatePair(Enum.ItemClass.Container, Enum.ItemContainerSubclass.Cooking),
		CreatePair(Enum.ItemClass.Container, Enum.ItemContainerSubclass.Reagent),
	};

	local standardCategory = containersCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_STANDARD_CONTAINER);
	for k,v in pairs(StandardContainers) do
		standardCategory:CreateSubCategoryAndFilter(v.classID, v.subClassID);
	end
	
	local ammoCategory = containersCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_AMMO_CONTAINER);
	for k,v in pairs(AmmoContainers) do
		ammoCategory:CreateSubCategoryAndFilter(v.classID, v.subClassID);
	end

	local reagentCategory = containersCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_REAGENT_CONTAINER);
	for k,v in pairs(ReagentContainers) do
		reagentCategory:CreateSubCategoryAndFilter(v.classID, v.subClassID);
	end
end

do -- Consumables
	local consumablesCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONSUMABLES);
	consumablesCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_REQUIRED_LEVEL);

	local subclasses = C_AuctionHouse.GetAuctionItemSubClasses(Enum.ItemClass.Consumable);

	for k,v in pairs(subclasses) do
		if not (v == Enum.ItemConsumableSubclass.Itemenhancement or v == Enum.ItemConsumableSubclass.ItemenhancementTemporary) then
			consumablesCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Consumable, v);
		end
		if v == Enum.ItemConsumableSubclass.Bandage then -- After bandages add item enhancement with subcategories
			local enhanceCategory = consumablesCategory:CreateNamedSubCategory(AUCTION_SUBCATEGORY_ITEM_ENHANCEMENT);

			enhanceCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Consumable, Enum.ItemConsumableSubclass.Itemenhancement);
			enhanceCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Consumable, Enum.ItemConsumableSubclass.ItemenhancementTemporary);
		end
	end
end

do -- Trade Goods
	local tradeGoodsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_TRADE_GOODS);
	tradeGoodsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Tradegoods);
end

do -- Projectile
	local projectileCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_PROJECTILE);
	projectileCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Projectile);
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

do -- Quest Items
	local questItemsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_QUEST_ITEMS);
	questItemsCategory:AddFilter(Enum.ItemClass.Questitem);
end

do -- Miscellaneous
	local miscellaneousCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_MISCELLANEOUS);
	miscellaneousCategory:AddFilter(Enum.ItemClass.Miscellaneous);
	miscellaneousCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Miscellaneous);
end

do -- WoW Token
	local wowTokenCategory = AuctionFrame_CreateCategory(TOKEN_FILTER_LABEL);
	wowTokenCategory:AddFilter(ITEM_CLASS_WOW_TOKEN);
	wowTokenCategory:SetFlag("WOW_TOKEN_FLAG");
end
