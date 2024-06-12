﻿--
-- New constants should be added to this file and other constants
-- deprecated and moved to this file.
--

WORLD_QUEST_ICONS_BY_PROFESSION = {
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.FirstAid)] = "worldquest-icon-firstaid",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Blacksmithing)] = "worldquest-icon-blacksmithing",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Leatherworking)] = "worldquest-icon-leatherworking",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Alchemy)] = "worldquest-icon-alchemy",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Herbalism)] = "worldquest-icon-herbalism",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Mining)] = "worldquest-icon-mining",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Engineering)] = "worldquest-icon-engineering",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Enchanting)] = "worldquest-icon-enchanting",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Jewelcrafting)] = "worldquest-icon-jewelcrafting",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Inscription)] = "worldquest-icon-inscription",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Archaeology)] = "worldquest-icon-archaeology",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Fishing)] = "worldquest-icon-fishing",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Cooking)] = "worldquest-icon-cooking",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Tailoring)] = "worldquest-icon-tailoring",
	[C_TradeSkillUI.GetProfessionSkillLineID(Enum.Profession.Skinning)] = "worldquest-icon-skinning",
};

HTML_START = "<html><body><p>";
HTML_START_CENTERED = "<html><body><p align=\"center\">";
HTML_END = "</p></body></html>";

--
-- Trading Post
--
LOOT_SOURCE_TRADING_POST = 11;


--
-- Class
--
CLASS_SORT_ORDER = {
	"WARRIOR",
	"DEATHKNIGHT",
	"PALADIN",
	"MONK",
	"PRIEST",
	"SHAMAN",
	"DRUID",
	"ROGUE",
	"MAGE",
	"WARLOCK",
	"HUNTER",
	"DEMONHUNTER",
	"EVOKER",
};
MAX_CLASSES = #CLASS_SORT_ORDER;

LOCALIZED_CLASS_NAMES_MALE = LocalizedClassList(false);
LOCALIZED_CLASS_NAMES_FEMALE = LocalizedClassList(true);

--
-- Spell
--
HUNTER_DISMISS_PET = 2641;
WARLOCK_METAMORPHOSIS = 103958;
WARLOCK_SOULBURN = 117198;
WARLOCK_GREEN_FIRE = 101508;
BATTLEGROUND_ENLISTMENT_BONUS = 241260;

SCHOOL_STRINGS = {
	STRING_SCHOOL_PHYSICAL,
	STRING_SCHOOL_HOLY,
	STRING_SCHOOL_FIRE,
	STRING_SCHOOL_NATURE,
	STRING_SCHOOL_FROST,
	STRING_SCHOOL_SHADOW,
	STRING_SCHOOL_ARCANE
}


MAX_POWER_PER_EMBER = 10;

SPECIALIZATION_TAB = 1;
TALENTS_TAB = 2;
NUM_TALENT_FRAME_TABS = 2;

--
-- Specs
--
SPEC_WARLOCK_AFFLICTION = 1;	--These are spec indices
SPEC_WARLOCK_DEMONOLOGY = 2;
SPEC_WARLOCK_DESTRUCTION = 3;
SPEC_PRIEST_SHADOW = 3;
SPEC_MONK_MISTWEAVER = 2;
SPEC_MONK_BREWMASTER = 1;
SPEC_MONK_WINDWALKER = 3;
SPEC_PALADIN_RETRIBUTION = 3;
SPEC_MAGE_ARCANE = 1;
SPEC_SHAMAN_RESTORATION = 3;
SPEC_DRUID_BALANCE = 1;
SPEC_DRUID_FERAL = 2;
SPEC_DRUID_GUARDIAN = 3;
SPEC_EVOKER_AUGMENTATION = 3;

TALENT_SORT_ORDER = {
	"spec1",
	"spec2",
};

TALENT_ACTIVATION_SPELLS = {
	63645,
	63644,
};

--
-- Achievement
--

-- Criteria Types
CRITERIA_TYPE_ACHIEVEMENT = 8;

-- Achievement Flags
ACHIEVEMENT_FLAGS_HAS_PROGRESS_BAR 				= 0x00000080;
ACHIEVEMENT_FLAGS_GUILD							= 0x00004000;
ACHIEVEMENT_FLAGS_SHOW_GUILD_MEMBERS			= 0x00008000;
ACHIEVEMENT_FLAGS_SHOW_CRITERIA_MEMBERS 		= 0x00010000;
ACHIEVEMENT_FLAGS_ACCOUNT 						= 0x00020000;
ACHIEVEMENT_FLAGS_TOAST_ON_REPEAT_COMPLETION	= 0x02000000;

