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
			Name = "ContentTrackingTargetType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "JournalEncounter", Type = "ContentTrackingTargetType", EnumValue = 0 },
				{ Name = "Vendor", Type = "ContentTrackingTargetType", EnumValue = 1 },
				{ Name = "Achievement", Type = "ContentTrackingTargetType", EnumValue = 2 },
				{ Name = "Profession", Type = "ContentTrackingTargetType", EnumValue = 3 },
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
				{ Name = "targetSubInfo", Type = "number", Nilable = true },
				{ Name = "waypointText", Type = "string", Nilable = false },
			},
		},
		{
			Name = "EncounterTrackingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "encounterName", Type = "cstring", Nilable = false },
				{ Name = "instanceName", Type = "cstring", Nilable = false },
				{ Name = "subText", Type = "cstring", Nilable = false },
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
				{ Name = "zoneName", Type = "cstring", Nilable = true },
				{ Name = "currencyType", Type = "number", Nilable = true },
				{ Name = "cost", Type = "BigUInteger", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ContentTrackingTypes);