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
		{
			Name = "GetFeatureSetting",
			Type = "Function",

			Arguments =
			{
				{ Name = "feature", Type = "GameModeFeatureSetting", Nilable = false },
			},

			Returns =
			{
				{ Name = "featureSetting", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsFeatureEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "feature", Type = "GameModeFeatureSetting", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFeatureEnabled", Type = "bool", Nilable = false },
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