local TimerConstants =
{
	Tables =
	{
		{
			Name = "StartTimerType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "PvPBeginTimer", Type = "StartTimerType", EnumValue = 0 },
				{ Name = "ChallengeModeCountdown", Type = "StartTimerType", EnumValue = 1 },
				{ Name = "PlayerCountdown", Type = "StartTimerType", EnumValue = 2 },
				{ Name = "PlunderstormCountdown", Type = "StartTimerType", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TimerConstants);