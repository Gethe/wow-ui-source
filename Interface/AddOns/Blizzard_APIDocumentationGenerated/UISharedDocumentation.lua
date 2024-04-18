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
				{ Name = "relativeTo", Type = "ScriptRegion", Nilable = false },
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "uiBoundsRect",
			Type = "Structure",
			Fields =
			{
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
				{ Name = "width", Type = "uiUnit", Nilable = false },
				{ Name = "height", Type = "uiUnit", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIShared);