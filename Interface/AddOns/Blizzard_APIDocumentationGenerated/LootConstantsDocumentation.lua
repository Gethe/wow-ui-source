local LootConstants =
{
	Tables =
	{
		{
			Name = "LootMethod",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Freeforall", Type = "LootMethod", EnumValue = 0 },
				{ Name = "Roundrobin", Type = "LootMethod", EnumValue = 1 },
				{ Name = "Masterlooter", Type = "LootMethod", EnumValue = 2 },
				{ Name = "Group", Type = "LootMethod", EnumValue = 3 },
				{ Name = "Needbeforegreed", Type = "LootMethod", EnumValue = 4 },
				{ Name = "Personal", Type = "LootMethod", EnumValue = 5 },
			},
		},
		{
			Name = "LootMethodStyles",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "PersonalOnly", Type = "LootMethodStyles", EnumValue = 0 },
				{ Name = "Vanilla", Type = "LootMethodStyles", EnumValue = 1 },
			},
		},
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