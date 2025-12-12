local QuestOffer =
{
	Name = "QuestOffer",
	Type = "System",
	Namespace = "C_QuestOffer",
	Environment = "All",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "QuestGreeting",
			Type = "Event",
			LiteralName = "QUEST_GREETING",
			SynchronousEvent = true,
		},
		{
			Name = "QuestItemUpdate",
			Type = "Event",
			LiteralName = "QUEST_ITEM_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "QuestProgress",
			Type = "Event",
			LiteralName = "QUEST_PROGRESS",
			SynchronousEvent = true,
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