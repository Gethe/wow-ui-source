local TooltipInfo =
{
	Name = "TooltipInfo",
	Type = "System",
	Namespace = "C_TooltipInfo",

	Functions =
	{
		{
			Name = "GetAchievementByID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetAction",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetArtifactItem",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetArtifactPowerByID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetAzeriteEssence",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "essenceID", Type = "number", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetAzeriteEssenceSlot",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "AzeriteEssenceSlot", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetAzeritePower",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = false },
				{ Name = "owningItemLink", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetBackpackToken",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetBagItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "bagIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetBagItemChild",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "bagIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "equipSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetBuybackItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetCompanionPet",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "petGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetConduit",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
				{ Name = "conduitRank", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyByID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "amount", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyToken",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "tokenIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetEnhancedConduit",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "conduitID", Type = "number", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetEquipmentSet",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "setID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetExistingSocketGem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "toDestroy", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetGuildBankItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "tab", Type = "luaIndex", Nilable = false },
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetHeirloomByItemID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetHyperlink",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "hyperlink", Type = "cstring", Nilable = false },
				{ Name = "optionalArg1", Type = "number", Nilable = true },
				{ Name = "optionalArg2", Type = "number", Nilable = true },
				{ Name = "hideVendorPrice", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetInboxItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "messageIndex", Type = "luaIndex", Nilable = false },
				{ Name = "attachmentIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetInstanceLockEncountersComplete",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetInventoryItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "slot", Type = "luaIndex", Nilable = false },
				{ Name = "hideUselessStats", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetInventoryItemByID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetItemByGUID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetItemByID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetItemByItemModifiedAppearanceID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetItemInteractionItem",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetItemKey",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "itemSuffix", Type = "number", Nilable = false },
				{ Name = "requiredLevel", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetLFGDungeonReward",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "dungeonID", Type = "number", Nilable = false },
				{ Name = "lootIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetLFGDungeonShortageReward",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "dungeonID", Type = "number", Nilable = false },
				{ Name = "shortageSeverity", Type = "number", Nilable = false },
				{ Name = "lootIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetLootCurrency",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetLootItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetLootRollItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetMerchantCostItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
				{ Name = "costIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetMerchantItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetMinimapMouseover",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetMountBySpellID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "checkIndoors", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetOwnedItemByID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetPetAction",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetPossession",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetPvpBrawl",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "isSpecial", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetPvpTalent",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
				{ Name = "isInspect", Type = "bool", Nilable = true },
				{ Name = "groupIndex", Type = "luaIndex", Nilable = true },
				{ Name = "talentIndex", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetQuestCurrency",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "type", Type = "cstring", Nilable = false },
				{ Name = "currencyIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetQuestItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "type", Type = "cstring", Nilable = false },
				{ Name = "itemIndex", Type = "luaIndex", Nilable = false },
				{ Name = "allowCollectionText", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetQuestLogCurrency",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "type", Type = "cstring", Nilable = false },
				{ Name = "currencyIndex", Type = "luaIndex", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetQuestLogItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "type", Type = "cstring", Nilable = false },
				{ Name = "itemIndex", Type = "luaIndex", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "allowCollectionText", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetQuestLogSpecialItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "questIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetQuestPartyProgress",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "omitTitle", Type = "bool", Nilable = true },
				{ Name = "ignoreActivePlayer", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetRecipeRankInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetRecipeReagentItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "dataSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetRecipeResultItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
				{ Name = "recraftItemGUID", Type = "WOWGUID", Nilable = true },
				{ Name = "recipeLevel", Type = "luaIndex", Nilable = true },
				{ Name = "overrideQualityID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetRecipeResultItemForOrder",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
				{ Name = "orderID", Type = "BigUInteger", Nilable = true },
				{ Name = "recipeLevel", Type = "luaIndex", Nilable = true },
				{ Name = "overrideQualityID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgeResultItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = true },
				{ Name = "modifiers", Type = "table", InnerType = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSendMailItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "attachmentIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetShapeshift",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSlottedKeystone",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSocketGem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSocketedItem",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSocketedRelic",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSpellByID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "isPet", Type = "bool", Nilable = true },
				{ Name = "showSubtext", Type = "bool", Nilable = true },
				{ Name = "dontOverride", Type = "bool", Nilable = true },
				{ Name = "difficultyID", Type = "number", Nilable = true },
				{ Name = "isLink", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetTalent",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
				{ Name = "isInspect", Type = "bool", Nilable = true },
				{ Name = "groupIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetTotem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetToyByItemID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetTradePlayerItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetTradeTargetItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetTrainerService",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "serviceIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetTraitEntry",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "entryID", Type = "number", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetTransmogrifyItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUnit",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "hideStatus", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUnitAura",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "filter", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUnitBuff",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "filter", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUnitBuffByAuraInstanceID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "unitTokenString", Type = "cstring", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
				{ Name = "filter", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUnitDebuff",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "filter", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUnitDebuffByAuraInstanceID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "unitTokenString", Type = "cstring", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
				{ Name = "filter", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUpgradeItem",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetVoidDepositItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetVoidItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "tab", Type = "luaIndex", Nilable = false },
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetVoidWithdrawalItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetWeeklyReward",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemDBID", Type = "WeeklyRewardItemDBID", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetWorldCursor",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetWorldLootObject",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "unitTokenString", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HideHyperlinkTooltip",
			Type = "Event",
			LiteralName = "HIDE_HYPERLINK_TOOLTIP",
		},
		{
			Name = "ShowHyperlinkTooltip",
			Type = "Event",
			LiteralName = "SHOW_HYPERLINK_TOOLTIP",
			Payload =
			{
				{ Name = "hyperlink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "TooltipDataUpdate",
			Type = "Event",
			LiteralName = "TOOLTIP_DATA_UPDATE",
			Documentation = { "Sends an update to the UI that a sparse or cache lookup has resolved" },
			Payload =
			{
				{ Name = "dataInstanceID", Type = "number", Nilable = true },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(TooltipInfo);