local AchievementInfo =
{
	Name = "AchievementInfo",
	Type = "System",
	Namespace = "C_AchievementInfo",

	Functions =
	{
		{
			Name = "GetRewardItemID",
			Type = "Function",

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
			Name = "IsValidAchievement",
			Type = "Function",

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
			Payload =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AchievementSearchUpdated",
			Type = "Event",
			LiteralName = "ACHIEVEMENT_SEARCH_UPDATED",
		},
		{
			Name = "CriteriaComplete",
			Type = "Event",
			LiteralName = "CRITERIA_COMPLETE",
			Payload =
			{
				{ Name = "criteriaID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CriteriaEarned",
			Type = "Event",
			LiteralName = "CRITERIA_EARNED",
			Payload =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "CriteriaUpdate",
			Type = "Event",
			LiteralName = "CRITERIA_UPDATE",
		},
		{
			Name = "InspectAchievementReady",
			Type = "Event",
			LiteralName = "INSPECT_ACHIEVEMENT_READY",
			Payload =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "ReceivedAchievementList",
			Type = "Event",
			LiteralName = "RECEIVED_ACHIEVEMENT_LIST",
		},
		{
			Name = "ReceivedAchievementMemberList",
			Type = "Event",
			LiteralName = "RECEIVED_ACHIEVEMENT_MEMBER_LIST",
			Payload =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TrackedAchievementListChanged",
			Type = "Event",
			LiteralName = "TRACKED_ACHIEVEMENT_LIST_CHANGED",
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