local SimpleScriptRegionAPI =
{
	Name = "SimpleScriptRegionAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "CanChangeProtectedState",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "canChange", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EnableMouse",
			Type = "Function",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "EnableMouseWheel",
			Type = "Function",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "GetBottom",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "bottom", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCenter",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHeight",
			Type = "Function",

			Arguments =
			{
				{ Name = "ignoreRect", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLeft",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "left", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRect",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRight",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "right", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScaledRect",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScript",
			Type = "Function",

			Arguments =
			{
				{ Name = "scriptTypeName", Type = "string", Nilable = false },
				{ Name = "bindingType", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "script", Type = "function", Nilable = false },
			},
		},
		{
			Name = "GetSize",
			Type = "Function",

			Arguments =
			{
				{ Name = "ignoreRect", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSourceLocation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "location", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetTop",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "top", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetWidth",
			Type = "Function",

			Arguments =
			{
				{ Name = "ignoreRect", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "width", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasScript",
			Type = "Function",

			Arguments =
			{
				{ Name = "scriptName", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasScript", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Hide",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "HookScript",
			Type = "Function",

			Arguments =
			{
				{ Name = "scriptTypeName", Type = "string", Nilable = false },
				{ Name = "script", Type = "function", Nilable = false },
				{ Name = "bindingType", Type = "number", Nilable = true },
			},
		},
		{
			Name = "IsAnchoringRestricted",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isRestricted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsDragging",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isDragging", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMouseClickEnabled",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMouseEnabled",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMouseMotionEnabled",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMouseOver",
			Type = "Function",

			Arguments =
			{
				{ Name = "offsetTop", Type = "number", Nilable = false, Default = 0 },
				{ Name = "offsetBottom", Type = "number", Nilable = false, Default = 0 },
				{ Name = "offsetLeft", Type = "number", Nilable = false, Default = 0 },
				{ Name = "offsetRight", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "isMouseOver", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMouseWheelEnabled",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsProtected",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isProtected", Type = "bool", Nilable = false },
				{ Name = "isProtectedExplicitly", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRectValid",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsShown",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isShown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsVisible",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isVisible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetMouseClickEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetMouseMotionEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetParent",
			Type = "Function",

			Arguments =
			{
				{ Name = "parent", Type = "table", Nilable = true },
			},
		},
		{
			Name = "SetPassThroughButtons",
			Type = "Function",

			Arguments =
			{
				{ Name = "unpackedPrimitiveType", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "SetScript",
			Type = "Function",

			Arguments =
			{
				{ Name = "scriptTypeName", Type = "string", Nilable = false },
				{ Name = "script", Type = "function", Nilable = true },
			},
		},
		{
			Name = "SetShown",
			Type = "Function",

			Arguments =
			{
				{ Name = "show", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "Show",
			Type = "Function",

			Arguments =
			{
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

APIDocumentation:AddDocumentationTable(SimpleScriptRegionAPI);