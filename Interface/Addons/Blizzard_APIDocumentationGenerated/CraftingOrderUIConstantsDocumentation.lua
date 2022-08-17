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
			Name = "CraftingOrderCustomerOption",
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
				{ Name = "slots", Type = "number", Nilable = true },
				{ Name = "level", Type = "number", Nilable = true },
				{ Name = "skill", Type = "number", Nilable = true },
				{ Name = "secondaryCategoryID", Type = "number", Nilable = true },
				{ Name = "tertiaryCategoryID", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CraftingOrderUIConstants);