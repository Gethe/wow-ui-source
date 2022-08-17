local SimpleMessageFrameAPI =
{
	Name = "SimpleMessageFrameAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AddMessage",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "number", Nilable = true },
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
				{ Name = "fontFile", Type = "string", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
				{ Name = "flags", Type = "string", Nilable = false },
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
				{ Name = "font", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetFontStringByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "messageID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "fontString", Type = "table", Nilable = false },
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
				{ Name = "mode", Type = "string", Nilable = false },
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
				{ Name = "justifyH", Type = "string", Nilable = false },
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
				{ Name = "justifyV", Type = "string", Nilable = false },
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
				{ Name = "spacing", Type = "number", Nilable = false },
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

			Arguments =
			{
				{ Name = "messageID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFadeDuration",
			Type = "Function",

			Arguments =
			{
				{ Name = "fadeDurationSeconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFadePower",
			Type = "Function",

			Arguments =
			{
				{ Name = "fadePower", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFading",
			Type = "Function",

			Arguments =
			{
				{ Name = "fading", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFont",
			Type = "Function",

			Arguments =
			{
				{ Name = "fontFile", Type = "string", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
				{ Name = "flags", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetFontObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "font", Type = "table", Nilable = false },
			},
		},
		{
			Name = "SetIndentedWordWrap",
			Type = "Function",

			Arguments =
			{
				{ Name = "wordWrap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetInsertMode",
			Type = "Function",

			Arguments =
			{
				{ Name = "mode", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetJustifyH",
			Type = "Function",

			Arguments =
			{
				{ Name = "justifyH", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetJustifyV",
			Type = "Function",

			Arguments =
			{
				{ Name = "justifyV", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetShadowColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetShadowOffset",
			Type = "Function",

			Arguments =
			{
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSpacing",
			Type = "Function",

			Arguments =
			{
				{ Name = "spacing", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTextColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetTimeVisible",
			Type = "Function",

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