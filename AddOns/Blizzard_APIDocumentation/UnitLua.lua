local UnitLua =
{
	Name = "Unit",
	Type = "System",

	Functions =
	{
		{
			Name = "UnitPower",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "powerType", Type = "PowerTypeEnum", Nilable = false, Default = NUM_POWER_TYPES },
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
				{ Name = "powerType", Type = "PowerTypeEnum", Nilable = false },
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
				{ Name = "powerType", Type = "PowerTypeEnum", Nilable = false, Default = NUM_POWER_TYPES },
				{ Name = "unmodified", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "maxPower", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "PowerTypeEnum",
			Type = "Enumeration",
			NumValues = 22,
			MinValue = -2,
			MaxValue = 19,
			Fields =
			{
				{ Name = "PowerTypeHealthCost", Type = "PowerTypeEnum", EnumValue = -2 },
				{ Name = "PowerTypeNone", Type = "PowerTypeEnum", EnumValue = -1 },
				{ Name = "PowerTypeMana", Type = "PowerTypeEnum", EnumValue = 0 },
				{ Name = "PowerTypeRage", Type = "PowerTypeEnum", EnumValue = 1 },
				{ Name = "PowerTypeFocus", Type = "PowerTypeEnum", EnumValue = 2 },
				{ Name = "PowerTypeEnergy", Type = "PowerTypeEnum", EnumValue = 3 },
				{ Name = "PowerTypeComboPoints", Type = "PowerTypeEnum", EnumValue = 4 },
				{ Name = "PowerTypeRunes", Type = "PowerTypeEnum", EnumValue = 5 },
				{ Name = "PowerTypeRunicPower", Type = "PowerTypeEnum", EnumValue = 6 },
				{ Name = "PowerTypeSoulShards", Type = "PowerTypeEnum", EnumValue = 7 },
				{ Name = "PowerTypeLunarPower", Type = "PowerTypeEnum", EnumValue = 8 },
				{ Name = "PowerTypeHolyPower", Type = "PowerTypeEnum", EnumValue = 9 },
				{ Name = "PowerTypeAlternate", Type = "PowerTypeEnum", EnumValue = 10 },
				{ Name = "PowerTypeMaelstrom", Type = "PowerTypeEnum", EnumValue = 11 },
				{ Name = "PowerTypeChi", Type = "PowerTypeEnum", EnumValue = 12 },
				{ Name = "PowerTypeInsanity", Type = "PowerTypeEnum", EnumValue = 13 },
				{ Name = "PowerTypeObsolete", Type = "PowerTypeEnum", EnumValue = 14 },
				{ Name = "PowerTypeObsolete2", Type = "PowerTypeEnum", EnumValue = 15 },
				{ Name = "PowerTypeArcaneCharges", Type = "PowerTypeEnum", EnumValue = 16 },
				{ Name = "PowerTypeFury", Type = "PowerTypeEnum", EnumValue = 17 },
				{ Name = "PowerTypePain", Type = "PowerTypeEnum", EnumValue = 18 },
				{ Name = "NumPowerTypes", Type = "PowerTypeEnum", EnumValue = 19 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UnitLua);