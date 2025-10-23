local LoadingScreen =
{
	Name = "LoadingScreen",
	Type = "System",
	Namespace = "C_LoadingScreen",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "LoadingScreenDisabled",
			Type = "Event",
			LiteralName = "LOADING_SCREEN_DISABLED",
			SynchronousEvent = true,
		},
		{
			Name = "LoadingScreenEnabled",
			Type = "Event",
			LiteralName = "LOADING_SCREEN_ENABLED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(LoadingScreen);