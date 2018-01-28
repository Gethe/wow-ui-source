local BattlefieldInfo =
{
	Name = "BattlefieldInfo",
	Type = "System",
	Namespace = "C_BattlefieldInfo",

	Functions =
	{
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
			Name = "PvpBrawlInfoUpdated",
			Type = "Event",
			LiteralName = "PVP_BRAWL_INFO_UPDATED",
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
	},
};

APIDocumentation:AddDocumentationTable(BattlefieldInfo);