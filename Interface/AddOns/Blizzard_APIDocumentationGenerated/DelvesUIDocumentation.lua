local DelvesUI =
{
	Name = "DelvesUI",
	Type = "System",
	Namespace = "C_DelvesUI",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetCompanionInfoForActivePlayer",
			Type = "Function",

			Returns =
			{
				{ Name = "playerCompanionInfoID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCreatureDisplayInfoForCompanion",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "creatureDisplayInfoID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurioLink",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Given the spell ID for an owned curio and its rarity, return a spell link style hyperlink for the curio spell, since they aren't items when learned" },

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "rarity", Type = "CurioRarity", Nilable = false },
			},

			Returns =
			{
				{ Name = "curioLink", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetCurioNodeForCompanion",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "curioType", Type = "CurioType", Nilable = false },
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurioRarityByTraitCondAccountElementID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "traitCondAccountElementID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rarity", Type = "CurioRarity", Nilable = false },
			},
		},
		{
			Name = "GetCurrentDelvesSeasonNumber",
			Type = "Function",

			Returns =
			{
				{ Name = "seasonNumber", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDelvesAffixSpellsForSeason",
			Type = "Function",

			Returns =
			{
				{ Name = "affixSpellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetDelvesFactionForSeason",
			Type = "Function",

			Returns =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDelvesMinRequiredLevel",
			Type = "Function",
			Documentation = { "Players must be at or above the min level + offset to enter Delves. This function returns that min level." },

			Returns =
			{
				{ Name = "minRequiredLevel", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetFactionForCompanion",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLockedTextForCompanion",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "text", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetModelSceneForCompanion",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "modelSceneID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRoleNodeForCompanion",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRoleSubtreeForCompanion",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "roleType", Type = "CompanionRoleType", Nilable = false },
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "subTreeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTraitTreeForCompanion",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "companionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnseenCuriosBySlotType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slotType", Type = "CompanionConfigSlotTypes", Nilable = false },
				{ Name = "ownedCurioNodeIDs", Type = "table", InnerType = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "unseenCurioNodeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "HasActiveDelve",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEligibleForActiveDelveRewards",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTraitTreeForCompanion",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "traitTreeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isForCompanion", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestPartyEligibilityForDelveTiers",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Queries private party members to see what level they have unlocked for the Delve. Ineligible members are added to the tooltip of dropdown entries." },

			Arguments =
			{
				{ Name = "gossipOption", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SaveSeenCuriosBySlotType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slotType", Type = "CompanionConfigSlotTypes", Nilable = false },
				{ Name = "ownedCurioNodeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ActiveDelveDataUpdate",
			Type = "Event",
			LiteralName = "ACTIVE_DELVE_DATA_UPDATE",
			SynchronousEvent = true,
			Documentation = { "Signaled when SpellScript calls change the data for players/parties owning a delve or when the delve is shut down." },
		},
		{
			Name = "DelveAssistAction",
			Type = "Event",
			LiteralName = "DELVE_ASSIST_ACTION",
			SynchronousEvent = true,
			Documentation = { "Signaled when an assist action occurs in a delve." },
			Payload =
			{
				{ Name = "data", Type = "DelveAssistActionData", Nilable = false },
			},
		},
		{
			Name = "DelvesAccountDataElementChanged",
			Type = "Event",
			LiteralName = "DELVES_ACCOUNT_DATA_ELEMENT_CHANGED",
			SynchronousEvent = true,
			Documentation = { "Signaled when player account data element(s) have changed. This drives curio ranks, and the UI should update when this is sent." },
		},
		{
			Name = "PartyEligibilityForDelveTiersChanged",
			Type = "Event",
			LiteralName = "PARTY_ELIGIBILITY_FOR_DELVE_TIERS_CHANGED",
			SynchronousEvent = true,
			Documentation = { "Signaled when responses come in from RequestPartyEligibilityForDelveTiers." },
			Payload =
			{
				{ Name = "playerName", Type = "string", Nilable = false },
				{ Name = "maxEligibleLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShowDelvesCompanionConfigurationUI",
			Type = "Event",
			LiteralName = "SHOW_DELVES_COMPANION_CONFIGURATION_UI",
			SynchronousEvent = true,
			Documentation = { "Signaled when SpellScript indicates that a curio has been learned or upgraded. Will show the companion config UI." },
		},
		{
			Name = "WalkInDataUpdate",
			Type = "Event",
			LiteralName = "WALK_IN_DATA_UPDATE",
			SynchronousEvent = true,
			Documentation = { "Signaled when the player or a private party member join a new walk-in instance or when the instance is shut down." },
		},
	},

	Tables =
	{
		{
			Name = "CompanionRoleType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Dps", Type = "CompanionRoleType", EnumValue = 0 },
				{ Name = "Heal", Type = "CompanionRoleType", EnumValue = 1 },
				{ Name = "Tank", Type = "CompanionRoleType", EnumValue = 2 },
			},
		},
		{
			Name = "CurioType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Combat", Type = "CurioType", EnumValue = 0 },
				{ Name = "Utility", Type = "CurioType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DelvesUI);