local LegendaryCrafting =
{
	Name = "LegendaryCrafting",
	Type = "System",
	Namespace = "C_LegendaryCrafting",
	Environment = "All",

	Functions =
	{
		{
			Name = "CloseRuneforgeInteraction",
			Type = "Function",
		},
		{
			Name = "CraftRuneforgeLegendary",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "description", Type = "RuneforgeLegendaryCraftDescription", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgeItemPreviewInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "baseItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "runeforgeLegendary", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "componentInfo", Type = "RuneforgeLegendaryComponentInfo", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgeLegendaryCost",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "baseItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "runeforgeLegendary", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "upgradeItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "cost", Type = "table", InnerType = "CurrencyCost", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgeModifierInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "baseItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = true },
				{ Name = "addedModifierIndex", Type = "luaIndex", Nilable = false },
				{ Name = "modifiers", Type = "table", InnerType = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "table", InnerType = "string", Nilable = false },
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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "runeforgePowerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slotNames", Type = "table", InnerType = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetRuneforgePowers",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "baseItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = true },
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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "item", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRuneforgeLegendary", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRuneforgeLegendaryMaxLevel",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "runeforgeLegendary", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isMaxLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUpgradeItemValidForRuneforgeLegendary",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "runeforgeLegendary", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "upgradeItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValidRuneforgeBaseItem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "baseItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MakeRuneforgeCraftDescription",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "baseItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "runeforgeLegendary", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "upgradeItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "NewRuneforgePowerAdded",
			Type = "Event",
			LiteralName = "NEW_RUNEFORGE_POWER_ADDED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RuneforgeLegendaryCraftingClosed",
			Type = "Event",
			LiteralName = "RUNEFORGE_LEGENDARY_CRAFTING_CLOSED",
			SynchronousEvent = true,
		},
		{
			Name = "RuneforgeLegendaryCraftingOpened",
			Type = "Event",
			LiteralName = "RUNEFORGE_LEGENDARY_CRAFTING_OPENED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isUpgrade", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RuneforgePowerInfoUpdated",
			Type = "Event",
			LiteralName = "RUNEFORGE_POWER_INFO_UPDATED",
			SynchronousEvent = true,
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