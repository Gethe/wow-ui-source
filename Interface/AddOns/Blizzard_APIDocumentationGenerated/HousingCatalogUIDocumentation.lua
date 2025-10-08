local HousingCatalogUI =
{
	Name = "HousingCatalogUI",
	Type = "System",
	Namespace = "C_HousingCatalog",

	Functions =
	{
		{
			Name = "CanDestroyEntry",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "entryID", Type = "HousingCatalogEntryID", Nilable = false },
			},

			Returns =
			{
				{ Name = "canDelete", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CreateCatalogSearcher",
			Type = "Function",

			Returns =
			{
				{ Name = "searcher", Type = "HousingCatalogSearcher", Nilable = false },
			},
		},
		{
			Name = "DeletePreviewCartDecor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "DestroyEntry",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "entryID", Type = "HousingCatalogEntryID", Nilable = false },
				{ Name = "destroyAll", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAllFilterTagGroups",
			Type = "Function",

			Returns =
			{
				{ Name = "filterTagGroups", Type = "table", InnerType = "HousingCatalogFilterTagGroupInfo", Nilable = false },
			},
		},
		{
			Name = "GetCatalogCategoryInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "HousingCatalogCategoryInfo", Nilable = true },
			},
		},
		{
			Name = "GetCatalogEntryInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "entryID", Type = "HousingCatalogEntryID", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "HousingCatalogEntryInfo", Nilable = true },
			},
		},
		{
			Name = "GetCatalogSubcategoryInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "subcategoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "HousingCatalogSubcategoryInfo", Nilable = true },
			},
		},
		{
			Name = "GetFeaturedBundles",
			Type = "Function",

			Returns =
			{
				{ Name = "bundleInfos", Type = "table", InnerType = "HousingBundleInfo", Nilable = false },
			},
		},
		{
			Name = "GetFeaturedDecor",
			Type = "Function",

			Returns =
			{
				{ Name = "entryInfos", Type = "table", InnerType = "HousingFeaturedDecorEntry", Nilable = false },
			},
		},
		{
			Name = "IsPreviewCartItemShown",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isShown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestHousingMarketInfoRefresh",
			Type = "Function",
		},
		{
			Name = "SearchCatalogCategories",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "searchParams", Type = "HousingCategorySearchInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "categoryIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "SearchCatalogSubcategories",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "searchParams", Type = "HousingCategorySearchInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "subcategoryIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "SetPreviewCartItemShown",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "shown", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingCatalogCategoryUpdated",
			Type = "Event",
			LiteralName = "HOUSING_CATALOG_CATEGORY_UPDATED",
			Payload =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingCatalogSearcherReleased",
			Type = "Event",
			LiteralName = "HOUSING_CATALOG_SEARCHER_RELEASED",
			Payload =
			{
				{ Name = "searcher", Type = "HousingCatalogSearcher", Nilable = false },
			},
		},
		{
			Name = "HousingCatalogSubcategoryUpdated",
			Type = "Event",
			LiteralName = "HOUSING_CATALOG_SUBCATEGORY_UPDATED",
			Payload =
			{
				{ Name = "subcategoryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingDecorAddToPreviewList",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_ADD_TO_PREVIEW_LIST",
			Payload =
			{
				{ Name = "previewItemData", Type = "HousingPreviewItemData", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPreviewListRemoveFromWorld",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PREVIEW_LIST_REMOVE_FROM_WORLD",
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPreviewListUpdated",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PREVIEW_LIST_UPDATED",
		},
		{
			Name = "HousingStorageEntryUpdated",
			Type = "Event",
			LiteralName = "HOUSING_STORAGE_ENTRY_UPDATED",
			Payload =
			{
				{ Name = "entryID", Type = "HousingCatalogEntryID", Nilable = false },
			},
		},
		{
			Name = "HousingStorageUpdated",
			Type = "Event",
			LiteralName = "HOUSING_STORAGE_UPDATED",
		},
	},

	Tables =
	{
		{
			Name = "HousingBundleDecorEntryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "decorID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingBundleInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "price", Type = "number", Nilable = false },
				{ Name = "productID", Type = "number", Nilable = false },
				{ Name = "decorEntries", Type = "table", InnerType = "HousingBundleDecorEntryInfo", Nilable = false },
			},
		},
		{
			Name = "HousingCatalogCategoryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "icon", Type = "textureAtlas", Nilable = true },
				{ Name = "subcategoryIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "anyOwnedEntries", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingCatalogEntryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "entryID", Type = "HousingCatalogEntryID", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "asset", Type = "ModelAsset", Nilable = true },
				{ Name = "iconTexture", Type = "FileAsset", Nilable = true },
				{ Name = "iconAtlas", Type = "textureAtlas", Nilable = true },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "showQuantity", Type = "bool", Nilable = false },
				{ Name = "categoryIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "subcategoryIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "dataTagsByID", Type = "LuaValueVariant", Nilable = false },
				{ Name = "size", Type = "HousingCatalogEntrySize", Nilable = false },
				{ Name = "placementCost", Type = "number", Nilable = false },
				{ Name = "numPlaced", Type = "number", Nilable = false },
				{ Name = "numStored", Type = "number", Nilable = false },
				{ Name = "isAllowedOutdoors", Type = "bool", Nilable = false },
				{ Name = "isAllowedIndoors", Type = "bool", Nilable = false },
				{ Name = "canCustomize", Type = "bool", Nilable = false },
				{ Name = "customizations", Type = "table", InnerType = "cstring", Nilable = false },
				{ Name = "marketInfo", Type = "HousingMarketInfo", Nilable = true },
				{ Name = "remainingRedeemable", Type = "number", Nilable = false },
				{ Name = "firstAcquisitionBonus", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingCatalogSubcategoryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "parentCategoryID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "icon", Type = "textureAtlas", Nilable = true },
				{ Name = "anyOwnedEntries", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingCategorySearchInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "withOwnedEntriesOnly", Type = "bool", Nilable = false, Default = false },
				{ Name = "includeFeaturedCategory", Type = "bool", Nilable = false, Default = false },
				{ Name = "editorModeContext", Type = "HouseEditorMode", Nilable = true },
			},
		},
		{
			Name = "HousingFeaturedDecorEntry",
			Type = "Structure",
			Fields =
			{
				{ Name = "entryID", Type = "HousingCatalogEntryID", Nilable = false },
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingMarketInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "price", Type = "number", Nilable = false },
				{ Name = "productID", Type = "number", Nilable = false },
				{ Name = "bundleIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "HousingPreviewItemData",
			Type = "Structure",
			Fields =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = true },
				{ Name = "isBundleParent", Type = "bool", Nilable = false },
				{ Name = "isBundleChild", Type = "bool", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "decorEntryID", Type = "HousingCatalogEntryID", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "price", Type = "number", Nilable = false },
				{ Name = "salePrice", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingCatalogUI);