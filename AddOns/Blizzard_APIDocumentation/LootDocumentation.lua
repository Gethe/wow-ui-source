local Loot =
{
	Name = "Loot",
	Type = "System",
	Namespace = "C_Loot",

	Functions =
	{
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
			Payload =
			{
				{ Name = "itemLink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "BonusRollActivate",
			Type = "Event",
			LiteralName = "BONUS_ROLL_ACTIVATE",
		},
		{
			Name = "BonusRollDeactivate",
			Type = "Event",
			LiteralName = "BONUS_ROLL_DEACTIVATE",
		},
		{
			Name = "BonusRollFailed",
			Type = "Event",
			LiteralName = "BONUS_ROLL_FAILED",
		},
		{
			Name = "BonusRollResult",
			Type = "Event",
			LiteralName = "BONUS_ROLL_RESULT",
			Payload =
			{
				{ Name = "typeIdentifier", Type = "string", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = false },
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
		},
		{
			Name = "CancelLootRoll",
			Type = "Event",
			LiteralName = "CANCEL_LOOT_ROLL",
			Payload =
			{
				{ Name = "rollID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ConfirmDisenchantRoll",
			Type = "Event",
			LiteralName = "CONFIRM_DISENCHANT_ROLL",
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
			Payload =
			{
				{ Name = "rollID", Type = "number", Nilable = false },
				{ Name = "rollType", Type = "number", Nilable = false },
				{ Name = "confirmReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "EncounterLootReceived",
			Type = "Event",
			LiteralName = "ENCOUNTER_LOOT_RECEIVED",
			Payload =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "itemName", Type = "string", Nilable = false },
				{ Name = "fileName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GarrisonMissionBonusRollLoot",
			Type = "Event",
			LiteralName = "GARRISON_MISSION_BONUS_ROLL_LOOT",
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
			Payload =
			{
				{ Name = "bagSlot", Type = "number", Nilable = false },
				{ Name = "iconFileID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LootBindConfirm",
			Type = "Event",
			LiteralName = "LOOT_BIND_CONFIRM",
			Payload =
			{
				{ Name = "lootSlot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LootClosed",
			Type = "Event",
			LiteralName = "LOOT_CLOSED",
		},
		{
			Name = "LootHistoryAutoShow",
			Type = "Event",
			LiteralName = "LOOT_HISTORY_AUTO_SHOW",
			Payload =
			{
				{ Name = "rollID", Type = "number", Nilable = false },
				{ Name = "isMasterLoot", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LootHistoryFullUpdate",
			Type = "Event",
			LiteralName = "LOOT_HISTORY_FULL_UPDATE",
		},
		{
			Name = "LootHistoryRollChanged",
			Type = "Event",
			LiteralName = "LOOT_HISTORY_ROLL_CHANGED",
			Payload =
			{
				{ Name = "historyIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LootHistoryRollComplete",
			Type = "Event",
			LiteralName = "LOOT_HISTORY_ROLL_COMPLETE",
		},
		{
			Name = "LootItemAvailable",
			Type = "Event",
			LiteralName = "LOOT_ITEM_AVAILABLE",
			Payload =
			{
				{ Name = "itemTooltip", Type = "string", Nilable = false },
				{ Name = "lootHandle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LootItemRollWon",
			Type = "Event",
			LiteralName = "LOOT_ITEM_ROLL_WON",
			Payload =
			{
				{ Name = "itemLink", Type = "string", Nilable = false },
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
			Payload =
			{
				{ Name = "autoloot", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LootRollsComplete",
			Type = "Event",
			LiteralName = "LOOT_ROLLS_COMPLETE",
			Payload =
			{
				{ Name = "lootHandle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LootSlotChanged",
			Type = "Event",
			LiteralName = "LOOT_SLOT_CHANGED",
			Payload =
			{
				{ Name = "lootSlot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LootSlotCleared",
			Type = "Event",
			LiteralName = "LOOT_SLOT_CLEARED",
			Payload =
			{
				{ Name = "lootSlot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "OpenMasterLootList",
			Type = "Event",
			LiteralName = "OPEN_MASTER_LOOT_LIST",
		},
		{
			Name = "PetBattleLootReceived",
			Type = "Event",
			LiteralName = "PET_BATTLE_LOOT_RECEIVED",
			Payload =
			{
				{ Name = "typeIdentifier", Type = "string", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerLootSpecUpdated",
			Type = "Event",
			LiteralName = "PLAYER_LOOT_SPEC_UPDATED",
		},
		{
			Name = "QuestCurrencyLootReceived",
			Type = "Event",
			LiteralName = "QUEST_CURRENCY_LOOT_RECEIVED",
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
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShowLootToast",
			Type = "Event",
			LiteralName = "SHOW_LOOT_TOAST",
			Payload =
			{
				{ Name = "typeIdentifier", Type = "string", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = false },
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
			Payload =
			{
				{ Name = "itemLink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ShowLootToastUpgrade",
			Type = "Event",
			LiteralName = "SHOW_LOOT_TOAST_UPGRADE",
			Payload =
			{
				{ Name = "itemLink", Type = "string", Nilable = false },
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
			Payload =
			{
				{ Name = "typeIdentifier", Type = "string", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = false },
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
			Payload =
			{
				{ Name = "typeIdentifier", Type = "string", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = false },
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
		},
		{
			Name = "UpdateMasterLootList",
			Type = "Event",
			LiteralName = "UPDATE_MASTER_LOOT_LIST",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Loot);