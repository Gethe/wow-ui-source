local QuestChoice =
{
	Name = "QuestChoice",
	Type = "System",
	Namespace = "C_QuestChoice",

	Functions =
	{
		{
			Name = "GetQuestChoiceOptionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "optionIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "responseID", Type = "number", Nilable = false },
				{ Name = "buttonText", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "header", Type = "string", Nilable = false },
				{ Name = "choiceArtID", Type = "number", Nilable = false },
				{ Name = "confirmation", Type = "string", Nilable = true },
				{ Name = "widgetSetID", Type = "number", Nilable = true },
				{ Name = "disabledButton", Type = "bool", Nilable = false },
				{ Name = "desaturatedArt", Type = "bool", Nilable = false },
				{ Name = "groupID", Type = "number", Nilable = true },
				{ Name = "headerIconAtlasElement", Type = "string", Nilable = true },
				{ Name = "subHeader", Type = "string", Nilable = true },
				{ Name = "buttonTooltip", Type = "string", Nilable = true },
				{ Name = "rewardQuestID", Type = "number", Nilable = true },
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
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(QuestChoice);