

CatalogShopConstants =
{
	ScrollViewType =
	{
		List = 1,
		Grid = 2,
	},

	ScrollViewElementType =
	{
		Header = 1,
		Product = 2,
	},

	DefaultWoWAtlas = "tokens-wow-generic-large";

	MysteryTypes =
	{
		Pet = "mystery-pet",
		Mount = "mystery-mount",
	},

	Default =
	{
		PreviewBackgroundTexture = "shop-bg-map-blue",
	},

	CardTemplate =
	{
		Header = "CatalogShopSectionHeaderTemplate",
		HeaderPersonalized = "CatalogShopSectionHeaderOptOutLinkTemplate",
		HeaderSectionGroupBYOB = "CatalogShopSectionHeaderTemplate",
		Wide = "WideCatalogShopProductCardTemplate",
		WideCardToken = "WideWoWTokenCatalogShopCardTemplate",
		WideCardSubscription = "WideSubscriptionCatalogShopCardTemplate",
		WideCardGameTime = "WideGameTimeCatalogShopCardTemplate",

		Small = "SmallCatalogShopProductCardTemplate",
		SmallServices = "SmallCatalogShopServicesCardTemplate",
		SmallSubscription = "SmallCatalogShopSubscriptionCardTemplate",
		SmallGameTime = "SmallCatalogShopGameTimeCardTemplate",
		SmallTender = "SmallCatalogShopTenderCardTemplate",
		SmallToys = "SmallCatalogShopToysCardTemplate",
		SmallAccess = "SmallCatalogShopAccessCardTemplate",
		SmallDecor = "SmallCatalogShopDecorCardTemplate",
		SmallRoom = "SmallCatalogShopRoomCardTemplate",
		SmallExteriorType = "SmallCatalogShopExteriorTypeCardTemplate",
		SmallBYOB = "SmallCatalogShopBYOBCardTemplate",

		Details = "DetailsCatalogShopProductCardTemplate",
		DetailsServices = "DetailsCatalogShopServicesCardTemplate",
		DetailsSubscription = "DetailsCatalogShopSubscriptionCardTemplate",
		DetailsGameTime = "DetailsCatalogShopGameTimeCardTemplate",
		DetailsTender = "DetailsCatalogShopTenderCardTemplate",
		DetailsToys = "DetailsCatalogShopToysCardTemplate",
		DetailsAccess = "DetailsCatalogShopAccessCardTemplate",
		DetailsDecor = "DetailsCatalogShopDecorCardTemplate",
		DetailsRoom = "DetailsCatalogShopRoomCardTemplate",
		DetailsExteriorType = "DetailsCatalogShopExteriorTypeCardTemplate"
	},

	ModelSceneContext =
	{
		SmallCard = 1,
		WideCard = 2,
		PreviewScene = 3,
	},

	ScreenPadding =
	{
		Horizontal = 100,
		Vertical = 100,
	},

	DefaultActorTag =
	{
		Pet = "pet",
		Mount = "mount",
		Toy = "actor",
		Celebrate = "fanfare",
		Transmog = "transmog",
		Decor = "decor",
	},

	ProductType =
	{
		Pet = "Pet",
		Mount = "Mount",
		Toy = "Toy",
		Transmog = "Transmog",
		Services = "Services",
		Token = "WoW Token",
		Bundle = "Bundle",
		BYOB = "BYOB",
		Subscription = "Subscription",
		TradersTenders = "Tender",
		Decor = "Decor",
		Access = "Access",
		GameTime = "Game Time",
		Room = "House Room",
		HousingExteriorType = "House Exterior Type",
	},

	-- These names match up with names in CatalogShop_C::GetOtherFlavorGameData
	GameTypes =
	{
		Classic = "classic",
		Modern = "modern",
	},

	GameTypeGlobalStringTag =
	{
		Classic = CATALOG_SHOP_WOW_FLAVOR_CLASSIC,
		Modern = CATALOG_SHOP_WOW_FLAVOR_MODERN,
	},

	ShopGlobalStringTag =
	{
		MissingLicenseCaptionText = CATALOG_SHOP_MISSING_LICENSE_ITEM,
	},

	DefaultCameraTag =
	{
		Primary = "primary",
	},

	DefaultAnimID =
	{
		MountSelfIdle = 618,
		MountSpecialAnimKit = 1371,
		PetDefault = 23877,
	},

	Celebrate =
	{
		CreatureID = 27823,
		SpellVisualID = 259750,
	},

	NoResults =
	{
		BackgroundTexture = "shop-bg-map-blue",
	},

	LicenseTermTypes =
	{
		NotApplicable = 0,
		Days = 1,
		Years = 2,
		Fixed = 3,
		Hours = 4,
		Minutes = 5,
		Weeks = 6,
		Months = 7,
	},

	CategoryLinks =
	{
		Pets = "pets",
		Mounts = "mounts",
		Transmogs = "transmogs",
		Subscriptions = "subscriptions",
		GameTime = "gametimeoffers",
		GameUpgrades = "game upgrades",
		Services = "services",
		Featured = "featured",
		Housing = "housing",
	},

	VCIcon =
	{
		Default = "plunderstorm-icon-kills",
		Hearthsteel = "hearthsteel-icon-32x32",
		Talebound = "talebound-icon-currency"
	}
};

