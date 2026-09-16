PRICE_DISPLAY_WIDTH = 145;
PRICE_DISPLAY_WITH_CHECKMARK_WIDTH = 150;

function AuctionCategoryMixin:AddBulkInventoryTypeCategories(classID, subClassID, inventoryTypes)
	local inventoryTypeNone = nil;
	local useParentFilters = true;
	self:CreateSubCategoryAndFilter(classID, subClassID, inventoryTypeNone, nil, useParentFilters);

	for _, inventoryType in ipairs(inventoryTypes) do
		self:CreateSubCategoryAndFilter(classID, subClassID, inventoryType);
	end
end

do -- Weapons
	local weaponsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_WEAPONS);

	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Axe1H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Axe2H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Bows);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Guns);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Mace1H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Mace2H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Polearm);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Sword1H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Sword2H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Staff);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Unarmed);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Generic);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Dagger);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Thrown);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Crossbow);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Wand);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Fishingpole);
end

do -- Armor
	local MiscArmorInventoryTypes = {
		Enum.InventoryType.IndexHeadType,
		Enum.InventoryType.IndexNeckType,
		Enum.InventoryType.IndexBodyType,
		Enum.InventoryType.IndexFingerType,
		Enum.InventoryType.IndexTrinketType,
		Enum.InventoryType.IndexHoldableType,
	};

	local ClothArmorInventoryTypes = {
		Enum.InventoryType.IndexHeadType,
		Enum.InventoryType.IndexShoulderType,
		Enum.InventoryType.IndexChestType,
		Enum.InventoryType.IndexWaistType,
		Enum.InventoryType.IndexLegsType,
		Enum.InventoryType.IndexFeetType,
		Enum.InventoryType.IndexWristType,
		Enum.InventoryType.IndexHandType,
		Enum.InventoryType.IndexCloakType, -- Only for Cloth.
	};

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

	local miscCategory = armorCategory:CreateSubCategory(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic);
	miscCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic, MiscArmorInventoryTypes);

	local clothCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth);
	clothCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth, ClothArmorInventoryTypes);

	local clothChestCategory = clothCategory:FindSubCategoryByName(C_Item.GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	clothChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth, Enum.InventoryType.IndexRobeType);

	local leatherCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Leather);
	leatherCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Leather, ArmorInventoryTypes);

	local leatherChestCategory = leatherCategory:FindSubCategoryByName(C_Item.GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	leatherChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Leather, Enum.InventoryType.IndexRobeType);

	local mailCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Mail);
	mailCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Mail, ArmorInventoryTypes);

	local mailChestCategory = mailCategory:FindSubCategoryByName(C_Item.GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	mailChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Mail, Enum.InventoryType.IndexRobeType);

	local plateCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Plate);
	plateCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Plate, ArmorInventoryTypes);

	local plateChestCategory = plateCategory:FindSubCategoryByName(C_Item.GetItemInventorySlotInfo(Enum.InventoryType.IndexChestType));
	plateChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Plate, Enum.InventoryType.IndexRobeType);

	armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Shield);
	if ClassicExpansionAtLeast(LE_EXPANSION_CATACLYSM) then
		armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Relic);
	else
		armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Libram);
		armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Idol);
		armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Totem);
	end
end

do -- Containers
	local containersCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONTAINERS);
	--containersCategory:SetDetailColumnString(SLOT_ABBR);
	containersCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Container);
end

do -- Consumables (SubClasses Added in TBC)
	local consumablesCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONSUMABLES);
	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) then
		consumablesCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Consumable);
	else
		consumablesCategory:AddFilter(Enum.ItemClass.Consumable);
	end
end

do -- Glyphs (Added in Wrath)
	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		local glyphsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_GLYPHS);
		glyphsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Glyph);
	end
end

do -- Trade Goods (SubClasses Added in TBC)
	local tradeGoodsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_TRADE_GOODS);
	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) then
		tradeGoodsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Tradegoods);
	else
		tradeGoodsCategory:AddFilter(Enum.ItemClass.Tradegoods);
	end
end

do -- Projectile
	if ClassicExpansionAtMost(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		local projectileCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_PROJECTILE);
		projectileCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Projectile);
	end
end

do -- Quiver
	if ClassicExpansionAtMost(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		local quiverCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_QUIVER);
		quiverCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Quiver);
	end
end

do -- Recipes
	local recipesCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_RECIPES);
	recipesCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Recipe);
end

do -- Reagent (Changed to a ItemClass.Miscellaneous and other ClassIDs in TBC)
	if GetClassicExpansionLevel() == LE_EXPANSION_CLASSIC then
		local reagentCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_REAGENT);
		reagentCategory:AddFilter(Enum.ItemClass.Reagent);
	end
end

do -- Gems (Added in TBC)
	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) then
		local gemsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_GEMS);
		gemsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Gem);
	end
end

do -- Miscellaneous (SubClasses Added in TBC)
	local miscellaneousCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_MISCELLANEOUS);
	miscellaneousCategory:AddFilter(Enum.ItemClass.Miscellaneous);
	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) then
		miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.Junk);
		miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.Reagent);
		if not ClassicExpansionAtLeast(LE_EXPANSION_MISTS_OF_PANDARIA) then
			miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.CompanionPet);
		end
		miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.Holiday);
		miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.Other);
		miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.Mount);
	end
end

do -- Quest Items (Added in TBC)
	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) then
		local questItemsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_QUEST_ITEMS);
		questItemsCategory:AddFilter(Enum.ItemClass.Questitem);
	end
end

do -- Battle Pets (Added in MoP)
	if ClassicExpansionAtLeast(LE_EXPANSION_MISTS_OF_PANDARIA) then
		local battlePetsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_BATTLE_PETS);
		battlePetsCategory:AddFilter(Enum.ItemClass.Battlepet);
		battlePetsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Battlepet);
		battlePetsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous, Enum.ItemMiscellaneousSubclass.CompanionPet);
	end
end

do -- WoW Token
	local wowTokenCategory = AuctionFrame_CreateCategory(TOKEN_FILTER_LABEL);
	wowTokenCategory:AddFilter(ITEM_CLASS_WOW_TOKEN);
	wowTokenCategory:SetFlag("WOW_TOKEN_FLAG");
end
