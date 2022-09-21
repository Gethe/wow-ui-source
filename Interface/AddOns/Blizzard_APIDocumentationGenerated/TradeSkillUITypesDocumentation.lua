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
			Name = "CraftingReagent",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "currencyID", Type = "number", Nilable = true },
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
	},
};

APIDocumentation:AddDocumentationTable(TradeSkillUITypes);