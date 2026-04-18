local ChallengeModeInfo =
{
	Name = "ChallengeModeInfo",
	Type = "System",
	Namespace = "C_ChallengeMode",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetActiveChallengeMapID",
			Type = "Function",

			Returns =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetChallengeBestTime",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "guildBestTime", Type = "number", Nilable = true },
				{ Name = "realmBestTime", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetChallengeCompletionInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "ChallengeCompletionInfo", Nilable = false },
			},
		},
		{
			Name = "GetChallengeGuildBestTimeInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "guildBestTime", Type = "ChallengeModeBestTime", Nilable = false },
			},
		},
		{
			Name = "GetChallengeMapRewardInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "medal", Type = "number", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "iconID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "isCurrency", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetChallengeModeMapTimes",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mapTimes", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetChallengeRealmBestTimeInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "guildBestTime", Type = "ChallengeModeBestTime", Nilable = false },
			},
		},
		{
			Name = "GetGuildLeaders",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "topAttempt", Type = "table", InnerType = "ChallengeModeGuildTopAttempt", Nilable = false },
			},
		},
		{
			Name = "GetMapScoreInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "displayScores", Type = "table", InnerType = "MythicPlusRatingLinkInfo", Nilable = false },
			},
		},
		{
			Name = "GetMapTable",
			Type = "Function",

			Returns =
			{
				{ Name = "mapChallengeModeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetMapUIInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "timeLimit", Type = "number", Nilable = false },
				{ Name = "texture", Type = "number", Nilable = true },
				{ Name = "backgroundTexture", Type = "number", Nilable = false },
				{ Name = "mapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumChallengeMapRewards",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "medal", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "numRewards", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumMedals",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "numMedals", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpecificDungeonOverallScoreRarityColor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns a color value from the passed in mythic+ rating from the combined affix scores for a specific dungeon" },

			Arguments =
			{
				{ Name = "specificDungeonOverallScore", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "specificDungeonOverallScoreColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "IsChallengeModeActive",
			Type = "Function",

			Returns =
			{
				{ Name = "challengeModeActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsChallengeModeEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsChallengeModeResettable",
			Type = "Function",

			Returns =
			{
				{ Name = "canReset", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestChallengeModeLeaderboard",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Request a page of challenge mode leaderboards that will be returned in a 'CHALLENGE_MODE_LEADERBOARD_RESULT' event" },

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "challengeModeID", Type = "number", Nilable = false },
				{ Name = "page", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RequestLeaders",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "Reset",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "ChallengeModeCompleted",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_COMPLETED",
			SynchronousEvent = true,
		},
		{
			Name = "ChallengeModeCompletedRewards",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_COMPLETED_REWARDS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "medal", Type = "number", Nilable = false },
				{ Name = "timeMS", Type = "number", Nilable = false },
				{ Name = "money", Type = "number", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "ChallengeModeReward", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeDeathCountUpdated",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_DEATH_COUNT_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "ChallengeModeKeystoneReceptableOpen",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN",
			SynchronousEvent = true,
		},
		{
			Name = "ChallengeModeKeystoneSlotted",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_KEYSTONE_SLOTTED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "keystoneID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeLeaderboardResult",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_LEADERBOARD_RESULT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "challengeModeID", Type = "number", Nilable = false },
				{ Name = "page", Type = "number", Nilable = false },
				{ Name = "results", Type = "table", InnerType = "MythicPlusLeaderboardResult", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeLeadersUpdate",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_LEADERS_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "ChallengeModeLeaverTimerEnded",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_LEAVER_TIMER_ENDED",
			SynchronousEvent = true,
		},
		{
			Name = "ChallengeModeLeaverTimerStarted",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_LEAVER_TIMER_STARTED",
			SynchronousEvent = true,
		},
		{
			Name = "ChallengeModeMapsUpdate",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_MAPS_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "ChallengeModeMemberInfoUpdated",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_MEMBER_INFO_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "ChallengeModeNewRecord",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_NEW_RECORD",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "timeMS", Type = "number", Nilable = false },
				{ Name = "medal", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeReset",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_RESET",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeStart",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_START",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "ChallengeCompletionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "level", Type = "number", Nilable = false, Default = 0 },
				{ Name = "time", Type = "number", Nilable = false, Default = 0 },
				{ Name = "onTime", Type = "bool", Nilable = false, Default = false },
				{ Name = "keystoneUpgradeLevels", Type = "number", Nilable = false, Default = 0 },
				{ Name = "practiceRun", Type = "bool", Nilable = false, Default = false },
				{ Name = "oldOverallDungeonScore", Type = "number", Nilable = true },
				{ Name = "newOverallDungeonScore", Type = "number", Nilable = true },
				{ Name = "isMapRecord", Type = "bool", Nilable = false, Default = false },
				{ Name = "isAffixRecord", Type = "bool", Nilable = false, Default = false },
				{ Name = "isEligibleForScore", Type = "bool", Nilable = false, Default = false },
				{ Name = "members", Type = "table", InnerType = "ChallengeModeCompletionMemberInfo", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeBestTime",
			Type = "Structure",
			Fields =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
				{ Name = "durationMs", Type = "number", Nilable = false },
				{ Name = "members", Type = "table", InnerType = "ChallengeModeBestTimeMember", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeBestTimeMember",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "classFileName", Type = "cstring", Nilable = false },
				{ Name = "className", Type = "cstring", Nilable = false },
				{ Name = "specializationID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeCompletionMemberInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "memberGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeGuildAttemptMember",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "classFileName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeGuildTopAttempt",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "classFileName", Type = "cstring", Nilable = false },
				{ Name = "keystoneLevel", Type = "number", Nilable = false },
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
				{ Name = "isYou", Type = "bool", Nilable = false },
				{ Name = "members", Type = "table", InnerType = "ChallengeModeGuildAttemptMember", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeReward",
			Type = "Structure",
			Fields =
			{
				{ Name = "rewardID", Type = "number", Nilable = false },
				{ Name = "displayInfoID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "isCurrency", Type = "bool", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(ChallengeModeInfo);