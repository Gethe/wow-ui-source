--Legend Category data
--Add more pin types here! Data Structure:
--  Atlas - Atlas name to use for icon
--  Name - Global String for Icon Label
--  Tooltip - Global String for Icon Tooltip
--  TemplateNames - Table of asscotiated Map Pin Template names
--      Note: when adding a new template for the legend, be sure the template inherits LegendHighlightableMapPoiPinTemplate and also calls LegendHighlightablePoiPinMixin:OnLegendPinMouseEnter/Leave
--  MetaData - Table of needed meta data to differentiate between different pins with the same template. If no meta data exists, all pins with the given template names will highlight
--      Note: when adding new meta data types, be sure to update MapLegendButtonMixin:MetaDataMatches to check the new data comparison
--  BackgroundAtlas - Optional Atlas name for background to icon
MapLegendPinDefinitions = {
	CampaignQuest =		{Atlas = "Quest-Campaign-Available", fixedWidth = 24, fixedHeight = 24, Name = MAP_LEGEND_CAMPAIGN,   Tooltip = MAP_LEGEND_CAMPAIGN_TOOLTIP,    TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"},  MetaData = {questClassification = Enum.QuestClassification.Campaign }},
	ImportantQuest =	{Atlas = "UI-QuestPoiImportant-QuestBang", fixedWidth = 28, fixedHeight = 32,  Name = MAP_LEGEND_IMPORTANT,  Tooltip = MAP_LEGEND_IMPORTANT_TOOLTIP,   TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"},  MetaData = {questClassification = Enum.QuestClassification.Important}},
	LegendaryQuest =	{Atlas = "UI-QuestPoiLegendary-QuestBang",  Name = MAP_LEGEND_LEGENDARY,  Tooltip = MAP_LEGEND_LEGENDARY_TOOLTIP,   TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"}, MetaData = {questClassification = Enum.QuestClassification.Legendary}},
	MetaQuest =			{Atlas = "UI-QuestPoiWrapper-QuestBang",    Name = MAP_LEGEND_META,       Tooltip = MAP_LEGEND_META_TOOLTIP,        TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"}, MetaData = {questClassification = Enum.QuestClassification.Meta}},
	RepeatableQuest =	{Atlas = "UI-QuestPoiRecurring-QuestBang",    Name = MAP_LEGEND_REPEATABLE, Tooltip = MAP_LEGEND_REPEATABLE_TOOLTIP,        TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"}, MetaData = {questClassification = Enum.QuestClassification.Recurring}},
	LocalStoryQuest =	{Atlas = "QuestNormal", fixedWidth = 28, fixedHeight = 28, Name = MAP_LEGEND_LOCALSTORY, Tooltip = MAP_LEGEND_LOCALSTORY_TOOLTIP,  TemplateNames = {"QuestPinTemplate","QuestOfferPinTemplate"}, MetaData = {questClassification = Enum.QuestClassification.Normal}},
	InProgressQuest =	{Atlas = "Quest-In-Progress-Icon-yellow",   Name = MAP_LEGEND_INPROGRESS, Tooltip = MAP_LEGEND_INPROGRESS_TOOLTIP,  TemplateNames = {"QuestPinTemplate"},                         MetaData = {Style = POIButtonUtil.Style.QuestInProgress},     BackgroundAtlas = "UI-QuestPoi-QuestNumber"},
	TurnInQuest =		{Atlas = "UI-QuestPoi-QuestBangTurnIn",     Name = MAP_LEGEND_TURNIN,     Tooltip = MAP_LEGEND_TURNIN_TOOLTIP,      TemplateNames = {"QuestPinTemplate"},                         MetaData = {Style = POIButtonUtil.Style.QuestComplete},       BackgroundAtlas = "UI-QuestPoi-QuestNumber"},
	WorldQuest =		{Atlas = "worldquest-icon",               Name = MAP_LEGEND_WORLDQUEST,     Tooltip = MAP_LEGEND_WORLDQUEST_TOOLTIP,      TemplateNames = {"WorldQuestPinTemplate", "WorldMap_WorldQuestPinTemplate"},  BackgroundAtlas = "UI-QuestPoi-QuestNumber"},
	WorldBoss =			{Atlas = "vignettekillboss",              Name = MAP_LEGEND_WORLDBOSS,      Tooltip = MAP_LEGEND_WORLDBOSS_TOOLTIP,       TemplateNames = {"WorldQuestPinTemplate", "WorldMap_WorldQuestPinTemplate"},  MetaData = {worldQuestType = Enum.QuestTagType.WorldBoss}},
	BonusObjective =	{Atlas = "Bonus-Objective-Star",           Name = MAP_LEGEND_BONUSOBJECTIVE, Tooltip = MAP_LEGEND_BONUSOBJECTIVE_TOOLTIP,  TemplateNames = {"BonusObjectivePinTemplate"}, BackgroundAtlas = "UI-QuestPoi-QuestNumber"},
	LegendEvent =		{Atlas = "minimap-genericevent-hornicon", fixedWidth = 32, fixedHeight = 32, Name = MAP_LEGEND_EVENT,          Tooltip = MAP_LEGEND_EVENT_TOOLTIP,           TemplateNames = {"AreaPOIEventPinTemplate"}, MetaData = {AtlasPrefix="UI-EventPoi"}},
	RareCreature =		{Atlas = "VignetteKill",                  Name = MAP_LEGEND_RARE,           Tooltip = MAP_LEGEND_RARE_TOOLTIP,            TemplateNames = {"VignettePinPOIButtonTemplate"}, MetaData = {Atlas="VignetteKill"}},
	RareEliteCreature = {Atlas = "VignetteKillElite",             Name = MAP_LEGEND_RAREELITE,      Tooltip = MAP_LEGEND_RAREELITE_TOOLTIP,       TemplateNames = {"VignettePinPOIButtonTemplate"}, MetaData = {Atlas="VignetteKillElite"}},
	Dungeon =			{Atlas = "Dungeon",                  Name = MAP_LEGEND_DUNGEON,   Tooltip = MAP_LEGEND_DUNGEON_TOOLTIP,   TemplateNames = {"DungeonEntrancePinTemplate"}, MetaData = {isRaid = false}},
	Raid =				{Atlas = "Raid",                     Name = MAP_LEGEND_RAID,      Tooltip = MAP_LEGEND_RAID_TOOLTIP,      TemplateNames = {"DungeonEntrancePinTemplate"}, MetaData = {isRaid = true}},
	Hub =				{Atlas = "poi-hub",                  Name = MAP_LEGEND_HUB,       Tooltip = MAP_LEGEND_HUB_TOOLTIP,       TemplateNames = {"QuestHubPinTemplate"}},
	DigSite =			{Atlas = "ArchBlob",                 Name = MAP_LEGEND_DIGSITE,   Tooltip = MAP_LEGEND_DIGSITE_TOOLTIP,   TemplateNames = {"DigSitePinTemplate"}},
	PetBattle =			{Atlas = "WildBattlePetCapturable", fixedWidth = 24, fixedHeight = 24, Name = MAP_LEGEND_PETBATTLE, Tooltip = MAP_LEGEND_PETBATTLE_TOOLTIP, TemplateNames = {"PetTamerPinTemplate"}},
	Delve =				{Atlas = "delves-regular",		   Name = MAP_LEGEND_DELVE,		Tooltip = MAP_LEGEND_DELVE_TOOLTIP,		TemplateNames = {"DelveEntrancePinTemplate", "AreaPOIPinTemplate"}, MetaData = {AtlasPrefix="delves-"}},
	Teleport =			{Atlas = "TaxiNode_Continent_Neutral",  Name = MAP_LEGEND_TELEPORT,     Tooltip = MAP_LEGEND_TELEPORT_TOOLTIP,    TemplateNames = {"AreaPOIPinTemplate"}, MetaData = {AtlasPrefix = "TaxiNode_Continent"}},
	Cave =				{Atlas = "CaveUnderground-Up",          Name = MAP_LEGEND_CAVE,         Tooltip = MAP_LEGEND_CAVE_TOOLTIP,        TemplateNames = {"MapLinkPinTemplate"}},
	FlightMaster =		{Atlas = "FlightPath",                  fixedWidth = 24, fixedHeight = 24, Name = MAP_LEGEND_FLIGHTPOINT,  Tooltip = MAP_LEGEND_FLIGHTPOINT_TOOLTIP, TemplateNames = {"FlightPointPinTemplate"}},
};
