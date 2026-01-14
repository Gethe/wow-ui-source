local HousingBasicModeUI =
{
	Name = "HousingBasicModeUI",
	Type = "System",
	Namespace = "C_HousingBasicMode",
	Environment = "All",

	Functions =
	{
		{
			Name = "CancelActiveEditing",
			Type = "Function",
			Documentation = { "Cancels all in-progress editing of the selected target, which will reset any unsaved changes and deselect the active target; Un-placed decor will be returned to the house chest" },
		},
		{
			Name = "CommitDecorMovement",
			Type = "Function",
			Documentation = { "Attempt to save the changes made to the currently selected decor instance" },
		},
		{
			Name = "CommitHouseExteriorPosition",
			Type = "Function",
			Documentation = { "Attempt to save the changes made to the House Exterior's position within the plot" },
		},
		{
			Name = "FinishPlacingNewDecor",
			Type = "Function",
		},
		{
			Name = "GetHoveredDecorInfo",
			Type = "Function",
			Documentation = { "Returns info for the placed decor instance currently being hovered, if there is one" },

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetSelectedDecorInfo",
			Type = "Function",
			Documentation = { "Returns info for the decor instance that's currently selected, if there is one" },

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "IsDecorSelected",
			Type = "Function",
			Documentation = { "Returns true if a decor instance is currently selected and being dragged" },

			Returns =
			{
				{ Name = "hasSelectedDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFreePlaceEnabled",
			Type = "Function",
			Documentation = { "When free place is enabled, collision checks while dragging decor/the house exterior are ignored" },

			Returns =
			{
				{ Name = "freePlaceEnabled", Type = "bool", Nilable = false },
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
			Documentation = { "Returns true if the house's exterior is currently being hovered" },

			Returns =
			{
				{ Name = "isHouseExteriorHovered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHouseExteriorSelected",
			Type = "Function",
			Documentation = { "Returns true if the house's exterior is currently selected and being moved" },

			Returns =
			{
				{ Name = "isHouseExteriorSelected", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHoveringDecor",
			Type = "Function",
			Documentation = { "Returns true if a placed decor instance is currently being hovered" },

			Returns =
			{
				{ Name = "isHoveringDecor", Type = "bool", Nilable = false },
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
			Documentation = { "Attempt to return the currently selected decor instance back to the house chest" },
		},
		{
			Name = "RotateDecor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Rotates the currently selected decor along a single axis; For wall decor, rotates such that the object stays flat against its current wall; For all other decor, rotates around the Z (vertical) axis" },

			Arguments =
			{
				{ Name = "rotDegrees", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RotateHouseExterior",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Rotates the House Exterior around the Z (vertical) axis" },

			Arguments =
			{
				{ Name = "rotDegrees", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFreePlaceEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Set whether free place is enabled; When free place is enabled, collision checks while dragging decor/the house exterior are ignored" },

			Arguments =
			{
				{ Name = "freePlaceEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetGridSnapEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isGridSnapEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetGridVisible",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gridVisible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "StartPlacingNewDecor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "catalogEntryID", Type = "HousingCatalogEntryID", Nilable = false },
			},
		},
		{
			Name = "StartPlacingPreviewDecor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "decorRecordID", Type = "number", Nilable = false },
				{ Name = "bundleCatalogShopProductID", Type = "number", Nilable = true },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingBasicModeHoveredTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "targetType", Type = "HousingBasicModeTargetType", Nilable = false },
				{ Name = "activeFlags", Type = "HousingDecorPlacementRestriction", Nilable = false },
			},
		},
		{
			Name = "HousingBasicModeSelectedTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "hasSelectedTarget", Type = "bool", Nilable = false },
				{ Name = "targetType", Type = "HousingBasicModeTargetType", Nilable = false },
				{ Name = "isPreview", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingDecorFreePlaceStatusChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_FREE_PLACE_STATUS_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isFreePlaceEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingDecorGridSnapOccurred",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_GRID_SNAP_OCCURRED",
			SynchronousEvent = true,
		},
		{
			Name = "HousingDecorGridSnapStatusChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_GRID_SNAP_STATUS_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isGridSnapEnabled", Type = "bool", Nilable = false },
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
	},
};

APIDocumentation:AddDocumentationTable(HousingBasicModeUI);