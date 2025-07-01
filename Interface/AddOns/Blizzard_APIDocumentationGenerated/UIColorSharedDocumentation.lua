local UIColorShared =
{
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

APIDocumentation:AddDocumentationTable(UIColorShared);