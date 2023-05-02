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
				{ Name = "mapID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCurrentTrackingTarget",
			Type = "Function",

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
				{ Name = "mapInfo", Type = "ContentTrackingMapInfo", Nilable = false },
			},
		},
		{
			Name = "GetObjectiveText",
			Type = "Function",

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
			Name = "IsNavigable",
			Type = "Function",
			Documentation = { "Returns if the trackable is either on your current map, or if we're able to determine a route to that map from your location via waypoints." },

			Arguments =
			{
				{ Name = "trackableType", Type = "ContentTrackingType", Nilable = false },
				{ Name = "trackableID", Type = "number", Nilable = false },
			},

			Returns =
			{
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
			},
		},
		{
			Name = "ToggleTracking",
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
	},

	Events =
	{
		{
			Name = "CollectableEntryUpdate",
			Type = "Event",
			LiteralName = "COLLECTABLE_ENTRY_UPDATE",
			Payload =
			{
				{ Name = "collectableEntryID", Type = "number", Nilable = false },
			},
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
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ContentTracking);