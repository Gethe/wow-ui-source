local QuestInfoSystem =
{
	Name = "QuestInfoSystem",
	Type = "System",
	Namespace = "C_QuestInfoSystem",

	Functions =
	{
		{
			Name = "GetQuestClassification",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "classification", Type = "QuestClassification", Nilable = true },
			},
		},
		{
			Name = "GetQuestRewardCurrencies",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "questRewardCurrencyInfo", Type = "table", InnerType = "QuestRewardCurrencyInfo", Nilable = false },
			},
		},
		{
			Name = "GetQuestRewardSpellInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "QuestRewardSpellInfo", Nilable = true },
			},
		},
		{
			Name = "GetQuestRewardSpells",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "spellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestShouldToastCompletion",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "shouldToast", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasQuestRewardCurrencies",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "hasQuestRewardCurrencies", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasQuestRewardSpells",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "hasRewardSpells", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "QuestClassification",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Important", Type = "QuestClassification", EnumValue = 0 },
				{ Name = "Legendary", Type = "QuestClassification", EnumValue = 1 },
				{ Name = "Campaign", Type = "QuestClassification", EnumValue = 2 },
				{ Name = "Calling", Type = "QuestClassification", EnumValue = 3 },
				{ Name = "Meta", Type = "QuestClassification", EnumValue = 4 },
				{ Name = "Recurring", Type = "QuestClassification", EnumValue = 5 },
				{ Name = "Questline", Type = "QuestClassification", EnumValue = 6 },
				{ Name = "Normal", Type = "QuestClassification", EnumValue = 7 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestInfoSystem);