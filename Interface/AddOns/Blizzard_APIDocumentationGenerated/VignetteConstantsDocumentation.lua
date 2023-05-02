local VignetteConstants =
{
	Tables =
	{
		{
			Name = "VignetteType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Normal", Type = "VignetteType", EnumValue = 0 },
				{ Name = "PvPBounty", Type = "VignetteType", EnumValue = 1 },
				{ Name = "Torghast", Type = "VignetteType", EnumValue = 2 },
				{ Name = "Treasure", Type = "VignetteType", EnumValue = 3 },
				{ Name = "FyrakkFlight", Type = "VignetteType", EnumValue = 4 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(VignetteConstants);