-- Eval Tree Flags
EVALUATION_TREE_FLAG_PROGRESS_BAR		= 0x00000001;
EVALUATION_TREE_FLAG_DO_NOT_DISPLAY		= 0x00000002;
NUM_EVALUATION_TREE_FLAGS				= 2;

--
-- Inventory
--

-- General item constants
ITEM_UNIQUE_EQUIPPED = -1;
MAX_NUM_SOCKETS = 3;

BAG_ITEM_QUALITY_COLORS = {
	[Enum.ItemQuality.Common] = COMMON_GRAY_COLOR,
	[Enum.ItemQuality.Uncommon] = UNCOMMON_GREEN_COLOR,
	[Enum.ItemQuality.Rare] = RARE_BLUE_COLOR,
	[Enum.ItemQuality.Epic] = EPIC_PURPLE_COLOR,
	[Enum.ItemQuality.Legendary] = LEGENDARY_ORANGE_COLOR,
	[Enum.ItemQuality.Artifact] = ARTIFACT_GOLD_COLOR,
	[Enum.ItemQuality.Heirloom] = HEIRLOOM_BLUE_COLOR,
	[Enum.ItemQuality.WoWToken] = HEIRLOOM_BLUE_COLOR,
}

NEW_ITEM_ATLAS_BY_QUALITY = {
	[Enum.ItemQuality.Poor] = "bags-glow-white",
	[Enum.ItemQuality.Common] = "bags-glow-white",
	[Enum.ItemQuality.Uncommon] = "bags-glow-green",
	[Enum.ItemQuality.Rare] = "bags-glow-blue",
	[Enum.ItemQuality.Epic] = "bags-glow-purple",
	[Enum.ItemQuality.Legendary] = "bags-glow-orange",
	[Enum.ItemQuality.Artifact] = "bags-glow-artifact",
	[Enum.ItemQuality.Heirloom] = "bags-glow-heirloom",
};

-- Loot
LOOT_BORDER_BY_QUALITY = {
	[Enum.ItemQuality.Uncommon] = "loottoast-itemborder-green",
	[Enum.ItemQuality.Rare] = "loottoast-itemborder-blue",
	[Enum.ItemQuality.Epic] = "loottoast-itemborder-purple",
	[Enum.ItemQuality.Legendary] = "loottoast-itemborder-orange",
	[Enum.ItemQuality.Heirloom] = "loottoast-itemborder-heirloom",
	[Enum.ItemQuality.Artifact] = "loottoast-itemborder-artifact",
};

LOOT_ROLL_TYPE_PASS = 0;
LOOT_ROLL_TYPE_NEED = 1;
LOOT_ROLL_TYPE_GREED = 2;
LOOT_ROLL_TYPE_DISENCHANT = 3;

-- Item location bitflags
ITEM_INVENTORY_LOCATION_PLAYER		= 0x00100000;
ITEM_INVENTORY_LOCATION_BAGS		= 0x00200000;
ITEM_INVENTORY_LOCATION_BANK		= 0x00400000;
ITEM_INVENTORY_LOCATION_VOIDSTORAGE	= 0x00800000;
ITEM_INVENTORY_BAG_BIT_OFFSET 		= 8; -- Number of bits that the bag index in GetInventoryItemsForSlot gets shifted to the left.

-- Inventory slots
INVSLOT_AMMO		= 0;
INVSLOT_HEAD 		= 1; INVSLOT_FIRST_EQUIPPED = INVSLOT_HEAD;
INVSLOT_NECK		= 2;
INVSLOT_SHOULDER	= 3;
INVSLOT_BODY		= 4;
INVSLOT_CHEST		= 5;
INVSLOT_WAIST		= 6;
INVSLOT_LEGS		= 7;
INVSLOT_FEET		= 8;
INVSLOT_WRIST		= 9;
INVSLOT_HAND		= 10;
INVSLOT_FINGER1		= 11;
INVSLOT_FINGER2		= 12;
INVSLOT_TRINKET1	= 13;
INVSLOT_TRINKET2	= 14;
INVSLOT_BACK		= 15;
INVSLOT_MAINHAND	= 16;
INVSLOT_OFFHAND		= 17;
INVSLOT_RANGED		= 18;
INVSLOT_TABARD		= 19;
INVSLOT_LAST_EQUIPPED = INVSLOT_TABARD;
NUM_INVSLOTS = (INVSLOT_LAST_EQUIPPED - INVSLOT_FIRST_EQUIPPED) + 1;

INVSLOTS_EQUIPABLE_IN_COMBAT = {
[INVSLOT_MAINHAND] = true,
[INVSLOT_OFFHAND] = true,
[INVSLOT_RANGED] = true,
}

