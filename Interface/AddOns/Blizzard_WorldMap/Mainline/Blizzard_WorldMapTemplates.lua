function WorldMapTrackingOptionsButtonMixin:BuildGameSpecificFilterTable(addFilter)
	addFilter(SHOW_PET_BATTLES_ON_MAP_TEXT, "showTamers", PET_BATTLES_FILTER_DESCRIPTION);
	addFilter(SHOW_PET_BATTLES_ON_MAP_TEXT, "showTamersWQ");
	addFilter(WORLD_QUEST_REWARD_FILTERS_ANIMA, "worldQuestFilterAnima");
	addFilter(WORLD_QUEST_REWARD_FILTERS_RESOURCES, "worldQuestFilterResources");
	addFilter(WORLD_QUEST_REWARD_FILTERS_ARTIFACT_POWER, "worldQuestFilterArtifactPower");
	addFilter(WORLD_QUEST_REWARD_FILTERS_PROFESSION_MATERIALS, "worldQuestFilterProfessionMaterials");
	addFilter(WORLD_QUEST_REWARD_FILTERS_GOLD, "worldQuestFilterGold");
	addFilter(WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, "worldQuestFilterEquipment");
	addFilter(WORLD_QUEST_REWARD_FILTERS_REPUTATION, "worldQuestFilterReputation");
	addFilter(DRAGONRIDING_RACES_MAP_TOGGLE, "dragonRidingRacesFilter", SKYRIDING_RACES_FILTER_DESCRIPTION);
	addFilter(DRAGONRIDING_RACES_MAP_TOGGLE, "dragonRidingRacesFilterWQ");
	addFilter(DELVES_SHOW_ENTRACES_ON_MAP_TEXT, "showDelveEntrancesOnMap", DELVE_ENTRANCES_FILTER_DESCRIPTION);
	addFilter(ARCHAEOLOGY_SHOW_DIG_SITES, "digSites", SHOW_DIGSITES_FILTER_DESCRIPTION, Enum.MinimapTrackingFilter.Digsites);
	addFilter(SHOW_LOCAL_STORY_OFFERS_ON_MAP_TEXT, "questPOILocalStory", LOCAL_STORIES_FILTER_DESCRIPTION);
	addFilter(MINIMAP_TRACKING_ACCOUNT_COMPLETED_QUESTS, "showAccountCompletedQuests", ACCOUNT_COMPLETED_QUESTS_FILTER_DESCRIPTION, Enum.MinimapTrackingFilter.AccountCompletedQuests, true);
end
