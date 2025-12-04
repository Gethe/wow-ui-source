local StringUtil =
{
	Name = "StringUtil",
	Type = "System",
	Namespace = "C_StringUtil",

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
			Name = "FloorToNearestString",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "text", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RoundToNearestString",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "text", Type = "string", Nilable = false },
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
		{
			Name = "TruncateWhenZero",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Formats the given number to a string as an integer (rounding down). If the integer is zero, returns an empty string." },

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "text", Type = "string", Nilable = false },
			},
		},
		{
			Name = "WrapString",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Returns a string with 'prefix' and 'suffix' joined to 'infix' iif 'infix' is not an empty string. Else, an empty string is returned." },

			Arguments =
			{
				{ Name = "infix", Type = "stringView", Nilable = false },
				{ Name = "prefix", Type = "stringView", Nilable = true },
				{ Name = "suffix", Type = "stringView", Nilable = true },
			},

			Returns =
			{
				{ Name = "text", Type = "string", Nilable = false },
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