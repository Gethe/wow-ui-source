local ContentTracking =
{
	Name = "ContentTracking",
	Type = "System",
	Namespace = "C_ContentTracking",

	Functions =
	{
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
				{ Name = "targetSubInfo", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetEncounterTrackingInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "journalEncounterID", Type = "number", Nilable = false },
				{ Name = "difficultyID", Type = "number", Nilable = true },
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
				{ Name = "creatureID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "vendorTrackingInfo", Type = "VendorTrackingInfo", Nilable = false },
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
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ContentTracking);