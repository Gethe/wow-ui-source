local Glue =
{
	Name = "Glue",
	Type = "System",
	Namespace = "C_Glue",

	Functions =
	{
		{
			Name = "IsFirstLoadThisSession",
			Type = "Function",

			Returns =
			{
				{ Name = "IsFirstLoadThisSession", Type = "bool", Nilable = false },
			},
		},
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