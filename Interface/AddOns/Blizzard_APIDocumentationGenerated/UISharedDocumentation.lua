local UIShared =
{
	Tables =
	{
		{
			Name = "FontStringScaleAnimationMode",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "FontSize", Type = "FontStringScaleAnimationMode", EnumValue = 0, Documentation = { "Scale animations apply to the height of the font. This will cause small jumps between different font heights as the animation progresses, and may adjust the layout of text if used on a fixed-size font string." } },
				{ Name = "Vertex", Type = "FontStringScaleAnimationMode", EnumValue = 1, Documentation = { "Scale animations apply to the vertices of the font. Scaling is smoother, but if used on non-slug fonts may cause significant pixelation of the font text, Layout of the text is not adjusted as the animation progresses, and the direction of scaling respects horizontal and vertical justification settings (eg. text at the bottom-right scaling up grows toward the top-left)." } },
			},
		},
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