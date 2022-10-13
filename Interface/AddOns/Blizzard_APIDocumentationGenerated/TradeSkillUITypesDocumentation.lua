local TradeSkillUITypes =
{
	Tables =
	{
		{
			Name = "TradeskillOrderDuration",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Short", Type = "TradeskillOrderDuration", EnumValue = 1 },
				{ Name = "Medium", Type = "TradeskillOrderDuration", EnumValue = 2 },
				{ Name = "Long", Type = "TradeskillOrderDuration", EnumValue = 3 },
			},
		},
		{
			Name = "TradeskillOrderRecipient",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Public", Type = "TradeskillOrderRecipient", EnumValue = 1 },
				{ Name = "Guild", Type = "TradeskillOrderRecipient", EnumValue = 2 },
				{ Name = "Private", Type = "TradeskillOrderRecipient", EnumValue = 3 },
			},
		},
		{
			Name = "TradeskillOrderStatus",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Unclaimed", Type = "TradeskillOrderStatus", EnumValue = 1 },
				{ Name = "Started", Type = "TradeskillOrderStatus", EnumValue = 2 },
				{ Name = "Completed", Type = "TradeskillOrderStatus", EnumValue = 3 },
				{ Name = "Expired", Type = "TradeskillOrderStatus", EnumValue = 4 },
			},
		},
		{
			Name = "TradeskillRecipeType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Item", Type = "TradeskillRecipeType", EnumValue = 1 },
				{ Name = "Salvage", Type = "TradeskillRecipeType", EnumValue = 2 },
				{ Name = "Enchant", Type = "TradeskillRecipeType", EnumValue = 3 },
				{ Name = "Recraft", Type = "TradeskillRecipeType", EnumValue = 4 },
			},
		},
		{
			Name = "TradeskillRelativeDifficulty",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Optimal", Type = "TradeskillRelativeDifficulty", EnumValue = 0 },
				{ Name = "Medium", Type = "TradeskillRelativeDifficulty", EnumValue = 1 },
				{ Name = "Easy", Type = "TradeskillRelativeDifficulty", EnumValue = 2 },
				{ Name = "Trivial", Type = "TradeskillRelativeDifficulty", EnumValue = 3 },
			},
		},
		{
			Name = "TradeskillSlotDataType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Reagent", Type = "TradeskillSlotDataType", EnumValue = 1 },
				{ Name = "ModifiedReagent", Type = "TradeskillSlotDataType", EnumValue = 2 },
				{ Name = "Currency", Type = "TradeskillSlotDataType", EnumValue = 3 },
			},
		},
		{
			Name = "CraftingCurrencyResultData",
			Type = "Structure",
			Fields =
			{
				{ Name = "currencyID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "quantity", Type = "number", Nilable = false, Default = 0 },
				{ Name = "associatedItemGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CraftingItemResultData",
			Type = "Structure",
			Fields =
			{
				{ Name = "resourcesReturned", Type = "table", InnerType = "CraftingResourceReturnInfo", Nilable = true },
				{ Name = "craftingQuality", Type = "number", Nilable = true },
				{ Name = "itemID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "itemGUID", Type = "string", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false, Default = 0 },
				{ Name = "hyperlink", Type = "string", Nilable = false },
				{ Name = "isCrit", Type = "bool", Nilable = false, Default = false },
				{ Name = "critBonusSkill", Type = "number", Nilable = false, Default = 0 },
				{ Name = "recraftable", Type = "bool", Nilable = false, Default = false },
				{ Name = "bonusCraft", Type = "bool", Nilable = false, Default = false },
				{ Name = "multicraft", Type = "number", Nilable = false, Default = 0 },
				{ Name = "associatedItemGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CraftingItemSlotModification",
			Type = "Structure",
			Fields =
			{
				{ Name = "dataSlotIndex", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "CraftingOperationBonusStatInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "bonusStatName", Type = "string", Nilable = false },
				{ Name = "bonusStatValue", Type = "number", Nilable = false },
				{ Name = "ratingDescription", Type = "string", Nilable = false },
				{ Name = "ratingPct", Type = "number", Nilable = false },
				{ Name = "bonusRatingPct", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CraftingOperationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "baseDifficulty", Type = "number", Nilable = false },
				{ Name = "bonusDifficulty", Type = "number", Nilable = false },
				{ Name = "baseSkill", Type = "number", Nilable = false },
				{ Name = "bonusSkill", Type = "number", Nilable = false },
				{ Name = "isQualityCraft", Type = "bool", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "craftingQuality", Type = "number", Nilable = false },
				{ Name = "craftingQualityID", Type = "number", Nilable = false },
				{ Name = "craftingDataID", Type = "number", Nilable = false },
				{ Name = "lowerSkillThreshold", Type = "number", Nilable = false },
				{ Name = "upperSkillTreshold", Type = "number", Nilable = false },
				{ Name = "bonusStats", Type = "table", InnerType = "CraftingOperationBonusStatInfo", Nilable = false },
			},
		},
		{
			Name = "CraftingReagent",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "currencyID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CraftingReagentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "dataSlotIndex", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CraftingReagentSlotInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "mcrSlotID", Type = "number", Nilable = false },
				{ Name = "requiredSkillRank", Type = "number", Nilable = false },
				{ Name = "slotText", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CraftingReagentSlotSchematic",
			Type = "Structure",
			Fields =
			{
				{ Name = "reagents", Type = "table", InnerType = "CraftingReagent", Nilable = false },
				{ Name = "reagentType", Type = "CraftingReagentType", Nilable = false },
				{ Name = "quantityRequired", Type = "number", Nilable = false },
				{ Name = "slotInfo", Type = "CraftingReagentSlotInfo", Nilable = true },
				{ Name = "dataSlotType", Type = "TradeskillSlotDataType", Nilable = false, Default = "Reagent" },
				{ Name = "dataSlotIndex", Type = "number", Nilable = false },
				{ Name = "slotIndex", Type = "number", Nilable = false },
				{ Name = "orderSource", Type = "CraftingOrderReagentSource", Nilable = true },
			},
		},
		{
			Name = "CraftingRecipeOutputInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "hyperlink", Type = "string", Nilable = true },
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CraftingRecipeSchematic",
			Type = "Structure",
			Fields =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "quantityMin", Type = "number", Nilable = false },
				{ Name = "quantityMax", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "recipeType", Type = "TradeskillRecipeType", Nilable = false, Default = "Item" },
				{ Name = "productQuality", Type = "number", Nilable = true },
				{ Name = "outputItemID", Type = "number", Nilable = true },
				{ Name = "reagentSlotSchematics", Type = "table", InnerType = "CraftingReagentSlotSchematic", Nilable = false },
				{ Name = "isRecraft", Type = "bool", Nilable = false },
				{ Name = "hasCraftingOperationInfo", Type = "bool", Nilable = false },
				{ Name = "hasGatheringOperationInfo", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CraftingRecipeSkillLineInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "professionSkillLineID", Type = "number", Nilable = false },
				{ Name = "expansionSkillLineID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CraftingResourceReturnInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GatheringOperationBonusStatInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "bonusStatName", Type = "string", Nilable = false },
				{ Name = "bonusStatValue", Type = "number", Nilable = false },
				{ Name = "ratingDescription", Type = "string", Nilable = false },
				{ Name = "ratingPct", Type = "number", Nilable = false },
				{ Name = "bonusRatingPct", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GatheringOperationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "maxDifficulty", Type = "number", Nilable = false },
				{ Name = "baseSkill", Type = "number", Nilable = false },
				{ Name = "bonusSkill", Type = "number", Nilable = false },
				{ Name = "bonusStats", Type = "table", InnerType = "GatheringOperationBonusStatInfo", Nilable = false },
			},
		},
		{
			Name = "ProfessionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "profession", Type = "Profession", Nilable = true },
				{ Name = "professionID", Type = "number", Nilable = false },
				{ Name = "professionName", Type = "string", Nilable = false },
				{ Name = "expansionName", Type = "string", Nilable = false },
				{ Name = "skillLevel", Type = "number", Nilable = false },
				{ Name = "maxSkillLevel", Type = "number", Nilable = false },
				{ Name = "skillModifier", Type = "number", Nilable = false },
				{ Name = "isPrimaryProfession", Type = "bool", Nilable = false },
				{ Name = "parentProfessionID", Type = "number", Nilable = true },
				{ Name = "parentProfessionName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "RegularReagentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TradeSkillRecipeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "relativeDifficulty", Type = "TradeskillRelativeDifficulty", Nilable = true },
				{ Name = "maxTrivialLevel", Type = "number", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "alternateVerb", Type = "string", Nilable = true },
				{ Name = "numSkillUps", Type = "number", Nilable = false },
				{ Name = "canSkillUp", Type = "bool", Nilable = false },
				{ Name = "firstCraft", Type = "bool", Nilable = false },
				{ Name = "sourceType", Type = "number", Nilable = true },
				{ Name = "learned", Type = "bool", Nilable = false },
				{ Name = "disabled", Type = "bool", Nilable = false },
				{ Name = "favorite", Type = "bool", Nilable = false },
				{ Name = "supportsQualities", Type = "bool", Nilable = false },
				{ Name = "craftable", Type = "bool", Nilable = false, Default = true },
				{ Name = "disabledReason", Type = "string", Nilable = true },
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
				{ Name = "previousRecipeID", Type = "number", Nilable = true },
				{ Name = "nextRecipeID", Type = "number", Nilable = true },
				{ Name = "icon", Type = "number", Nilable = true },
				{ Name = "hyperlink", Type = "string", Nilable = true },
				{ Name = "currentRecipeExperience", Type = "number", Nilable = true },
				{ Name = "nextLevelRecipeExperience", Type = "number", Nilable = true },
				{ Name = "unlockedRecipeLevel", Type = "number", Nilable = true },
				{ Name = "earnedExperience", Type = "number", Nilable = true },
				{ Name = "supportsCraftingStats", Type = "bool", Nilable = false, Default = false },
				{ Name = "hasSingleItemOutput", Type = "bool", Nilable = false, Default = false },
				{ Name = "qualityItemIDs", Type = "table", InnerType = "number", Nilable = true },
				{ Name = "qualityIlvlBonuses", Type = "table", InnerType = "number", Nilable = true },
				{ Name = "maxQuality", Type = "number", Nilable = true },
				{ Name = "qualityIDs", Type = "table", InnerType = "number", Nilable = true },
				{ Name = "createsItem", Type = "bool", Nilable = false, Default = true },
				{ Name = "abilityVerb", Type = "string", Nilable = true },
				{ Name = "abilityAllVerb", Type = "string", Nilable = true },
				{ Name = "isRecraft", Type = "bool", Nilable = false, Default = false },
				{ Name = "isDummyRecipe", Type = "bool", Nilable = false, Default = false },
				{ Name = "isGatheringRecipe", Type = "bool", Nilable = false, Default = false },
				{ Name = "isEnchantingRecipe", Type = "bool", Nilable = false, Default = false },
				{ Name = "isSalvageRecipe", Type = "bool", Nilable = false, Default = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TradeSkillUITypes);