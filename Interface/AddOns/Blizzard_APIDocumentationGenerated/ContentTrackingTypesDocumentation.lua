local ContentTrackingTypes =
{
	Tables =
	{
		{
			Name = "ContentTrackingError",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Untrackable", Type = "ContentTrackingError", EnumValue = 0 },
				{ Name = "MaxTracked", Type = "ContentTrackingError", EnumValue = 1 },
				{ Name = "AlreadyTracked", Type = "ContentTrackingError", EnumValue = 2 },
			},
		},
		{
			Name = "ContentTrackingResult",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Success", Type = "ContentTrackingResult", EnumValue = 0 },
				{ Name = "DataPending", Type = "ContentTrackingResult", EnumValue = 1 },
				{ Name = "Failure", Type = "ContentTrackingResult", EnumValue = 2 },
			},
		},
		{
			Name = "ContentTrackingStopType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Invalidated", Type = "ContentTrackingStopType", EnumValue = 0 },
				{ Name = "Collected", Type = "ContentTrackingStopType", EnumValue = 1 },
				{ Name = "Manual", Type = "ContentTrackingStopType", EnumValue = 2 },
			},
		},
		{
			Name = "ContentTrackingTargetType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "JournalEncounter", Type = "ContentTrackingTargetType", EnumValue = 0 },
				{ Name = "Vendor", Type = "ContentTrackingTargetType", EnumValue = 1 },
				{ Name = "Achievement", Type = "ContentTrackingTargetType", EnumValue = 2 },
				{ Name = "Profession", Type = "ContentTrackingTargetType", EnumValue = 3 },
				{ Name = "Quest", Type = "ContentTrackingTargetType", EnumValue = 4 },
			},
		},
		{
			Name = "ContentTrackingType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Appearance", Type = "ContentTrackingType", EnumValue = 0 },
				{ Name = "Mount", Type = "ContentTrackingType", EnumValue = 1 },
				{ Name = "Achievement", Type = "ContentTrackingType", EnumValue = 2 },
			},
		},
		{
			Name = "ContentTrackingConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "MaxTrackedCollectableSources", Type = "number", Value = 15 },
				{ Name = "MaxTrackedAchievements", Type = "number", Value = 10 },
			},
		},
		{
			Name = "ContentTrackingMapInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "trackableType", Type = "ContentTrackingType", Nilable = false },
				{ Name = "trackableID", Type = "number", Nilable = false },
				{ Name = "targetType", Type = "ContentTrackingTargetType", Nilable = false },
				{ Name = "targetID", Type = "number", Nilable = false },
				{ Name = "waypointText", Type = "string", Nilable = false },
			},
		},
		{
			Name = "EncounterTrackingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "encounterName", Type = "cstring", Nilable = false },
				{ Name = "journalEncounterID", Type = "number", Nilable = true },
				{ Name = "journalInstanceID", Type = "number", Nilable = true },
				{ Name = "instanceName", Type = "cstring", Nilable = false },
				{ Name = "subText", Type = "cstring", Nilable = true },
				{ Name = "difficultyID", Type = "number", Nilable = true },
				{ Name = "lfgDungeonID", Type = "number", Nilable = true },
				{ Name = "groupFinderActivityID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "VendorTrackingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "creatureName", Type = "cstring", Nilable = false },
				{ Name = "zoneName", Type = "string", Nilable = true },
				{ Name = "currencyType", Type = "number", Nilable = true },
				{ Name = "cost", Type = "BigUInteger", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ContentTrackingTypes);