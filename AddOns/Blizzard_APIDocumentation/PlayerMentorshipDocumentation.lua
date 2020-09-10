local PlayerMentorship =
{
	Name = "PlayerMentorship",
	Type = "System",
	Namespace = "C_PlayerMentorship",

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
			Name = "GetMentorOptionalAchievementIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "achievementIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetMentorshipStatus",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "status", Type = "PlayerMentorshipStatus", Nilable = false },
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
			Name = "NewcomerGraduation",
			Type = "Event",
			LiteralName = "NEWCOMER_GRADUATION",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PlayerMentorship);