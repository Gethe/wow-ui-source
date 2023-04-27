local SimpleHTMLAPI =
{
	Name = "SimpleHTMLAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetContentHeight",
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
			Name = "GetFont",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
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
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
			},

			Returns =
			{
				{ Name = "font", Type = "SimpleFont", Nilable = false },
			},
		},
		{
			Name = "GetHyperlinkFormat",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "format", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetIndentedWordWrap",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
			},

			Returns =
			{
				{ Name = "wordWrap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetJustifyH",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
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
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
			},

			Returns =
			{
				{ Name = "justifyV", Type = "TBFStyleFlags", Nilable = false },
			},
		},
		{
			Name = "GetShadowColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
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
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
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
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
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
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
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
			Name = "GetTextData",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "content", Type = "table", InnerType = "HTMLContentNode", Nilable = false },
			},
		},
		{
			Name = "SetFont",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
				{ Name = "fontFile", Type = "cstring", Nilable = false },
				{ Name = "height", Type = "uiFontHeight", Nilable = false },
				{ Name = "flags", Type = "TBFFlags", Nilable = false },
			},
		},
		{
			Name = "SetFontObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
				{ Name = "font", Type = "SimpleFont", Nilable = false },
			},
		},
		{
			Name = "SetHyperlinkFormat",
			Type = "Function",

			Arguments =
			{
				{ Name = "format", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetIndentedWordWrap",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
				{ Name = "wordWrap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetJustifyH",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
				{ Name = "justifyH", Type = "TBFStyleFlags", Nilable = false },
			},
		},
		{
			Name = "SetJustifyV",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
				{ Name = "justifyV", Type = "TBFStyleFlags", Nilable = false },
			},
		},
		{
			Name = "SetShadowColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
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
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSpacing",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
				{ Name = "spacing", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "ignoreMarkup", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetTextColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "HTMLTextType", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
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

APIDocumentation:AddDocumentationTable(SimpleHTMLAPI);