local WorldElapsedTimerConstants =
{
	Tables =
	{
		{
			Name = "WorldElapsedTimerTypes",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "WorldElapsedTimerTypes", EnumValue = 0 },
				{ Name = "ChallengeMode", Type = "WorldElapsedTimerTypes", EnumValue = 1 },
				{ Name = "ProvingGround", Type = "WorldElapsedTimerTypes", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WorldElapsedTimerConstants);