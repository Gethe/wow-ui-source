local TradeSkillUITypes =
{
	Tables =
	{
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
				{ Name = "itemID", Type = "number", Nilable = false },
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
};

APIDocumentation:AddDocumentationTable(TradeSkillUITypes);