BYOBInterface =
{
	-- indexed by selectionGroupIndex, then by productID,
	-- returns either true or false or nil, depending on if the child product in this BYOB Bundle
	-- has been checked by the Player
	SelectionGroupChoices = {};

	-- indexed by selectionGroupIndex, stores the required quantites for this BYOB Bundle
	SelectionGroupRequiredQuantities = {};

};

local function BYOB_ResetData()
	BYOBInterface.SelectionGroupChoices = {};
	BYOBInterface.SelectionGroupRequiredQuantities = {};
end

-- Counts products in the selection group that are not hidden and not fully owned.
local function BYOB_GetAvailableChoiceCount(selectionGroupInfo)
	local availableCount = 0;
	for _, childInfo in ipairs(selectionGroupInfo.products) do
		local childProductInfo = CatalogShopUtil.GetProductInfo(childInfo.childProductID);
		if childProductInfo and (not childProductInfo.isHidden) and (not childProductInfo.isFullyOwned) then
			availableCount = availableCount + 1;
		end
	end
	return availableCount;
end

local function BYOB_GetSelectionGroupChoicesForIndex(selectionGroupIndex)
	assertsafe(selectionGroupIndex, "selectionGroupIndex is required.");
	if BYOBInterface.SelectionGroupChoices[selectionGroupIndex] then
		return BYOBInterface.SelectionGroupChoices[selectionGroupIndex];
	end
	BYOBInterface.SelectionGroupChoices[selectionGroupIndex] = {};
	return BYOBInterface.SelectionGroupChoices[selectionGroupIndex];
end

local function BYOB_GetSelectionGroupChoiceRequiredQuantity(selectionGroupIndex)
	assertsafe(selectionGroupIndex, "selectionGroupIndex is required.");
	return BYOBInterface.SelectionGroupRequiredQuantities[selectionGroupIndex] or 0;
end

local function BYOB_IsProductChecked(selectionGroupIndex, productID)
	assertsafe(selectionGroupIndex, "selectionGroupIndex is required.");
	assertsafe(productID, "productID is required.");
	local selectionGroupChoices = BYOB_GetSelectionGroupChoicesForIndex(selectionGroupIndex);
	return selectionGroupChoices[productID];
end

local function BYOB_TotalProductsChecked(selectionGroupIndex)
	assertsafe(selectionGroupIndex, "selectionGroupIndex is required.");
	local selectionGroupChoices = BYOB_GetSelectionGroupChoicesForIndex(selectionGroupIndex);
	local count = 0;
	for _, isChecked in pairs(selectionGroupChoices) do
		if isChecked then
			count = count + 1;
		end
	end
	return count;
end

local function BYOB_ChoicesCompleted(selectionGroupIndex)
	assertsafe(selectionGroupIndex, "selectionGroupIndex is required.");
	local requiredQuantity = BYOB_GetSelectionGroupChoiceRequiredQuantity(selectionGroupIndex);

	local count = BYOB_TotalProductsChecked(selectionGroupIndex);
	return count == requiredQuantity;
end

local function BYOB_AllChoicesCompleted()
	local requiredQuantity = 0;
	local count = 0;
	for index, selectionGroupRequiredQuantities in pairs(BYOBInterface.SelectionGroupRequiredQuantities) do
		requiredQuantity = requiredQuantity + selectionGroupRequiredQuantities;
		count = count + BYOB_TotalProductsChecked(index);
	end
	return count == requiredQuantity;
end

local function BYOB_SetProductChoiceChecked(selectionGroupIndex, productID, isChecked)
	assertsafe(selectionGroupIndex, "selectionGroupIndex is required.");
	assertsafe(productID, "productID is required.");
	local selectionGroupChoices = BYOB_GetSelectionGroupChoicesForIndex(selectionGroupIndex);
	selectionGroupChoices[productID] = isChecked;
end

local function BYOB_SetSelectionGroupChoiceRequiredQuantity(selectionGroupIndex, requiredQuantity)
	assertsafe(selectionGroupIndex, "selectionGroupIndex is required.");
	BYOBInterface.SelectionGroupRequiredQuantities[selectionGroupIndex] = requiredQuantity;
end

local function BYOB_IsProductChoiceEnabled(selectionGroupIndex, productID)
	assertsafe(selectionGroupIndex, "selectionGroupIndex is required.");
	assertsafe(productID, "productID is required.");

	local isEnabled = true;
	local isChecked = BYOB_IsProductChecked(selectionGroupIndex, productID);
	if BYOB_ChoicesCompleted(selectionGroupIndex) then
		isEnabled = isChecked;
	end
	return isEnabled;
end

BYOBInterface.ResetData = BYOB_ResetData;
BYOBInterface.GetAvailableChoiceCount = BYOB_GetAvailableChoiceCount;
BYOBInterface.IsProductChecked = BYOB_IsProductChecked;
BYOBInterface.TotalProductsChecked = BYOB_TotalProductsChecked;
BYOBInterface.ChoicesCompleted = BYOB_ChoicesCompleted;
BYOBInterface.AllChoicesCompleted = BYOB_AllChoicesCompleted;
BYOBInterface.SetProductChoiceChecked = BYOB_SetProductChoiceChecked;
BYOBInterface.SetSelectionGroupChoiceRequiredQuantity = BYOB_SetSelectionGroupChoiceRequiredQuantity;
BYOBInterface.GetSelectionGroupChoiceRequiredQuantity = BYOB_GetSelectionGroupChoiceRequiredQuantity;
BYOBInterface.IsProductChoiceEnabled = BYOB_IsProductChoiceEnabled;
