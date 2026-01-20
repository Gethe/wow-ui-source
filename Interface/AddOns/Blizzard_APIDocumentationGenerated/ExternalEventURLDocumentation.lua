local ExternalEventURL =
{
	Name = "ExternalEventURL",
	Type = "System",
	Namespace = "C_ExternalEventURL",
	Environment = "All",

	Functions =
	{
		{
			Name = "HasURL",
			Type = "Function",

			Returns =
			{
				{ Name = "hasURL", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsNew",
			Type = "Function",

			Returns =
			{
				{ Name = "isNew", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LaunchURL",
			Type = "Function",
			HasRestrictions = true,
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ExternalEventURL);