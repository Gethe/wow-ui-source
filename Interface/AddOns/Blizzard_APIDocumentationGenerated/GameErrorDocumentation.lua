local GameError =
{
	Name = "GameError",
	Type = "System",

	Functions =
	{
		{
			Name = "GetGameMessageInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "gameErrorIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "errorName", Type = "cstring", Nilable = false },
				{ Name = "soundKitID", Type = "number", Nilable = true },
				{ Name = "voiceID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "NotWhileDeadError",
			Type = "Function",
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(GameError);