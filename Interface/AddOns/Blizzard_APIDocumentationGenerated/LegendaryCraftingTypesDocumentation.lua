local LegendaryCraftingTypes =
{
	Tables =
	{
		{
			Name = "RuneforgePowerFilter",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "All", Type = "RuneforgePowerFilter", EnumValue = 0 },
				{ Name = "Relevant", Type = "RuneforgePowerFilter", EnumValue = 1 },
				{ Name = "Available", Type = "RuneforgePowerFilter", EnumValue = 2 },
				{ Name = "Unavailable", Type = "RuneforgePowerFilter", EnumValue = 3 },
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
		{
			Name = "RuneforgeItemPreviewInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "itemName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RuneforgeLegendaryComponentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
				{ Name = "modifiers", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "RuneforgeLegendaryCraftDescription",
			Type = "Structure",
			Fields =
			{
				{ Name = "baseItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "runeforgePowerID", Type = "number", Nilable = false },
				{ Name = "modifiers", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "RuneforgePower",
			Type = "Structure",
			Fields =
			{
				{ Name = "runeforgePowerID", Type = "number", Nilable = false },
				{ Name = "state", Type = "RuneforgePowerState", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "descriptionSpellID", Type = "number", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "source", Type = "cstring", Nilable = true },
				{ Name = "iconFileID", Type = "fileID", Nilable = false },
				{ Name = "specName", Type = "cstring", Nilable = true },
				{ Name = "matchesSpec", Type = "bool", Nilable = false },
				{ Name = "matchesCovenant", Type = "bool", Nilable = false },
				{ Name = "covenantID", Type = "number", Nilable = true },
				{ Name = "slots", Type = "table", InnerType = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LegendaryCraftingTypes);