local ProfessionConstants =
{
	Tables =
	{
		{
			Name = "CraftingReagentType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Optional", Type = "CraftingReagentType", EnumValue = 0 },
				{ Name = "Basic", Type = "CraftingReagentType", EnumValue = 1 },
				{ Name = "Finishing", Type = "CraftingReagentType", EnumValue = 2 },
			},
		},
		{
			Name = "Profession",
			Type = "Enumeration",
			NumValues = 15,
			MinValue = 0,
			MaxValue = 14,
			Fields =
			{
				{ Name = "FirstAid", Type = "Profession", EnumValue = 0 },
				{ Name = "Blacksmithing", Type = "Profession", EnumValue = 1 },
				{ Name = "Leatherworking", Type = "Profession", EnumValue = 2 },
				{ Name = "Alchemy", Type = "Profession", EnumValue = 3 },
				{ Name = "Herbalism", Type = "Profession", EnumValue = 4 },
				{ Name = "Cooking", Type = "Profession", EnumValue = 5 },
				{ Name = "Mining", Type = "Profession", EnumValue = 6 },
				{ Name = "Tailoring", Type = "Profession", EnumValue = 7 },
				{ Name = "Engineering", Type = "Profession", EnumValue = 8 },
				{ Name = "Enchanting", Type = "Profession", EnumValue = 9 },
				{ Name = "Fishing", Type = "Profession", EnumValue = 10 },
				{ Name = "Skinning", Type = "Profession", EnumValue = 11 },
				{ Name = "Jewelcrafting", Type = "Profession", EnumValue = 12 },
				{ Name = "Inscription", Type = "Profession", EnumValue = 13 },
				{ Name = "Archaeology", Type = "Profession", EnumValue = 14 },
			},
		},
		{
			Name = "ProfessionActionType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Craft", Type = "ProfessionActionType", EnumValue = 0 },
				{ Name = "Gather", Type = "ProfessionActionType", EnumValue = 1 },
			},
		},
		{
			Name = "ProfessionEffect",
			Type = "Enumeration",
			NumValues = 26,
			MinValue = 0,
			MaxValue = 25,
			Fields =
			{
				{ Name = "Skill", Type = "ProfessionEffect", EnumValue = 0 },
				{ Name = "StatInspiration", Type = "ProfessionEffect", EnumValue = 1 },
				{ Name = "StatResourcefulness", Type = "ProfessionEffect", EnumValue = 2 },
				{ Name = "StatFinesse", Type = "ProfessionEffect", EnumValue = 3 },
				{ Name = "StatDeftness", Type = "ProfessionEffect", EnumValue = 4 },
				{ Name = "StatPerception", Type = "ProfessionEffect", EnumValue = 5 },
				{ Name = "StatCraftingSpeed", Type = "ProfessionEffect", EnumValue = 6 },
				{ Name = "StatMulticraft", Type = "ProfessionEffect", EnumValue = 7 },
				{ Name = "UnlockReagentSlot", Type = "ProfessionEffect", EnumValue = 8 },
				{ Name = "ModInspiration", Type = "ProfessionEffect", EnumValue = 9 },
				{ Name = "ModResourcefulness", Type = "ProfessionEffect", EnumValue = 10 },
				{ Name = "ModFinesse", Type = "ProfessionEffect", EnumValue = 11 },
				{ Name = "ModDeftness", Type = "ProfessionEffect", EnumValue = 12 },
				{ Name = "ModPerception", Type = "ProfessionEffect", EnumValue = 13 },
				{ Name = "ModCraftingSpeed", Type = "ProfessionEffect", EnumValue = 14 },
				{ Name = "ModMulticraft", Type = "ProfessionEffect", EnumValue = 15 },
				{ Name = "ModUnused_1", Type = "ProfessionEffect", EnumValue = 16 },
				{ Name = "ModUnused_2", Type = "ProfessionEffect", EnumValue = 17 },
				{ Name = "ModCraftExtraQuantity", Type = "ProfessionEffect", EnumValue = 18 },
				{ Name = "ModGatherExtraQuantity", Type = "ProfessionEffect", EnumValue = 19 },
				{ Name = "ModCraftCritSize", Type = "ProfessionEffect", EnumValue = 20 },
				{ Name = "ModCraftReductionQuantity", Type = "ProfessionEffect", EnumValue = 21 },
				{ Name = "DecreaseDifficulty", Type = "ProfessionEffect", EnumValue = 22 },
				{ Name = "IncreaseDifficulty", Type = "ProfessionEffect", EnumValue = 23 },
				{ Name = "ModSkillGain", Type = "ProfessionEffect", EnumValue = 24 },
				{ Name = "AccumulateRanksByLabel", Type = "ProfessionEffect", EnumValue = 25 },
			},
		},
		{
			Name = "ProfessionRating",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Inspiration", Type = "ProfessionRating", EnumValue = 0 },
				{ Name = "Resourcefulness", Type = "ProfessionRating", EnumValue = 1 },
				{ Name = "Finesse", Type = "ProfessionRating", EnumValue = 2 },
				{ Name = "Deftness", Type = "ProfessionRating", EnumValue = 3 },
				{ Name = "Perception", Type = "ProfessionRating", EnumValue = 4 },
				{ Name = "CraftingSpeed", Type = "ProfessionRating", EnumValue = 5 },
				{ Name = "Multicraft", Type = "ProfessionRating", EnumValue = 6 },
				{ Name = "Unused_1", Type = "ProfessionRating", EnumValue = 7 },
				{ Name = "Unused_2", Type = "ProfessionRating", EnumValue = 8 },
			},
		},
		{
			Name = "ProfessionRatingType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Craft", Type = "ProfessionRatingType", EnumValue = 0 },
				{ Name = "Gather", Type = "ProfessionRatingType", EnumValue = 1 },
			},
		},
		{
			Name = "SkinningState",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "SkinningState", EnumValue = 0 },
				{ Name = "Reserved", Type = "SkinningState", EnumValue = 1 },
				{ Name = "Skinning", Type = "SkinningState", EnumValue = 2 },
				{ Name = "Looting", Type = "SkinningState", EnumValue = 3 },
				{ Name = "Skinned", Type = "SkinningState", EnumValue = 4 },
			},
		},
		{
			Name = "ProfessionConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "NUM_PRIMARY_PROFESSIONS", Type = "number", Value = 2 },
				{ Name = "CLASSIC_PROFESSION_PARENT_TIER_INDEX", Type = "number", Value = 4 },
				{ Name = "RUNEFORGING_SKILL_LINE_ID", Type = "number", Value = 960 },
				{ Name = "RUNEFORGING_ROOT_CATEGORY_ID", Type = "number", Value = 210 },
				{ Name = "MAX_CRAFTING_REAGENT_SLOTS", Type = "number", Value = 12 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ProfessionConstants);