-- Container constants
BACKPACK_CONTAINER = Enum.BagIndex.Backpack;
BANK_CONTAINER = Enum.BagIndex.Bank;
BANK_CONTAINER_INVENTORY_OFFSET = 39; -- Used for PickupInventoryItem
REAGENTBANK_CONTAINER = Enum.BagIndex.Reagentbank;

NUM_BAG_SLOTS = Constants.InventoryConstants.NumBagSlots;
NUM_REAGENTBAG_SLOTS = Constants.InventoryConstants.NumReagentBagSlots;
NUM_TOTAL_EQUIPPED_BAG_SLOTS = NUM_BAG_SLOTS + NUM_REAGENTBAG_SLOTS;
NUM_BANKGENERIC_SLOTS = Constants.InventoryConstants.NumGenericBankSlots;
NUM_BANKBAGSLOTS = Constants.InventoryConstants.NumBankBagSlots;

ITEM_INVENTORY_BANK_BAG_OFFSET = NUM_TOTAL_EQUIPPED_BAG_SLOTS; -- Number of bags before the first bank bag
CONTAINER_BAG_OFFSET = 30; -- Used for PutItemInBag

-- Item IDs
HEARTHSTONE_ITEM_ID = 6948;

--
-- Equipment Set
--
MAX_EQUIPMENT_SETS_PER_PLAYER = 10;
EQUIPMENT_SET_EMPTY_SLOT = 0;
EQUIPMENT_SET_IGNORED_SLOT = 1;
EQUIPMENT_SET_ITEM_MISSING = -1;

--
-- Combat Log
--

-- Affiliation
COMBATLOG_OBJECT_AFFILIATION_MINE		= 0x00000001;
COMBATLOG_OBJECT_AFFILIATION_PARTY		= 0x00000002;
COMBATLOG_OBJECT_AFFILIATION_RAID		= 0x00000004;
COMBATLOG_OBJECT_AFFILIATION_OUTSIDER		= 0x00000008;
COMBATLOG_OBJECT_AFFILIATION_MASK		= 0x0000000F;
-- Reaction
COMBATLOG_OBJECT_REACTION_FRIENDLY		= 0x00000010;
COMBATLOG_OBJECT_REACTION_NEUTRAL		= 0x00000020;
COMBATLOG_OBJECT_REACTION_HOSTILE		= 0x00000040;
COMBATLOG_OBJECT_REACTION_MASK			= 0x000000F0;
-- Ownership
COMBATLOG_OBJECT_CONTROL_PLAYER			= 0x00000100;
COMBATLOG_OBJECT_CONTROL_NPC			= 0x00000200;
COMBATLOG_OBJECT_CONTROL_MASK			= 0x00000300;
-- Unit type
COMBATLOG_OBJECT_TYPE_PLAYER			= 0x00000400;
COMBATLOG_OBJECT_TYPE_NPC			= 0x00000800;
COMBATLOG_OBJECT_TYPE_PET			= 0x00001000;
COMBATLOG_OBJECT_TYPE_GUARDIAN			= 0x00002000;
COMBATLOG_OBJECT_TYPE_OBJECT			= 0x00004000;
COMBATLOG_OBJECT_TYPE_MASK			= 0x0000FC00;

-- Special cases (non-exclusive)
COMBATLOG_OBJECT_TARGET				= 0x00010000;
COMBATLOG_OBJECT_FOCUS				= 0x00020000;
COMBATLOG_OBJECT_MAINTANK			= 0x00040000;
COMBATLOG_OBJECT_MAINASSIST			= 0x00080000;
COMBATLOG_OBJECT_NONE				= 0x80000000;
COMBATLOG_OBJECT_SPECIAL_MASK		= 0xFFFF0000;

COMBATLOG_OBJECT_RAIDTARGET1		= 0x00000001;
COMBATLOG_OBJECT_RAIDTARGET2		= 0x00000002;
COMBATLOG_OBJECT_RAIDTARGET3		= 0x00000004;
COMBATLOG_OBJECT_RAIDTARGET4		= 0x00000008;
COMBATLOG_OBJECT_RAIDTARGET5		= 0x00000010;
COMBATLOG_OBJECT_RAIDTARGET6		= 0x00000020;
COMBATLOG_OBJECT_RAIDTARGET7		= 0x00000040;
COMBATLOG_OBJECT_RAIDTARGET8		= 0x00000080;
COMBATLOG_OBJECT_RAIDTARGET_MASK	= bit.bor(
						COMBATLOG_OBJECT_RAIDTARGET1,
						COMBATLOG_OBJECT_RAIDTARGET2,
						COMBATLOG_OBJECT_RAIDTARGET3,
						COMBATLOG_OBJECT_RAIDTARGET4,
						COMBATLOG_OBJECT_RAIDTARGET5,
						COMBATLOG_OBJECT_RAIDTARGET6,
						COMBATLOG_OBJECT_RAIDTARGET7,
						COMBATLOG_OBJECT_RAIDTARGET8
						);

