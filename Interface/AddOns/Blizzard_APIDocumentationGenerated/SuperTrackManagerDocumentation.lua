local SuperTrackManager =
{
	Name = "SuperTrackManager",
	Type = "System",
	Namespace = "C_SuperTrack",

	Functions =
	{
		{
			Name = "ClearAllSuperTracked",
			Type = "Function",
		},
		{
			Name = "ClearSuperTrackedContent",
			Type = "Function",
		},
		{
			Name = "ClearSuperTrackedMapPin",
			Type = "Function",
		},
		{
			Name = "GetHighestPrioritySuperTrackingType",
			Type = "Function",

			Returns =
			{
				{ Name = "type", Type = "SuperTrackingType", Nilable = true },
			},
		},
		{
			Name = "GetNextWaypointForMap",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "waypointDescription", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetSuperTrackedContent",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "trackableType", Type = "ContentTrackingType", Nilable = false },
				{ Name = "trackableID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSuperTrackedItemName",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetSuperTrackedMapPin",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "type", Type = "SuperTrackingMapPinType", Nilable = false },
				{ Name = "typeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSuperTrackedQuestID",
			Type = "Function",

			Returns =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSuperTrackedVignette",
			Type = "Function",

			Returns =
			{
				{ Name = "vignetteGUID", Type = "WOWGUID", Nilable = true },
			},
		},
		{
			Name = "IsSuperTrackingAnything",
			Type = "Function",

			Returns =
			{
				{ Name = "isSuperTracking", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSuperTrackingContent",
			Type = "Function",

			Returns =
			{
				{ Name = "isSuperTracking", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSuperTrackingCorpse",
			Type = "Function",

			Returns =
			{
				{ Name = "isSuperTracking", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSuperTrackingMapPin",
			Type = "Function",

			Returns =
			{
				{ Name = "isSuperTracking", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSuperTrackingQuest",
			Type = "Function",

			Returns =
			{
				{ Name = "isSuperTracking", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSuperTrackingUserWaypoint",
			Type = "Function",

			Returns =
			{
				{ Name = "isSuperTracking", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSuperTrackedContent",
			Type = "Function",

			Arguments =
			{
				{ Name = "trackableType", Type = "ContentTrackingType", Nilable = false },
				{ Name = "trackableID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSuperTrackedMapPin",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "SuperTrackingMapPinType", Nilable = false },
				{ Name = "typeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSuperTrackedQuestID",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSuperTrackedUserWaypoint",
			Type = "Function",

			Arguments =
			{
				{ Name = "superTracked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSuperTrackedVignette",
			Type = "Function",

			Arguments =
			{
				{ Name = "vignetteGUID", Type = "WOWGUID", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SuperTrackingChanged",
			Type = "Event",
			LiteralName = "SUPER_TRACKING_CHANGED",
		},
		{
			Name = "SuperTrackingPathUpdated",
			Type = "Event",
			LiteralName = "SUPER_TRACKING_PATH_UPDATED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SuperTrackManager);