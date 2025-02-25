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
			Name = "CanBeRefunded",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "canBeRefunded", Type = "bool", Nilable = false },
			},
		},
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
			Name = "DoesItemMatchTargetEnchantingSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLoc", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "matchesTargetEnchantingSpell", Type = "bool", Nilable = false },
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
			Name = "GetDelvePreviewItemLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "context", Type = "ItemCreationContext", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemLink", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetDelvePreviewItemQuality",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "context", Type = "ItemCreationContext", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemQuality", Type = "ItemQuality", Nilable = false },
			},
		},
		{
			Name = "GetDetailedItemLevelInfo",
			Type = "Function",
			MayReturnNothing = true,

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
			Name = "GetFirstTriggeredSpellForItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemQuality", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = true },
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
			Name = "GetItemCooldown",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "startTimeSeconds", Type = "number", Nilable = false },
				{ Name = "durationSeconds", Type = "number", Nilable = false },
				{ Name = "enableCooldownTimer", Type = "bool", Nilable = false },
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
				{ Name = "includeAccountBank", Type = "bool", Nilable = false, Default = false },
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
			MayReturnNothing = true,

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
			Name = "GetItemGemID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "gemID", Type = "number", Nilable = false },
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
			Name = "GetItemInfo",
			Type = "Function",
			MayReturnNothing = true,

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
			MayReturnNothing = true,

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
			Name = "GetItemInventorySlotKey",
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
			Name = "GetItemLearnTransmogSet",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "setID", Type = "number", Nilable = true },
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
			Name = "GetItemNumAddedSockets",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "socketCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemNumSockets",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "socketCount", Type = "number", Nilable = false },
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
			MayReturnNothing = true,

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
			MayReturnNothing = true,

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
			Name = "GetItemStatDelta",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemLink1", Type = "cstring", Nilable = false },
				{ Name = "itemLink2", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "statTable", Type = "LuaValueVariant", Nilable = false },
			},
		},
		{
			Name = "GetItemStats",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemLink", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "statTable", Type = "LuaValueVariant", Nilable = false },
			},
		},
		{
			Name = "GetItemSubClassInfo",
			Type = "Function",
			MayReturnNothing = true,

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
			MayReturnNothing = true,

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
			Name = "GetItemUniquenessByID",
			Type = "Function",
			MayReturnNothing = true,

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
			MayReturnNothing = true,

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
			Name = "GetSetBonusesForSpecializationByItemID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemSetSpellIDs", Type = "table", InnerType = "number", Nilable = false },
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
			Name = "IsBoundToAccountUntilEquip",
			Type = "Function",
			Documentation = { "You can use IsItemBindToAccountUntilEquip instead if the item is not in your inventory" },

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isBoundToAccountUntilEquip", Type = "bool", Nilable = false },
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
			Name = "IsCorruptedItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "IsCosmeticItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "IsCurioItem",
			Type = "Function",
			Documentation = { "Returns whether the item is a consumable curio that can be applied to a delves companion." },

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = true },
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
			Name = "IsItemBindToAccountUntilEquip",
			Type = "Function",
			Documentation = { "You can use IsBoundToAccountUntilEquip instead if the item exists in your inventory" },

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "isItemBindToAccountUntilEquip", Type = "bool", Nilable = false },
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
			Name = "ReplaceTradeskillEnchant",
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
			Name = "ConvertToBindToAccountConfirm",
			Type = "Event",
			LiteralName = "CONVERT_TO_BIND_TO_ACCOUNT_CONFIRM",
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