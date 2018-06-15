local MythicPlusInfo =
{
	Name = "MythicPlusInfo",
	Type = "System",
	Namespace = "C_MythicPlus",

	Functions =
	{
		{
			Name = "GetCurrentAffixes",
			Type = "Function",

			Returns =
			{
				{ Name = "affixIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetOwnedKeystoneLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "keyStoneLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRewardLevelForDifficultyLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "difficultyLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "weeklyRewardLevel", Type = "number", Nilable = false },
				{ Name = "endOfRunRewardLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSeasonBestForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "durationSec", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "completionDate", Type = "MythicPlusDate", Nilable = false },
				{ Name = "affixIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "members", Type = "table", InnerType = "MythicPlusMember", Nilable = false },
			},
		},
		{
			Name = "GetWeeklyBestForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "durationSec", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "completionDate", Type = "MythicPlusDate", Nilable = false },
				{ Name = "affixIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "members", Type = "table", InnerType = "MythicPlusMember", Nilable = false },
			},
		},
		{
			Name = "GetWeeklyChestRewardLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "currentWeekBestLevel", Type = "number", Nilable = false },
				{ Name = "weeklyRewardLevel", Type = "number", Nilable = false },
				{ Name = "nextDifficultyWeeklyRewardLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsMythicPlusActive",
			Type = "Function",

			Returns =
			{
				{ Name = "isMythicPlusActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsWeeklyRewardAvailable",
			Type = "Function",

			Returns =
			{
				{ Name = "weeklyRewardAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestCurrentAffixes",
			Type = "Function",
		},
		{
			Name = "RequestMapInfo",
			Type = "Function",
		},
		{
			Name = "RequestRewards",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "MythicPlusCurrentAffixUpdate",
			Type = "Event",
			LiteralName = "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE",
		},
		{
			Name = "MythicPlusNewSeasonRecord",
			Type = "Event",
			LiteralName = "MYTHIC_PLUS_NEW_SEASON_RECORD",
			Payload =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
				{ Name = "completionMilliseconds", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MythicPlusNewWeeklyRecord",
			Type = "Event",
			LiteralName = "MYTHIC_PLUS_NEW_WEEKLY_RECORD",
			Payload =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
				{ Name = "completionMilliseconds", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "MythicPlusDate",
			Type = "Structure",
			Fields =
			{
				{ Name = "year", Type = "number", Nilable = false },
				{ Name = "month", Type = "number", Nilable = false },
				{ Name = "day", Type = "number", Nilable = false },
				{ Name = "hour", Type = "number", Nilable = false },
				{ Name = "minute", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MythicPlusMember",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MythicPlusInfo);