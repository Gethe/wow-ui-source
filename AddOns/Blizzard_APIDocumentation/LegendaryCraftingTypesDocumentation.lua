local LegendaryCraftingTypes =
{
	Tables =
	{
		{
			Name = "RuneforgeLegendaryError",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "MissingReagents", Type = "RuneforgeLegendaryError", EnumValue = 0 },
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
		{
			Name = "CurrencyCost",
			Type = "Structure",
			Fields =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LegendaryCraftingTypes);