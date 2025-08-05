local ChallengeModeInfo =
{
	Name = "ChallengeModeInfo",
	Type = "System",
	Namespace = "C_ChallengeMode",

	Functions =
	{
		{
			Name = "CanUseKeystoneInCurrentMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearKeystone",
			Type = "Function",
		},
		{
			Name = "CloseKeystoneFrame",
			Type = "Function",
		},
		{
			Name = "GetActiveChallengeMapID",
			Type = "Function",

			Returns =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetActiveKeystoneInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "activeKeystoneLevel", Type = "number", Nilable = false },
				{ Name = "activeAffixIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "wasActiveKeystoneCharged", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAffixInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "affixID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "filedataid", Type = "number", Nilable = false },
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
			Name = "GetDeathCount",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "numDeaths", Type = "number", Nilable = false },
				{ Name = "timeLost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDungeonScoreRarityColor",
			Type = "Function",
			Documentation = { "Returns a color value from the passed in overall season M+ rating." },

			Arguments =
			{
				{ Name = "dungeonScore", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "scoreColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
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
			Name = "GetKeystoneLevelRarityColor",
			Type = "Function",
			Documentation = { "Returns a color value from the passed in keystone level." },

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "levelScore", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "GetLeaverPenaltyWarningTimeLeft",
			Type = "Function",
			Documentation = { "Returns how much time is left before player is automatically flagged as a leaver (and removed from the group) for exiting a restricted challenge mode instance" },

			Returns =
			{
				{ Name = "timeLeftSeconds", Type = "number", Nilable = false, Default = 0 },
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
			Name = "GetOverallDungeonScore",
			Type = "Function",
			Documentation = { "Gets the overall season mythic+ rating for the player." },

			Returns =
			{
				{ Name = "overallDungeonScore", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPowerLevelDamageHealthMod",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "powerLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "damageMod", Type = "number", Nilable = false },
				{ Name = "healthMod", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSlottedKeystoneInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
				{ Name = "affixIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "keystoneLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpecificDungeonOverallScoreRarityColor",
			Type = "Function",
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
			Name = "GetSpecificDungeonScoreRarityColor",
			Type = "Function",
			Documentation = { "Returns a color value from the passed in mythic+ rating for a specific dungeon." },

			Arguments =
			{
				{ Name = "specificDungeonScore", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "specificDungeonScoreColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "GetStartTime",
			Type = "Function",

			Returns =
			{
				{ Name = "startTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasSlottedKeystone",
			Type = "Function",

			Returns =
			{
				{ Name = "hasSlottedKeystone", Type = "bool", Nilable = false },
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
			Name = "IsChallengeModeResettable",
			Type = "Function",

			Returns =
			{
				{ Name = "canReset", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveKeystone",
			Type = "Function",

			Returns =
			{
				{ Name = "removalSuccessful", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestLeaders",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "Reset",
			Type = "Function",
		},
		{
			Name = "SlotKeystone",
			Type = "Function",
		},
		{
			Name = "StartChallengeMode",
			Type = "Function",

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ChallengeModeCompleted",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_COMPLETED",
		},
		{
			Name = "ChallengeModeCompletedRewards",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_COMPLETED_REWARDS",
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
		},
		{
			Name = "ChallengeModeKeystoneReceptableOpen",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN",
		},
		{
			Name = "ChallengeModeKeystoneSlotted",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_KEYSTONE_SLOTTED",
			Payload =
			{
				{ Name = "keystoneID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeLeadersUpdate",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_LEADERS_UPDATE",
		},
		{
			Name = "ChallengeModeLeaverTimerEnded",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_LEAVER_TIMER_ENDED",
		},
		{
			Name = "ChallengeModeLeaverTimerStarted",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_LEAVER_TIMER_STARTED",
		},
		{
			Name = "ChallengeModeMapsUpdate",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_MAPS_UPDATE",
		},
		{
			Name = "ChallengeModeMemberInfoUpdated",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_MEMBER_INFO_UPDATED",
		},
		{
			Name = "ChallengeModeNewRecord",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_NEW_RECORD",
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
			Payload =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeStart",
			Type = "Event",
			LiteralName = "CHALLENGE_MODE_START",
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
};

APIDocumentation:AddDocumentationTable(ChallengeModeInfo);