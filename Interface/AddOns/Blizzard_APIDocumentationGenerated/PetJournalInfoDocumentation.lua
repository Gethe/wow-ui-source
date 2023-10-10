local PetJournalInfo =
{
	Name = "PetJournalInfo",
	Type = "System",
	Namespace = "C_PetJournal",

	Functions =
	{
		{
			Name = "GetNumPetsInJournal",
			Type = "Function",

			Arguments =
			{
				{ Name = "creatureID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "maxAllowed", Type = "number", Nilable = false },
				{ Name = "numPets", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPetSummonInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "battlePetGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSummonable", Type = "bool", Nilable = false },
				{ Name = "error", Type = "PetJournalError", Nilable = false },
				{ Name = "errorText", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "PetIsSummonable",
			Type = "Function",

			Arguments =
			{
				{ Name = "battlePetGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSummonable", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CompanionLearned",
			Type = "Event",
			LiteralName = "COMPANION_LEARNED",
		},
		{
			Name = "CompanionUnlearned",
			Type = "Event",
			LiteralName = "COMPANION_UNLEARNED",
		},
		{
			Name = "CompanionUpdate",
			Type = "Event",
			LiteralName = "COMPANION_UPDATE",
			Payload =
			{
				{ Name = "companionType", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "NewPetAdded",
			Type = "Event",
			LiteralName = "NEW_PET_ADDED",
			Payload =
			{
				{ Name = "battlePetGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "PetJournalListUpdate",
			Type = "Event",
			LiteralName = "PET_JOURNAL_LIST_UPDATE",
		},
		{
			Name = "PetJournalPetDeleted",
			Type = "Event",
			LiteralName = "PET_JOURNAL_PET_DELETED",
			Payload =
			{
				{ Name = "battlePetGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "PetJournalPetRestored",
			Type = "Event",
			LiteralName = "PET_JOURNAL_PET_RESTORED",
			Payload =
			{
				{ Name = "battlePetGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "PetJournalPetRevoked",
			Type = "Event",
			LiteralName = "PET_JOURNAL_PET_REVOKED",
			Payload =
			{
				{ Name = "battlePetGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "UpdateSummonpetsAction",
			Type = "Event",
			LiteralName = "UPDATE_SUMMONPETS_ACTION",
		},
	},

	Tables =
	{
		{
			Name = "PetJournalError",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "None", Type = "PetJournalError", EnumValue = 0 },
				{ Name = "PetIsDead", Type = "PetJournalError", EnumValue = 1 },
				{ Name = "JournalIsLocked", Type = "PetJournalError", EnumValue = 2 },
				{ Name = "InvalidFaction", Type = "PetJournalError", EnumValue = 3 },
				{ Name = "NoFavoritesToSummon", Type = "PetJournalError", EnumValue = 4 },
				{ Name = "NoValidRandomSummon", Type = "PetJournalError", EnumValue = 5 },
				{ Name = "InvalidCovenant", Type = "PetJournalError", EnumValue = 6 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PetJournalInfo);