local GameEnvironmentManager =
{
	Name = "GameEnvironmentManager",
	Type = "System",
	Namespace = "C_GameEnvironmentManager",

	Functions =
	{
		{
			Name = "GetCurrentGameEnvironment",
			Type = "Function",

			Returns =
			{
				{ Name = "gameEnvironment", Type = "GameEnvironment", Nilable = false },
			},
		},
		{
			Name = "RequestGameEnvironment",
			Type = "Function",

			Arguments =
			{
				{ Name = "gameEnvironment", Type = "GameEnvironment", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "GameEnvironmentSwitched",
			Type = "Event",
			LiteralName = "GAME_ENVIRONMENT_SWITCHED",
			Payload =
			{
				{ Name = "gameEnvironment", Type = "GameEnvironment", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(GameEnvironmentManager);