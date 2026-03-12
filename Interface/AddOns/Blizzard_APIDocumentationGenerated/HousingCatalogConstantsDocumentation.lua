local HousingCatalogConstants =
{
	Tables =
	{
		{
			Name = "HousingCatalogEntryModelScenePresets",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 1317,
			MaxValue = 1452,
			Fields =
			{
				{ Name = "DecorDefault", Type = "HousingCatalogEntryModelScenePresets", EnumValue = 1317 },
				{ Name = "DecorTiny", Type = "HousingCatalogEntryModelScenePresets", EnumValue = 1333 },
				{ Name = "DecorSmall", Type = "HousingCatalogEntryModelScenePresets", EnumValue = 1334 },
				{ Name = "DecorMedium", Type = "HousingCatalogEntryModelScenePresets", EnumValue = 1335 },
				{ Name = "DecorLarge", Type = "HousingCatalogEntryModelScenePresets", EnumValue = 1336 },
				{ Name = "DecorHuge", Type = "HousingCatalogEntryModelScenePresets", EnumValue = 1337 },
				{ Name = "DecorCeiling", Type = "HousingCatalogEntryModelScenePresets", EnumValue = 1338 },
				{ Name = "DecorWall", Type = "HousingCatalogEntryModelScenePresets", EnumValue = 1339 },
				{ Name = "DecorFlat", Type = "HousingCatalogEntryModelScenePresets", EnumValue = 1318 },
				{ Name = "DecorHorizontalSurface", Type = "HousingCatalogEntryModelScenePresets", EnumValue = 1452 },
			},
		},
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
				{ Name = "HOUSING_CATALOG_FEATURED_CATEGORY_ID", Type = "number", Value = 17 },
				{ Name = "HOUSING_CATALOG_ALL_CATEGORY_ID", Type = "number", Value = 18 },
				{ Name = "HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT", Type = "number", Value = 1317 },
			},
		},
		{
			Name = "HousingCatalogEntryID",
			Type = "Structure",
			Documentation = { "Identifier for base entries in the catalog" },
			Fields =
			{
				{ Name = "recordID", Type = "number", Nilable = false },
				{ Name = "entryType", Type = "HousingCatalogEntryType", Nilable = false },
			},
		},
		{
			Name = "HousingCatalogEntryVariantID",
			Type = "Structure",
			Documentation = { "Compound Identifier for entry variant stacks in the catalog" },
			Fields =
			{
				{ Name = "recordID", Type = "number", Nilable = false },
				{ Name = "entryType", Type = "HousingCatalogEntryType", Nilable = false },
				{ Name = "variantIdentifier", Type = "number", Nilable = false, Documentation = { "Hashed value used to identify and differentiate stacks that are the same type and record, but have some variant-specific difference (e.g. dye colors)" } },
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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(HousingCatalogConstants);