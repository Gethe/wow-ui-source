local TradeSkillUI =
{
	Name = "TradeSkillUI",
	Type = "System",
	Namespace = "C_TradeSkillUI",

	Functions =
	{
		{
			Name = "CanStoreEnchantInItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "canStore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CloseTradeSkill",
			Type = "Function",
		},
		{
			Name = "CraftEnchant",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "numCasts", Type = "number", Nilable = false, Default = 1 },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
				{ Name = "itemTarget", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = true },
				{ Name = "applyConcentration", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "CraftRecipe",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "numCasts", Type = "number", Nilable = false, Default = 1 },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
				{ Name = "recipeLevel", Type = "luaIndex", Nilable = true },
				{ Name = "orderID", Type = "BigUInteger", Nilable = true },
				{ Name = "applyConcentration", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "CraftSalvage",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "numCasts", Type = "number", Nilable = false, Default = 1 },
				{ Name = "itemTarget", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
				{ Name = "applyConcentration", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "DoesRecraftingRecipeAcceptItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAllProfessionTradeSkillLines",
			Type = "Function",

			Returns =
			{
				{ Name = "skillLineID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetBaseProfessionInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "ProfessionInfo", Nilable = false },
			},
		},
		{
			Name = "GetChildProfessionInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "ProfessionInfo", Nilable = false },
			},
		},
		{
			Name = "GetChildProfessionInfos",
			Type = "Function",

			Returns =
			{
				{ Name = "infos", Type = "table", InnerType = "ProfessionInfo", Nilable = false },
			},
		},
		{
			Name = "GetConcentrationCurrencyID",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "currencyType", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCraftableCount",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "numAvailable", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCraftingOperationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = false },
				{ Name = "allocationItemGUID", Type = "WOWGUID", Nilable = true },
				{ Name = "applyConcentration", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CraftingOperationInfo", Nilable = true },
			},
		},
		{
			Name = "GetCraftingOperationInfoForOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = false },
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
				{ Name = "applyConcentration", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CraftingOperationInfo", Nilable = true },
			},
		},
		{
			Name = "GetCraftingReagentBonusText",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "craftingReagentIndex", Type = "luaIndex", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = false },
				{ Name = "allocationItemGUID", Type = "WOWGUID", Nilable = true },
			},

			Returns =
			{
				{ Name = "bonusText", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "GetCraftingTargetItems",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemIDs", Type = "table", InnerType = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "items", Type = "table", InnerType = "CraftingTargetItem", Nilable = false },
			},
		},
		{
			Name = "GetEnchantItems",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "items", Type = "table", InnerType = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetFactionSpecificOutputItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetGatheringOperationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "GatheringOperationInfo", Nilable = true },
			},
		},
		{
			Name = "GetHideUnownedFlags",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "cannotModifyHideUnowned", Type = "bool", Nilable = false },
				{ Name = "alwaysShowUnowned", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetItemCraftedQualityByItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "quality", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetItemReagentQualityByItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "quality", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetItemSlotModifications",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "slotMods", Type = "table", InnerType = "CraftingItemSlotModification", Nilable = false },
			},
		},
		{
			Name = "GetItemSlotModificationsForOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
			},

			Returns =
			{
				{ Name = "slotMods", Type = "table", InnerType = "CraftingItemSlotModification", Nilable = false },
			},
		},
		{
			Name = "GetOriginalCraftRecipeID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "recipeID", Type = "number", Nilable = true },
				{ Name = "skillLineAbilityID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetProfessionByInventorySlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "profession", Type = "Profession", Nilable = true },
			},
		},
		{
			Name = "GetProfessionChildSkillLineID",
			Type = "Function",

			Returns =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetProfessionForCursorItem",
			Type = "Function",

			Returns =
			{
				{ Name = "profession", Type = "Profession", Nilable = true },
			},
		},
		{
			Name = "GetProfessionInfoByRecipeID",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ProfessionInfo", Nilable = false },
			},
		},
		{
			Name = "GetProfessionInfoBySkillLineID",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ProfessionInfo", Nilable = false },
			},
		},
		{
			Name = "GetProfessionInventorySlots",
			Type = "Function",

			Returns =
			{
				{ Name = "invSlots", Type = "table", InnerType = "InventorySlots", Nilable = false },
			},
		},
		{
			Name = "GetProfessionNameForSkillLineAbility",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "professionNmae", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetProfessionSkillLineID",
			Type = "Function",

			Arguments =
			{
				{ Name = "profession", Type = "Profession", Nilable = false },
			},

			Returns =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetProfessionSlots",
			Type = "Function",

			Arguments =
			{
				{ Name = "profession", Type = "Profession", Nilable = false },
			},

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetProfessionSpells",
			Type = "Function",

			Arguments =
			{
				{ Name = "professionID", Type = "number", Nilable = false },
				{ Name = "skillLineID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "knownSpells", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetQualitiesForRecipe",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "qualityIDs", Type = "table", InnerType = "number", Nilable = true },
			},
		},
		{
			Name = "GetReagentDifficultyText",
			Type = "Function",

			Arguments =
			{
				{ Name = "craftingReagentIndex", Type = "luaIndex", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "bonusText", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetReagentRequirementItemIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetReagentSlotStatus",
			Type = "Function",

			Arguments =
			{
				{ Name = "mcrSlotID", Type = "number", Nilable = false },
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "locked", Type = "bool", Nilable = false },
				{ Name = "lockedReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRecipeDescription",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = false },
				{ Name = "allocationItemGUID", Type = "WOWGUID", Nilable = true },
			},

			Returns =
			{
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRecipeFixedReagentItemLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "dataSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetRecipeInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "recipeInfo", Type = "TradeSkillRecipeInfo", Nilable = true },
			},
		},
		{
			Name = "GetRecipeInfoForSkillLineAbility",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "recipeInfo", Type = "TradeSkillRecipeInfo", Nilable = true },
			},
		},
		{
			Name = "GetRecipeOutputItemData",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "reagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
				{ Name = "allocationItemGUID", Type = "WOWGUID", Nilable = true },
				{ Name = "overrideQualityID", Type = "number", Nilable = true },
				{ Name = "recraftOrderID", Type = "BigUInteger", Nilable = true },
			},

			Returns =
			{
				{ Name = "outputInfo", Type = "CraftingRecipeOutputInfo", Nilable = false },
			},
		},
		{
			Name = "GetRecipeQualityItemIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "qualityItemIDs", Type = "table", InnerType = "number", Nilable = true },
			},
		},
		{
			Name = "GetRecipeQualityReagentItemLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "dataSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "qualityIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetRecipeRequirements",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "requirements", Type = "table", InnerType = "CraftingRecipeRequirement", Nilable = false },
			},
		},
		{
			Name = "GetRecipeSchematic",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "isRecraft", Type = "bool", Nilable = false },
				{ Name = "recipeLevel", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "schematic", Type = "CraftingRecipeSchematic", Nilable = false },
			},
		},
		{
			Name = "GetRecipesTracked",
			Type = "Function",

			Arguments =
			{
				{ Name = "isRecraft", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "recipeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRecraftItems",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "items", Type = "table", InnerType = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetRecraftRemovalWarnings",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "replacedItemIDs", Type = "table", InnerType = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "warnings", Type = "table", InnerType = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetRemainingRecasts",
			Type = "Function",

			Returns =
			{
				{ Name = "remaining", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSalvagableItemIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetShowLearned",
			Type = "Function",

			Returns =
			{
				{ Name = "flag", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetShowUnlearned",
			Type = "Function",

			Returns =
			{
				{ Name = "flag", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSkillLineForGear",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "skillLineID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSourceTypeFilter",
			Type = "Function",

			Returns =
			{
				{ Name = "sourceTypeFilter", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTradeSkillDisplayName",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "professionDisplayName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "HasFavoriteOrderRecipes",
			Type = "Function",

			Returns =
			{
				{ Name = "hasFavorites", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEnchantTargetValid",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
			},

			Returns =
			{
				{ Name = "valid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGuildTradeSkillsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsNPCCrafting",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsNearProfessionSpellFocus",
			Type = "Function",

			Arguments =
			{
				{ Name = "profession", Type = "Profession", Nilable = false },
			},

			Returns =
			{
				{ Name = "nearFocus", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOriginalCraftRecipeLearned",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "learned", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecipeFirstCraft",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecipeInBaseSkillLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecipeInSkillLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecipeProfessionLearned",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "recipeProfessionLearned", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecipeTracked",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "isRecraft", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "tracked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecraftItemEquipped",
			Type = "Function",

			Arguments =
			{
				{ Name = "recraftItemGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isEquipped", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecraftReagentValid",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "valid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRuneforging",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "OpenRecipe",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "OpenTradeSkill",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "opened", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RecraftLimitCategoryValid",
			Type = "Function",

			Arguments =
			{
				{ Name = "reagentItemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "recraftValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RecraftRecipe",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
				{ Name = "removedModifications", Type = "table", InnerType = "CraftingItemSlotModification", Nilable = true },
				{ Name = "applyConcentration", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RecraftRecipeForOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
				{ Name = "removedModifications", Type = "table", InnerType = "CraftingItemSlotModification", Nilable = true },
				{ Name = "applyConcentration", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetOnlyShowAvailableForOrders",
			Type = "Function",

			Arguments =
			{
				{ Name = "flag", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetProfessionChildSkillLineID",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetRecipeTracked",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "tracked", Type = "bool", Nilable = false },
				{ Name = "isRecraft", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetShowLearned",
			Type = "Function",

			Arguments =
			{
				{ Name = "flag", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetShowUnlearned",
			Type = "Function",

			Arguments =
			{
				{ Name = "flag", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSourceTypeFilter",
			Type = "Function",

			Arguments =
			{
				{ Name = "sourceTypeFilter", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CraftingDetailsUpdate",
			Type = "Event",
			LiteralName = "CRAFTING_DETAILS_UPDATE",
		},
		{
			Name = "NewRecipeLearned",
			Type = "Event",
			LiteralName = "NEW_RECIPE_LEARNED",
			Payload =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "luaIndex", Nilable = true },
				{ Name = "baseRecipeID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ObliterumForgePendingItemChanged",
			Type = "Event",
			LiteralName = "OBLITERUM_FORGE_PENDING_ITEM_CHANGED",
		},
		{
			Name = "OpenRecipeResponse",
			Type = "Event",
			LiteralName = "OPEN_RECIPE_RESPONSE",
			Payload =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "skillLineID", Type = "number", Nilable = false },
				{ Name = "expansionSkillLineID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TrackedRecipeUpdate",
			Type = "Event",
			LiteralName = "TRACKED_RECIPE_UPDATE",
			Payload =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "tracked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TradeSkillClose",
			Type = "Event",
			LiteralName = "TRADE_SKILL_CLOSE",
		},
		{
			Name = "TradeSkillCraftBegin",
			Type = "Event",
			LiteralName = "TRADE_SKILL_CRAFT_BEGIN",
			Payload =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TradeSkillCraftingReagentBonusTextUpdated",
			Type = "Event",
			LiteralName = "TRADE_SKILL_CRAFTING_REAGENT_BONUS_TEXT_UPDATED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TradeSkillCurrencyRewardResult",
			Type = "Event",
			LiteralName = "TRADE_SKILL_CURRENCY_REWARD_RESULT",
			Payload =
			{
				{ Name = "data", Type = "CraftingCurrencyResultData", Nilable = false },
			},
		},
		{
			Name = "TradeSkillDataSourceChanged",
			Type = "Event",
			LiteralName = "TRADE_SKILL_DATA_SOURCE_CHANGED",
		},
		{
			Name = "TradeSkillDataSourceChanging",
			Type = "Event",
			LiteralName = "TRADE_SKILL_DATA_SOURCE_CHANGING",
		},
		{
			Name = "TradeSkillDetailsUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_DETAILS_UPDATE",
		},
		{
			Name = "TradeSkillFavoritesChanged",
			Type = "Event",
			LiteralName = "TRADE_SKILL_FAVORITES_CHANGED",
			Payload =
			{
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TradeSkillItemCraftedResult",
			Type = "Event",
			LiteralName = "TRADE_SKILL_ITEM_CRAFTED_RESULT",
			Payload =
			{
				{ Name = "data", Type = "CraftingItemResultData", Nilable = false },
			},
		},
		{
			Name = "TradeSkillItemUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_ITEM_UPDATE",
			Payload =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "TradeSkillListUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_LIST_UPDATE",
		},
		{
			Name = "TradeSkillNameUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_NAME_UPDATE",
		},
		{
			Name = "TradeSkillShow",
			Type = "Event",
			LiteralName = "TRADE_SKILL_SHOW",
		},
		{
			Name = "UpdateTradeskillCastStopped",
			Type = "Event",
			LiteralName = "UPDATE_TRADESKILL_CAST_STOPPED",
			Payload =
			{
				{ Name = "isScrapping", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "CraftingReagentItemFlag",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "TooltipShowsAsStatModifications", Type = "CraftingReagentItemFlag", EnumValue = 0 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TradeSkillUI);