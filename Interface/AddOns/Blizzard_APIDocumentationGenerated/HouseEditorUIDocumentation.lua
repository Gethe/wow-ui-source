local HouseEditorUI =
{
	Name = "HouseEditorUI",
	Type = "System",
	Namespace = "C_HouseEditor",

	Functions =
	{
		{
			Name = "ActivateHouseEditorMode",
			Type = "Function",

			Arguments =
			{
				{ Name = "editMode", Type = "HouseEditorMode", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "EnterHouseEditor",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "GetActiveHouseEditorMode",
			Type = "Function",

			Returns =
			{
				{ Name = "editMode", Type = "HouseEditorMode", Nilable = false },
			},
		},
		{
			Name = "GetHouseEditorAvailability",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "GetHouseEditorModeAvailability",
			Type = "Function",

			Arguments =
			{
				{ Name = "editMode", Type = "HouseEditorMode", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "IsHouseEditorActive",
			Type = "Function",

			Returns =
			{
				{ Name = "isEditorActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHouseEditorModeActive",
			Type = "Function",

			Arguments =
			{
				{ Name = "editMode", Type = "HouseEditorMode", Nilable = false },
			},

			Returns =
			{
				{ Name = "isModeActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHouseEditorStatusAvailable",
			Type = "Function",
			Documentation = { "Returns true if the HouseEditor currently able process mode availability and switching; May be false if not in a house or plot, or while waiting to get house settings back from the server" },

			Returns =
			{
				{ Name = "editorStatusAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LeaveHouseEditor",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "HouseEditorAvailabilityChanged",
			Type = "Event",
			LiteralName = "HOUSE_EDITOR_AVAILABILITY_CHANGED",
		},
		{
			Name = "HouseEditorModeChangeFailure",
			Type = "Event",
			LiteralName = "HOUSE_EDITOR_MODE_CHANGE_FAILURE",
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HouseEditorModeChanged",
			Type = "Event",
			LiteralName = "HOUSE_EDITOR_MODE_CHANGED",
			Payload =
			{
				{ Name = "currentEditMode", Type = "HouseEditorMode", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(HouseEditorUI);