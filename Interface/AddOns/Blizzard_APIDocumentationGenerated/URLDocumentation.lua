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
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(URL);