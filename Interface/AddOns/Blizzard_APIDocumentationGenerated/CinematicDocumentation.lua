local Cinematic =
{
	Name = "Cinematic",
	Type = "System",

	Functions =
	{
		{
			Name = "CinematicFinished",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "movieType", Type = "CinematicType", Nilable = false },
				{ Name = "userCanceled", Type = "bool", Nilable = false, Default = false },
				{ Name = "didError", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "CinematicStarted",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "movieType", Type = "CinematicType", Nilable = false },
				{ Name = "movieID", Type = "number", Nilable = false },
				{ Name = "canCancel", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "InCinematic",
			Type = "Function",

			Returns =
			{
				{ Name = "inCinematic", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MouseOverrideCinematicDisable",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "doOverride", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "OpeningCinematic",
			Type = "Function",
		},
		{
			Name = "StopCinematic",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "CinematicStart",
			Type = "Event",
			LiteralName = "CINEMATIC_START",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "HideSubtitle",
			Type = "Event",
			LiteralName = "HIDE_SUBTITLE",
			SynchronousEvent = true,
		},
		{
			Name = "PlayMovie",
			Type = "Event",
			LiteralName = "PLAY_MOVIE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "movieID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShowSubtitle",
			Type = "Event",
			LiteralName = "SHOW_SUBTITLE",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Cinematic);