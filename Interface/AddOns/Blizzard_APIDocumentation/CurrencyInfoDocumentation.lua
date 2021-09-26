local CurrencyInfo =
{
	Name = "CurrencySystem",
	Type = "System",
	Namespace = "C_CurrencyInfo",

	Functions =
	{
		{
			Name = "GetCurrencyInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CurrencyInfo", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyInfoFromLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CurrencyInfo", Nilable = false },
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
				{ Name = "quantityChange", Type = "number", Nilable = true },
				{ Name = "quantityGainSource", Type = "number", Nilable = true },
				{ Name = "quantityLostSource", Type = "number", Nilable = true },
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
			Name = "CurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "isHeader", Type = "bool", Nilable = false },
				{ Name = "isHeaderExpanded", Type = "bool", Nilable = false },
				{ Name = "isTypeUnused", Type = "bool", Nilable = false },
				{ Name = "isShowInBackpack", Type = "bool", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "trackedQuantity", Type = "number", Nilable = false },
				{ Name = "iconFileID", Type = "number", Nilable = false },
				{ Name = "maxQuantity", Type = "number", Nilable = false },
				{ Name = "canEarnPerWeek", Type = "bool", Nilable = false },
				{ Name = "quantityEarnedThisWeek", Type = "number", Nilable = false },
				{ Name = "isTradeable", Type = "bool", Nilable = false },
				{ Name = "quality", Type = "ItemQuality", Nilable = false },
				{ Name = "maxWeeklyQuantity", Type = "number", Nilable = false },
				{ Name = "totalEarned", Type = "number", Nilable = false },
				{ Name = "discovered", Type = "bool", Nilable = false },
				{ Name = "useTotalEarnedForMaxQty", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CurrencyInfo);