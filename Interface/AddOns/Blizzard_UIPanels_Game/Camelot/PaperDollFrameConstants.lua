local SWORDS_WEAPON_SKILL_ID = 43;
local AXES_WEAPON_SKILL_ID = 44;
local BOWS_WEAPON_SKILL_ID = 45;
local GUNS_WEAPON_SKILL_ID = 46;
local MACES_WEAPON_SKILL_ID = 54;
local TWO_HANDED_SWORDS_WEAPON_SKILL_ID = 55;
local STAVES_WEAPON_SKILL_ID = 136;
local TWO_HANDED_MACES_WEAPON_SKILL_ID = 160;
local UNARMED_WEAPON_SKILL_ID = 162;
local TWO_HANDED_AXES_WEAPON_SKILL_ID = 172;
local DAGGERS_WEAPON_SKILL_ID = 173;
local THROWN_WEAPON_SKILL_ID = 176;
local CROSSBOWS_WEAPON_SKILL_ID = 226;
local WANDS_WEAPON_SKILL_ID = 228;
local POLEARMS_WEAPON_SKILL_ID = 229;
local FIST_WEAPONS_WEAPON_SKILL_ID = 473;
local FERAL_COMBAT_SKILL_ID = 134;

STAMINA_BREAK = 20;
INTELLECT_BREAK = 20;
MANA_PER_INTELLECT = 15;

PAPERDOLL_SIDEBARS = {PAPERDOLL_SIDEBARTAB_STATS, PAPERDOLL_SIDEBARTAB_EQUIPMENTMANAGER, PAPERDOLL_SIDEBARTAB_PET};

PAPER_DOLL_FRAME_SHOW_DPS = true;
PAPER_DOLL_FRAME_SHOW_RANGED_IF_UNEQUIPPED = false;

-- showFunc: only show if this function returns true (Note: make sure whatever your function is dependent on also triggers an update when it changes)

PAPERDOLL_STATCATEGORIES= {
	{
		categoryName = STAT_CATEGORY_GENERAL,
		unit = "player",
		stats = {
			{ stat = "HEALTH" },
			{ stat = "POWER" },
			{ stat = "MOVESPEED" },
		},
	},
	{
		categoryName = STAT_CATEGORY_PRIMARY_ATTRIBUTES,
		unit = "player",
		stats = { -- must match UNITSTAT order
			{ stat = "STRENGTH" },
			{ stat = "AGILITY" },
			{ stat = "STAMINA" },
			{ stat = "INTELLECT" },
			{ stat = "SPIRIT" },
		},
	},
	{
		categoryName = STAT_CATEGORY_WEAPONS,
		unit = "player",
		stats = {
			{ stat = "MAINHAND_DAMAGE" },
			{ stat = "OFFHAND_DAMAGE", hideAt = 0 },
			{ stat = "RANGED_DAMAGE", hideAt = 0 },
			{ stat = "ATTACK_AP", hideAt = 0 },
			{ stat = "RANGED_ATTACK_AP", hideAt = 0 },
		},
	},
	{
		categoryName = STAT_CATEGORY_MODIFIERS,
		unit = "player",
		stats = {
			{ stat = "HITCHANCE", hideAt = 0 },
			{ stat = "CRITCHANCE", hideAt = 0 },
			{ stat = "HASTE", hideAt = 0 },
			{ stat = "EXPERTISE", hideAt = 0 },
			{ stat = "ARMORPEN", hideAt = 0 },
			{ stat = "SPELLPOWER", hideAt = 0},
			{ stat = "SPELLHEALING", hideAt = 0 },
			{ stat = "SPELLPENETRATION", hideAt = 0 },
		},
	},
	{
		categoryName = STAT_CATEGORY_DEFENSE,
		unit = "player",
		stats = {
			{ stat = "DEFENSE" },
			{ stat = "DODGE", hideAt = 0  },
			{ stat = "BLOCK", hideAt = 0 , showFunc = C_PaperDollInfo.OffhandHasShield  },
			{ stat = "PARRY", hideAt = 0  },
			{ stat = "ARMOR" },
		},
	},
	{
		categoryName = STAT_CATEGORY_GENERAL,
		unit = "pet",
		stats = {
			{ stat = "HEALTH" },
			{ stat = "ARMOR" },
			{ stat = "MAINHAND_DAMAGE" },
			{ stat = "ATTACK_AP", hideAt = 0 },
			{ stat = "SPELLPOWER", hideAt = 0},
			{ stat = "HITCHANCE", hideAt = 0 },
			{ stat = "CRITCHANCE", hideAt = 0 },
			{ stat = "HASTE", hideAt = 0 },
			{ stat = "MOVESPEED" },
		},
	},
};
