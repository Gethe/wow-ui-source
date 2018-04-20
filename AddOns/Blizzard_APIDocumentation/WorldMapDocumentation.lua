local WorldMap =
{
	Name = "WorldMap",
	Type = "System",
	Namespace = "C_WorldMap",

	Functions =
	{
		{
			Name = "GetMapLandmarkInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "poiInfo", Type = "LandmarkInfo", Nilable = false },
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
			Name = "LandmarkInfo",
			Type = "Structure",
			Fields =
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
				{ Name = "atlasName", Type = "string", Nilable = true },
				{ Name = "displayAsBanner", Type = "bool", Nilable = true },
				{ Name = "textureKitPrefix", Type = "string", Nilable = true },
				{ Name = "useMouseOverTooltip", Type = "bool", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WorldMap);