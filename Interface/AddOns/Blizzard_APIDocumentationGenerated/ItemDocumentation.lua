local Item =
{
	Name = "Item",
	Type = "System",
	Namespace = "C_Item",

	Functions =
	{
		{
			Name = "ActionBindsItem",
			Type = "Function",
		},
		{
			Name = "BindEnchant",
			Type = "Function",
		},
		{
			Name = "ConfirmBindOnUse",
			Type = "Function",
		},
		{
			Name = "ConfirmNoRefundOnUse",
			Type = "Function",
		},
		{
			Name = "ConfirmOnUse",
			Type = "Function",
		},
		{
			Name = "DoesItemContainSpec",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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
			Name = "DropItemOnUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitGUID", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "EndBoundTradeable",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "EndRefund",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EquipItemByName",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "dstSlot", Type = "luaIndex", Nilable = true },
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
			Name = "GetDetailedItemLevelInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "actualItemLevel", Type = "number", Nilable = false },
				{ Name = "previewLevel", Type = "bool", Nilable = false },
				{ Name = "sparseItemLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemChildInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "slotID", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemClassInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemClassID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetItemCount",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "includeBank", Type = "bool", Nilable = false, Default = false },
				{ Name = "includeUses", Type = "bool", Nilable = false, Default = false },
				{ Name = "includeReagentBank", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemCreationContext",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "creationContext", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetItemFamily",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
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
			Name = "GetItemGem",
			Type = "Function",

			Arguments =
			{
				{ Name = "hyperlink", Type = "cstring", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "gemName", Type = "string", Nilable = false },
				{ Name = "gemLink", Type = "cstring", Nilable = false },
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
			Name = "GetItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemName", Type = "cstring", Nilable = false },
				{ Name = "itemLink", Type = "cstring", Nilable = false },
				{ Name = "itemQuality", Type = "ItemQuality", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "itemMinLevel", Type = "number", Nilable = false },
				{ Name = "itemType", Type = "cstring", Nilable = false },
				{ Name = "itemSubType", Type = "cstring", Nilable = false },
				{ Name = "itemStackCount", Type = "number", Nilable = false },
				{ Name = "itemEquipLoc", Type = "cstring", Nilable = false },
				{ Name = "itemTexture", Type = "fileID", Nilable = false },
				{ Name = "sellPrice", Type = "number", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
				{ Name = "subclassID", Type = "number", Nilable = false },
				{ Name = "bindType", Type = "number", Nilable = false },
				{ Name = "expansionID", Type = "number", Nilable = false },
				{ Name = "setID", Type = "number", Nilable = true },
				{ Name = "isCraftingReagent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetItemInfoInstant",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemType", Type = "cstring", Nilable = false },
				{ Name = "itemSubType", Type = "cstring", Nilable = false },
				{ Name = "itemEquipLoc", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
				{ Name = "subClassID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemInventorySlotInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "inventorySlot", Type = "InventoryType", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
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
			Name = "GetItemQualityColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "quality", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "colorRGBR", Type = "number", Nilable = false },
				{ Name = "colorRGBG", Type = "number", Nilable = false },
				{ Name = "colorRGBB", Type = "number", Nilable = false },
				{ Name = "qualityString", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetItemSetInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "setID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetItemSpecInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "specTable", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellName", Type = "cstring", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemSubClassInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemClassID", Type = "number", Nilable = false },
				{ Name = "itemSubClassID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "subClassName", Type = "cstring", Nilable = false },
				{ Name = "subClassUsesInvType", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetItemUniqueness",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "limitCategory", Type = "number", Nilable = false },
				{ Name = "limitMax", Type = "number", Nilable = false },
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
			Name = "IsArtifactPowerItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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
			Name = "IsConsumableItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCurrentItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsDressableItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEquippableItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEquippedItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEquippedItemType",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHarmfulItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHelpfulItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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
			Name = "IsItemInRange",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "targetToken", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = true },
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
			Name = "IsUsableItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "usable", Type = "bool", Nilable = false },
				{ Name = "noMana", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ItemHasRange",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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
			Name = "PickupItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},
		},
		{
			Name = "ReplaceEnchant",
			Type = "Function",
		},
		{
			Name = "ReplaceTradeEnchant",
			Type = "Function",
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
		{
			Name = "UseItemByName",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "target", Type = "cstring", Nilable = true },
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
	},

	Tables =
	{
		{
			Name = "ItemInfoResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemName", Type = "cstring", Nilable = false },
				{ Name = "itemLink", Type = "cstring", Nilable = false },
				{ Name = "itemQuality", Type = "ItemQuality", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "itemMinLevel", Type = "number", Nilable = false },
				{ Name = "itemType", Type = "cstring", Nilable = false },
				{ Name = "itemSubType", Type = "cstring", Nilable = false },
				{ Name = "itemStackCount", Type = "number", Nilable = false },
				{ Name = "itemEquipLoc", Type = "cstring", Nilable = false },
				{ Name = "itemTexture", Type = "fileID", Nilable = false },
				{ Name = "sellPrice", Type = "number", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
				{ Name = "subclassID", Type = "number", Nilable = false },
				{ Name = "bindType", Type = "number", Nilable = false },
				{ Name = "expansionID", Type = "number", Nilable = false },
				{ Name = "setID", Type = "number", Nilable = true },
				{ Name = "isCraftingReagent", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Item);