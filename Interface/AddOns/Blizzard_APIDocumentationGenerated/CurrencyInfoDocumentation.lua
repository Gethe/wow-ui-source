local CurrencyInfo =
{
	Name = "CurrencySystem",
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
			Name = "GetCoinIcon",
			Type = "Function",

			Arguments =
			{
				{ Name = "amount", Type = "WOWMONEY", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "GetCoinText",
			Type = "Function",

			Arguments =
			{
				{ Name = "amount", Type = "WOWMONEY", Nilable = false },
				{ Name = "separator", Type = "cstring", Nilable = false, Default = ", " },
			},

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetCoinTextureString",
			Type = "Function",

			Arguments =
			{
				{ Name = "amount", Type = "WOWMONEY", Nilable = false },
				{ Name = "fontHeight", Type = "number", Nilable = false, Default = 14 },
			},

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
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
		{
			Name = "GetCurrencyListLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsCurrencyContainer",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCurrencyContainer", Type = "bool", Nilable = false },
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
		{
			Name = "CurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "isHeader", Type = "bool", Nilable = false },
				{ Name = "isHeaderExpanded", Type = "bool", Nilable = false },
				{ Name = "isTypeUnused", Type = "bool", Nilable = false },
				{ Name = "isShowInBackpack", Type = "bool", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "trackedQuantity", Type = "number", Nilable = false },
				{ Name = "iconFileID", Type = "fileID", Nilable = false },
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