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
			Name = "GetAllPlacedDecor",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "placedDecor", Type = "table", InnerType = "HousingDecorInstanceListEntry", Nilable = false },
			},
		},
		{
			Name = "GetDecorIcon",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "decorID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "icon", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "GetDecorInstanceInfoForGUID",
			Type = "Function",

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
			Name = "GetDecorName",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "decorID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
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
			Name = "HasMaxPlacementBudget",
			Type = "Function",

			Returns =
			{
				{ Name = "hasMaxBudget", Type = "bool", Nilable = false },
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
			Name = "IsHouseExteriorDoorHovered",
			Type = "Function",

			Returns =
			{
				{ Name = "isHouseExteriorDoorHovered", Type = "bool", Nilable = false },
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
			Name = "IsHoveringDecor",
			Type = "Function",

			Returns =
			{
				{ Name = "isHoveringDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemovePlacedDecorEntry",
			Type = "Function",
			HasRestrictions = true,

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

			Arguments =
			{
				{ Name = "gridVisible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPlacedDecorEntryHovered",
			Type = "Function",
			HasRestrictions = true,

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
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "decorID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HouseExteriorPositionFailure",
			Type = "Event",
			LiteralName = "HOUSE_EXTERIOR_POSITION_FAILURE",
			Payload =
			{
				{ Name = "housingResult", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HouseExteriorPositionSuccess",
			Type = "Event",
			LiteralName = "HOUSE_EXTERIOR_POSITION_SUCCESS",
		},
		{
			Name = "HouseLevelChanged",
			Type = "Event",
			LiteralName = "HOUSE_LEVEL_CHANGED",
			Payload =
			{
				{ Name = "newHouseLevelInfo", Type = "HousingLevelInfo", Nilable = true },
			},
		},
		{
			Name = "HousingDecorGridVisibilityStatusChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_GRID_VISIBILITY_STATUS_CHANGED",
			Payload =
			{
				{ Name = "isGridVisible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPlaceFailure",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PLACE_FAILURE",
			Payload =
			{
				{ Name = "housingResult", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingDecorPlaceSuccess",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_PLACE_SUCCESS",
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "size", Type = "HousingCatalogEntrySize", Nilable = false },
				{ Name = "isNew", Type = "bool", Nilable = false, Documentation = { "Will be true if the decor is newly placed from storage, false if it was already placed and just moved" } },
			},
		},
		{
			Name = "HousingDecorRemoved",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_REMOVED",
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "HousingDecorSelectResponse",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_SELECT_RESPONSE",
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingNumDecorPlacedChanged",
			Type = "Event",
			LiteralName = "HOUSING_NUM_DECOR_PLACED_CHANGED",
		},
	},

	Tables =
	{
		{
			Name = "HousingDecorActionFlags",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 0,
			MaxValue = 1024,
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