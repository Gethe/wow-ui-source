local Font =
{
	Name = "Font",
	Type = "System",

	Functions =
	{
		{
			Name = "CreateFontFamily",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "members", Type = "table", InnerType = "CreateFontFamilyMemberInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "fontFamily", Type = "SimpleFont", Nilable = false },
			},
		},
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
			Name = "CreateFontFamilyMemberInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "alphabet", Type = "FontAlphabet", Nilable = false },
				{ Name = "file", Type = "cstring", Nilable = false },
				{ Name = "height", Type = "uiFontHeight", Nilable = false },
				{ Name = "flags", Type = "TBFFlags", Nilable = false },
			},
		},
		{
			Name = "FontScriptInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
				{ Name = "outline", Type = "cstring", Nilable = false },
				{ Name = "shadow", Type = "FontScriptShadowInfo", Nilable = true },
				{ Name = "fontObject", Type = "SimpleFont", Nilable = false },
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