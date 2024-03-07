local AreaPoiInfo =
{
	Name = "AreaPoiInfo",
	Type = "System",
	Namespace = "C_AreaPoiInfo",

	Functions =
	{
		{
			Name = "GetAreaPOIForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "areaPoiIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetAreaPOIInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "areaPoiID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "poiInfo", Type = "AreaPOIInfo", Nilable = false },
			},
		},
		{
			Name = "GetAreaPOITimeLeft",
			Type = "Function",
			Documentation = { "Returns the number of minutes until the POI expires." },

			Arguments =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "minutesLeft", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsAreaPOITimed",
			Type = "Function",
			Documentation = { "This statically determines if the POI is timed, GetAreaPOITimeLeft retrieves the value from the server and may return nothing for long intervals" },

			Arguments =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
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
			Name = "AreaPoisUpdated",
			Type = "Event",
			LiteralName = "AREA_POIS_UPDATED",
		},
	},

	Tables =
	{
		{
			Name = "AreaPOIInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
				{ Name = "position", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = true },
				{ Name = "textureIndex", Type = "number", Nilable = true },
				{ Name = "tooltipWidgetSet", Type = "number", Nilable = true },
				{ Name = "iconWidgetSet", Type = "number", Nilable = true },
				{ Name = "atlasName", Type = "string", Nilable = true },
				{ Name = "shouldGlow", Type = "bool", Nilable = false },
				{ Name = "factionID", Type = "number", Nilable = true },
				{ Name = "isPrimaryMapForPOI", Type = "bool", Nilable = false },
				{ Name = "isAlwaysOnFlightmap", Type = "bool", Nilable = false },
				{ Name = "addPaddingAboveTooltipWidgets", Type = "bool", Nilable = true },
				{ Name = "highlightWorldQuestsOnHover", Type = "bool", Nilable = false },
				{ Name = "highlightVignettesOnHover", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AreaPoiInfo);