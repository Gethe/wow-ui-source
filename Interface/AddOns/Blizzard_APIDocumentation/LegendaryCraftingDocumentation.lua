local LegendaryCrafting =
{
	Name = "LegendaryCrafting",
	Type = "System",
	Namespace = "C_LegendaryCrafting",

	Functions =
	{
		{
			Name = "CloseRuneforgeInteraction",
			Type = "Function",
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
			Name = "GetRuneforgeItemPreviewInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "baseItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "runeforgePowerID", Type = "number", Nilable = true },
				{ Name = "modifiers", Type = "table", InnerType = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "info", Type = "RuneforgeItemPreviewInfo", Nilable = true },
			},
		},
		{
			Name = "GetRuneforgeLegendaryComponentInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "runeforgeLegendary", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "componentInfo", Type = "RuneforgeLegendaryComponentInfo", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgeLegendaryCost",
			Type = "Function",

			Arguments =
			{
				{ Name = "baseItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "cost", Type = "table", InnerType = "CurrencyCost", Nilable = false },
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
			Name = "GetRuneforgeLegendaryCurrencies",
			Type = "Function",

			Returns =
			{
				{ Name = "currencies", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgeLegendaryUpgradeCost",
			Type = "Function",

			Arguments =
			{
				{ Name = "runeforgeLegendary", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "upgradeItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "cost", Type = "table", InnerType = "CurrencyCost", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgeModifierInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "baseItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = true },
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
			Name = "GetRuneforgePowerSlots",
			Type = "Function",

			Arguments =
			{
				{ Name = "runeforgePowerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slotNames", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgePowers",
			Type = "Function",

			Arguments =
			{
				{ Name = "baseItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = true },
				{ Name = "filter", Type = "RuneforgePowerFilter", Nilable = true },
			},

			Returns =
			{
				{ Name = "primaryRuneforgePowerIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "otherRuneforgePowerIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgePowersByClassSpecAndCovenant",
			Type = "Function",

			Arguments =
			{
				{ Name = "classID", Type = "number", Nilable = true },
				{ Name = "specID", Type = "number", Nilable = true },
				{ Name = "covenantID", Type = "number", Nilable = true },
				{ Name = "filter", Type = "RuneforgePowerFilter", Nilable = true },
			},

			Returns =
			{
				{ Name = "runeforgePowerIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "IsRuneforgeLegendary",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRuneforgeLegendary", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRuneforgeLegendaryMaxLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "runeforgeLegendary", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isMaxLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUpgradeItemValidForRuneforgeLegendary",
			Type = "Function",

			Arguments =
			{
				{ Name = "runeforgeLegendary", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "upgradeItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
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
				{ Name = "modifiers", Type = "table", InnerType = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "description", Type = "RuneforgeLegendaryCraftDescription", Nilable = false },
			},
		},
		{
			Name = "UpgradeRuneforgeLegendary",
			Type = "Function",

			Arguments =
			{
				{ Name = "runeforgeLegendary", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "upgradeItem", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "NewRuneforgePowerAdded",
			Type = "Event",
			LiteralName = "NEW_RUNEFORGE_POWER_ADDED",
			Payload =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RuneforgeLegendaryCraftingClosed",
			Type = "Event",
			LiteralName = "RUNEFORGE_LEGENDARY_CRAFTING_CLOSED",
		},
		{
			Name = "RuneforgeLegendaryCraftingOpened",
			Type = "Event",
			LiteralName = "RUNEFORGE_LEGENDARY_CRAFTING_OPENED",
			Payload =
			{
				{ Name = "isUpgrade", Type = "bool", Nilable = false },
			},
		},
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