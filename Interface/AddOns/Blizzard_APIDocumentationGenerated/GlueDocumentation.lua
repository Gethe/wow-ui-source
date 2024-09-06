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
		{
			Name = "AccountCvarsLoaded",
			Type = "Event",
			LiteralName = "ACCOUNT_CVARS_LOADED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Glue);