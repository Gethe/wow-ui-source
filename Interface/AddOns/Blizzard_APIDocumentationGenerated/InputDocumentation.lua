local Input =
{
	Name = "Input",
	Type = "System",

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
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Input);