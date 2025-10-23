local StringUtil =
{
	Name = "StringUtil",
	Type = "System",

	Functions =
	{
		{
			Name = "EscapeQuotedCodes",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Returns a string with all quoted code sequences ('|' characters) escaped." },

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "escaped", Type = "stringView", Nilable = false },
			},
		},
		{
			Name = "StripHyperlinks",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "maintainColor", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, preserve all '|c' and '|r' quoted code sequences." } },
				{ Name = "maintainBrackets", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, preserve all '[' and ']' characters." } },
				{ Name = "stripNewlines", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, remove all '|n' quoted code sequences." } },
				{ Name = "maintainAtlases", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, preserve all balanced '|A' and '|a' quoted code sequences." } },
			},

			Returns =
			{
				{ Name = "stripped", Type = "stringView", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "StripHyperlinkOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "maintainColor", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, preserve all '|c' and '|r' quoted code sequences." } },
				{ Name = "maintainBrackets", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, preserve all '[' and ']' characters." } },
				{ Name = "stripNewlines", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, remove all '|n' quoted code sequences." } },
				{ Name = "maintainAtlases", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, preserve all balanced '|A' and '|a' quoted code sequences." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(StringUtil);