local ReputationInfo =
{
	Name = "ReputationInfo",
	Type = "System",
	Namespace = "C_Reputation",

	Functions =
	{
		{
			Name = "AreLegacyReputationsShown",
			Type = "Function",

			Returns =
			{
				{ Name = "areLegacyReputationsShown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CollapseAllFactionHeaders",
			Type = "Function",
		},
		{
			Name = "CollapseFactionHeader",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionSortIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "ExpandAllFactionHeaders",
			Type = "Function",
		},
		{
			Name = "ExpandFactionHeader",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionSortIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetFactionDataByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "factionData", Type = "FactionData", Nilable = true },
			},
		},
		{
			Name = "GetFactionDataByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionSortIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "factionData", Type = "FactionData", Nilable = true },
			},
		},
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
			Name = "GetGuildRepExpirationTime",
			Type = "Function",

			Returns =
			{
				{ Name = "expirationTime", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetNumFactions",
			Type = "Function",

			Returns =
			{
				{ Name = "numFactions", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetReputationSortType",
			Type = "Function",

			Returns =
			{
				{ Name = "sortType", Type = "ReputationSortType", Nilable = false },
			},
		},
		{
			Name = "GetSelectedFaction",
			Type = "Function",

			Returns =
			{
				{ Name = "selectedFactionSortIndex", Type = "luaIndex", Nilable = false },
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
			Name = "IsFactionActive",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionSortIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
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
				{ Name = "hasParagon", Type = "bool", Nilable = false },
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
		{
			Name = "SetFactionActive",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionSortIndex", Type = "luaIndex", Nilable = false },
				{ Name = "setActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetLegacyReputationsShown",
			Type = "Function",

			Arguments =
			{
				{ Name = "showLegacyReputations", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetReputationSortType",
			Type = "Function",

			Arguments =
			{
				{ Name = "sortType", Type = "ReputationSortType", Nilable = false },
			},
		},
		{
			Name = "SetSelectedFaction",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionSortIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SetWatchedFactionByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetWatchedFactionByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionSortIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "ToggleFactionAtWar",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionSortIndex", Type = "luaIndex", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ReputationSortType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "ReputationSortType", EnumValue = 0 },
				{ Name = "Account", Type = "ReputationSortType", EnumValue = 1 },
				{ Name = "Character", Type = "ReputationSortType", EnumValue = 2 },
			},
		},
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
};

APIDocumentation:AddDocumentationTable(ReputationInfo);