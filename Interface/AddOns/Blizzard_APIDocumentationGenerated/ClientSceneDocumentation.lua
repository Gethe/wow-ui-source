local ClientScene =
{
	Name = "ClientScene",
	Type = "System",
	Namespace = "C_ClientScene",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ClientSceneClosed",
			Type = "Event",
			LiteralName = "CLIENT_SCENE_CLOSED",
		},
		{
			Name = "ClientSceneOpened",
			Type = "Event",
			LiteralName = "CLIENT_SCENE_OPENED",
			Payload =
			{
				{ Name = "sceneType", Type = "ClientSceneType", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "ClientSceneType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "DefaultSceneType", Type = "ClientSceneType", EnumValue = 0 },
				{ Name = "MinigameSceneType", Type = "ClientSceneType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ClientScene);