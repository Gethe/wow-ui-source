local PlayerMentorship =
{
	Name = "PlayerMentorship",
	Type = "System",
	Namespace = "C_PlayerMentorship",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetMentorLevelRequirement",
			Type = "Function",

			Returns =
			{
				{ Name = "level", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMentorRequirements",
			Type = "Function",

			Returns =
			{
				{ Name = "achievementIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "optionalAchievementIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "optionalCompleteAtLeastCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMentorshipStatus",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "playerLocation", Type = "PlayerLocation", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "status", Type = "PlayerMentorshipStatus", Nilable = false },
			},
		},
		{
			Name = "IsActivePlayerConsideredNewcomer",
			Type = "Function",

			Returns =
			{
				{ Name = "isConsideredNewcomer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMentorRestricted",
			Type = "Function",

			Returns =
			{
				{ Name = "isRestricted", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "MentorshipStatusChanged",
			Type = "Event",
			LiteralName = "MENTORSHIP_STATUS_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "NewcomerGraduation",
			Type = "Event",
			LiteralName = "NEWCOMER_GRADUATION",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PlayerMentorship);