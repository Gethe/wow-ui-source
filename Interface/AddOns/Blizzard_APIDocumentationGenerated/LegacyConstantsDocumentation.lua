local LegacyConstants =
{
	Tables =
	{
		{
			Name = "LegacyRewardFlags",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Milestone", Type = "LegacyRewardFlags", EnumValue = 1 },
				{ Name = "Capstone", Type = "LegacyRewardFlags", EnumValue = 2 },
				{ Name = "Hidden", Type = "LegacyRewardFlags", EnumValue = 4 },
			},
		},
		{
			Name = "LegacyConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "LEGACY_REWARD_TRACK_FACTION_ID", Type = "number", Value = 2802 },
				{ Name = "LEGACY_POINTS_TRAIT_CURRENCY_ID", Type = "number", Value = 4225 },
				{ Name = "LEGACY_REWARD_MAX_LEGACY_POINTS", Type = "number", Value = 90 },
				{ Name = "LEGACY_REWARD_TEXTURE_KIT_ID", Type = "number", Value = 5578 },
				{ Name = "LEGACY_REWARD_GLOBAL_COLOR_ID", Type = "number", Value = 296 },
				{ Name = "LEGACY_TREE_PROFESSIONS_ID", Type = "number", Value = 1187 },
				{ Name = "LEGACY_TREE_ADVENTURE_ID", Type = "number", Value = 1188 },
				{ Name = "LEGACY_TREE_PROGRESSION_ID", Type = "number", Value = 1189 },
				{ Name = "LEGACY_TREE_ADVENTURE_TALENTED_NODE_ID", Type = "number", Value = 110298 },
				{ Name = "LEGACY_DEFAULT_CATEGORY_WARRIOR", Type = "number", Value = 15585 },
				{ Name = "LEGACY_DEFAULT_CATEGORY_PALADIN", Type = "number", Value = 15580 },
				{ Name = "LEGACY_DEFAULT_CATEGORY_HUNTER", Type = "number", Value = 15578 },
				{ Name = "LEGACY_DEFAULT_CATEGORY_ROGUE", Type = "number", Value = 15582 },
				{ Name = "LEGACY_DEFAULT_CATEGORY_PRIEST", Type = "number", Value = 15581 },
				{ Name = "LEGACY_DEFAULT_CATEGORY_SHAMAN", Type = "number", Value = 15583 },
				{ Name = "LEGACY_DEFAULT_CATEGORY_MAGE", Type = "number", Value = 15579 },
				{ Name = "LEGACY_DEFAULT_CATEGORY_WARLOCK", Type = "number", Value = 15584 },
				{ Name = "LEGACY_DEFAULT_CATEGORY_DRUID", Type = "number", Value = 15577 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(LegacyConstants);