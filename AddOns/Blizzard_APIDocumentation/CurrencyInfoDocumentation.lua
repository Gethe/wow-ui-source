local CurrencyInfo =
{
	Name = "CurrencyInfo",
	Type = "System",
	Namespace = "C_CurrencyInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "CurrencyDisplayUpdate",
			Type = "Event",
			LiteralName = "CURRENCY_DISPLAY_UPDATE",
			Payload =
			{
				{ Name = "currencyType", Type = "number", Nilable = true },
				{ Name = "quantity", Type = "number", Nilable = true },
			},
		},
		{
			Name = "PlayerMoney",
			Type = "Event",
			LiteralName = "PLAYER_MONEY",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(CurrencyInfo);