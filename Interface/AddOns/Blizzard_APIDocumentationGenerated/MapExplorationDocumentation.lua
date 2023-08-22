local MapExploration =
{
	Name = "MapExplorationInfo",
	Type = "System",
	Namespace = "C_MapExplorationInfo",

	Functions =
	{
		{
			Name = "GetExploredAreaIDsAtPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "normalizedPosition", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "areaID", Type = "table", InnerType = "number", Nilable = true },
			},
		},
		{
			Name = "GetExploredMapTextures",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "overlayInfo", Type = "table", InnerType = "UiMapExplorationInfo", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "MapExplorationUpdated",
			Type = "Event",
			LiteralName = "MAP_EXPLORATION_UPDATED",
		},
	},

	Tables =
	{
		{
			Name = "UiMapExplorationHitRect",
			Type = "Structure",
			Fields =
			{
				{ Name = "top", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "right", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UiMapExplorationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "textureWidth", Type = "number", Nilable = false },
				{ Name = "textureHeight", Type = "number", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
				{ Name = "isShownByMouseOver", Type = "bool", Nilable = false },
				{ Name = "isDrawOnTopLayer", Type = "bool", Nilable = false },
				{ Name = "fileDataIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "hitRect", Type = "UiMapExplorationHitRect", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MapExploration);