local ContentTracking =
{
	Name = "ContentTracking",
	Type = "System",
	Namespace = "C_ContentTracking",

	Functions =
	{
		{
			Name = "GetBestMapForTrackable",
			Type = "Function",

			Arguments =
			{
				{ Name = "trackableType", Type = "ContentTrackingType", Nilable = false },
				{ Name = "trackableID", Type = "number", Nilable = false },
				{ Name = "ignoreWaypoint", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "result", Type = "ContentTrackingResult", Nilable = false },
				{ Name = "mapID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCollectableSourceTrackingEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetCollectableSourceTypes",
			Type = "Function",

			Returns =
			{
				{ Name = "collectableSourceTypes", Type = "table", InnerType = "ContentTrackingType", Nilable = false },
			},
		},
		{
			Name = "GetCurrentTrackingTarget",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "type", Type = "ContentTrackingType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "targetType", Type = "ContentTrackingTargetType", Nilable = false },
				{ Name = "targetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEncounterTrackingInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "journalEncounterID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "trackingInfo", Type = "EncounterTrackingInfo", Nilable = false },
			},
		},
		{
			Name = "GetNextWaypointForTrackable",
			Type = "Function",

			Arguments =
			{
				{ Name = "trackableType", Type = "ContentTrackingType", Nilable = false },
				{ Name = "trackableID", Type = "number", Nilable = false },
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "ContentTrackingResult", Nilable = false },
				{ Name = "mapInfo", Type = "ContentTrackingMapInfo", Nilable = true },
			},
		},
		{
			Name = "GetObjectiveText",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "targetType", Type = "ContentTrackingTargetType", Nilable = false },
				{ Name = "targetID", Type = "number", Nilable = false },
				{ Name = "includeHyperlinks", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "objectiveText", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetTitle",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "trackableType", Type = "ContentTrackingType", Nilable = false },
				{ Name = "trackableID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "title", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetTrackablesOnMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "trackableType", Type = "ContentTrackingType", Nilable = false },
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "ContentTrackingResult", Nilable = false },
				{ Name = "trackableMapInfos", Type = "table", InnerType = "ContentTrackingMapInfo", Nilable = false },
			},
		},
		{
			Name = "GetTrackedIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "trackableType", Type = "ContentTrackingType", Nilable = false },
			},

			Returns =
			{
				{ Name = "entryIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetVendorTrackingInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "collectableEntryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "vendorTrackingInfo", Type = "VendorTrackingInfo", Nilable = false },
			},
		},
		{
			Name = "GetWaypointText",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "trackableType", Type = "ContentTrackingType", Nilable = false },
				{ Name = "trackableID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "waypointText", Type = "string", Nilable = false },
			},
		},
		{
			Name = "IsNavigable",
			Type = "Function",
			Documentation = { "If successful, returns if the trackable is either on your current map, or if we're able to determine a route to that map from your location via waypoints." },

			Arguments =
			{
				{ Name = "trackableType", Type = "ContentTrackingType", Nilable = false },
				{ Name = "trackableID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "ContentTrackingResult", Nilable = false },
				{ Name = "isNavigable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTrackable",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "ContentTrackingType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isTrackable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTracking",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "ContentTrackingType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isTracking", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "StartTracking",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "ContentTrackingType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "error", Type = "ContentTrackingError", Nilable = true },
			},
		},
		{
			Name = "StopTracking",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "ContentTrackingType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "stopType", Type = "ContentTrackingStopType", Nilable = false },
			},
		},
		{
			Name = "ToggleTracking",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "ContentTrackingType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "stopType", Type = "ContentTrackingStopType", Nilable = false },
			},

			Returns =
			{
				{ Name = "error", Type = "ContentTrackingError", Nilable = true },
			},
		},
	},

	Events =
	{
		{
			Name = "ContentTrackingIsEnabledUpdate",
			Type = "Event",
			LiteralName = "CONTENT_TRACKING_IS_ENABLED_UPDATE",
			Payload =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ContentTrackingListUpdate",
			Type = "Event",
			LiteralName = "CONTENT_TRACKING_LIST_UPDATE",
		},
		{
			Name = "ContentTrackingUpdate",
			Type = "Event",
			LiteralName = "CONTENT_TRACKING_UPDATE",
			Payload =
			{
				{ Name = "type", Type = "ContentTrackingType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "isTracked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TrackableInfoUpdate",
			Type = "Event",
			LiteralName = "TRACKABLE_INFO_UPDATE",
			Payload =
			{
				{ Name = "type", Type = "ContentTrackingType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TrackingTargetInfoUpdate",
			Type = "Event",
			LiteralName = "TRACKING_TARGET_INFO_UPDATE",
			Payload =
			{
				{ Name = "targetType", Type = "ContentTrackingTargetType", Nilable = false },
				{ Name = "targetID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ContentTracking);