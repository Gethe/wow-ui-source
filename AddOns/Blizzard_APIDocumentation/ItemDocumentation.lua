local Item =
{
	Name = "Item",
	Type = "System",
	Namespace = "C_Item",

	Functions =
	{
		{
			Name = "DoesItemExist",
			Type = "Function",

			Arguments =
			{
				{ Name = "emptiableItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemExists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetCurrentItemLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "currentItemLevel", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetItemName",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetItemQuality",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemQuality", Type = "ItemQuality", Nilable = true },
			},
		},
		{
			Name = "IsBound",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isBound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemDataCached",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCached", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemDataCachedByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCached", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLocked",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isLocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LockItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "RequestLoadItemData",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "RequestLoadItemDataByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnlockItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ActionWillBindItem",
			Type = "Event",
			LiteralName = "ACTION_WILL_BIND_ITEM",
		},
		{
			Name = "BindEnchant",
			Type = "Event",
			LiteralName = "BIND_ENCHANT",
		},
		{
			Name = "CharacterItemFixupNotification",
			Type = "Event",
			LiteralName = "CHARACTER_ITEM_FIXUP_NOTIFICATION",
			Payload =
			{
				{ Name = "fixupVersion", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ConfirmBeforeUse",
			Type = "Event",
			LiteralName = "CONFIRM_BEFORE_USE",
		},
		{
			Name = "DeleteItemConfirm",
			Type = "Event",
			LiteralName = "DELETE_ITEM_CONFIRM",
			Payload =
			{
				{ Name = "itemName", Type = "string", Nilable = false },
				{ Name = "qualityID", Type = "number", Nilable = false },
				{ Name = "bonding", Type = "number", Nilable = false },
				{ Name = "questWarn", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EndBoundTradeable",
			Type = "Event",
			LiteralName = "END_BOUND_TRADEABLE",
			Payload =
			{
				{ Name = "reason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetItemInfoReceived",
			Type = "Event",
			LiteralName = "GET_ITEM_INFO_RECEIVED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ItemDataLoadResult",
			Type = "Event",
			LiteralName = "ITEM_DATA_LOAD_RESULT",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MerchantConfirmTradeTimerRemoval",
			Type = "Event",
			LiteralName = "MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL",
			Payload =
			{
				{ Name = "itemLink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ReplaceEnchant",
			Type = "Event",
			LiteralName = "REPLACE_ENCHANT",
			Payload =
			{
				{ Name = "existingStr", Type = "string", Nilable = false },
				{ Name = "replacementStr", Type = "string", Nilable = false },
			},
		},
		{
			Name = "TradeReplaceEnchant",
			Type = "Event",
			LiteralName = "TRADE_REPLACE_ENCHANT",
			Payload =
			{
				{ Name = "existing", Type = "string", Nilable = false },
				{ Name = "replacement", Type = "string", Nilable = false },
			},
		},
		{
			Name = "UseBindConfirm",
			Type = "Event",
			LiteralName = "USE_BIND_CONFIRM",
		},
		{
			Name = "UseNoRefundConfirm",
			Type = "Event",
			LiteralName = "USE_NO_REFUND_CONFIRM",
		},
	},

	Tables =
	{
		{
			Name = "ItemQuality",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "ItemQualityPoor", Type = "ItemQuality", EnumValue = 0 },
				{ Name = "ItemQualityStandard", Type = "ItemQuality", EnumValue = 1 },
				{ Name = "ItemQualityGood", Type = "ItemQuality", EnumValue = 2 },
				{ Name = "ItemQualitySuperior", Type = "ItemQuality", EnumValue = 3 },
				{ Name = "ItemQualityEpic", Type = "ItemQuality", EnumValue = 4 },
				{ Name = "ItemQualityLegendary", Type = "ItemQuality", EnumValue = 5 },
				{ Name = "ItemQualityArtifact", Type = "ItemQuality", EnumValue = 6 },
				{ Name = "ItemQualityHeirloom", Type = "ItemQuality", EnumValue = 7 },
				{ Name = "ItemQualityWoWToken", Type = "ItemQuality", EnumValue = 8 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Item);