local UIEventToastConstants =
{
	Tables =
	{
		{
			Name = "EventToastDisplayType",
			Type = "Enumeration",
			NumValues = 16,
			MinValue = 0,
			MaxValue = 15,
			Fields =
			{
				{ Name = "NormalSingleLine", Type = "EventToastDisplayType", EnumValue = 0 },
				{ Name = "NormalBlockText", Type = "EventToastDisplayType", EnumValue = 1 },
				{ Name = "NormalTitleAndSubTitle", Type = "EventToastDisplayType", EnumValue = 2 },
				{ Name = "NormalTextWithIcon", Type = "EventToastDisplayType", EnumValue = 3 },
				{ Name = "LargeTextWithIcon", Type = "EventToastDisplayType", EnumValue = 4 },
				{ Name = "NormalTextWithIconAndRarity", Type = "EventToastDisplayType", EnumValue = 5 },
				{ Name = "Scenario", Type = "EventToastDisplayType", EnumValue = 6 },
				{ Name = "ChallengeMode", Type = "EventToastDisplayType", EnumValue = 7 },
				{ Name = "ScenarioClickExpand", Type = "EventToastDisplayType", EnumValue = 8 },
				{ Name = "WeeklyRewardUnlock", Type = "EventToastDisplayType", EnumValue = 9 },
				{ Name = "WeeklyRewardUpgrade", Type = "EventToastDisplayType", EnumValue = 10 },
				{ Name = "FlightpointDiscovered", Type = "EventToastDisplayType", EnumValue = 11 },
				{ Name = "CapstoneUnlocked", Type = "EventToastDisplayType", EnumValue = 12 },
				{ Name = "SingleLineWithIcon", Type = "EventToastDisplayType", EnumValue = 13 },
				{ Name = "Scoreboard", Type = "EventToastDisplayType", EnumValue = 14 },
				{ Name = "HouseUpgradeAvailable", Type = "EventToastDisplayType", EnumValue = 15 },
			},
		},
		{
			Name = "EventToastEventType",
			Type = "Enumeration",
			NumValues = 27,
			MinValue = 0,
			MaxValue = 26,
			Fields =
			{
				{ Name = "LevelUp", Type = "EventToastEventType", EnumValue = 0 },
				{ Name = "LevelUpSpell", Type = "EventToastEventType", EnumValue = 1 },
				{ Name = "LevelUpDungeon", Type = "EventToastEventType", EnumValue = 2 },
				{ Name = "LevelUpRaid", Type = "EventToastEventType", EnumValue = 3 },
				{ Name = "LevelUpPvP", Type = "EventToastEventType", EnumValue = 4 },
				{ Name = "PetBattleNewAbility", Type = "EventToastEventType", EnumValue = 5 },
				{ Name = "PetBattleFinalRound", Type = "EventToastEventType", EnumValue = 6 },
				{ Name = "PetBattleCapture", Type = "EventToastEventType", EnumValue = 7 },
				{ Name = "BattlePetLevelChanged", Type = "EventToastEventType", EnumValue = 8 },
				{ Name = "BattlePetLevelUpAbility", Type = "EventToastEventType", EnumValue = 9 },
				{ Name = "QuestBossEmote", Type = "EventToastEventType", EnumValue = 10 },
				{ Name = "MythicPlusWeeklyRecord", Type = "EventToastEventType", EnumValue = 11 },
				{ Name = "QuestTurnedIn", Type = "EventToastEventType", EnumValue = 12 },
				{ Name = "WorldStateChange", Type = "EventToastEventType", EnumValue = 13 },
				{ Name = "Scenario", Type = "EventToastEventType", EnumValue = 14 },
				{ Name = "LevelUpOther", Type = "EventToastEventType", EnumValue = 15 },
				{ Name = "PlayerAuraAdded", Type = "EventToastEventType", EnumValue = 16 },
				{ Name = "PlayerAuraRemoved", Type = "EventToastEventType", EnumValue = 17 },
				{ Name = "SpellScript", Type = "EventToastEventType", EnumValue = 18 },
				{ Name = "CriteriaUpdated", Type = "EventToastEventType", EnumValue = 19 },
				{ Name = "PvPTierUpdate", Type = "EventToastEventType", EnumValue = 20 },
				{ Name = "SpellLearned", Type = "EventToastEventType", EnumValue = 21 },
				{ Name = "TreasureItem", Type = "EventToastEventType", EnumValue = 22 },
				{ Name = "WeeklyRewardUnlock", Type = "EventToastEventType", EnumValue = 23 },
				{ Name = "WeeklyRewardUpgrade", Type = "EventToastEventType", EnumValue = 24 },
				{ Name = "FlightpointDiscovered", Type = "EventToastEventType", EnumValue = 25 },
				{ Name = "HouseUpgradeAvailable", Type = "EventToastEventType", EnumValue = 26 },
			},
		},
		{
			Name = "EventToastFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "DisableRightClickDismiss", Type = "EventToastFlags", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIEventToastConstants);