local SimpleEditBoxAPI =
{
	Name = "SimpleEditBoxAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AddHistoryLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ClearFocus",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ClearHighlightText",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ClearHistory",
			Type = "Function",

			Arguments =
			{
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
			Name = "GetAltArrowKeyMode",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "altMode", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetBlinkSpeed",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "cursorBlinkSpeedSec", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCursorPosition",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "cursorPosition", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDisplayText",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "displayText", Type = "string", Nilable = false },
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
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "fontHeight", Type = "uiUnit", Nilable = false },
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
			Name = "GetHighlightColor",
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
			Name = "GetHistoryLines",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "numHistoryLines", Type = "number", Nilable = false },
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
				{ Name = "isIndented", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetInputLanguage",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "language", Type = "cstring", Nilable = false },
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
				{ Name = "justifyH", Type = "TBFStyleFlags", Nilable = false },
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
				{ Name = "justifyV", Type = "TBFStyleFlags", Nilable = false },
			},
		},
		{
			Name = "GetMaxBytes",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maxBytes", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxLetters",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maxLetters", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumLetters",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "numLetters", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumber",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "number", Type = "number", Nilable = true },
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
				{ Name = "fontHeight", Type = "uiUnit", Nilable = false },
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
			Name = "GetTextInsets",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "right", Type = "uiUnit", Nilable = false },
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetUTF8CursorPosition",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "cursorPosition", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetVisibleTextByteLimit",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maxVisibleBytes", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasFocus",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasFocus", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasText",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasText", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HighlightText",
			Type = "Function",

			Arguments =
			{
				{ Name = "start", Type = "number", Nilable = false, Default = 0 },
				{ Name = "stop", Type = "number", Nilable = false, Default = -1 },
			},
		},
		{
			Name = "Insert",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsAlphabeticOnly",
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
			Name = "IsAutoFocus",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "autoFocus", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCountInvisibleLetters",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "countInvisibleLetters", Type = "bool", Nilable = false },
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
			Name = "IsInIMECompositionMode",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isInIMECompositionMode", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMultiLine",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "multiline", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsNumeric",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isNumeric", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsNumericFullRange",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isNumeric", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPassword",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isPassword", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSecureText",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isSecure", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ResetInputMode",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetAlphabeticOnly",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetAltArrowKeyMode",
			Type = "Function",

			Arguments =
			{
				{ Name = "altMode", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetAutoFocus",
			Type = "Function",

			Arguments =
			{
				{ Name = "autoFocus", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetBlinkSpeed",
			Type = "Function",

			Arguments =
			{
				{ Name = "cursorBlinkSpeedSec", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCountInvisibleLetters",
			Type = "Function",

			Arguments =
			{
				{ Name = "countInvisibleLetters", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetCursorPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "cursorPosition", Type = "number", Nilable = false },
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
			Name = "SetFocus",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetFont",
			Type = "Function",

			Arguments =
			{
				{ Name = "fontFile", Type = "cstring", Nilable = false },
				{ Name = "height", Type = "uiFontHeight", Nilable = false },
				{ Name = "flags", Type = "TBFFlags", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFontObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "font", Type = "SimpleFont", Nilable = false },
			},
		},
		{
			Name = "SetHighlightColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetHistoryLines",
			Type = "Function",

			Arguments =
			{
				{ Name = "numHistoryLines", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetIndentedWordWrap",
			Type = "Function",

			Arguments =
			{
				{ Name = "isIndented", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetJustifyH",
			Type = "Function",

			Arguments =
			{
				{ Name = "justifyH", Type = "TBFStyleFlags", Nilable = false },
			},
		},
		{
			Name = "SetJustifyV",
			Type = "Function",

			Arguments =
			{
				{ Name = "justifyV", Type = "TBFStyleFlags", Nilable = false },
			},
		},
		{
			Name = "SetMaxBytes",
			Type = "Function",

			Arguments =
			{
				{ Name = "maxBytes", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMaxLetters",
			Type = "Function",

			Arguments =
			{
				{ Name = "maxLetters", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMultiLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "multiline", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetNumber",
			Type = "Function",

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetNumeric",
			Type = "Function",

			Arguments =
			{
				{ Name = "isNumeric", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetNumericFullRange",
			Type = "Function",

			Arguments =
			{
				{ Name = "isNumeric", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetPassword",
			Type = "Function",

			Arguments =
			{
				{ Name = "isPassword", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetSecureText",
			Type = "Function",

			Arguments =
			{
				{ Name = "isSecure", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetSecurityDisablePaste",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetSecurityDisableSetText",
			Type = "Function",

			Arguments =
			{
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
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
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
				{ Name = "fontHeight", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
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
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetTextInsets",
			Type = "Function",

			Arguments =
			{
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "right", Type = "uiUnit", Nilable = false },
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetVisibleTextByteLimit",
			Type = "Function",

			Arguments =
			{
				{ Name = "maxVisibleBytes", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ToggleInputLanguage",
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

APIDocumentation:AddDocumentationTable(SimpleEditBoxAPI);