local LuaStringExtensions =
{
	Name = "LuaStringExtensions",
	Type = "System",
	Namespace = "string",
	Environment = "All",

	Functions =
	{
		{
			Name = "ltrim",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns a string with all bytes in the specified character set removed from the start." },

			Arguments =
			{
				{ Name = "str", Type = "stringView", Nilable = false, Documentation = { "The string to trim." } },
				{ Name = "characters", Type = "stringView", Nilable = false, Default = " \\r\\n\\t", Documentation = { "The set of bytes to remove." } },
			},

			Returns =
			{
				{ Name = "trimmed", Type = "stringView", Nilable = false, Documentation = { "The left-trimmed string." } },
			},
		},
		{
			Name = "rtrim",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns a string with all bytes in the specified character set removed from the end." },

			Arguments =
			{
				{ Name = "str", Type = "stringView", Nilable = false, Documentation = { "The string to trim." } },
				{ Name = "characters", Type = "stringView", Nilable = false, Default = " \\r\\n\\t", Documentation = { "The set of bytes to remove." } },
			},

			Returns =
			{
				{ Name = "trimmed", Type = "stringView", Nilable = false, Documentation = { "The right-trimmed string." } },
			},
		},
		{
			Name = "contains",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a string contains the specified literal substring." },

			Arguments =
			{
				{ Name = "str", Type = "stringView", Nilable = false, Documentation = { "The string to search." } },
				{ Name = "substring", Type = "stringView", Nilable = false, Documentation = { "The literal substring for which to search." } },
			},

			Returns =
			{
				{ Name = "contains", Type = "bool", Nilable = false, Documentation = { "True if the string contains the specified substring; otherwise false." } },
			},
		},
		{
			Name = "endswith",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a string ends with the specified suffix." },

			Arguments =
			{
				{ Name = "str", Type = "stringView", Nilable = false, Documentation = { "The string to inspect." } },
				{ Name = "suffix", Type = "stringView", Nilable = false, Documentation = { "The suffix for which to search." } },
			},

			Returns =
			{
				{ Name = "endsWith", Type = "bool", Nilable = false, Documentation = { "True if the string ends with the specified suffix; otherwise false." } },
			},
		},
		{
			Name = "startswith",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a string starts with the specified prefix." },

			Arguments =
			{
				{ Name = "str", Type = "stringView", Nilable = false, Documentation = { "The string to inspect." } },
				{ Name = "prefix", Type = "stringView", Nilable = false, Documentation = { "The prefix for which to search." } },
			},

			Returns =
			{
				{ Name = "startsWith", Type = "bool", Nilable = false, Documentation = { "True if the string starts with the specified prefix; otherwise false." } },
			},
		},
		{
			Name = "trim",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns a string with all bytes in the specified character set removed from both ends." },

			Arguments =
			{
				{ Name = "str", Type = "stringView", Nilable = false, Documentation = { "The string to trim." } },
				{ Name = "characters", Type = "stringView", Nilable = false, Default = " \\r\\n\\t", Documentation = { "The set of bytes to remove." } },
			},

			Returns =
			{
				{ Name = "trimmed", Type = "stringView", Nilable = false, Documentation = { "The trimmed string." } },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(LuaStringExtensions);