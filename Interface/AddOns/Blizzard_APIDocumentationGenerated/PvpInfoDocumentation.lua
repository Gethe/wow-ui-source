local PvpInfo =
{
	Name = "PvpInfo",
	Type = "System",
	Namespace = "C_PvP",
	Environment = "All",

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
			Name = "AreTrainingGroundsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "areTrainingGroundsEnabled", Type = "bool", Nilable = false },
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
			Name = "CanPlayerUseTrainingGroundsUI",
			Type = "Function",

			Returns =
			{
				{ Name = "canUseTrainingGroundsUI", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CanToggleWarMode",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetBattlegroundInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "battlegroundIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "battlegroundInfo", Type = "BattlegroundInfo", Nilable = true },
			},
		},
		{
			Name = "GetBrawlRewards",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetRandomTrainingGroundRewards",
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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetTrainingGrounds",
			Type = "Function",

			Returns =
			{
				{ Name = "trainingGrounds", Type = "table", InnerType = "BattlegroundInfo", Nilable = false },
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
			MayReturnNothing = true,

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
			Name = "HasMatchStarted",
			Type = "Function",
			Documentation = { "Returns true if a match is either active or complete." },

			Returns =
			{
				{ Name = "hasStarted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasRandomTrainingGroundWinToday",
			Type = "Function",

			Returns =
			{
				{ Name = "hasRandomTrainingGroundWinToday", Type = "bool", Nilable = false },
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
			Name = "JoinBattlefield",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "battlemasterListId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "JoinBrawl",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isSpecialBrawl", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "JoinRandomTrainingGround",
			Type = "Function",
		},
		{
			Name = "JoinRatedBGBlitz",
			Type = "Function",
		},
		{
			Name = "JoinTrainingGround",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "trainingGroundID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RequestCrowdControlSpell",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "playerToken", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "SetPVP",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enablePVP", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetWarModeDesired",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "warModeDesired", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "StartSoloRBGWarGameByName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			HasRestrictions = true,
		},
		{
			Name = "ToggleWarMode",
			Type = "Function",
			HasRestrictions = true,
		},
	},

	Events =
	{
		{
			Name = "ArenaOpponentUpdate",
			Type = "Event",
			LiteralName = "ARENA_OPPONENT_UPDATE",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "ArenaSeasonWorldState",
			Type = "Event",
			LiteralName = "ARENA_SEASON_WORLD_STATE",
			SynchronousEvent = true,
		},
		{
			Name = "BattlefieldAutoQueue",
			Type = "Event",
			LiteralName = "BATTLEFIELD_AUTO_QUEUE",
			SynchronousEvent = true,
		},
		{
			Name = "BattlefieldAutoQueueEject",
			Type = "Event",
			LiteralName = "BATTLEFIELD_AUTO_QUEUE_EJECT",
			SynchronousEvent = true,
		},
		{
			Name = "BattlefieldQueueTimeout",
			Type = "Event",
			LiteralName = "BATTLEFIELD_QUEUE_TIMEOUT",
			SynchronousEvent = true,
		},
		{
			Name = "BattlefieldsClosed",
			Type = "Event",
			LiteralName = "BATTLEFIELDS_CLOSED",
			SynchronousEvent = true,
		},
		{
			Name = "BattlefieldsShow",
			Type = "Event",
			LiteralName = "BATTLEFIELDS_SHOW",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "BattlegroundPointsUpdate",
			Type = "Event",
			LiteralName = "BATTLEGROUND_POINTS_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "GdfSimComplete",
			Type = "Event",
			LiteralName = "GDF_SIM_COMPLETE",
			SynchronousEvent = true,
		},
		{
			Name = "HonorLevelUpdate",
			Type = "Event",
			LiteralName = "HONOR_LEVEL_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isHigherLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "NotifyPvpAfkResult",
			Type = "Event",
			LiteralName = "NOTIFY_PVP_AFK_RESULT",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "PlayerJoinedPvpMatch",
			Type = "Event",
			LiteralName = "PLAYER_JOINED_PVP_MATCH",
			SynchronousEvent = true,
		},
		{
			Name = "PostMatchCurrencyRewardUpdate",
			Type = "Event",
			LiteralName = "POST_MATCH_CURRENCY_REWARD_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "reward", Type = "PVPPostMatchCurrencyReward", Nilable = false },
			},
		},
		{
			Name = "PostMatchItemRewardUpdate",
			Type = "Event",
			LiteralName = "POST_MATCH_ITEM_REWARD_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "PvpBrawlInfoUpdated",
			Type = "Event",
			LiteralName = "PVP_BRAWL_INFO_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "PvpMatchActive",
			Type = "Event",
			LiteralName = "PVP_MATCH_ACTIVE",
			SynchronousEvent = true,
		},
		{
			Name = "PvpMatchComplete",
			Type = "Event",
			LiteralName = "PVP_MATCH_COMPLETE",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "PvpMatchStateChanged",
			Type = "Event",
			LiteralName = "PVP_MATCH_STATE_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "PvpRatedStatsUpdate",
			Type = "Event",
			LiteralName = "PVP_RATED_STATS_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "PvpRewardsUpdate",
			Type = "Event",
			LiteralName = "PVP_REWARDS_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "PvpRolePopupHide",
			Type = "Event",
			LiteralName = "PVP_ROLE_POPUP_HIDE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "readyCheckInfo", Type = "PvpReadyCheckInfo", Nilable = true },
			},
		},
		{
			Name = "PvpRolePopupShow",
			Type = "Event",
			LiteralName = "PVP_ROLE_POPUP_SHOW",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "readyCheckInfo", Type = "PvpReadyCheckInfo", Nilable = false },
			},
		},
		{
			Name = "PvpRoleUpdate",
			Type = "Event",
			LiteralName = "PVP_ROLE_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "PvpSpecialEventInfoUpdated",
			Type = "Event",
			LiteralName = "PVP_SPECIAL_EVENT_INFO_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "PvpTypesEnabled",
			Type = "Event",
			LiteralName = "PVP_TYPES_ENABLED",
			SynchronousEvent = true,
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
			UniqueEvent = true,
		},
		{
			Name = "PvpWorldstateUpdate",
			Type = "Event",
			LiteralName = "PVP_WORLDSTATE_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "PvpqueueAnywhereShow",
			Type = "Event",
			LiteralName = "PVPQUEUE_ANYWHERE_SHOW",
			SynchronousEvent = true,
		},
		{
			Name = "PvpqueueAnywhereUpdateAvailable",
			Type = "Event",
			LiteralName = "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE",
			SynchronousEvent = true,
		},
		{
			Name = "TrainingGroundsEnabledStatusUpdated",
			Type = "Event",
			LiteralName = "TRAINING_GROUNDS_ENABLED_STATUS_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateActiveBattlefield",
			Type = "Event",
			LiteralName = "UPDATE_ACTIVE_BATTLEFIELD",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateBattlefieldScore",
			Type = "Event",
			LiteralName = "UPDATE_BATTLEFIELD_SCORE",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateBattlefieldStatus",
			Type = "Event",
			LiteralName = "UPDATE_BATTLEFIELD_STATUS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "battleFieldIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "WarModeStatusUpdate",
			Type = "Event",
			LiteralName = "WAR_MODE_STATUS_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "warModeEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "WargameInviteSent",
			Type = "Event",
			LiteralName = "WARGAME_INVITE_SENT",
			SynchronousEvent = true,
		},
		{
			Name = "WargameRequestResponse",
			Type = "Event",
			LiteralName = "WARGAME_REQUEST_RESPONSE",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
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
			SynchronousEvent = true,
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
			Name = "BattlegroundInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = true },
				{ Name = "gameType", Type = "cstring", Nilable = false },
				{ Name = "shortDescription", Type = "cstring", Nilable = false },
				{ Name = "longDescription", Type = "cstring", Nilable = false },
				{ Name = "mapDescription", Type = "cstring", Nilable = false },
				{ Name = "maxPlayers", Type = "number", Nilable = false },
				{ Name = "battlegroundID", Type = "number", Nilable = true },
				{ Name = "lfgDungeonID", Type = "number", Nilable = true },
				{ Name = "mapID", Type = "number", Nilable = true },
				{ Name = "isHoliday", Type = "bool", Nilable = false },
				{ Name = "isRandom", Type = "bool", Nilable = false },
				{ Name = "canEnter", Type = "bool", Nilable = false },
				{ Name = "isTrainingGround", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "BattlemasterListInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "matchmakingType", Type = "PvPMatchmakingType", Nilable = false },
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
				{ Name = "crossFactionAllowed", Type = "bool", Nilable = false, Default = false },
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
				{ Name = "bgIndex", Type = "luaIndex", Nilable = false },
				{ Name = "hasRandomWinToday", Type = "bool", Nilable = false },
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
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
		{
			Name = "WorldPVPBattlegroundInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "bgID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "isActive", Type = "bool", Nilable = false },
				{ Name = "canQueue", Type = "bool", Nilable = false },
				{ Name = "canEnter", Type = "bool", Nilable = false },
				{ Name = "startTime", Type = "time_t", Nilable = false },
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PvpInfo);