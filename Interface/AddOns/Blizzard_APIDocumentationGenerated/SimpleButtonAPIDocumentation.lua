local SimpleButtonAPI =
{
	Name = "SimpleButtonAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "ClearDisabledTexture",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ClearHighlightTexture",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ClearNormalTexture",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ClearPushedTexture",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "Click",
			Type = "Function",

			Arguments =
			{
				{ Name = "button", Type = "string", Nilable = false, Default = "LeftButton" },
				{ Name = "isDown", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "Disable",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "Enable",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetButtonState",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "buttonState", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetDisabledFontObject",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "font", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetDisabledTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "texture", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetFontString",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "fontString", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetHighlightFontObject",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "font", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetHighlightTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "texture", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetMotionScriptsWhileDisabled",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "motionScriptsWhileDisabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetNormalFontObject",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "font", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetNormalTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "texture", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetPushedTextOffset",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPushedTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "texture", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetText",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "text", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetTextHeight",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTextWidth",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "width", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LockHighlight",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "RegisterForClicks",
			Type = "Function",

			Arguments =
			{
				{ Name = "unpackedPrimitiveType", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "RegisterForMouse",
			Type = "Function",

			Arguments =
			{
				{ Name = "unpackedPrimitiveType", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "SetButtonState",
			Type = "Function",

			Arguments =
			{
				{ Name = "buttonState", Type = "string", Nilable = false },
				{ Name = "lock", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetDisabledAtlas",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetDisabledFontObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "font", Type = "table", Nilable = false },
			},
		},
		{
			Name = "SetDisabledTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetFontString",
			Type = "Function",

			Arguments =
			{
				{ Name = "fontString", Type = "table", Nilable = false },
			},
		},
		{
			Name = "SetFormattedText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetHighlightAtlas",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "string", Nilable = false },
				{ Name = "blendMode", Type = "string", Nilable = true },
			},
		},
		{
			Name = "SetHighlightFontObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "font", Type = "table", Nilable = false },
			},
		},
		{
			Name = "SetHighlightLocked",
			Type = "Function",

			Arguments =
			{
				{ Name = "locked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetHighlightTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "string", Nilable = false },
				{ Name = "blendMode", Type = "string", Nilable = true },
			},
		},
		{
			Name = "SetMotionScriptsWhileDisabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "motionScriptsWhileDisabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetNormalAtlas",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetNormalFontObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "font", Type = "table", Nilable = false },
			},
		},
		{
			Name = "SetNormalTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetPushedAtlas",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetPushedTextOffset",
			Type = "Function",

			Arguments =
			{
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPushedTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false, Default = "" },
			},
		},
		{
			Name = "UnlockHighlight",
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

APIDocumentation:AddDocumentationTable(SimpleButtonAPI);