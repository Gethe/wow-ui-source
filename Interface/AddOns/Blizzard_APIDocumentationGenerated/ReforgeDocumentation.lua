local Reforge =
{
	Name = "Reforge",
	Type = "System",
	Namespace = "C_Reforge",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ForgeMasterClosed",
			Type = "Event",
			LiteralName = "FORGE_MASTER_CLOSED",
		},
		{
			Name = "ForgeMasterItemChanged",
			Type = "Event",
			LiteralName = "FORGE_MASTER_ITEM_CHANGED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ForgeMasterOpened",
			Type = "Event",
			LiteralName = "FORGE_MASTER_OPENED",
		},
		{
			Name = "ForgeMasterSetItem",
			Type = "Event",
			LiteralName = "FORGE_MASTER_SET_ITEM",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Reforge);