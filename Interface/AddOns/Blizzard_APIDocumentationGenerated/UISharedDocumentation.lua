local UIShared =
{
	Tables =
	{
		{
			Name = "AnchorBinding",
			Type = "Structure",
			Fields =
			{
				{ Name = "point", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "table", Nilable = false },
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "uiRect",
			Type = "Structure",
			Fields =
			{
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIShared);