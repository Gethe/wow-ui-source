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
				{ Name = "baseItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
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
			Name = "GetItemHyperlink",
			Type = "Function",

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetItemUpgradeCurrentLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "isPvpItemLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetItemUpgradeEffect",
			Type = "Function",

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

			Returns =
			{
				{ Name = "itemInfo", Type = "ItemUpgradeItemInfo", Nilable = false },
			},
		},
		{
			Name = "GetItemUpgradePvpItemLevelDeltaValues",
			Type = "Function",

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
			Name = "SetItemUpgradeFromCursorItem",
			Type = "Function",
		},
		{
			Name = "SetItemUpgradeFromLocation",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemToSet", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
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
			Name = "ItemUpgradeCurrencyCost",
			Type = "Structure",
			Fields =
			{
				{ Name = "cost", Type = "number", Nilable = false },
				{ Name = "currencyID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ItemUpgradeItemCost",
			Type = "Structure",
			Fields =
			{
				{ Name = "cost", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
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
				{ Name = "currUpgrade", Type = "number", Nilable = false },
				{ Name = "maxUpgrade", Type = "number", Nilable = false },
				{ Name = "upgradeLevelInfos", Type = "table", InnerType = "ItemUpgradeLevelInfo", Nilable = false },
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