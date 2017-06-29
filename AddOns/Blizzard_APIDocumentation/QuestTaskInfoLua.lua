local QuestTaskInfoLua =
{
	Name = "QuestTaskInfo",
	Type = "System",
	Namespace = "C_TaskQuest",

	Functions =
	{
		{
			Name = "GetDistanceSqToQuest",
			Type = "Function",

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
			Name = "GetQuestLocation",
			Type = "Function",

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
			Name = "GetQuestZoneID",
			Type = "Function",

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
			Type = "Function",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "parentMapID", Type = "number", Nilable = true },
				{ Name = "transformFlags", Type = "MapTransform", Nilable = true },
			},

			Returns =
			{
				{ Name = "taskPOIs", Type = "table", InnerType = "TaskPOIData", Nilable = false },
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
		{
			Name = "TaskPOIData",
			Type = "Structure",
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