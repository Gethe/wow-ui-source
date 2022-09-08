local Container =
{
	Name = "Container",
	Type = "System",
	Namespace = "C_Container",

	Functions =
	{
		{
			Name = "GetBagSlotFlag",
			Type = "Function",

			Arguments =
			{
				{ Name = "bagIndex", Type = "number", Nilable = false },
				{ Name = "flag", Type = "BagSlotFlags", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSet", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetBagSlotFlag",
			Type = "Function",

			Arguments =
			{
				{ Name = "bagIndex", Type = "number", Nilable = false },
				{ Name = "flag", Type = "BagSlotFlags", Nilable = false },
				{ Name = "isSet", Type = "bool", Nilable = false },
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
				{ Name = "bagID", Type = "number", Nilable = false },
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
				{ Name = "bagID", Type = "number", Nilable = false },
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
				{ Name = "bagOrSlotIndex", Type = "number", Nilable = false },
				{ Name = "slotIndex", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ItemLocked",
			Type = "Event",
			LiteralName = "ITEM_LOCKED",
			Payload =
			{
				{ Name = "bagOrSlotIndex", Type = "number", Nilable = false },
				{ Name = "slotIndex", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ItemUnlocked",
			Type = "Event",
			LiteralName = "ITEM_UNLOCKED",
			Payload =
			{
				{ Name = "bagOrSlotIndex", Type = "number", Nilable = false },
				{ Name = "slotIndex", Type = "number", Nilable = true },
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
	},
};

APIDocumentation:AddDocumentationTable(Container);