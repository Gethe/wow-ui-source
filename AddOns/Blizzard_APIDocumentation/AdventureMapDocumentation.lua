local AdventureMap =
{
	Name = "AdventureMap",
	Type = "System",
	Namespace = "C_AdventureMap",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "AdventureMapClose",
			Type = "Event",
			LiteralName = "ADVENTURE_MAP_CLOSE",
		},
		{
			Name = "AdventureMapOpen",
			Type = "Event",
			LiteralName = "ADVENTURE_MAP_OPEN",
			Payload =
			{
				{ Name = "followerTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AdventureMapQuestUpdate",
			Type = "Event",
			LiteralName = "ADVENTURE_MAP_QUEST_UPDATE",
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AdventureMapUpdateInsets",
			Type = "Event",
			LiteralName = "ADVENTURE_MAP_UPDATE_INSETS",
		},
		{
			Name = "AdventureMapUpdatePois",
			Type = "Event",
			LiteralName = "ADVENTURE_MAP_UPDATE_POIS",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(AdventureMap);