local CurrencyConstants_Mainline =
{
	Tables =
	{
		{
			Name = "CurrencyDestroyReason",
			Type = "Enumeration",
			NumValues = 18,
			MinValue = 0,
			MaxValue = 17,
			Fields =
			{
				{ Name = "Cheat", Type = "CurrencyDestroyReason", EnumValue = 0 },
				{ Name = "Spell", Type = "CurrencyDestroyReason", EnumValue = 1 },
				{ Name = "VersionUpdate", Type = "CurrencyDestroyReason", EnumValue = 2 },
				{ Name = "QuestTurnin", Type = "CurrencyDestroyReason", EnumValue = 3 },
				{ Name = "Vendor", Type = "CurrencyDestroyReason", EnumValue = 4 },
				{ Name = "Trade", Type = "CurrencyDestroyReason", EnumValue = 5 },
				{ Name = "Capped", Type = "CurrencyDestroyReason", EnumValue = 6 },
				{ Name = "Garrison", Type = "CurrencyDestroyReason", EnumValue = 7 },
				{ Name = "DroppedToCorpse", Type = "CurrencyDestroyReason", EnumValue = 8 },
				{ Name = "BonusRoll", Type = "CurrencyDestroyReason", EnumValue = 9 },
				{ Name = "FactionConversion", Type = "CurrencyDestroyReason", EnumValue = 10 },
				{ Name = "FulfillCraftingOrder", Type = "CurrencyDestroyReason", EnumValue = 11 },
				{ Name = "Script", Type = "CurrencyDestroyReason", EnumValue = 12 },
				{ Name = "ConcentrationCast", Type = "CurrencyDestroyReason", EnumValue = 13 },
				{ Name = "AccountTransfer", Type = "CurrencyDestroyReason", EnumValue = 14 },
				{ Name = "HonorLoss", Type = "CurrencyDestroyReason", EnumValue = 15 },
				{ Name = "CraftingOrderReagent", Type = "CurrencyDestroyReason", EnumValue = 16 },
				{ Name = "AccountServerConversion", Type = "CurrencyDestroyReason", EnumValue = 17 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CurrencyConstants_Mainline);