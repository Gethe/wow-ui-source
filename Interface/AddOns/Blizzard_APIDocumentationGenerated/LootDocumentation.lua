local Loot =
{
	Name = "Loot",
	Type = "System",
	Namespace = "C_Loot",

	Functions =
	{
		{
			Name = "GetLootRollDuration",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "rollID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "duration", Type = "number", Nilable = true },
			},
		},
		{
			Name = "IsLegacyLootModeEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isLegacyLootModeEnabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AzeriteEmpoweredItemLooted",
			Type = "Event",
			LiteralName = "AZERITE_EMPOWERED_ITEM_LOOTED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "itemLink", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "BonusRollActivate",
			Type = "Event",
			LiteralName = "BONUS_ROLL_ACTIVATE",
			SynchronousEvent = true,
		},
		{
			Name = "BonusRollDeactivate",
			Type = "Event",
			LiteralName = "BONUS_ROLL_DEACTIVATE",
			SynchronousEvent = true,
		},
		{
			Name = "BonusRollFailed",
			Type = "Event",
			LiteralName = "BONUS_ROLL_FAILED",
			SynchronousEvent = true,
		},
		{
			Name = "BonusRollResult",
			Type = "Event",
			LiteralName = "BONUS_ROLL_RESULT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "typeIdentifier", Type = "cstring", Nilable = false },
				{ Name = "itemLink", Type = "cstring", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "sex", Type = "number", Nilable = false },
				{ Name = "personalLootToast", Type = "bool", Nilable = false },
				{ Name = "currencyID", Type = "number", Nilable = true },
				{ Name = "isSecondaryResult", Type = "bool", Nilable = false },
				{ Name = "corrupted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "BonusRollStarted",
			Type = "Event",
			LiteralName = "BONUS_ROLL_STARTED",
			SynchronousEvent = true,
		},
		{
			Name = "CancelAllLootRolls",
			Type = "Event",
			LiteralName = "CANCEL_ALL_LOOT_ROLLS",
			SynchronousEvent = true,
		},
		{
			Name = "CancelLootRoll",
			Type = "Event",
			LiteralName = "CANCEL_LOOT_ROLL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "rollID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ConfirmDisenchantRoll",
			Type = "Event",
			LiteralName = "CONFIRM_DISENCHANT_ROLL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "rollID", Type = "number", Nilable = false },
				{ Name = "rollType", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ConfirmLootRoll",
			Type = "Event",
			LiteralName = "CONFIRM_LOOT_ROLL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "rollID", Type = "number", Nilable = false },
				{ Name = "rollType", Type = "number", Nilable = false },
				{ Name = "confirmReason", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "EncounterLootReceived",
			Type = "Event",
			LiteralName = "ENCOUNTER_LOOT_RECEIVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemLink", Type = "cstring", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "itemName", Type = "cstring", Nilable = false },
				{ Name = "fileName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GarrisonMissionBonusRollLoot",
			Type = "Event",
			LiteralName = "GARRISON_MISSION_BONUS_ROLL_LOOT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ItemPush",
			Type = "Event",
			LiteralName = "ITEM_PUSH",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "bagSlot", Type = "luaIndex", Nilable = false },
				{ Name = "iconFileID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LegacyLootRulesChanged",
			Type = "Event",
			LiteralName = "LEGACY_LOOT_RULES_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isLegacyLootModeEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LootBindConfirm",
			Type = "Event",
			LiteralName = "LOOT_BIND_CONFIRM",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "lootSlot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "LootClosed",
			Type = "Event",
			LiteralName = "LOOT_CLOSED",
			SynchronousEvent = true,
		},
		{
			Name = "LootItemAvailable",
			Type = "Event",
			LiteralName = "LOOT_ITEM_AVAILABLE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "itemTooltip", Type = "cstring", Nilable = false },
				{ Name = "lootHandle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LootItemRollWon",
			Type = "Event",
			LiteralName = "LOOT_ITEM_ROLL_WON",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "itemLink", Type = "cstring", Nilable = false },
				{ Name = "rollQuantity", Type = "number", Nilable = false },
				{ Name = "rollType", Type = "number", Nilable = false },
				{ Name = "roll", Type = "number", Nilable = false },
				{ Name = "upgraded", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LootOpened",
			Type = "Event",
			LiteralName = "LOOT_OPENED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "autoLoot", Type = "bool", Nilable = false },
				{ Name = "isFromItem", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LootReady",
			Type = "Event",
			LiteralName = "LOOT_READY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "autoloot", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LootRollsComplete",
			Type = "Event",
			LiteralName = "LOOT_ROLLS_COMPLETE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "lootHandle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LootSlotChanged",
			Type = "Event",
			LiteralName = "LOOT_SLOT_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "lootSlot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "LootSlotCleared",
			Type = "Event",
			LiteralName = "LOOT_SLOT_CLEARED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "lootSlot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "MainSpecNeedRoll",
			Type = "Event",
			LiteralName = "MAIN_SPEC_NEED_ROLL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "rollID", Type = "number", Nilable = false },
				{ Name = "roll", Type = "number", Nilable = false },
				{ Name = "isWinning", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "OpenMasterLootList",
			Type = "Event",
			LiteralName = "OPEN_MASTER_LOOT_LIST",
			SynchronousEvent = true,
		},
		{
			Name = "PetBattleLootReceived",
			Type = "Event",
			LiteralName = "PET_BATTLE_LOOT_RECEIVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "typeIdentifier", Type = "cstring", Nilable = false },
				{ Name = "itemLink", Type = "cstring", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerLootSpecUpdated",
			Type = "Event",
			LiteralName = "PLAYER_LOOT_SPEC_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "QuestCurrencyLootReceived",
			Type = "Event",
			LiteralName = "QUEST_CURRENCY_LOOT_RECEIVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "currencyId", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "QuestLootReceived",
			Type = "Event",
			LiteralName = "QUEST_LOOT_RECEIVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "itemLink", Type = "cstring", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShowLootToast",
			Type = "Event",
			LiteralName = "SHOW_LOOT_TOAST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "typeIdentifier", Type = "cstring", Nilable = false },
				{ Name = "itemLink", Type = "cstring", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "sex", Type = "number", Nilable = false },
				{ Name = "personalLootToast", Type = "bool", Nilable = false },
				{ Name = "toastMethod", Type = "number", Nilable = false },
				{ Name = "lessAwesome", Type = "bool", Nilable = false },
				{ Name = "upgraded", Type = "bool", Nilable = false },
				{ Name = "corrupted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShowLootToastLegendaryLooted",
			Type = "Event",
			LiteralName = "SHOW_LOOT_TOAST_LEGENDARY_LOOTED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "itemLink", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ShowLootToastUpgrade",
			Type = "Event",
			LiteralName = "SHOW_LOOT_TOAST_UPGRADE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "itemLink", Type = "cstring", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "sex", Type = "number", Nilable = false },
				{ Name = "baseQuality", Type = "number", Nilable = false },
				{ Name = "personalLootToast", Type = "bool", Nilable = false },
				{ Name = "lessAwesome", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShowPvpFactionLootToast",
			Type = "Event",
			LiteralName = "SHOW_PVP_FACTION_LOOT_TOAST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "typeIdentifier", Type = "cstring", Nilable = false },
				{ Name = "itemLink", Type = "cstring", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "sex", Type = "number", Nilable = false },
				{ Name = "personalLootToast", Type = "bool", Nilable = false },
				{ Name = "lessAwesome", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShowRatedPvpRewardToast",
			Type = "Event",
			LiteralName = "SHOW_RATED_PVP_REWARD_TOAST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "typeIdentifier", Type = "cstring", Nilable = false },
				{ Name = "itemLink", Type = "cstring", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "sex", Type = "number", Nilable = false },
				{ Name = "personalLootToast", Type = "bool", Nilable = false },
				{ Name = "lessAwesome", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "StartLootRoll",
			Type = "Event",
			LiteralName = "START_LOOT_ROLL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "rollID", Type = "number", Nilable = false },
				{ Name = "rollTime", Type = "number", Nilable = false },
				{ Name = "lootHandle", Type = "number", Nilable = true },
			},
		},
		{
			Name = "TrialCapReachedMoney",
			Type = "Event",
			LiteralName = "TRIAL_CAP_REACHED_MONEY",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateMasterLootList",
			Type = "Event",
			LiteralName = "UPDATE_MASTER_LOOT_LIST",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Loot);