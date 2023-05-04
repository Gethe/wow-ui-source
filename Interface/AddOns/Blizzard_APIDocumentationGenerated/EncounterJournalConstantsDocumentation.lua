local EncounterJournalConstants =
{
	Tables =
	{
		{
			Name = "JournalEncounterFlags",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 1,
			MaxValue = 32,
			Fields =
			{
				{ Name = "Obsolete", Type = "JournalEncounterFlags", EnumValue = 1 },
				{ Name = "LimitDifficulties", Type = "JournalEncounterFlags", EnumValue = 2 },
				{ Name = "AllianceOnly", Type = "JournalEncounterFlags", EnumValue = 4 },
				{ Name = "HordeOnly", Type = "JournalEncounterFlags", EnumValue = 8 },
				{ Name = "NoMap", Type = "JournalEncounterFlags", EnumValue = 16 },
				{ Name = "InternalOnly", Type = "JournalEncounterFlags", EnumValue = 32 },
			},
		},
		{
			Name = "JournalEncounterIconFlags",
			Type = "Enumeration",
			NumValues = 14,
			MinValue = 1,
			MaxValue = 8192,
			Fields =
			{
				{ Name = "Tank", Type = "JournalEncounterIconFlags", EnumValue = 1 },
				{ Name = "Dps", Type = "JournalEncounterIconFlags", EnumValue = 2 },
				{ Name = "Healer", Type = "JournalEncounterIconFlags", EnumValue = 4 },
				{ Name = "Heroic", Type = "JournalEncounterIconFlags", EnumValue = 8 },
				{ Name = "Deadly", Type = "JournalEncounterIconFlags", EnumValue = 16 },
				{ Name = "Important", Type = "JournalEncounterIconFlags", EnumValue = 32 },
				{ Name = "Interruptible", Type = "JournalEncounterIconFlags", EnumValue = 64 },
				{ Name = "Magic", Type = "JournalEncounterIconFlags", EnumValue = 128 },
				{ Name = "Curse", Type = "JournalEncounterIconFlags", EnumValue = 256 },
				{ Name = "Poison", Type = "JournalEncounterIconFlags", EnumValue = 512 },
				{ Name = "Disease", Type = "JournalEncounterIconFlags", EnumValue = 1024 },
				{ Name = "Enrage", Type = "JournalEncounterIconFlags", EnumValue = 2048 },
				{ Name = "Mythic", Type = "JournalEncounterIconFlags", EnumValue = 4096 },
				{ Name = "Bleed", Type = "JournalEncounterIconFlags", EnumValue = 8192 },
			},
		},
		{
			Name = "JournalEncounterItemFlags",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 1,
			MaxValue = 16,
			Fields =
			{
				{ Name = "Obsolete", Type = "JournalEncounterItemFlags", EnumValue = 1 },
				{ Name = "LimitDifficulties", Type = "JournalEncounterItemFlags", EnumValue = 2 },
				{ Name = "DisplayAsPerPlayerLoot", Type = "JournalEncounterItemFlags", EnumValue = 4 },
				{ Name = "DisplayAsVeryRare", Type = "JournalEncounterItemFlags", EnumValue = 8 },
				{ Name = "DisplayAsExtremelyRare", Type = "JournalEncounterItemFlags", EnumValue = 16 },
			},
		},
		{
			Name = "JournalEncounterLocFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Primary", Type = "JournalEncounterLocFlags", EnumValue = 1 },
			},
		},
		{
			Name = "JournalEncounterSecTypes",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Generic", Type = "JournalEncounterSecTypes", EnumValue = 0 },
				{ Name = "Creature", Type = "JournalEncounterSecTypes", EnumValue = 1 },
				{ Name = "Ability", Type = "JournalEncounterSecTypes", EnumValue = 2 },
				{ Name = "Overview", Type = "JournalEncounterSecTypes", EnumValue = 3 },
			},
		},
		{
			Name = "JournalEncounterSectionFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "StartExpanded", Type = "JournalEncounterSectionFlags", EnumValue = 1 },
				{ Name = "LimitDifficulties", Type = "JournalEncounterSectionFlags", EnumValue = 2 },
			},
		},
		{
			Name = "JournalInstanceFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Timewalker", Type = "JournalInstanceFlags", EnumValue = 1 },
				{ Name = "HideUserSelectableDifficulty", Type = "JournalInstanceFlags", EnumValue = 2 },
			},
		},
		{
			Name = "JournalLinkTypes",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Instance", Type = "JournalLinkTypes", EnumValue = 0 },
				{ Name = "Encounter", Type = "JournalLinkTypes", EnumValue = 1 },
				{ Name = "Section", Type = "JournalLinkTypes", EnumValue = 2 },
				{ Name = "Tier", Type = "JournalLinkTypes", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncounterJournalConstants);