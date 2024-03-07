local QuestTaskInfo =
{
	Name = "QuestTaskInfo",
	Type = "System",
	Namespace = "C_TaskQuest",

	Functions =
	{
		{
			Name = "DoesMapShowTaskQuestObjectives",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "showsTaskQuestObjectives", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetQuestInfoByQuestID",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questTitle", Type = "cstring", Nilable = false },
				{ Name = "factionID", Type = "number", Nilable = true },
				{ Name = "capped", Type = "bool", Nilable = true },
				{ Name = "displayAsObjective", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "GetQuestLocation",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "locationX", Type = "number", Nilable = false },
				{ Name = "locationY", Type = "number", Nilable = false },
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
			Name = "GetQuestTimeLeftSeconds",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "secondsLeft", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestZoneID",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestsForPlayerByMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "taskPOIs", Type = "table", InnerType = "TaskPOIData", Nilable = false },
			},
		},
		{
			Name = "GetThreatQuests",
			Type = "Function",

			Returns =
			{
				{ Name = "quests", Type = "table", InnerType = "number", Nilable = false },
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
			Name = "TaskPOIData",
			Type = "Structure",
			Fields =
			{
				{ Name = "questId", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "inProgress", Type = "bool", Nilable = false },
				{ Name = "numObjectives", Type = "number", Nilable = false },
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "isQuestStart", Type = "bool", Nilable = false },
				{ Name = "isDaily", Type = "bool", Nilable = false },
				{ Name = "isCombatAllyQuest", Type = "bool", Nilable = false },
				{ Name = "childDepth", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestTaskInfo);