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
			Name = "CraftingOrderReagentsType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "All", Type = "CraftingOrderReagentsType", EnumValue = 0 },
				{ Name = "Some", Type = "CraftingOrderReagentsType", EnumValue = 1 },
				{ Name = "None", Type = "CraftingOrderReagentsType", EnumValue = 2 },
			},
		},
		{
			Name = "CraftingOrderConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "MAX_CRAFTING_ORDER_FAVORITE_RECIPES", Type = "number", Value = 100 },
				{ Name = "NPC_CRAFTING_ORDER_NUM_SUPPORTED_REWARDS", Type = "number", Value = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CraftingOrderUIConstants);