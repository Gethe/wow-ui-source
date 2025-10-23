local AdventureMap =
{
	Name = "AdventureMap",
	Type = "System",
	Namespace = "C_AdventureMap",

	Functions =
	{
		{
			Name = "GetAdventureMapTextureKit",
			Type = "Function",

			Returns =
			{
				{ Name = "adventureMapTextureKit", Type = "textureKit", Nilable = false },
			},
		},
		{
			Name = "GetQuestPortraitInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "AdventureMapQuestPortraitInfo", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AdventureMapClose",
			Type = "Event",
			LiteralName = "ADVENTURE_MAP_CLOSE",
			SynchronousEvent = true,
		},
		{
			Name = "AdventureMapOpen",
			Type = "Event",
			LiteralName = "ADVENTURE_MAP_OPEN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "followerTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AdventureMapQuestUpdate",
			Type = "Event",
			LiteralName = "ADVENTURE_MAP_QUEST_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AdventureMapUpdateInsets",
			Type = "Event",
			LiteralName = "ADVENTURE_MAP_UPDATE_INSETS",
			UniqueEvent = true,
		},
		{
			Name = "AdventureMapUpdatePois",
			Type = "Event",
			LiteralName = "ADVENTURE_MAP_UPDATE_POIS",
			UniqueEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "AdventureMapQuestPortraitInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "portraitDisplayID", Type = "number", Nilable = false },
				{ Name = "mountPortraitDisplayID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "modelSceneID", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AdventureMap);