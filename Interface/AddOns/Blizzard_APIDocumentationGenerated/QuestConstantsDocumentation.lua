local QuestConstants =
{
	Tables =
	{
		{
			Name = "CombinedQuestLogStatus",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Available", Type = "CombinedQuestLogStatus", EnumValue = 0 },
				{ Name = "Complete", Type = "CombinedQuestLogStatus", EnumValue = 1 },
				{ Name = "CompleteDaily", Type = "CombinedQuestLogStatus", EnumValue = 2 },
				{ Name = "CompleteWeekly", Type = "CombinedQuestLogStatus", EnumValue = 3 },
				{ Name = "CompleteMonthly", Type = "CombinedQuestLogStatus", EnumValue = 4 },
				{ Name = "CompleteYearly", Type = "CombinedQuestLogStatus", EnumValue = 5 },
				{ Name = "CompleteGameReset", Type = "CombinedQuestLogStatus", EnumValue = 6 },
				{ Name = "Reset", Type = "CombinedQuestLogStatus", EnumValue = 7 },
			},
		},
		{
			Name = "CombinedQuestStatus",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Invalid", Type = "CombinedQuestStatus", EnumValue = 0 },
				{ Name = "Completed", Type = "CombinedQuestStatus", EnumValue = 1 },
				{ Name = "NotCompleted", Type = "CombinedQuestStatus", EnumValue = 2 },
			},
		},
		{
			Name = "QuestCompleteSpellType",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 0,
			MaxValue = 11,
			Fields =
			{
				{ Name = "LegacyBehavior", Type = "QuestCompleteSpellType", EnumValue = 0 },
				{ Name = "Follower", Type = "QuestCompleteSpellType", EnumValue = 1 },
				{ Name = "Tradeskill", Type = "QuestCompleteSpellType", EnumValue = 2 },
				{ Name = "Ability", Type = "QuestCompleteSpellType", EnumValue = 3 },
				{ Name = "Aura", Type = "QuestCompleteSpellType", EnumValue = 4 },
				{ Name = "Spell", Type = "QuestCompleteSpellType", EnumValue = 5 },
				{ Name = "Unlock", Type = "QuestCompleteSpellType", EnumValue = 6 },
				{ Name = "Companion", Type = "QuestCompleteSpellType", EnumValue = 7 },
				{ Name = "QuestlineUnlock", Type = "QuestCompleteSpellType", EnumValue = 8 },
				{ Name = "QuestlineReward", Type = "QuestCompleteSpellType", EnumValue = 9 },
				{ Name = "QuestlineUnlockPart", Type = "QuestCompleteSpellType", EnumValue = 10 },
				{ Name = "PossibleReward", Type = "QuestCompleteSpellType", EnumValue = 11 },
			},
		},
		{
			Name = "QuestRepeatability",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "QuestRepeatability", EnumValue = 0 },
				{ Name = "Daily", Type = "QuestRepeatability", EnumValue = 1 },
				{ Name = "Weekly", Type = "QuestRepeatability", EnumValue = 2 },
				{ Name = "Turnin", Type = "QuestRepeatability", EnumValue = 3 },
				{ Name = "World", Type = "QuestRepeatability", EnumValue = 4 },
			},
		},
		{
			Name = "QuestRewardContextFlags",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "QuestRewardContextFlags", EnumValue = 0 },
				{ Name = "FirstCompletionBonus", Type = "QuestRewardContextFlags", EnumValue = 1 },
				{ Name = "RepeatCompletionBonus", Type = "QuestRewardContextFlags", EnumValue = 2 },
			},
		},
		{
			Name = "QuestTagType",
			Type = "Enumeration",
			NumValues = 20,
			MinValue = 0,
			MaxValue = 19,
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
				{ Name = "DragonRiderRacing", Type = "QuestTagType", EnumValue = 16 },
				{ Name = "Capstone", Type = "QuestTagType", EnumValue = 17 },
				{ Name = "WorldBoss", Type = "QuestTagType", EnumValue = 18 },
				{ Name = "Placeholder_1", Type = "QuestTagType", EnumValue = 19 },
			},
		},
		{
			Name = "QuestTreasurePickerType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Visible", Type = "QuestTreasurePickerType", EnumValue = 0 },
				{ Name = "Hidden", Type = "QuestTreasurePickerType", EnumValue = 1 },
				{ Name = "Select", Type = "QuestTreasurePickerType", EnumValue = 2 },
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