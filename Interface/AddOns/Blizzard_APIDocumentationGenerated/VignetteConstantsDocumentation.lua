local VignetteConstants =
{
	Tables =
	{
		{
			Name = "VignetteType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Normal", Type = "VignetteType", EnumValue = 0 },
				{ Name = "PvPBounty", Type = "VignetteType", EnumValue = 1 },
				{ Name = "Torghast", Type = "VignetteType", EnumValue = 2 },
				{ Name = "Treasure", Type = "VignetteType", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(VignetteConstants);