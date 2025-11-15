local HousingExpertModeUI =
{
	Name = "HousingExpertModeUI",
	Type = "System",
	Namespace = "C_HousingExpertMode",

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
			Name = "GetHoveredDecorInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetPrecisionSubmode",
			Type = "Function",

			Returns =
			{
				{ Name = "activeSubMode", Type = "HousingPrecisionSubmode", Nilable = true },
			},
		},
		{
			Name = "GetPrecisionSubmodeRestriction",
			Type = "Function",
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
			Name = "RemoveSelectedDecor",
			Type = "Function",
		},
		{
			Name = "ResetPrecisionChanges",
			Type = "Function",

			Arguments =
			{
				{ Name = "activeSubmodeOnly", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SelectNextRotationAxis",
			Type = "Function",
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
			Name = "SetPrecisionIncrementingActive",
			Type = "Function",

			Arguments =
			{
				{ Name = "incrementType", Type = "HousingIncrementType", Nilable = false },
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPrecisionSubmode",
			Type = "Function",

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
			Payload =
			{
				{ Name = "event", Type = "TransformManipulatorEvent", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPrecisionManipulationStatusChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PRECISION_MANIPULATION_STATUS_CHANGED",
			Payload =
			{
				{ Name = "isManipulatingSelection", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPrecisionSubmodeChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PRECISION_SUBMODE_CHANGED",
			Payload =
			{
				{ Name = "activeSubmode", Type = "HousingPrecisionSubmode", Nilable = true },
			},
		},
		{
			Name = "HousingExpertModeHoveredTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_EXPERT_MODE_HOVERED_TARGET_CHANGED",
			Payload =
			{
				{ Name = "hasHoveredTarget", Type = "bool", Nilable = false },
				{ Name = "targetType", Type = "HousingExpertModeTargetType", Nilable = false },
			},
		},
		{
			Name = "HousingExpertModeSelectedTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED",
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