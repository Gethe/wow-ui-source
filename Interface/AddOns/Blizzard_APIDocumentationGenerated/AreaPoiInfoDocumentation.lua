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
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = true },
				{ Name = "areaPoiID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "poiInfo", Type = "AreaPOIInfo", Nilable = false },
			},
		},
		{
			Name = "GetAreaPOISecondsLeft",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns the number of seconds until the POI expires." },

			Arguments =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "secondsLeft", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDelvesForMap",
			Type = "Function",
			Documentation = { "Returns all area POIInfos flagged as delves for the given map." },

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
			Name = "GetDragonridingRacesForMap",
			Type = "Function",
			Documentation = { "Returns all area POIInfos flagged as dragonriding races for the given map." },

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
			Name = "GetEventsForMap",
			Type = "Function",
			Documentation = { "Returns all area POIInfos flagged as events for the given map." },

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
			Name = "GetQuestHubsForMap",
			Type = "Function",
			Documentation = { "Returns all area POIInfos flagged as quest hubs for the given map." },

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
				{ Name = "hideTimerInTooltip", Type = "bool", Nilable = true },
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
				{ Name = "linkedUiMapID", Type = "number", Nilable = true },
				{ Name = "textureIndex", Type = "number", Nilable = true },
				{ Name = "tooltipWidgetSet", Type = "number", Nilable = true },
				{ Name = "iconWidgetSet", Type = "number", Nilable = true },
				{ Name = "atlasName", Type = "string", Nilable = true },
				{ Name = "uiTextureKit", Type = "textureKit", Nilable = true },
				{ Name = "shouldGlow", Type = "bool", Nilable = false },
				{ Name = "factionID", Type = "number", Nilable = true },
				{ Name = "isPrimaryMapForPOI", Type = "bool", Nilable = false },
				{ Name = "isAlwaysOnFlightmap", Type = "bool", Nilable = false },
				{ Name = "addPaddingAboveTooltipWidgets", Type = "bool", Nilable = true },
				{ Name = "highlightWorldQuestsOnHover", Type = "bool", Nilable = false },
				{ Name = "highlightVignettesOnHover", Type = "bool", Nilable = false },
				{ Name = "isCurrentEvent", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AreaPoiInfo);