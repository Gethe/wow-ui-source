local SuperTrackManager =
{
	Name = "SuperTrackManager",
	Type = "System",
	Namespace = "C_SuperTrack",

	Functions =
	{
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
		{
			Name = "SuperTrackingType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Quest", Type = "SuperTrackingType", EnumValue = 1 },
				{ Name = "UserWaypoint", Type = "SuperTrackingType", EnumValue = 2 },
				{ Name = "Corpse", Type = "SuperTrackingType", EnumValue = 4 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SuperTrackManager);