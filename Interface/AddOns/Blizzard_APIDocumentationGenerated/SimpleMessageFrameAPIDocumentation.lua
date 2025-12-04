local SimpleMessageFrameAPI =
{
	Name = "SimpleMessageFrameAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AddMessage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
				{ Name = "messageID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "Clear",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetFadeDuration",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "fadeDurationSeconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFadePower",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "fadePower", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFading",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isFading", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetFont",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "fontFile", Type = "cstring", Nilable = false },
				{ Name = "height", Type = "uiFontHeight", Nilable = false },
				{ Name = "flags", Type = "TBFFlags", Nilable = false },
			},
		},
		{
			Name = "GetFontObject",
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
			Name = "GetFontStringByID",
			Type = "Function",
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "messageID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "fontString", Type = "SimpleFontString", Nilable = false },
			},
		},
		{
			Name = "GetIndentedWordWrap",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "wordWrap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetInsertMode",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "mode", Type = "InsertMode", Nilable = false },
			},
		},
		{
			Name = "GetJustifyH",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "justifyH", Type = "JustifyHorizontal", Nilable = false },
			},
		},
		{
			Name = "GetJustifyV",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "justifyV", Type = "JustifyVertical", Nilable = false },
			},
		},
		{
			Name = "GetShadowColor",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "colorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetShadowOffset",
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
			Name = "GetSpacing",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "spacing", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetTextColor",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "colorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTimeVisible",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "timeVisibleSeconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasMessageByID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "messageID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasMessage", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ResetMessageFadeByID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "messageID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFadeDuration",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fadeDurationSeconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFadePower",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fadePower", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFading",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fading", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFont",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fontFile", Type = "cstring", Nilable = false },
				{ Name = "height", Type = "uiFontHeight", Nilable = false },
				{ Name = "flags", Type = "TBFFlags", Nilable = false },
			},
		},
		{
			Name = "SetFontObject",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "font", Type = "SimpleFont", Nilable = false },
			},
		},
		{
			Name = "SetIndentedWordWrap",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "wordWrap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetInsertMode",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mode", Type = "InsertMode", Nilable = false },
			},
		},
		{
			Name = "SetJustifyH",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "justifyH", Type = "JustifyHorizontal", Nilable = false },
			},
		},
		{
			Name = "SetJustifyV",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "justifyV", Type = "JustifyVertical", Nilable = false },
			},
		},
		{
			Name = "SetShadowColor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetShadowOffset",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSpacing",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "spacing", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetTextColor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetTimeVisible",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "timeVisibleSeconds", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleMessageFrameAPI);