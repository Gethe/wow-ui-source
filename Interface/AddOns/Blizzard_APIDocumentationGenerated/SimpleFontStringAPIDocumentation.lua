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
				{ Name = "leftIndex", Type = "number", Nilable = false },
				{ Name = "rightIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "areas", Type = "table", InnerType = "uiRect", Nilable = true },
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
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "characterIndex", Type = "number", Nilable = false },
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
				{ Name = "fontFile", Type = "string", Nilable = true },
				{ Name = "fontHeight", Type = "number", Nilable = false },
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
				{ Name = "justifyH", Type = "string", Nilable = false },
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
				{ Name = "lineHeight", Type = "number", Nilable = false },
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
				{ Name = "spacing", Type = "number", Nilable = false },
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
				{ Name = "height", Type = "number", Nilable = false },
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
				{ Name = "width", Type = "number", Nilable = false },
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
				{ Name = "width", Type = "number", Nilable = false },
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
				{ Name = "width", Type = "number", Nilable = false },
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
				{ Name = "fontFile", Type = "string", Nilable = false },
				{ Name = "fontHeight", Type = "number", Nilable = false },
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
			Name = "SetFormattedText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false },
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
			Name = "SetText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false, Default = "" },
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
			Name = "SetTextHeight",
			Type = "Function",

			Arguments =
			{
				{ Name = "height", Type = "number", Nilable = false },
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