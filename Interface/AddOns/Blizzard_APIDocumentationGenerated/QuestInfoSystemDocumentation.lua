local QuestInfoSystem =
{
	Name = "QuestInfoSystem",
	Type = "System",
	Namespace = "C_QuestInfoSystem",

	Functions =
	{
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
	},
};

APIDocumentation:AddDocumentationTable(QuestInfoSystem);