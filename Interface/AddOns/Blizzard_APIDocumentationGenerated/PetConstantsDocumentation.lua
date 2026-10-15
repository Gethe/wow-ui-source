local PetConstants =
{
	Tables =
	{
		{
			Name = "PetConsts_Retail",
			Type = "Constants",
			Values =
			{
				{ Name = "PET_XP_LEVEL_MODIFIER", Type = "number", Value = 0.05 },
				{ Name = "NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL", Type = "number", Value = 5 },
				{ Name = "MAX_SUMMONABLE_HUNTER_PETS", Type = "number", Value = Constants.PetConsts.NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
				{ Name = "MAX_STABLE_SLOTS", Type = "number", Value = 200 },
				{ Name = "EXTRA_PET_STABLE_SLOT", Type = "number", Value = Constants.PetConsts.MAX_SUMMONABLE_HUNTER_PETS },
				{ Name = "STABLED_PETS_FIRST_SLOT_INDEX", Type = "number", Value = Constants.PetConsts.EXTRA_PET_STABLE_SLOT },
				{ Name = "NUM_PET_SLOTS_HUNTER", Type = "number", Value = Constants.PetConsts.MAX_STABLE_SLOTS + Constants.PetConsts.NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
				{ Name = "MAX_NUM_PET_SLOTS", Type = "number", Value = Constants.PetConsts.NUM_PET_SLOTS_HUNTER },
				{ Name = "DEFAULT_PET_PERSONALITY", Type = "number", Value = 0 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PetConstants);