local NeighborhoodInitiativesConstants =
{
	Tables =
	{
		{
			Name = "InitiativeMilestoneFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "FinalMilestone", Type = "InitiativeMilestoneFlags", EnumValue = 1 },
			},
		},
		{
			Name = "InitiativeRewardFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "PermanentWorldState", Type = "InitiativeRewardFlags", EnumValue = 1 },
			},
		},
		{
			Name = "NeighborhoodInitiativeChestResult",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "NiSuccess", Type = "NeighborhoodInitiativeChestResult", EnumValue = 0 },
				{ Name = "NiUnspecifiedFailure", Type = "NeighborhoodInitiativeChestResult", EnumValue = 1 },
				{ Name = "NiNoHouseFound", Type = "NeighborhoodInitiativeChestResult", EnumValue = 2 },
				{ Name = "NiNoRewards", Type = "NeighborhoodInitiativeChestResult", EnumValue = 3 },
				{ Name = "NiThrottled", Type = "NeighborhoodInitiativeChestResult", EnumValue = 4 },
				{ Name = "NiServiceDisabled", Type = "NeighborhoodInitiativeChestResult", EnumValue = 5 },
			},
		},
		{
			Name = "NeighborhoodInitiativeFlags",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Disabled", Type = "NeighborhoodInitiativeFlags", EnumValue = 1 },
				{ Name = "NoAbandon", Type = "NeighborhoodInitiativeFlags", EnumValue = 2 },
				{ Name = "NoRepeat", Type = "NeighborhoodInitiativeFlags", EnumValue = 4 },
			},
		},
		{
			Name = "NeighborhoodInitiativeNeighborhoodTypes",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "NiNeighborhoodTypeSingleton", Type = "NeighborhoodInitiativeNeighborhoodTypes", EnumValue = 0 },
				{ Name = "NiNeighborhoodTypePool", Type = "NeighborhoodInitiativeNeighborhoodTypes", EnumValue = 1 },
			},
		},
		{
			Name = "NeighborhoodInitiativeTaskType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Single", Type = "NeighborhoodInitiativeTaskType", EnumValue = 0 },
				{ Name = "RepeatableFinite", Type = "NeighborhoodInitiativeTaskType", EnumValue = 1 },
				{ Name = "RepeatableInfinite", Type = "NeighborhoodInitiativeTaskType", EnumValue = 2 },
			},
		},
		{
			Name = "NeighborhoodInitiativeUpdateStatus",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Started", Type = "NeighborhoodInitiativeUpdateStatus", EnumValue = 0 },
				{ Name = "MilestoneCompleted", Type = "NeighborhoodInitiativeUpdateStatus", EnumValue = 1 },
				{ Name = "Completed", Type = "NeighborhoodInitiativeUpdateStatus", EnumValue = 2 },
				{ Name = "Failed", Type = "NeighborhoodInitiativeUpdateStatus", EnumValue = 3 },
			},
		},
		{
			Name = "NeighborhoodInitiativesCompletionStates",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "NiCompletionStateNotCompleted", Type = "NeighborhoodInitiativesCompletionStates", EnumValue = 0 },
				{ Name = "NiCompletionStatePlayerCompleted", Type = "NeighborhoodInitiativesCompletionStates", EnumValue = 1 },
				{ Name = "NiCompletionStateSystemAbandoned", Type = "NeighborhoodInitiativesCompletionStates", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(NeighborhoodInitiativesConstants);