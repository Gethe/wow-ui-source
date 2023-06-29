local SocialQueue =
{
	Name = "SocialQueue",
	Type = "System",
	Namespace = "C_SocialQueue",

	Functions =
	{
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "SocialQueueConfig",
			Type = "Structure",
			Fields =
			{
				{ Name = "TOASTS_DISABLED", Type = "bool", Nilable = false },
				{ Name = "TOAST_DURATION", Type = "number", Nilable = false },
				{ Name = "DELAY_DURATION", Type = "number", Nilable = false },
				{ Name = "QUEUE_MULTIPLIER", Type = "number", Nilable = false },
				{ Name = "PLAYER_MULTIPLIER", Type = "number", Nilable = false },
				{ Name = "PLAYER_FRIEND_VALUE", Type = "number", Nilable = false },
				{ Name = "PLAYER_GUILD_VALUE", Type = "number", Nilable = false },
				{ Name = "THROTTLE_INITIAL_THRESHOLD", Type = "number", Nilable = false },
				{ Name = "THROTTLE_DECAY_TIME", Type = "number", Nilable = false },
				{ Name = "THROTTLE_PRIORITY_SPIKE", Type = "number", Nilable = false },
				{ Name = "THROTTLE_MIN_THRESHOLD", Type = "number", Nilable = false },
				{ Name = "THROTTLE_PVP_PRIORITY_NORMAL", Type = "number", Nilable = false },
				{ Name = "THROTTLE_PVP_PRIORITY_LOW", Type = "number", Nilable = false },
				{ Name = "THROTTLE_PVP_HONOR_THRESHOLD", Type = "number", Nilable = false },
				{ Name = "THROTTLE_LFGLIST_PRIORITY_DEFAULT", Type = "number", Nilable = false },
				{ Name = "THROTTLE_LFGLIST_PRIORITY_ABOVE", Type = "number", Nilable = false },
				{ Name = "THROTTLE_LFGLIST_PRIORITY_BELOW", Type = "number", Nilable = false },
				{ Name = "THROTTLE_LFGLIST_ILVL_SCALING_ABOVE", Type = "number", Nilable = false },
				{ Name = "THROTTLE_LFGLIST_ILVL_SCALING_BELOW", Type = "number", Nilable = false },
				{ Name = "THROTTLE_RF_PRIORITY_ABOVE", Type = "number", Nilable = false },
				{ Name = "THROTTLE_RF_ILVL_SCALING_ABOVE", Type = "number", Nilable = false },
				{ Name = "THROTTLE_DF_MAX_ITEM_LEVEL", Type = "number", Nilable = false },
				{ Name = "THROTTLE_DF_BEST_PRIORITY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SocialQueueGroupInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "canJoin", Type = "bool", Nilable = false },
				{ Name = "numQueues", Type = "number", Nilable = false },
				{ Name = "needTank", Type = "bool", Nilable = false },
				{ Name = "needHealer", Type = "bool", Nilable = false },
				{ Name = "needDamage", Type = "bool", Nilable = false },
				{ Name = "isSoloQueueParty", Type = "bool", Nilable = false },
				{ Name = "leaderGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "SocialQueueGroupQueueInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "clientID", Type = "number", Nilable = false },
				{ Name = "eligible", Type = "bool", Nilable = false },
				{ Name = "needTank", Type = "bool", Nilable = false },
				{ Name = "needHealer", Type = "bool", Nilable = false },
				{ Name = "needDamage", Type = "bool", Nilable = false },
				{ Name = "isAutoAccept", Type = "bool", Nilable = false },
				{ Name = "queueData", Type = "QueueSpecificInfo", Nilable = false },
			},
		},
		{
			Name = "SocialQueuePlayerInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "clubId", Type = "ClubId", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SocialQueue);