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
				{ Name = "azeriteEmpoweredItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canSelect", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAllTierInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "tierInfo", Type = "table", InnerType = "AzeriteEmpoweredItemTierInfo", Nilable = false },
			},
		},
		{
			Name = "GetPowerInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerInfo", Type = "AzeriteEmpoweredItemPowerInfo", Nilable = false },
			},
		},
		{
			Name = "HasAnyUnselectedPowers",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasAnyUnselectedPowers", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAzeriteEmpoweredItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
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
				{ Name = "itemInfo", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAzeriteEmpoweredItem", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SelectPower",
			Type = "Function",

			Arguments =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AzeriteEmpoweredItemSelectionUpdated",
			Type = "Event",
			LiteralName = "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED",
			Payload =
			{
				{ Name = "azeriteEmpoweredItemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "AzeriteEmpoweredItemPowerInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "azeritePowerID", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "tierIndex", Type = "number", Nilable = false },
				{ Name = "selected", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AzeriteEmpoweredItemTierInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "tierIndex", Type = "number", Nilable = false },
				{ Name = "azeritePowerIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "unlockLevel", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AzeriteEmpoweredItem);