local HousingCleanupModeUI =
{
	Name = "HousingCleanupModeUI",
	Type = "System",
	Namespace = "C_HousingCleanupMode",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetHoveredDecorInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "IsHoveringDecor",
			Type = "Function",

			Returns =
			{
				{ Name = "isHoveringDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveSelectedDecor",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "HousingCleanupModeHoveredTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_CLEANUP_MODE_HOVERED_TARGET_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "hasHoveredTarget", Type = "bool", Nilable = false },
				{ Name = "targetType", Type = "HousingCleanupModeTargetType", Nilable = false },
			},
		},
		{
			Name = "HousingCleanupModeTargetSelected",
			Type = "Event",
			LiteralName = "HOUSING_CLEANUP_MODE_TARGET_SELECTED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "HousingCleanupModeTargetType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "HousingCleanupModeTargetType", EnumValue = 0 },
				{ Name = "Decor", Type = "HousingCleanupModeTargetType", EnumValue = 1 },
				{ Name = "HouseExterior", Type = "HousingCleanupModeTargetType", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingCleanupModeUI);