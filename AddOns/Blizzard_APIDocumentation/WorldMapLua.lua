local WorldMapLua =
{
	Name = "WorldMap",
	Type = "System",
	Namespace = "C_WorldMap",

	Functions =
	{
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
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(WorldMapLua);