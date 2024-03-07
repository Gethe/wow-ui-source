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
				{ Name = "link", Type = "cstring", Nilable = false },
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
	},
};

APIDocumentation:AddDocumentationTable(ItemUpgrade);