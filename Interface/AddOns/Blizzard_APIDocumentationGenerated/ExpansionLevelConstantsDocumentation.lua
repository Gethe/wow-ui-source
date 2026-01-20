local ExpansionLevelConstants =
{
	Tables =
	{
		{
			Name = "ExpansionLevel",
			Type = "Enumeration",
			NumValues = 13,
			MinValue = 0,
			MaxValue = 12,
			Fields =
			{
				{ Name = "None", Type = "ExpansionLevel", EnumValue = 0 },
				{ Name = "BurningCrusade", Type = "ExpansionLevel", EnumValue = 1 },
				{ Name = "Northrend", Type = "ExpansionLevel", EnumValue = 2 },
				{ Name = "Cataclysm", Type = "ExpansionLevel", EnumValue = 3 },
				{ Name = "MistsOfPandaria", Type = "ExpansionLevel", EnumValue = 4 },
				{ Name = "Draenor", Type = "ExpansionLevel", EnumValue = 5 },
				{ Name = "Legion", Type = "ExpansionLevel", EnumValue = 6 },
				{ Name = "BattleForAzeroth", Type = "ExpansionLevel", EnumValue = 7 },
				{ Name = "Shadowlands", Type = "ExpansionLevel", EnumValue = 8 },
				{ Name = "Dragonflight", Type = "ExpansionLevel", EnumValue = 9 },
				{ Name = "WarWithin", Type = "ExpansionLevel", EnumValue = 10 },
				{ Name = "Midnight", Type = "ExpansionLevel", EnumValue = 11 },
				{ Name = "LastTitan", Type = "ExpansionLevel", EnumValue = 12 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ExpansionLevelConstants);