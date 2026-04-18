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
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CharacterServicesConstants);