local EngravingInfo =
{
	Name = "EngravingInfo",
	Type = "System",
	Namespace = "C_Engraving",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddCategoryFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "category", Type = "InventoryType", Nilable = false },
			},
		},
		{
			Name = "AddExclusiveCategoryFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "category", Type = "InventoryType", Nilable = false },
			},
		},
		{
			Name = "CastRune",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClearAllCategoryFilters",
			Type = "Function",
		},
		{
			Name = "ClearCategoryFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "category", Type = "InventoryType", Nilable = false },
			},
		},
		{
			Name = "ClearExclusiveCategoryFilter",
			Type = "Function",
		},
		{
			Name = "EnableEquippedFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetCurrentRuneCast",
			Type = "Function",

			Returns =
			{
				{ Name = "engravingInfo", Type = "EngravingData", Nilable = true },
			},
		},
		{
			Name = "GetEngravingModeEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetExclusiveCategoryFilter",
			Type = "Function",

			Returns =
			{
				{ Name = "category", Type = "InventoryType", Nilable = true },
			},
		},
		{
			Name = "GetNumRunesKnown",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "equipmentSlot", Type = "InventoryType", Nilable = true },
			},

			Returns =
			{
				{ Name = "known", Type = "number", Nilable = false },
				{ Name = "max", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRuneCategories",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "shouldFilter", Type = "bool", Nilable = false },
				{ Name = "ownedOnly", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "categories", Type = "table", InnerType = "InventoryType", Nilable = false },
			},
		},
		{
			Name = "GetRuneForEquipmentSlot",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "equipmentSlot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "engravingInfo", Type = "EngravingData", Nilable = true },
			},
		},
		{
			Name = "GetRuneForInventorySlot",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "containerIndex", Type = "luaIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "engravingInfo", Type = "EngravingData", Nilable = true },
			},
		},
		{
			Name = "GetRunesForCategory",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "category", Type = "InventoryType", Nilable = false },
				{ Name = "ownedOnly", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "engravingInfo", Type = "table", InnerType = "EngravingData", Nilable = false },
			},
		},
		{
			Name = "HasCategoryFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "category", Type = "InventoryType", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEngravingEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "value", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEquipmentSlotEngravable",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "equipmentSlot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEquippedFilterEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInventorySlotEngravable",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "containerIndex", Type = "luaIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInventorySlotEngravableByCurrentRuneCast",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "containerIndex", Type = "luaIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsKnownRuneSpell",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRuneEquipped",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RefreshRunesList",
			Type = "Function",
		},
		{
			Name = "SetEngravingModeEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSearchFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filter", Type = "cstring", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "EngravingModeChanged",
			Type = "Event",
			LiteralName = "ENGRAVING_MODE_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EngravingTargetingModeChanged",
			Type = "Event",
			LiteralName = "ENGRAVING_TARGETING_MODE_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RuneUpdated",
			Type = "Event",
			LiteralName = "RUNE_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "rune", Type = "EngravingData", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "EngravingData",
			Type = "Structure",
			Fields =
			{
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
				{ Name = "itemEnchantmentID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "iconTexture", Type = "number", Nilable = false },
				{ Name = "equipmentSlot", Type = "InventoryType", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "learnedAbilitySpellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(EngravingInfo);