local GamePadConst =
{
	Tables =
	{
		{
			Name = "GamePadPowerLevel",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Critical", Type = "GamePadPowerLevel", EnumValue = 0 },
				{ Name = "Low", Type = "GamePadPowerLevel", EnumValue = 1 },
				{ Name = "Medium", Type = "GamePadPowerLevel", EnumValue = 2 },
				{ Name = "High", Type = "GamePadPowerLevel", EnumValue = 3 },
				{ Name = "Wired", Type = "GamePadPowerLevel", EnumValue = 4 },
				{ Name = "Unknown", Type = "GamePadPowerLevel", EnumValue = 5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GamePadConst);