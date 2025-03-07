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
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "reputationRewards", Type = "table", InnerType = "QuestRewardReputationInfo", Nilable = false },
			},
		},
		{
			Name = "GetQuestRequiredCurrencyInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "questRewardIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "questRequiredCurrencyInfo", Type = "QuestRequiredCurrencyInfo", Nilable = true },
			},
		},
		{
			Name = "GetQuestRewardCurrencyInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "questInfoType", Type = "cstring", Nilable = false },
				{ Name = "questRewardIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "questRewardCurrencyInfo", Type = "QuestRewardCurrencyInfo", Nilable = true },
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
		{
			Name = "QuestRequiredCurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "texture", Type = "fileID", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "requiredAmount", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestOffer);