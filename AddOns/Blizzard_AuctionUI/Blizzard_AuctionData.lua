NUM_BROWSE_TO_DISPLAY = 8;
NUM_AUCTION_ITEMS_PER_PAGE = 50;
NUM_FILTERS_TO_DISPLAY = 15;
BROWSE_FILTER_HEIGHT = 20;
NUM_BIDS_TO_DISPLAY = 9;
NUM_AUCTIONS_TO_DISPLAY = 9;
AUCTIONS_BUTTON_HEIGHT = 37;
CLASS_FILTERS = {};
OPEN_FILTER_LIST = {};
AUCTION_TIMER_UPDATE_DELAY = 0.3;
MAXIMUM_BID_PRICE = 2000000000;
AUCTION_CANCEL_COST =  5;	--5% of the current bid
NUM_TOKEN_LOGS_TO_DISPLAY = 14;

AuctionSort = { };

-- owner sorts
AuctionSort["owner_status"] = {
	{ column = "seller",	reverse = false	},
	{ column = "buyout",	reverse = false	},
	{ column = "quality",	reverse = false	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = false	},
	{ column = "bid",		reverse = false	},
	{ column = "duration",	reverse = false	},
	{ column = "status",	reverse = false	},
};

AuctionSort["owner_bid"] = {
	{ column = "seller",	reverse = false	},
	{ column = "buyout",	reverse = false	},
	{ column = "quality",	reverse = false	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = false	},
	{ column = "duration",	reverse = false	},
	{ column = "status",	reverse = false	},
	{ column = "bid",		reverse = false	},
};

AuctionSort["owner_quality"] = {
	{ column = "seller",	reverse = false	},
	{ column = "buyout",	reverse = false	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = false	},
	{ column = "bid",		reverse = false	},
	{ column = "duration",	reverse = false	},
	{ column = "status",	reverse = false	},
	{ column = "quality",	reverse = false	},
};

AuctionSort["owner_duration"] = {
	{ column = "seller",	reverse = false	},
	{ column = "buyout",	reverse = false	},
	{ column = "quality",	reverse = false	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = false	},
	{ column = "bid",		reverse = false	},
	{ column = "status",	reverse = false	},
	{ column = "duration",	reverse = false	},
};

-- bidder sorts
AuctionSort["bidder_quality"] = {
	{ column =  "seller",	reverse = false	},
	{ column =  "buyout",	reverse = false	},
	{ column =  "name",		reverse = false	},
	{ column =  "level",	reverse = false	},
	{ column =  "bid",		reverse = false	},
	{ column =  "duration", reverse = false	},
	{ column =  "status",	reverse = false	},
	{ column =  "quality",	reverse = false	},
};

AuctionSort["bidder_level"] = {
	{ column =  "seller",	reverse = false	},
	{ column =  "buyout",	reverse = false	},
	{ column =  "quality",	reverse = false	},
	{ column =  "name",		reverse = false	},
	{ column =  "bid",		reverse = false	},
	{ column =  "duration", reverse = false	},
	{ column =  "status",	reverse = false	},
	{ column =  "level",	reverse = false	},
};

AuctionSort["bidder_buyout"] = {
	{ column =  "seller",	reverse = false	},
	{ column =  "quality",	reverse = false	},
	{ column =  "name",		reverse = false	},
	{ column =  "level",	reverse = false	},
	{ column =  "bid",		reverse = false	},
	{ column =  "duration", reverse = false	},
	{ column =  "status",	reverse = false	},
	{ column =  "buyout",	reverse = false	},
};
 
AuctionSort["bidder_status"] = {
	{ column =  "seller",	reverse = false	},
	{ column =  "buyout",	reverse = false	},
	{ column =  "quality",	reverse = false	},
	{ column =  "name",		reverse = false	},
	{ column =  "level",	reverse = false	},
	{ column =  "bid",		reverse = false	},
	{ column =  "duration", reverse = false	},
	{ column =  "status",	reverse = false	},
};

AuctionSort["bidder_bid"] = {
	{ column =  "seller",	reverse = false	},
	{ column =  "buyout",	reverse = false	},
	{ column =  "quality",	reverse = false	},
	{ column =  "name",		reverse = false	},
	{ column =  "level",	reverse = false	},
	{ column =  "duration", reverse = false	},
	{ column =  "status",	reverse = false	},
	{ column =  "bid",		reverse = false	},
};

