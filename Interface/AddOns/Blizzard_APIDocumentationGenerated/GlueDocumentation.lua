local Glue =
{
	Name = "Glue",
	Type = "System",

	Functions =
	{
		{
			Name = "IsOnGlueScreen",
			Type = "Function",

			Returns =
			{
				{ Name = "isOnGlueScreen", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Glue);