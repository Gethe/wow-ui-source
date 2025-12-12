local Os =
{
	Name = "Os",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "CopyToClipboard",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "removeMarkup", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "length", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTimePreciseSec",
			Type = "Function",

			Returns =
			{
				{ Name = "time", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Os);