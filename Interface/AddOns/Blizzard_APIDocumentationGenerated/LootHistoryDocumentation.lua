local LootHistory =
{
	Name = "LootHistory",
	Type = "System",
	Namespace = "C_LootHistory",

	Functions =
	{
		{
			Name = "GetAllEncounterInfos",
			Type = "Function",

			Returns =
			{
				{ Name = "infos", Type = "table", InnerType = "EncounterLootInfo", Nilable = false },
			},
		},
		{
			Name = "GetInfoForEncounter",
			Type = "Function",

			Arguments =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "EncounterLootInfo", Nilable = true },
			},
		},
		{
			Name = "GetLootHistoryTime",
			Type = "Function",

			Returns =
			{
				{ Name = "time", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSortedDropsForEncounter",
			Type = "Function",

			Arguments =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "drops", Type = "table", InnerType = "EncounterLootDropInfo", Nilable = true },
			},
		},
		{
			Name = "GetSortedInfoForDrop",
			Type = "Function",

			Arguments =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "lootListID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "EncounterLootDropInfo", Nilable = true },
			},
		},
	},

	Events =
	{
		{
			Name = "LootHistoryClearHistory",
			Type = "Event",
			LiteralName = "LOOT_HISTORY_CLEAR_HISTORY",
		},
		{
			Name = "LootHistoryGoToEncounter",
			Type = "Event",
			LiteralName = "LOOT_HISTORY_GO_TO_ENCOUNTER",
			Payload =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LootHistoryOneHundredRoll",
			Type = "Event",
			LiteralName = "LOOT_HISTORY_ONE_HUNDRED_ROLL",
			Payload =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "lootListID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LootHistoryUpdateDrop",
			Type = "Event",
			LiteralName = "LOOT_HISTORY_UPDATE_DROP",
			Payload =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "lootListID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LootHistoryUpdateEncounter",
			Type = "Event",
			LiteralName = "LOOT_HISTORY_UPDATE_ENCOUNTER",
			Payload =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "EncounterLootDropRollState",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "NeedMainSpec", Type = "EncounterLootDropRollState", EnumValue = 0 },
				{ Name = "NeedOffSpec", Type = "EncounterLootDropRollState", EnumValue = 1 },
				{ Name = "Transmog", Type = "EncounterLootDropRollState", EnumValue = 2 },
				{ Name = "Greed", Type = "EncounterLootDropRollState", EnumValue = 3 },
				{ Name = "NoRoll", Type = "EncounterLootDropRollState", EnumValue = 4 },
				{ Name = "Pass", Type = "EncounterLootDropRollState", EnumValue = 5 },
			},
		},
		{
			Name = "EncounterLootDropInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "lootListID", Type = "number", Nilable = false },
				{ Name = "itemHyperlink", Type = "string", Nilable = false },
				{ Name = "playerRollState", Type = "EncounterLootDropRollState", Nilable = false },
				{ Name = "currentLeader", Type = "EncounterLootDropRollInfo", Nilable = true },
				{ Name = "isTied", Type = "bool", Nilable = false, Default = false },
				{ Name = "winner", Type = "EncounterLootDropRollInfo", Nilable = true },
				{ Name = "allPassed", Type = "bool", Nilable = false, Default = false },
				{ Name = "rollInfos", Type = "table", InnerType = "EncounterLootDropRollInfo", Nilable = false },
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EncounterLootDropRollInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "playerName", Type = "string", Nilable = false },
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "playerClass", Type = "string", Nilable = false },
				{ Name = "isSelf", Type = "bool", Nilable = false },
				{ Name = "state", Type = "EncounterLootDropRollState", Nilable = false },
				{ Name = "isWinner", Type = "bool", Nilable = false, Default = false },
				{ Name = "roll", Type = "number", Nilable = true },
			},
		},
		{
			Name = "EncounterLootDrops",
			Type = "Structure",
			Fields =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "drops", Type = "table", InnerType = "EncounterLootDropInfo", Nilable = false },
			},
		},
		{
			Name = "EncounterLootInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "encounterName", Type = "string", Nilable = false },
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LootHistory);