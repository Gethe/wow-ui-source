local SplashScreen =
{
	Name = "SplashScreen",
	Type = "System",
	Namespace = "C_SplashScreen",

	Functions =
	{
		{
			Name = "AcknowledgeSplash",
			Type = "Function",
		},
		{
			Name = "CanViewSplashScreen",
			Type = "Function",

			Returns =
			{
				{ Name = "canView", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestLatestSplashScreen",
			Type = "Function",

			Arguments =
			{
				{ Name = "fromGameMenu", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "OpenSplashScreen",
			Type = "Event",
			LiteralName = "OPEN_SPLASH_SCREEN",
			Payload =
			{
				{ Name = "info", Type = "SplashScreenInfo", Nilable = true },
			},
		},
	},

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
		{
			Name = "SplashScreenInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "minDisplayCharLevel", Type = "number", Nilable = false },
				{ Name = "minQuestDisplayLevel", Type = "number", Nilable = false },
				{ Name = "soundKitID", Type = "number", Nilable = false },
				{ Name = "allianceQuestID", Type = "number", Nilable = true },
				{ Name = "hordeQuestID", Type = "number", Nilable = true },
				{ Name = "header", Type = "string", Nilable = false },
				{ Name = "topLeftFeatureTitle", Type = "string", Nilable = false },
				{ Name = "topLeftFeatureDesc", Type = "string", Nilable = false },
				{ Name = "bottomLeftFeatureTitle", Type = "string", Nilable = false },
				{ Name = "bottomLeftFeatureDesc", Type = "string", Nilable = false },
				{ Name = "rightFeatureTitle", Type = "string", Nilable = false },
				{ Name = "rightFeatureDesc", Type = "string", Nilable = false },
				{ Name = "shouldShowQuest", Type = "bool", Nilable = false },
				{ Name = "screenType", Type = "SplashScreenType", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SplashScreen);