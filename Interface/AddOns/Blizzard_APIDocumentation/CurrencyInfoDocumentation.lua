local CurrencyInfo =
{
	Name = "CurrencySystem",
	Type = "System",
	Namespace = "C_CurrencyInfo",

	Functions =
	{
		{
			Name = "DoesWarModeBonusApply",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "warModeApplies", Type = "bool", Nilable = true },
				{ Name = "limitOncePerTooltip", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "ExpandCurrencyList",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "expand", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAzeriteCurrencyID",
			Type = "Function",

			Returns =
			{
				{ Name = "azeriteCurrencyID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetBackpackCurrencyInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "BackpackCurrencyInfo", Nilable = false },
			},
		},
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
		{
			Name = "GetCurrencyIDFromLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyLink", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
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
			Name = "GetCurrencyLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "number", Nilable = false },
				{ Name = "amount", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyListInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
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
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyListSize",
			Type = "Function",

			Returns =
			{
				{ Name = "currencyListSize", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFactionGrantedByCurrency",
			Type = "Function",
			Documentation = { "Gets the faction ID for currency that is immediately converted into reputation with that faction instead." },

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "factionID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetWarResourcesCurrencyID",
			Type = "Function",

			Returns =
			{
				{ Name = "warResourceCurrencyID", Type = "number", Nilable = false },
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
		{
			Name = "PickupCurrency",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCurrencyBackpack",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "backpack", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCurrencyUnused",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "unused", Type = "bool", Nilable = false },
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
			Name = "BackpackCurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "iconFileID", Type = "number", Nilable = false },
				{ Name = "currencyTypesID", Type = "number", Nilable = false },
			},
		},
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
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "isHeader", Type = "bool", Nilable = false },
				{ Name = "isHeaderExpanded", Type = "bool", Nilable = false },
				{ Name = "isTypeUnused", Type = "bool", Nilable = false },
				{ Name = "isShowInBackpack", Type = "bool", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
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