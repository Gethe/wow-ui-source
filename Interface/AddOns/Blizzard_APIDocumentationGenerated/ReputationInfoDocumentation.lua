local ReputationInfo =
{
	Name = "ReputationInfo",
	Type = "System",
	Namespace = "C_Reputation",

	Functions =
	{
		{
			Name = "GetFactionParagonInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "currentValue", Type = "number", Nilable = false },
				{ Name = "threshold", Type = "number", Nilable = false },
				{ Name = "rewardQuestID", Type = "number", Nilable = false },
				{ Name = "hasRewardPending", Type = "bool", Nilable = false },
				{ Name = "tooLowLevelForParagon", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFactionParagon",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasParagon", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestFactionParagonPreloadRewardData",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetWatchedFaction",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ReputationInfo);