local QuestLog =
{
	Name = "QuestLog",
	Type = "System",
	Namespace = "C_QuestLog",

	Functions =
	{
		{
			Name = "GetMapForQuestPOIs",
			Type = "Function",

			Returns =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxNumQuests",
			Type = "Function",
			Documentation = { "This is the maximum number of quests a player can be on, including hidden quests, world quests, emissaries etc" },

			Returns =
			{
				{ Name = "maxNumQuests", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxNumQuestsCanAccept",
			Type = "Function",
			Documentation = { "This is the maximum number of standard quests a player can accept. These are quests that are normally visible in the quest log." },

			Returns =
			{
				{ Name = "maxNumQuestsCanAccept", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNextWaypoint",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNextWaypointForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNextWaypointText",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "waypointText", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetNumQuestObjectives",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "leaderboardCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "title", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetQuestObjectives",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "objectives", Type = "table", InnerType = "QuestObjectiveInfo", Nilable = false },
			},
		},
		{
			Name = "GetQuestsOnMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "quests", Type = "table", InnerType = "QuestOnMapInfo", Nilable = false },
			},
		},
		{
			Name = "GetZoneStoryInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
				{ Name = "storyMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsLegendaryQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isLegendaryQuest", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOnQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isOnQuest", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsQuestDisabledForSession",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isDisabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsQuestFlaggedCompleted",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCompleted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsQuestReplayable",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isReplayable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsQuestReplayedRecently",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "recentlyReplayed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsQuestTrivial",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isTrivial", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "QuestHasWarModeBonus",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasBonus", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestLoadQuestByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMapForQuestPOIs",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShouldShowQuestRewards",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "shouldShow", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "QuestAccepted",
			Type = "Event",
			LiteralName = "QUEST_ACCEPTED",
			Payload =
			{
				{ Name = "questIndex", Type = "number", Nilable = false },
				{ Name = "questId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "QuestAutocomplete",
			Type = "Event",
			LiteralName = "QUEST_AUTOCOMPLETE",
			Payload =
			{
				{ Name = "questId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "QuestComplete",
			Type = "Event",
			LiteralName = "QUEST_COMPLETE",
		},
		{
			Name = "QuestDataLoadResult",
			Type = "Event",
			LiteralName = "QUEST_DATA_LOAD_RESULT",
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "QuestDetail",
			Type = "Event",
			LiteralName = "QUEST_DETAIL",
			Payload =
			{
				{ Name = "questStartItemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "QuestLogCriteriaUpdate",
			Type = "Event",
			LiteralName = "QUEST_LOG_CRITERIA_UPDATE",
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "specificTreeID", Type = "number", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "numFulfilled", Type = "number", Nilable = false },
				{ Name = "numRequired", Type = "number", Nilable = false },
			},
		},
		{
			Name = "QuestLogUpdate",
			Type = "Event",
			LiteralName = "QUEST_LOG_UPDATE",
		},
		{
			Name = "QuestPoiUpdate",
			Type = "Event",
			LiteralName = "QUEST_POI_UPDATE",
		},
		{
			Name = "QuestRemoved",
			Type = "Event",
			LiteralName = "QUEST_REMOVED",
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "QuestTurnedIn",
			Type = "Event",
			LiteralName = "QUEST_TURNED_IN",
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "xpReward", Type = "number", Nilable = false },
				{ Name = "moneyReward", Type = "number", Nilable = false },
			},
		},
		{
			Name = "QuestWatchListChanged",
			Type = "Event",
			LiteralName = "QUEST_WATCH_LIST_CHANGED",
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "added", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "QuestWatchUpdate",
			Type = "Event",
			LiteralName = "QUEST_WATCH_UPDATE",
			Payload =
			{
				{ Name = "questIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "QuestlineUpdate",
			Type = "Event",
			LiteralName = "QUESTLINE_UPDATE",
			Payload =
			{
				{ Name = "requestRequired", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SuperTrackedQuestChanged",
			Type = "Event",
			LiteralName = "SUPER_TRACKED_QUEST_CHANGED",
		},
		{
			Name = "TaskProgressUpdate",
			Type = "Event",
			LiteralName = "TASK_PROGRESS_UPDATE",
		},
		{
			Name = "TreasurePickerCacheFlush",
			Type = "Event",
			LiteralName = "TREASURE_PICKER_CACHE_FLUSH",
		},
		{
			Name = "WaypointUpdate",
			Type = "Event",
			LiteralName = "WAYPOINT_UPDATE",
		},
		{
			Name = "WorldQuestCompletedBySpell",
			Type = "Event",
			LiteralName = "WORLD_QUEST_COMPLETED_BY_SPELL",
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "QuestTag",
			Type = "Enumeration",
			NumValues = 11,
			MinValue = 1,
			MaxValue = 266,
			Fields =
			{
				{ Name = "Group", Type = "QuestTag", EnumValue = 1 },
				{ Name = "Pvp", Type = "QuestTag", EnumValue = 41 },
				{ Name = "Raid", Type = "QuestTag", EnumValue = 62 },
				{ Name = "Dungeon", Type = "QuestTag", EnumValue = 81 },
				{ Name = "Legendary", Type = "QuestTag", EnumValue = 83 },
				{ Name = "Heroic", Type = "QuestTag", EnumValue = 85 },
				{ Name = "Raid10", Type = "QuestTag", EnumValue = 88 },
				{ Name = "Raid25", Type = "QuestTag", EnumValue = 89 },
				{ Name = "Scenario", Type = "QuestTag", EnumValue = 98 },
				{ Name = "Account", Type = "QuestTag", EnumValue = 102 },
				{ Name = "CombatAlly", Type = "QuestTag", EnumValue = 266 },
			},
		},
		{
			Name = "QuestObjectiveInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "finished", Type = "bool", Nilable = false },
				{ Name = "numFulfilled", Type = "number", Nilable = false },
				{ Name = "numRequired", Type = "number", Nilable = false },
			},
		},
		{
			Name = "QuestOnMapInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "type", Type = "number", Nilable = false },
				{ Name = "isMapIndicatorQuest", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestLog);