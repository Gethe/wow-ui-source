local LegendaryCrafting =
{
	Name = "LegendaryCrafting",
	Type = "System",
	Namespace = "C_LegendaryCrafting",

	Functions =
	{
		{
			Name = "CanCraftRuneforgeLegendary",
			Type = "Function",

			Arguments =
			{
				{ Name = "description", Type = "RuneforgeLegendaryCraftDescription", Nilable = false },
			},

			Returns =
			{
				{ Name = "canCraft", Type = "bool", Nilable = false },
				{ Name = "error", Type = "RuneforgeLegendaryError", Nilable = true },
			},
		},
		{
			Name = "CraftRuneforgeLegendary",
			Type = "Function",

			Arguments =
			{
				{ Name = "description", Type = "RuneforgeLegendaryCraftDescription", Nilable = false },
			},
		},
		{
			Name = "GetItemLevelTiers",
			Type = "Function",

			Arguments =
			{
				{ Name = "baseItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "tiers", Type = "table", InnerType = "ItemLevelTier", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgeLegendaryCraftSpellID",
			Type = "Function",

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgeModifierInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "baseItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = true },
				{ Name = "itemLevelTierIndex", Type = "number", Nilable = true },
				{ Name = "addedModifierIndex", Type = "number", Nilable = false },
				{ Name = "modifiers", Type = "table", InnerType = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgeModifiers",
			Type = "Function",

			Arguments =
			{
				{ Name = "baseItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "modifiedReagentItemIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgePowerInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "runeforgePowerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "power", Type = "RuneforgePower", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgePowers",
			Type = "Function",

			Arguments =
			{
				{ Name = "baseItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = true },
			},

			Returns =
			{
				{ Name = "runeforgePowerIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "IsValidRuneforgeBaseItem",
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
			Name = "MakeRuneforgeCraftDescription",
			Type = "Function",

			Arguments =
			{
				{ Name = "baseItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "runeforgePowerID", Type = "number", Nilable = false },
				{ Name = "itemLevelTierIndex", Type = "number", Nilable = false },
				{ Name = "modifiers", Type = "table", InnerType = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "description", Type = "RuneforgeLegendaryCraftDescription", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "RuneforgePowerInfoUpdated",
			Type = "Event",
			LiteralName = "RUNEFORGE_POWER_INFO_UPDATED",
			Payload =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(LegendaryCrafting);