local AutoComplete =
{
	Name = "AutoComplete",
	Type = "System",
	Namespace = "C_AutoComplete",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetAutoCompletePresenceID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "presenceID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetAutoCompleteRealms",
			Type = "Function",

			Returns =
			{
				{ Name = "realms", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "GetAutoCompleteResults",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "numResults", Type = "number", Nilable = false },
				{ Name = "cursorPosition", Type = "number", Nilable = false },
				{ Name = "allowFullMatch", Type = "bool", Nilable = false },
				{ Name = "includeFlags", Type = "number", Nilable = false },
				{ Name = "excludeFlags", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "results", Type = "table", InnerType = "AutoCompleteResult", Nilable = false },
			},
		},
		{
			Name = "IsRecognizedName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "includeFlags", Type = "number", Nilable = false },
				{ Name = "excludeFlags", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRecognizedName", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "AutoCompleteResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "priority", Type = "AutoCompletePriority", Nilable = false },
				{ Name = "bnetID", Type = "number", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(AutoComplete);