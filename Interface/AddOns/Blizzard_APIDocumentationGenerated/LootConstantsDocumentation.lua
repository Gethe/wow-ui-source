local LootConstants =
{
	Tables =
	{
		{
			Name = "LootSlotType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "LootSlotType", EnumValue = 0 },
				{ Name = "Item", Type = "LootSlotType", EnumValue = 1 },
				{ Name = "Money", Type = "LootSlotType", EnumValue = 2 },
				{ Name = "Currency", Type = "LootSlotType", EnumValue = 3 },
			},
		},
		{
			Name = "LootConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "MasterLootQualityThreshold", Type = "number", Value = 5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LootConstants);