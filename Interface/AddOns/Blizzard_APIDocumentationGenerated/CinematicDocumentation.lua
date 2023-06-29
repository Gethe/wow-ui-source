local Cinematic =
{
	Name = "Cinematic",
	Type = "System",
	Namespace = "C_Cinematic",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "CinematicStart",
			Type = "Event",
			LiteralName = "CINEMATIC_START",
			Payload =
			{
				{ Name = "canBeCancelled", Type = "bool", Nilable = false },
				{ Name = "forcedAspectRatio", Type = "CinematicAspectRatio", Nilable = false },
			},
		},
		{
			Name = "CinematicStop",
			Type = "Event",
			LiteralName = "CINEMATIC_STOP",
		},
		{
			Name = "HideSubtitle",
			Type = "Event",
			LiteralName = "HIDE_SUBTITLE",
		},
		{
			Name = "PlayMovie",
			Type = "Event",
			LiteralName = "PLAY_MOVIE",
			Payload =
			{
				{ Name = "movieID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "StopMovie",
			Type = "Event",
			LiteralName = "STOP_MOVIE",
		},
	},

	Tables =
	{
		{
			Name = "CinematicAspectRatio",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "NoAspectRatioSpecified", Type = "CinematicAspectRatio", EnumValue = 0 },
				{ Name = "Legacy_16_X_9", Type = "CinematicAspectRatio", EnumValue = 1 },
				{ Name = "Square_1_X_1", Type = "CinematicAspectRatio", EnumValue = 2 },
				{ Name = "Sd_4_X_3", Type = "CinematicAspectRatio", EnumValue = 3 },
				{ Name = "Hd_16_X_9", Type = "CinematicAspectRatio", EnumValue = 4 },
				{ Name = "Cinemascope2Dot4X_1", Type = "CinematicAspectRatio", EnumValue = 5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Cinematic);