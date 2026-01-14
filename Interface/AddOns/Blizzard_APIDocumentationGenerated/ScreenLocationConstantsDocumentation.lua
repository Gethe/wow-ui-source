local ScreenLocationConstants =
{
	Tables =
	{
		{
			Name = "ScreenLocationType",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 0,
			MaxValue = 11,
			Fields =
			{
				{ Name = "Center", Type = "ScreenLocationType", EnumValue = 0 },
				{ Name = "Left", Type = "ScreenLocationType", EnumValue = 1 },
				{ Name = "Right", Type = "ScreenLocationType", EnumValue = 2 },
				{ Name = "Top", Type = "ScreenLocationType", EnumValue = 3 },
				{ Name = "Bottom", Type = "ScreenLocationType", EnumValue = 4 },
				{ Name = "TopLeft", Type = "ScreenLocationType", EnumValue = 5 },
				{ Name = "TopRight", Type = "ScreenLocationType", EnumValue = 6 },
				{ Name = "LeftOutside", Type = "ScreenLocationType", EnumValue = 7 },
				{ Name = "RightOutside", Type = "ScreenLocationType", EnumValue = 8 },
				{ Name = "LeftRight", Type = "ScreenLocationType", EnumValue = 9 },
				{ Name = "TopBottom", Type = "ScreenLocationType", EnumValue = 10 },
				{ Name = "LeftRightOutside", Type = "ScreenLocationType", EnumValue = 11 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ScreenLocationConstants);