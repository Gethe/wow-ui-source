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
				{ Name = "color", Type = "colorRGBA", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(UIColorShared);