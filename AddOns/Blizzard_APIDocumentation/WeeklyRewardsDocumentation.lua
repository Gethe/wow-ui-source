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

			Returns =
			{
				{ Name = "activities", Type = "table", InnerType = "WeeklyRewardActivityInfo", Nilable = false },
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
	},

	Events =
	{
		{
			Name = "WeeklyRewardsHide",
			Type = "Event",
			LiteralName = "WEEKLY_REWARDS_HIDE",
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