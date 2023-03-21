local QuestOffer =
{
	Name = "QuestOffer",
	Type = "System",
	Namespace = "C_QuestOffer",

	Functions =
	{
		{
			Name = "GetHideRequiredItems",
			Type = "Function",

			Returns =
			{
				{ Name = "hideRequiredItems", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetQuestOfferMajorFactionReputationRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "reputationRewards", Type = "table", InnerType = "QuestReputationRewardInfo", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "QuestAcceptConfirm",
			Type = "Event",
			LiteralName = "QUEST_ACCEPT_CONFIRM",
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "questTitle", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "QuestFinished",
			Type = "Event",
			LiteralName = "QUEST_FINISHED",
		},
		{
			Name = "QuestGreeting",
			Type = "Event",
			LiteralName = "QUEST_GREETING",
		},
		{
			Name = "QuestItemUpdate",
			Type = "Event",
			LiteralName = "QUEST_ITEM_UPDATE",
		},
		{
			Name = "QuestProgress",
			Type = "Event",
			LiteralName = "QUEST_PROGRESS",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(QuestOffer);