-- Object type constants
COMBATLOG_FILTER_ME			= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PLAYER
						);

COMBATLOG_FILTER_MINE			= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_OBJECT
						);

COMBATLOG_FILTER_MY_PET			= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_PET
						);
COMBATLOG_FILTER_FRIENDLY_UNITS		= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_CONTROL_NPC,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						);

COMBATLOG_FILTER_HOSTILE_PLAYERS	= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_HOSTILE,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						);

COMBATLOG_FILTER_HOSTILE_UNITS		= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_HOSTILE,
						COMBATLOG_OBJECT_CONTROL_NPC,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						);

COMBATLOG_FILTER_NEUTRAL_UNITS		= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_NEUTRAL,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_CONTROL_NPC,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						);
COMBATLOG_FILTER_UNKNOWN_UNITS		= COMBATLOG_OBJECT_NONE;
COMBATLOG_FILTER_EVERYTHING =	0xFFFFFFFF;

--
-- Calendar
--
CALENDAR_FIRST_WEEKDAY			= 1;		-- 1=SUN 2=MON 3=TUE 4=WED 5=THU 6=FRI 7=SAT

--
-- Difficulty
--
QuestDifficultyColors = {
	["impossible"]		= { r = 1.00, g = 0.10, b = 0.10, font = "QuestDifficulty_Impossible" };
	["verydifficult"]	= { r = 1.00, g = 0.50, b = 0.25, font = "QuestDifficulty_VeryDifficult" };
	["difficult"]		= { r = 1.00, g = 0.82, b = 0.00, font = "QuestDifficulty_Difficult" };
	["standard"]		= { r = 0.25, g = 0.75, b = 0.25, font = "QuestDifficulty_Standard" };
	["trivial"]			= { r = 0.50, g = 0.50, b = 0.50, font = "QuestDifficulty_Trivial" };
	["header"]			= { r = 0.70, g = 0.70, b = 0.70, font = "QuestDifficulty_Header" };
	["disabled"]		= { r = 0.498, g = 0.498, b = 0.498, font = "QuestDifficulty_Impossible" };
};

QuestDifficultyHighlightColors = {
	["impossible"]		= { r = 1.00, g = 0.40, b = 0.40, font = "QuestDifficulty_Impossible" };
	["verydifficult"]	= { r = 1.00, g = 0.75, b = 0.44, font = "QuestDifficulty_VeryDifficult" };
	["difficult"]		= { r = 1.00, g = 1.00, b = 0.10, font = "QuestDifficulty_Difficult" };
	["standard"]		= { r = 0.43, g = 0.93, b = 0.43, font = "QuestDifficulty_Standard" };
	["trivial"]			= { r = 0.70, g = 0.70, b = 0.70,  font = "QuestDifficulty_Trivial" };
	["header"]			= { r = 1.00, g = 1.00, b = 1.00, font = "QuestDifficulty_Header" };
	["disabled"]		= { r = 0.60, g = 0.60, b = 0.60, font = "QuestDifficulty_Impossible" };
};

--
-- WorldMap
--
NUM_WORLDMAP_PATCH_TILES = 6;

--
-- Totems
--

MAX_TOTEMS = 4;

FIRE_TOTEM_SLOT = 1;
EARTH_TOTEM_SLOT = 2;
WATER_TOTEM_SLOT = 3;
AIR_TOTEM_SLOT = 4;

STANDARD_TOTEM_PRIORITIES = {1, 2, 3, 4};

SHAMAN_TOTEM_PRIORITIES = {
	EARTH_TOTEM_SLOT,
	FIRE_TOTEM_SLOT,
	WATER_TOTEM_SLOT,
	AIR_TOTEM_SLOT,
};

TOTEM_MULTI_CAST_SUMMON_SPELLS = {
	66842,
	66843,
	66844,
};

TOTEM_MULTI_CAST_RECALL_SPELLS = {
	36936,
};

--
-- GM Ticket
--

GMTICKET_QUEUE_STATUS_ENABLED = 1;
GMTICKET_QUEUE_STATUS_DISABLED = -1;

