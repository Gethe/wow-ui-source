local GarrisonInfo =
{
	Name = "GarrisonInfo",
	Type = "System",
	Namespace = "C_Garrison",

	Functions =
	{
		{
			Name = "AddFollowerToMission",
			Type = "Function",

			Arguments =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
				{ Name = "followerID", Type = "string", Nilable = false },
				{ Name = "boardIndex", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "followerAdded", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAutoCombatDamageClassValues",
			Type = "Function",

			Returns =
			{
				{ Name = "damageClassStrings", Type = "table", InnerType = "AutoCombatDamageClassString", Nilable = false },
			},
		},
		{
			Name = "GetAutoMissionBoardState",
			Type = "Function",

			Arguments =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "targetInfo", Type = "table", InnerType = "AutoMissionTargetingInfo", Nilable = false },
			},
		},
		{
			Name = "GetAutoMissionEnvironmentEffect",
			Type = "Function",

			Arguments =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "autoMissionEnvEffect", Type = "AutoMissionEnvironmentEffect", Nilable = true },
			},
		},
		{
			Name = "GetAutoMissionTargetingInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
				{ Name = "followerID", Type = "string", Nilable = false },
				{ Name = "casterBoardIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "targetInfo", Type = "table", InnerType = "AutoMissionTargetingInfo", Nilable = false },
			},
		},
		{
			Name = "GetAutoMissionTargetingInfoForSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
				{ Name = "autoCombatSpellID", Type = "number", Nilable = false },
				{ Name = "casterBoardIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "targetInfo", Type = "table", InnerType = "AutoMissionTargetingInfo", Nilable = false },
			},
		},
		{
			Name = "GetAutoTroops",
			Type = "Function",

			Arguments =
			{
				{ Name = "followerType", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "autoTroopInfo", Type = "table", InnerType = "AutoCombatTroopInfo", Nilable = false },
			},
		},
		{
			Name = "GetCombatLogSpellInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "autoCombatSpellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellInfo", Type = "AutoCombatSpellInfo", Nilable = true },
			},
		},
		{
			Name = "GetCurrentGarrTalentTreeFriendshipFactionID",
			Type = "Function",

			Returns =
			{
				{ Name = "currentGarrTalentTreeFriendshipFactionID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCurrentGarrTalentTreeID",
			Type = "Function",

			Returns =
			{
				{ Name = "currentGarrTalentTreeID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetFollowerAutoCombatSpells",
			Type = "Function",

			Arguments =
			{
				{ Name = "garrFollowerID", Type = "string", Nilable = false },
				{ Name = "followerLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "autoCombatSpells", Type = "table", InnerType = "AutoCombatSpellInfo", Nilable = false },
				{ Name = "autoCombatAutoAttack", Type = "AutoCombatSpellInfo", Nilable = true },
			},
		},
		{
			Name = "GetFollowerAutoCombatStats",
			Type = "Function",

			Arguments =
			{
				{ Name = "garrFollowerID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "autoCombatInfo", Type = "FollowerAutoCombatStatsInfo", Nilable = true },
			},
		},
		{
			Name = "GetFollowerMissionCompleteInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "followerID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "followerMissionCompleteInfo", Type = "FollowerMissionCompleteInfo", Nilable = false },
			},
		},
		{
			Name = "GetGarrisonPlotsInstancesForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "garrisonPlotInstances", Type = "table", InnerType = "GarrisonPlotInstanceMapInfo", Nilable = false },
			},
		},
		{
			Name = "GetGarrisonTalentTreeCurrencyTypes",
			Type = "Function",

			Arguments =
			{
				{ Name = "garrTalentTreeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "garrTalentTreeCurrencyType", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetGarrisonTalentTreeType",
			Type = "Function",

			Arguments =
			{
				{ Name = "garrTalentTreeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "garrTalentTreeType", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMissionCompleteEncounters",
			Type = "Function",

			Arguments =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "encounters", Type = "table", InnerType = "GarrisonEnemyEncounterInfo", Nilable = false },
			},
		},
		{
			Name = "GetMissionDeploymentInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "missionDeploymentInfo", Type = "MissionDeploymentInfo", Nilable = false },
			},
		},
		{
			Name = "GetMissionEncounterIconInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "missionEncounterIconInfo", Type = "MissionEncounterIconInfo", Nilable = false },
			},
		},
		{
			Name = "GetTalentInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "GarrisonTalentInfo", Nilable = false },
			},
		},
		{
			Name = "GetTalentPointsSpentInTalentTree",
			Type = "Function",

			Arguments =
			{
				{ Name = "garrTalentTreeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "talentPoints", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTalentTreeIDsByClassID",
			Type = "Function",

			Arguments =
			{
				{ Name = "garrType", Type = "number", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "treeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetTalentTreeInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "GarrisonTalentTreeInfo", Nilable = false },
			},
		},
		{
			Name = "GetTalentTreeResetInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "garrTalentTreeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "goldCost", Type = "number", Nilable = false },
				{ Name = "currencyCosts", Type = "table", InnerType = "GarrisonTalentCurrencyCostInfo", Nilable = false },
			},
		},
		{
			Name = "GetTalentTreeTalentPointResearchInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "garrTalentTreeID", Type = "number", Nilable = false },
				{ Name = "talentPointIndex", Type = "number", Nilable = false },
				{ Name = "isRespec", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "goldCost", Type = "number", Nilable = false },
				{ Name = "currencyCosts", Type = "table", InnerType = "GarrisonTalentCurrencyCostInfo", Nilable = false },
				{ Name = "durationSecs", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTalentUnlockWorldQuest",
			Type = "Function",

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "worldQuestID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasAdventures",
			Type = "Function",

			Returns =
			{
				{ Name = "hasAdventures", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAtGarrisonMissionNPC",
			Type = "Function",

			Returns =
			{
				{ Name = "atGarrisonMissionNPC", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEnvironmentCountered",
			Type = "Function",

			Arguments =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "environmentCountered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFollowerOnCompletedMission",
			Type = "Function",

			Arguments =
			{
				{ Name = "followerID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "followerOnCompletedMission", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTalentConditionMet",
			Type = "Function",

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isMet", Type = "bool", Nilable = false },
				{ Name = "failureString", Type = "string", Nilable = true },
			},
		},
		{
			Name = "RegenerateCombatLog",
			Type = "Function",

			Arguments =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveFollowerFromMission",
			Type = "Function",

			Arguments =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
				{ Name = "followerID", Type = "string", Nilable = false },
				{ Name = "boardIndex", Type = "number", Nilable = true },
			},
		},
		{
			Name = "RushHealAllFollowers",
			Type = "Function",

			Arguments =
			{
				{ Name = "followerType", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RushHealFollower",
			Type = "Function",

			Arguments =
			{
				{ Name = "garrFollowerID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetAutoCombatSpellFastForward",
			Type = "Function",

			Arguments =
			{
				{ Name = "state", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "GarrisonArchitectClosed",
			Type = "Event",
			LiteralName = "GARRISON_ARCHITECT_CLOSED",
		},
		{
			Name = "GarrisonArchitectOpened",
			Type = "Event",
			LiteralName = "GARRISON_ARCHITECT_OPENED",
			Payload =
			{
				{ Name = "followerTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonBuildingActivatable",
			Type = "Event",
			LiteralName = "GARRISON_BUILDING_ACTIVATABLE",
			Payload =
			{
				{ Name = "buildingName", Type = "string", Nilable = false },
				{ Name = "garrisonType", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonBuildingActivated",
			Type = "Event",
			LiteralName = "GARRISON_BUILDING_ACTIVATED",
			Payload =
			{
				{ Name = "garrisonPlotInstanceID", Type = "number", Nilable = false },
				{ Name = "garrisonBuildingID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonBuildingError",
			Type = "Event",
			LiteralName = "GARRISON_BUILDING_ERROR",
		},
		{
			Name = "GarrisonBuildingListUpdate",
			Type = "Event",
			LiteralName = "GARRISON_BUILDING_LIST_UPDATE",
			Payload =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonBuildingPlaced",
			Type = "Event",
			LiteralName = "GARRISON_BUILDING_PLACED",
			Payload =
			{
				{ Name = "garrisonPlotInstanceID", Type = "number", Nilable = false },
				{ Name = "newPlacement", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GarrisonBuildingRemoved",
			Type = "Event",
			LiteralName = "GARRISON_BUILDING_REMOVED",
			Payload =
			{
				{ Name = "garrPlotInstanceID", Type = "number", Nilable = false },
				{ Name = "garrBuildingID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonBuildingUpdate",
			Type = "Event",
			LiteralName = "GARRISON_BUILDING_UPDATE",
			Payload =
			{
				{ Name = "garrisonBuildingID", Type = "number", Nilable = false },
				{ Name = "garrPlotInstanceID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GarrisonFollowerAdded",
			Type = "Event",
			LiteralName = "GARRISON_FOLLOWER_ADDED",
			Payload =
			{
				{ Name = "followerDbID", Type = "string", Nilable = false },
				{ Name = "followerName", Type = "string", Nilable = false },
				{ Name = "followerClassName", Type = "string", Nilable = false },
				{ Name = "followerLevel", Type = "number", Nilable = false },
				{ Name = "followerQuality", Type = "number", Nilable = false },
				{ Name = "isUpgraded", Type = "bool", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "followerTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonFollowerCategoriesUpdated",
			Type = "Event",
			LiteralName = "GARRISON_FOLLOWER_CATEGORIES_UPDATED",
		},
		{
			Name = "GarrisonFollowerDurabilityChanged",
			Type = "Event",
			LiteralName = "GARRISON_FOLLOWER_DURABILITY_CHANGED",
			Payload =
			{
				{ Name = "garrFollowerTypeID", Type = "number", Nilable = false },
				{ Name = "followerDbID", Type = "string", Nilable = false },
				{ Name = "followerDurability", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonFollowerHealed",
			Type = "Event",
			LiteralName = "GARRISON_FOLLOWER_HEALED",
			Payload =
			{
				{ Name = "followerID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GarrisonFollowerListUpdate",
			Type = "Event",
			LiteralName = "GARRISON_FOLLOWER_LIST_UPDATE",
			Payload =
			{
				{ Name = "followerTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonFollowerRemoved",
			Type = "Event",
			LiteralName = "GARRISON_FOLLOWER_REMOVED",
			Payload =
			{
				{ Name = "followerTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonFollowerUpgraded",
			Type = "Event",
			LiteralName = "GARRISON_FOLLOWER_UPGRADED",
			Payload =
			{
				{ Name = "followerDbID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GarrisonFollowerXpChanged",
			Type = "Event",
			LiteralName = "GARRISON_FOLLOWER_XP_CHANGED",
			Payload =
			{
				{ Name = "garrFollowerTypeID", Type = "number", Nilable = false },
				{ Name = "followerDbID", Type = "string", Nilable = false },
				{ Name = "xpChange", Type = "number", Nilable = false },
				{ Name = "oldFollowerXp", Type = "number", Nilable = false },
				{ Name = "oldFollowerLevel", Type = "number", Nilable = false },
				{ Name = "oldFollowerQuality", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonHideLandingPage",
			Type = "Event",
			LiteralName = "GARRISON_HIDE_LANDING_PAGE",
		},
		{
			Name = "GarrisonInvasionAvailable",
			Type = "Event",
			LiteralName = "GARRISON_INVASION_AVAILABLE",
		},
		{
			Name = "GarrisonInvasionUnavailable",
			Type = "Event",
			LiteralName = "GARRISON_INVASION_UNAVAILABLE",
		},
		{
			Name = "GarrisonLandingpageShipments",
			Type = "Event",
			LiteralName = "GARRISON_LANDINGPAGE_SHIPMENTS",
		},
		{
			Name = "GarrisonMissionAreaBonusAdded",
			Type = "Event",
			LiteralName = "GARRISON_MISSION_AREA_BONUS_ADDED",
			Payload =
			{
				{ Name = "garrisonMissonBonusAbilityID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonMissionBonusRollComplete",
			Type = "Event",
			LiteralName = "GARRISON_MISSION_BONUS_ROLL_COMPLETE",
			Payload =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GarrisonMissionCompleteResponse",
			Type = "Event",
			LiteralName = "GARRISON_MISSION_COMPLETE_RESPONSE",
			Payload =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
				{ Name = "canComplete", Type = "bool", Nilable = false },
				{ Name = "success", Type = "bool", Nilable = false },
				{ Name = "bonusRollSuccess", Type = "bool", Nilable = false },
				{ Name = "followerDeaths", Type = "table", InnerType = "GarrisonFollowerDeathInfo", Nilable = false },
				{ Name = "autoCombatResult", Type = "AutoCombatResult", Nilable = true },
			},
		},
		{
			Name = "GarrisonMissionFinished",
			Type = "Event",
			LiteralName = "GARRISON_MISSION_FINISHED",
			Payload =
			{
				{ Name = "followerTypeID", Type = "number", Nilable = false },
				{ Name = "missionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonMissionListUpdate",
			Type = "Event",
			LiteralName = "GARRISON_MISSION_LIST_UPDATE",
			Payload =
			{
				{ Name = "garrFollowerTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonMissionNpcClosed",
			Type = "Event",
			LiteralName = "GARRISON_MISSION_NPC_CLOSED",
		},
		{
			Name = "GarrisonMissionNpcOpened",
			Type = "Event",
			LiteralName = "GARRISON_MISSION_NPC_OPENED",
			Payload =
			{
				{ Name = "followerTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonMissionRewardInfo",
			Type = "Event",
			LiteralName = "GARRISON_MISSION_REWARD_INFO",
			Payload =
			{
				{ Name = "missionID", Type = "number", Nilable = false },
				{ Name = "followerDbID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GarrisonMissionStarted",
			Type = "Event",
			LiteralName = "GARRISON_MISSION_STARTED",
			Payload =
			{
				{ Name = "garrFollowerTypeID", Type = "number", Nilable = false },
				{ Name = "missionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonMonumentCloseUi",
			Type = "Event",
			LiteralName = "GARRISON_MONUMENT_CLOSE_UI",
		},
		{
			Name = "GarrisonMonumentListLoaded",
			Type = "Event",
			LiteralName = "GARRISON_MONUMENT_LIST_LOADED",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GarrisonMonumentReplaced",
			Type = "Event",
			LiteralName = "GARRISON_MONUMENT_REPLACED",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GarrisonMonumentSelectedTrophyIdLoaded",
			Type = "Event",
			LiteralName = "GARRISON_MONUMENT_SELECTED_TROPHY_ID_LOADED",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GarrisonMonumentShowUi",
			Type = "Event",
			LiteralName = "GARRISON_MONUMENT_SHOW_UI",
		},
		{
			Name = "GarrisonRandomMissionAdded",
			Type = "Event",
			LiteralName = "GARRISON_RANDOM_MISSION_ADDED",
			Payload =
			{
				{ Name = "followerTypeID", Type = "number", Nilable = false },
				{ Name = "missionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonRecallPortalLastUsedTime",
			Type = "Event",
			LiteralName = "GARRISON_RECALL_PORTAL_LAST_USED_TIME",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
				{ Name = "recallPortalLastUsedTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonRecallPortalUsed",
			Type = "Event",
			LiteralName = "GARRISON_RECALL_PORTAL_USED",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GarrisonRecruitFollowerResult",
			Type = "Event",
			LiteralName = "GARRISON_RECRUIT_FOLLOWER_RESULT",
		},
		{
			Name = "GarrisonRecruitmentFollowersGenerated",
			Type = "Event",
			LiteralName = "GARRISON_RECRUITMENT_FOLLOWERS_GENERATED",
		},
		{
			Name = "GarrisonRecruitmentNpcClosed",
			Type = "Event",
			LiteralName = "GARRISON_RECRUITMENT_NPC_CLOSED",
		},
		{
			Name = "GarrisonRecruitmentNpcOpened",
			Type = "Event",
			LiteralName = "GARRISON_RECRUITMENT_NPC_OPENED",
			Payload =
			{
				{ Name = "followerTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonRecruitmentReady",
			Type = "Event",
			LiteralName = "GARRISON_RECRUITMENT_READY",
		},
		{
			Name = "GarrisonShipmentReceived",
			Type = "Event",
			LiteralName = "GARRISON_SHIPMENT_RECEIVED",
		},
		{
			Name = "GarrisonShipyardNpcClosed",
			Type = "Event",
			LiteralName = "GARRISON_SHIPYARD_NPC_CLOSED",
		},
		{
			Name = "GarrisonShipyardNpcOpened",
			Type = "Event",
			LiteralName = "GARRISON_SHIPYARD_NPC_OPENED",
			Payload =
			{
				{ Name = "followerTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonShowLandingPage",
			Type = "Event",
			LiteralName = "GARRISON_SHOW_LANDING_PAGE",
		},
		{
			Name = "GarrisonSpecGroupUpdated",
			Type = "Event",
			LiteralName = "GARRISON_SPEC_GROUP_UPDATED",
			Payload =
			{
				{ Name = "garrTypeID", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonSpecGroupsCleared",
			Type = "Event",
			LiteralName = "GARRISON_SPEC_GROUPS_CLEARED",
			Payload =
			{
				{ Name = "garrTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonTalentComplete",
			Type = "Event",
			LiteralName = "GARRISON_TALENT_COMPLETE",
			Payload =
			{
				{ Name = "garrTypeID", Type = "number", Nilable = false },
				{ Name = "doAlert", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GarrisonTalentEventUpdate",
			Type = "Event",
			LiteralName = "GARRISON_TALENT_EVENT_UPDATE",
			Payload =
			{
				{ Name = "eventType", Type = "number", Nilable = false },
				{ Name = "eventID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonTalentNpcClosed",
			Type = "Event",
			LiteralName = "GARRISON_TALENT_NPC_CLOSED",
		},
		{
			Name = "GarrisonTalentNpcOpened",
			Type = "Event",
			LiteralName = "GARRISON_TALENT_NPC_OPENED",
			Payload =
			{
				{ Name = "garrisonTypeID", Type = "number", Nilable = false },
				{ Name = "garrisonTalentTreeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonTalentResearchStarted",
			Type = "Event",
			LiteralName = "GARRISON_TALENT_RESEARCH_STARTED",
			Payload =
			{
				{ Name = "garrTypeID", Type = "number", Nilable = false },
				{ Name = "garrisonTalentTreeID", Type = "number", Nilable = false },
				{ Name = "garrTalentID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonTalentUnlocksResult",
			Type = "Event",
			LiteralName = "GARRISON_TALENT_UNLOCKS_RESULT",
		},
		{
			Name = "GarrisonTalentUpdate",
			Type = "Event",
			LiteralName = "GARRISON_TALENT_UPDATE",
			Payload =
			{
				{ Name = "garrTypeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonTradeskillNpcClosed",
			Type = "Event",
			LiteralName = "GARRISON_TRADESKILL_NPC_CLOSED",
		},
		{
			Name = "GarrisonUpdate",
			Type = "Event",
			LiteralName = "GARRISON_UPDATE",
		},
		{
			Name = "GarrisonUpgradeableResult",
			Type = "Event",
			LiteralName = "GARRISON_UPGRADEABLE_RESULT",
			Payload =
			{
				{ Name = "garrisonUpgradeable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GarrisonUsePartyGarrisonChanged",
			Type = "Event",
			LiteralName = "GARRISON_USE_PARTY_GARRISON_CHANGED",
		},
		{
			Name = "ShipmentCrafterClosed",
			Type = "Event",
			LiteralName = "SHIPMENT_CRAFTER_CLOSED",
		},
		{
			Name = "ShipmentCrafterInfo",
			Type = "Event",
			LiteralName = "SHIPMENT_CRAFTER_INFO",
			Payload =
			{
				{ Name = "success", Type = "number", Nilable = false },
				{ Name = "shipmentCount", Type = "number", Nilable = false },
				{ Name = "maxShipments", Type = "number", Nilable = false },
				{ Name = "ownedShipments", Type = "number", Nilable = false },
				{ Name = "plotInstanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShipmentCrafterOpened",
			Type = "Event",
			LiteralName = "SHIPMENT_CRAFTER_OPENED",
			Payload =
			{
				{ Name = "charShipmentContainerID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShipmentCrafterReagentUpdate",
			Type = "Event",
			LiteralName = "SHIPMENT_CRAFTER_REAGENT_UPDATE",
		},
		{
			Name = "ShipmentUpdate",
			Type = "Event",
			LiteralName = "SHIPMENT_UPDATE",
			Payload =
			{
				{ Name = "shipmentStarted", Type = "bool", Nilable = true },
				{ Name = "hasAttachedFollower", Type = "bool", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "AutoCombatDamageClassString",
			Type = "Structure",
			Fields =
			{
				{ Name = "damageClassValue", Type = "number", Nilable = false },
				{ Name = "locString", Type = "string", Nilable = false },
			},
		},
		{
			Name = "AutoCombatResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "winner", Type = "bool", Nilable = false },
				{ Name = "combatLog", Type = "table", InnerType = "AutoMissionRound", Nilable = false },
			},
		},
		{
			Name = "AutoCombatSpellInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "autoCombatSpellID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "cooldown", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "schoolMask", Type = "number", Nilable = false },
				{ Name = "previewMask", Type = "number", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "spellTutorialFlag", Type = "number", Nilable = false },
				{ Name = "hasThornsEffect", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AutoCombatTroopInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "followerID", Type = "string", Nilable = false },
				{ Name = "garrFollowerID", Type = "string", Nilable = false },
				{ Name = "followerTypeID", Type = "number", Nilable = false },
				{ Name = "displayIDs", Type = "table", InnerType = "FollowerDisplayID", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "levelXP", Type = "number", Nilable = false },
				{ Name = "maxXP", Type = "number", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
				{ Name = "scale", Type = "number", Nilable = false },
				{ Name = "displayScale", Type = "number", Nilable = true },
				{ Name = "displayHeight", Type = "number", Nilable = true },
				{ Name = "classSpec", Type = "number", Nilable = true },
				{ Name = "className", Type = "string", Nilable = true },
				{ Name = "flavorText", Type = "string", Nilable = true },
				{ Name = "classAtlas", Type = "string", Nilable = false },
				{ Name = "portraitIconID", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "isTroop", Type = "bool", Nilable = false },
				{ Name = "raceID", Type = "number", Nilable = false },
				{ Name = "health", Type = "number", Nilable = false },
				{ Name = "maxHealth", Type = "number", Nilable = false },
				{ Name = "role", Type = "number", Nilable = false },
				{ Name = "isAutoTroop", Type = "bool", Nilable = false },
				{ Name = "isSoulbind", Type = "bool", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "autoCombatStats", Type = "FollowerAutoCombatStatsInfo", Nilable = false },
			},
		},
		{
			Name = "AutoMissionCombatEventInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "boardIndex", Type = "number", Nilable = false },
				{ Name = "oldHealth", Type = "number", Nilable = false },
				{ Name = "newHealth", Type = "number", Nilable = false },
				{ Name = "maxHealth", Type = "number", Nilable = false },
				{ Name = "points", Type = "number", Nilable = true },
			},
		},
		{
			Name = "AutoMissionEnvironmentEffect",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "autoCombatSpellInfo", Type = "AutoCombatSpellInfo", Nilable = false },
			},
		},
		{
			Name = "AutoMissionEvent",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "schoolMask", Type = "number", Nilable = false },
				{ Name = "effectIndex", Type = "number", Nilable = false },
				{ Name = "casterBoardIndex", Type = "number", Nilable = false },
				{ Name = "auraType", Type = "number", Nilable = false },
				{ Name = "targetInfo", Type = "table", InnerType = "AutoMissionCombatEventInfo", Nilable = false },
			},
		},
		{
			Name = "AutoMissionRound",
			Type = "Structure",
			Fields =
			{
				{ Name = "events", Type = "table", InnerType = "AutoMissionEvent", Nilable = false },
			},
		},
		{
			Name = "AutoMissionTargetingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "targetIndex", Type = "number", Nilable = false },
				{ Name = "previewType", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "effectIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "FollowerAutoCombatStatsInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "currentHealth", Type = "number", Nilable = false },
				{ Name = "maxHealth", Type = "number", Nilable = false },
				{ Name = "attack", Type = "number", Nilable = false },
				{ Name = "healingTimestamp", Type = "number", Nilable = false },
				{ Name = "healCost", Type = "number", Nilable = false },
				{ Name = "minutesHealingRemaining", Type = "number", Nilable = false },
			},
		},
		{
			Name = "FollowerDisplayID",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "followerPageScale", Type = "number", Nilable = false },
				{ Name = "showWeapon", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "FollowerMissionCompleteInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "displayIDs", Type = "table", InnerType = "FollowerDisplayID", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "currentXP", Type = "number", Nilable = false },
				{ Name = "maxXP", Type = "number", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
				{ Name = "scale", Type = "number", Nilable = false },
				{ Name = "movementType", Type = "number", Nilable = true },
				{ Name = "impactDelay", Type = "number", Nilable = true },
				{ Name = "castID", Type = "number", Nilable = true },
				{ Name = "castSoundID", Type = "number", Nilable = true },
				{ Name = "impactID", Type = "number", Nilable = true },
				{ Name = "impactSoundID", Type = "number", Nilable = true },
				{ Name = "targetImpactID", Type = "number", Nilable = true },
				{ Name = "targetImpactSoundID", Type = "number", Nilable = true },
				{ Name = "className", Type = "string", Nilable = true },
				{ Name = "classAtlas", Type = "string", Nilable = false },
				{ Name = "portraitIconID", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "isTroop", Type = "bool", Nilable = false },
				{ Name = "boardIndex", Type = "number", Nilable = false },
				{ Name = "health", Type = "number", Nilable = false },
				{ Name = "maxHealth", Type = "number", Nilable = false },
				{ Name = "role", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonAbilityCounterInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "factor", Type = "number", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GarrisonAbilityInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "isTrait", Type = "bool", Nilable = false },
				{ Name = "isSpecialization", Type = "bool", Nilable = false },
				{ Name = "temporary", Type = "bool", Nilable = false },
				{ Name = "category", Type = "string", Nilable = true },
				{ Name = "counters", Type = "table", InnerType = "GarrisonAbilityCounterInfo", Nilable = false },
				{ Name = "isEmptySlot", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GarrisonEnemyEncounterInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "displayID", Type = "number", Nilable = false },
				{ Name = "portraitFileDataID", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "scale", Type = "number", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
				{ Name = "mechanics", Type = "table", InnerType = "GarrisonMechanicInfo", Nilable = false },
				{ Name = "autoCombatSpells", Type = "table", InnerType = "AutoCombatSpellInfo", Nilable = false },
				{ Name = "autoCombatAutoAttack", Type = "AutoCombatSpellInfo", Nilable = true },
				{ Name = "role", Type = "number", Nilable = false },
				{ Name = "health", Type = "number", Nilable = false },
				{ Name = "maxHealth", Type = "number", Nilable = false },
				{ Name = "attack", Type = "number", Nilable = false },
				{ Name = "boardIndex", Type = "number", Nilable = false },
				{ Name = "isElite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GarrisonFollowerDeathInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "followerID", Type = "string", Nilable = false },
				{ Name = "state", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonMechanicInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "mechanicTypeID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "factor", Type = "number", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "ability", Type = "GarrisonAbilityInfo", Nilable = true },
			},
		},
		{
			Name = "GarrisonPlotInstanceMapInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "buildingPlotInstanceID", Type = "number", Nilable = false },
				{ Name = "position", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "atlasName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "MissionDeploymentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "location", Type = "string", Nilable = false },
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "environment", Type = "string", Nilable = true },
				{ Name = "environmentDesc", Type = "string", Nilable = true },
				{ Name = "environmentTexture", Type = "number", Nilable = false },
				{ Name = "locTextureKit", Type = "string", Nilable = false },
				{ Name = "isExhausting", Type = "bool", Nilable = false },
				{ Name = "enemies", Type = "table", InnerType = "GarrisonEnemyEncounterInfo", Nilable = false },
			},
		},
		{
			Name = "MissionEncounterIconInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "portraitFileDataID", Type = "number", Nilable = false },
				{ Name = "missionScalar", Type = "number", Nilable = false },
				{ Name = "isElite", Type = "bool", Nilable = false },
				{ Name = "isRare", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GarrisonInfo);