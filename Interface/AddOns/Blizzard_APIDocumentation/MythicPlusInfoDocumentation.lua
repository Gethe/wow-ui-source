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
				{ Name = "affixIDs", Type = "table", InnerType = "MythicPlusKeystoneAffix", Nilable = false },
			},
		},
		{
			Name = "GetCurrentSeason",
			Type = "Function",

			Returns =
			{
				{ Name = "seasonID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrentSeasonValues",
			Type = "Function",

			Returns =
			{
				{ Name = "displaySeasonID", Type = "number", Nilable = false },
				{ Name = "milestoneSeasonID", Type = "number", Nilable = false },
				{ Name = "rewardSeasonID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLastWeeklyBestInformation",
			Type = "Function",

			Returns =
			{
				{ Name = "challengeMapId", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOwnedKeystoneChallengeMapID",
			Type = "Function",

			Returns =
			{
				{ Name = "challengeMapID", Type = "number", Nilable = false },
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
			Name = "GetRewardLevelFromKeystoneLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "keystoneLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rewardLevel", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetRunHistory",
			Type = "Function",

			Arguments =
			{
				{ Name = "includePreviousWeeks", Type = "bool", Nilable = false, Default = false },
				{ Name = "includeIncompleteRuns", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "runs", Type = "table", InnerType = "MythicPlusRunInfo", Nilable = false },
			},
		},
		{
			Name = "GetSeasonBestAffixScoreInfoForMap",
			Type = "Function",
			Documentation = { "Gets the active players best runs by the seasonal tracked affixes as well as their overall score for the current season." },

			Arguments =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "affixScores", Type = "table", InnerType = "MythicPlusAffixScoreInfo", Nilable = false },
				{ Name = "bestOverAllScore", Type = "number", Nilable = false },
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
				{ Name = "intimeInfo", Type = "MapSeasonBestInfo", Nilable = true },
				{ Name = "overtimeInfo", Type = "MapSeasonBestInfo", Nilable = true },
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
				{ Name = "dungeonScore", Type = "number", Nilable = false },
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
				{ Name = "nextBestLevel", Type = "number", Nilable = false },
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
			Name = "MapSeasonBestInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "durationSec", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "completionDate", Type = "MythicPlusDate", Nilable = false },
				{ Name = "affixIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "members", Type = "table", InnerType = "MythicPlusMember", Nilable = false },
				{ Name = "dungeonScore", Type = "number", Nilable = false },
			},
		},
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
			Name = "MythicPlusKeystoneAffix",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "seasonID", Type = "number", Nilable = false },
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
		{
			Name = "MythicPlusRunInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "thisWeek", Type = "bool", Nilable = false },
				{ Name = "completed", Type = "bool", Nilable = false },
				{ Name = "runScore", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MythicPlusInfo);