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
		{
			Name = "RestrictPingsTo",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "RestrictPingsTo", EnumValue = 0 },
				{ Name = "Lead", Type = "RestrictPingsTo", EnumValue = 1 },
				{ Name = "Assist", Type = "RestrictPingsTo", EnumValue = 2 },
				{ Name = "TankHealer", Type = "RestrictPingsTo", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PartyConstants);