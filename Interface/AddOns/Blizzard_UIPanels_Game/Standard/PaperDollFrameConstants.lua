PAPERDOLL_SIDEBARS = {PAPERDOLL_SIDEBARTAB_STATS, PAPERDOLL_SIDEBARTAB_TITLES, PAPERDOLL_SIDEBARTAB_EQUIPMENTMANAGER};

-- primary: only show the 1 for the player's current spec
-- roles: only show if the player's current spec is one of the roles
-- hideAt: only show if it's not this value
-- showFunc: only show if this function returns true (Note: make sure whatever your function is dependent on also triggers an update when it changes)

PAPERDOLL_STATCATEGORIES= {
	[1] = {
		categoryFrame = "AttributesCategory",
		stats = {
			[1] = { stat = "STRENGTH", primary = LE_UNIT_STAT_STRENGTH },
			[2] = { stat = "AGILITY", primary = LE_UNIT_STAT_AGILITY },
			[3] = { stat = "INTELLECT", primary = LE_UNIT_STAT_INTELLECT },
			[4] = { stat = "STAMINA" },
			[5] = { stat = "ARMOR" },
			[6] = { stat = "STAGGER", hideAt = 0, roles = { Enum.LFGRole.Tank }},
			[7] = { stat = "MANAREGEN", roles =  { Enum.LFGRole.Healer } },
		},
	},
	[2] = {
		categoryFrame = "EnhancementsCategory",
		stats = {
			{ stat = "CRITCHANCE", hideAt = 0 },
			{ stat = "HASTE", hideAt = 0 },
			{ stat = "MASTERY", hideAt = 0 },
			{ stat = "VERSATILITY", hideAt = 0 },
			{ stat = "LIFESTEAL", hideAt = 0 },
			{ stat = "AVOIDANCE", hideAt = 0 },
			{ stat = "SPEED", hideAt = 0 },
			{ stat = "DODGE", roles =  { Enum.LFGRole.Tank } },
			{ stat = "PARRY", hideAt = 0, roles =  { Enum.LFGRole.Tank } },
			{ stat = "BLOCK", hideAt = 0, showFunc = C_PaperDollInfo.OffhandHasShield },
		},
	},
};
