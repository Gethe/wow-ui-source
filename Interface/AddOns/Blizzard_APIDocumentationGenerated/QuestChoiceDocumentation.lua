local QuestChoice =
{
	Name = "QuestChoice",
	Type = "System",
	Namespace = "C_QuestChoice",

	Functions =
	{
		{
			Name = "CloseQuestChoice",
			Type = "Function",
		},
		{
			Name = "GetQuestChoiceInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "choiceID", Type = "number", Nilable = false },
				{ Name = "questionText", Type = "string", Nilable = false },
				{ Name = "numOptions", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestChoiceOptionInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "responseID", Type = "number", Nilable = false },
				{ Name = "answer", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "iconID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestChoiceRewardCurrency",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "optionIndex", Type = "number", Nilable = false },
				{ Name = "currencyIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "iconID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestChoiceRewardFaction",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "optionIndex", Type = "number", Nilable = false },
				{ Name = "currencyIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestChoiceRewardInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "title", Type = "string", Nilable = true },
				{ Name = "skillLineID", Type = "number", Nilable = false },
				{ Name = "skillPointCount", Type = "number", Nilable = false },
				{ Name = "money", Type = "number", Nilable = false },
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "numItems", Type = "number", Nilable = false },
				{ Name = "numCurrencies", Type = "number", Nilable = false },
				{ Name = "numItemChoices", Type = "number", Nilable = false },
				{ Name = "numFactions", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestChoiceRewardItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "optionIndex", Type = "number", Nilable = false },
				{ Name = "itemIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "iconID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SendQuestChoiceResponse",
			Type = "Function",

			Arguments =
			{
				{ Name = "responseID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "QuestChoiceClose",
			Type = "Event",
			LiteralName = "QUEST_CHOICE_CLOSE",
		},
		{
			Name = "QuestChoiceUpdate",
			Type = "Event",
			LiteralName = "QUEST_CHOICE_UPDATE",
		},
		{
			Name = "UniqueQuestChoiceUpdate",
			Type = "Event",
			LiteralName = "UNIQUE_QUEST_CHOICE_UPDATE",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(QuestChoice);