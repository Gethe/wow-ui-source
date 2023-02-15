local MajorFactions =
{
	Name = "MajorFactionsUI",
	Type = "System",
	Namespace = "C_MajorFactions",

	Functions =
	{
		{
			Name = "GetCovenantIDForMajorFaction",
			Type = "Function",

			Arguments =
			{
				{ Name = "majorFactionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "covenantID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrentRenownLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "majorFactionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFeatureAbilities",
			Type = "Function",

			Returns =
			{
				{ Name = "featureAbilities", Type = "table", InnerType = "MajorFactionFeatureAbilityInfo", Nilable = false },
			},
		},
		{
			Name = "GetMajorFactionData",
			Type = "Function",

			Arguments =
			{
				{ Name = "majorFactionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "MajorFactionData", Nilable = true },
			},
		},
		{
			Name = "GetMajorFactionIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "expansionID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "majorFactionIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRenownLevels",
			Type = "Function",

			Arguments =
			{
				{ Name = "majorFactionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "levels", Type = "table", InnerType = "MajorFactionRenownLevelInfo", Nilable = false },
			},
		},
		{
			Name = "GetRenownNPCFactionID",
			Type = "Function",

			Returns =
			{
				{ Name = "renownNPCFactionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRenownRewardsForLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "majorFactionID", Type = "number", Nilable = false },
				{ Name = "renownLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rewards", Type = "table", InnerType = "MajorFactionRenownRewardInfo", Nilable = false },
			},
		},
		{
			Name = "HasMaximumRenown",
			Type = "Function",

			Arguments =
			{
				{ Name = "majorFactionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasMaxRenown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlayerInRenownCatchUpMode",
			Type = "Function",

			Returns =
			{
				{ Name = "isInCatchUpMode", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsWeeklyRenownCapped",
			Type = "Function",

			Arguments =
			{
				{ Name = "majorFactionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isWeeklyCapped", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestCatchUpState",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "MajorFactionInteractionEnded",
			Type = "Event",
			LiteralName = "MAJOR_FACTION_INTERACTION_ENDED",
		},
		{
			Name = "MajorFactionInteractionStarted",
			Type = "Event",
			LiteralName = "MAJOR_FACTION_INTERACTION_STARTED",
		},
		{
			Name = "MajorFactionRenownCatchUpStateUpdate",
			Type = "Event",
			LiteralName = "MAJOR_FACTION_RENOWN_CATCH_UP_STATE_UPDATE",
		},
		{
			Name = "MajorFactionRenownLevelChanged",
			Type = "Event",
			LiteralName = "MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
			Payload =
			{
				{ Name = "majorFactionID", Type = "number", Nilable = false },
				{ Name = "newRenownLevel", Type = "number", Nilable = false },
				{ Name = "oldRenownLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MajorFactionUnlocked",
			Type = "Event",
			LiteralName = "MAJOR_FACTION_UNLOCKED",
			Payload =
			{
				{ Name = "majorFactionID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "MajorFactionData",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "factionID", Type = "number", Nilable = false },
				{ Name = "expansionID", Type = "number", Nilable = false },
				{ Name = "bountySetID", Type = "number", Nilable = false },
				{ Name = "isUnlocked", Type = "bool", Nilable = false },
				{ Name = "unlockDescription", Type = "cstring", Nilable = true },
				{ Name = "unlockOrder", Type = "number", Nilable = false },
				{ Name = "renownLevel", Type = "number", Nilable = false },
				{ Name = "renownReputationEarned", Type = "number", Nilable = false },
				{ Name = "renownLevelThreshold", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "celebrationSoundKit", Type = "number", Nilable = false },
				{ Name = "renownFanfareSoundKitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MajorFactionFeatureAbilityInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "featureAbilityType", Type = "number", Nilable = false },
				{ Name = "uiOrder", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MajorFactionRenownLevelInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "factionID", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "locked", Type = "bool", Nilable = false },
				{ Name = "isMilestone", Type = "bool", Nilable = false },
				{ Name = "isCapstone", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MajorFactionRenownRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "renownRewardID", Type = "number", Nilable = false },
				{ Name = "uiOrder", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "spellID", Type = "number", Nilable = true },
				{ Name = "mountID", Type = "number", Nilable = true },
				{ Name = "transmogID", Type = "number", Nilable = true },
				{ Name = "transmogSetID", Type = "number", Nilable = true },
				{ Name = "titleMaskID", Type = "number", Nilable = true },
				{ Name = "transmogIllusionSourceID", Type = "number", Nilable = true },
				{ Name = "icon", Type = "fileID", Nilable = true },
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "description", Type = "cstring", Nilable = true },
				{ Name = "toastDescription", Type = "cstring", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MajorFactions);