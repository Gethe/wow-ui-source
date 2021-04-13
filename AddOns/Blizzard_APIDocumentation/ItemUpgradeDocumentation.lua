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
			Name = "GetNumItemUpgradeEffects",
			Type = "Function",

			Returns =
			{
				{ Name = "numItemUpgradeEffects", Type = "number", Nilable = false },
			},
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
	},
};

APIDocumentation:AddDocumentationTable(ItemUpgrade);