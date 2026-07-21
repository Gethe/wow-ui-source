local MoneyConstants =
{
	Tables =
	{
		{
			Name = "CurrencyType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Copper", Type = "CurrencyType", EnumValue = 0 },
				{ Name = "Silver", Type = "CurrencyType", EnumValue = 1 },
				{ Name = "Gold", Type = "CurrencyType", EnumValue = 2 },
			},
		},
		{
			Name = "MoneyFormattingConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "GOLD_REWARD_THRESHOLD_TO_HIDE_COPPER", Type = "number", Value = 10 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(MoneyConstants);