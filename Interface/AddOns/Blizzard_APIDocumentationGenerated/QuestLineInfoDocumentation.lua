local QuestLineInfo =
{
	Name = "QuestLineUI",
	Type = "System",
	Namespace = "C_QuestLine",

	Functions =
	{
		{
			Name = "GetAvailableQuestLines",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questLines", Type = "table", InnerType = "QuestLineInfo", Nilable = false },
			},
		},
		{
			Name = "GetForceVisibleQuests",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestLineInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "uiMapID", Type = "number", Nilable = true },
				{ Name = "displayableOnly", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "questLineInfo", Type = "QuestLineInfo", Nilable = true },
			},
		},
		{
			Name = "GetQuestLineQuests",
			Type = "Function",

			Arguments =
			{
				{ Name = "questLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "IsComplete",
			Type = "Function",

			Arguments =
			{
				{ Name = "questLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isComplete", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "QuestLineIgnoresAccountCompletedFiltering",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "questLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questLineIgnoresAccountCompletedFiltering", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestQuestLinesForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "QuestLineFloorLocation",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Above", Type = "QuestLineFloorLocation", EnumValue = 0 },
				{ Name = "Below", Type = "QuestLineFloorLocation", EnumValue = 1 },
				{ Name = "Same", Type = "QuestLineFloorLocation", EnumValue = 2 },
			},
		},
		{
			Name = "QuestLineInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "questLineName", Type = "cstring", Nilable = false },
				{ Name = "questName", Type = "cstring", Nilable = false },
				{ Name = "questLineID", Type = "number", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "isHidden", Type = "bool", Nilable = false },
				{ Name = "isLegendary", Type = "bool", Nilable = false },
				{ Name = "isLocalStory", Type = "bool", Nilable = false },
				{ Name = "isDaily", Type = "bool", Nilable = false },
				{ Name = "isCampaign", Type = "bool", Nilable = false },
				{ Name = "isImportant", Type = "bool", Nilable = false },
				{ Name = "isAccountCompleted", Type = "bool", Nilable = false },
				{ Name = "isCombatAllyQuest", Type = "bool", Nilable = false },
				{ Name = "isMeta", Type = "bool", Nilable = false },
				{ Name = "inProgress", Type = "bool", Nilable = false },
				{ Name = "isQuestStart", Type = "bool", Nilable = false },
				{ Name = "floorLocation", Type = "QuestLineFloorLocation", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestLineInfo);