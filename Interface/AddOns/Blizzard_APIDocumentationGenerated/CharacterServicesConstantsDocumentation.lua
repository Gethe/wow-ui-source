local CharacterServicesConstants =
{
	Tables =
	{
		{
			Name = "CharacterServiceInfoFlag",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "RestrictToRecommendedSpecs", Type = "CharacterServiceInfoFlag", EnumValue = 1 },
				{ Name = "AllowMaxLevelBoost", Type = "CharacterServiceInfoFlag", EnumValue = 2 },
			},
		},
		{
			Name = "NoRPEReason",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "HasRPE", Type = "NoRPEReason", EnumValue = 0 },
				{ Name = "LowLevel", Type = "NoRPEReason", EnumValue = 1 },
				{ Name = "Timerunner", Type = "NoRPEReason", EnumValue = 2 },
				{ Name = "IneligibleMap", Type = "NoRPEReason", EnumValue = 3 },
				{ Name = "RecentlyActive", Type = "NoRPEReason", EnumValue = 4 },
				{ Name = "RecentlyBoosted", Type = "NoRPEReason", EnumValue = 5 },
				{ Name = "UpgradeInProgress", Type = "NoRPEReason", EnumValue = 6 },
				{ Name = "FactionOrRaceChange", Type = "NoRPEReason", EnumValue = 7 },
				{ Name = "BNetToken", Type = "NoRPEReason", EnumValue = 8 },
				{ Name = "PlayerLocked", Type = "NoRPEReason", EnumValue = 9 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CharacterServicesConstants);