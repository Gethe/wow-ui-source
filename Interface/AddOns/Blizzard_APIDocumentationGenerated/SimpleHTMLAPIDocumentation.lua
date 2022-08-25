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
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFont",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "string", Nilable = false },
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
				{ Name = "textType", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "font", Type = "table", Nilable = false },
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
				{ Name = "format", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetIndentedWordWrap",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "string", Nilable = false },
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
				{ Name = "textType", Type = "string", Nilable = false },
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
				{ Name = "textType", Type = "string", Nilable = false },
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
				{ Name = "textType", Type = "string", Nilable = false },
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
				{ Name = "textType", Type = "string", Nilable = false },
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
				{ Name = "textType", Type = "string", Nilable = false },
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
				{ Name = "textType", Type = "string", Nilable = false },
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
				{ Name = "textType", Type = "string", Nilable = false },
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
				{ Name = "textType", Type = "string", Nilable = false },
				{ Name = "font", Type = "table", Nilable = false },
			},
		},
		{
			Name = "SetHyperlinkFormat",
			Type = "Function",

			Arguments =
			{
				{ Name = "format", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetIndentedWordWrap",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "string", Nilable = false },
				{ Name = "wordWrap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetJustifyH",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "string", Nilable = false },
				{ Name = "justifyH", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetJustifyV",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "string", Nilable = false },
				{ Name = "justifyV", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetShadowColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "string", Nilable = false },
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
				{ Name = "textType", Type = "string", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSpacing",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "string", Nilable = false },
				{ Name = "spacing", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "ignoreMarkup", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetTextColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "textType", Type = "string", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "number", Nilable = true },
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