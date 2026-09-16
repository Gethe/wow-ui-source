local PetConstants =
{
	Tables =
	{
		{
			Name = "PetActionbuttonType",
			Type = "Enumeration",
			NumValues = 28,
			MinValue = 0,
			MaxValue = 27,
			Fields =
			{
				{ Name = "None", Type = "PetActionbuttonType", EnumValue = 0 },
				{ Name = "Spell", Type = "PetActionbuttonType", EnumValue = 1 },
				{ Name = "Slot1Obsolete", Type = "PetActionbuttonType", EnumValue = 2 },
				{ Name = "Slot2Obsolete", Type = "PetActionbuttonType", EnumValue = 3 },
				{ Name = "Slot3Obsolete", Type = "PetActionbuttonType", EnumValue = 4 },
				{ Name = "Slot4Obsolete", Type = "PetActionbuttonType", EnumValue = 5 },
				{ Name = "Mode", Type = "PetActionbuttonType", EnumValue = 6 },
				{ Name = "Orders", Type = "PetActionbuttonType", EnumValue = 7 },
				{ Name = "Slot1", Type = "PetActionbuttonType", EnumValue = 8 },
				{ Name = "Slot2", Type = "PetActionbuttonType", EnumValue = 9 },
				{ Name = "Slot3", Type = "PetActionbuttonType", EnumValue = 10 },
				{ Name = "Slot4", Type = "PetActionbuttonType", EnumValue = 11 },
				{ Name = "Slot5", Type = "PetActionbuttonType", EnumValue = 12 },
				{ Name = "Slot6", Type = "PetActionbuttonType", EnumValue = 13 },
				{ Name = "Slot7", Type = "PetActionbuttonType", EnumValue = 14 },
				{ Name = "Slot8", Type = "PetActionbuttonType", EnumValue = 15 },
				{ Name = "Slot9", Type = "PetActionbuttonType", EnumValue = 16 },
				{ Name = "Slot10", Type = "PetActionbuttonType", EnumValue = 17 },
				{ Name = "Slot11", Type = "PetActionbuttonType", EnumValue = 18 },
				{ Name = "Slot12", Type = "PetActionbuttonType", EnumValue = 19 },
				{ Name = "Slot13", Type = "PetActionbuttonType", EnumValue = 20 },
				{ Name = "Slot14", Type = "PetActionbuttonType", EnumValue = 21 },
				{ Name = "Slot15", Type = "PetActionbuttonType", EnumValue = 22 },
				{ Name = "Slot16", Type = "PetActionbuttonType", EnumValue = 23 },
				{ Name = "Slot17", Type = "PetActionbuttonType", EnumValue = 24 },
				{ Name = "Slot18", Type = "PetActionbuttonType", EnumValue = 25 },
				{ Name = "Max", Type = "PetActionbuttonType", EnumValue = 26 },
				{ Name = "VehicleAction", Type = "PetActionbuttonType", EnumValue = 27 },
			},
		},
		{
			Name = "PetConsts_Camelot",
			Type = "Constants",
			Values =
			{
				{ Name = "PET_XP_LEVEL_MODIFIER", Type = "number", Value = 0.25 },
				{ Name = "NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL", Type = "number", Value = 1 },
				{ Name = "MAX_SUMMONABLE_HUNTER_PETS", Type = "number", Value = Constants.PetConsts.NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
				{ Name = "MAX_STABLE_SLOTS", Type = "number", Value = 2 },
				{ Name = "EXTRA_PET_STABLE_SLOT", Type = "number", Value = Constants.PetConsts.PETNUMBER_INVALIDSLOT },
				{ Name = "STABLED_PETS_FIRST_SLOT_INDEX", Type = "number", Value = Constants.PetConsts.MAX_SUMMONABLE_HUNTER_PETS },
				{ Name = "NUM_PET_SLOTS_HUNTER", Type = "number", Value = Constants.PetConsts.MAX_STABLE_SLOTS + Constants.PetConsts.NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
				{ Name = "MAX_NUM_PET_SLOTS", Type = "number", Value = Constants.PetConsts.MAX_SUMMONABLE_PETS },
				{ Name = "DEFAULT_PET_PERSONALITY", Type = "number", Value = 1 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PetConstants);