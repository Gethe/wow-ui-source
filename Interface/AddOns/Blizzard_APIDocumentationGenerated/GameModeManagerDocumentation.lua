local GameModeManager =
{
	Name = "GameModeManager",
	Type = "System",
	Namespace = "C_GameModeManager",

	Functions =
	{
		{
			Name = "GetCurrentGameMode",
			Type = "Function",

			Returns =
			{
				{ Name = "gameMode", Type = "GameMode", Nilable = false },
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

APIDocumentation:AddDocumentationTable(GameModeManager);