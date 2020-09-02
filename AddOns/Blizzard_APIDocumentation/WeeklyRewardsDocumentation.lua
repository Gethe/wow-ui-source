local WeeklyRewards =
{
	Name = "WeeklyRewards",
	Type = "System",
	Namespace = "C_WeeklyRewards",

	Functions =
	{
		{
			Name = "CanClaimRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "canClaimRewards", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClaimReward",
			Type = "Function",

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CloseInteraction",
			Type = "Function",
		},
		{
			Name = "GetActivities",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "WeeklyRewardChestThresholdType", Nilable = true },
			},

			Returns =
			{
				{ Name = "activities", Type = "table", InnerType = "WeeklyRewardActivityInfo", Nilable = false },
			},
		},
		{
			Name = "GetConquestWeeklyProgress",
			Type = "Function",

			Returns =
			{
				{ Name = "weeklyProgress", Type = "ConquestWeeklyProgress", Nilable = false },
			},
		},
		{
			Name = "GetExampleRewardItemHyperlinks",
			Type = "Function",

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hyperlink", Type = "string", Nilable = false },
				{ Name = "upgradeHyperlink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetItemHyperlink",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemDBID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "hyperlink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "HasAvailableRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "hasAvailableRewards", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasGeneratedRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "hasGeneratedRewards", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "WeeklyRewardsHide",
			Type = "Event",
			LiteralName = "WEEKLY_REWARDS_HIDE",
		},
		{
			Name = "WeeklyRewardsItemChanged",
			Type = "Event",
			LiteralName = "WEEKLY_REWARDS_ITEM_CHANGED",
		},
		{
			Name = "WeeklyRewardsShow",
			Type = "Event",
			LiteralName = "WEEKLY_REWARDS_SHOW",
		},
		{
			Name = "WeeklyRewardsUpdate",
			Type = "Event",
			LiteralName = "WEEKLY_REWARDS_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "ConquestProgressBarDisplayType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "FirstChest", Type = "ConquestProgressBarDisplayType", EnumValue = 0 },
				{ Name = "AdditionalChest", Type = "ConquestProgressBarDisplayType", EnumValue = 1 },
				{ Name = "Seasonal", Type = "ConquestProgressBarDisplayType", EnumValue = 2 },
			},
		},
		{
			Name = "ConquestWeeklyProgress",
			Type = "Structure",
			Fields =
			{
				{ Name = "progress", Type = "number", Nilable = false },
				{ Name = "maxProgress", Type = "number", Nilable = false },
				{ Name = "displayType", Type = "ConquestProgressBarDisplayType", Nilable = false },
				{ Name = "unlocksCompleted", Type = "number", Nilable = false },
				{ Name = "maxUnlocks", Type = "number", Nilable = false },
				{ Name = "sampleItemHyperlink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "WeeklyRewardActivityInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "WeeklyRewardChestThresholdType", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "threshold", Type = "number", Nilable = false },
				{ Name = "progress", Type = "number", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "WeeklyRewardActivityRewardInfo", Nilable = false },
			},
		},
		{
			Name = "WeeklyRewardActivityRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "CachedRewardType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "itemDBID", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WeeklyRewards);