local IslandsQueueUI =
{
	Name = "IslandsQueue",
	Type = "System",
	Namespace = "C_IslandsQueue",

	Functions =
	{
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
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(IslandsQueueUI);