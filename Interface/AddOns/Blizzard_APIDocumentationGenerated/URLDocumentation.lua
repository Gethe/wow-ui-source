local URL =
{
	Name = "URL",
	Type = "System",

	Functions =
	{
		{
			Name = "LaunchURL",
			Type = "Function",
			HasRestrictions = true,

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