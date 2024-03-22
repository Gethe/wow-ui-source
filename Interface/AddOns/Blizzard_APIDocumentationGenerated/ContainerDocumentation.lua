local Container =
{
	Name = "Container",
	Type = "System",
	Namespace = "C_Container",

	Functions =
	{
		{
			Name = "ContainerIDToInventoryID",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerID", Type = "BagIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "inventoryID", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "ContainerRefundItemPurchase",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "isEquipped", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "GetBagName",
			Type = "Function",

			Arguments =
			{
				{ Name = "bagIndex", Type = "BagIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetBagSlotFlag",
			Type = "Function",

			Arguments =
			{
				{ Name = "bagIndex", Type = "BagIndex", Nilable = false },
				{ Name = "flag", Type = "BagSlotFlags", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSet", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetContainerFreeSlots",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "freeSlots", Type = "table", InnerType = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetContainerItemCooldown",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "enable", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetContainerItemDurability",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "durability", Type = "number", Nilable = false },
				{ Name = "maxDurability", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetContainerItemGems",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "numGems", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetContainerItemID",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "containerID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetContainerItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "containerInfo", Type = "ContainerItemInfo", Nilable = false },
			},
		},
		{
			Name = "GetContainerItemLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemLink", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetContainerItemPurchaseCurrency",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "itemIndex", Type = "luaIndex", Nilable = false },
				{ Name = "isEquipped", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "currencyInfo", Type = "ItemPurchaseCurrency", Nilable = false },
			},
		},
		{
			Name = "GetContainerItemPurchaseInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "isEquipped", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ItemPurchaseInfo", Nilable = false },
			},
		},
		{
			Name = "GetContainerItemPurchaseItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "itemIndex", Type = "luaIndex", Nilable = false },
				{ Name = "isEquipped", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemInfo", Type = "ItemPurchaseItem", Nilable = false },
			},
		},
		{
			Name = "GetContainerItemQuestInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "questInfo", Type = "ItemQuestInfo", Nilable = false },
			},
		},
		{
			Name = "GetContainerNumFreeSlots",
			Type = "Function",

			Arguments =
			{
				{ Name = "bagIndex", Type = "BagIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "numFreeSlots", Type = "number", Nilable = false },
				{ Name = "bagFamily", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetContainerNumSlots",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "numSlots", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetInsertItemsLeftToRight",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetItemCooldown",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "enable", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsBagSlotFlagEnabledOnOtherBankBags",
			Type = "Function",

			Arguments =
			{
				{ Name = "bagIndex", Type = "BagIndex", Nilable = false },
				{ Name = "flagIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSet", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsContainerFiltered",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFiltered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PickupContainerItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SetBagPortraitTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
				{ Name = "bagIndex", Type = "BagIndex", Nilable = false },
			},
		},
		{
			Name = "SetBagSlotFlag",
			Type = "Function",

			Arguments =
			{
				{ Name = "bagIndex", Type = "BagIndex", Nilable = false },
				{ Name = "flag", Type = "BagSlotFlags", Nilable = false },
				{ Name = "isSet", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetInsertItemsLeftToRight",
			Type = "Function",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetItemSearch",
			Type = "Function",

			Arguments =
			{
				{ Name = "searchString", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ShowContainerSellCursor",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SocketContainerItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SplitContainerItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UseContainerItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "unitToken", Type = "UnitToken", Nilable = true },
				{ Name = "reagentBankOpen", Type = "bool", Nilable = false, Default = false },
			},
		},
	},

	Events =
	{
		{
			Name = "BagClosed",
			Type = "Event",
			LiteralName = "BAG_CLOSED",
			Payload =
			{
				{ Name = "bagID", Type = "BagIndex", Nilable = false },
			},
		},
		{
			Name = "BagContainerUpdate",
			Type = "Event",
			LiteralName = "BAG_CONTAINER_UPDATE",
		},
		{
			Name = "BagNewItemsUpdated",
			Type = "Event",
			LiteralName = "BAG_NEW_ITEMS_UPDATED",
		},
		{
			Name = "BagOpen",
			Type = "Event",
			LiteralName = "BAG_OPEN",
			Payload =
			{
				{ Name = "bagID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BagOverflowWithFullInventory",
			Type = "Event",
			LiteralName = "BAG_OVERFLOW_WITH_FULL_INVENTORY",
		},
		{
			Name = "BagSlotFlagsUpdated",
			Type = "Event",
			LiteralName = "BAG_SLOT_FLAGS_UPDATED",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BagUpdate",
			Type = "Event",
			LiteralName = "BAG_UPDATE",
			Payload =
			{
				{ Name = "bagID", Type = "BagIndex", Nilable = false },
			},
		},
		{
			Name = "BagUpdateCooldown",
			Type = "Event",
			LiteralName = "BAG_UPDATE_COOLDOWN",
		},
		{
			Name = "BagUpdateDelayed",
			Type = "Event",
			LiteralName = "BAG_UPDATE_DELAYED",
		},
		{
			Name = "EquipBindRefundableConfirm",
			Type = "Event",
			LiteralName = "EQUIP_BIND_REFUNDABLE_CONFIRM",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EquipBindTradeableConfirm",
			Type = "Event",
			LiteralName = "EQUIP_BIND_TRADEABLE_CONFIRM",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ExpandBagBarChanged",
			Type = "Event",
			LiteralName = "EXPAND_BAG_BAR_CHANGED",
			Payload =
			{
				{ Name = "expandBagBar", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "InventorySearchUpdate",
			Type = "Event",
			LiteralName = "INVENTORY_SEARCH_UPDATE",
		},
		{
			Name = "ItemLockChanged",
			Type = "Event",
			LiteralName = "ITEM_LOCK_CHANGED",
			Payload =
			{
				{ Name = "bagOrSlotIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "ItemLocked",
			Type = "Event",
			LiteralName = "ITEM_LOCKED",
			Payload =
			{
				{ Name = "bagOrSlotIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "ItemUnlocked",
			Type = "Event",
			LiteralName = "ITEM_UNLOCKED",
			Payload =
			{
				{ Name = "bagOrSlotIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "UseCombinedBagsChanged",
			Type = "Event",
			LiteralName = "USE_COMBINED_BAGS_CHANGED",
			Payload =
			{
				{ Name = "useCombinedBags", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "ContainerItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "iconFileID", Type = "fileID", Nilable = false },
				{ Name = "stackCount", Type = "number", Nilable = false },
				{ Name = "isLocked", Type = "bool", Nilable = false },
				{ Name = "quality", Type = "ItemQuality", Nilable = true },
				{ Name = "isReadable", Type = "bool", Nilable = false },
				{ Name = "hasLoot", Type = "bool", Nilable = false },
				{ Name = "hyperlink", Type = "string", Nilable = false },
				{ Name = "isFiltered", Type = "bool", Nilable = false },
				{ Name = "hasNoValue", Type = "bool", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "isBound", Type = "bool", Nilable = false },
				{ Name = "itemName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ItemPurchaseCurrency",
			Type = "Structure",
			Fields =
			{
				{ Name = "iconFileID", Type = "number", Nilable = true },
				{ Name = "currencyCount", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ItemPurchaseInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "money", Type = "WOWMONEY", Nilable = false },
				{ Name = "itemCount", Type = "number", Nilable = false },
				{ Name = "refundSeconds", Type = "time_t", Nilable = false },
				{ Name = "currencyCount", Type = "number", Nilable = false },
				{ Name = "hasEnchants", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ItemPurchaseItem",
			Type = "Structure",
			Fields =
			{
				{ Name = "iconFileID", Type = "number", Nilable = true },
				{ Name = "itemCount", Type = "number", Nilable = false },
				{ Name = "hyperlink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ItemQuestInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "isQuestItem", Type = "bool", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Container);