GMTICKET_ASSIGNEDTOGM_STATUS_NOT_ASSIGNED = 0;	-- ticket is not currently assigned to a gm
GMTICKET_ASSIGNEDTOGM_STATUS_ASSIGNED = 1;		-- ticket is assigned to a normal gm
GMTICKET_ASSIGNEDTOGM_STATUS_ESCALATED = 2;		-- ticket is in the escalation queue

GMTICKET_OPENEDBYGM_STATUS_NOT_OPENED = 0;		-- ticket has never been opened by a gm
GMTICKET_OPENEDBYGM_STATUS_OPENED = 1;			-- ticket has been opened by a gm


-- indicies for adding lights ModelFFX:Add*Light
LIGHT_LIVE  = 0;
LIGHT_GHOST = 1;

-- general constant translation table
STATIC_CONSTANTS = {}
RegisterStaticConstants(STATIC_CONSTANTS);

-- textures for quest item overlays
TEXTURE_ITEM_QUEST_BANG = "Interface\\ContainerFrame\\UI-Icon-QuestBang";
TEXTURE_ITEM_QUEST_BORDER = "Interface\\ContainerFrame\\UI-Icon-QuestBorder";

-- Friends
SHOW_SEARCH_BAR_NUM_FRIENDS = 12;

-- Search box
MIN_CHARACTER_SEARCH = 3;

-- Panel default size
PANEL_DEFAULT_WIDTH = 338;
PANEL_DEFAULT_HEIGHT = 424;

--Inline role icons
INLINE_TANK_ICON = CreateAtlasMarkup(GetMicroIconForRole("TANK"), 16, 16);
INLINE_HEALER_ICON = CreateAtlasMarkup(GetMicroIconForRole("HEALER"), 16, 16);
INLINE_DAMAGER_ICON = CreateAtlasMarkup(GetMicroIconForRole("DAMAGER"), 16, 16);

-- Guild
MAX_GUILDBANK_TABS = 8;
MAX_BUY_GUILDBANK_TABS = 6;

EXP_DEFAULT_WIDTH = 1024;

-- Date stuff
CALENDAR_WEEKDAY_NAMES = {
	WEEKDAY_SUNDAY,
	WEEKDAY_MONDAY,
	WEEKDAY_TUESDAY,
	WEEKDAY_WEDNESDAY,
	WEEKDAY_THURSDAY,
	WEEKDAY_FRIDAY,
	WEEKDAY_SATURDAY,
};

-- month names show up differently for full date displays in some languages
CALENDAR_FULLDATE_MONTH_NAMES = {
	FULLDATE_MONTH_JANUARY,
	FULLDATE_MONTH_FEBRUARY,
	FULLDATE_MONTH_MARCH,
	FULLDATE_MONTH_APRIL,
	FULLDATE_MONTH_MAY,
	FULLDATE_MONTH_JUNE,
	FULLDATE_MONTH_JULY,
	FULLDATE_MONTH_AUGUST,
	FULLDATE_MONTH_SEPTEMBER,
	FULLDATE_MONTH_OCTOBER,
	FULLDATE_MONTH_NOVEMBER,
	FULLDATE_MONTH_DECEMBER,
};


-- Forms.
DRUID_CAT_FORM = 1;
DRUID_TREE_FORM = 2;
DRUID_TRAVEL_FORM = 3;
DRUID_ACQUATIC_FORM = 4;
DRUID_BEAR_FORM = 5;
SHAMAN_GHOST_WOLF_FORM = 16;
DRUID_FLIGHT_FORM = 27;
PRIEST_SHADOWFORM = 28;
DRUID_MOONKIN_FORM_1 = 31;
DRUID_MOONKIN_FORM_2 = 35;
ROGUE_STEALTH = 30;

ANIMAL_FORMS = {
	[DRUID_CAT_FORM] = {actorTag = "druid-cat-form"};
	[DRUID_TREE_FORM] = {actorTag = "animal-form"};
	[DRUID_TRAVEL_FORM] = {actorTag = "druid-travel-form"};
	[DRUID_ACQUATIC_FORM] = {actorTag = "druid-acquatic-form"};
	[DRUID_BEAR_FORM] = {actorTag = "druid-bear-form"};
	[SHAMAN_GHOST_WOLF_FORM] = {actorTag = "animal-form"};
	[DRUID_FLIGHT_FORM] = {actorTag = "druid-flight-form"};
	[DRUID_MOONKIN_FORM_1] = {actorTag = "druid-moonkin-form"};
	[DRUID_MOONKIN_FORM_2] = {actorTag = "druid-moonkin-form"};
};

-- PVP Global Lua Constants
CONQUEST_CURRENCY = 390;
HONOR_CURRENCY = 392;
JUSTICE_CURRENCY = 395;
VALOR_CURRENCY = 396;

