local TradeSkillUITypes =
{
	Tables =
	{
		{
			Name = "CraftingReagentItemFlag",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "TooltipShowsAsStatModifications", Type = "CraftingReagentItemFlag", EnumValue = 1 },
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
			Name = "CraftingItemSlotModification",
			Type = "Structure",
			Fields =
			{
				{ Name = "dataSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "reagent", Type = "CraftingReagent", Nilable = false },
			},
		},
		{
			Name = "CraftingQualityInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "icon", Type = "textureAtlas", Nilable = false },
				{ Name = "iconSmall", Type = "textureAtlas", Nilable = false },
				{ Name = "iconInventory", Type = "textureAtlas", Nilable = false },
				{ Name = "iconMixed", Type = "textureAtlas", Nilable = false },
				{ Name = "iconAppear", Type = "textureAtlas", Nilable = false },
				{ Name = "iconDissolve", Type = "textureAtlas", Nilable = false },
				{ Name = "barFill", Type = "textureAtlas", Nilable = false },
				{ Name = "barBackground", Type = "textureAtlas", Nilable = false },
				{ Name = "barBackgroundCap", Type = "textureAtlas", Nilable = false },
				{ Name = "barHighlight", Type = "textureAtlas", Nilable = false },
				{ Name = "iconChat", Type = "textureAtlas", Nilable = false },
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
				{ Name = "slot", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RegularReagentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "reagent", Type = "CraftingReagent", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TradeSkillReagentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "reagentName", Type = "cstring", Nilable = true },
				{ Name = "reagentFileID", Type = "fileID", Nilable = true },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "reagentCount", Type = "number", Nilable = false },
				{ Name = "playerReagentCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TradeSkillRecipeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "string", Nilable = false, Default = "recipe" },
				{ Name = "categoryID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "difficulty", Type = "cstring", Nilable = true },
				{ Name = "relativeDifficulty", Type = "TradeskillRelativeDifficulty", Nilable = true },
				{ Name = "maxTrivialLevel", Type = "number", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "numAvailable", Type = "number", Nilable = false },
				{ Name = "alternateVerb", Type = "cstring", Nilable = true },
				{ Name = "numSkillUps", Type = "number", Nilable = false },
				{ Name = "numIndents", Type = "number", Nilable = false },
				{ Name = "sourceType", Type = "number", Nilable = true },
				{ Name = "learned", Type = "bool", Nilable = false },
				{ Name = "disabled", Type = "bool", Nilable = false },
				{ Name = "favorite", Type = "bool", Nilable = false },
				{ Name = "hiddenUnlessLearned", Type = "bool", Nilable = false },
				{ Name = "craftable", Type = "bool", Nilable = false, Default = true },
				{ Name = "disabledReason", Type = "cstring", Nilable = true },
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "previousRecipeID", Type = "number", Nilable = true },
				{ Name = "nextRecipeID", Type = "number", Nilable = true },
				{ Name = "icon", Type = "number", Nilable = true },
				{ Name = "productQuality", Type = "number", Nilable = true },
				{ Name = "currentRecipeExperience", Type = "number", Nilable = true },
				{ Name = "nextLevelRecipeExperience", Type = "number", Nilable = true },
				{ Name = "unlockedRecipeLevel", Type = "number", Nilable = true },
				{ Name = "earnedExperience", Type = "number", Nilable = true },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(TradeSkillUITypes);