local CharacterCreationConstants =
{
	Tables =
	{
		{
			Name = "CharSectionCondition",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "AlliedRace", Type = "CharSectionCondition", EnumValue = 0 },
				{ Name = "HeritageArmor", Type = "CharSectionCondition", EnumValue = 1 },
				{ Name = "ConditionalAppeareance", Type = "CharSectionCondition", EnumValue = 2 },
				{ Name = "RaceClassCombo", Type = "CharSectionCondition", EnumValue = 3 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CharacterCreationConstants);