-- Looking for Guild Parameters
LFGUILD_PARAM_QUESTS 	= 1;
LFGUILD_PARAM_DUNGEONS	= 2;
LFGUILD_PARAM_RAIDS		= 3;
LFGUILD_PARAM_PVP		= 4;
LFGUILD_PARAM_RP		= 5;
LFGUILD_PARAM_WEEKDAYS	= 6;
LFGUILD_PARAM_WEEKENDS	= 7;
LFGUILD_PARAM_TANK		= 8;
LFGUILD_PARAM_HEALER	= 9;
LFGUILD_PARAM_DAMAGE	= 10;
LFGUILD_PARAM_ANY_LEVEL	= 11;
LFGUILD_PARAM_MAX_LEVEL	= 12;
LFGUILD_PARAM_LOOKING	= 13;

-- Instance
INSTANCE_TYPE_DUNGEON = 1;
INSTANCE_TYPE_RAID = 2;
INSTANCE_TYPE_BG = 3;
INSTANCE_TYPE_ARENA = 4;

DEFAULT_READY_CHECK_STAY_TIME = 10;


PET_TYPE_SUFFIX = {
[1] = "Humanoid",
[2] = "Dragon",
[3] = "Flying",
[4] = "Undead",
[5] = "Critter",
[6] = "Magical",
[7] = "Elemental",
[8] = "Beast",
[9] = "Water",
[10] = "Mechanical",
};

PET_BATTLE_PET_TYPE_PASSIVES = {
	238,	--Humanoid - Recovery
	245,	--Dragon - Execute
	239,	--Flying - Swiftness
	242,	--Undead - Damned
	236,	--Critter - Elusive
	243,	--Magical - Spellshield
	241,	--Elemental - Weather Immune
	237,	--Beast - Enrage
	240,	--Aquatic - Purity
	244,	--Mechanical - Failsafe
};

MAX_NUM_PET_BATTLE_ATTACK_MODIFIERS = 2;

PET_BATTLE_STATE_ATTACK = 18;
PET_BATTLE_STATE_SPEED = 20;

PET_BATTLE_EVENT_ON_APPLY = 0;
PET_BATTLE_EVENT_ON_DAMAGE_TAKEN = 1;
PET_BATTLE_EVENT_ON_DAMAGE_DEALT = 2;
PET_BATTLE_EVENT_ON_HEAL_TAKEN = 3;
PET_BATTLE_EVENT_ON_HEAL_DEALT = 4;
PET_BATTLE_EVENT_ON_AURA_REMOVED = 5;
PET_BATTLE_EVENT_ON_ROUND_START = 6;
PET_BATTLE_EVENT_ON_ROUND_END = 7;
PET_BATTLE_EVENT_ON_TURN = 8;
PET_BATTLE_EVENT_ON_ABILITY = 9;
PET_BATTLE_EVENT_ON_SWAP_IN = 10;
PET_BATTLE_EVENT_ON_SWAP_OUT = 11;

PET_BATTLE_PAD_INDEX = 0;

-- Challenge Mode
CHALLENGE_MEDAL_NONE = 0;
CHALLENGE_MEDAL_BRONZE = 1;
CHALLENGE_MEDAL_SILVER = 2;
CHALLENGE_MEDAL_GOLD = 3;
CHALLENGE_MEDAL_PLAT = 4; --as of 7/2/2013 only used for endless proving grounds
NUM_CHALLENGE_MEDALS = 3;
CHALLENGE_MEDAL_TEXTURES = {
	[CHALLENGE_MEDAL_BRONZE] = "Interface\\Challenges\\challenges-bronze",
	[CHALLENGE_MEDAL_SILVER] = "Interface\\Challenges\\challenges-silver",
	[CHALLENGE_MEDAL_GOLD]   = "Interface\\Challenges\\challenges-gold",
	[CHALLENGE_MEDAL_PLAT]   = "Interface\\Challenges\\challenges-plat",
}
CHALLENGE_MEDAL_TEXTURES_SMALL = {
	[CHALLENGE_MEDAL_BRONZE] = "Interface\\Challenges\\challenges-bronze-sm",
	[CHALLENGE_MEDAL_SILVER] = "Interface\\Challenges\\challenges-silver-sm",
	[CHALLENGE_MEDAL_GOLD]   = "Interface\\Challenges\\challenges-gold-sm",
	[CHALLENGE_MEDAL_PLAT]   = "Interface\\Challenges\\challenges-plat-sm",
}

