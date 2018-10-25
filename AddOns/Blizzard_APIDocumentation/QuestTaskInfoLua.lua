local QuestTaskInfoLua =
{
	Name = "QuestTaskInfo",
	Type = "System",
	Namespace = "C_TaskQuest",

	Functions =
	{
		{
			Name = "GetQuestInfoByQuestID",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questTitle", Type = "string", Nilable = false },
				{ Name = "factionID", Type = "number", Nilable = true },
				{ Name = "capped", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "GetQuestProgressBarInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "progress", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestTimeLeftMinutes",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "minutesLeft", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsActive",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestPreloadRewardData",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "MapTransform",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "IsForFlightMap", Type = "MapTransform", EnumValue = 0 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestTaskInfoLua);