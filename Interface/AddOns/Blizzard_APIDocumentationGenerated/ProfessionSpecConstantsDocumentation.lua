local ProfessionSpecConstants =
{
	Tables =
	{
		{
			Name = "ProfTraitPerkNodeFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "UnlocksSubpath", Type = "ProfTraitPerkNodeFlags", EnumValue = 1 },
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
			Name = "ProfTabInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "rootNodeID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SpecializationTabInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = true },
				{ Name = "errorReason", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ProfessionSpecConstants);