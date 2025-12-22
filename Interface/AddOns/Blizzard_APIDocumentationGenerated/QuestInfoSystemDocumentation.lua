local QuestInfoSystem =
{
	Name = "QuestInfoSystem",
	Type = "System",
	Namespace = "C_QuestInfoSystem",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetQuestClassification",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "questInfoID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "classification", Type = "QuestClassification", Nilable = false },
			},
		},
		{
			Name = "GetQuestLogRewardFavor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "clampFavorToCycleCap", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestRewardCurrencies",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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