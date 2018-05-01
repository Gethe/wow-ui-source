local GarrisonInfo =
{
	Name = "GarrisonInfo",
	Type = "System",
	Namespace = "C_Garrison",

	Functions =
	{
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
				{ Name = "texturePrefix", Type = "string", Nilable = false },
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
			},
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
			Name = "GarrisonFollowerDeathInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "followerID", Type = "string", Nilable = false },
				{ Name = "state", Type = "number", Nilable = false },
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
	},
};

APIDocumentation:AddDocumentationTable(GarrisonInfo);