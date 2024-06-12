local PvpInfo =
{
	Name = "PvpInfo",
	Type = "System",
	Namespace = "C_PvP",

	Functions =
	{
		{
			Name = "ArePvpTalentsUnlocked",
			Type = "Function",

			Returns =
			{
				{ Name = "arePvpTalentsUnlocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanDisplayDamage",
			Type = "Function",

			Returns =
			{
				{ Name = "canDisplay", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanDisplayDeaths",
			Type = "Function",

			Returns =
			{
				{ Name = "canDisplay", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanDisplayHealing",
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
			Name = "CanDisplayKillingBlows",
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
				{ Name = "seconds", Type = "time_t", Nilable = false },
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
				{ Name = "playerToken", Type = "UnitToken", Nilable = false },
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
				{ Name = "roleShortageBonus", Type = "RoleShortageReward", Nilable = true },
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
				{ Name = "roleShortageBonus", Type = "RoleShortageReward", Nilable = true },
			},
		},
		{
			Name = "GetAssignedSpecForBattlefieldQueue",
			Type = "Function",

			Arguments =
			{
				{ Name = "queueID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "specializationID", Type = "number", Nilable = true },
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
			Name = "GetBattlefieldFlagPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "flagIndex", Type = "luaIndex", Nilable = false },
				{ Name = "uiMapId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiPosx", Type = "number", Nilable = true },
				{ Name = "uiPosy", Type = "number", Nilable = true },
				{ Name = "flagTexture", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetBattlefieldVehicleInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "vehicleIndex", Type = "luaIndex", Nilable = false },
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
				{ Name = "roleShortageBonus", Type = "RoleShortageReward", Nilable = true },
				{ Name = "hasWon", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetBrawlSoloRBGMinItemLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "minItemLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCustomVictoryStatID",
			Type = "Function",

			Returns =
			{
				{ Name = "statID", Type = "number", Nilable = false },
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
				{ Name = "pvpWaitTime", Type = "time_t", Nilable = false },
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
			Name = "GetPVPActiveRatedMatchDeserterPenalty",
			Type = "Function",

			Returns =
			{
				{ Name = "deserterPenalty", Type = "RatedMatchDeserterPenalty", Nilable = true },
			},
		},
		{
			Name = "GetPVPSeasonRewardAchievementID",
			Type = "Function",

			Returns =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPersonalRatedBGBlitzSpecStats",
			Type = "Function",

			Returns =
			{
				{ Name = "specStats", Type = "RatedBGBlitzSpecStats", Nilable = true },
			},
		},
		{
			Name = "GetPersonalRatedSoloShuffleSpecStats",
			Type = "Function",

			Returns =
			{
				{ Name = "specStats", Type = "RatedSoloShuffleSpecStats", Nilable = true },
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
			Name = "GetPvpTalentsUnlockedLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "unlockLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPvpTierID",
			Type = "Function",

			Arguments =
			{
				{ Name = "tierEnum", Type = "number", Nilable = false },
				{ Name = "bracketEnum", Type = "luaIndex", Nilable = false },
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
				{ Name = "roleShortageBonus", Type = "RoleShortageReward", Nilable = true },
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
				{ Name = "roleShortageBonus", Type = "RoleShortageReward", Nilable = true },
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
				{ Name = "roleShortageBonus", Type = "RoleShortageReward", Nilable = true },
			},
		},
		{
			Name = "GetRatedSoloRBGMinItemLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "minItemLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRatedSoloRBGRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "itemRewards", Type = "table", InnerType = "BattlefieldItemReward", Nilable = true },
				{ Name = "currencyRewards", Type = "table", InnerType = "BattlefieldCurrencyReward", Nilable = true },
				{ Name = "roleShortageBonus", Type = "RoleShortageReward", Nilable = true },
			},
		},
		{
			Name = "GetRatedSoloShuffleMinItemLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "minItemLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRatedSoloShuffleRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "itemRewards", Type = "table", InnerType = "BattlefieldItemReward", Nilable = true },
				{ Name = "currencyRewards", Type = "table", InnerType = "BattlefieldCurrencyReward", Nilable = true },
				{ Name = "roleShortageBonus", Type = "RoleShortageReward", Nilable = true },
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
				{ Name = "offsetIndex", Type = "luaIndex", Nilable = false },
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
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
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
			Name = "GetSpecialEventBrawlInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "brawlInfo", Type = "PvpBrawlInfo", Nilable = true },
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
			Name = "GetUIDisplaySeason",
			Type = "Function",

			Returns =
			{
				{ Name = "uiDisplaySeason", Type = "number", Nilable = false },
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
			Name = "GetZonePVPInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "pvpType", Type = "cstring", Nilable = false },
				{ Name = "isSubZonePvP", Type = "bool", Nilable = false },
				{ Name = "factionName", Type = "cstring", Nilable = true },
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
			Name = "IsBrawlSoloRBG",
			Type = "Function",

			Returns =
			{
				{ Name = "isBrawlSoloRBG", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsBrawlSoloShuffle",
			Type = "Function",

			Returns =
			{
				{ Name = "isBrawlSoloShuffle", Type = "bool", Nilable = false },
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
			Name = "IsInRatedMatchWithDeserterPenalty",
			Type = "Function",

			Returns =
			{
				{ Name = "isInRatedMatchWithDeserterPenalty", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMatchActive",
			Type = "Function",

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMatchComplete",
			Type = "Function",

			Returns =
			{
				{ Name = "isComplete", Type = "bool", Nilable = false },
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
			Name = "IsRatedSoloRBG",
			Type = "Function",

			Returns =
			{
				{ Name = "isRatedSoloRBG", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRatedSoloShuffle",
			Type = "Function",

			Returns =
			{
				{ Name = "isRatedSoloShuffle", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSoloRBG",
			Type = "Function",

			Returns =
			{
				{ Name = "isSoloRBG", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSoloShuffle",
			Type = "Function",

			Returns =
			{
				{ Name = "isSoloShuffle", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSubZonePVPPOI",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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

			Arguments =
			{
				{ Name = "isSpecialBrawl", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "JoinRatedBGBlitz",
			Type = "Function",
		},
		{
			Name = "RequestCrowdControlSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerToken", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "SetPVP",
			Type = "Function",

			Arguments =
			{
				{ Name = "enablePVP", Type = "bool", Nilable = false, Default = false },
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
			Name = "StartSoloRBGWarGameByName",
			Type = "Function",

			Arguments =
			{
				{ Name = "args", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "number", Nilable = false },
			},
		},
		{
			Name = "StartSpectatorSoloRBGWarGame",
			Type = "Function",

			Arguments =
			{
				{ Name = "opaqueID1", Type = "number", Nilable = false },
				{ Name = "opaqueID2", Type = "number", Nilable = false },
				{ Name = "specifiedMap", Type = "cstring", Nilable = false },
				{ Name = "tournamentRules", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TogglePVP",
			Type = "Function",
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
				{ Name = "unitToken", Type = "cstring", Nilable = false },
				{ Name = "updateReason", Type = "cstring", Nilable = false },
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
			Name = "BattlefieldAutoQueue",
			Type = "Event",
			LiteralName = "BATTLEFIELD_AUTO_QUEUE",
		},
		{
			Name = "BattlefieldAutoQueueEject",
			Type = "Event",
			LiteralName = "BATTLEFIELD_AUTO_QUEUE_EJECT",
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
				{ Name = "offender", Type = "cstring", Nilable = false },
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
			Name = "PlayerJoinedPvpMatch",
			Type = "Event",
			LiteralName = "PLAYER_JOINED_PVP_MATCH",
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
				{ Name = "duration", Type = "time_t", Nilable = false },
			},
		},
		{
			Name = "PvpMatchInactive",
			Type = "Event",
			LiteralName = "PVP_MATCH_INACTIVE",
		},
		{
			Name = "PvpMatchStateChanged",
			Type = "Event",
			LiteralName = "PVP_MATCH_STATE_CHANGED",
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
			Name = "PvpRolePopupHide",
			Type = "Event",
			LiteralName = "PVP_ROLE_POPUP_HIDE",
			Payload =
			{
				{ Name = "readyCheckInfo", Type = "PvpReadyCheckInfo", Nilable = true },
			},
		},
		{
			Name = "PvpRolePopupShow",
			Type = "Event",
			LiteralName = "PVP_ROLE_POPUP_SHOW",
			Payload =
			{
				{ Name = "readyCheckInfo", Type = "PvpReadyCheckInfo", Nilable = false },
			},
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
				{ Name = "ratedSoloShuffle", Type = "bool", Nilable = false },
				{ Name = "ratedBGBlitz", Type = "bool", Nilable = false },
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
			Name = "WargameInviteSent",
			Type = "Event",
			LiteralName = "WARGAME_INVITE_SENT",
		},
		{
			Name = "WargameRequestResponse",
			Type = "Event",
			LiteralName = "WARGAME_REQUEST_RESPONSE",
			Payload =
			{
				{ Name = "responderGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "responderName", Type = "cstring", Nilable = true },
				{ Name = "accepted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "WargameRequested",
			Type = "Event",
			LiteralName = "WARGAME_REQUESTED",
			Payload =
			{
				{ Name = "opposingPartyMemberName", Type = "cstring", Nilable = false },
				{ Name = "battlegroundName", Type = "cstring", Nilable = false },
				{ Name = "timeoutSeconds", Type = "time_t", Nilable = false },
				{ Name = "tournamentRules", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "WorldPvpQueue",
			Type = "Event",
			LiteralName = "WORLD_PVP_QUEUE",
		},
	},

	Tables =
	{
		{
			Name = "BrawlType",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "None", Type = "BrawlType", EnumValue = 0 },
				{ Name = "Battleground", Type = "BrawlType", EnumValue = 1 },
				{ Name = "Arena", Type = "BrawlType", EnumValue = 2 },
				{ Name = "LFG", Type = "BrawlType", EnumValue = 3 },
				{ Name = "SoloShuffle", Type = "BrawlType", EnumValue = 4 },
				{ Name = "SoloRbg", Type = "BrawlType", EnumValue = 5 },
			},
		},
		{
			Name = "PvPMatchState",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Inactive", Type = "PvPMatchState", EnumValue = 0 },
				{ Name = "Waiting", Type = "PvPMatchState", EnumValue = 1 },
				{ Name = "StartUp", Type = "PvPMatchState", EnumValue = 2 },
				{ Name = "Engaged", Type = "PvPMatchState", EnumValue = 3 },
				{ Name = "PostRound", Type = "PvPMatchState", EnumValue = 4 },
				{ Name = "Complete", Type = "PvPMatchState", EnumValue = 5 },
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
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "texture", Type = "fileID", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BattlefieldRewards",
			Type = "Structure",
			Fields =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "itemRewards", Type = "table", InnerType = "BattlefieldItemReward", Nilable = true },
				{ Name = "currencyRewards", Type = "table", InnerType = "BattlefieldCurrencyReward", Nilable = true },
				{ Name = "roleShortageBonus", Type = "RoleShortageReward", Nilable = true },
			},
		},
		{
			Name = "BattlefieldVehicleInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "isOccupied", Type = "bool", Nilable = false },
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
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
				{ Name = "icon", Type = "fileID", Nilable = false },
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
				{ Name = "badgeFileDataID", Type = "fileID", Nilable = false },
				{ Name = "achievementRewardedID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LevelUpBattlegroundInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
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
				{ Name = "tooltipTitle", Type = "string", Nilable = false },
				{ Name = "tooltip", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PvpBrawlInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "brawlID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "shortDescription", Type = "string", Nilable = false },
				{ Name = "longDescription", Type = "string", Nilable = false },
				{ Name = "canQueue", Type = "bool", Nilable = false },
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "groupsAllowed", Type = "bool", Nilable = false },
				{ Name = "timeLeftUntilNextChange", Type = "number", Nilable = true },
				{ Name = "brawlType", Type = "BrawlType", Nilable = false },
				{ Name = "mapNames", Type = "table", InnerType = "string", Nilable = false },
				{ Name = "includesAllArenas", Type = "bool", Nilable = false, Default = false },
				{ Name = "minItemLevel", Type = "number", Nilable = false, Default = 0 },
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
				{ Name = "roundsSeasonPlayed", Type = "number", Nilable = false },
				{ Name = "roundsSeasonWon", Type = "number", Nilable = false },
				{ Name = "roundsWeeklyPlayed", Type = "number", Nilable = false },
				{ Name = "roundsWeeklyWon", Type = "number", Nilable = false },
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
			Name = "PvpReadyCheckInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "roles", Type = "table", InnerType = "PvpRoleQueueInfo", Nilable = false },
				{ Name = "numPlayersAccepted", Type = "number", Nilable = false },
				{ Name = "numPlayersDeclined", Type = "number", Nilable = false },
				{ Name = "totalNumPlayers", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PvpRoleQueueInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "role", Type = "cstring", Nilable = false },
				{ Name = "totalRole", Type = "number", Nilable = false },
				{ Name = "totalAccepted", Type = "number", Nilable = false },
				{ Name = "totalDeclined", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PvpScalingData",
			Type = "Structure",
			Fields =
			{
				{ Name = "scalingDataID", Type = "number", Nilable = false },
				{ Name = "specializationID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PVPScoreInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
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
				{ Name = "postmatchMMR", Type = "number", Nilable = false },
				{ Name = "talentSpec", Type = "string", Nilable = false },
				{ Name = "honorLevel", Type = "number", Nilable = false },
				{ Name = "roleAssigned", Type = "number", Nilable = false },
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
				{ Name = "tierIconID", Type = "fileID", Nilable = false },
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
			Name = "RatedBGBlitzSpecStats",
			Type = "Structure",
			Fields =
			{
				{ Name = "weeklyMostPlayedSpecID", Type = "number", Nilable = false },
				{ Name = "weeklyMostPlayedSpecGames", Type = "number", Nilable = false },
				{ Name = "seasonMostPlayedSpecID", Type = "number", Nilable = false },
				{ Name = "seasonMostPlayedSpecGames", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RatedMatchDeserterPenalty",
			Type = "Structure",
			Fields =
			{
				{ Name = "personalRatingChange", Type = "number", Nilable = false },
				{ Name = "queuePenaltySpellID", Type = "number", Nilable = false },
				{ Name = "queuePenaltyDuration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RatedSoloShuffleSpecStats",
			Type = "Structure",
			Fields =
			{
				{ Name = "weeklyMostPlayedSpecID", Type = "number", Nilable = false },
				{ Name = "weeklyMostPlayedSpecRounds", Type = "number", Nilable = false },
				{ Name = "seasonMostPlayedSpecID", Type = "number", Nilable = false },
				{ Name = "seasonMostPlayedSpecRounds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RoleShortageReward",
			Type = "Structure",
			Fields =
			{
				{ Name = "validRoles", Type = "table", InnerType = "cstring", Nilable = false },
				{ Name = "rewardSpellID", Type = "number", Nilable = false },
				{ Name = "rewardItemID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PvpInfo);