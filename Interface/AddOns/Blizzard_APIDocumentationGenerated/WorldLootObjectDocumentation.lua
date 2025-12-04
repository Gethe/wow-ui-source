local WorldLootObject =
{
	Name = "WorldLootObject",
	Type = "System",
	Namespace = "C_WorldLootObject",

	Functions =
	{
		{
			Name = "DoesSlotMatchInventoryType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
				{ Name = "inventoryType", Type = "InventoryType", Nilable = false },
			},

			Returns =
			{
				{ Name = "matches", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetWorldLootObjectDistanceSquared",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "distanceSquared", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetWorldLootObjectInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetWorldLootObjectInfoByGUID",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "objectGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "WorldLootObjectInfo", Nilable = false },
			},
		},
		{
			Name = "IsWorldLootObject",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "IsWorldLootObjectByGUID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isWorldLootObject", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsWorldLootObjectInRange",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "isLeftClick", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "WorldLootObjectInfoUpdated",
			Type = "Event",
			LiteralName = "WORLD_LOOT_OBJECT_INFO_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
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