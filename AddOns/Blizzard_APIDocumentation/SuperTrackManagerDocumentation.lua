local SuperTrackManager =
{
	Name = "SuperTrackManager",
	Type = "System",
	Namespace = "C_SuperTrack",

	Functions =
	{
		{
			Name = "GetHighestPrioritySuperTrackingType",
			Type = "Function",

			Returns =
			{
				{ Name = "type", Type = "SuperTrackingType", Nilable = true },
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
			Name = "IsSuperTrackingAnything",
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
	},

	Events =
	{
		{
			Name = "SuperTrackingChanged",
			Type = "Event",
			LiteralName = "SUPER_TRACKING_CHANGED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SuperTrackManager);