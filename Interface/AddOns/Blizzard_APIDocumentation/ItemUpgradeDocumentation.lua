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
			Name = "GetItemLevelIncrement",
			Type = "Function",

			Arguments =
			{
				{ Name = "numUpgradeLevels", Type = "number", Nilable = false, Default = 1 },
			},

			Returns =
			{
				{ Name = "itemLevelIncrement", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemUpdateLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "itemLevel", Type = "number", Nilable = false },
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
			Name = "GetItemUpgradeStats",
			Type = "Function",

			Arguments =
			{
				{ Name = "upgraded", Type = "bool", Nilable = false, Default = false },
				{ Name = "numUpgradeLevels", Type = "number", Nilable = false, Default = 1 },
			},

			Returns =
			{
				{ Name = "itemStats", Type = "table", InnerType = "ItemUpgradeStat", Nilable = false },
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
		},
	},

	Events =
	{
		{
			Name = "ItemUpgradeMasterClosed",
			Type = "Event",
			LiteralName = "ITEM_UPGRADE_MASTER_CLOSED",
		},
		{
			Name = "ItemUpgradeMasterOpened",
			Type = "Event",
			LiteralName = "ITEM_UPGRADE_MASTER_OPENED",
		},
		{
			Name = "ItemUpgradeMasterSetItem",
			Type = "Event",
			LiteralName = "ITEM_UPGRADE_MASTER_SET_ITEM",
		},
		{
			Name = "ItemUpgradeMasterUpdate",
			Type = "Event",
			LiteralName = "ITEM_UPGRADE_MASTER_UPDATE",
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
				{ Name = "levelStats", Type = "table", InnerType = "ItemUpgradeStat", Nilable = false },
				{ Name = "costsToUpgrade", Type = "table", InnerType = "ItemUpgradeCurrencyCost", Nilable = false },
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