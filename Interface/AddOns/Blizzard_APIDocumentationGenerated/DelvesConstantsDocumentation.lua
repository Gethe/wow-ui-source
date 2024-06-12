local DelvesConstants =
{
	Tables =
	{
		{
			Name = "CompanionConfigSlotTypes",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Role", Type = "CompanionConfigSlotTypes", EnumValue = 0 },
				{ Name = "Utility", Type = "CompanionConfigSlotTypes", EnumValue = 1 },
				{ Name = "Combat", Type = "CompanionConfigSlotTypes", EnumValue = 2 },
			},
		},
		{
			Name = "CurioRarity",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Common", Type = "CurioRarity", EnumValue = 1 },
				{ Name = "Uncommon", Type = "CurioRarity", EnumValue = 2 },
				{ Name = "Rare", Type = "CurioRarity", EnumValue = 3 },
				{ Name = "Epic", Type = "CurioRarity", EnumValue = 4 },
			},
		},
		{
			Name = "DelvesConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "MIN_PLAYER_LEVEL", Type = "number", Value = 70 },
				{ Name = "DELVE_NORMAL_KEY_CURRENCY_ID", Type = "number", Value = 3028 },
				{ Name = "DELVE_EPIC_KEY_CURRENCY_ID", Type = "number", Value = 3029 },
				{ Name = "DELVE_COMPANION_TOOLTIP_WIDGET_SET_ID", Type = "number", Value = 1331 },
				{ Name = "DELVES_COMPANION_TRAIT_SYSTEM_ID", Type = "number", Value = 6 },
				{ Name = "BRANN_COMPANION_INFO_ID", Type = "number", Value = 1 },
				{ Name = "BRANN_TRAIT_TREE_ID", Type = "number", Value = 874 },
				{ Name = "BRANN_CREATURE_DISPLAY_ID", Type = "number", Value = 115505 },
				{ Name = "BRANN_FACTION_ID", Type = "number", Value = 2640 },
				{ Name = "BRANN_ROLE_NODE_ID", Type = "number", Value = 99809 },
				{ Name = "BRANN_COMBAT_TRINKET_NODE_ID", Type = "number", Value = 99855 },
				{ Name = "BRANN_UTILITY_TRINKET_NODE_ID", Type = "number", Value = 99854 },
				{ Name = "BRANN_DPS_SUBTREE_ID", Type = "number", Value = 29 },
				{ Name = "BRANN_HEALER_SUBTREE_ID", Type = "number", Value = 30 },
				{ Name = "DELVES_S1_FACTION_ID", Type = "number", Value = 2644 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DelvesConstants);