AuctionSort["bidder_duration"] = {
	{ column =  "seller",	reverse = false	},
	{ column =  "buyout",	reverse = false	},
	{ column =  "quality",	reverse = false	},
	{ column =  "name",		reverse = false	},
	{ column =  "level",	reverse = false	},
	{ column =  "bid",		reverse = false	},
	{ column =  "status",	reverse = false	},
	{ column =  "duration", reverse = false	},
};

-- list sorts
AuctionSort["list_level"] = {
	{ column = "seller",	reverse = false },
	{ column = "name",		reverse = false },
	{ column = "status",	reverse = false	},
	{ column = "buyout",	reverse = false	},
	{ column = "duration",	reverse = false	},
	{ column = "bid",		reverse = false	},
	{ column = "quality",	reverse = false	},
	{ column = "level",		reverse = false	},
};
AuctionSort["list_duration"] = {
	{ column = "seller",	reverse = false },
	{ column = "name",		reverse = false },
	{ column = "status",	reverse = false	},
	{ column = "buyout",	reverse = false	},
	{ column = "bid",		reverse = false	},
	{ column = "quality",	reverse = true	},
	{ column = "level",		reverse = false	},
	{ column = "duration",	reverse = false	},
};
AuctionSort["list_seller"] = {
	{ column = "name",		reverse = false },
	{ column = "status",	reverse = false	},
	{ column = "buyout",	reverse = false	},
	{ column = "duration",	reverse = false	},
	{ column = "bid",		reverse = false	},
	{ column = "quality",	reverse = true	},
	{ column = "level",		reverse = false	},
	{ column = "seller",	reverse = false },
};
AuctionSort["list_bid"] = {
	{ column = "seller",	reverse = false },
	{ column = "name",		reverse = false },
	{ column = "status",	reverse = false	},
	{ column = "buyout",	reverse = false	},
	{ column = "duration",	reverse = false	},
	{ column = "quality",	reverse = true	},
	{ column = "level",		reverse = false	},
	{ column = "bid",		reverse = false	},
};

AuctionSort["list_quality"] = {
	{ column = "seller",	reverse = false },
	{ column = "name",		reverse = false },
	{ column = "status",	reverse = false	},
	{ column = "buyout",	reverse = false	},
	{ column = "duration",	reverse = false	},
	{ column = "bid",		reverse = false	},
	{ column = "level",		reverse = false	},
	{ column = "quality",	reverse = false	},
};

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

function AuctionCategoryMixin:CreateSubCategory(classID, subClassID, inventoryType)
	local name = "";
	if inventoryType then
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

function AuctionCategoryMixin:CreateNamedSubCategoryAndFilter(name, classID, subClassID, inventoryType)
	local category = self:CreateNamedSubCategory(name);
	category:AddFilter(classID, subClassID, inventoryType);

	return category;
end

function AuctionCategoryMixin:CreateSubCategoryAndFilter(classID, subClassID, inventoryType)
	local category = self:CreateSubCategory(classID, subClassID, inventoryType);
	category:AddFilter(classID, subClassID, inventoryType);

	return category;
end

function AuctionCategoryMixin:AddBulkInventoryTypeCategories(classID, subClassID, inventoryTypes)
	for i, inventoryType in ipairs(inventoryTypes) do
		self:CreateSubCategoryAndFilter(classID, subClassID, inventoryType);
	end
end

function AuctionCategoryMixin:AddFilter(classID, subClassID, inventoryType)
	self.filters = self.filters or {};
	self.filters[#self.filters + 1] = { classID = classID, subClassID = subClassID, inventoryType = inventoryType, };

	if self.parent then
		self.parent:AddFilter(classID, subClassID, inventoryType);
	end
end

do
	local function GenerateSubClassesHelper(self, classID, ...)
		for i = 1, select("#", ...) do
			local subClassID = select(i, ...);
			self:CreateSubCategoryAndFilter(classID, subClassID);
		end
	end

	function AuctionCategoryMixin:GenerateSubCategoriesAndFiltersFromSubClass(classID)
		GenerateSubClassesHelper(self, classID, GetAuctionItemSubClasses(classID));
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

	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_BOWS);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_GUNS);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD2H);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_GENERIC);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_THROWN);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_CROSSBOW);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_WAND);
	weaponsCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_FISHINGPOLE);
