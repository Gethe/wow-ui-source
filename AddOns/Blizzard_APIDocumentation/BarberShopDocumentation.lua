local BarberShop =
{
	Name = "BarberShop",
	Type = "System",
	Namespace = "C_BarberShop",

	Functions =
	{
		{
			Name = "ApplyCustomizationChoices",
			Type = "Function",

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Cancel",
			Type = "Function",
		},
		{
			Name = "ClearPreviewChoices",
			Type = "Function",

			Arguments =
			{
				{ Name = "clearSavedChoices", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "GetAvailableCustomizations",
			Type = "Function",

			Returns =
			{
				{ Name = "categories", Type = "table", InnerType = "CharCustomizationCategory", Nilable = false },
			},
		},
		{
			Name = "GetCurrentCameraZoom",
			Type = "Function",

			Returns =
			{
				{ Name = "zoomLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrentCharacterData",
			Type = "Function",

			Returns =
			{
				{ Name = "characterData", Type = "BarberShopCharacterData", Nilable = false },
			},
		},
		{
			Name = "GetCurrentCost",
			Type = "Function",

			Returns =
			{
				{ Name = "cost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasAnyChanges",
			Type = "Function",

			Returns =
			{
				{ Name = "hasChanges", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsViewingAlteredForm",
			Type = "Function",

			Returns =
			{
				{ Name = "isViewingAlteredForm", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PreviewCustomizationChoice",
			Type = "Function",

			Arguments =
			{
				{ Name = "optionID", Type = "number", Nilable = false },
				{ Name = "choiceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RandomizeCustomizationChoices",
			Type = "Function",
		},
		{
			Name = "ResetCameraRotation",
			Type = "Function",
		},
		{
			Name = "ResetCustomizationChoices",
			Type = "Function",
		},
		{
			Name = "RotateCamera",
			Type = "Function",

			Arguments =
			{
				{ Name = "diffDegrees", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraDistanceOffset",
			Type = "Function",

			Arguments =
			{
				{ Name = "offset", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraZoomLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "zoomLevel", Type = "number", Nilable = false },
				{ Name = "keepCustomZoom", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "SetCustomizationChoice",
			Type = "Function",

			Arguments =
			{
				{ Name = "optionID", Type = "number", Nilable = false },
				{ Name = "choiceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetModelDressState",
			Type = "Function",

			Arguments =
			{
				{ Name = "dressedState", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSelectedSex",
			Type = "Function",

			Arguments =
			{
				{ Name = "sex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetViewingAlteredForm",
			Type = "Function",

			Arguments =
			{
				{ Name = "isViewingAlteredForm", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetViewingShapeshiftForm",
			Type = "Function",

			Arguments =
			{
				{ Name = "shapeshiftFormID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ZoomCamera",
			Type = "Function",

			Arguments =
			{
				{ Name = "zoomAmount", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "BarberShopAppearanceApplied",
			Type = "Event",
			LiteralName = "BARBER_SHOP_APPEARANCE_APPLIED",
		},
		{
			Name = "BarberShopCameraValuesUpdated",
			Type = "Event",
			LiteralName = "BARBER_SHOP_CAMERA_VALUES_UPDATED",
		},
		{
			Name = "BarberShopClose",
			Type = "Event",
			LiteralName = "BARBER_SHOP_CLOSE",
		},
		{
			Name = "BarberShopCostUpdate",
			Type = "Event",
			LiteralName = "BARBER_SHOP_COST_UPDATE",
		},
		{
			Name = "BarberShopForceCustomizationsUpdate",
			Type = "Event",
			LiteralName = "BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE",
		},
		{
			Name = "BarberShopOpen",
			Type = "Event",
			LiteralName = "BARBER_SHOP_OPEN",
		},
		{
			Name = "BarberShopResult",
			Type = "Event",
			LiteralName = "BARBER_SHOP_RESULT",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "BarberShopCharacterData",
			Type = "Structure",
			Fields =
			{
				{ Name = "raceData", Type = "BarberShopRaceData", Nilable = false },
				{ Name = "sex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BarberShopRaceData",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "fileName", Type = "string", Nilable = false },
				{ Name = "alternateFormRaceData", Type = "CharacterAlternateFormData", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(BarberShop);