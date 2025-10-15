local HousingCatalogConstants =
{
	Tables =
	{
		{
			Name = "HousingCatalogEntrySize",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 69,
			Fields =
			{
				{ Name = "None", Type = "HousingCatalogEntrySize", EnumValue = 0 },
				{ Name = "Tiny", Type = "HousingCatalogEntrySize", EnumValue = 65 },
				{ Name = "Small", Type = "HousingCatalogEntrySize", EnumValue = 66 },
				{ Name = "Medium", Type = "HousingCatalogEntrySize", EnumValue = 67 },
				{ Name = "Large", Type = "HousingCatalogEntrySize", EnumValue = 68 },
				{ Name = "Huge", Type = "HousingCatalogEntrySize", EnumValue = 69 },
			},
		},
		{
			Name = "HousingCatalogEntrySubtype",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Invalid", Type = "HousingCatalogEntrySubtype", EnumValue = 0 },
				{ Name = "Unowned", Type = "HousingCatalogEntrySubtype", EnumValue = 1, Documentation = { "Unowned entry, for displaying a catalog object in a static context" } },
				{ Name = "MarketItem", Type = "HousingCatalogEntrySubtype", EnumValue = 2, Documentation = { "Purchasable shop product" } },
				{ Name = "OwnedModifiedStack", Type = "HousingCatalogEntrySubtype", EnumValue = 3, Documentation = { "Stack of owned instances that share specific modifications" } },
				{ Name = "OwnedUnmodifiedStack", Type = "HousingCatalogEntrySubtype", EnumValue = 4, Documentation = { "Stack of owned default instances of a record" } },
			},
		},
		{
			Name = "HousingCatalogEntryType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Invalid", Type = "HousingCatalogEntryType", EnumValue = 0 },
				{ Name = "Decor", Type = "HousingCatalogEntryType", EnumValue = 1 },
				{ Name = "Room", Type = "HousingCatalogEntryType", EnumValue = 2 },
			},
		},
		{
			Name = "HousingCatalogSortType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "DateAdded", Type = "HousingCatalogSortType", EnumValue = 0 },
				{ Name = "Alphabetical", Type = "HousingCatalogSortType", EnumValue = 1 },
			},
		},
		{
			Name = "HousingCatalogConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "HOUSING_CATALOG_OPTIONS_EXPECTED", Type = "number", Value = 1200 },
				{ Name = "HOUSING_CATALOG_NUM_FEATURED_EXPECTED", Type = "number", Value = 100 },
				{ Name = "HOUSING_CATALOG_NUM_FEATURED_BUNDLES_EXPECTED", Type = "number", Value = 5 },
				{ Name = "HOUSING_CATALOG_CATEGORIES_EXPECTED", Type = "number", Value = 20 },
				{ Name = "HOUSING_CATALOG_SUBCATEGORIES_EXPECTED", Type = "number", Value = 50 },
				{ Name = "HOUSING_CATALOG_SUBCATEGORIES_PER_CATEGORY_EXPECTED", Type = "number", Value = 5 },
				{ Name = "HOUSING_CATALOG_ENTRY_TAGS_EXPECTED", Type = "number", Value = 5 },
				{ Name = "HOUSING_CATALOG_TAG_GROUP_TAGS_EXPECTED", Type = "number", Value = 16 },
				{ Name = "HOUSING_CATALOG_FILTER_TAGS_EXPECTED", Type = "number", Value = 90 },
				{ Name = "HOUSING_CATALOG_NUM_FILTER_TAG_GROUPS", Type = "number", Value = 6 },
				{ Name = "HOUSING_CATALOG_OPTIONS_PER_CATEGORY_EXPECTED", Type = "number", Value = Constants.HousingCatalogConsts.HOUSING_CATALOG_OPTIONS_EXPECTED / Constants.HousingCatalogConsts.HOUSING_CATALOG_CATEGORIES_EXPECTED },
				{ Name = "HOUSING_CATALOG_OPTIONS_PER_SUBCATEGORY_EXPECTED", Type = "number", Value = Constants.HousingCatalogConsts.HOUSING_CATALOG_OPTIONS_EXPECTED / Constants.HousingCatalogConsts.HOUSING_CATALOG_SUBCATEGORIES_EXPECTED },
				{ Name = "HOUSING_CATALOG_ROOMS_SUBCATEGORY_ID", Type = "number", Value = 35 },
				{ Name = "HOUSING_CATALOG_ROOMS_CATEGORY_ID", Type = "number", Value = 9 },
				{ Name = "HOUSING_CATALOG_FEATURED_CATEGORY_ID", Type = "number", Value = 17 },
				{ Name = "HOUSING_CATALOG_ALL_CATEGORY_ID", Type = "number", Value = 18 },
				{ Name = "HOUSING_CATALOG_SIZE_DATAGROUP_ID", Type = "number", Value = 2 },
				{ Name = "HOUSING_CATALOG_NONE_TAG_ID", Type = "number", Value = -33 },
				{ Name = "HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT", Type = "number", Value = 1317 },
				{ Name = "HOUSING_CATALOG_DECOR_MODELSCENEID_FLAT", Type = "number", Value = 1318 },
			},
		},
		{
			Name = "HousingCatalogEntryID",
			Type = "Structure",
			Documentation = { "Compound Identifier for entry stacks in the catalog" },
			Fields =
			{
				{ Name = "recordID", Type = "number", Nilable = false },
				{ Name = "entryType", Type = "HousingCatalogEntryType", Nilable = false },
				{ Name = "entrySubtype", Type = "HousingCatalogEntrySubtype", Nilable = false },
				{ Name = "subtypeIdentifier", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingCatalogFilterTagGroupInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "groupID", Type = "number", Nilable = false },
				{ Name = "groupName", Type = "cstring", Nilable = false },
				{ Name = "tags", Type = "table", InnerType = "HousingCatalogFilterTagInfo", Nilable = false },
			},
		},
		{
			Name = "HousingCatalogFilterTagInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "tagID", Type = "number", Nilable = false },
				{ Name = "tagName", Type = "string", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "anyAssociatedEntries", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingCatalogConstants);