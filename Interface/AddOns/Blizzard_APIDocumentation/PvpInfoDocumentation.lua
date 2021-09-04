local PvpInfo =
{
	Name = "PvpInfo",
	Type = "System",
	Namespace = "C_PvP",

	Functions =
	{
		{
			Name = "CanDisplayDeaths",
			Type = "Function",

			Returns =
			{
				{ Name = "canDisplay", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanDisplayHonorableKills",
			Type = "Function",

			Returns =
			{
				{ Name = "canDisplay", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUseRatedPVPUI",
			Type = "Function",

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CanToggleWarMode",
			Type = "Function",

			Arguments =
			{
				{ Name = "toggle", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "canTogglePvP", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanToggleWarModeInArea",
			Type = "Function",

			Returns =
			{
				{ Name = "canTogglePvPInArea", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DoesMatchOutcomeAffectRating",
			Type = "Function",

			Returns =
			{
				{ Name = "doesAffect", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetActiveBrawlInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "brawlInfo", Type = "PvpBrawlInfo", Nilable = true },
			},
		},
		{
			Name = "GetActiveMatchBracket",
			Type = "Function",

			Returns =
			{
				{ Name = "bracket", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetActiveMatchDuration",
			Type = "Function",

			Returns =
			{
				{ Name = "seconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetActiveMatchState",
			Type = "Function",

			Returns =
			{
				{ Name = "state", Type = "PvPMatchState", Nilable = false },
			},
		},
		{
			Name = "GetActiveMatchWinner",
			Type = "Function",

			Returns =
			{
				{ Name = "winner", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetArenaCrowdControlInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerToken", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetArenaRewards",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamSize", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "itemRewards", Type = "table", InnerType = "BattlefieldItemReward", Nilable = true },
				{ Name = "currencyRewards", Type = "table", InnerType = "BattlefieldCurrencyReward", Nilable = true },
			},
		},
		{
			Name = "GetArenaSkirmishRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "itemRewards", Type = "table", InnerType = "BattlefieldItemReward", Nilable = true },
				{ Name = "currencyRewards", Type = "table", InnerType = "BattlefieldCurrencyReward", Nilable = true },
			},
		},
		{
			Name = "GetAvailableBrawlInfo",
			Type = "Function",
			Documentation = { "If nil is returned, PVP_BRAWL_INFO_UPDATED event will be sent when the data is ready." },

			Returns =
			{
				{ Name = "brawlInfo", Type = "PvpBrawlInfo", Nilable = true },
			},
		},
		{
			Name = "GetBattlefieldVehicleInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "vehicleIndex", Type = "number", Nilable = false },
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "BattlefieldVehicleInfo", Nilable = false },
			},
		},
		{
			Name = "GetBattlefieldVehicles",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "vehicles", Type = "table", InnerType = "BattlefieldVehicleInfo", Nilable = false },
			},
		},
		{
			Name = "GetBrawlRewards",
			Type = "Function",

			Arguments =
			{
				{ Name = "brawlType", Type = "BrawlType", Nilable = false },
			},

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "itemRewards", Type = "table", InnerType = "BattlefieldItemReward", Nilable = true },
				{ Name = "currencyRewards", Type = "table", InnerType = "BattlefieldCurrencyReward", Nilable = true },
				{ Name = "hasWon", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetGlobalPvpScalingInfoForSpecID",
			Type = "Function",

			Arguments =
			{
				{ Name = "specializationID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "pvpScalingData", Type = "table", InnerType = "PvpScalingData", Nilable = false },
			},
		},
		{
			Name = "GetHonorRewardInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "honorLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "HonorRewardInfo", Nilable = true },
			},
		},
		{
			Name = "GetLevelUpBattlegrounds",
			Type = "Function",

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "battlefields", Type = "table", InnerType = "LevelUpBattlegroundInfo", Nilable = false },
			},
		},
		{
			Name = "GetMatchPVPStatColumn",
			Type = "Function",

			Arguments =
			{
				{ Name = "pvpStatID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "MatchPVPStatColumn", Nilable = true },
			},
		},
		{
			Name = "GetMatchPVPStatColumns",
			Type = "Function",

			Returns =
			{
				{ Name = "columns", Type = "table", InnerType = "MatchPVPStatColumn", Nilable = false },
			},
		},
		{
			Name = "GetNextHonorLevelForReward",
			Type = "Function",

			Arguments =
			{
				{ Name = "honorLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "nextHonorLevelWithReward", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetOutdoorPvPWaitTime",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "pvpWaitTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPVPActiveMatchPersonalRatedInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "PVPPersonalRatedInfo", Nilable = true },
			},
		},
		{
			Name = "GetPostMatchCurrencyRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "rewards", Type = "table", InnerType = "PVPPostMatchCurrencyReward", Nilable = false },
			},
		},
		{
			Name = "GetPostMatchItemRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "rewards", Type = "table", InnerType = "PVPPostMatchItemReward", Nilable = false },
			},
		},
		{
			Name = "GetPvpTierID",
			Type = "Function",

			Arguments =
			{
				{ Name = "tierEnum", Type = "number", Nilable = false },
				{ Name = "bracketEnum", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "id", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetPvpTierInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "tierID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "pvpTierInfo", Type = "PvpTierInfo", Nilable = true },
			},
		},
		{
			Name = "GetRandomBGInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "RandomBGInfo", Nilable = false },
			},
		},
		{
			Name = "GetRandomBGRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "itemRewards", Type = "table", InnerType = "BattlefieldItemReward", Nilable = true },
				{ Name = "currencyRewards", Type = "table", InnerType = "BattlefieldCurrencyReward", Nilable = true },
			},
		},
		{
			Name = "GetRandomEpicBGInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "RandomBGInfo", Nilable = false },
			},
		},
		{
			Name = "GetRandomEpicBGRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "itemRewards", Type = "table", InnerType = "BattlefieldItemReward", Nilable = true },
				{ Name = "currencyRewards", Type = "table", InnerType = "BattlefieldCurrencyReward", Nilable = true },
			},
		},
		{
			Name = "GetRatedBGRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "itemRewards", Type = "table", InnerType = "BattlefieldItemReward", Nilable = true },
				{ Name = "currencyRewards", Type = "table", InnerType = "BattlefieldCurrencyReward", Nilable = true },
			},
		},
		{
			Name = "GetRewardItemLevelsByTierEnum",
			Type = "Function",

			Arguments =
			{
				{ Name = "pvpTierEnum", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "activityItemLevel", Type = "number", Nilable = false },
				{ Name = "weeklyItemLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScoreInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "offsetIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "PVPScoreInfo", Nilable = true },
			},
		},
		{
			Name = "GetScoreInfoByPlayerGuid",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "PVPScoreInfo", Nilable = true },
			},
		},
		{
			Name = "GetSeasonBestInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "tierID", Type = "number", Nilable = false },
				{ Name = "nextTierID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSkirmishInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "pvpBracket", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "battlemasterListInfo", Type = "BattlemasterListInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpecialEventDetails",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "SpecialEventDetails", Nilable = true },
			},
		},
		{
			Name = "GetSpecialEventInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "RandomBGInfo", Nilable = false },
			},
		},
		{
			Name = "GetTeamInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "PVPTeamInfo", Nilable = true },
			},
		},
		{
			Name = "GetWarModeRewardBonus",
			Type = "Function",

			Returns =
			{
				{ Name = "rewardBonus", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetWarModeRewardBonusDefault",
			Type = "Function",

			Returns =
			{
				{ Name = "defaultBonus", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetWeeklyChestInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "rewardAchieved", Type = "bool", Nilable = false },
				{ Name = "lastWeekRewardAchieved", Type = "bool", Nilable = false },
				{ Name = "lastWeekRewardClaimed", Type = "bool", Nilable = false },
				{ Name = "pvpTierMaxFromWins", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasArenaSkirmishWinToday",
			Type = "Function",

			Returns =
			{
				{ Name = "hasArenaSkirmishWinToday", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsActiveBattlefield",
			Type = "Function",

			Returns =
			{
				{ Name = "isActiveBattlefield", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsActiveMatchRegistered",
			Type = "Function",

			Returns =
			{
				{ Name = "registered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsArena",
			Type = "Function",

			Returns =
			{
				{ Name = "isArena", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsBattleground",
			Type = "Function",

			Returns =
			{
				{ Name = "isBattleground", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsBattlegroundEnlistmentBonusActive",
			Type = "Function",

			Returns =
			{
				{ Name = "battlegroundActive", Type = "bool", Nilable = false },
				{ Name = "brawlActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInBrawl",
			Type = "Function",

			Returns =
			{
				{ Name = "isInBrawl", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMatchConsideredArena",
			Type = "Function",

			Returns =
			{
				{ Name = "asArena", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMatchFactional",
			Type = "Function",

			Returns =
			{
				{ Name = "isFactional", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPVPMap",
			Type = "Function",

			Returns =
			{
				{ Name = "isPVPMap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRatedArena",
			Type = "Function",

			Returns =
			{
				{ Name = "isRatedArena", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRatedBattleground",
			Type = "Function",

			Returns =
			{
				{ Name = "isRatedBattleground", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRatedMap",
			Type = "Function",

			Returns =
			{
				{ Name = "isRatedMap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsWarModeActive",
			Type = "Function",

			Returns =
			{
				{ Name = "warModeActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsWarModeDesired",
			Type = "Function",

			Returns =
			{
				{ Name = "warModeDesired", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsWarModeFeatureEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "warModeEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "JoinBrawl",
			Type = "Function",
		},
		{
			Name = "RequestCrowdControlSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerToken", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetWarModeDesired",
			Type = "Function",

			Arguments =
			{
				{ Name = "warModeDesired", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ToggleWarMode",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "ArenaOpponentUpdate",
			Type = "Event",
			LiteralName = "ARENA_OPPONENT_UPDATE",
			Payload =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "updateReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ArenaPrepOpponentSpecializations",
			Type = "Event",
			LiteralName = "ARENA_PREP_OPPONENT_SPECIALIZATIONS",
		},
		{
			Name = "ArenaSeasonWorldState",
			Type = "Event",
			LiteralName = "ARENA_SEASON_WORLD_STATE",
		},
		{
			Name = "BattlefieldQueueTimeout",
			Type = "Event",
			LiteralName = "BATTLEFIELD_QUEUE_TIMEOUT",
		},
		{
			Name = "BattlefieldsClosed",
			Type = "Event",
			LiteralName = "BATTLEFIELDS_CLOSED",
		},
		{
			Name = "BattlefieldsShow",
			Type = "Event",
			LiteralName = "BATTLEFIELDS_SHOW",
			Payload =
			{
				{ Name = "isArena", Type = "bool", Nilable = true },
				{ Name = "battleMasterListID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "BattlegroundObjectivesUpdate",
			Type = "Event",
			LiteralName = "BATTLEGROUND_OBJECTIVES_UPDATE",
		},
		{
			Name = "BattlegroundPointsUpdate",
			Type = "Event",
			LiteralName = "BATTLEGROUND_POINTS_UPDATE",
		},
		{
			Name = "GdfSimComplete",
			Type = "Event",
			LiteralName = "GDF_SIM_COMPLETE",
		},
		{
			Name = "HonorLevelUpdate",
			Type = "Event",
			LiteralName = "HONOR_LEVEL_UPDATE",
			Payload =
			{
				{ Name = "isHigherLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "NotifyPvpAfkResult",
			Type = "Event",
			LiteralName = "NOTIFY_PVP_AFK_RESULT",
			Payload =
			{
				{ Name = "offender", Type = "string", Nilable = false },
				{ Name = "numBlackMarksOnOffender", Type = "number", Nilable = false },
				{ Name = "numPlayersIHaveReported", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerEnteringBattleground",
			Type = "Event",
			LiteralName = "PLAYER_ENTERING_BATTLEGROUND",
		},
		{
			Name = "PostMatchCurrencyRewardUpdate",
			Type = "Event",
			LiteralName = "POST_MATCH_CURRENCY_REWARD_UPDATE",
			Payload =
			{
				{ Name = "reward", Type = "PVPPostMatchCurrencyReward", Nilable = false },
			},
		},
		{
			Name = "PostMatchItemRewardUpdate",
			Type = "Event",
			LiteralName = "POST_MATCH_ITEM_REWARD_UPDATE",
		},
		{
			Name = "PvpBrawlInfoUpdated",
			Type = "Event",
			LiteralName = "PVP_BRAWL_INFO_UPDATED",
		},
		{
			Name = "PvpMatchActive",
			Type = "Event",
			LiteralName = "PVP_MATCH_ACTIVE",
		},
		{
			Name = "PvpMatchComplete",
			Type = "Event",
			LiteralName = "PVP_MATCH_COMPLETE",
			Payload =
			{
				{ Name = "winner", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PvpMatchInactive",
			Type = "Event",
			LiteralName = "PVP_MATCH_INACTIVE",
		},
		{
			Name = "PvpRatedStatsUpdate",
			Type = "Event",
			LiteralName = "PVP_RATED_STATS_UPDATE",
		},
		{
			Name = "PvpRewardsUpdate",
			Type = "Event",
			LiteralName = "PVP_REWARDS_UPDATE",
		},
		{
			Name = "PvpRoleUpdate",
			Type = "Event",
			LiteralName = "PVP_ROLE_UPDATE",
		},
		{
			Name = "PvpSpecialEventInfoUpdated",
			Type = "Event",
			LiteralName = "PVP_SPECIAL_EVENT_INFO_UPDATED",
		},
		{
			Name = "PvpTypesEnabled",
			Type = "Event",
			LiteralName = "PVP_TYPES_ENABLED",
			Payload =
			{
				{ Name = "wargameBattlegrounds", Type = "bool", Nilable = false },
				{ Name = "ratedBattlegrounds", Type = "bool", Nilable = false },
				{ Name = "ratedArenas", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PvpVehicleInfoUpdated",
			Type = "Event",
			LiteralName = "PVP_VEHICLE_INFO_UPDATED",
		},
		{
			Name = "PvpWorldstateUpdate",
			Type = "Event",
			LiteralName = "PVP_WORLDSTATE_UPDATE",
		},
		{
			Name = "PvpqueueAnywhereShow",
			Type = "Event",
			LiteralName = "PVPQUEUE_ANYWHERE_SHOW",
		},
		{
			Name = "PvpqueueAnywhereUpdateAvailable",
			Type = "Event",
			LiteralName = "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE",
		},
		{
			Name = "UpdateActiveBattlefield",
			Type = "Event",
			LiteralName = "UPDATE_ACTIVE_BATTLEFIELD",
		},
		{
			Name = "UpdateBattlefieldScore",
			Type = "Event",
			LiteralName = "UPDATE_BATTLEFIELD_SCORE",
		},
		{
			Name = "UpdateBattlefieldStatus",
			Type = "Event",
			LiteralName = "UPDATE_BATTLEFIELD_STATUS",
			Payload =
			{
				{ Name = "battleFieldIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "WarModeStatusUpdate",
			Type = "Event",
			LiteralName = "WAR_MODE_STATUS_UPDATE",
			Payload =
			{
				{ Name = "warModeEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "WargameRequested",
			Type = "Event",
			LiteralName = "WARGAME_REQUESTED",
			Payload =
			{
				{ Name = "opposingPartyMemberName", Type = "string", Nilable = false },
				{ Name = "battlegroundName", Type = "string", Nilable = false },
				{ Name = "timeoutSeconds", Type = "number", Nilable = false },
				{ Name = "tournamentRules", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "BrawlType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "BrawlType", EnumValue = 0 },
				{ Name = "Battleground", Type = "BrawlType", EnumValue = 1 },
				{ Name = "Arena", Type = "BrawlType", EnumValue = 2 },
				{ Name = "Lfg", Type = "BrawlType", EnumValue = 3 },
			},
		},
		{
			Name = "PvPMatchState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Inactive", Type = "PvPMatchState", EnumValue = 0 },
				{ Name = "Active", Type = "PvPMatchState", EnumValue = 1 },
				{ Name = "Complete", Type = "PvPMatchState", EnumValue = 2 },
			},
		},
		{
			Name = "BattlefieldCurrencyReward",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BattlefieldItemReward",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "texture", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BattlefieldVehicleInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "isOccupied", Type = "bool", Nilable = false },
				{ Name = "atlas", Type = "string", Nilable = false },
				{ Name = "textureWidth", Type = "number", Nilable = false },
				{ Name = "textureHeight", Type = "number", Nilable = false },
				{ Name = "facing", Type = "number", Nilable = false },
				{ Name = "isPlayer", Type = "bool", Nilable = false },
				{ Name = "isAlive", Type = "bool", Nilable = false },
				{ Name = "shouldDrawBelowPlayerBlips", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "BattlemasterListInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "instanceType", Type = "number", Nilable = false },
				{ Name = "minPlayers", Type = "number", Nilable = false },
				{ Name = "maxPlayers", Type = "number", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "longDescription", Type = "string", Nilable = false },
				{ Name = "shortDescription", Type = "string", Nilable = false },
			},
		},
		{
			Name = "HonorRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "honorLevelName", Type = "string", Nilable = false },
				{ Name = "badgeFileDataID", Type = "number", Nilable = false },
				{ Name = "achievementRewardedID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LevelUpBattlegroundInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "isEpic", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MatchPVPStatColumn",
			Type = "Structure",
			Fields =
			{
				{ Name = "pvpStatID", Type = "number", Nilable = false },
				{ Name = "columnHeaderID", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PvpBrawlInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "shortDescription", Type = "string", Nilable = false },
				{ Name = "longDescription", Type = "string", Nilable = false },
				{ Name = "canQueue", Type = "bool", Nilable = false },
				{ Name = "timeLeftUntilNextChange", Type = "number", Nilable = false },
				{ Name = "brawlType", Type = "BrawlType", Nilable = false },
				{ Name = "mapNames", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "PVPPersonalRatedInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "personalRating", Type = "number", Nilable = false },
				{ Name = "bestSeasonRating", Type = "number", Nilable = false },
				{ Name = "bestWeeklyRating", Type = "number", Nilable = false },
				{ Name = "seasonPlayed", Type = "number", Nilable = false },
				{ Name = "seasonWon", Type = "number", Nilable = false },
				{ Name = "weeklyPlayed", Type = "number", Nilable = false },
				{ Name = "weeklyWon", Type = "number", Nilable = false },
				{ Name = "lastWeeksBestRating", Type = "number", Nilable = false },
				{ Name = "hasWonBracketToday", Type = "bool", Nilable = false },
				{ Name = "tier", Type = "number", Nilable = false },
				{ Name = "ranking", Type = "number", Nilable = true },
			},
		},
		{
			Name = "PVPPostMatchCurrencyReward",
			Type = "Structure",
			Fields =
			{
				{ Name = "currencyType", Type = "number", Nilable = false },
				{ Name = "quantityChanged", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PVPPostMatchItemReward",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "link", Type = "string", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "sex", Type = "number", Nilable = false },
				{ Name = "isUpgraded", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PvpScalingData",
			Type = "Structure",
			Fields =
			{
				{ Name = "scalingDataID", Type = "number", Nilable = false },
				{ Name = "specializationID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PVPScoreInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "guid", Type = "string", Nilable = false },
				{ Name = "killingBlows", Type = "number", Nilable = false },
				{ Name = "honorableKills", Type = "number", Nilable = false },
				{ Name = "deaths", Type = "number", Nilable = false },
				{ Name = "honorGained", Type = "number", Nilable = false },
				{ Name = "faction", Type = "number", Nilable = false },
				{ Name = "raceName", Type = "string", Nilable = false },
				{ Name = "className", Type = "string", Nilable = false },
				{ Name = "classToken", Type = "string", Nilable = false },
				{ Name = "damageDone", Type = "number", Nilable = false },
				{ Name = "healingDone", Type = "number", Nilable = false },
				{ Name = "rating", Type = "number", Nilable = false },
				{ Name = "ratingChange", Type = "number", Nilable = false },
				{ Name = "prematchMMR", Type = "number", Nilable = false },
				{ Name = "mmrChange", Type = "number", Nilable = false },
				{ Name = "talentSpec", Type = "string", Nilable = false },
				{ Name = "honorLevel", Type = "number", Nilable = false },
				{ Name = "stats", Type = "table", InnerType = "PVPStatInfo", Nilable = false },
			},
		},
		{
			Name = "PVPStatInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "pvpStatID", Type = "number", Nilable = false },
				{ Name = "pvpStatValue", Type = "number", Nilable = false },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
				{ Name = "iconName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PVPTeamInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "size", Type = "number", Nilable = false },
				{ Name = "rating", Type = "number", Nilable = false },
				{ Name = "ratingNew", Type = "number", Nilable = false },
				{ Name = "ratingMMR", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PvpTierInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "descendRating", Type = "number", Nilable = false },
				{ Name = "ascendRating", Type = "number", Nilable = false },
				{ Name = "descendTier", Type = "number", Nilable = false },
				{ Name = "ascendTier", Type = "number", Nilable = false },
				{ Name = "pvpTierEnum", Type = "number", Nilable = false },
				{ Name = "tierIconID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RandomBGInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "canQueue", Type = "bool", Nilable = false },
				{ Name = "bgID", Type = "number", Nilable = false },
				{ Name = "hasRandomWinToday", Type = "bool", Nilable = false },
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SpecialEventDetails",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "shortDescription", Type = "string", Nilable = false },
				{ Name = "longDescription", Type = "string", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PvpInfo);