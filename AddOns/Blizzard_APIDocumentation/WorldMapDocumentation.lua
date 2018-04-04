local WorldMap =
{
	Name = "WorldMap",
	Type = "System",
	Namespace = "C_WorldMap",

	Functions =
	{
		{
			Name = "GetAreaPOIForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapAreaID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "areaPOIs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetAreaPOIInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapAreaID", Type = "number", Nilable = false },
				{ Name = "areaPOIID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "poiInfo", Type = "AreaPOIInfo", Nilable = false },
			},
		},
		{
			Name = "GetAreaPOITimeLeft",
			Type = "Function",

			Arguments =
			{
				{ Name = "areaPOIID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "minutesLeft", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMapLandmarkInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "landmarkType", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "textureIndex", Type = "number", Nilable = true },
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "mapLinkID", Type = "number", Nilable = true },
				{ Name = "inBattleMap", Type = "bool", Nilable = true },
				{ Name = "graveyardID", Type = "number", Nilable = true },
				{ Name = "areaID", Type = "number", Nilable = true },
				{ Name = "poiID", Type = "number", Nilable = true },
				{ Name = "isObjectIcon", Type = "bool", Nilable = true },
				{ Name = "atlasName", Type = "string", Nilable = true },
				{ Name = "displayAsBanner", Type = "bool", Nilable = true },
				{ Name = "textureKitPrefix", Type = "string", Nilable = true },
				{ Name = "useMouseOverTooltip", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "IsAreaPOITimed",
			Type = "Function",
			Documentation = { "This statically determines if the POI is timed, GetAreaPOITimeLeft retrieves the value from the server and may return nothing for long intervals" },

			Arguments =
			{
				{ Name = "areaPOIID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isTimed", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CemeteryPreferenceUpdated",
			Type = "Event",
			LiteralName = "CEMETERY_PREFERENCE_UPDATED",
		},
		{
			Name = "CloseWorldMap",
			Type = "Event",
			LiteralName = "CLOSE_WORLD_MAP",
		},
		{
			Name = "MapBarUpdate",
			Type = "Event",
			LiteralName = "MAP_BAR_UPDATE",
		},
		{
			Name = "NewWmoChunk",
			Type = "Event",
			LiteralName = "NEW_WMO_CHUNK",
		},
		{
			Name = "WorldMapUpdate",
			Type = "Event",
			LiteralName = "WORLD_MAP_UPDATE",
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
			Name = "AreaPOIInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "textureIndex", Type = "number", Nilable = true },
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "mapLinkID", Type = "number", Nilable = true },
				{ Name = "inBattleMap", Type = "bool", Nilable = true },
				{ Name = "graveyardID", Type = "number", Nilable = true },
				{ Name = "areaID", Type = "number", Nilable = true },
				{ Name = "poiID", Type = "number", Nilable = true },
				{ Name = "isObjectIcon", Type = "bool", Nilable = true },
				{ Name = "atlasName", Type = "string", Nilable = true },
				{ Name = "displayAsBanner", Type = "bool", Nilable = true },
				{ Name = "textureKitPrefix", Type = "string", Nilable = true },
				{ Name = "useMouseOverTooltip", Type = "bool", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WorldMap);