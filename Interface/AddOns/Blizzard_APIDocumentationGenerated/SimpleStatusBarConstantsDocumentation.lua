local SimpleStatusBarConstants =
{
	Tables =
	{
		{
			Name = "StatusBarFillStyle",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Standard", Type = "StatusBarFillStyle", EnumValue = 0, Documentation = { "Fills the bar regularly, either in a left-to-right or top-to-bottom direction as values increase." } },
				{ Name = "StandardNoRangeFill", Type = "StatusBarFillStyle", EnumValue = 1, Documentation = { "Similar to standard, except if the range between the min and max values is zero instead render as-if the bar were 100% full. If the min and max values are both zero, will render as 0% full." } },
				{ Name = "Center", Type = "StatusBarFillStyle", EnumValue = 2, Documentation = { "Fills the bar in an outward growing manner from the center." } },
				{ Name = "Reverse", Type = "StatusBarFillStyle", EnumValue = 3, Documentation = { "Inverse of Standard, filling right-to-left or bottom-to-top as values increase." } },
			},
		},
		{
			Name = "StatusBarInterpolation",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Immediate", Type = "StatusBarInterpolation", EnumValue = 0, Documentation = { "Immediately snap to the target value with no interpolation." } },
				{ Name = "ExponentialEaseOut", Type = "StatusBarInterpolation", EnumValue = 1, Documentation = { "Interpolate the bar toward the target value with exponential ease-out style decay." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SimpleStatusBarConstants);