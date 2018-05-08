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
			Name = "GetIslandInfoByDifficulty",
			Type = "Function",

			Arguments =
			{
				{ Name = "difficulty", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "table", InnerType = "IslandsQueueInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "IslandsQueueInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "cardArtAtlas", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(IslandsQueueUI);