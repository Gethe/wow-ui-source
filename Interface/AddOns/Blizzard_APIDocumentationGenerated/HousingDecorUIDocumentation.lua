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
			Documentation = { "Cancels all in-progress editing of the selected target, which will reset any unsaved changes and deselect the active target" },
		},
		{
			Name = "CommitDecorMovement",
			Type = "Function",
			Documentation = { "Attempt to save the changes made to the currently selected decor instance" },
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
			Documentation = { "Placed Decor List APIs currently restricted due to being potentially very expensive operations, may be reworked & opened up in the future" },

			Returns =
			{
				{ Name = "placedDecor", Type = "table", InnerType = "HousingDecorInstanceListEntry", Nilable = false },
			},
		},
		{
			Name = "GetDecorIcon",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns info for the placed decor instance associated with the passed Decor GUID, if there is one" },

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
			SecretArguments = "AllowedWhenUntainted",

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
			Documentation = { "Returns info for the placed decor instance currently being hovered, if there is one" },

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetMaxPlacementBudget",
			Type = "Function",
			Documentation = { "Returns the max decor placement budget for the current house interior or plot; Can be increased via house level" },

			Returns =
			{
				{ Name = "maxBudget", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumDecorPlaced",
			Type = "Function",
			Documentation = { "Returns the number of individual decor objects placed in the current house or plot; This is NOT the value used in placement budget calculations, see GetSpentPlacementBudget for that" },

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
			Documentation = { "Returns info for the placed decor instance that's currently selected, if there is one" },

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetSpentPlacementBudget",
			Type = "Function",
			Documentation = { "Returns how much of the current house interior or plot's decor placement budget has been spent; Different kinds of decor take up different budget amounts, so this value isn't an individual decor count, see GetNumDecorPlaced for that" },

			Returns =
			{
				{ Name = "totalCost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasMaxPlacementBudget",
			Type = "Function",
			Documentation = { "Returns whether there's a max decor placement budget available and active for the current player, in the current house interior or plot" },

			Returns =
			{
				{ Name = "hasMaxBudget", Type = "bool", Nilable = false },
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
			Name = "IsHouseExteriorDoorHovered",
			Type = "Function",
			Documentation = { "Returns true if the entry door of the house's exterior is currently being hovered" },

			Returns =
			{
				{ Name = "isHouseExteriorDoorHovered", Type = "bool", Nilable = false },
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
			Name = "IsHoveringDecor",
			Type = "Function",
			Documentation = { "Returns true if a placed decor instance is currently being hovered" },

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
			Documentation = { "Placed Decor List APIs currently restricted due to being potentially very expensive operations, may be reworked & opened up in the future" },

			Arguments =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "RemoveSelectedDecor",
			Type = "Function",
			Documentation = { "Attempt to return the currently selected decor instance back to the house chest" },
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
			Documentation = { "Placed Decor List APIs currently restricted due to being potentially very expensive operations, may be reworked & opened up in the future" },

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
			Documentation = { "Placed Decor List APIs currently restricted due to being potentially very expensive operations, may be reworked & opened up in the future" },

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
				{ Name = "decorID", Type = "number", Nilable = false },
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
				{ Name = "isPreview", Type = "bool", Nilable = false },
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
				{ Name = "level", Type = "number", Nilable = false, Documentation = { "This specific house's current level, determined/increasesd by earning house xp" } },
				{ Name = "interiorDecorPlacementBudget", Type = "number", Nilable = false, Documentation = { "Current max decor placement budget for inside the house; Can be increased via house level" } },
				{ Name = "exteriorDecorPlacementBudget", Type = "number", Nilable = false, Documentation = { "Current max decor placement budget for the house exterior/in the house's plot; Can be increased via house level" } },
				{ Name = "roomPlacementBudget", Type = "number", Nilable = false, Documentation = { "Current max room placement budget for the house; Can be increased via house level" } },
				{ Name = "exteriorFixtureBudget", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingDecorUI);