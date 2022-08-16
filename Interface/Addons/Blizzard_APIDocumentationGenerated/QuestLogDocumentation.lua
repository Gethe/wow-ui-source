local QuestLog =
{
	Name = "QuestLog",
	Type = "System",
	Namespace = "C_QuestLog",

	Functions =
	{
		{
			Name = "AbandonQuest",
			Type = "Function",
		},
		{
			Name = "AddQuestWatch",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "watchType", Type = "QuestWatchType", Nilable = true },
			},

			Returns =
			{
				{ Name = "wasWatched", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AddWorldQuestWatch",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "watchType", Type = "QuestWatchType", Nilable = true },
			},

			Returns =
			{
				{ Name = "wasWatched", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanAbandonQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canAbandon", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAbandonQuest",
			Type = "Function",

			Returns =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAbandonQuestItems",
			Type = "Function",

			Returns =
			{
				{ Name = "itemIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetActiveThreatMaps",
			Type = "Function",

			Returns =
			{
				{ Name = "uiMapIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetAllCompletedQuestIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "quests", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetBountiesForMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "bounties", Type = "table", InnerType = "BountyInfo", Nilable = true },
			},
		},
		{
			Name = "GetBountySetInfoForMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "displayLocation", Type = "MapOverlayDisplayLocation", Nilable = false },
				{ Name = "lockQuestID", Type = "number", Nilable = false },
				{ Name = "bountySetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDistanceSqToQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "distanceSq", Type = "number", Nilable = false },
				{ Name = "onContinent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "questLogIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "QuestInfo", Nilable = true },
			},
		},
		{
			Name = "GetLogIndexForQuestID",
			Type = "Function",
			Documentation = { "Only returns a log index for actual quests, not headers" },

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questLogIndex", Type = "number", Nilable = true },
			},
		},
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
			Name = "GetNumQuestLogEntries",
			Type = "Function",

			Returns =
			{
				{ Name = "numShownEntries", Type = "number", Nilable = false },
				{ Name = "numQuests", Type = "number", Nilable = false },
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
			Name = "GetNumQuestWatches",
			Type = "Function",

			Returns =
			{
				{ Name = "numQuestWatches", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumWorldQuestWatches",
			Type = "Function",

			Returns =
			{
				{ Name = "numQuestWatches", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestAdditionalHighlights",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
				{ Name = "worldQuests", Type = "bool", Nilable = false },
				{ Name = "worldQuestsElite", Type = "bool", Nilable = false },
				{ Name = "dungeons", Type = "bool", Nilable = false },
				{ Name = "treasures", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetQuestDetailsTheme",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "theme", Type = "QuestTheme", Nilable = true },
			},
		},
		{
			Name = "GetQuestDifficultyLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetQuestIDForLogIndex",
			Type = "Function",
			Documentation = { "Only returns a questID for actual quests, not headers" },

			Arguments =
			{
				{ Name = "questLogIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetQuestIDForQuestWatchIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "questWatchIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetQuestIDForWorldQuestWatchIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "questWatchIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetQuestLogPortraitGiver",
			Type = "Function",

			Arguments =
			{
				{ Name = "questLogIndex", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "portraitGiver", Type = "number", Nilable = false },
				{ Name = "portraitGiverText", Type = "string", Nilable = false },
				{ Name = "portraitGiverName", Type = "string", Nilable = false },
				{ Name = "portraitGiverMount", Type = "number", Nilable = false },
				{ Name = "portraitGiverModelSceneID", Type = "number", Nilable = true },
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
			Name = "GetQuestTagInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "QuestTagInfo", Nilable = true },
			},
		},
		{
			Name = "GetQuestType",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questType", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetQuestWatchType",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "watchType", Type = "QuestWatchType", Nilable = true },
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
			Name = "GetRequiredMoney",
			Type = "Function",
			Documentation = { "Uses the selected quest if no questID is provided" },

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "requiredMoney", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSelectedQuest",
			Type = "Function",

			Returns =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSuggestedGroupSize",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "suggestedGroupSize", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTimeAllowed",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "totalTime", Type = "number", Nilable = false },
				{ Name = "elapsedTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTitleForLogIndex",
			Type = "Function",
			Documentation = { "Returns a valid title for anything that is in the quest log." },

			Arguments =
			{
				{ Name = "questLogIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "title", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetTitleForQuestID",
			Type = "Function",
			Documentation = { "Only returns a valid title for quests, header titles cannot be discovered using this." },

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "title", Type = "string", Nilable = true },
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
			Name = "HasActiveThreats",
			Type = "Function",

			Returns =
			{
				{ Name = "hasActiveThreats", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAccountQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAccountQuest", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsComplete",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isComplete", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFailed",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFailed", Type = "bool", Nilable = false },
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
			Name = "IsOnMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "onMap", Type = "bool", Nilable = false },
				{ Name = "hasLocalPOI", Type = "bool", Nilable = false },
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
			Name = "IsPushableQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPushable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsQuestBounty",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isBounty", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsQuestCalling",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCalling", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsQuestCriteriaForBounty",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "bountyQuestID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCriteriaForBounty", Type = "bool", Nilable = false },
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
			Name = "IsQuestInvasion",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isInvasion", Type = "bool", Nilable = false },
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
			Name = "IsQuestTask",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isTask", Type = "bool", Nilable = false },
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
			Name = "IsRepeatableQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRepeatable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsThreatQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isThreat", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUnitOnQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isOnQuest", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsWorldQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isWorldQuest", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "QuestCanHaveWarModeBonus",
			Type = "Function",
			Documentation = { "Tests whether a quest is eligible for warmode bonuses (e.g. most world quests, some daily quests" },

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
			Name = "QuestHasQuestSessionBonus",
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
			Name = "QuestHasWarModeBonus",
			Type = "Function",
			Documentation = { "Tests whether a quest in the player's quest log that is eligible for warmode bonuses (see 'QuestCanHaveWarModeBOnus') has been completed in warmode (including accepting it)" },

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
			Name = "ReadyForTurnIn",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "readyForTurnIn", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "RemoveQuestWatch",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "wasRemoved", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveWorldQuestWatch",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "wasRemoved", Type = "bool", Nilable = false },
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
			Name = "SetAbandonQuest",
			Type = "Function",
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
			Name = "SetSelectedQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShouldDisplayTimeRemaining",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "displayTimeRemaining", Type = "bool", Nilable = false },
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
		{
			Name = "SortQuestWatches",
			Type = "Function",
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
				{ Name = "wasReplayQuest", Type = "bool", Nilable = false },
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
				{ Name = "questID", Type = "number", Nilable = false },
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
			Name = "MapOverlayDisplayLocation",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Default", Type = "MapOverlayDisplayLocation", EnumValue = 0 },
				{ Name = "BottomLeft", Type = "MapOverlayDisplayLocation", EnumValue = 1 },
				{ Name = "TopLeft", Type = "MapOverlayDisplayLocation", EnumValue = 2 },
				{ Name = "BottomRight", Type = "MapOverlayDisplayLocation", EnumValue = 3 },
				{ Name = "TopRight", Type = "MapOverlayDisplayLocation", EnumValue = 4 },
				{ Name = "Hidden", Type = "MapOverlayDisplayLocation", EnumValue = 5 },
			},
		},
		{
			Name = "QuestFrequency",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Default", Type = "QuestFrequency", EnumValue = 0 },
				{ Name = "Daily", Type = "QuestFrequency", EnumValue = 1 },
				{ Name = "Weekly", Type = "QuestFrequency", EnumValue = 2 },
			},
		},
		{
			Name = "QuestTag",
			Type = "Enumeration",
			NumValues = 11,
			MinValue = 1,
			MaxValue = 266,
			Fields =
			{
				{ Name = "Group", Type = "QuestTag", EnumValue = 1 },
				{ Name = "PvP", Type = "QuestTag", EnumValue = 41 },
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
			Name = "QuestWatchType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Automatic", Type = "QuestWatchType", EnumValue = 0 },
				{ Name = "Manual", Type = "QuestWatchType", EnumValue = 1 },
			},
		},
		{
			Name = "WorldQuestQuality",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Common", Type = "WorldQuestQuality", EnumValue = 0 },
				{ Name = "Rare", Type = "WorldQuestQuality", EnumValue = 1 },
				{ Name = "Epic", Type = "WorldQuestQuality", EnumValue = 2 },
			},
		},
		{
			Name = "QuestInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "questLogIndex", Type = "number", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "campaignID", Type = "number", Nilable = true },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "difficultyLevel", Type = "number", Nilable = false },
				{ Name = "suggestedGroup", Type = "number", Nilable = false },
				{ Name = "frequency", Type = "QuestFrequency", Nilable = true },
				{ Name = "isHeader", Type = "bool", Nilable = false },
				{ Name = "isCollapsed", Type = "bool", Nilable = false },
				{ Name = "startEvent", Type = "bool", Nilable = false },
				{ Name = "isTask", Type = "bool", Nilable = false },
				{ Name = "isBounty", Type = "bool", Nilable = false },
				{ Name = "isStory", Type = "bool", Nilable = false },
				{ Name = "isScaling", Type = "bool", Nilable = false },
				{ Name = "isOnMap", Type = "bool", Nilable = false },
				{ Name = "hasLocalPOI", Type = "bool", Nilable = false },
				{ Name = "isHidden", Type = "bool", Nilable = false },
				{ Name = "isAutoComplete", Type = "bool", Nilable = false },
				{ Name = "overridesSortOrder", Type = "bool", Nilable = false },
				{ Name = "readyForTranslation", Type = "bool", Nilable = false, Default = true },
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
		{
			Name = "QuestTagInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "tagName", Type = "string", Nilable = false },
				{ Name = "tagID", Type = "number", Nilable = false },
				{ Name = "worldQuestType", Type = "number", Nilable = true },
				{ Name = "quality", Type = "WorldQuestQuality", Nilable = true },
				{ Name = "tradeskillLineID", Type = "number", Nilable = true },
				{ Name = "isElite", Type = "bool", Nilable = true },
				{ Name = "displayExpiration", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "QuestTheme",
			Type = "Structure",
			Fields =
			{
				{ Name = "background", Type = "string", Nilable = false },
				{ Name = "seal", Type = "string", Nilable = false },
				{ Name = "signature", Type = "string", Nilable = false },
				{ Name = "poiIcon", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestLog);