local SecondsFormatterShared =
{
	Tables =
	{
		{
			Name = "SecondsFormatterAbbrevation",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "SecondsFormatterAbbrevation", EnumValue = 0 },
				{ Name = "Truncate", Type = "SecondsFormatterAbbrevation", EnumValue = 1 },
				{ Name = "OneLetter", Type = "SecondsFormatterAbbrevation", EnumValue = 2 },
			},
		},
		{
			Name = "SecondsFormatterInterval",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Seconds", Type = "SecondsFormatterInterval", EnumValue = 0 },
				{ Name = "Minutes", Type = "SecondsFormatterInterval", EnumValue = 1 },
				{ Name = "Hours", Type = "SecondsFormatterInterval", EnumValue = 2 },
				{ Name = "Days", Type = "SecondsFormatterInterval", EnumValue = 3 },
			},
		},
		{
			Name = "SecondsFormatterIntervalWhitespace",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Preserve", Type = "SecondsFormatterIntervalWhitespace", EnumValue = 0, Documentation = { "Do not strip any whitespace from interval unit strings." } },
				{ Name = "Strip", Type = "SecondsFormatterIntervalWhitespace", EnumValue = 1, Documentation = { "Strip whitespace from interval unit strings. Some locales override this setting (eg. deDE, ruRU)." } },
				{ Name = "StripIgnoreLocale", Type = "SecondsFormatterIntervalWhitespace", EnumValue = 2, Documentation = { "Always strip whitespace from interval unit strings even if the client locale should normally preserve whitespace." } },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SecondsFormatterShared);