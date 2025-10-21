local AchievementTelemetry =
{
	Name = "AchievementTelemetry",
	Type = "System",
	Namespace = "C_AchievementTelemetry",

	Functions =
	{
		{
			Name = "LinkAchievementInClub",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LinkAchievementInWhisper",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShowAchievements",
			Type = "Function",
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(AchievementTelemetry);