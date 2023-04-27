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
			Name = "QuestRewardSpellInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "texture", Type = "fileID", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "garrFollowerID", Type = "number", Nilable = true },
				{ Name = "isTradeskill", Type = "bool", Nilable = false },
				{ Name = "isSpellLearned", Type = "bool", Nilable = false },
				{ Name = "hideSpellLearnText", Type = "bool", Nilable = false },
				{ Name = "isBoostSpell", Type = "bool", Nilable = false },
				{ Name = "genericUnlock", Type = "bool", Nilable = false },
				{ Name = "type", Type = "QuestCompleteSpellType", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestInfoSystem);