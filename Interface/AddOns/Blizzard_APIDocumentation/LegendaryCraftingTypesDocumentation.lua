local LegendaryCraftingTypes =
{
	Tables =
	{
		{
			Name = "RuneforgePowerFilter",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "All", Type = "RuneforgePowerFilter", EnumValue = 0 },
				{ Name = "Available", Type = "RuneforgePowerFilter", EnumValue = 1 },
				{ Name = "Unavailable", Type = "RuneforgePowerFilter", EnumValue = 2 },
			},
		},
		{
			Name = "RuneforgePowerState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Available", Type = "RuneforgePowerState", EnumValue = 0 },
				{ Name = "Unavailable", Type = "RuneforgePowerState", EnumValue = 1 },
				{ Name = "Invalid", Type = "RuneforgePowerState", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LegendaryCraftingTypes);