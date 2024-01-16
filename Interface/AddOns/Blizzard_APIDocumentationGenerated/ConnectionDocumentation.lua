local Connection =
{
	Name = "ConnectionScript",
	Type = "System",

	Functions =
	{
		{
			Name = "SelectedRealmName",
			Type = "Function",

			Returns =
			{
				{ Name = "selectedRealmName", Type = "cstring", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Connection);