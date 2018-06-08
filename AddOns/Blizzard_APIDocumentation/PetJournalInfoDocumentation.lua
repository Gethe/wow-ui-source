local PetJournalInfo =
{
	Name = "PetJournalInfo",
	Type = "System",
	Namespace = "C_PetJournal",

	Functions =
	{
		{
			Name = "GetDisplayIDByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "speciesID", Type = "number", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "displayID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetDisplayProbabilityByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "speciesID", Type = "number", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "displayProbability", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetNumDisplays",
			Type = "Function",

			Arguments =
			{
				{ Name = "speciesID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "numDisplays", Type = "number", Nilable = true },
			},
		},
		{
			Name = "PetUsesRandomDisplay",
			Type = "Function",

			Arguments =
			{
				{ Name = "speciesID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "usesRandomDisplay", Type = "bool", Nilable = true },
			},
		},
	},

	Events =
	{
		{
			Name = "BattlepetForceNameDeclension",
			Type = "Event",
			LiteralName = "BATTLEPET_FORCE_NAME_DECLENSION",
			Payload =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "battlePetGUID", Type = "string", Nilable = false },
			},
		},
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
				{ Name = "companionType", Type = "string", Nilable = true },
			},
		},
		{
			Name = "NewPetAdded",
			Type = "Event",
			LiteralName = "NEW_PET_ADDED",
			Payload =
			{
				{ Name = "battlePetGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PetJournalAutoSlottedPet",
			Type = "Event",
			LiteralName = "PET_JOURNAL_AUTO_SLOTTED_PET",
			Payload =
			{
				{ Name = "slotIndex", Type = "number", Nilable = false },
				{ Name = "battlePetGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PetJournalCageFailed",
			Type = "Event",
			LiteralName = "PET_JOURNAL_CAGE_FAILED",
		},
		{
			Name = "PetJournalListUpdate",
			Type = "Event",
			LiteralName = "PET_JOURNAL_LIST_UPDATE",
		},
		{
			Name = "PetJournalNewBattleSlot",
			Type = "Event",
			LiteralName = "PET_JOURNAL_NEW_BATTLE_SLOT",
		},
		{
			Name = "PetJournalPetDeleted",
			Type = "Event",
			LiteralName = "PET_JOURNAL_PET_DELETED",
			Payload =
			{
				{ Name = "battlePetGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PetJournalPetRestored",
			Type = "Event",
			LiteralName = "PET_JOURNAL_PET_RESTORED",
			Payload =
			{
				{ Name = "battlePetGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PetJournalPetRevoked",
			Type = "Event",
			LiteralName = "PET_JOURNAL_PET_REVOKED",
			Payload =
			{
				{ Name = "battlePetGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PetJournalPetsHealed",
			Type = "Event",
			LiteralName = "PET_JOURNAL_PETS_HEALED",
		},
		{
			Name = "PetJournalTrapLevelSet",
			Type = "Event",
			LiteralName = "PET_JOURNAL_TRAP_LEVEL_SET",
			Payload =
			{
				{ Name = "trapLevel", Type = "number", Nilable = false },
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
	},
};

APIDocumentation:AddDocumentationTable(PetJournalInfo);