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
				{ Name = "forcedAspectRatio", Type = "CameraModeAspectRatio", Nilable = false },
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
			Name = "ShowSubtitle",
			Type = "Event",
			LiteralName = "SHOW_SUBTITLE",
			Payload =
			{
				{ Name = "subtitle", Type = "cstring", Nilable = false },
				{ Name = "sender", Type = "cstring", Nilable = true },
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
	},
};

APIDocumentation:AddDocumentationTable(Cinematic);