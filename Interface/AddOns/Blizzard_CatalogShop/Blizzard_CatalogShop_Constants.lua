

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

	Default =
	{
		PreviewBackgroundTexture = "shop-bg-map-blue",
	},

	CardTemplate =
	{
		Header = "CatalogShopSectionHeaderTemplate",
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

		Details = "DetailsCatalogShopProductCardTemplate",
		DetailsServices = "DetailsCatalogShopServicesCardTemplate",
		DetailsSubscription = "DetailsCatalogShopSubscriptionCardTemplate",
		DetailsGameTime = "DetailsCatalogShopGameTimeCardTemplate",
		DetailsTender = "DetailsCatalogShopTenderCardTemplate",
		DetailsToys = "DetailsCatalogShopToysCardTemplate",
		DetailsAccess = "DetailsCatalogShopAccessCardTemplate",
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
		Subscription = "Subscription",
		TradersTenders = "Tender",
		Decor = "Decor",
		Access = "Access",
		GameTime = "Game Time",
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
		SpellVisualID = 173390,
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
	}
};
