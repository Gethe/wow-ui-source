local HousingExpertModeUI =
{
	Name = "HousingExpertModeUI",
	Type = "System",
	Namespace = "C_HousingExpertMode",
	Environment = "All",

	Functions =
	{
		{
			Name = "CancelActiveEditing",
			Type = "Function",
			Documentation = { "Cancels all in-progress editing of the selected target, which will reset any unsaved changes and deselect the active target; Will not reset any already-applied changes" },
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
			Name = "GetHoveredDecorInfo",
			Type = "Function",
			Documentation = { "Returns info for the placed decor instance currently being hovered, if there is one" },

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetPrecisionSubmode",
			Type = "Function",
			Documentation = { "Returns the currently active Expert submode, if there is one" },

			Returns =
			{
				{ Name = "activeSubMode", Type = "HousingPrecisionSubmode", Nilable = true },
			},
		},
		{
			Name = "GetPrecisionSubmodeRestriction",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the type of restriction currently active on the submode; Will return HousingExpertSubmodeRestriction:None if submode is not currently restricted" },

			Arguments =
			{
				{ Name = "subMode", Type = "HousingPrecisionSubmode", Nilable = false },
			},

			Returns =
			{
				{ Name = "restriction", Type = "HousingExpertSubmodeRestriction", Nilable = false },
			},
		},
		{
			Name = "GetSelectedDecorInfo",
			Type = "Function",
			Documentation = { "Returns info for the placed decor instance that's currently selected, if there is one" },

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "IsDecorSelected",
			Type = "Function",
			Documentation = { "Returns true if a placed decor instance is currently selected" },

			Returns =
			{
				{ Name = "hasSelectedDecor", Type = "bool", Nilable = false },
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
			Documentation = { "Returns true if the house's exterior is currently selected" },

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
			Name = "RemoveSelectedDecor",
			Type = "Function",
			Documentation = { "Attempt to return the currently selected decor instance back to the house chest" },
		},
		{
			Name = "ResetPrecisionChanges",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Reset the selected target's transform back to default values; This is NOT an undo, meaning it will completely reset the transform value to default, NOT just recently-made changes" },

			Arguments =
			{
				{ Name = "activeSubmodeOnly", Type = "bool", Nilable = false, Documentation = { "If true, only transform values associated with the currently active submode with be reset (ex: in Scale submode, only target's scale will be reset); If false, all transform values will be reset" } },
			},
		},
		{
			Name = "SelectNextRotationAxis",
			Type = "Function",
			Documentation = { "In the rotation submode, swaps the selected axis to the next available one, in order of X -> Y -> Z (wrapping back around to X again, etc); If no axis is selected, selects the first available one, also in that order" },
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
			Name = "SetPrecisionIncrementingActive",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets a specific type of incremental change active or inactive; Whilever that type is active and target stays selected, incremental changes of that type will continue to be made every frame" },

			Arguments =
			{
				{ Name = "incrementType", Type = "HousingIncrementType", Nilable = false },
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPrecisionSubmode",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Activate a specific Expert submode" },

			Arguments =
			{
				{ Name = "subMode", Type = "HousingPrecisionSubmode", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingDecorPrecisionManipulationEvent",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PRECISION_MANIPULATION_EVENT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "event", Type = "TransformManipulatorEvent", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPrecisionManipulationStatusChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PRECISION_MANIPULATION_STATUS_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isManipulatingSelection", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPrecisionSubmodeChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PRECISION_SUBMODE_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "activeSubmode", Type = "HousingPrecisionSubmode", Nilable = true },
			},
		},
		{
			Name = "HousingExpertModeHoveredTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_EXPERT_MODE_HOVERED_TARGET_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "hasHoveredTarget", Type = "bool", Nilable = false },
				{ Name = "targetType", Type = "HousingExpertModeTargetType", Nilable = false },
			},
		},
		{
			Name = "HousingExpertModePlacementFlagsUpdated",
			Type = "Event",
			LiteralName = "HOUSING_EXPERT_MODE_PLACEMENT_FLAGS_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "targetType", Type = "HousingExpertModeTargetType", Nilable = false },
				{ Name = "activeFlags", Type = "HousingDecorPlacementRestriction", Nilable = false },
			},
		},
		{
			Name = "HousingExpertModeSelectedTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "hasSelectedTarget", Type = "bool", Nilable = false },
				{ Name = "targetType", Type = "HousingExpertModeTargetType", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "HousingExpertModeTargetType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "HousingExpertModeTargetType", EnumValue = 0 },
				{ Name = "Decor", Type = "HousingExpertModeTargetType", EnumValue = 1 },
				{ Name = "House", Type = "HousingExpertModeTargetType", EnumValue = 2 },
			},
		},
		{
			Name = "HousingExpertSubmodeRestriction",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "HousingExpertSubmodeRestriction", EnumValue = 0 },
				{ Name = "NotInExpertMode", Type = "HousingExpertSubmodeRestriction", EnumValue = 1 },
				{ Name = "NoHouseExteriorScale", Type = "HousingExpertSubmodeRestriction", EnumValue = 2 },
				{ Name = "NoWMOScale", Type = "HousingExpertSubmodeRestriction", EnumValue = 3 },
			},
		},
		{
			Name = "HousingIncrementType",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 1,
			MaxValue = 512,
			Fields =
			{
				{ Name = "Left", Type = "HousingIncrementType", EnumValue = 1 },
				{ Name = "Right", Type = "HousingIncrementType", EnumValue = 2 },
				{ Name = "Forward", Type = "HousingIncrementType", EnumValue = 4 },
				{ Name = "Back", Type = "HousingIncrementType", EnumValue = 8 },
				{ Name = "Up", Type = "HousingIncrementType", EnumValue = 16 },
				{ Name = "Down", Type = "HousingIncrementType", EnumValue = 32 },
				{ Name = "RotateLeft", Type = "HousingIncrementType", EnumValue = 64 },
				{ Name = "RotateRight", Type = "HousingIncrementType", EnumValue = 128 },
				{ Name = "ScaleUp", Type = "HousingIncrementType", EnumValue = 256 },
				{ Name = "ScaleDown", Type = "HousingIncrementType", EnumValue = 512 },
			},
		},
		{
			Name = "HousingPrecisionSubmode",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Translate", Type = "HousingPrecisionSubmode", EnumValue = 0 },
				{ Name = "Rotate", Type = "HousingPrecisionSubmode", EnumValue = 1 },
				{ Name = "Scale", Type = "HousingPrecisionSubmode", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingExpertModeUI);