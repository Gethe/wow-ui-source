local TooltipConstants =
{
	Tables =
	{
		{
			Name = "TooltipSide",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Left", Type = "TooltipSide", EnumValue = 0 },
				{ Name = "Right", Type = "TooltipSide", EnumValue = 1 },
				{ Name = "Top", Type = "TooltipSide", EnumValue = 2 },
				{ Name = "Bottom", Type = "TooltipSide", EnumValue = 3 },
			},
		},
		{
			Name = "TooltipTextureAnchor",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "LeftTop", Type = "TooltipTextureAnchor", EnumValue = 0 },
				{ Name = "LeftCenter", Type = "TooltipTextureAnchor", EnumValue = 1 },
				{ Name = "LeftBottom", Type = "TooltipTextureAnchor", EnumValue = 2 },
				{ Name = "RightTop", Type = "TooltipTextureAnchor", EnumValue = 3 },
				{ Name = "RightCenter", Type = "TooltipTextureAnchor", EnumValue = 4 },
				{ Name = "RightBottom", Type = "TooltipTextureAnchor", EnumValue = 5 },
				{ Name = "All", Type = "TooltipTextureAnchor", EnumValue = 6 },
			},
		},
		{
			Name = "TooltipTextureRelativeRegion",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "LeftLine", Type = "TooltipTextureRelativeRegion", EnumValue = 0 },
				{ Name = "RightLine", Type = "TooltipTextureRelativeRegion", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TooltipConstants);