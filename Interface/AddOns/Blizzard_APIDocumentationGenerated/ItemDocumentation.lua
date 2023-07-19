local Item =
{
	Name = "Item",
	Type = "System",
	Namespace = "C_Item",

	Functions =
	{
		{
			Name = "CanItemTransmogAppearance",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "canTransmog", Type = "bool", Nilable = false },
				{ Name = "errorCode", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CanScrapItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "canBeScrapped", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanViewItemPowers",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isItemViewable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DoesItemExist",
			Type = "Function",

			Arguments =
			{
				{ Name = "emptiableItemLocation", Type = "EmptiableItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemExists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DoesItemExistByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemExists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DoesItemMatchBonusTreeReplacement",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "matchesBonusTree", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DoesItemMatchTrackJump",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "matchesTrackJump", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAppliedItemTransmogInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ItemTransmogInfo", Mixin = "ItemTransmogInfoMixin", Nilable = true },
			},
		},
		{
			Name = "GetBaseItemTransmogInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ItemTransmogInfo", Mixin = "ItemTransmogInfoMixin", Nilable = true },
			},
		},
		{
			Name = "GetCurrentItemLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "currentItemLevel", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCurrentItemTransmogInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ItemTransmogInfo", Mixin = "ItemTransmogInfoMixin", Nilable = true },
			},
		},
		{
			Name = "GetItemConversionOutputIcon",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "icon", Type = "fileID", Nilable = true },
			},
		},
		{
			Name = "GetItemGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetItemID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemIDByGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetItemIDForItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemIcon",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "icon", Type = "fileID", Nilable = true },
			},
		},
		{
			Name = "GetItemIconByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "icon", Type = "fileID", Nilable = true },
			},
		},
		{
			Name = "GetItemInventoryType",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "inventoryType", Type = "InventoryType", Nilable = true },
			},
		},
		{
			Name = "GetItemInventoryTypeByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "inventoryType", Type = "InventoryType", Nilable = true },
			},
		},
		{
			Name = "GetItemLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemLink", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetItemLinkByGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemLink", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetItemLocation",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = true },
			},
		},
		{
			Name = "GetItemMaxStackSize",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "stackSize", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetItemMaxStackSizeByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "stackSize", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetItemName",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetItemNameByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
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
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemQuality", Type = "ItemQuality", Nilable = true },
			},
		},
		{
			Name = "GetItemQualityByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemQuality", Type = "ItemQuality", Nilable = true },
			},
		},
		{
			Name = "GetItemUniquenessByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "isUnique", Type = "bool", Nilable = false },
				{ Name = "limitCategoryName", Type = "cstring", Nilable = true },
				{ Name = "limitCategoryCount", Type = "number", Nilable = true },
				{ Name = "limitCategoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetLimitedCurrencyItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "maxQuantity", Type = "number", Nilable = false },
				{ Name = "totalEarned", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetStackCount",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "stackCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsAnimaItemByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAnimaItem", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsBound",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isBound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsDressableItemByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "isDressableItem", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemConduit",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isConduit", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemConvertibleAndValidForPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isItemConvertibleAndValidForPlayer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemCorrupted",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCorrupted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemCorruptionRelated",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCorruptionRelated", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemCorruptionResistant",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCorruptionResistant", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemDataCached",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
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
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCached", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemGUIDInInventory",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "valid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemKeystoneByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "isKeystone", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemSpecificToPlayerClass",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "isItemSpecificToPlayerClass", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLocked",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
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
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "LockItemByGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "RequestLoadItemData",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "RequestLoadItemDataByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},
		},
		{
			Name = "UnlockItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "UnlockItemByGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
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
				{ Name = "itemName", Type = "cstring", Nilable = false },
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
				{ Name = "reason", Type = "cstring", Nilable = false },
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
			Name = "ItemChanged",
			Type = "Event",
			LiteralName = "ITEM_CHANGED",
			Payload =
			{
				{ Name = "previousHyperlink", Type = "string", Nilable = false },
				{ Name = "newHyperlink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ItemConversionDataReady",
			Type = "Event",
			LiteralName = "ITEM_CONVERSION_DATA_READY",
			Payload =
			{
				{ Name = "itemGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "ItemCountChanged",
			Type = "Event",
			LiteralName = "ITEM_COUNT_CHANGED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
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
				{ Name = "itemLink", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ReplaceEnchant",
			Type = "Event",
			LiteralName = "REPLACE_ENCHANT",
			Payload =
			{
				{ Name = "existingStr", Type = "cstring", Nilable = false },
				{ Name = "replacementStr", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ReplaceTradeskillEnchant",
			Type = "Event",
			LiteralName = "REPLACE_TRADESKILL_ENCHANT",
			Payload =
			{
				{ Name = "existing", Type = "cstring", Nilable = false },
				{ Name = "replacement", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "TradeReplaceEnchant",
			Type = "Event",
			LiteralName = "TRADE_REPLACE_ENCHANT",
			Payload =
			{
				{ Name = "existing", Type = "cstring", Nilable = false },
				{ Name = "replacement", Type = "cstring", Nilable = false },
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
		{
			Name = "WeaponEnchantChanged",
			Type = "Event",
			LiteralName = "WEAPON_ENCHANT_CHANGED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Item);