local DuelInfo =
{
	Name = "DuelInfo",
	Type = "System",
	Namespace = "C_DuelInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "DuelFinished",
			Type = "Event",
			LiteralName = "DUEL_FINISHED",
			SynchronousEvent = true,
		},
		{
			Name = "DuelInbounds",
			Type = "Event",
			LiteralName = "DUEL_INBOUNDS",
			SynchronousEvent = true,
		},
		{
			Name = "DuelOutofbounds",
			Type = "Event",
			LiteralName = "DUEL_OUTOFBOUNDS",
			SynchronousEvent = true,
		},
		{
			Name = "DuelRequested",
			Type = "Event",
			LiteralName = "DUEL_REQUESTED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "playerName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "DuelToTheDeathRequested",
			Type = "Event",
			LiteralName = "DUEL_TO_THE_DEATH_REQUESTED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "playerName", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(DuelInfo);