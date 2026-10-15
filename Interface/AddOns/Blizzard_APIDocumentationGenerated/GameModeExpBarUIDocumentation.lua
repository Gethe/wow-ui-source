local GameModeExpBarUI =
{
	Name = "GameModeExpBarUI",
	Type = "System",
	Namespace = "C_GameModeExpBar",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetCurrentLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrentXP",
			Type = "Function",

			Returns =
			{
				{ Name = "xp", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxXPForLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "maxXP", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "GameModeExpBarDataUpdated",
			Type = "Event",
			LiteralName = "GAME_MODE_EXP_BAR_DATA_UPDATED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(GameModeExpBarUI);