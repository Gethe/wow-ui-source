local GameEnvironmentConstants =
{
	Tables =
	{
		{
			Name = "EventRealmQueues",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "EventRealmQueues", EnumValue = 0 },
				{ Name = "PlunderstormSolo", Type = "EventRealmQueues", EnumValue = 1 },
				{ Name = "PlunderstormDuo", Type = "EventRealmQueues", EnumValue = 2 },
				{ Name = "PlunderstormTrio", Type = "EventRealmQueues", EnumValue = 4 },
			},
		},
		{
			Name = "GameEnvironment",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "WoW", Type = "GameEnvironment", EnumValue = 0 },
				{ Name = "WoWLabs", Type = "GameEnvironment", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GameEnvironmentConstants);