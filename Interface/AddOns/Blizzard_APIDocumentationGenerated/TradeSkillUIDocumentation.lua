local TradeSkillUI =
{
	Name = "TradeSkillUI",
	Type = "System",
	Namespace = "C_TradeSkillUI",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetItemReagentQualityInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CraftingQualityInfo", Nilable = true },
			},
		},
		{
			Name = "GetTradeSkillDisplayName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetTradeSkillTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "tradeSkillID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "tradeSkillTexture", Type = "number", Nilable = true },
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
	},

	Events =
	{
		{
			Name = "NewRecipeLearned",
			Type = "Event",
			LiteralName = "NEW_RECIPE_LEARNED",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "TradeSkillClose",
			Type = "Event",
			LiteralName = "TRADE_SKILL_CLOSE",
			SynchronousEvent = true,
		},
		{
			Name = "TradeSkillDataSourceChanged",
			Type = "Event",
			LiteralName = "TRADE_SKILL_DATA_SOURCE_CHANGED",
			UniqueEvent = true,
		},
		{
			Name = "TradeSkillDataSourceChanging",
			Type = "Event",
			LiteralName = "TRADE_SKILL_DATA_SOURCE_CHANGING",
			UniqueEvent = true,
		},
		{
			Name = "TradeSkillDetailsUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_DETAILS_UPDATE",
			UniqueEvent = true,
		},
		{
			Name = "TradeSkillFilterUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_FILTER_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "TradeSkillListUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_LIST_UPDATE",
			UniqueEvent = true,
		},
		{
			Name = "TradeSkillNameUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_NAME_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "TradeSkillShow",
			Type = "Event",
			LiteralName = "TRADE_SKILL_SHOW",
			SynchronousEvent = true,
		},
		{
			Name = "TradeSkillUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateTradeskillRecast",
			Type = "Event",
			LiteralName = "UPDATE_TRADESKILL_RECAST",
			UniqueEvent = true,
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(TradeSkillUI);