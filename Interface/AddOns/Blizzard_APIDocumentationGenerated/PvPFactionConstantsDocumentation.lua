local PvPFactionConstants =
{
	Tables =
	{
		{
			Name = "PvPFaction",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Horde", Type = "PvPFaction", EnumValue = 0 },
				{ Name = "Alliance", Type = "PvPFaction", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PvPFactionConstants);