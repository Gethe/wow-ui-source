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
		{
			Name = "RestrictionType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Invalid", Type = "RestrictionType", EnumValue = 0 },
				{ Name = "ServerExpansion", Type = "RestrictionType", EnumValue = 1 },
				{ Name = "AccountExpansion", Type = "RestrictionType", EnumValue = 2 },
				{ Name = "Achievement", Type = "RestrictionType", EnumValue = 3 },
				{ Name = "Entitlement", Type = "RestrictionType", EnumValue = 4 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CharacterCreationConstants);