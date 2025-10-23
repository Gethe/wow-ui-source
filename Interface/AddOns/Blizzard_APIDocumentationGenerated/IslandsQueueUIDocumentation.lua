local IslandsQueueUI =
{
	Name = "IslandsQueue",
	Type = "System",
	Namespace = "C_IslandsQueue",

	Functions =
	{
		{
			Name = "CloseIslandsQueueScreen",
			Type = "Function",
		},
		{
			Name = "GetIslandDifficultyInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "islandDifficultyInfo", Type = "table", InnerType = "IslandsQueueDifficultyInfo", Nilable = false },
			},
		},
		{
			Name = "GetIslandsMaxGroupSize",
			Type = "Function",

			Returns =
			{
				{ Name = "maxGroupSize", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetIslandsWeeklyQuestID",
			Type = "Function",

			Returns =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "QueueForIsland",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "difficultyID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RequestPreloadRewardData",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "questId", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "IslandsQueueClose",
			Type = "Event",
			LiteralName = "ISLANDS_QUEUE_CLOSE",
			SynchronousEvent = true,
		},
		{
			Name = "IslandsQueueOpen",
			Type = "Event",
			LiteralName = "ISLANDS_QUEUE_OPEN",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "IslandsQueueDifficultyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "difficultyId", Type = "number", Nilable = false },
				{ Name = "previewRewardQuestId", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(IslandsQueueUI);