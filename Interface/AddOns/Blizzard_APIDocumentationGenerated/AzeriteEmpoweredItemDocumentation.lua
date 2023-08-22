local AzeriteEmpoweredItem =
{
	Name = "AzeriteEmpoweredItem",
	Type = "System",
	Namespace = "C_AzeriteEmpoweredItem",

	Functions =
	{
		{
			Name = "CanSelectPower",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "AzeriteEmpoweredItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canSelect", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ConfirmAzeriteEmpoweredItemRespec",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "AzeriteEmpoweredItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "GetAllTierInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "AzeriteEmpoweredItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "tierInfo", Type = "table", InnerType = "AzeriteEmpoweredItemTierInfo", Nilable = false },
			},
		},
		{
			Name = "GetAllTierInfoByItemID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = true, Documentation = { "Specify a class ID to get tier information about that class, otherwise uses the player's class if left nil" } },
			},

			Returns =
			{
				{ Name = "tierInfo", Type = "table", InnerType = "AzeriteEmpoweredItemTierInfo", Nilable = false },
			},
		},
		{
			Name = "GetAzeriteEmpoweredItemRespecCost",
			Type = "Function",

			Returns =
			{
				{ Name = "cost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPowerInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerInfo", Type = "AzeriteEmpoweredItemPowerInfo", Nilable = false },
			},
		},
		{
			Name = "GetPowerText",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "AzeriteEmpoweredItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = false },
				{ Name = "level", Type = "AzeritePowerLevel", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerText", Type = "AzeriteEmpoweredItemPowerText", Nilable = false },
			},
		},
		{
			Name = "GetSpecsForPower",
			Type = "Function",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "specInfo", Type = "table", InnerType = "AzeriteSpecInfo", Nilable = false },
			},
		},
		{
			Name = "HasAnyUnselectedPowers",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "AzeriteEmpoweredItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasAnyUnselectedPowers", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasBeenViewed",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "AzeriteEmpoweredItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasBeenViewed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAzeriteEmpoweredItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAzeriteEmpoweredItem", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAzeriteEmpoweredItemByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAzeriteEmpoweredItem", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAzeritePreviewSourceDisplayable",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = true, Documentation = { "Specify a class ID to determine if its displayable for that class, otherwise uses the player's class if left nil" } },
			},

			Returns =
			{
				{ Name = "isAzeritePreviewSourceDisplayable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHeartOfAzerothEquipped",
			Type = "Function",

			Returns =
			{
				{ Name = "isHeartOfAzerothEquipped", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPowerAvailableForSpec",
			Type = "Function",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPowerAvailableForSpec", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPowerSelected",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "AzeriteEmpoweredItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSelected", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SelectPower",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "AzeriteEmpoweredItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetHasBeenViewed",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "AzeriteEmpoweredItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AzeriteEmpoweredItemEquippedStatusChanged",
			Type = "Event",
			LiteralName = "AZERITE_EMPOWERED_ITEM_EQUIPPED_STATUS_CHANGED",
			Payload =
			{
				{ Name = "isHeartEquipped", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AzeriteEmpoweredItemSelectionUpdated",
			Type = "Event",
			LiteralName = "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED",
			Payload =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "AzeriteEmpoweredItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "AzeritePowerLevel",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Base", Type = "AzeritePowerLevel", EnumValue = 0 },
				{ Name = "Upgraded", Type = "AzeritePowerLevel", EnumValue = 1 },
				{ Name = "Downgraded", Type = "AzeritePowerLevel", EnumValue = 2 },
			},
		},
		{
			Name = "AzeriteEmpoweredItemPowerInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "azeritePowerID", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AzeriteEmpoweredItemPowerText",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
		{
			Name = "AzeriteEmpoweredItemTierInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "azeritePowerIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "unlockLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AzeriteSpecInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "classID", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AzeriteEmpoweredItem);