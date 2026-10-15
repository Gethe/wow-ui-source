local SpecializationConstants =
{
	Tables =
	{
		{
			Name = "ChrSpecializationFlags",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 1,
			MaxValue = 256,
			Fields =
			{
				{ Name = "IsCaster", Type = "ChrSpecializationFlags", EnumValue = 1 },
				{ Name = "IsRanged", Type = "ChrSpecializationFlags", EnumValue = 2 },
				{ Name = "IsMelee", Type = "ChrSpecializationFlags", EnumValue = 4 },
				{ Name = "ChallengeModeSpiritAsHit", Type = "ChrSpecializationFlags", EnumValue = 8 },
				{ Name = "SheatheInvertedForDualWield", Type = "ChrSpecializationFlags", EnumValue = 16 },
				{ Name = "OverrideSpec", Type = "ChrSpecializationFlags", EnumValue = 32 },
				{ Name = "RecommendedSpec", Type = "ChrSpecializationFlags", EnumValue = 64 },
				{ Name = "DisabledForTesting", Type = "ChrSpecializationFlags", EnumValue = 128 },
				{ Name = "AllowedSpecForBoost", Type = "ChrSpecializationFlags", EnumValue = 256 },
			},
		},
		{
			Name = "SpecGroup",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Primary", Type = "SpecGroup", EnumValue = 0 },
				{ Name = "Secondary", Type = "SpecGroup", EnumValue = 1 },
			},
		},
		{
			Name = "SpecializationSpellsFlag",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "DevOnly", Type = "SpecializationSpellsFlag", EnumValue = 1 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SpecializationConstants);