local QuestConstants =
{
	Tables =
	{
		{
			Name = "QuestTagType",
			Type = "Enumeration",
			NumValues = 16,
			MinValue = 0,
			MaxValue = 15,
			Fields =
			{
				{ Name = "Tag", Type = "QuestTagType", EnumValue = 0 },
				{ Name = "Profession", Type = "QuestTagType", EnumValue = 1 },
				{ Name = "Normal", Type = "QuestTagType", EnumValue = 2 },
				{ Name = "PvP", Type = "QuestTagType", EnumValue = 3 },
				{ Name = "PetBattle", Type = "QuestTagType", EnumValue = 4 },
				{ Name = "Bounty", Type = "QuestTagType", EnumValue = 5 },
				{ Name = "Dungeon", Type = "QuestTagType", EnumValue = 6 },
				{ Name = "Invasion", Type = "QuestTagType", EnumValue = 7 },
				{ Name = "Raid", Type = "QuestTagType", EnumValue = 8 },
				{ Name = "Contribution", Type = "QuestTagType", EnumValue = 9 },
				{ Name = "RatedReward", Type = "QuestTagType", EnumValue = 10 },
				{ Name = "InvasionWrapper", Type = "QuestTagType", EnumValue = 11 },
				{ Name = "FactionAssault", Type = "QuestTagType", EnumValue = 12 },
				{ Name = "Islands", Type = "QuestTagType", EnumValue = 13 },
				{ Name = "Threat", Type = "QuestTagType", EnumValue = 14 },
				{ Name = "CovenantCalling", Type = "QuestTagType", EnumValue = 15 },
			},
		},
		{
			Name = "RelativeContentDifficulty",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Trivial", Type = "RelativeContentDifficulty", EnumValue = 0 },
				{ Name = "Easy", Type = "RelativeContentDifficulty", EnumValue = 1 },
				{ Name = "Fair", Type = "RelativeContentDifficulty", EnumValue = 2 },
				{ Name = "Difficult", Type = "RelativeContentDifficulty", EnumValue = 3 },
				{ Name = "Impossible", Type = "RelativeContentDifficulty", EnumValue = 4 },
			},
		},
		{
			Name = "QuestWatchConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "MAX_QUEST_WATCHES", Type = "number", Value = 25 },
				{ Name = "MAX_WORLD_QUEST_WATCHES_AUTOMATIC", Type = "number", Value = 1 },
				{ Name = "MAX_WORLD_QUEST_WATCHES_MANUAL", Type = "number", Value = 5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestConstants);