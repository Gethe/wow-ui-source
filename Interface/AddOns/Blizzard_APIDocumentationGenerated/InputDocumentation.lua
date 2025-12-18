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
			Name = "GetMouseButtonClicked",
			Type = "Function",

			Returns =
			{
				{ Name = "buttonName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetMouseButtonName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "button", Type = "mouseButton", Nilable = false },
			},

			Returns =
			{
				{ Name = "buttonName", Type = "cstring", Nilable = false },
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
			Name = "IsAltKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsControlKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsKeyDown",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "keyOrMouseName", Type = "cstring", Nilable = false },
				{ Name = "excludeBindingState", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "IsLeftAltKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLeftControlKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLeftMetaKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLeftShiftKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMetaKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsModifierKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMouseButtonDown",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "button", Type = "mouseButton", Nilable = true },
			},

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRightAltKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRightControlKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRightMetaKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRightShiftKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsShiftKeyDown",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUsingGamepad",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUsingMouse",
			Type = "Function",

			Returns =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCursorPosition",
			Type = "Function",
			RequiresLimitedInput = true,
			SecretArguments = "AllowedWhenUntainted",
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
			SecretArguments = "AllowedWhenUntainted",
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
			SecretArguments = "AllowedWhenUntainted",
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
			SecretArguments = "AllowedWhenUntainted",
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
			SecretArguments = "AllowedWhenUntainted",
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
};

APIDocumentation:AddDocumentationTable(Input);