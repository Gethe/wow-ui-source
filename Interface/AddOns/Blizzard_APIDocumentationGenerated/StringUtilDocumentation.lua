local StringUtil =
{
	Name = "StringUtil",
	Type = "System",
	Namespace = "C_StringUtil",
	Environment = "All",

	Functions =
	{
		{
			Name = "EscapeLuaFormatString",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Returns a string with Lua format string tokens ('%') escaped." },

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "escapedText", Type = "stringView", Nilable = false },
			},
		},
		{
			Name = "EscapeLuaPatterns",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Returns a string with all Lua pattern characters escaped." },

			Arguments =
			{
				{ Name = "text", Type = "stringView", Nilable = false },
			},

			Returns =
			{
				{ Name = "escapedText", Type = "string", Nilable = false },
			},
		},
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
			Name = "RemoveContiguousSpaces",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Returns a string with all contiguous occurrences of ASCII space characters truncated." },

			Arguments =
			{
				{ Name = "text", Type = "stringView", Nilable = false },
				{ Name = "maxAllowedSpaces", Type = "number", Nilable = false, Documentation = { "Maximum number of permitted contiguous space characters; excessive spaces will be truncated to this count." } },
			},

			Returns =
			{
				{ Name = "trimmedText", Type = "string", Nilable = false },
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
			Name = "trim",
			Type = "Function",
			Namespace = "string",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns a string with all bytes in the 'characters' set removed from the start and end." },

			Arguments =
			{
				{ Name = "str", Type = "stringView", Nilable = false },
				{ Name = "characters", Type = "stringView", Nilable = false, Default = " \\r\\n\\t" },
			},

			Returns =
			{
				{ Name = "trimmed", Type = "stringView", Nilable = false },
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