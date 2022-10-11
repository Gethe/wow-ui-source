local CraftingOrderUIConstants =
{
	Tables =
	{
		{
			Name = "CraftingOrderCustomerCategoryType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Primary", Type = "CraftingOrderCustomerCategoryType", EnumValue = 0 },
				{ Name = "Secondary", Type = "CraftingOrderCustomerCategoryType", EnumValue = 1 },
				{ Name = "Tertiary", Type = "CraftingOrderCustomerCategoryType", EnumValue = 2 },
			},
		},
		{
			Name = "CraftingOrderCustomerCategory",
			Type = "Structure",
			Fields =
			{
				{ Name = "categoryName", Type = "string", Nilable = false },
				{ Name = "categoryID", Type = "number", Nilable = false },
				{ Name = "uiSortOrder", Type = "number", Nilable = false },
				{ Name = "primaryCategorySortOrder", Type = "number", Nilable = true },
				{ Name = "secondaryCategorySortOrder", Type = "number", Nilable = true },
				{ Name = "type", Type = "CraftingOrderCustomerCategoryType", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderCustomerCategoryFilters",
			Type = "Structure",
			Fields =
			{
				{ Name = "primaryCategoryID", Type = "number", Nilable = true },
				{ Name = "secondaryCategoryID", Type = "number", Nilable = true },
				{ Name = "tertiaryCategoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CraftingOrderCustomerOptionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
				{ Name = "professionID", Type = "number", Nilable = false },
				{ Name = "skillUpSkillLineID", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemName", Type = "string", Nilable = false },
				{ Name = "primaryCategoryID", Type = "number", Nilable = false },
				{ Name = "iLvl", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "quality", Type = "ItemQuality", Nilable = true },
				{ Name = "slots", Type = "number", Nilable = true },
				{ Name = "skill", Type = "number", Nilable = true },
				{ Name = "secondaryCategoryID", Type = "number", Nilable = true },
				{ Name = "tertiaryCategoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CraftingOrderCustomerSearchParams",
			Type = "Structure",
			Fields =
			{
				{ Name = "categoryFilters", Type = "CraftingOrderCustomerCategoryFilters", Nilable = false },
				{ Name = "searchText", Type = "string", Nilable = true },
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "uncollectedOnly", Type = "bool", Nilable = false },
				{ Name = "usableOnly", Type = "bool", Nilable = false },
				{ Name = "upgradesOnly", Type = "bool", Nilable = false },
				{ Name = "includePoor", Type = "bool", Nilable = false },
				{ Name = "includeCommon", Type = "bool", Nilable = false },
				{ Name = "includeUncommon", Type = "bool", Nilable = false },
				{ Name = "includeRare", Type = "bool", Nilable = false },
				{ Name = "includeEpic", Type = "bool", Nilable = false },
				{ Name = "includeLegendary", Type = "bool", Nilable = false },
				{ Name = "includeArtifact", Type = "bool", Nilable = false },
				{ Name = "isFavoritesSearch", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderCustomerSearchResults",
			Type = "Structure",
			Fields =
			{
				{ Name = "options", Type = "table", InnerType = "CraftingOrderCustomerOptionInfo", Nilable = false },
				{ Name = "extraColumnType", Type = "AuctionHouseExtraColumn", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CraftingOrderUIConstants);