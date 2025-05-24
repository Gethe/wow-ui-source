local WarbandSceneInfo =
{
	Name = "WarbandSceneInfo",
	Type = "System",
	Namespace = "C_WarbandScene",

	Functions =
	{
		{
			Name = "GetRandomEntryID",
			Type = "Function",

			Returns =
			{
				{ Name = "warbandSceneID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetWarbandSceneEntry",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "warbandSceneID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "warbandSceneEntry", Type = "WarbandSceneEntry", Nilable = false },
			},
		},
		{
			Name = "HasWarbandScene",
			Type = "Function",

			Arguments =
			{
				{ Name = "warbandSceneID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "owned", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "warbandSceneID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "favorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SearchWarbandSceneEntries",
			Type = "Function",

			Arguments =
			{
				{ Name = "searchParams", Type = "WarbandSceneSearchInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "matchingEntryIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "SetFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "warbandSceneID", Type = "number", Nilable = false },
				{ Name = "favorite", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "NewWarbandSceneAdded",
			Type = "Event",
			LiteralName = "NEW_WARBAND_SCENE_ADDED",
			Payload =
			{
				{ Name = "warbandScenID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "WarbandSceneFavoritesUpdated",
			Type = "Event",
			LiteralName = "WARBAND_SCENE_FAVORITES_UPDATED",
		},
	},

	Tables =
	{
		{
			Name = "WarbandSceneEntry",
			Type = "Structure",
			Fields =
			{
				{ Name = "warbandSceneID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "source", Type = "cstring", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false, Default = false },
				{ Name = "hasFanfare", Type = "bool", Nilable = false, Default = false },
				{ Name = "sourceType", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "WarbandSceneSearchInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ownedOnly", Type = "bool", Nilable = false, Default = false },
				{ Name = "favoritesOnly", Type = "bool", Nilable = false, Default = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WarbandSceneInfo);