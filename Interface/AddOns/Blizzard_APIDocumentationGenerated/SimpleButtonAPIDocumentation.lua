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
				{ Name = "button", Type = "cstring", Nilable = false, Default = "LeftButton" },
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
				{ Name = "buttonState", Type = "SimpleButtonStateToken", Nilable = false },
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
				{ Name = "font", Type = "SimpleFont", Nilable = false },
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
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
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
				{ Name = "fontString", Type = "SimpleFontString", Nilable = false },
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
				{ Name = "font", Type = "SimpleFont", Nilable = false },
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
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
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
				{ Name = "font", Type = "SimpleFont", Nilable = false },
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
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
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
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
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
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
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
				{ Name = "text", Type = "cstring", Nilable = false },
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
				{ Name = "height", Type = "uiUnit", Nilable = false },
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
				{ Name = "width", Type = "uiUnit", Nilable = false },
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
				{ Name = "buttonState", Type = "SimpleButtonStateToken", Nilable = false },
				{ Name = "lock", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetDisabledAtlas",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},
		},
		{
			Name = "SetDisabledFontObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "font", Type = "SimpleFont", Nilable = false },
			},
		},
		{
			Name = "SetDisabledTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
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
				{ Name = "fontString", Type = "SimpleFontString", Nilable = false },
			},
		},
		{
			Name = "SetFormattedText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetHighlightAtlas",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
				{ Name = "blendMode", Type = "BlendMode", Nilable = true },
			},
		},
		{
			Name = "SetHighlightFontObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "font", Type = "SimpleFont", Nilable = false },
			},
		},
		{
			Name = "SetHighlightTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
				{ Name = "blendMode", Type = "BlendMode", Nilable = true },
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
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},
		},
		{
			Name = "SetNormalFontObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "font", Type = "SimpleFont", Nilable = false },
			},
		},
		{
			Name = "SetNormalTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetPushedAtlas",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},
		},
		{
			Name = "SetPushedTextOffset",
			Type = "Function",

			Arguments =
			{
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetPushedTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Default = "" },
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