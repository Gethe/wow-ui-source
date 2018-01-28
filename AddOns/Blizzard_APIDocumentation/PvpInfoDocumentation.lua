local PvpInfo =
{
	Name = "PvpInfo",
	Type = "System",
	Namespace = "C_PvP",

	Functions =
	{
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
				{ Name = "rewards", Type = "table", InnerType = "BattlefieldReward", Nilable = true },
			},
		},
		{
			Name = "GetArenaSkirmishRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "BattlefieldReward", Nilable = true },
			},
		},
		{
			Name = "GetBrawlInfo",
			Type = "Function",
			Documentation = { "If nil is returned, PVP_BRAWL_INFO_UPDATED event will be sent when the data is ready." },

			Returns =
			{
				{ Name = "brawlInfo", Type = "PvpBrawlInfo", Nilable = true },
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
				{ Name = "rewards", Type = "table", InnerType = "BattlefieldReward", Nilable = true },
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
			Name = "GetRandomBGRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "BattlefieldReward", Nilable = true },
			},
		},
		{
			Name = "GetRatedBGRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "honor", Type = "number", Nilable = false },
				{ Name = "experience", Type = "number", Nilable = false },
				{ Name = "rewards", Type = "table", InnerType = "BattlefieldReward", Nilable = true },
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
			Name = "HasArenaSkirmishWinToday",
			Type = "Function",

			Returns =
			{
				{ Name = "hasArenaSkirmishWinToday", Type = "bool", Nilable = false },
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
	},

	Events =
	{
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
			Name = "PrestigeAndHonorInvoluntarilyChanged",
			Type = "Event",
			LiteralName = "PRESTIGE_AND_HONOR_INVOLUNTARILY_CHANGED",
		},
		{
			Name = "PvpqueueAnywhereUpdateAvailable",
			Type = "Event",
			LiteralName = "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE",
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
			Name = "BattlefieldReward",
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
			Name = "PvpBrawlInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "shortDescription", Type = "string", Nilable = false },
				{ Name = "longDescription", Type = "string", Nilable = false },
				{ Name = "active", Type = "bool", Nilable = false },
				{ Name = "timeLeftUntilNextChange", Type = "number", Nilable = false },
				{ Name = "lfgDungeonID", Type = "number", Nilable = false },
				{ Name = "brawlType", Type = "BrawlType", Nilable = false },
				{ Name = "mapNames", Type = "table", InnerType = "string", Nilable = false },
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
	},
};

APIDocumentation:AddDocumentationTable(PvpInfo);