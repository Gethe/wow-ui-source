local SocialQueue =
{
	Name = "SocialQueue",
	Type = "System",
	Namespace = "C_SocialQueue",

	Functions =
	{
		{
			Name = "GetAllGroups",
			Type = "Function",

			Arguments =
			{
				{ Name = "allowNonJoinable", Type = "bool", Nilable = false, Default = false },
				{ Name = "allowNonQueuedGroups", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "groupGUIDs", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "GetConfig",
			Type = "Function",

			Returns =
			{
				{ Name = "config", Type = "SocialQueueConfig", Nilable = false },
			},
		},
		{
			Name = "GetGroupForPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "groupGUID", Type = "string", Nilable = false },
				{ Name = "isSoloQueueParty", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetGroupInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "groupGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "canJoin", Type = "bool", Nilable = false },
				{ Name = "numQueues", Type = "number", Nilable = false },
				{ Name = "needTank", Type = "bool", Nilable = false },
				{ Name = "needHealer", Type = "bool", Nilable = false },
				{ Name = "needDamage", Type = "bool", Nilable = false },
				{ Name = "isSoloQueueParty", Type = "bool", Nilable = false },
				{ Name = "questSessionActive", Type = "bool", Nilable = false },
				{ Name = "leaderGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetGroupMembers",
			Type = "Function",

			Arguments =
			{
				{ Name = "groupGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "groupMembers", Type = "table", InnerType = "SocialQueuePlayerInfo", Nilable = false },
			},
		},
		{
			Name = "GetGroupQueues",
			Type = "Function",

			Arguments =
			{
				{ Name = "groupGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "queues", Type = "table", InnerType = "SocialQueueGroupQueueInfo", Nilable = false },
			},
		},
		{
			Name = "RequestToJoin",
			Type = "Function",

			Arguments =
			{
				{ Name = "groupGUID", Type = "string", Nilable = false },
				{ Name = "applyAsTank", Type = "bool", Nilable = false, Default = false },
				{ Name = "applyAsHealer", Type = "bool", Nilable = false, Default = false },
				{ Name = "applyAsDamage", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "requestSuccessful", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SignalToastDisplayed",
			Type = "Function",

			Arguments =
			{
				{ Name = "groupGUID", Type = "string", Nilable = false },
				{ Name = "priority", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SocialQueueConfigUpdated",
			Type = "Event",
			LiteralName = "SOCIAL_QUEUE_CONFIG_UPDATED",
		},
		{
			Name = "SocialQueueUpdate",
			Type = "Event",
			LiteralName = "SOCIAL_QUEUE_UPDATE",
			Payload =
			{
				{ Name = "groupGUID", Type = "string", Nilable = false },
				{ Name = "numAddedItems", Type = "number", Nilable = true },
			},
		},
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
				{ Name = "guid", Type = "string", Nilable = false },
				{ Name = "clubId", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SocialQueue);