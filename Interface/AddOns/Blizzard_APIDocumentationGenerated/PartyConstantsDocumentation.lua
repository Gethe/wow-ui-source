local PartyConstants =
{
	Tables =
	{
		{
			Name = "AvgItemLevelCategories",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Base", Type = "AvgItemLevelCategories", EnumValue = 0 },
				{ Name = "EquippedBase", Type = "AvgItemLevelCategories", EnumValue = 1 },
				{ Name = "EquippedEffective", Type = "AvgItemLevelCategories", EnumValue = 2 },
				{ Name = "PvP", Type = "AvgItemLevelCategories", EnumValue = 3 },
				{ Name = "PvPWeighted", Type = "AvgItemLevelCategories", EnumValue = 4 },
				{ Name = "EquippedEffectiveWeighted", Type = "AvgItemLevelCategories", EnumValue = 5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PartyConstants);