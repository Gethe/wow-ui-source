local AchievementInfo =
{
	Name = "AchievementInfo",
	Type = "System",
	Namespace = "C_AchievementInfo",
	Environment = "All",

	Functions =
	{
		{
			Name = "AreGuildAchievementsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetRewardItemID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rewardItemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSupercedingAchievements",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "supercedingAchievements", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "IsGuildAchievement",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "achievementId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isGuild", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValidAchievement",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "achievementId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValidAchievement", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPortraitTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "textureObject", Type = "SimpleTexture", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AchievementEarned",
			Type = "Event",
			LiteralName = "ACHIEVEMENT_EARNED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
				{ Name = "alreadyEarned", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "AchievementPlayerName",
			Type = "Event",
			LiteralName = "ACHIEVEMENT_PLAYER_NAME",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AchievementSearchUpdated",
			Type = "Event",
			LiteralName = "ACHIEVEMENT_SEARCH_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "CriteriaComplete",
			Type = "Event",
			LiteralName = "CRITERIA_COMPLETE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "criteriaID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CriteriaEarned",
			Type = "Event",
			LiteralName = "CRITERIA_EARNED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "achievementAlreadyEarnedOnAccount", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CriteriaUpdate",
			Type = "Event",
			LiteralName = "CRITERIA_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "InspectAchievementReady",
			Type = "Event",
			LiteralName = "INSPECT_ACHIEVEMENT_READY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "ReceivedAchievementList",
			Type = "Event",
			LiteralName = "RECEIVED_ACHIEVEMENT_LIST",
			UniqueEvent = true,
		},
		{
			Name = "ReceivedAchievementMemberList",
			Type = "Event",
			LiteralName = "RECEIVED_ACHIEVEMENT_MEMBER_LIST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TrackedAchievementListChanged",
			Type = "Event",
			LiteralName = "TRACKED_ACHIEVEMENT_LIST_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "achievementID", Type = "number", Nilable = true },
				{ Name = "added", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "TrackedAchievementUpdate",
			Type = "Event",
			LiteralName = "TRACKED_ACHIEVEMENT_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
				{ Name = "criteriaID", Type = "number", Nilable = true },
				{ Name = "elapsed", Type = "time_t", Nilable = true },
				{ Name = "duration", Type = "number", Nilable = true },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(AchievementInfo);