local HousingBasicModeUI =
{
	Name = "HousingBasicModeUI",
	Type = "System",
	Namespace = "C_HousingBasicMode",

	Functions =
	{
		{
			Name = "CancelActiveEditing",
			Type = "Function",
		},
		{
			Name = "CommitDecorMovement",
			Type = "Function",
		},
		{
			Name = "CommitHouseExteriorPosition",
			Type = "Function",
		},
		{
			Name = "FinishPlacingNewDecor",
			Type = "Function",
		},
		{
			Name = "GetHoveredDecorInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetSelectedDecorInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "IsDecorSelected",
			Type = "Function",

			Returns =
			{
				{ Name = "hasSelectedDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGridSnapEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isGridSnapEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGridVisible",
			Type = "Function",

			Returns =
			{
				{ Name = "gridVisible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHouseExteriorHovered",
			Type = "Function",

			Returns =
			{
				{ Name = "isHouseExteriorHovered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHouseExteriorSelected",
			Type = "Function",

			Returns =
			{
				{ Name = "isHouseExteriorSelected", Type = "bool", Nilable = false },
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
			Name = "IsNudgeEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "nudgeEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlacingNewDecor",
			Type = "Function",

			Returns =
			{
				{ Name = "hasPendingDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveSelectedDecor",
			Type = "Function",
		},
		{
			Name = "RotateDecor",
			Type = "Function",

			Arguments =
			{
				{ Name = "rotDegrees", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RotateHouseExterior",
			Type = "Function",

			Arguments =
			{
				{ Name = "rotDegrees", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetGridSnapEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "isGridSnapEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetGridVisible",
			Type = "Function",

			Arguments =
			{
				{ Name = "gridVisible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetNudgeEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "nudgeEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "StartPlacingNewDecor",
			Type = "Function",

			Arguments =
			{
				{ Name = "catalogEntryID", Type = "HousingCatalogEntryID", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingBasicModeHoveredTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED",
			Payload =
			{
				{ Name = "hasHoveredTarget", Type = "bool", Nilable = false },
				{ Name = "targetType", Type = "HousingBasicModeTargetType", Nilable = false },
			},
		},
		{
			Name = "HousingBasicModePlacementFlagsUpdated",
			Type = "Event",
			LiteralName = "HOUSING_BASIC_MODE_PLACEMENT_FLAGS_UPDATED",
			Payload =
			{
				{ Name = "targetType", Type = "HousingBasicModeTargetType", Nilable = false },
				{ Name = "placementInfo", Type = "InvalidPlacementInfo", Nilable = false },
			},
		},
		{
			Name = "HousingBasicModeSelectedTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED",
			Payload =
			{
				{ Name = "hasSelectedTarget", Type = "bool", Nilable = false },
				{ Name = "targetType", Type = "HousingBasicModeTargetType", Nilable = false },
			},
		},
		{
			Name = "HousingDecorGridSnapOccurred",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_GRID_SNAP_OCCURRED",
		},
		{
			Name = "HousingDecorGridSnapStatusChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_GRID_SNAP_STATUS_CHANGED",
			Payload =
			{
				{ Name = "isGridSnapEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingDecorNudgeStatusChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_NUDGE_STATUS_CHANGED",
			Payload =
			{
				{ Name = "isNudgeEnabled", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "HousingBasicModeTargetType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "HousingBasicModeTargetType", EnumValue = 0 },
				{ Name = "Decor", Type = "HousingBasicModeTargetType", EnumValue = 1 },
				{ Name = "House", Type = "HousingBasicModeTargetType", EnumValue = 2 },
			},
		},
		{
			Name = "InvalidPlacementInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "anyRestrictions", Type = "bool", Nilable = false },
				{ Name = "invalidCollision", Type = "bool", Nilable = false },
				{ Name = "invalidTarget", Type = "bool", Nilable = false },
				{ Name = "tooFar", Type = "bool", Nilable = false },
				{ Name = "notInRoom", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingBasicModeUI);