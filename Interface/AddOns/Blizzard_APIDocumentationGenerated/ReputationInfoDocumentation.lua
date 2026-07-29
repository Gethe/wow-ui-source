local ReputationInfo =
{
	Name = "ReputationInfo",
	Type = "System",
	Namespace = "C_Reputation",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetFactionParagonInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "currentValue", Type = "number", Nilable = false },
				{ Name = "threshold", Type = "number", Nilable = false },
				{ Name = "rewardQuestID", Type = "number", Nilable = false },
				{ Name = "hasRewardPending", Type = "bool", Nilable = false },
				{ Name = "tooLowLevelForParagon", Type = "bool", Nilable = false },
				{ Name = "paragonStorageLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetGuildFactionData",
			Type = "Function",

			Returns =
			{
				{ Name = "guildFactionData", Type = "FactionData", Nilable = true },
			},
		},
		{
			Name = "GetWatchedFactionData",
			Type = "Function",

			Returns =
			{
				{ Name = "watchedFactionData", Type = "FactionData", Nilable = true },
			},
		},
		{
			Name = "IsAccountWideReputation",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAccountWide", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFactionParagon",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "factionIsParagon", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFactionParagonForCurrentPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "currentPlayerHasParagon", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMajorFaction",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isMajorFaction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestFactionParagonPreloadRewardData",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "FactionStandingChanged",
			Type = "Event",
			LiteralName = "FACTION_STANDING_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
				{ Name = "updatedStanding", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "FactionData",
			Type = "Structure",
			Fields =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "reaction", Type = "luaIndex", Nilable = false },
				{ Name = "currentReactionThreshold", Type = "number", Nilable = false },
				{ Name = "nextReactionThreshold", Type = "number", Nilable = false },
				{ Name = "currentStanding", Type = "number", Nilable = false },
				{ Name = "atWarWith", Type = "bool", Nilable = false },
				{ Name = "canToggleAtWar", Type = "bool", Nilable = false },
				{ Name = "isChild", Type = "bool", Nilable = false },
				{ Name = "isHeader", Type = "bool", Nilable = false },
				{ Name = "isHeaderWithRep", Type = "bool", Nilable = false },
				{ Name = "isCollapsed", Type = "bool", Nilable = false },
				{ Name = "isWatched", Type = "bool", Nilable = false },
				{ Name = "hasBonusRepGain", Type = "bool", Nilable = false },
				{ Name = "canSetInactive", Type = "bool", Nilable = false },
				{ Name = "isAccountWide", Type = "bool", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(ReputationInfo);