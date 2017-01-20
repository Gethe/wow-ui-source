local QuestTaskInfoLua =
{
	Name = "QuestTaskInfo",
	Namespace = "C_TaskQuest",

	Functions =
	{
		{
			Name = "GetDistanceSqToQuest",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "distanceSquared", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestInfoByQuestID",

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
			Name = "GetQuestLocation",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "parentMapID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "locationX", Type = "number", Nilable = false },
				{ Name = "locationY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestProgressBarInfo",

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
			Name = "GetQuestZoneID",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "zoneMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestsForPlayerByMapID",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "parentMapID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "taskPOIs", Type = "table", InnerType = "TaskPOIData", Nilable = false },
			},
		},
		{
			Name = "IsActive",

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

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "TaskPOIData",
			Fields =
			{
				{ Name = "questId", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "floor", Type = "number", Nilable = false },
				{ Name = "inProgress", Type = "bool", Nilable = false },
				{ Name = "numObjectives", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestTaskInfoLua);