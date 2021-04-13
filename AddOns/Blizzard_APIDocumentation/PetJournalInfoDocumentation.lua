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
			Name = "GetPetAbilityInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "abilityID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "petType", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPetAbilityListTable",
			Type = "Function",

			Arguments =
			{
				{ Name = "speciesID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "table", InnerType = "PetAbilityLevelInfo", Nilable = false },
			},
		},
		{
			Name = "GetPetInfoTableByPetID",
			Type = "Function",

			Arguments =
			{
				{ Name = "petID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "PetJournalPetInfo", Nilable = false },
			},
		},
		{
			Name = "GetPetLoadOutInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "petID", Type = "string", Nilable = true },
				{ Name = "ability1ID", Type = "number", Nilable = false },
				{ Name = "ability2ID", Type = "number", Nilable = false },
				{ Name = "ability3ID", Type = "number", Nilable = false },
				{ Name = "locked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetPetSummonInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "battlePetGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSummonable", Type = "bool", Nilable = false },
				{ Name = "error", Type = "PetJournalError", Nilable = false },
				{ Name = "errorText", Type = "string", Nilable = false },
			},
		},
		{
			Name = "PetIsSummonable",
			Type = "Function",

			Arguments =
			{
				{ Name = "battlePetGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSummonable", Type = "bool", Nilable = false },
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
		{
			Name = "PetAbilityLevelInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "abilityID", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetJournalPetInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "speciesID", Type = "number", Nilable = false },
				{ Name = "customName", Type = "string", Nilable = true },
				{ Name = "petLevel", Type = "number", Nilable = false },
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "maxXP", Type = "number", Nilable = false },
				{ Name = "displayID", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "petType", Type = "number", Nilable = false },
				{ Name = "creatureID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "sourceText", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "isWild", Type = "bool", Nilable = false },
				{ Name = "canBattle", Type = "bool", Nilable = false },
				{ Name = "tradable", Type = "bool", Nilable = false },
				{ Name = "unique", Type = "bool", Nilable = false },
				{ Name = "obtainable", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PetJournalInfo);