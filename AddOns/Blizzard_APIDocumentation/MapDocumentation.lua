local Map =
{
	Name = "MapUI",
	Type = "System",
	Namespace = "C_Map",

	Functions =
	{
		{
			Name = "GetCurrentMapID",
			Type = "Function",

			Returns =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMapArtBackgroundTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "texture", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMapArtHelpTextPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "position", Type = "MapCanvasPosition", Nilable = false },
			},
		},
		{
			Name = "GetMapArtLayerTextures",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "layerIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "textures", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetMapArtLayers",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "layerInfo", Type = "table", InnerType = "UiMapLayerInfo", Nilable = false },
			},
		},
		{
			Name = "GetMapChildrenInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "mapType", Type = "UIMapType", Nilable = true },
				{ Name = "allDescendants", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "info", Type = "table", InnerType = "UiMapDetails", Nilable = false },
			},
		},
		{
			Name = "GetMapDisplayInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hideIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetMapGroupID",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiMapGroupID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMapGroupMembersInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapGroupID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "table", InnerType = "UiMapGroupMemberInfo", Nilable = false },
			},
		},
		{
			Name = "GetMapHighlightInfoAtPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "fileDataID", Type = "number", Nilable = false },
				{ Name = "texturePercentageX", Type = "number", Nilable = false },
				{ Name = "texturePercentageY", Type = "number", Nilable = false },
				{ Name = "textureX", Type = "number", Nilable = false },
				{ Name = "textureY", Type = "number", Nilable = false },
				{ Name = "scrollChildX", Type = "number", Nilable = false },
				{ Name = "scrollChildY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMapInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "UiMapDetails", Nilable = false },
			},
		},
		{
			Name = "GetMapInfoAtPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "UiMapDetails", Nilable = false },
			},
		},
		{
			Name = "GetMapLevels",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "playerMinLevel", Type = "number", Nilable = false },
				{ Name = "playerMaxLevel", Type = "number", Nilable = false },
				{ Name = "petMinLevel", Type = "number", Nilable = false, Default = 0 },
				{ Name = "petMaxLevel", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "GetMapOverlayNameAtPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetMapRectOnMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "topUiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "minX", Type = "number", Nilable = false },
				{ Name = "maxX", Type = "number", Nilable = false },
				{ Name = "minY", Type = "number", Nilable = false },
				{ Name = "maxY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "MapCanvasPosition",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "MapCanvasPosition", EnumValue = 0 },
				{ Name = "BottomLeft", Type = "MapCanvasPosition", EnumValue = 1 },
				{ Name = "BottomRight", Type = "MapCanvasPosition", EnumValue = 2 },
				{ Name = "TopLeft", Type = "MapCanvasPosition", EnumValue = 3 },
				{ Name = "TopRight", Type = "MapCanvasPosition", EnumValue = 4 },
			},
		},
		{
			Name = "UIMapType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Cosmic", Type = "UIMapType", EnumValue = 0 },
				{ Name = "World", Type = "UIMapType", EnumValue = 1 },
				{ Name = "Continent", Type = "UIMapType", EnumValue = 2 },
				{ Name = "Zone", Type = "UIMapType", EnumValue = 3 },
				{ Name = "Dungeon", Type = "UIMapType", EnumValue = 4 },
				{ Name = "Micro", Type = "UIMapType", EnumValue = 5 },
				{ Name = "Orphan", Type = "UIMapType", EnumValue = 6 },
			},
		},
		{
			Name = "UIMapSystem",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "World", Type = "UIMapSystem", EnumValue = 0 },
				{ Name = "Taxi", Type = "UIMapSystem", EnumValue = 1 },
				{ Name = "Adventure", Type = "UIMapSystem", EnumValue = 2 },
			},
		},
		{
			Name = "UiMapLayerInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "layerWidth", Type = "number", Nilable = false },
				{ Name = "layerHeight", Type = "number", Nilable = false },
				{ Name = "tileWidth", Type = "number", Nilable = false },
				{ Name = "tileHeight", Type = "number", Nilable = false },
				{ Name = "minScale", Type = "number", Nilable = false },
				{ Name = "maxScale", Type = "number", Nilable = false },
				{ Name = "additionalZoomSteps", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UiMapDetails",
			Type = "Structure",
			Fields =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "mapType", Type = "UIMapType", Nilable = false },
				{ Name = "parentMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UiMapGroupMemberInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "relativeHeightIndex", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Map);