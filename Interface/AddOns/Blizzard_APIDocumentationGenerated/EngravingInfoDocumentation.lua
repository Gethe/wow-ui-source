local EngravingInfo =
{
	Name = "EngravingInfo",
	Type = "System",
	Namespace = "C_Engraving",

	Functions =
	{
		{
			Name = "AddCategoryFilter",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AddExclusiveCategoryFilter",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CastRune",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "category", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClearExclusiveCategoryFilter",
			Type = "Function",
		},
		{
			Name = "EnableEquippedFilter",
			Type = "Function",

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
				{ Name = "category", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetNumRunesKnown",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSlot", Type = "number", Nilable = true },
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

			Arguments =
			{
				{ Name = "shouldFilter", Type = "bool", Nilable = false },
				{ Name = "ownedOnly", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "categories", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRuneForEquipmentSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSlot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "engravingInfo", Type = "EngravingData", Nilable = true },
			},
		},
		{
			Name = "GetRuneForInventorySlot",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "category", Type = "number", Nilable = false },
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

			Arguments =
			{
				{ Name = "category", Type = "number", Nilable = false },
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

			Arguments =
			{
				{ Name = "equipmentSlot", Type = "number", Nilable = false },
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

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSearchFilter",
			Type = "Function",

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
			Payload =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EngravingTargetingModeChanged",
			Type = "Event",
			LiteralName = "ENGRAVING_TARGETING_MODE_CHANGED",
			Payload =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RuneUpdated",
			Type = "Event",
			LiteralName = "RUNE_UPDATED",
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
				{ Name = "equipmentSlot", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "learnedAbilitySpellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EngravingInfo);