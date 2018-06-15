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
			Name = "GetIslandDifficultyIds",
			Type = "Function",

			Returns =
			{
				{ Name = "lfgIslandDifficultyIds", Type = "table", InnerType = "number", Nilable = false },
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

			Arguments =
			{
				{ Name = "difficultyID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "IslandsQueueClose",
			Type = "Event",
			LiteralName = "ISLANDS_QUEUE_CLOSE",
		},
		{
			Name = "IslandsQueueOpen",
			Type = "Event",
			LiteralName = "ISLANDS_QUEUE_OPEN",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(IslandsQueueUI);