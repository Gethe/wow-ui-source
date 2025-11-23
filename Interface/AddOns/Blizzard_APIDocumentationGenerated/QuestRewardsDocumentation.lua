local QuestRewards =
{
	Tables =
	{
		{
			Name = "QuestRewardCurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "texture", Type = "fileID", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "baseRewardAmount", Type = "number", Nilable = false },
				{ Name = "bonusRewardAmount", Type = "number", Nilable = false },
				{ Name = "totalRewardAmount", Type = "number", Nilable = false },
				{ Name = "questRewardContextFlags", Type = "QuestRewardContextFlags", Nilable = true },
			},
		},
		{
			Name = "QuestRewardReputationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
				{ Name = "rewardAmount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "QuestRewardSpellInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "texture", Type = "fileID", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "garrFollowerID", Type = "number", Nilable = true },
				{ Name = "isTradeskill", Type = "bool", Nilable = false },
				{ Name = "isSpellLearned", Type = "bool", Nilable = false },
				{ Name = "hideSpellLearnText", Type = "bool", Nilable = false },
				{ Name = "isBoostSpell", Type = "bool", Nilable = false },
				{ Name = "genericUnlock", Type = "bool", Nilable = false },
				{ Name = "type", Type = "QuestCompleteSpellType", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestRewards);