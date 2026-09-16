function WorldMapTrackingOptionsButtonMixin:BuildGameSpecificFilterTable(addFilter)
	addFilter(SHOW_QUEST_LEVELS, "showQuestLevel", QUEST_LEVEL_FILTER_DESCRIPTION);
	addFilter(MAP_QUEST_DIFFICULTY_TEXT, "showQuestDifficultyColor", QUEST_DIFFICULTY_FILTER_DESCRIPTION);
end

function WorldMapTrackingOptionsButtonMixin:RefreshFilterCounter()
	-- No-op in Camelot.
end