local ArtifactConstants =
{
	Tables =
	{
		{
			Name = "ArtifactAppearanceFlags",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 1,
			MaxValue = 16,
			Fields =
			{
				{ Name = "Default", Type = "ArtifactAppearanceFlags", EnumValue = 1 },
				{ Name = "HideIfNotLearned", Type = "ArtifactAppearanceFlags", EnumValue = 2 },
				{ Name = "Unused", Type = "ArtifactAppearanceFlags", EnumValue = 4 },
				{ Name = "NoLongerObtainable", Type = "ArtifactAppearanceFlags", EnumValue = 8 },
				{ Name = "EnabledByFirst", Type = "ArtifactAppearanceFlags", EnumValue = 16 },
			},
		},
		{
			Name = "ArtifactAppearanceSetFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "HiddenIfNoAppearancesLearned", Type = "ArtifactAppearanceSetFlags", EnumValue = 1 },
			},
		},
		{
			Name = "ArtifactFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "DisplayOffhandInFront", Type = "ArtifactFlags", EnumValue = 1 },
				{ Name = "HideOffhandAtForge", Type = "ArtifactFlags", EnumValue = 2 },
			},
		},
		{
			Name = "ArtifactPowerLabel",
			Type = "Enumeration",
			NumValues = 14,
			MinValue = 0,
			MaxValue = 13,
			Fields =
			{
				{ Name = "None", Type = "ArtifactPowerLabel", EnumValue = 0 },
				{ Name = "Gold_1", Type = "ArtifactPowerLabel", EnumValue = 1 },
				{ Name = "Gold_2", Type = "ArtifactPowerLabel", EnumValue = 2 },
				{ Name = "Gold_3", Type = "ArtifactPowerLabel", EnumValue = 3 },
				{ Name = "Bronze_01", Type = "ArtifactPowerLabel", EnumValue = 4 },
				{ Name = "Bronze_02", Type = "ArtifactPowerLabel", EnumValue = 5 },
				{ Name = "Bronze_03", Type = "ArtifactPowerLabel", EnumValue = 6 },
				{ Name = "Bronze_04", Type = "ArtifactPowerLabel", EnumValue = 7 },
				{ Name = "Bronze_05", Type = "ArtifactPowerLabel", EnumValue = 8 },
				{ Name = "Bronze_06", Type = "ArtifactPowerLabel", EnumValue = 9 },
				{ Name = "Bronze_07", Type = "ArtifactPowerLabel", EnumValue = 10 },
				{ Name = "Bronze_08", Type = "ArtifactPowerLabel", EnumValue = 11 },
				{ Name = "Bronze_09", Type = "ArtifactPowerLabel", EnumValue = 12 },
				{ Name = "Bronze_10", Type = "ArtifactPowerLabel", EnumValue = 13 },
			},
		},
		{
			Name = "ArtifactPowerPickerFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "MustBeUnique", Type = "ArtifactPowerPickerFlags", EnumValue = 1 },
			},
		},
		{
			Name = "ArtifactPowerStaticFlags",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 1,
			MaxValue = 64,
			Fields =
			{
				{ Name = "IsGoldMedal", Type = "ArtifactPowerStaticFlags", EnumValue = 1 },
				{ Name = "IsStartPower", Type = "ArtifactPowerStaticFlags", EnumValue = 2 },
				{ Name = "IsEndgamePower", Type = "ArtifactPowerStaticFlags", EnumValue = 4 },
				{ Name = "IsMetaPower", Type = "ArtifactPowerStaticFlags", EnumValue = 8 },
				{ Name = "OneFreeRank", Type = "ArtifactPowerStaticFlags", EnumValue = 16 },
				{ Name = "MaxRanksVariable", Type = "ArtifactPowerStaticFlags", EnumValue = 32 },
				{ Name = "TooltipSingleRank", Type = "ArtifactPowerStaticFlags", EnumValue = 64 },
			},
		},
		{
			Name = "ArtifactTiers",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "One", Type = "ArtifactTiers", EnumValue = 0 },
				{ Name = "Two", Type = "ArtifactTiers", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ArtifactConstants);