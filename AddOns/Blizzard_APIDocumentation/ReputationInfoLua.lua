local ReputationInfoLua =
{
	Name = "ReputationInfo",
	Namespace = "C_Reputation",

	Functions =
	{
		{
			Name = "GetFactionParagonInfo",

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
			},
		},
		{
			Name = "IsFactionParagon",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasParagon", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ReputationInfoLua);