local Input =
{
	Name = "Input",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetCursorDelta",
			Type = "Function",

			Returns =
			{
				{ Name = "deltaX", Type = "number", Nilable = false },
				{ Name = "deltaY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCursorPosition",
			Type = "Function",

			Returns =
			{
				{ Name = "posX", Type = "number", Nilable = false },
				{ Name = "posY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMouseFoci",
			Type = "Function",

			Returns =
			{
				{ Name = "region", Type = "table", InnerType = "ScriptRegion", Nilable = false },
			},
		},
		{
			Name = "GetStringFromModifiers",
			Type = "Function",

			Arguments =
			{
				{ Name = "modifiers", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "modifierString", Type = "string", Nilable = false },
			},
		},
		{
			Name = "MakeModifiers",
			Type = "Function",

			Returns =
			{
				{ Name = "modifiers", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCursorPosition",
			Type = "Function",
			RequiresLimitedInput = true,
			Documentation = { "Insecure code can only call this once in response to gamepad input hardware events." },

			Arguments =
			{
				{ Name = "xPosition", Type = "uiUnit", Nilable = false },
				{ Name = "yPosition", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SimulateMouseClick",
			Type = "Function",
			RequiresLimitedInput = true,
			MouseFocusValidForLimitedInput = true,
			Documentation = { "Effectively the same as SimulateMouseDown plus SimulateMouseUp and consumes limited input for both." },

			Arguments =
			{
				{ Name = "button", Type = "mouseButton", Nilable = false },
			},
		},
		{
			Name = "SimulateMouseDown",
			Type = "Function",
			RequiresLimitedInput = true,
			MouseFocusValidForLimitedInput = true,
			Documentation = { "Insecure code can only call this once in response to gamepad input hardware events." },

			Arguments =
			{
				{ Name = "button", Type = "mouseButton", Nilable = false },
			},
		},
		{
			Name = "SimulateMouseUp",
			Type = "Function",
			RequiresLimitedInput = true,
			MouseFocusValidForLimitedInput = true,
			Documentation = { "Insecure code can only call this once in response to gamepad input hardware events." },

			Arguments =
			{
				{ Name = "button", Type = "mouseButton", Nilable = false },
			},
		},
		{
			Name = "SimulateMouseWheel",
			Type = "Function",
			RequiresLimitedInput = true,
			MouseFocusValidForLimitedInput = true,
			Documentation = { "Insecure code can only call this once in response to gamepad input hardware events." },

			Arguments =
			{
				{ Name = "delta", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
	Predicates =
	{
		{
			Name = "MouseFocusValidForLimitedInput",
			Type = "Precondition",
			FailureMode = "ReturnNothing",
			Documentation = { "Requires that all mouse foci are not forbidden, hidden from the global environment, fully locked down, script inaccessible, or protected frames (while in combat)" },
		},
		{
			Name = "RequiresLimitedInput",
			Type = "Precondition",
			FailureMode = "Error",
		},
	},
};

APIDocumentation:AddDocumentationTable(Input);