local SimpleFontStringAPI =
{
	Name = "SimpleFontStringAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "CalculateScreenAreaFromCharacterSpan",
			Type = "Function",

			Arguments =
			{
				{ Name = "leftIndex", Type = "luaIndex", Nilable = false },
				{ Name = "rightIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "areas", Type = "table", InnerType = "uiBoundsRect", Nilable = true },
			},
		},
		{
			Name = "CanNonSpaceWrap",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "wrap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanWordWrap",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "wrap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "FindCharacterIndexAtCoordinate",
			Type = "Function",

			Arguments =
			{
				{ Name = "x", Type = "uiUnit", Nilable = false },
				{ Name = "y", Type = "uiUnit", Nilable = false },
			},

			Returns =
			{
				{ Name = "characterIndex", Type = "luaIndex", Nilable = false },
				{ Name = "inside", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetFieldSize",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "fieldSize", Type = "number", Nilable = false },
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
				{ Name = "fontFile", Type = "cstring", Nilable = true },
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
			Name = "GetIndentedWordWrap",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "wrap", Type = "bool", Nilable = false },
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
				{ Name = "justifyH", Type = "TBFStyleFlags", Nilable = false },
			},
		},
		{
			Name = "GetLineHeight",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "lineHeight", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetMaxLines",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maxLines", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumLines",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "numLines", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRotation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "radians", Type = "number", Nilable = false },
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
			Name = "GetStringHeight",
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
			Name = "GetStringWidth",
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
			Name = "GetTextScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "textScale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnboundedStringWidth",
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
			Name = "GetWrappedWidth",
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
			Name = "IsTruncated",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isTruncated", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAlphaGradient",
			Type = "Function",

			Arguments =
			{
				{ Name = "start", Type = "number", Nilable = false },
				{ Name = "length", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isWithinText", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFixedColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "fixedColor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFont",
			Type = "Function",

			Arguments =
			{
				{ Name = "fontFile", Type = "cstring", Nilable = false },
				{ Name = "fontHeight", Type = "uiUnit", Nilable = false },
				{ Name = "flags", Type = "TBFFlags", Nilable = false },
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
			Name = "SetFormattedText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetIndentedWordWrap",
			Type = "Function",

			Arguments =
			{
				{ Name = "wrap", Type = "bool", Nilable = false },
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
			Name = "SetMaxLines",
			Type = "Function",

			Arguments =
			{
				{ Name = "maxLines", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetNonSpaceWrap",
			Type = "Function",

			Arguments =
			{
				{ Name = "wrap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetRotation",
			Type = "Function",

			Arguments =
			{
				{ Name = "radians", Type = "number", Nilable = false },
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
				{ Name = "spacing", Type = "uiUnit", Nilable = false },
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
			Name = "SetTextHeight",
			Type = "Function",

			Arguments =
			{
				{ Name = "height", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetTextScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "textScale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetWordWrap",
			Type = "Function",

			Arguments =
			{
				{ Name = "wrap", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleFontStringAPI);