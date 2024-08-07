local PetConstants =
{
	Tables =
	{
		{
			Name = "PetConsts_PostCata",
			Type = "Constants",
			Values =
			{
				{ Name = "NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL", Type = "number", Value = 5 },
				{ Name = "MAX_SUMMONABLE_PETS", Type = "number", Value = 25 },
				{ Name = "MAX_SUMMONABLE_HUNTER_PETS", Type = "number", Value = NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
				{ Name = "MAX_STABLE_SLOTS", Type = "number", Value = 200 },
				{ Name = "EXTRA_PET_STABLE_SLOT", Type = "number", Value = (int)MAX_SUMMONABLE_HUNTER_PETS },
				{ Name = "STABLED_PETS_FIRST_SLOT_INDEX", Type = "number", Value = Constants.PetConsts.EXTRA_PET_STABLE_SLOT },
				{ Name = "NUM_PET_SLOTS_HUNTER", Type = "number", Value = Constants.PetConsts.MAX_STABLE_SLOTS + Constants.PetConsts.NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
				{ Name = "NUM_PET_SLOTS_DEATHKNIGHT", Type = "number", Value = 1 },
				{ Name = "NUM_PET_SLOTS_MAGE", Type = "number", Value = 1 },
				{ Name = "NUM_PET_SLOTS_WARLOCK", Type = "number", Value = MAX_SUMMONABLE_PETS },
				{ Name = "MAX_NUM_PET_SLOTS", Type = "number", Value = NUM_PET_SLOTS_HUNTER },
			},
		},
		{
			Name = "PetConsts_PreWrath",
			Type = "Constants",
			Values =
			{
				{ Name = "NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL", Type = "number", Value = 1 },
				{ Name = "MAX_SUMMONABLE_PETS", Type = "number", Value = 25 },
				{ Name = "MAX_SUMMONABLE_HUNTER_PETS", Type = "number", Value = NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
				{ Name = "MAX_STABLE_SLOTS", Type = "number", Value = 2 },
				{ Name = "EXTRA_PET_STABLE_SLOT", Type = "number", Value = 0 },
				{ Name = "STABLED_PETS_FIRST_SLOT_INDEX", Type = "number", Value = (int)MAX_SUMMONABLE_HUNTER_PETS },
				{ Name = "NUM_PET_SLOTS_HUNTER", Type = "number", Value = MAX_STABLE_SLOTS + NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
				{ Name = "NUM_PET_SLOTS_DEATHKNIGHT", Type = "number", Value = 0 },
				{ Name = "NUM_PET_SLOTS_MAGE", Type = "number", Value = 1 },
				{ Name = "NUM_PET_SLOTS_WARLOCK", Type = "number", Value = MAX_SUMMONABLE_PETS },
				{ Name = "MAX_NUM_PET_SLOTS", Type = "number", Value = MAX_SUMMONABLE_PETS },
			},
		},
		{
			Name = "PetConsts_Wrath",
			Type = "Constants",
			Values =
			{
				{ Name = "NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL", Type = "number", Value = 1 },
				{ Name = "MAX_SUMMONABLE_PETS", Type = "number", Value = 25 },
				{ Name = "MAX_SUMMONABLE_HUNTER_PETS", Type = "number", Value = NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
				{ Name = "MAX_STABLE_SLOTS", Type = "number", Value = 4 },
				{ Name = "EXTRA_PET_STABLE_SLOT", Type = "number", Value = 0 },
				{ Name = "STABLED_PETS_FIRST_SLOT_INDEX", Type = "number", Value = (int)MAX_SUMMONABLE_HUNTER_PETS },
				{ Name = "NUM_PET_SLOTS_HUNTER", Type = "number", Value = MAX_STABLE_SLOTS + NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
				{ Name = "NUM_PET_SLOTS_DEATHKNIGHT", Type = "number", Value = 1 },
				{ Name = "NUM_PET_SLOTS_MAGE", Type = "number", Value = 1 },
				{ Name = "NUM_PET_SLOTS_WARLOCK", Type = "number", Value = MAX_SUMMONABLE_PETS },
				{ Name = "MAX_NUM_PET_SLOTS", Type = "number", Value = MAX_SUMMONABLE_PETS },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PetConstants);