-- Player Reporting
PLAYER_REPORT_TYPE_SPAM = "spam";
PLAYER_REPORT_TYPE_LANGUAGE = "language";
PLAYER_REPORT_TYPE_ABUSE = "abuse";
PLAYER_REPORT_TYPE_BAD_PLAYER_NAME = "badplayername";
PLAYER_REPORT_TYPE_BAD_GUILD_NAME = "badguildname";
PLAYER_REPORT_TYPE_CHEATING = "cheater";
PLAYER_REPORT_TYPE_BAD_BATTLEPET_NAME = "badbattlepetname";
PLAYER_REPORT_TYPE_BAD_PET_NAME = "badpetname";

--Loot
BONUS_ROLL_REQUIRED_CURRENCY = 697;

-- Quest
QUEST_TYPE_DUNGEON = 81;
QUEST_TYPE_SCENARIO = 98;

MAX_QUESTS = 25;
MAX_OBJECTIVES = 20;
MAX_QUESTLOG_QUESTS = 25;

WORLD_QUESTS_TIME_CRITICAL_MINUTES = 15;
WORLD_QUESTS_TIME_LOW_MINUTES = 75;

WORLD_QUESTS_AVAILABLE_QUEST_ID = 43341;

-- LFG
LFG_CATEGORY_NAMES = {
	[LE_LFG_CATEGORY_LFD] = LOOKING_FOR_DUNGEON,
	[LE_LFG_CATEGORY_RF] = RAID_FINDER,
	[LE_LFG_CATEGORY_SCENARIO] = SCENARIOS,
	[LE_LFG_CATEGORY_LFR] = LOOKING_FOR_RAID,
	[LE_LFG_CATEGORY_FLEXRAID] = FLEX_RAID,
	[LE_LFG_CATEGORY_WORLDPVP] = WORLD_PVP,
	[LE_LFG_CATEGORY_BATTLEFIELD] = LFG_CATEGORY_BATTLEFIELD,
}

-- PVP
MAX_ARENA_TEAMS = 2;
MAX_WORLD_PVP_QUEUES = 2;
CONQUEST_SIZE_STRINGS = { RATED_SOLO_SHUFFLE_SIZE, RATED_BG_BLITZ_SIZE, ARENA_2V2, ARENA_3V3, BATTLEGROUND_10V10 };
CONQUEST_TYPE_STRINGS = { ARENA, BATTLEGROUNDS, ARENA, ARENA, BATTLEGROUNDS };
CONQUEST_SIZES = { 1, 1, 2, 3, 10 };
CONQUEST_BRACKET_INDEXES = { 7, 9, 1, 2, 4 }; -- 5v5 was removed

-- Chat
CHANNEL_INVITE_TIMEOUT = 60;

-- Scenarios
SCENARIO_FLAG_DEPRECATED1			= 0x00000001;
SCENARIO_FLAG_SUPRESS_STAGE_TEXT	= 0x00000002;
SCENARIO_FLAG_DEPRECATED2			= 0x00000004;
SCENARIO_FLAG_DEPRECATED3			= 0x00000008;

-- Lua Warning types
LUA_WARNING_TREAT_AS_ERROR = 0;

-- Quest Tags
QUEST_TAG_ATLAS = {
	["COMPLETED"] = "questlog-questtypeicon-quest",
	["COMPLETED_LEGENDARY"] = "questlog-questtypeicon-legendaryturnin",
	["DAILY"] = "questlog-questtypeicon-daily",
	["WEEKLY"] = "questlog-questtypeicon-weekly",
	["FAILED"] = "questlog-questtypeicon-questfailed",
	["STORY"] = "questlog-questtypeicon-story",
	["ALLIANCE"] = "questlog-questtypeicon-alliance",
	["HORDE"] = "questlog-questtypeicon-horde",
	["EXPIRING_SOON"] = "questlog-questtypeicon-expiringsoon",
	["EXPIRING"] = "questlog-questtypeicon-expiring",
	[Enum.QuestTag.Dungeon] = "questlog-questtypeicon-dungeon",
	[Enum.QuestTag.Scenario] = "questlog-questtypeicon-scenario",
	[Enum.QuestTag.Account] = "questlog-questtypeicon-account",
	[Enum.QuestTag.Legendary] = "questlog-questtypeicon-legendary",
	[Enum.QuestTag.Group] = "questlog-questtypeicon-group",
	[Enum.QuestTag.PvP] = "questlog-questtypeicon-pvp",
	[Enum.QuestTag.Heroic] = "questlog-questtypeicon-heroic",
	-- same texture for all raids
	[Enum.QuestTag.Raid] = "questlog-questtypeicon-raid",
	[Enum.QuestTag.Raid10] = "questlog-questtypeicon-raid",
	[Enum.QuestTag.Raid25] = "questlog-questtypeicon-raid",
};

