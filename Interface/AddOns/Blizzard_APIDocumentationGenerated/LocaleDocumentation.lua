local Locale =
{
	Name = "Locale",
	Type = "System",

	Functions =
	{
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