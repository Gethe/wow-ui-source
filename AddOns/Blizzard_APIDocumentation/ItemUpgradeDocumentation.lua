local ItemUpgrade =
{
	Name = "ItemUpgrade",
	Type = "System",
	Namespace = "C_ItemUpgrade",

	Functions =
	{
		{
			Name = "GetItemHyperlink",
			Type = "Function",

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
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