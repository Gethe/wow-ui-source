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
	},
};

APIDocumentation:AddDocumentationTable(HousingCleanupModeUI);