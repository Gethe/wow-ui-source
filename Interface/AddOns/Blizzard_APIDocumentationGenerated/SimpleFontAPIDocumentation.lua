local SimpleFontAPI =
{
	Name = "SimpleFontAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "CopyFontObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "sourceFont", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
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
			Name = "SetAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
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
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SimpleFontAPI);