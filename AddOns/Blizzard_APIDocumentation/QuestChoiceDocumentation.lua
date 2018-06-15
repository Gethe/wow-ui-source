local QuestChoice =
{
	Name = "QuestChoice",
	Type = "System",
	Namespace = "C_QuestChoice",

	Functions =
	{
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