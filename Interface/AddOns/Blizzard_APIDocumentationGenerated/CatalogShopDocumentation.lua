local CatalogShop =
{
	Name = "CatalogShop",
	Type = "System",
	Namespace = "C_CatalogShop",
	Environment = "All",

	Functions =
	{
		{
			Name = "BulkPurchaseProducts",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "productIDs", Type = "table", InnerType = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canPurchaseProducts", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CloseCatalogShopInteraction",
			Type = "Function",
		},
		{
			Name = "ConfirmHousingPurchase",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "productIDs", Type = "table", InnerType = "number", Nilable = false },
			},
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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetFailureInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "errorResultEnum", Type = "StoreError", Nilable = true },
				{ Name = "errorResultRaw", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetFirstCategoryByProductID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "categoryInfo", Type = "CatalogShopCategoryInfo", Nilable = true },
			},
		},
		{
			Name = "GetNewProducts",
			Type = "Function",

			Returns =
			{
				{ Name = "newProducts", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetProductAvailabilityTimeRemainingSecs",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetProductIDsForCategory",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "productIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetProductIDsForCategorySection",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "productInfo", Type = "CatalogShopProductInfo", Nilable = true },
			},
		},
		{
			Name = "GetProductSortOrder",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetRefundableDecors",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "productIDOpt", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "refundableDecorInfos", Type = "table", InnerType = "RefundableDecorInfo", Nilable = false },
			},
		},
		{
			Name = "GetSectionIDsForCategory",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetVirtualCurrencyBalance",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "currencyCode", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "balance", Type = "string", Nilable = true },
			},
		},
		{
			Name = "HasNewProducts",
			Type = "Function",

			Returns =
			{
				{ Name = "hasNewProducts", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsShop2Enabled",
			Type = "Function",

			Returns =
			{
				{ Name = "value", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "OnLegalDisclaimerClicked",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "catalogShopProductID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "OpenCatalogShopInteractionFromHouse",
			Type = "Function",

			Returns =
			{
				{ Name = "shoppingSessionUUIDStr", Type = "string", Nilable = false },
			},
		},
		{
			Name = "OpenCatalogShopInteractionFromShop",
			Type = "Function",

			Returns =
			{
				{ Name = "shoppingSessionUUIDStr", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ProductDisplayedTelemetry",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "categoryId", Type = "number", Nilable = false },
				{ Name = "sectionId", Type = "number", Nilable = false },
				{ Name = "catalogShopProductID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ProductSelectedTelemetry",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "categoryId", Type = "number", Nilable = false },
				{ Name = "sectionId", Type = "number", Nilable = false },
				{ Name = "catalogShopProductID", Type = "number", Nilable = false },
				{ Name = "wasCodeSelection", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PurchaseProduct",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canPurchase", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RefreshRefundableDecors",
			Type = "Function",
		},
		{
			Name = "RefreshVirtualCurrencyBalance",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "currencyCode", Type = "string", Nilable = false },
			},
		},
		{
			Name = "StartHousingVCPurchaseConfirmation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "BulkPurchaseResultReceived",
			Type = "Event",
			LiteralName = "BULK_PURCHASE_RESULT_RECEIVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "BulkPurchaseResult", Nilable = false },
				{ Name = "productResults", Type = "table", InnerType = "BulkPurchaseIndividualProductResult", Nilable = false },
			},
		},
		{
			Name = "CatalogShopAddPendingProduct",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_ADD_PENDING_PRODUCT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopDataRefresh",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_DATA_REFRESH",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "shoppingSessionUUIDStr", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CatalogShopDisabled",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_DISABLED",
			SynchronousEvent = true,
		},
		{
			Name = "CatalogShopFetchFailure",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_FETCH_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "shoppingSessionUUIDStr", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CatalogShopFetchSuccess",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_FETCH_SUCCESS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "shoppingSessionUUIDStr", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CatalogShopOpenSimpleCheckout",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_OPEN_SIMPLE_CHECKOUT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "checkoutID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopPmtImageDownloaded",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_PMT_IMAGE_DOWNLOADED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "catalogProductID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopPurchaseSuccess",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_PURCHASE_SUCCESS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopRebuildScrollBox",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_REBUILD_SCROLL_BOX",
			SynchronousEvent = true,
		},
		{
			Name = "CatalogShopRefundableDecorsUpdated",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_REFUNDABLE_DECORS_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "CatalogShopRemovePendingProduct",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_REMOVE_PENDING_PRODUCT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopResultError",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_RESULT_ERROR",
			SynchronousEvent = true,
		},
		{
			Name = "CatalogShopSpecificProductRefresh",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_SPECIFIC_PRODUCT_REFRESH",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CatalogShopVirtualCurrencyBalanceUpdate",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_VIRTUAL_CURRENCY_BALANCE_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "currencyCode", Type = "string", Nilable = false },
				{ Name = "balance", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CatalogShopVirtualCurrencyBalanceUpdateFailure",
			Type = "Event",
			LiteralName = "CATALOG_SHOP_VIRTUAL_CURRENCY_BALANCE_UPDATE_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "currencyCode", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetSeenProducts",
			Type = "Event",
			LiteralName = "SET_SEEN_PRODUCTS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "productIds", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "ShowNewProductNotification",
			Type = "Event",
			LiteralName = "SHOW_NEW_PRODUCT_NOTIFICATION",
			SynchronousEvent = true,
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
			Name = "BulkPurchaseIndividualProductResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "recordId", Type = "number", Nilable = false },
				{ Name = "parentProductId", Type = "number", Nilable = true },
				{ Name = "entitlementId", Type = "string", Nilable = false },
				{ Name = "externalTransactionId", Type = "string", Nilable = false },
				{ Name = "status", Type = "SimpleOrderStatus", Nilable = false },
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
				{ Name = "showPersistentRefundButton", Type = "bool", Nilable = false },
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
				{ Name = "otherProductGameTitleBaseTag", Type = "string", Nilable = true },
				{ Name = "otherProductGameType", Type = "string", Nilable = true },
				{ Name = "customLoopingSoundStart", Type = "number", Nilable = true },
				{ Name = "customLoopingSoundMiddle", Type = "number", Nilable = true },
				{ Name = "customLoopingSoundEnd", Type = "number", Nilable = true },
				{ Name = "specialActorID_1", Type = "string", Nilable = true },
				{ Name = "specialActorID_2", Type = "string", Nilable = true },
				{ Name = "specialActorID_3", Type = "string", Nilable = true },
				{ Name = "specialActorID_4", Type = "string", Nilable = true },
				{ Name = "specialActorID_5", Type = "string", Nilable = true },
				{ Name = "gameFlavorID", Type = "number", Nilable = true },
				{ Name = "decorFileDataID", Type = "number", Nilable = true },
				{ Name = "quantity", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CatalogShopProductInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "catalogShopProductID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "type", Type = "string", Nilable = true },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "iconTexture", Type = "string", Nilable = false },
				{ Name = "isFullyOwned", Type = "bool", Nilable = false },
				{ Name = "isPurchasePending", Type = "bool", Nilable = false },
				{ Name = "refundable", Type = "bool", Nilable = false },
				{ Name = "price", Type = "string", Nilable = false },
				{ Name = "originalPrice", Type = "string", Nilable = false },
				{ Name = "discountPercentage", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "mountID", Type = "number", Nilable = false },
				{ Name = "mountTypeName", Type = "string", Nilable = false },
				{ Name = "speciesID", Type = "number", Nilable = false },
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
				{ Name = "subItems", Type = "table", InnerType = "CatalogShopSubItemInfo", Nilable = false },
				{ Name = "subItemsLoaded", Type = "bool", Nilable = false },
				{ Name = "backgroundTexture", Type = "string", Nilable = false },
				{ Name = "foregroundTexture", Type = "string", Nilable = true },
				{ Name = "smallCardBGTexture", Type = "string", Nilable = true },
				{ Name = "smallCardFGTexture", Type = "string", Nilable = true },
				{ Name = "wideCardBGTexture", Type = "string", Nilable = true },
				{ Name = "wideCardFGTexture", Type = "string", Nilable = true },
				{ Name = "previewIconTexture", Type = "string", Nilable = true },
				{ Name = "optionalWideCardBackgroundTexture", Type = "string", Nilable = true },
				{ Name = "isBundle", Type = "bool", Nilable = false },
				{ Name = "bundleChildrenSize", Type = "number", Nilable = false },
				{ Name = "licenseTermType", Type = "number", Nilable = false },
				{ Name = "licenseTermDuration", Type = "number", Nilable = false },
				{ Name = "virtualCurrencies", Type = "table", InnerType = "CatalogShopVirtualCurrency", Nilable = false },
				{ Name = "isHidden", Type = "bool", Nilable = false },
				{ Name = "hasPendingOrders", Type = "bool", Nilable = false },
				{ Name = "numBundleDetailCards", Type = "number", Nilable = false },
				{ Name = "isDynamicallyDiscounted", Type = "bool", Nilable = false },
				{ Name = "shouldShowOriginalPrice", Type = "bool", Nilable = false },
				{ Name = "wideCardBGOverrideProductURL", Type = "string", Nilable = true },
				{ Name = "consumableQuantity", Type = "number", Nilable = true },
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
		{
			Name = "RefundableDecorInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "timeRemainingSeconds", Type = "time_t", Nilable = false },
				{ Name = "standaloneDecorProductID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CatalogShop);