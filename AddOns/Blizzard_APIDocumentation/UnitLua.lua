local UnitLua =
{
	Name = "Unit",
	Type = "System",

	Functions =
	{
		{
			Name = "UnitIsOwnerOrControllerOfUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "controllingUnit", Type = "string", Nilable = false },
				{ Name = "controlledUnit", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "unitIsOwnerOrControllerOfUnit", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitPower",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "powerType", Type = "PowerType", Nilable = false, Default = "NumPowerTypes" },
				{ Name = "unmodified", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "power", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPowerDisplayMod",
			Type = "Function",

			Arguments =
			{
				{ Name = "powerType", Type = "PowerType", Nilable = false },
			},

			Returns =
			{
				{ Name = "displayMod", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPowerMax",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "powerType", Type = "PowerType", Nilable = false, Default = "NumPowerTypes" },
				{ Name = "unmodified", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "maxPower", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "PowerType",
			Type = "Enumeration",
			NumValues = 22,
			MinValue = -2,
			MaxValue = 19,
			Fields =
			{
				{ Name = "HealthCost", Type = "PowerType", EnumValue = -2 },
				{ Name = "None", Type = "PowerType", EnumValue = -1 },
				{ Name = "Mana", Type = "PowerType", EnumValue = 0 },
				{ Name = "Rage", Type = "PowerType", EnumValue = 1 },
				{ Name = "Focus", Type = "PowerType", EnumValue = 2 },
				{ Name = "Energy", Type = "PowerType", EnumValue = 3 },
				{ Name = "ComboPoints", Type = "PowerType", EnumValue = 4 },
				{ Name = "Runes", Type = "PowerType", EnumValue = 5 },
				{ Name = "RunicPower", Type = "PowerType", EnumValue = 6 },
				{ Name = "SoulShards", Type = "PowerType", EnumValue = 7 },
				{ Name = "LunarPower", Type = "PowerType", EnumValue = 8 },
				{ Name = "HolyPower", Type = "PowerType", EnumValue = 9 },
				{ Name = "Alternate", Type = "PowerType", EnumValue = 10 },
				{ Name = "Maelstrom", Type = "PowerType", EnumValue = 11 },
				{ Name = "Chi", Type = "PowerType", EnumValue = 12 },
				{ Name = "Insanity", Type = "PowerType", EnumValue = 13 },
				{ Name = "Obsolete", Type = "PowerType", EnumValue = 14 },
				{ Name = "Obsolete2", Type = "PowerType", EnumValue = 15 },
				{ Name = "ArcaneCharges", Type = "PowerType", EnumValue = 16 },
				{ Name = "Fury", Type = "PowerType", EnumValue = 17 },
				{ Name = "Pain", Type = "PowerType", EnumValue = 18 },
				{ Name = "NumPowerTypes", Type = "PowerType", EnumValue = 19 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UnitLua);