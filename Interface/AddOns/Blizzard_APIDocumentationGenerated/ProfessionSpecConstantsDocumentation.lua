local ProfessionSpecConstants =
{
	Tables =
	{
		{
			Name = "ProfTraitPerkNodeFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "UnlocksSubpath", Type = "ProfTraitPerkNodeFlags", EnumValue = 1 },
				{ Name = "IsMajorBonus", Type = "ProfTraitPerkNodeFlags", EnumValue = 2 },
			},
		},
		{
			Name = "ProfessionsSpecPathState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Locked", Type = "ProfessionsSpecPathState", EnumValue = 0 },
				{ Name = "Progressing", Type = "ProfessionsSpecPathState", EnumValue = 1 },
				{ Name = "Completed", Type = "ProfessionsSpecPathState", EnumValue = 2 },
			},
		},
		{
			Name = "ProfessionsSpecPerkState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Unearned", Type = "ProfessionsSpecPerkState", EnumValue = 0 },
				{ Name = "Pending", Type = "ProfessionsSpecPerkState", EnumValue = 1 },
				{ Name = "Earned", Type = "ProfessionsSpecPerkState", EnumValue = 2 },
			},
		},
		{
			Name = "ProfessionsSpecTabState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Locked", Type = "ProfessionsSpecTabState", EnumValue = 0 },
				{ Name = "Unlocked", Type = "ProfessionsSpecTabState", EnumValue = 1 },
				{ Name = "Unlockable", Type = "ProfessionsSpecTabState", EnumValue = 2 },
			},
		},
		{
			Name = "ProfTabHighlight",
			Type = "Structure",
			Fields =
			{
				{ Name = "description", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ProfTabInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "rootNodeID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "rootIconID", Type = "number", Nilable = false },
				{ Name = "highlights", Type = "table", InnerType = "ProfTabHighlight", Nilable = false },
			},
		},
		{
			Name = "SpecPerkInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "perkID", Type = "number", Nilable = false },
				{ Name = "isMajorPerk", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SpecializationCurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "numAvailable", Type = "number", Nilable = false },
				{ Name = "currencyName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SpecializationTabInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = true },
				{ Name = "errorReason", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ProfessionSpecConstants);