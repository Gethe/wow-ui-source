local ItemUpgrade =
{
	Name = "ItemUpgrade",
	Type = "System",
	Namespace = "C_ItemUpgrade",

	Functions =
	{
		{
			Name = "CanUpgradeItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "baseItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearItemUpgrade",
			Type = "Function",
		},
		{
			Name = "CloseItemUpgrade",
			Type = "Function",
		},
		{
			Name = "GetHighWatermarkForItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false, Documentation = { "Item ID, Link, or Name" } },
			},

			Returns =
			{
				{ Name = "characterHighWatermark", Type = "number", Nilable = false },
				{ Name = "accountHighWatermark", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHighWatermarkForSlot",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemRedundancySlot", Type = "number", Nilable = false, Documentation = { "Must be an Enum.ItemRedundancySlot value" } },
			},

			Returns =
			{
				{ Name = "characterHighWatermark", Type = "number", Nilable = false },
				{ Name = "accountHighWatermark", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHighWatermarkSlotForItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false, Documentation = { "Item ID, Link, or Name" } },
			},

			Returns =
			{
				{ Name = "itemRedundancySlot", Type = "number", Nilable = false, Documentation = { "Enum.ItemRedundancySlot value" } },
			},
		},
		{
			Name = "GetItemHyperlink",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "link", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetItemUpgradeCurrentLevel",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "isPvpItemLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetItemUpgradeEffect",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "effectIndex", Type = "number", Nilable = false },
				{ Name = "numUpgradeLevels", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "outBaseEffect", Type = "string", Nilable = false },
				{ Name = "outUpgradedEffect", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetItemUpgradeItemInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "itemInfo", Type = "ItemUpgradeItemInfo", Nilable = false },
			},
		},
		{
			Name = "GetItemUpgradePvpItemLevelDeltaValues",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "numUpgradeLevels", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "currentPvPItemLevel", Type = "number", Nilable = false },
				{ Name = "upgradedPvPItemLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumItemUpgradeEffects",
			Type = "Function",

			Returns =
			{
				{ Name = "numItemUpgradeEffects", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsItemBound",
			Type = "Function",

			Returns =
			{
				{ Name = "isBound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetItemUpgradeFromCursorItem",
			Type = "Function",
		},
		{
			Name = "SetItemUpgradeFromLocation",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemToSet", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "UpgradeItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "numUpgrades", Type = "number", Nilable = false, Default = 1 },
			},
		},
	},

	Events =
	{
		{
			Name = "ItemUpgradeFailed",
			Type = "Event",
			LiteralName = "ITEM_UPGRADE_FAILED",
		},
		{
			Name = "ItemUpgradeMasterSetItem",
			Type = "Event",
			LiteralName = "ITEM_UPGRADE_MASTER_SET_ITEM",
		},
	},

	Tables =
	{
		{
			Name = "ItemUpgradeCostDiscountInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "isDiscounted", Type = "bool", Nilable = false },
				{ Name = "discountHighWatermark", Type = "number", Nilable = false },
				{ Name = "isPartialTwoHandDiscount", Type = "bool", Nilable = false },
				{ Name = "isAccountWideDiscount", Type = "bool", Nilable = false },
				{ Name = "doesCurrentCharacterMeetHighWatermark", Type = "bool", Nilable = false, Documentation = { "Reflects whether current character meets discount's high watermark, even if discount itself is account-wide" } },
			},
		},
		{
			Name = "ItemUpgradeCurrencyCost",
			Type = "Structure",
			Fields =
			{
				{ Name = "cost", Type = "number", Nilable = false },
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "discountInfo", Type = "ItemUpgradeCostDiscountInfo", Nilable = false },
			},
		},
		{
			Name = "ItemUpgradeItemCost",
			Type = "Structure",
			Fields =
			{
				{ Name = "cost", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "discountInfo", Type = "ItemUpgradeCostDiscountInfo", Nilable = false },
			},
		},
		{
			Name = "ItemUpgradeItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "iconID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "itemUpgradeable", Type = "bool", Nilable = false },
				{ Name = "displayQuality", Type = "number", Nilable = false },
				{ Name = "highWatermarkSlot", Type = "number", Nilable = false },
				{ Name = "currUpgrade", Type = "number", Nilable = false },
				{ Name = "maxUpgrade", Type = "number", Nilable = false },
				{ Name = "minItemLevel", Type = "number", Nilable = false },
				{ Name = "maxItemLevel", Type = "number", Nilable = false },
				{ Name = "upgradeLevelInfos", Type = "table", InnerType = "ItemUpgradeLevelInfo", Nilable = false },
				{ Name = "customUpgradeString", Type = "string", Nilable = true },
				{ Name = "upgradeCostTypesForSeason", Type = "table", InnerType = "ItemUpgradeSeasonalCostType", Nilable = false },
			},
		},
		{
			Name = "ItemUpgradeLevelInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "upgradeLevel", Type = "number", Nilable = false },
				{ Name = "displayQuality", Type = "number", Nilable = false },
				{ Name = "itemLevelIncrement", Type = "number", Nilable = false },
				{ Name = "levelStats", Type = "table", InnerType = "ItemUpgradeStat", Nilable = false },
				{ Name = "currencyCostsToUpgrade", Type = "table", InnerType = "ItemUpgradeCurrencyCost", Nilable = false },
				{ Name = "itemCostsToUpgrade", Type = "table", InnerType = "ItemUpgradeItemCost", Nilable = false },
				{ Name = "failureMessage", Type = "string", Nilable = true },
			},
		},
		{
			Name = "ItemUpgradeSeasonalCostType",
			Type = "Structure",
			Documentation = { "Costs are made up of either an Item OR a Currency, so either itemID or currencyID will be nil" },
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "currencyID", Type = "number", Nilable = true },
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "sourceString", Type = "string", Nilable = true },
			},
		},
		{
			Name = "ItemUpgradeStat",
			Type = "Structure",
			Fields =
			{
				{ Name = "displayString", Type = "string", Nilable = false },
				{ Name = "statValue", Type = "number", Nilable = false },
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ItemUpgrade);