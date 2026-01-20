local SplashScreenConstants =
{
	Tables =
	{
		{
			Name = "SplashScreenType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "WhatsNew", Type = "SplashScreenType", EnumValue = 0 },
				{ Name = "SeasonRollOver", Type = "SplashScreenType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SplashScreenConstants);