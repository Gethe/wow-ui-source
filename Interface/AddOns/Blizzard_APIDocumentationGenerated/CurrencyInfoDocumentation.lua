local CurrencyInfo =
{
	Name = "CurrencySystem",
	Type = "System",
	Namespace = "C_CurrencyInfo",

	Functions =
	{
		{
			Name = "CanTransferCurrency",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canTransferCurrency", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "AccountCurrencyTransferResult", Nilable = true },
			},
		},
		{
			Name = "DoesCurrentFilterRequireAccountCurrencyData",
			Type = "Function",

			Returns =
			{
				{ Name = "doesCurrentFilterRequireAccountCurrencyData", Type = "bool", Nilable = false },
			},
		},
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
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "expand", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "FetchCurrencyDataFromAccountCharacters",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "accountCurrencyData", Type = "table", InnerType = "CharacterCurrencyData", Nilable = false },
			},
		},
		{
			Name = "FetchCurrencyTransferTransactions",
			Type = "Function",

			Returns =
			{
				{ Name = "currencyTransferTransactions", Type = "table", InnerType = "CurrencyTransferTransaction", Nilable = false },
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
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "BackpackCurrencyInfo", Nilable = false },
			},
		},
		{
			Name = "GetBasicCurrencyInfo",
			Type = "Function",
			MayReturnNothing = true,

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
			Name = "GetCostToTransferCurrency",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "totalQuantityConsumed", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCurrencyContainerInfo",
			Type = "Function",
			MayReturnNothing = true,

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
			Name = "GetCurrencyDescription",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "description", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyFilter",
			Type = "Function",

			Returns =
			{
				{ Name = "filterType", Type = "CurrencyFilterType", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyIDFromLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyLink", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyInfo",
			Type = "Function",
			MayReturnNothing = true,

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
			MayReturnNothing = true,

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
				{ Name = "amount", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "link", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyListInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
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
			Name = "GetCurrencyListSize",
			Type = "Function",

			Returns =
			{
				{ Name = "currencyListSize", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDragonIslesSuppliesCurrencyID",
			Type = "Function",

			Returns =
			{
				{ Name = "dragonIslesSuppliesCurrencyID", Type = "number", Nilable = false },
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
			Name = "GetMaxTransferableAmountFromQuantity",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "requestedQuantity", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "maxTransferableAmount", Type = "number", Nilable = true },
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
			Name = "IsAccountCharacterCurrencyDataReady",
			Type = "Function",

			Returns =
			{
				{ Name = "isReady", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAccountTransferableCurrency",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAccountTransferableCurrency", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAccountWideCurrency",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAccountWideCurrency", Type = "bool", Nilable = false },
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
			Name = "IsCurrencyTransferInProgress",
			Type = "Function",

			Returns =
			{
				{ Name = "currencyTransferInProgress", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCurrencyTransferTransactionDataReady",
			Type = "Function",

			Returns =
			{
				{ Name = "isReady", Type = "bool", Nilable = false },
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
			Name = "PlayerHasMaxQuantity",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasMaxQuantity", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerHasMaxWeeklyQuantity",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasMaxWeeklyQuantity", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestCurrencyDataForAccountCharacters",
			Type = "Function",
		},
		{
			Name = "RequestCurrencyFromAccountCharacter",
			Type = "Function",

			Arguments =
			{
				{ Name = "sourceCharacterGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCurrencyBackpack",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "backpack", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCurrencyBackpackByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyType", Type = "number", Nilable = false },
				{ Name = "backpack", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCurrencyFilter",
			Type = "Function",

			Arguments =
			{
				{ Name = "filterType", Type = "CurrencyFilterType", Nilable = false },
			},
		},
		{
			Name = "SetCurrencyUnused",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "unused", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AccountCharacterCurrencyDataReceived",
			Type = "Event",
			LiteralName = "ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED",
		},
		{
			Name = "AccountMoney",
			Type = "Event",
			LiteralName = "ACCOUNT_MONEY",
		},
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
				{ Name = "destroyReason", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CurrencyTransferFailed",
			Type = "Event",
			LiteralName = "CURRENCY_TRANSFER_FAILED",
			Payload =
			{
				{ Name = "failureReason", Type = "AccountCurrencyTransferResult", Nilable = false },
			},
		},
		{
			Name = "CurrencyTransferInitiated",
			Type = "Event",
			LiteralName = "CURRENCY_TRANSFER_INITIATED",
		},
		{
			Name = "CurrencyTransferLogUpdate",
			Type = "Event",
			LiteralName = "CURRENCY_TRANSFER_LOG_UPDATE",
		},
		{
			Name = "CurrencyTransferSuccess",
			Type = "Event",
			LiteralName = "CURRENCY_TRANSFER_SUCCESS",
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
				{ Name = "iconFileID", Type = "fileID", Nilable = false },
				{ Name = "currencyTypesID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CharacterCurrencyData",
			Type = "Structure",
			Fields =
			{
				{ Name = "characterGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "characterName", Type = "string", Nilable = false },
				{ Name = "fullCharacterName", Type = "string", Nilable = false },
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
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
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "isHeader", Type = "bool", Nilable = false },
				{ Name = "isHeaderExpanded", Type = "bool", Nilable = false },
				{ Name = "currencyListDepth", Type = "number", Nilable = false },
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
				{ Name = "isAccountWide", Type = "bool", Nilable = false },
				{ Name = "isAccountTransferable", Type = "bool", Nilable = false },
				{ Name = "transferPercentage", Type = "number", Nilable = true },
				{ Name = "rechargingCycleDurationMS", Type = "number", Nilable = false },
				{ Name = "rechargingAmountPerCycle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CurrencyTransferTransaction",
			Type = "Structure",
			Fields =
			{
				{ Name = "sourceCharacterGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "sourceCharacterName", Type = "string", Nilable = false, Default = "" },
				{ Name = "fullSourceCharacterName", Type = "string", Nilable = false, Default = "" },
				{ Name = "destinationCharacterGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "destinationCharacterName", Type = "string", Nilable = false, Default = "" },
				{ Name = "fullDestinationCharacterName", Type = "string", Nilable = false, Default = "" },
				{ Name = "currencyType", Type = "number", Nilable = false },
				{ Name = "quantityTransferred", Type = "number", Nilable = false },
				{ Name = "totalQuantityConsumed", Type = "number", Nilable = false },
				{ Name = "timestamp", Type = "time_t", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CurrencyInfo);