local SecondsFormatterShared =
{
	Tables =
	{
		{
			Name = "SecondsFormatterAbbreviation",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "SecondsFormatterAbbreviation", EnumValue = 0 },
				{ Name = "Truncate", Type = "SecondsFormatterAbbreviation", EnumValue = 1 },
				{ Name = "OneLetter", Type = "SecondsFormatterAbbreviation", EnumValue = 2 },
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
		{
			Name = "SecondsFormatterRounding",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "RoundUp", Type = "SecondsFormatterRounding", EnumValue = 0, Documentation = { "Round fractional seconds up to the next whole second when not displaying milliseconds." } },
				{ Name = "Truncate", Type = "SecondsFormatterRounding", EnumValue = 1, Documentation = { "Truncate fractional seconds to the current whole second when not displaying milliseconds." } },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SecondsFormatterShared);