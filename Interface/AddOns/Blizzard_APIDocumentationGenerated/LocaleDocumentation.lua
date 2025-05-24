local Locale =
{
	Name = "Locale",
	Type = "System",

	Functions =
	{
		{
			Name = "GetAvailableLocaleInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "ignoreLocaleRestrictions", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "localeInfos", Type = "table", InnerType = "LocaleInfo", Nilable = false },
			},
		},
		{
			Name = "GetAvailableLocales",
			Type = "Function",

			Arguments =
			{
				{ Name = "ignoreLocaleRestrictions", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "unpackedPrimitiveType", Type = "string", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetCurrentRegion",
			Type = "Function",

			Returns =
			{
				{ Name = "region", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLocale",
			Type = "Function",

			Returns =
			{
				{ Name = "localeName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetOSLocale",
			Type = "Function",

			Returns =
			{
				{ Name = "localeName", Type = "cstring", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "LocaleInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "localeId", Type = "number", Nilable = false },
				{ Name = "localeName", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Locale);