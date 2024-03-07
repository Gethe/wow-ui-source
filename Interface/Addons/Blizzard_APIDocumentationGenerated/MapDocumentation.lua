local Map =
{
	Name = "MapUI",
	Type = "System",
	Namespace = "C_Map",

	Functions =
	{
		{
			Name = "GetAreaInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "areaID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetBestMapForUnit",
			Type = "Function",
			Documentation = { "Only works for the player and party members." },

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiMapID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetBountySetIDForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "bountySetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFallbackWorldMapID",
			Type = "Function",

			Returns =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMapArtBackgroundAtlas",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "atlasName", Type = "textureAtlas", Nilable = false },
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
			Name = "GetMapArtID",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiMapArtID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMapArtLayerTextures",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "layerIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "textures", Type = "table", InnerType = "fileID", Nilable = false },
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
			Name = "GetMapBannersForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mapBanners", Type = "table", InnerType = "MapBannerInfo", Nilable = false },
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
				{ Name = "fileDataID", Type = "fileID", Nilable = false },
				{ Name = "atlasID", Type = "textureAtlas", Nilable = false },
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
				{ Name = "ignoreZoneMapPositionData", Type = "bool", Nilable = true },
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
			Name = "GetMapLinksForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mapLinks", Type = "table", InnerType = "MapLinkInfo", Nilable = false },
			},
		},
		{
			Name = "GetMapPosFromWorldPos",
			Type = "Function",

			Arguments =
			{
				{ Name = "continentID", Type = "number", Nilable = false },
				{ Name = "worldPosition", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "overrideUiMapID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "mapPosition", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
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
			Name = "GetPlayerMapPosition",
			Type = "Function",
			Documentation = { "Only works for the player and party members." },

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "position", Type = "vector2", Mixin = "Vector2DMixin", Nilable = true },
			},
		},
		{
			Name = "GetWorldPosFromMapPos",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "mapPosition", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "continentID", Type = "number", Nilable = false },
				{ Name = "worldPosition", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
			},
		},
		{
			Name = "MapHasArt",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasArt", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestPreloadMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "NewWmoChunk",
			Type = "Event",
			LiteralName = "NEW_WMO_CHUNK",
		},
		{
			Name = "ZoneChanged",
			Type = "Event",
			LiteralName = "ZONE_CHANGED",
		},
		{
			Name = "ZoneChangedIndoors",
			Type = "Event",
			LiteralName = "ZONE_CHANGED_INDOORS",
		},
		{
			Name = "ZoneChangedNewArea",
			Type = "Event",
			LiteralName = "ZONE_CHANGED_NEW_AREA",
		},
	},

	Tables =
	{
		{
			Name = "MapBannerInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "atlasName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "MapLinkInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
				{ Name = "position", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "atlasName", Type = "string", Nilable = false },
				{ Name = "linkedUiMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UiMapDetails",
			Type = "Structure",
			Fields =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
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
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UiMapHighlightInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "fileDataID", Type = "fileID", Nilable = false },
				{ Name = "atlasID", Type = "textureAtlas", Nilable = false },
				{ Name = "texturePercentageX", Type = "number", Nilable = false },
				{ Name = "texturePercentageY", Type = "number", Nilable = false },
				{ Name = "textureX", Type = "number", Nilable = false },
				{ Name = "textureY", Type = "number", Nilable = false },
				{ Name = "scrollChildX", Type = "number", Nilable = false },
				{ Name = "scrollChildY", Type = "number", Nilable = false },
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
	},
};

APIDocumentation:AddDocumentationTable(Map);