local CombatLogShared =
{
	Tables =
	{
		{
			Name = "CombatLogMessageOrder",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Newest", Type = "CombatLogMessageOrder", EnumValue = 0 },
				{ Name = "Oldest", Type = "CombatLogMessageOrder", EnumValue = 1 },
			},
		},
		{
			Name = "CombatLogEventInfo",
			Type = "Structure",
			Fields =
			{
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CombatLogShared);