local CurrencyInfo =
{
	Name = "CurrencyInfo",
	Type = "System",
	Namespace = "C_CurrencyInfo",

	Functions =
	{
		{
			Name = "GetBasicCurrencyInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyType", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "info", Type = "CurrencyDisplayInfo", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyContainerInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyType", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CurrencyDisplayInfo", Nilable = false },
			},
		},
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
		{
			Name = "CurrencyDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "displayAmount", Type = "number", Nilable = false },
				{ Name = "actualAmount", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CurrencyInfo);