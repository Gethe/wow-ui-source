local Os =
{
	Name = "Os",
	Type = "System",

	Functions =
	{
		{
			Name = "CopyToClipboard",
			Type = "Function",

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