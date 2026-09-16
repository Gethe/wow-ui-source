
QuestsCategoryData = { "CampaignQuest", "ImportantQuest", "LegendaryQuest", "MetaQuest", "RepeatableQuest", "LocalStoryQuest", "InProgressQuest", "TurnInQuest" };

LimitedCategoryData = { "WorldQuest", "WorldBoss", "BonusObjective", "LegendEvent", "RareCreature", "RareEliteCreature"};

ActivitiesCategoryData = { "Dungeon", "Raid", "Hub", "DigSite", "PetBattle", "Delve" };

MovementCategoryData = { "Teleport", "Cave", "FlightMaster"};

--Legend Data
--Add more categories here! Data Structure:
--  CategoryTitle = Global String Title to display
--  CategoryData = Legend Catagory Data table defined above
MapLegendData = {
	{CategoryTitle = MAP_LEGEND_CATEGORY_QUESTS,      CategoryData = QuestsCategoryData},
	{CategoryTitle = MAP_LEGEND_CATEGORY_LTA,         CategoryData = LimitedCategoryData},
	{CategoryTitle = MAP_LEGEND_CATEGORY_ACTIVITIES,  CategoryData = ActivitiesCategoryData},
	{CategoryTitle = MAP_LEGEND_CATEGORY_MOVEMENT,    CategoryData = MovementCategoryData},
};
