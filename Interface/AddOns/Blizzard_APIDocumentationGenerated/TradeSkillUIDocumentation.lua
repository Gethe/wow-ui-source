local TradeSkillUI =
{
	Name = "TradeSkillUI",
	Type = "System",
	Namespace = "C_TradeSkillUI",

	Functions =
	{
		{
			Name = "CloseTradeSkill",
			Type = "Function",
		},
		{
			Name = "ContinueRecast",
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
				{ Name = "itemTarget", Type = "table", Mixin = "ItemLocationMixin", Nilable = true },
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
				{ Name = "recipeLevel", Type = "number", Nilable = true },
				{ Name = "orderID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CraftSalvage",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "numCasts", Type = "number", Nilable = false, Default = 1 },
				{ Name = "itemTarget", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "DoesRecraftingRecipeAcceptItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
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
			Name = "GetCraftableCount",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
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
				{ Name = "allocationItemGUID", Type = "string", Nilable = true },
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
				{ Name = "orderID", Type = "number", Nilable = false },
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
				{ Name = "craftingReagentIndex", Type = "number", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = false },
				{ Name = "allocationItemGUID", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "bonusText", Type = "table", InnerType = "string", Nilable = false },
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
				{ Name = "items", Type = "table", InnerType = "string", Nilable = false },
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
				{ Name = "itemInfo", Type = "string", Nilable = false },
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
				{ Name = "itemInfo", Type = "string", Nilable = false },
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
				{ Name = "itemGUID", Type = "string", Nilable = false },
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
				{ Name = "orderID", Type = "number", Nilable = false },
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
				{ Name = "itemGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "recipeID", Type = "number", Nilable = true },
				{ Name = "skillLineAbilityID", Type = "number", Nilable = true },
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
				{ Name = "slots", Type = "table", InnerType = "number", Nilable = false },
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
				{ Name = "craftingReagentIndex", Type = "number", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "bonusText", Type = "string", Nilable = false },
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
				{ Name = "allocationItemGUID", Type = "string", Nilable = true },
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
				{ Name = "dataSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRecipeInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
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
				{ Name = "recipeLevel", Type = "number", Nilable = true },
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
				{ Name = "allocationItemGUID", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "outputInfo", Type = "CraftingRecipeOutputInfo", Nilable = false },
			},
		},
		{
			Name = "GetRecipeQualityReagentItemLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "dataSlotIndex", Type = "number", Nilable = false },
				{ Name = "qualityIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRecipeRepeatCount",
			Type = "Function",

			Returns =
			{
				{ Name = "recastTimes", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRecipeSchematic",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "isRecraft", Type = "bool", Nilable = false },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "schematic", Type = "CraftingRecipeSchematic", Nilable = false },
			},
		},
		{
			Name = "GetRecipesTracked",
			Type = "Function",

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
				{ Name = "items", Type = "table", InnerType = "string", Nilable = false },
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
				{ Name = "itemInfo", Type = "string", Nilable = false },
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
				{ Name = "professionDisplayName", Type = "string", Nilable = false },
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
			Name = "HasRecipesTracked",
			Type = "Function",

			Returns =
			{
				{ Name = "hasRecipesTracked", Type = "bool", Nilable = false },
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
				{ Name = "itemGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "learned", Type = "bool", Nilable = false },
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
			},

			Returns =
			{
				{ Name = "tracked", Type = "bool", Nilable = false },
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
			Name = "RecipeCanBeRecrafted",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "recraftable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RecraftRecipe",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "string", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
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
				{ Name = "orderID", Type = "number", Nilable = false },
				{ Name = "itemGUID", Type = "string", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
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
				{ Name = "recipeLevel", Type = "number", Nilable = true },
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
				{ Name = "itemGUID", Type = "string", Nilable = false },
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
			Name = "UpdateTradeskillCastComplete",
			Type = "Event",
			LiteralName = "UPDATE_TRADESKILL_CAST_COMPLETE",
		},
		{
			Name = "UpdateTradeskillRecast",
			Type = "Event",
			LiteralName = "UPDATE_TRADESKILL_RECAST",
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