local URL =
{
	Name = "URL",
	Type = "System",

	Functions =
	{
		{
			Name = "LaunchURL",
			Type = "Function",

			Arguments =
			{
				{ Name = "url", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LoadURLIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "param", Type = "number", Nilable = true },
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

APIDocumentation:AddDocumentationTable(URL);