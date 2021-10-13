local TradeSkillUI =
{
	Name = "TradeSkillUI",
	Type = "System",
	Namespace = "C_TradeSkillUI",

	Functions =
	{
		{
			Name = "CraftRecipe",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "numCasts", Type = "number", Nilable = false, Default = 1 },
				{ Name = "optionalReagents", Type = "table", InnerType = "OptionalReagentInfo", Nilable = true },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
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
			Name = "GetOptionalReagentBonusText",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "optionalReagentIndex", Type = "number", Nilable = false },
				{ Name = "optionalReagents", Type = "table", InnerType = "OptionalReagentInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "bonusText", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetOptionalReagentInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "OptionalReagentSlot", Nilable = false },
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
			Name = "GetRecipeNumReagents",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "numReagents", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRecipeReagentInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "reagentIndex", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "reagentName", Type = "string", Nilable = true },
				{ Name = "reagentFileID", Type = "number", Nilable = true },
				{ Name = "reagentCount", Type = "number", Nilable = false },
				{ Name = "playerReagentCount", Type = "number", Nilable = false },
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
			Name = "GetTradeSkillLine",
			Type = "Function",

			Returns =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
				{ Name = "skillLineDisplayName", Type = "string", Nilable = false },
				{ Name = "skillLineRank", Type = "number", Nilable = false },
				{ Name = "skillLineMaxRank", Type = "number", Nilable = false },
				{ Name = "skillLineModifier", Type = "number", Nilable = false },
				{ Name = "parentSkillLineID", Type = "number", Nilable = true },
				{ Name = "parentSkillLineDisplayName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetTradeSkillLineInfoByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "skillLineDisplayName", Type = "string", Nilable = false },
				{ Name = "skillLineRank", Type = "number", Nilable = false },
				{ Name = "skillLineMaxRank", Type = "number", Nilable = false },
				{ Name = "skillLineModifier", Type = "number", Nilable = false },
				{ Name = "parentSkillLineID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "IsEmptySkillLineCategory",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "effectivelyKnown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetRecipeRepeatCount",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "numCasts", Type = "number", Nilable = false, Default = 1 },
				{ Name = "optionalReagents", Type = "table", InnerType = "OptionalReagentInfo", Nilable = true },
			},
		},
	},

	Events =
	{
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
			Name = "ObliterumForgeClose",
			Type = "Event",
			LiteralName = "OBLITERUM_FORGE_CLOSE",
		},
		{
			Name = "ObliterumForgePendingItemChanged",
			Type = "Event",
			LiteralName = "OBLITERUM_FORGE_PENDING_ITEM_CHANGED",
		},
		{
			Name = "ObliterumForgeShow",
			Type = "Event",
			LiteralName = "OBLITERUM_FORGE_SHOW",
		},
		{
			Name = "TradeSkillClose",
			Type = "Event",
			LiteralName = "TRADE_SKILL_CLOSE",
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
			Name = "TradeSkillOptionalReagentBonusTextUpdated",
			Type = "Event",
			LiteralName = "TRADE_SKILL_OPTIONAL_REAGENT_BONUS_TEXT_UPDATED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TradeSkillShow",
			Type = "Event",
			LiteralName = "TRADE_SKILL_SHOW",
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
			Name = "OptionalReagentItemFlag",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "TooltipShowsAsStatModifications", Type = "OptionalReagentItemFlag", EnumValue = 0 },
			},
		},
		{
			Name = "OptionalReagentSlot",
			Type = "Structure",
			Fields =
			{
				{ Name = "requiredSkillRank", Type = "number", Nilable = false },
				{ Name = "lockedReason", Type = "string", Nilable = true },
				{ Name = "slotText", Type = "string", Nilable = true },
				{ Name = "options", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TradeSkillUI);