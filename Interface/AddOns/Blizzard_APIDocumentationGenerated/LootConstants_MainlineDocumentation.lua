local LootConstants_Mainline =
{
	Tables =
	{
		{
			Name = "LootRollDisabledReason",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "None", Type = "LootRollDisabledReason", EnumValue = 0 },
				{ Name = "NotAllowed", Type = "LootRollDisabledReason", EnumValue = 1 },
				{ Name = "UniqueRestriction", Type = "LootRollDisabledReason", EnumValue = 2 },
				{ Name = "NotDisenchantable", Type = "LootRollDisabledReason", EnumValue = 3 },
				{ Name = "InsufficientEnchantSkill", Type = "LootRollDisabledReason", EnumValue = 4 },
				{ Name = "GreedOnly", Type = "LootRollDisabledReason", EnumValue = 5 },
				{ Name = "HasBetterExactItem", Type = "LootRollDisabledReason", EnumValue = 6 },
				{ Name = "MissingProfession", Type = "LootRollDisabledReason", EnumValue = 7 },
			},
		},
		{
			Name = "LootRollType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Pass", Type = "LootRollType", EnumValue = 0 },
				{ Name = "Need", Type = "LootRollType", EnumValue = 1 },
				{ Name = "Greed", Type = "LootRollType", EnumValue = 2 },
				{ Name = "Disenchant", Type = "LootRollType", EnumValue = 3 },
				{ Name = "Transmog", Type = "LootRollType", EnumValue = 4 },
			},
		},
		{
			Name = "LootConsts_Camelot",
			Type = "Constants",
			Values =
			{
				{ Name = "MasterLootQualityThreshold", Type = "number", Value = 4 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(LootConstants_Mainline);