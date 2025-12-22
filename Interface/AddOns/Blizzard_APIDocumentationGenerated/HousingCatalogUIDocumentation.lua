local HousingCatalogUI =
{
	Name = "HousingCatalogUI",
	Type = "System",
	Namespace = "C_HousingCatalog",
	Environment = "All",

	Functions =
	{
		{
			Name = "CanDestroyEntry",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns false if the entry can't be deleted from storage; Typically these types of entries are something that doesn't count towards the max storage limit" },

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
			Documentation = { "Creates a new instance of a HousingCatalog searcher; This can be used to asynchronously search/filter the HousingCatalog without affecting/being restricted by the filter state of other Housing Catalog UI displays" },

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
			Documentation = { "Attempt to delete the entry from storage" },

			Arguments =
			{
				{ Name = "entryID", Type = "HousingCatalogEntryID", Nilable = false },
				{ Name = "destroyAll", Type = "bool", Nilable = false, Documentation = { "If true, deletes all entries within the stack; If false, will only delete one" } },
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
			Name = "GetBundleInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "bundleCatalogShopProductID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "bundleInfo", Type = "HousingBundleInfo", Nilable = true },
			},
		},
		{
			Name = "GetCartSizeLimit",
			Type = "Function",

			Returns =
			{
				{ Name = "cartSizeLimit", Type = "number", Nilable = false },
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
			Name = "GetCatalogEntryInfoByItem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false, Documentation = { "ItemID, name, or link of an item that grants/corresponds to a particular type of housing catalog object (ex: decor)" } },
				{ Name = "tryGetOwnedInfo", Type = "bool", Nilable = false, Documentation = { "If true and player owns this entry, will return an 'Owned' subtype, with owned quantity info; Otherwise, will be an Unowned subtype with only basic static info" } },
			},

			Returns =
			{
				{ Name = "info", Type = "HousingCatalogEntryInfo", Nilable = true },
			},
		},
		{
			Name = "GetCatalogEntryInfoByRecordID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "entryType", Type = "HousingCatalogEntryType", Nilable = false },
				{ Name = "recordID", Type = "number", Nilable = false },
				{ Name = "tryGetOwnedInfo", Type = "bool", Nilable = false, Documentation = { "If true and player owns this entry, will return an 'Owned' subtype, with owned quantity info; Otherwise, will be an Unowned subtype with only basic static info" } },
			},

			Returns =
			{
				{ Name = "info", Type = "HousingCatalogEntryInfo", Nilable = true },
			},
		},
		{
			Name = "GetCatalogEntryRefundTimeStampByRecordID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "entryType", Type = "HousingCatalogEntryType", Nilable = false },
				{ Name = "recordID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "refundTimeStamp", Type = "time_t", Nilable = true },
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
			Name = "GetDecorMaxOwnedCount",
			Type = "Function",
			Documentation = { "Returns the maximum total number of decor that can be in storage/in the house chest; Note that not all decor entries in storage count towards this limit (see GetDecorTotalOwnedCount)" },

			Returns =
			{
				{ Name = "maxOwnedCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDecorTotalOwnedCount",
			Type = "Function",

			Returns =
			{
				{ Name = "totalOwnedCount", Type = "number", Nilable = false, Documentation = { "The total number of owned decor in storage, including both exempt and non-exempt decor" } },
				{ Name = "exemptDecorCount", Type = "number", Nilable = false, Documentation = { "The number of decor that do not count against the max storage limit" } },
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
			Name = "HasFeaturedEntries",
			Type = "Function",

			Returns =
			{
				{ Name = "hasEntries", Type = "bool", Nilable = false },
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
			Name = "PromotePreviewDecor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "decorID", Type = "number", Nilable = false },
				{ Name = "previewDecorGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestHousingMarketInfoRefresh",
			Type = "Function",
		},
		{
			Name = "RequestHousingMarketRefundInfo",
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
			UniqueEvent = true,
			Payload =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingCatalogSubcategoryUpdated",
			Type = "Event",
			LiteralName = "HOUSING_CATALOG_SUBCATEGORY_UPDATED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "subcategoryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingDecorAddToPreviewList",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_ADD_TO_PREVIEW_LIST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "previewItemData", Type = "HousingPreviewItemData", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPreviewListRemoveFromWorld",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PREVIEW_LIST_REMOVE_FROM_WORLD",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPreviewListUpdated",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PREVIEW_LIST_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "HousingRefundListUpdated",
			Type = "Event",
			LiteralName = "HOUSING_REFUND_LIST_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "HousingStorageEntryUpdated",
			Type = "Event",
			LiteralName = "HOUSING_STORAGE_ENTRY_UPDATED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "entryID", Type = "HousingCatalogEntryID", Nilable = false },
			},
		},
		{
			Name = "HousingStorageUpdated",
			Type = "Event",
			LiteralName = "HOUSING_STORAGE_UPDATED",
			UniqueEvent = true,
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
				{ Name = "originalPrice", Type = "number", Nilable = true },
				{ Name = "productID", Type = "number", Nilable = false },
				{ Name = "decorEntries", Type = "table", InnerType = "HousingBundleDecorEntryInfo", Nilable = false },
				{ Name = "canPreview", Type = "bool", Nilable = false, Default = true, Documentation = { "Bundles containing non-decor items cannot be previewed" } },
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
				{ Name = "anyOwnedEntries", Type = "bool", Nilable = false, Documentation = { "True if the player owns anything that falls under this category" } },
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
				{ Name = "asset", Type = "ModelAsset", Nilable = true, Documentation = { "3D model asset for displaying in the UI; May be nil if the entry doesn't have a model, or has one that isn't supported by UI model scenes" } },
				{ Name = "iconTexture", Type = "FileAsset", Nilable = true, Documentation = { "Entry icon in the form of a texture file; Catalog entries should have either this OR an iconAtlas set" } },
				{ Name = "iconAtlas", Type = "textureAtlas", Nilable = true, Documentation = { "Entry icon in the form a texture atlas element; Catalog entries should have either this OR an iconTexture set" } },
				{ Name = "uiModelSceneID", Type = "number", Nilable = true, Documentation = { "Specific UI model scene ID to use when previewing this entry's 3D model; If not set, the default catalog model scene is used" } },
				{ Name = "categoryIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "subcategoryIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "dataTagsByID", Type = "LuaValueVariant", Nilable = false, Documentation = { "Simple localized 'tag' strings that are primarily used for things like categorization and filtering" } },
				{ Name = "size", Type = "HousingCatalogEntrySize", Nilable = false },
				{ Name = "placementCost", Type = "number", Nilable = false, Documentation = { "How much of the applicable budget placing this entry would cost (if any)" } },
				{ Name = "showQuantity", Type = "bool", Nilable = false, Documentation = { "Typically false if quantity isn't used by or meaningful for this particular kind of catalog entry" } },
				{ Name = "quantity", Type = "number", Nilable = false, Documentation = { "The number of fully instantiated instances of this entry that exist in storage; Does not include unredeemed instances (see remainingRedeemable)" } },
				{ Name = "remainingRedeemable", Type = "number", Nilable = false, Documentation = { "The number of unredeemed instances of this entry that exist in storage; Some auto-awarded housing objects are granted in this 'lazily-instantiated' way, and will be 'redeemed' on first being placed" } },
				{ Name = "numPlaced", Type = "number", Nilable = false, Documentation = { "The total number of instances of this entry that have been placed across all of the player's houses and plots" } },
				{ Name = "isUniqueTrophy", Type = "bool", Nilable = false, Documentation = { "This decor is flagged to display as a unique trophy item." } },
				{ Name = "isAllowedOutdoors", Type = "bool", Nilable = false, Documentation = { "True if this entry is something that is allowed to be placed outside, within a plot" } },
				{ Name = "isAllowedIndoors", Type = "bool", Nilable = false, Documentation = { "True if this entry is something that is allowed to be placed indoors, within a house interior" } },
				{ Name = "canCustomize", Type = "bool", Nilable = false, Documentation = { "True if this entry is something that can be customized; Kinds of customization vary depending on the entry type" } },
				{ Name = "isPrefab", Type = "bool", Nilable = false },
				{ Name = "quality", Type = "ItemQuality", Nilable = true },
				{ Name = "customizations", Type = "table", InnerType = "cstring", Nilable = false, Documentation = { "Labels for each of the customizations applied to this entry, if any" } },
				{ Name = "dyeIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "marketInfo", Type = "HousingMarketInfo", Nilable = true },
				{ Name = "firstAcquisitionBonus", Type = "number", Nilable = false, Documentation = { "House XP that can be gained upon acquiring this entry for the first time" } },
				{ Name = "sourceText", Type = "cstring", Nilable = false, Documentation = { "Describes specific sources this entry may be gained from; Faction-specific sources may or may not be included based on the current player's faction" } },
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
				{ Name = "anyOwnedEntries", Type = "bool", Nilable = false, Documentation = { "True if the player owns anything that falls under this subcategory" } },
			},
		},
		{
			Name = "HousingCategorySearchInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "withOwnedEntriesOnly", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, search will only return categories/subcategories that the player owns something under" } },
				{ Name = "includeFeaturedCategory", Type = "bool", Nilable = false, Default = false },
				{ Name = "editorModeContext", Type = "HouseEditorMode", Nilable = true, Documentation = { "If set, will restrict results to only categories associated with/used by this Editor Mode" } },
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
				{ Name = "productID", Type = "number", Nilable = true },
				{ Name = "bundleCatalogShopProductID", Type = "number", Nilable = true },
				{ Name = "isBundleParent", Type = "bool", Nilable = false },
				{ Name = "isBundleChild", Type = "bool", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "decorID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "price", Type = "number", Nilable = false },
				{ Name = "salePrice", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingCatalogUI);