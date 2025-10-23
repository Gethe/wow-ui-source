local HousingDecorUI =
{
	Name = "HousingDecorUI",
	Type = "System",
	Namespace = "C_HousingDecor",

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
			Name = "EnterPreviewState",
			Type = "Function",
		},
		{
			Name = "ExitPreviewState",
			Type = "Function",
		},
		{
			Name = "GetAllPlacedDecor",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "placedDecor", Type = "table", InnerType = "HousingDecorInstanceListEntry", Nilable = false },
			},
		},
		{
			Name = "GetDecorInstanceInfoForGUID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
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
			Name = "GetMaxDecorPlaced",
			Type = "Function",

			Returns =
			{
				{ Name = "numPlaced", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxPlacementBudget",
			Type = "Function",

			Returns =
			{
				{ Name = "maxBudget", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumDecorPlaced",
			Type = "Function",

			Returns =
			{
				{ Name = "numPlaced", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumPreviewDecor",
			Type = "Function",

			Returns =
			{
				{ Name = "numDecor", Type = "number", Nilable = false },
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
			Name = "GetSpentPlacementBudget",
			Type = "Function",

			Returns =
			{
				{ Name = "totalCost", Type = "number", Nilable = false },
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
			Name = "IsHoveringDecor",
			Type = "Function",

			Returns =
			{
				{ Name = "isHoveringDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsModeDisabledForPreviewState",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mode", Type = "HouseEditorMode", Nilable = false },
			},

			Returns =
			{
				{ Name = "isModeDisabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPreviewState",
			Type = "Function",

			Returns =
			{
				{ Name = "isPreviewState", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemovePlacedDecorEntry",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "RemoveSelectedDecor",
			Type = "Function",
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
			Name = "SetPlacedDecorEntryHovered",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "hovered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPlacedDecorEntrySelected",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "selected", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HouseDecorAddedToChest",
			Type = "Event",
			LiteralName = "HOUSE_DECOR_ADDED_TO_CHEST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "HouseExteriorPositionFailure",
			Type = "Event",
			LiteralName = "HOUSE_EXTERIOR_POSITION_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "housingResult", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HouseExteriorPositionSuccess",
			Type = "Event",
			LiteralName = "HOUSE_EXTERIOR_POSITION_SUCCESS",
			SynchronousEvent = true,
		},
		{
			Name = "HouseLevelChanged",
			Type = "Event",
			LiteralName = "HOUSE_LEVEL_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "newHouseLevelInfo", Type = "HousingLevelInfo", Nilable = true },
			},
		},
		{
			Name = "HousingDecorGridVisibilityStatusChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_GRID_VISIBILITY_STATUS_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isGridVisible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPlaceFailure",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PLACE_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "housingResult", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPlaceSuccess",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PLACE_SUCCESS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "size", Type = "HousingCatalogEntrySize", Nilable = false },
				{ Name = "isNew", Type = "bool", Nilable = false, Documentation = { "Will be true if the decor is newly placed from storage, false if it was already placed and just moved" } },
			},
		},
		{
			Name = "HousingDecorPreviewStateChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PREVIEW_STATE_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isPreviewState", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingDecorRemoved",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_REMOVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "HousingDecorSelectResponse",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_SELECT_RESPONSE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingNumDecorPlacedChanged",
			Type = "Event",
			LiteralName = "HOUSING_NUM_DECOR_PLACED_CHANGED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "HousingDecorActionFlags",
			Type = "Enumeration",
			NumValues = 13,
			MinValue = 0,
			MaxValue = 2048,
			Fields =
			{
				{ Name = "None", Type = "HousingDecorActionFlags", EnumValue = 0 },
				{ Name = "Add", Type = "HousingDecorActionFlags", EnumValue = 1 },
				{ Name = "Remove", Type = "HousingDecorActionFlags", EnumValue = 2 },
				{ Name = "DragMove", Type = "HousingDecorActionFlags", EnumValue = 4 },
				{ Name = "PrecisionMove", Type = "HousingDecorActionFlags", EnumValue = 8 },
				{ Name = "ClickTarget", Type = "HousingDecorActionFlags", EnumValue = 16 },
				{ Name = "HoverTarget", Type = "HousingDecorActionFlags", EnumValue = 32 },
				{ Name = "TargetRoomComponents", Type = "HousingDecorActionFlags", EnumValue = 64 },
				{ Name = "TargetHouseExterior", Type = "HousingDecorActionFlags", EnumValue = 128 },
				{ Name = "MaintainLastTarget", Type = "HousingDecorActionFlags", EnumValue = 256 },
				{ Name = "IncludeTargetChildren", Type = "HousingDecorActionFlags", EnumValue = 512 },
				{ Name = "UsePlacedDecorList", Type = "HousingDecorActionFlags", EnumValue = 1024 },
				{ Name = "PreviewDecor", Type = "HousingDecorActionFlags", EnumValue = 2048 },
			},
		},
		{
			Name = "HousingDecorInstanceListEntry",
			Type = "Structure",
			Documentation = { "Smaller structs with the minimum fields from HousingDecorInstanceInfo needed to identify/display a slim list of placed decor" },
			Fields =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "HousingLevelInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "interiorDecorPlacementBudget", Type = "number", Nilable = false },
				{ Name = "exteriorDecorPlacementBudget", Type = "number", Nilable = false },
				{ Name = "roomPlacementBudget", Type = "number", Nilable = false },
				{ Name = "exteriorFixtureBudget", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingDecorUI);