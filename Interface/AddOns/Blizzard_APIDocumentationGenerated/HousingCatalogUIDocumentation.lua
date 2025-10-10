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
			Name = "DestroyEntry",
			Type = "Function",

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
			Name = "RequestHousingMarketInfoRefresh",
			Type = "Function",
		},
		{
			Name = "SearchCatalogCategories",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "searchParams", Type = "HousingCategorySearchInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "subcategoryIDs", Type = "table", InnerType = "number", Nilable = false },
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
	},
};

APIDocumentation:AddDocumentationTable(HousingCatalogUI);