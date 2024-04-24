local PetConstants =
{
	Tables =
	{
		{
			Name = "PetConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "MAX_STABLE_SLOTS", Type = "number", Value = 200 },
				{ Name = "MAX_SUMMONABLE_PETS", Type = "number", Value = 25 },
				{ Name = "MAX_SUMMONABLE_HUNTER_PETS", Type = "number", Value = 5 },
				{ Name = "NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL", Type = "number", Value = 5 },
				{ Name = "NUM_PET_SLOTS", Type = "number", Value = MAX_STABLE_SLOTS + NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
				{ Name = "EXTRA_PET_STABLE_SLOT", Type = "number", Value = 5 },
				{ Name = "STABLED_PETS_FIRST_SLOT_INDEX", Type = "number", Value = EXTRA_PET_STABLE_SLOT + 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PetConstants);