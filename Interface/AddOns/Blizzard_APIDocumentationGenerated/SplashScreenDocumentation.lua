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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fromGameMenu", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SendSplashScreenActionLaunchedTelem",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "SendSplashScreenCloseTelem",
			Type = "Function",
			HasRestrictions = true,
		},
	},

	Events =
	{
		{
			Name = "OpenSplashScreen",
			Type = "Event",
			LiteralName = "OPEN_SPLASH_SCREEN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "info", Type = "SplashScreenInfo", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "SplashScreenInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
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
				{ Name = "gameMenuRequest", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SplashScreen);