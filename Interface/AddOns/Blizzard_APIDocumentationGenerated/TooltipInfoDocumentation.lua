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

			Arguments =
			{
				{ Name = "actionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetArtifactItem",
			Type = "Function",

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetArtifactPowerByID",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = false },
				{ Name = "owningItemLink", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetBackpackToken",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetBagItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "bagIndex", Type = "number", Nilable = false },
				{ Name = "slotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetBagItemChild",
			Type = "Function",

			Arguments =
			{
				{ Name = "bagIndex", Type = "number", Nilable = false },
				{ Name = "slotIndex", Type = "number", Nilable = false },
				{ Name = "equipSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetBuybackItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetCompanionPet",
			Type = "Function",

			Arguments =
			{
				{ Name = "petGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetConduit",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "tokenIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetEnhancedConduit",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
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

			Arguments =
			{
				{ Name = "tab", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetHeirloomByItemID",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "hyperlink", Type = "string", Nilable = false },
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

			Arguments =
			{
				{ Name = "messageIndex", Type = "number", Nilable = false },
				{ Name = "attachmentIndex", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetInstanceLockEncountersComplete",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetInventoryItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
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

			Arguments =
			{
				{ Name = "guid", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetItemByID",
			Type = "Function",

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
			Name = "GetItemInteractionItem",
			Type = "Function",

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetItemKey",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "dungeonID", Type = "number", Nilable = false },
				{ Name = "lootIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetLFGDungeonShortageReward",
			Type = "Function",

			Arguments =
			{
				{ Name = "dungeonID", Type = "number", Nilable = false },
				{ Name = "shortageSeverity", Type = "number", Nilable = false },
				{ Name = "lootIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetLootCurrency",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetLootItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetLootRollItem",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
				{ Name = "costIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetMerchantItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetMinimapMouseover",
			Type = "Function",

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetMountBySpellID",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetPossession",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetPvpBrawl",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
				{ Name = "isInspect", Type = "bool", Nilable = true },
				{ Name = "groupIndex", Type = "number", Nilable = true },
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

			Arguments =
			{
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "currencyIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetQuestItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "itemIndex", Type = "number", Nilable = false },
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

			Arguments =
			{
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "currencyIndex", Type = "number", Nilable = false },
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

			Arguments =
			{
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "itemIndex", Type = "number", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "allowCollectionText", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetQuestLogRewardSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIndex", Type = "number", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetQuestLogSpecialItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "questIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetQuestPartyProgress",
			Type = "Function",

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
			Name = "GetQuestRewardSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetRecipeRankInfo",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "dataSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetRecipeResultItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
				{ Name = "recraftItemGUID", Type = "string", Nilable = true },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
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

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
				{ Name = "orderID", Type = "number", Nilable = true },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
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

			Arguments =
			{
				{ Name = "itemGUID", Type = "string", Nilable = false },
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

			Arguments =
			{
				{ Name = "attachmentIndex", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetShapeshift",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSlottedKeystone",
			Type = "Function",

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSocketGem",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSocketedItem",
			Type = "Function",

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSocketedRelic",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
				{ Name = "spellBookType", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetSpellByID",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
				{ Name = "isInspect", Type = "bool", Nilable = true },
				{ Name = "groupIndex", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetTotem",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetToyByItemID",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetTradeTargetItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetTrainerService",
			Type = "Function",

			Arguments =
			{
				{ Name = "serviceIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetTraitEntry",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = false },
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

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "filter", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUnitBuff",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "filter", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUnitBuffByAuraInstanceID",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitTokenString", Type = "string", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
				{ Name = "filter", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUnitDebuff",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "filter", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUnitDebuffByAuraInstanceID",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitTokenString", Type = "string", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
				{ Name = "filter", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetUpgradeItem",
			Type = "Function",

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetVoidDepositItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetVoidItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "tab", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetVoidWithdrawalItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "TooltipData", Nilable = false },
			},
		},
		{
			Name = "GetWorldCursor",
			Type = "Function",

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
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(TooltipInfo);