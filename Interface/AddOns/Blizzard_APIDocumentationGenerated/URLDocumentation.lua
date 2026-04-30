local URL =
{
	Name = "URL",
	Type = "System",
	Environment = "All",

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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(URL);