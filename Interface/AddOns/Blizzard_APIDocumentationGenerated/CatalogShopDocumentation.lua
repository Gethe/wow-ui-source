local CatalogShop =
{
	Name = "CatalogShop",
	Type = "System",
	Namespace = "C_CatalogShop",

	Functions =
	{
		{
			Name = "CloseCatalogShopInteraction",
			Type = "Function",
		},
		{
			Name = "GetAvailableCategoryIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "categoryIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetAvailableTransmogRaceInfos",
			Type = "Function",

			Returns =
			{
				{ Name = "raceIDs", Type = "table", InnerType = "AvailableRaceInfo", Nilable = false },
			},
		},
		{
			Name = "GetCatalogShopProductDisplayInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "catalogShopProductID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "item", Type = "CatalogShopProductDisplayInfo", Nilable = false },
			},
		},
		{
			Name = "GetCategoryInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "categoryInfo", Type = "CatalogShopCategoryInfo", Nilable = false },
			},
		},
		{
			Name = "GetCategorySectionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
				{ Name = "sectionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sectionInfo", Type = "CatalogShopSectionInfo", Nilable = false },
			},
		},
		{
			Name = "GetProductAvailabilityTimeRemainingSecs",
			Type = "Function",

			Arguments =
			{
				{ Name = "catalogShopProductID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "timeRemainingSecs", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetProductIDsForBundle",
			Type = "Function",

			Arguments =
			{
				{ Name = "bundleProductID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "childIDs", Type = "table", InnerType = "CatalogShopBundleChildInfo", Nilable = false },
			},
		},
		{
			Name = "GetProductIDsForCategorySection",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
				{ Name = "sectionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "productIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetProductInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "productInfo", Type = "CatalogShopProductInfo", Nilable = false },
			},
		},
		{
			Name = "GetProductSortOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
				{ Name = "sectionID", Type = "number", Nilable = false },
				{ Name = "productID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sortOrder", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSectionIDsForCategory",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sectionIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellVisualInfoForMount",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellVisualID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellVisualInfo", Type = "CatalogShopSpellVisualInfo", Nilable = false },
			},
		},
		{
			Name = "OpenCatalogShopInteraction",
			Type = "Function",
		},
		{
			Name = "ProductSelectedTelemetry",
			Type = "Function",

			Arguments =
			{
				{ Name = "catalogShopProductID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PurchaseProduct",
			Type = "Function",

			Arguments =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canPurchase", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CatalogShopAddPendingProduct",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_ADD_PENDING_PRODUCT",
			Payload =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopDataRefresh",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_DATA_REFRESH",
		},
		{
			Name = "CatalogShopDisabled",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_DISABLED",
		},
		{
			Name = "CatalogShopFetchFailure",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_FETCH_FAILURE",
		},
		{
			Name = "CatalogShopFetchSuccess",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_FETCH_SUCCESS",
		},
		{
			Name = "CatalogShopOpenSimpleCheckout",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_OPEN_SIMPLE_CHECKOUT",
			Payload =
			{
				{ Name = "checkoutID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopPmtImageDownloaded",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_PMT_IMAGE_DOWNLOADED",
			Payload =
			{
				{ Name = "catalogProductID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopPurchaseSuccess",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_PURCHASE_SUCCESS",
			Payload =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopRemovePendingProduct",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_REMOVE_PENDING_PRODUCT",
			Payload =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopSpecificProductRefresh",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_SPECIFIC_PRODUCT_REFRESH",
			Payload =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "AvailableRaceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "raceID", Type = "number", Nilable = false },
				{ Name = "displayName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CatalogShopBundleChildInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "childProductID", Type = "number", Nilable = false },
				{ Name = "displayOrder", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopCategoryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "displayName", Type = "string", Nilable = false },
				{ Name = "iconTexture", Type = "string", Nilable = false },
				{ Name = "linkTag", Type = "string", Nilable = false },
				{ Name = "isDisabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CatalogShopProductDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "defaultPreviewModelSceneID", Type = "number", Nilable = false },
				{ Name = "defaultCardModelSceneID", Type = "number", Nilable = false },
				{ Name = "defaultWideCardModelSceneID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "overridePreviewModelSceneID", Type = "number", Nilable = true },
				{ Name = "overrideCardModelSceneID", Type = "number", Nilable = true },
				{ Name = "overrideWideCardModelSceneID", Type = "number", Nilable = true },
				{ Name = "creatureDisplayInfoIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "spellVisualIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "mainHandItemModifiedAppearanceID", Type = "number", Nilable = true },
				{ Name = "offHandItemModifiedAppearanceID", Type = "number", Nilable = true },
				{ Name = "itemModifiedAppearanceIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "iconFileDataID", Type = "number", Nilable = true },
				{ Name = "iconTextureKit", Type = "textureKit", Nilable = true },
				{ Name = "productType", Type = "string", Nilable = true },
				{ Name = "itemDescription", Type = "string", Nilable = true },
				{ Name = "hasUnknownLicense", Type = "bool", Nilable = false },
				{ Name = "otherProductImageAtlasName", Type = "string", Nilable = true },
				{ Name = "otherProductPMTURL", Type = "string", Nilable = true },
				{ Name = "customLoopingSoundStart", Type = "number", Nilable = true },
				{ Name = "customLoopingSoundMiddle", Type = "number", Nilable = true },
				{ Name = "customLoopingSoundEnd", Type = "number", Nilable = true },
				{ Name = "specialActorID_1", Type = "number", Nilable = true },
				{ Name = "specialActorID_2", Type = "number", Nilable = true },
				{ Name = "specialActorID_3", Type = "number", Nilable = true },
				{ Name = "specialActorID_4", Type = "number", Nilable = true },
				{ Name = "specialActorID_5", Type = "number", Nilable = true },
				{ Name = "subTitleID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CatalogShopProductInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "catalogShopProductID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "iconTexture", Type = "string", Nilable = false },
				{ Name = "productCardType", Type = "number", Nilable = false },
				{ Name = "purchased", Type = "bool", Nilable = false },
				{ Name = "isPurchasePending", Type = "bool", Nilable = false },
				{ Name = "refundable", Type = "bool", Nilable = false },
				{ Name = "price", Type = "string", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "mountID", Type = "number", Nilable = false },
				{ Name = "mountTypeName", Type = "string", Nilable = false },
				{ Name = "speciesID", Type = "number", Nilable = false },
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
				{ Name = "subItems", Type = "table", InnerType = "CatalogShopSubItemInfo", Nilable = false },
				{ Name = "subItemsLoaded", Type = "bool", Nilable = false },
				{ Name = "backgroundTexture", Type = "string", Nilable = false },
				{ Name = "hasTimeRemaining", Type = "bool", Nilable = false },
				{ Name = "optionalWideCardBackgroundTexture", Type = "string", Nilable = true },
				{ Name = "isBundle", Type = "bool", Nilable = false },
				{ Name = "bundleChildrenSize", Type = "number", Nilable = false },
				{ Name = "licenseTermType", Type = "number", Nilable = false },
				{ Name = "licenseTermDuration", Type = "number", Nilable = false },
				{ Name = "virtualCurrencies", Type = "table", InnerType = "CatalogShopVirtualCurrency", Nilable = false },
			},
		},
		{
			Name = "CatalogShopSectionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "displayName", Type = "string", Nilable = false },
				{ Name = "parentCatalogShopCategoryInfoID", Type = "number", Nilable = true },
				{ Name = "cardType", Type = "string", Nilable = true },
				{ Name = "scrollGridSize", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CatalogShopSpellVisualInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "animID", Type = "number", Nilable = true },
				{ Name = "spellVisualKitID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CatalogShopSubItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = false },
				{ Name = "invType", Type = "string", Nilable = false },
				{ Name = "quality", Type = "ItemQuality", Nilable = false },
			},
		},
		{
			Name = "CatalogShopVirtualCurrency",
			Type = "Structure",
			Fields =
			{
				{ Name = "amount", Type = "number", Nilable = false },
				{ Name = "currencyCode", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CatalogShop);