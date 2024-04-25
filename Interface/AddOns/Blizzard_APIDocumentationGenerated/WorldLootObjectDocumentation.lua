local WorldLootObject =
{
	Name = "WorldLootObject",
	Type = "System",
	Namespace = "C_WorldLootObject",

	Functions =
	{
		{
			Name = "GetCurrentWorldLootObjectSwapInventoryType",
			Type = "Function",

			Returns =
			{
				{ Name = "inventoryType", Type = "InventoryType", Nilable = false },
			},
		},
		{
			Name = "GetWorldLootObjectInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "WorldLootObjectInfo", Nilable = false },
			},
		},
		{
			Name = "IsWorldLootObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isWorldLootObject", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsWorldLootObjectInRange",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isWorldLootObjectInRange", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "OnWorldLootObjectClick",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "WorldLootObjectInfoUpdated",
			Type = "Event",
			LiteralName = "WORLD_LOOT_OBJECT_INFO_UPDATED",
			Payload =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "WorldLootObjectSwapInventoryTypeUpdated",
			Type = "Event",
			LiteralName = "WORLD_LOOT_OBJECT_SWAP_INVENTORY_TYPE_UPDATED",
		},
	},

	Tables =
	{
		{
			Name = "WorldLootObjectInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "inventoryType", Type = "InventoryType", Nilable = false },
				{ Name = "atMaxQuality", Type = "bool", Nilable = false },
				{ Name = "isUpgrade", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WorldLootObject);