local UnitHealPredictionCalculatorShared =
{
	Tables =
	{
		{
			Name = "UnitDamageAbsorbClampMode",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "MissingHealth", Type = "UnitDamageAbsorbClampMode", EnumValue = 0, Documentation = { "Clamp damage absorb values to the amount of missing health with incoming heals subtracted." } },
				{ Name = "MissingHealthWithoutIncomingHeals", Type = "UnitDamageAbsorbClampMode", EnumValue = 1, Documentation = { "Clamp damage absorb values to the amount of missing health. Incoming heals do not decrease missing health." } },
				{ Name = "MaximumHealth", Type = "UnitDamageAbsorbClampMode", EnumValue = 2, Documentation = { "Clamp damage absorb values to the amount of maximum health." } },
			},
		},
		{
			Name = "UnitHealAbsorbClampMode",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "CurrentHealth", Type = "UnitHealAbsorbClampMode", EnumValue = 0, Documentation = { "Clamp heal absorb values to the amount of current health." } },
				{ Name = "MaximumHealth", Type = "UnitHealAbsorbClampMode", EnumValue = 1, Documentation = { "Clamp heal absorb values to the amount of maximum health." } },
			},
		},
		{
			Name = "UnitHealAbsorbMode",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "ReducedByIncomingHeals", Type = "UnitHealAbsorbMode", EnumValue = 0, Documentation = { "Reduce heal absorb values by incoming heals, and vice versa, clamping to zero where necessary." } },
				{ Name = "Total", Type = "UnitHealAbsorbMode", EnumValue = 1, Documentation = { "Use heal absorb and incoming heal values as-is without any reductions." } },
			},
		},
		{
			Name = "UnitIncomingHealClampMode",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "MissingHealth", Type = "UnitIncomingHealClampMode", EnumValue = 0, Documentation = { "Clamp incoming heal values to the amount of missing health with overflow applied." } },
				{ Name = "MaximumHealth", Type = "UnitIncomingHealClampMode", EnumValue = 1, Documentation = { "Clamp incoming heal values to the amount of maximum health." } },
			},
		},
		{
			Name = "UnitDamageAbsorbInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "amount", Type = "number", Nilable = false, Documentation = { "Amount of applied damage absorb affects with potential reductions from clamping included." } },
				{ Name = "clamped", Type = "bool", Nilable = false, Documentation = { "If true, the value is in excess of the clamp boundary." } },
			},
		},
		{
			Name = "UnitHealAbsorbInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "amount", Type = "number", Nilable = false, Documentation = { "Amount of applied heal absorb affects with potential reductions from incoming heals and clamping included." } },
				{ Name = "clamped", Type = "bool", Nilable = false, Documentation = { "If true, the value is in excess of the clamp boundary." } },
			},
		},
		{
			Name = "UnitHealPredictionValues",
			Type = "Structure",
			Fields =
			{
				{ Name = "health", Type = "number", Nilable = false, Default = 0 },
				{ Name = "healthMax", Type = "number", Nilable = false, Default = 0 },
				{ Name = "totalIncomingHeals", Type = "number", Nilable = false, Default = 0 },
				{ Name = "totalIncomingHealsFromHealer", Type = "number", Nilable = false, Default = 0 },
				{ Name = "totalDamageAbsorbs", Type = "number", Nilable = false, Default = 0 },
				{ Name = "totalHealAbsorbs", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "UnitIncomingHealInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "amount", Type = "number", Nilable = false, Documentation = { "Amount of incoming heals across all units with potential reductions from heal absorb effects included." } },
				{ Name = "amountFromHealer", Type = "number", Nilable = false, Documentation = { "Amount of incoming heals from the healer unit. Will never exceed the all-units value." } },
				{ Name = "amountFromOthers", Type = "number", Nilable = false, Documentation = { "Amount of incoming heals from units other than theh healer. Calculated as the difference between amount and amount-from-healer." } },
				{ Name = "clamped", Type = "bool", Nilable = false, Documentation = { "If true, the value is in excess of the clamp boundary." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UnitHealPredictionCalculatorShared);