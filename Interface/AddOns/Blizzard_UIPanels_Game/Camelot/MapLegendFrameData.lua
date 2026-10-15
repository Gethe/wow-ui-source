
QuestsCategoryData = { "RepeatableQuest", "LocalStoryQuest", "InProgressQuest", "TurnInQuest" };

ActivitiesCategoryData = { "Dungeon", "Raid" };

MovementCategoryData = { "FlightMaster"};

--Legend Data
--Add more categories here! Data Structure:
--  CategoryTitle = Global String Title to display
--  CategoryData = Legend Catagory Data table defined above
MapLegendData = {
	{CategoryTitle = MAP_LEGEND_CATEGORY_QUESTS,      CategoryData = QuestsCategoryData},
	{CategoryTitle = MAP_LEGEND_CATEGORY_ACTIVITIES,  CategoryData = ActivitiesCategoryData},
	{CategoryTitle = MAP_LEGEND_CATEGORY_MOVEMENT,    CategoryData = MovementCategoryData},
};
