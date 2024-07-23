local ClientSettings =
{
	Tables =
	{
		{
			Name = "ClientSettingsConfigFlag",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 1,
			MaxValue = 256,
			Fields =
			{
				{ Name = "ClientSettingsConfigDebug", Type = "ClientSettingsConfigFlag", EnumValue = 1 },
				{ Name = "ClientSettingsConfigInternal", Type = "ClientSettingsConfigFlag", EnumValue = 2 },
				{ Name = "ClientSettingsConfigPerf", Type = "ClientSettingsConfigFlag", EnumValue = 4 },
				{ Name = "ClientSettingsConfigGm", Type = "ClientSettingsConfigFlag", EnumValue = 8 },
				{ Name = "ClientSettingsConfigTest", Type = "ClientSettingsConfigFlag", EnumValue = 16 },
				{ Name = "ClientSettingsConfigTestRetail", Type = "ClientSettingsConfigFlag", EnumValue = 32 },
				{ Name = "ClientSettingsConfigBeta", Type = "ClientSettingsConfigFlag", EnumValue = 64 },
				{ Name = "ClientSettingsConfigBetaRetail", Type = "ClientSettingsConfigFlag", EnumValue = 128 },
				{ Name = "ClientSettingsConfigRetail", Type = "ClientSettingsConfigFlag", EnumValue = 256 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ClientSettings);