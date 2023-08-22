local UIManager =
{
	Name = "UI",
	Type = "System",
	Namespace = "C_UI",

	Functions =
	{
		{
			Name = "DoesAnyDisplayHaveNotch",
			Type = "Function",
			Documentation = { "True if any display attached has a notch. This does not mean the current view intersects the notch." },

			Returns =
			{
				{ Name = "notchPresent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetTopLeftNotchSafeRegion",
			Type = "Function",
			Documentation = { "Region of screen left of screen notch. Zeros if no notch." },

			Returns =
			{
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "right", Type = "number", Nilable = false },
				{ Name = "top", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTopRightNotchSafeRegion",
			Type = "Function",
			Documentation = { "Region of screen right of screen notch. Zeros if no notch." },

			Returns =
			{
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "right", Type = "number", Nilable = false },
				{ Name = "top", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
			},
		},
		{
			Name = "Reload",
			Type = "Function",
		},
		{
			Name = "ShouldUIParentAvoidNotch",
			Type = "Function",
			Documentation = { "UIParent will shift down to avoid notch if true. This does not mean there is a notch." },

			Returns =
			{
				{ Name = "willAvoidNotch", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "NotchedDisplayModeChanged",
			Type = "Event",
			LiteralName = "NOTCHED_DISPLAY_MODE_CHANGED",
		},
		{
			Name = "UiScaleChanged",
			Type = "Event",
			LiteralName = "UI_SCALE_CHANGED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(UIManager);