WORLD_QUEST_TYPE_ATLAS = {
	[Enum.QuestTagType.Dungeon] = "questlog-questtypeicon-dungeon",
	[Enum.QuestTagType.Raid] = "questlog-questtypeicon-raid",
};

-- MATCH CONDITIONS
MATCH_CONDITION_WRONG_ACHIEVEMENT = 34;
MATCH_CONDITION_SUCCESS = 57;

-- FOR ABBREVIATING LARGE NUMBERS
FIRST_NUMBER_CAP_VALUE = 1000;

-- GARRISONS
GARRISON_HIGH_THREAT_VALUE = 300;
LOOT_SOURCE_GARRISON_CACHE = 10;
WOW_TOKEN_ITEM_ID = 122284;

-- TRANSMOG
ENCHANT_EMPTY_SLOT_FILEDATAID = 134941;
WARDROBE_TOOLTIP_CYCLE_ARROW_ICON = "|TInterface\\Transmogrify\\transmog-tooltip-arrow:12:11:-1:-1|t";
WARDROBE_TOOLTIP_CYCLE_SPACER_ICON = "|TInterface\\Common\\spacer:12:11:-1:-1|t";
WARDROBE_CYCLE_KEY = "TAB";
WARDROBE_PREV_VISUAL_KEY = "LEFT";
WARDROBE_NEXT_VISUAL_KEY = "RIGHT";
WARDROBE_UP_VISUAL_KEY = "UP";
WARDROBE_DOWN_VISUAL_KEY = "DOWN";

TRANSMOG_INVALID_CODES = {
	"NO_ITEM",
	"NOT_SOULBOUND",
	"LEGENDARY",
	"ITEM_TYPE",
	"DESTINATION",
	"MISMATCH",
	"",		-- same item
	"",		-- invalid source
	"",		-- invalid source quality
	"CANNOT_USE",
	"SLOT_FOR_RACE",
	"",		-- no illusion
	"SLOT_FOR_FORM",
}

TRANSMOG_SOURCE_BOSS_DROP = 1;

FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE = Enum.TransmogCollectionType.Wand;
LAST_TRANSMOG_COLLECTION_WEAPON_TYPE = Enum.TransmogCollectionTypeMeta.NumValues - 1;
NO_TRANSMOG_VISUAL_ID = 0;
REMOVE_TRANSMOG_ID = 0;

-- ITEMSUBCLASSTYPES
ITEMSUBCLASSTYPES = {
	["DAGGER"] = { classID = 2, subClassID = 15},
}

-- MINIMAP
TYPEID_DUNGEON = 1;
TYPEID_RANDOM_DUNGEON = 6;

LFG_SUBTYPEID_DUNGEON = 1;
LFG_SUBTYPEID_HEROIC = 2;
LFG_SUBTYPEID_RAID = 3;
LFG_SUBTYPEID_SCENARIO = 4;
LFG_SUBTYPEID_FLEXRAID = 5;
LFG_SUBTYPEID_WORLDPVP = 6;

-- TEXTURES
QUESTION_MARK_ICON = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK.BLP";


UPPER_LEFT_VERTEX = 1;
LOWER_LEFT_VERTEX = 2;
UPPER_RIGHT_VERTEX = 3;
LOWER_RIGHT_VERTEX = 4;

-- TUTORIALS
HELPTIP_HEIGHT_PADDING = 29;

-- RELIC TALENTS
RELIC_TALENT_TYPE_LIGHT = 1;
RELIC_TALENT_TYPE_VOID = 2;
RELIC_TALENT_TYPE_NEUTRAL = 3;

RELIC_TALENT_STYLE_CLOSED = 1;
RELIC_TALENT_STYLE_UPCOMING = 2;
RELIC_TALENT_STYLE_AVAILABLE = 3;
RELIC_TALENT_STYLE_CHOSEN = 4;

RELIC_TALENT_LINK_TYPE_LIGHT = 1;
RELIC_TALENT_LINK_TYPE_VOID = 2;

RELIC_TALENT_LINK_STYLE_DISABLED = 1;
RELIC_TALENT_LINK_STYLE_POTENTIAL = 2;
RELIC_TALENT_LINK_STYLE_ACTIVE = 3;
RELIC_TALENT_LINK_STYLE_UPCOMING = 4;
RELIC_TALENT_LINK_STYLE_AVAILABLE = 5;

-- TODO: Need to be able to expose this from client...
Enum.ChatChannelType = {
	None = 0,
	Custom = 1,
	Private_Party = 2,
	Public_Party = 3,
	Communities = 4,
};

TOOLTIP_INDENT_OFFSET = 10;
