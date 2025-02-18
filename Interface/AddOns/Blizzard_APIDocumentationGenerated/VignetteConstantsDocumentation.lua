local VignetteConstants =
{
	Tables =
	{
		{
			Name = "VignetteObjectiveType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "VignetteObjectiveType", EnumValue = 0 },
				{ Name = "Defeat", Type = "VignetteObjectiveType", EnumValue = 1 },
				{ Name = "DefeatShowRemainingHealth", Type = "VignetteObjectiveType", EnumValue = 2 },
			},
		},
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