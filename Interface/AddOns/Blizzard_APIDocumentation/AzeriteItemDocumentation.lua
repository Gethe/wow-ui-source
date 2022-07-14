local AzeriteItem =
{
	Name = "AzeriteItem",
	Type = "System",
	Namespace = "C_AzeriteItem",

	Functions =
	{
		{
			Name = "FindActiveAzeriteItem",
			Type = "Function",

			Returns =
			{
				{ Name = "activeAzeriteItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "GetAzeriteItemXPInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "totalLevelXP", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPowerLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnlimitedPowerLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasActiveAzeriteItem",
			Type = "Function",

			Returns =
			{
				{ Name = "hasActiveAzeriteItem", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAzeriteItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAzeriteItem", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAzeriteItemAtMaxLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "isAtMax", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAzeriteItemByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAzeriteItem", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAzeriteItemEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AzeriteItemEnabledStateChanged",
			Type = "Event",
			LiteralName = "AZERITE_ITEM_ENABLED_STATE_CHANGED",
			Payload =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AzeriteItemExperienceChanged",
			Type = "Event",
			LiteralName = "AZERITE_ITEM_EXPERIENCE_CHANGED",
			Payload =
			{
				{ Name = "azeriteItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "oldExperienceAmount", Type = "number", Nilable = false },
				{ Name = "newExperienceAmount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AzeriteItemPowerLevelChanged",
			Type = "Event",
			LiteralName = "AZERITE_ITEM_POWER_LEVEL_CHANGED",
			Payload =
			{
				{ Name = "azeriteItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "oldPowerLevel", Type = "number", Nilable = false },
				{ Name = "newPowerLevel", Type = "number", Nilable = false },
				{ Name = "unlockedEmpoweredItemsInfo", Type = "table", InnerType = "UnlockedAzeriteEmpoweredItems", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "UnlockedAzeriteEmpoweredItems",
			Type = "Structure",
			Fields =
			{
				{ Name = "unlockedItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "tierIndex", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AzeriteItem);