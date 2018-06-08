local TradeSkillUI =
{
	Name = "TradeSkillUI",
	Type = "System",
	Namespace = "C_TradeSkillUI",

	Functions =
	{
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
	},

	Events =
	{
		{
			Name = "NewRecipeLearned",
			Type = "Event",
			LiteralName = "NEW_RECIPE_LEARNED",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
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
	},
};

APIDocumentation:AddDocumentationTable(TradeSkillUI);