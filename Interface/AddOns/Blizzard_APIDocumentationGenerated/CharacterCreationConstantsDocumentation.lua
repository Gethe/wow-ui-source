local CharacterCreationConstants =
{
	Tables =
	{
		{
			Name = "CharCreateAnimTurnType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Normal", Type = "CharCreateAnimTurnType", EnumValue = 0 },
				{ Name = "Torso", Type = "CharCreateAnimTurnType", EnumValue = 1 },
			},
		},
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
};

APIDocumentation:AddDocumentationTable(CharacterCreationConstants);