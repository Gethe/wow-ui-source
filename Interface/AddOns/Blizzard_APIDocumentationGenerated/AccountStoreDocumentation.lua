local AccountStore =
{
	Name = "AccountStore",
	Type = "System",
	Namespace = "C_AccountStore",

	Functions =
	{
		{
			Name = "BeginPurchase",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "purchaseStarted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetCategories",
			Type = "Function",

			Arguments =
			{
				{ Name = "storeFrontID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "categories", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetCategoryInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "AccountStoreCategoryInfo", Nilable = false },
			},
		},
		{
			Name = "GetCategoryItems",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyAvailable",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyIDForStore",
			Type = "Function",

			Arguments =
			{
				{ Name = "storeFrontID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "currencyID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCurrencyInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "AccountStoreCurrencyInfo", Nilable = false },
			},
		},
		{
			Name = "GetItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "AccountStoreItemInfo", Nilable = true },
			},
		},
		{
			Name = "GetStoreFrontState",
			Type = "Function",

			Arguments =
			{
				{ Name = "storeFrontID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "state", Type = "AccountStoreState", Nilable = false },
			},
		},
		{
			Name = "RefundItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "refundStarted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestStoreFrontInfoUpdate",
			Type = "Function",

			Arguments =
			{
				{ Name = "storeFrontID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AccountStoreCurrencyAvailableUpdated",
			Type = "Event",
			LiteralName = "ACCOUNT_STORE_CURRENCY_AVAILABLE_UPDATED",
			Payload =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AccountStoreItemInfoUpdated",
			Type = "Event",
			LiteralName = "ACCOUNT_STORE_ITEM_INFO_UPDATED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "StoreFrontStateUpdated",
			Type = "Event",
			LiteralName = "STORE_FRONT_STATE_UPDATED",
			Payload =
			{
				{ Name = "storeFrontID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "AccountStoreCategoryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "type", Type = "AccountStoreCategoryType", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "AccountStoreCurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "amount", Type = "number", Nilable = false },
				{ Name = "maxQuantity", Type = "number", Nilable = true },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "AccountStoreItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "status", Type = "AccountStoreItemStatus", Nilable = false },
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "flags", Type = "AccountStoreItemFlag", Nilable = false },
				{ Name = "customUIModelSceneID", Type = "number", Nilable = true },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = true },
				{ Name = "price", Type = "number", Nilable = false },
				{ Name = "nonrefundable", Type = "bool", Nilable = false },
				{ Name = "creatureDisplayID", Type = "number", Nilable = true },
				{ Name = "transmogSetID", Type = "number", Nilable = true },
				{ Name = "displayIcon", Type = "fileID", Nilable = true },
				{ Name = "refundSecondsRemaining", Type = "time_t", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AccountStore);