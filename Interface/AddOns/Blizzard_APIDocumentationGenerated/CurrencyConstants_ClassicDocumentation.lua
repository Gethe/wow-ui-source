local CurrencyConstants_Classic =
{
	Tables =
	{
		{
			Name = "CurrencyDestroyReason",
			Type = "Enumeration",
			NumValues = 11,
			MinValue = 0,
			MaxValue = 10,
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
				{ Name = "LegacyConversion", Type = "CurrencyDestroyReason", EnumValue = 10 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CurrencyConstants_Classic);