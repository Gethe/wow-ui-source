local UIColor =
{
	Name = "UIColor",
	Type = "System",
	Namespace = "C_UIColor",

	Functions =
	{
		{
			Name = "GetColors",
			Type = "Function",

			Returns =
			{
				{ Name = "colors", Type = "table", InnerType = "DBColorExport", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "DBColorExport",
			Type = "Structure",
			Fields =
			{
				{ Name = "baseTag", Type = "cstring", Nilable = false },
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIColor);