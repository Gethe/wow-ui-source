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
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Attempts switch the House Editor to a specific House Editor mode" },

			Arguments =
			{
				{ Name = "editMode", Type = "HouseEditorMode", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false, Documentation = { "The initial result of the attempt to activate the mode; If Success, mode is either already active, or we've succesfully started making required requests to server; Listen for MODE_CHANGED or MODE_CHANGE_FAILURE events for ultimate end result after server calls" } },
			},
		},
		{
			Name = "EnterHouseEditor",
			Type = "Function",
			Documentation = { "Attempts to open the House Editor to the default House Editor mode" },

			Returns =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false, Documentation = { "The initial result of the attempt to open the Editor; If Success, Editor is either already active, or we've succesfully started making required requests to server; Listen for MODE_CHANGED or MODE_CHANGE_FAILURE events for ultimate end result after server calls" } },
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
			Documentation = { "Returns the availability state of the House Editor overall" },

			Returns =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "GetHouseEditorModeAvailability",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the availability of a specific House Editor mode" },

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
			Documentation = { "Returns whether the House Editor is active, in any mode" },

			Returns =
			{
				{ Name = "isEditorActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHouseEditorModeActive",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns whether the specific House Editor mode is active" },

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
			SynchronousEvent = true,
		},
		{
			Name = "HouseEditorModeChangeFailure",
			Type = "Event",
			LiteralName = "HOUSE_EDITOR_MODE_CHANGE_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HouseEditorModeChanged",
			Type = "Event",
			LiteralName = "HOUSE_EDITOR_MODE_CHANGED",
			SynchronousEvent = true,
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