end

do -- Armor
	local ArmorInventoryTypes = {
		LE_INVENTORY_TYPE_HEAD_TYPE,
		LE_INVENTORY_TYPE_NECK_TYPE,
		LE_INVENTORY_TYPE_SHOULDER_TYPE,
		LE_INVENTORY_TYPE_BODY_TYPE,
		LE_INVENTORY_TYPE_CHEST_TYPE,
		LE_INVENTORY_TYPE_WAIST_TYPE,
		LE_INVENTORY_TYPE_LEGS_TYPE,
		LE_INVENTORY_TYPE_FEET_TYPE,
		LE_INVENTORY_TYPE_WRIST_TYPE,
		LE_INVENTORY_TYPE_HAND_TYPE,
		LE_INVENTORY_TYPE_FINGER_TYPE,
		LE_INVENTORY_TYPE_TRINKET_TYPE,
		LE_INVENTORY_TYPE_CLOAK_TYPE,
		LE_INVENTORY_TYPE_HOLDABLE_TYPE,
	};

	local armorCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_ARMOR);

	local miscCategory = armorCategory:CreateSubCategory(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC);
	miscCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, ArmorInventoryTypes);

	local clothCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH);
	clothCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH, ArmorInventoryTypes);

	local clothChestCategory = clothCategory:FindSubCategoryByName(GetItemInventorySlotInfo(LE_INVENTORY_TYPE_CHEST_TYPE));
	clothChestCategory:AddFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH, LE_INVENTORY_TYPE_ROBE_TYPE);

	local leatherCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER);
	leatherCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER, ArmorInventoryTypes);

	local leatherChestCategory = leatherCategory:FindSubCategoryByName(GetItemInventorySlotInfo(LE_INVENTORY_TYPE_CHEST_TYPE));
	leatherChestCategory:AddFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER, LE_INVENTORY_TYPE_ROBE_TYPE);

	local mailCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL);
	mailCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL, ArmorInventoryTypes);

	local mailChestCategory = mailCategory:FindSubCategoryByName(GetItemInventorySlotInfo(LE_INVENTORY_TYPE_CHEST_TYPE));
	mailChestCategory:AddFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL, LE_INVENTORY_TYPE_ROBE_TYPE);

	local plateCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE);
	plateCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE, ArmorInventoryTypes);

	local plateChestCategory = plateCategory:FindSubCategoryByName(GetItemInventorySlotInfo(LE_INVENTORY_TYPE_CHEST_TYPE));
	plateChestCategory:AddFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE, LE_INVENTORY_TYPE_ROBE_TYPE);

	armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_SHIELD);
	armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LIBRAM);
	armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_IDOL);
	armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_TOTEM);
end

do -- Containers
	local containersCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONTAINERS);
	--containersCategory:SetDetailColumnString(SLOT_ABBR);
	containersCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_CONTAINER);
end

do -- Consumables
	local consumablesCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONSUMABLES);
	consumablesCategory:AddFilter(LE_ITEM_CLASS_CONSUMABLE);
end

do -- Trade Goods
	local tradeGoodsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_TRADE_GOODS);
	tradeGoodsCategory:AddFilter(LE_ITEM_CLASS_TRADEGOODS);
end

do -- Projectile
	local projectileCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_PROJECTILE);
	projectileCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_PROJECTILE);
end

do -- Quiver
	local quiverCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_QUIVER);
	quiverCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_QUIVER);
end

do -- Recipes
	local recipesCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_RECIPES);
	recipesCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_RECIPE);
end

do -- Reagent
	local reagentCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_REAGENT);
	reagentCategory:AddFilter(LE_ITEM_CLASS_REAGENT);
end

do -- Miscellaneous
	local miscellaneousCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_MISCELLANEOUS);
	miscellaneousCategory:AddFilter(LE_ITEM_CLASS_MISCELLANEOUS);
end

do -- WoW Token
	local wowTokenCategory = AuctionFrame_CreateCategory(TOKEN_FILTER_LABEL);
	wowTokenCategory:AddFilter(ITEM_CLASS_WOW_TOKEN);
	wowTokenCategory:SetFlag("WOW_TOKEN_FLAG");
end