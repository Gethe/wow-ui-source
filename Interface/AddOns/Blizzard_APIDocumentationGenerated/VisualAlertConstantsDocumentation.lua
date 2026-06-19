local VisualAlertConstants =
{
	Tables =
	{
		{
			Name = "VisualAlertType",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 1,
			MaxValue = 10,
			Fields =
			{
				{ Name = "MarchingAnts", Type = "VisualAlertType", EnumValue = 1 },
				{ Name = "MarchingAntsCyan", Type = "VisualAlertType", EnumValue = 2 },
				{ Name = "MarchingAntsRed", Type = "VisualAlertType", EnumValue = 3 },
				{ Name = "MarchingAntsGreen", Type = "VisualAlertType", EnumValue = 4 },
				{ Name = "MarchingAntsBlue", Type = "VisualAlertType", EnumValue = 5 },
				{ Name = "Flash", Type = "VisualAlertType", EnumValue = 6 },
				{ Name = "FlashCyan", Type = "VisualAlertType", EnumValue = 7 },
				{ Name = "FlashRed", Type = "VisualAlertType", EnumValue = 8 },
				{ Name = "FlashGreen", Type = "VisualAlertType", EnumValue = 9 },
				{ Name = "FlashBlue", Type = "VisualAlertType", EnumValue = 10 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(VisualAlertConstants);