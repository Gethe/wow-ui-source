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
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
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

			Arguments =
			{
				{ Name = "affixID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "filedataid", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCompletionInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "time", Type = "number", Nilable = false },
				{ Name = "onTime", Type = "bool", Nilable = false },
				{ Name = "keystoneUpgradeLevels", Type = "number", Nilable = false },
				{ Name = "practiceRun", Type = "bool", Nilable = false },
				{ Name = "oldOverallDungeonScore", Type = "number", Nilable = false },
				{ Name = "newOverallDungeonScore", Type = "number", Nilable = false },
				{ Name = "IsMapRecord", Type = "bool", Nilable = false },
				{ Name = "IsAffixRecord", Type = "bool", Nilable = false },
				{ Name = "PrimaryAffix", Type = "number", Nilable = false },
				{ Name = "members", Type = "table", InnerType = "ChallengeModeCompletionMemberInfo", Nilable = false },
			},
		},
		{
			Name = "GetDeathCount",
			Type = "Function",

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
				{ Name = "scoreColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "GetGuildLeaders",
			Type = "Function",

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
				{ Name = "levelScore", Type = "table", Mixin = "ColorMixin", Nilable = false },
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

			Arguments =
			{
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "timeLimit", Type = "number", Nilable = false },
				{ Name = "texture", Type = "number", Nilable = true },
				{ Name = "backgroundTexture", Type = "number", Nilable = false },
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
				{ Name = "specificDungeonOverallScoreColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
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
				{ Name = "specificDungeonScoreColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
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
			Name = "SetKeystoneTooltip",
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
			Name = "ChallengeModeCompletionMemberInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "memberGUID", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeGuildAttemptMember",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "classFileName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ChallengeModeGuildTopAttempt",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "classFileName", Type = "string", Nilable = false },
				{ Name = "keystoneLevel", Type = "number", Nilable = false },
				{ Name = "mapChallengeModeID", Type = "number", Nilable = false },
				{ Name = "isYou", Type = "bool", Nilable = false },
				{ Name = "members", Type = "table", InnerType = "ChallengeModeGuildAttemptMember", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ChallengeModeInfo);