local QuestRewards =
{
	Tables =
	{
		{
			Name = "QuestReputationRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
				{ Name = "rewardAmount", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestRewards);