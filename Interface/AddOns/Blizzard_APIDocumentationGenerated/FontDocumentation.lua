local Font =
{
	Name = "Font",
	Type = "System",

	Functions =
	{
		{
			Name = "GetFontInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "fontObject", Type = "SimpleFont", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "FontScriptInfo", Nilable = true },
			},
		},
		{
			Name = "GetFonts",
			Type = "Function",

			Returns =
			{
				{ Name = "fontNames", Type = "table", InnerType = "cstring", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "FontScriptInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
				{ Name = "outline", Type = "cstring", Nilable = false },
				{ Name = "shadow", Type = "FontScriptShadowInfo", Nilable = true },
			},
		},
		{
			Name = "FontScriptShadowInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Font);