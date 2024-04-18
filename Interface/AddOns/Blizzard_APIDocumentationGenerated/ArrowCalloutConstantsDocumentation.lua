local ArrowCalloutConstants =
{
	Tables =
	{
		{
			Name = "ArrowCalloutDirection",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Up", Type = "ArrowCalloutDirection", EnumValue = 0 },
				{ Name = "Down", Type = "ArrowCalloutDirection", EnumValue = 1 },
				{ Name = "Left", Type = "ArrowCalloutDirection", EnumValue = 2 },
				{ Name = "Right", Type = "ArrowCalloutDirection", EnumValue = 3 },
			},
		},
		{
			Name = "ArrowCalloutType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "ArrowCalloutType", EnumValue = 0 },
				{ Name = "Generic", Type = "ArrowCalloutType", EnumValue = 1 },
				{ Name = "WorldLootObject", Type = "ArrowCalloutType", EnumValue = 2 },
				{ Name = "Tutorial", Type = "ArrowCalloutType", EnumValue = 3 },
				{ Name = "WidgetContainerNoBorder", Type = "ArrowCalloutType", EnumValue = 4 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ArrowCalloutConstants);