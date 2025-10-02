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
	},
};

APIDocumentation:AddDocumentationTable(UIColor);