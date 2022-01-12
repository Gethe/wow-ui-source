-- BIG PROBLEM HERE. NOT SAVING REFS
--
-- New constants should be added to this file and other constants
-- deprecated and moved to this file.
--

--
-- Expansion Info
--
MAX_PLAYER_LEVEL_TABLE = {};
MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_CLASSIC] = 60;
MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_BURNING_CRUSADE] = 70;
--MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = 80;
--MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_CATACLYSM] = 85;
--MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_MISTS_OF_PANDARIA] = 90;
--MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_WARLORDS_OF_DRAENOR] = 100;
--MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEGION] = 110;
--MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_BATTLE_FOR_AZEROTH] = 120;
--MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_9_0] = 120;
--MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_10_0] = 120;
--MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_11_0] = 120;

NPE_TUTORIAL_COMPLETE_LEVEL = 10;


AREA_NAME_FONT_COLOR = CreateColor(1.0, 0.9294, 0.7607);
AREA_DESCRIPTION_FONT_COLOR = HIGHLIGHT_FONT_COLOR;
INVASION_FONT_COLOR = CreateColor(0.78, 1, 0);
INVASION_DESCRIPTION_FONT_COLOR = CreateColor(1, 0.973, 0.035);

FACTION_BAR_COLORS = {
	[1] = {r = 0.8, g = 0.3, b = 0.22},
	[2] = {r = 0.8, g = 0.3, b = 0.22},
	[3] = {r = 0.75, g = 0.27, b = 0},
	[4] = {r = 0.9, g = 0.7, b = 0},
	[5] = {r = 0, g = 0.6, b = 0.1},
	[6] = {r = 0, g = 0.6, b = 0.1},
	[7] = {r = 0, g = 0.6, b = 0.1},
	[8] = {r = 0, g = 0.6, b = 0.1},
};

WORLD_QUEST_ICONS_BY_PROFESSION = {
	[129] = "worldquest-icon-firstaid",
	[164] = "worldquest-icon-blacksmithing",
	[165] = "worldquest-icon-leatherworking",
	[171] = "worldquest-icon-alchemy",
	[182] = "worldquest-icon-herbalism",
	[186] = "worldquest-icon-mining",
	[202] = "worldquest-icon-engineering",
	[333] = "worldquest-icon-enchanting",
	[755] = "worldquest-icon-jewelcrafting",
	[773] = "worldquest-icon-inscription",
	[794] = "worldquest-icon-archaeology",
	[356] = "worldquest-icon-fishing",
	[185] = "worldquest-icon-cooking",
	[197] = "worldquest-icon-tailoring",
	[393] = "worldquest-icon-skinning",
};

CHAT_FONT_HEIGHTS = {
	[1] = 12,
	[2] = 14,
	[3] = 16,
	[4] = 18
};

MATERIAL_TEXT_COLOR_TABLE = {
	["Default"] = {0.18, 0.12, 0.06},
	["Stone"] = {1.0, 1.0, 1.0},
	["Parchment"] = {0.18, 0.12, 0.06},
	["Marble"] = {0, 0, 0},
	["Silver"] = {0.12, 0.12, 0.12},
	["Bronze"] = {0.18, 0.12, 0.06},
	["ParchmentLarge"] = {.141, 0, 0}
};
MATERIAL_TITLETEXT_COLOR_TABLE = {
	["Default"] = {0, 0, 0},
	["Stone"] = {0.93, 0.82, 0},
	["Parchment"] = {0, 0, 0},
	["Marble"] = {0.93, 0.82, 0},
	["Silver"] = {0.93, 0.82, 0},
	["Bronze"] = {0.93, 0.82, 0},
	["ParchmentLarge"] = {.208, 0, 0}
};

FRIENDS_BNET_NAME_COLOR = CreateColor(0.510, 0.773, 1.0);
FRIENDS_BNET_BACKGROUND_COLOR = CreateColor(0, 0.694, 0.941, 0.05);
FRIENDS_WOW_NAME_COLOR = CreateColor(0.996, 0.882, 0.361);
FRIENDS_WOW_BACKGROUND_COLOR = CreateColor(1.0, 0.824, 0.0, 0.05);
FRIENDS_GRAY_COLOR = CreateColor(0.486, 0.518, 0.541);
FRIENDS_OFFLINE_BACKGROUND_COLOR = CreateColor(0.588, 0.588, 0.588, 0.05);
FRIENDS_BNET_NAME_COLOR_CODE = "|cff82c5ff";
FRIENDS_BROADCAST_TIME_COLOR_CODE = "|cff4381a8"
FRIENDS_WOW_NAME_COLOR_CODE = "|cfffde05c";
FRIENDS_OTHER_NAME_COLOR_CODE = "|cff7b8489";

HTML_START = "<html><body><p>";
HTML_START_CENTERED = "<html><body><p align=\"center\">";
HTML_END = "</p></body></html>";

--
-- Class
--
CLASS_SORT_ORDER = {
	"WARRIOR",
	--"DEATHKNIGHT",
	"PALADIN",
	--"MONK",
	"PRIEST",
	"SHAMAN",
	"DRUID",
	"ROGUE",
	"MAGE",
	"WARLOCK",
	"HUNTER",
	--"DEMONHUNTER",
};
MAX_CLASSES = #CLASS_SORT_ORDER;

LOCALIZED_CLASS_NAMES_MALE = {};
LOCALIZED_CLASS_NAMES_FEMALE = {};
FillLocalizedClassList(LOCALIZED_CLASS_NAMES_MALE, false);
FillLocalizedClassList(LOCALIZED_CLASS_NAMES_FEMALE, true);

--
-- Spell
--
HUNTER_DISMISS_PET = 2641;
WARLOCK_METAMORPHOSIS = 103958;
WARLOCK_SOULBURN = 117198;
WARLOCK_GREEN_FIRE = 101508;
BATTLEGROUND_ENLISTMENT_BONUS = 241260;

SCHOOL_MASK_NONE	= 0x00;
SCHOOL_MASK_PHYSICAL	= 0x01;
SCHOOL_MASK_HOLY	= 0x02;
SCHOOL_MASK_FIRE	= 0x04;
SCHOOL_MASK_NATURE	= 0x08;
SCHOOL_MASK_FROST	= 0x10;
SCHOOL_MASK_SHADOW	= 0x20;
SCHOOL_MASK_ARCANE	= 0x40;

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

--
-- Talent
--
SHOW_TALENT_LEVEL = 10;
SHOW_PVP_TALENT_LEVEL = 20;
SHOW_PVP_LEVEL = 10;
SHOW_LFD_LEVEL = 15;
SHOW_MASTERY_LEVEL = 78;
CLASS_TALENT_LEVELS = {
	["DEFAULT"]		= { 15, 30, 45, 60, 75, 90, 100 };
	["DEATHKNIGHT"]	= { 56, 57, 58, 60, 75, 90, 100 };
	["DEMONHUNTER"]	= { 99, 100, 102, 104, 106, 108, 110 };
}

SPECIALIZATION_TAB = 1;
TALENTS_TAB = 2;
NUM_TALENT_FRAME_TABS = 2;

--
-- Specs
--
SHOW_SPEC_LEVEL = 10
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

MAX_TRACKED_ACHIEVEMENTS = 10;

-- Criteria Types
CRITERIA_TYPE_ACHIEVEMENT = 8;

-- Achievement Flags
ACHIEVEMENT_FLAGS_HAS_PROGRESS_BAR 		= 0x00000080;
ACHIEVEMENT_FLAGS_GUILD					= 0x00004000;
ACHIEVEMENT_FLAGS_SHOW_GUILD_MEMBERS	= 0x00008000;
ACHIEVEMENT_FLAGS_SHOW_CRITERIA_MEMBERS = 0x00010000;
ACHIEVEMENT_FLAGS_ACCOUNT 				= 0x00020000;
NUM_ACHIEVEMENT_FLAGS			= 3;

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
	[LE_ITEM_QUALITY_COMMON] = {r=0.65882,g=0.65882,b=0.65882},
	[LE_ITEM_QUALITY_UNCOMMON] = {r=0.08235, g=0.70196, b=0},
	[LE_ITEM_QUALITY_RARE] = {r=0, g=0.56863, b=0.94902},
	[LE_ITEM_QUALITY_EPIC] = {r=0.78431, g=0.27059, b=0.98039},
	[LE_ITEM_QUALITY_LEGENDARY] = {r=1, g=0.50196, b=0},
	[LE_ITEM_QUALITY_ARTIFACT] = {r=0.90196, g=0.8, b=0.50196},
	[LE_ITEM_QUALITY_HEIRLOOM] = {r=0, g=0.8, b=1},
	[LE_ITEM_QUALITY_WOW_TOKEN] = {r=0, g=0.8, b=1},
}

NEW_ITEM_ATLAS_BY_QUALITY = {
	[LE_ITEM_QUALITY_POOR] = "bags-glow-white",
	[LE_ITEM_QUALITY_COMMON] = "bags-glow-white",
	[LE_ITEM_QUALITY_UNCOMMON] = "bags-glow-green",
	[LE_ITEM_QUALITY_RARE] = "bags-glow-blue",
	[LE_ITEM_QUALITY_EPIC] = "bags-glow-purple",
	[LE_ITEM_QUALITY_LEGENDARY] = "bags-glow-orange",
	[LE_ITEM_QUALITY_ARTIFACT] = "bags-glow-artifact",
	[LE_ITEM_QUALITY_HEIRLOOM] = "bags-glow-heirloom",
};

-- Loot
LOOT_BORDER_BY_QUALITY = {
	[LE_ITEM_QUALITY_UNCOMMON] = "loottoast-itemborder-green",
	[LE_ITEM_QUALITY_RARE] = "loottoast-itemborder-blue",
	[LE_ITEM_QUALITY_EPIC] = "loottoast-itemborder-purple",
	[LE_ITEM_QUALITY_LEGENDARY] = "loottoast-itemborder-orange",
	[LE_ITEM_QUALITY_HEIRLOOM] = "loottoast-itemborder-heirloom",
	[LE_ITEM_QUALITY_ARTIFACT] = "loottoast-itemborder-artifact",
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

INVSLOTS_EQUIPABLE_IN_COMBAT = {
[INVSLOT_MAINHAND] = true,
[INVSLOT_OFFHAND] = true,
[INVSLOT_RANGED] = true,
}

-- Container constants
ITEM_INVENTORY_BANK_BAG_OFFSET	= 4; -- Number of bags before the first bank bag
CONTAINER_BAG_OFFSET = 19; -- Used for PutItemInBag

BACKPACK_CONTAINER = 0;
BANK_CONTAINER = -1;
BANK_CONTAINER_INVENTORY_OFFSET = 39; -- Used for PickupInventoryItem
KEYRING_CONTAINER = -2;

NUM_BAG_SLOTS = 4;
NUM_BANKGENERIC_SLOTS = 28;
NUM_BANKBAGSLOTS = 7;

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

-- Event Types
CALENDAR_EVENTTYPE_RAID			= Enum.CalendarEventType.Raid;
CALENDAR_EVENTTYPE_DUNGEON		= Enum.CalendarEventType.Dungeon;
CALENDAR_EVENTTYPE_PVP			= Enum.CalendarEventType.Pvp;
CALENDAR_EVENTTYPE_MEETING		= Enum.CalendarEventType.Meeting;
CALENDAR_EVENTTYPE_OTHER		= Enum.CalendarEventType.Other;
CALENDAR_MAX_EVENTTYPE			= Enum.CalendarEventType.Other;

-- Invite Statuses
CALENDAR_INVITESTATUS_INVITED		= 1;
CALENDAR_INVITESTATUS_ACCEPTED		= 2;
CALENDAR_INVITESTATUS_DECLINED		= 3;
CALENDAR_INVITESTATUS_CONFIRMED		= 4;
CALENDAR_INVITESTATUS_OUT			= 5;
CALENDAR_INVITESTATUS_STANDBY		= 6;
CALENDAR_INVITESTATUS_SIGNEDUP		= 7;
CALENDAR_INVITESTATUS_NOT_SIGNEDUP	= 8;
CALENDAR_INVITESTATUS_TENTATIVE		= 9;
CALENDAR_MAX_INVITESTATUS			= CALENDAR_INVITESTATUS_TENTATIVE;

-- Invite Types
CALENDAR_INVITETYPE_NORMAL		= 1;
CALENDAR_INVITETYPE_SIGNUP		= 2;
CALENDAR_MAX_INVITETYPE			= CALENDAR_INVITETYPE_SIGNUP;

--
-- Difficulty
--
QuestDifficultyColors = {
	["impossible"]		= { r = 1.00, g = 0.10, b = 0.10, font = "QuestDifficulty_Impossible" };
	["verydifficult"]	= { r = 1.00, g = 0.50, b = 0.25, font = "QuestDifficulty_VeryDifficult" };
	["difficult"]		= { r = 1.00, g = 1.00, b = 0.00, font = "QuestDifficulty_Difficult" };
	["standard"]		= { r = 0.25, g = 0.75, b = 0.25, font = "QuestDifficulty_Standard" };
	["trivial"]			= { r = 0.50, g = 0.50, b = 0.50, font = "QuestDifficulty_Trivial" };
	["header"]			= { r = 0.70, g = 0.70, b = 0.70, font = "QuestDifficulty_Header" };
};

QuestDifficultyHighlightColors = {
	["impossible"]		= { r = 1.00, g = 0.40, b = 0.40, font = "QuestDifficulty_Impossible" };
	["verydifficult"]	= { r = 1.00, g = 0.75, b = 0.44, font = "QuestDifficulty_VeryDifficult" };
	["difficult"]		= { r = 1.00, g = 1.00, b = 0.10, font = "QuestDifficulty_Difficult" };
	["standard"]		= { r = 0.43, g = 0.93, b = 0.43, font = "QuestDifficulty_Standard" };
	["trivial"]			= { r = 0.70, g = 0.70, b = 0.70,  font = "QuestDifficulty_Trivial" };
	["header"]			= { r = 1.00, g = 1.00, b = 1.00, font = "QuestDifficulty_Header" };
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

-- faction
PLAYER_FACTION_GROUP = { [0] = "Horde", [1] = "Alliance", Horde = 0, Alliance = 1 };
PLAYER_FACTION_COLORS = { [0] = CreateColor(0.90, 0.05, 0.07), [1] = CreateColor(0.29, 0.33, 0.91) }

-- Panel default size
PANEL_DEFAULT_WIDTH = 338;
PANEL_DEFAULT_HEIGHT = 424;

--Inline role icons
INLINE_TANK_ICON = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:0:19:22:41|t";
INLINE_HEALER_ICON = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:20:39:1:20|t";
INLINE_DAMAGER_ICON = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:20:39:22:41|t"

-- Guild
MAX_GUILDBANK_TABS = 6;
MAX_BUY_GUILDBANK_TABS = 6;
MAX_GOLD_WITHDRAW = 1000;
MAX_GOLD_WITHDRAW_DIGITS = 9;

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


-- Druid Forms.
CAT_FORM = 1;
BEAR_FORM = 5;
MOONKIN_FORM = 31;

-- PVP Global Lua Constants
CONQUEST_CURRENCY = 390;
HONOR_CURRENCY = 392;
JUSTICE_CURRENCY = 395;
VALOR_CURRENCY = 396;
SHOW_CONQUEST_LEVEL = 70;

-- Honor Point texture file IDs. These files have some weird sizing, so they need som special handling.
HONOR_POINT_TEXTURES = { 136998, 137000 };

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
PLAYER_REPORT_TYPE_BAD_ARENA_TEAM_NAME = "badarenateamname";

--Loot
BONUS_ROLL_REQUIRED_CURRENCY = 697;

-- Quest
QUEST_TYPE_DUNGEON = 81;
QUEST_TYPE_SCENARIO = 98;

MAX_QUESTS = 25;
MAX_OBJECTIVES = 20;
MAX_QUESTLOG_QUESTS = 25;
MAX_WATCHABLE_QUESTS = 5;

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

-- Instance Difficulty
DIFFICULTY_DUNGEON_NORMAL = 1;
DIFFICULTY_DUNGEON_HEROIC = 2;
DIFFICULTY_RAID10_NORMAL = 3;
DIFFICULTY_RAID25_NORMAL = 4;
DIFFICULTY_RAID10_HEROIC = 5;
DIFFICULTY_RAID25_HEROIC = 6;
DIFFICULTY_RAID_LFR = 7;
DIFFICULTY_DUNGEON_CHALLENGE = 8;
DIFFICULTY_RAID40 = 9;
DIFFICULTY_PRIMARYRAID_NORMAL = 14;
DIFFICULTY_PRIMARYRAID_HEROIC = 15;
DIFFICULTY_PRIMARYRAID_MYTHIC = 16;
DIFFICULTY_PRIMARYRAID_LFR = 17;

-- PVP
MAX_ARENA_TEAMS = 2;
MAX_WORLD_PVP_QUEUES = 2;

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
QUEST_ICONS_FILE = "Interface\\QuestFrame\\QuestTypeIcons";
QUEST_ICONS_FILE_WIDTH = 128;
QUEST_ICONS_FILE_HEIGHT = 64;

QUEST_TAG_TCOORDS = {
	["COMPLETED"] = { 0.140625, 0.28125, 0, 0.28125 },
	["DAILY"] = { 0.28125, 0.421875, 0, 0.28125 },
	["WEEKLY"] = { 0.28125, 0.421875, 0.5625, 0.84375 },
	["FAILED"] = { 0.84375, 0.984375, 0.28125, 0.5625 },
	["STORY"] = { 0.703125, 0.84375, 0.28125, 0.5625 },
	["ALLIANCE"] = { 0.421875, 0.5625, 0.28125, 0.5625 },
	["HORDE"] = { 0.5625, 0.703125, 0.28125, 0.5625 },
	[Enum.QuestTag.Dungeon] = { 0.421875, 0.5625, 0, 0.28125 },
	[Enum.QuestTag.Scenario] = { 0.5625, 0.703125, 0, 0.28125 },
	[Enum.QuestTag.Account] = { 0.84375, 0.984375, 0, 0.28125 },
	[Enum.QuestTag.Legendary] = { 0, 0.140625, 0.28125, 0.5625 },
	[Enum.QuestTag.Group] = { 0.140625, 0.28125, 0.28125, 0.5625 },
	[Enum.QuestTag.PvP] = { 0.28125, 0.421875, 0.28125, 0.5625 },
	[Enum.QuestTag.Heroic] = { 0, 0.140625, 0.5625, 0.84375 },
	-- same texture for all raids
	[Enum.QuestTag.Raid] = { 0.703125, 0.84375, 0, 0.28125 },
	[Enum.QuestTag.Raid10] = { 0.703125, 0.84375, 0, 0.28125 },
	[Enum.QuestTag.Raid25] = { 0.703125, 0.84375, 0, 0.28125 },
};

WORLD_QUEST_TYPE_TCOORDS = {
	[LE_QUEST_TAG_TYPE_DUNGEON] = { 0.421875, 0.5625, 0, 0.28125 },
	[LE_QUEST_TAG_TYPE_RAID] = { 0.703125, 0.84375, 0, 0.28125 },
};

-- MATCH CONDITIONS
MATCH_CONDITION_WRONG_ACHIEVEMENT = 34;
MATCH_CONDITION_SUCCESS = 57;

-- FOR ABBREVIATING LARGE NUMBERS
FIRST_NUMBER_CAP_VALUE = 1000;

-- GARRISONS
GARRISON_HIGH_THREAT_VALUE = 300;

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

NO_TRANSMOG_SOURCE_ID = 0;

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

-- SPECTATOR MODE
MAX_SPECTATED_PER_TEAM = 15;

-- "Generic" GamePad button labels
KEY_PADDUP				= "GamePad Up";
KEY_PADDRIGHT			= "GamePad Right";
KEY_PADDDOWN			= "GamePad Down";
KEY_PADDLEFT			= "GamePad Left";
KEY_PAD1				= "GamePad 1";
KEY_PAD2				= "GamePad 2";
KEY_PAD3				= "GamePad 3";
KEY_PAD4				= "GamePad 4";
KEY_PAD5				= "GamePad 5";
KEY_PAD6				= "GamePad 6";
KEY_PADLSTICK			= "GamePad L Stick In";
KEY_PADRSTICK			= "GamePad R Stick In";
KEY_PADLSHOULDER		= "GamePad L Shoulder";
KEY_PADRSHOULDER		= "GamePad R Shoulder";
KEY_PADLTRIGGER			= "GamePad L Trigger";
KEY_PADRTRIGGER			= "GamePad R Trigger";
KEY_PADLSTICKUP			= "GamePad L Stick Up";
KEY_PADLSTICKRIGHT		= "GamePad L Stick Right";
KEY_PADLSTICKDOWN		= "GamePad L Stick Down";
KEY_PADLSTICKLEFT		= "GamePad L Stick Left";
KEY_PADRSTICKUP			= "GamePad R Stick Up";
KEY_PADRSTICKRIGHT		= "GamePad R Stick Right";
KEY_PADRSTICKDOWN		= "GamePad R Stick Down";
KEY_PADRSTICKLEFT		= "GamePad R Stick Left";
KEY_PADPADDLE1			= "GamePad Paddle 1";
KEY_PADPADDLE2			= "GamePad Paddle 2";
KEY_PADPADDLE3			= "GamePad Paddle 3";
KEY_PADPADDLE4			= "GamePad Paddle 4";
KEY_PADFORWARD			= "GamePad Forward";
KEY_PADBACK				= "GamePad Back";
KEY_PADSYSTEM			= "GamePad System";
KEY_PADSOCIAL			= "GamePad Social";
-- "Letters" label style specializations
KEY_PAD1_LTR			= "GamePad A";
KEY_PAD2_LTR			= "GamePad B";
KEY_PAD3_LTR			= "GamePad X";
KEY_PAD4_LTR			= "GamePad Y";
KEY_PADLSHOULDER_LTR	= "GamePad L Bumper";
KEY_PADRSHOULDER_LTR	= "GamePad R Bumper";
KEY_PADFORWARD_LTR		= "GamePad Start";
KEY_PADBACK_LTR			= "GamePad Back";
-- "Reverse" label style specializations
KEY_PAD1_REV			= "GamePad B";
KEY_PAD2_REV			= "GamePad A";
KEY_PAD3_REV			= "GamePad Y";
KEY_PAD4_REV			= "GamePad X";
KEY_PADLSHOULDER_REV	= "GamePad L";
KEY_PADRSHOULDER_REV	= "GamePad R";
KEY_PADLTRIGGER_REV		= "GamePad ZL";
KEY_PADRTRIGGER_REV		= "GamePad ZR";
KEY_PADFORWARD_REV		= "GamePad +";
KEY_PADBACK_REV			= "GamePad -";
-- "Shapes" label style specializations
KEY_PAD1_SHP			= "GamePad X";
KEY_PAD2_SHP			= "GamePad O";
KEY_PAD3_SHP			= "GamePad Square";
KEY_PAD4_SHP			= "GamePad Triangle";
KEY_PAD5_SHP			= "GamePad Mute";
KEY_PADLSTICK_SHP		= "GamePad L3";
KEY_PADRSTICK_SHP		= "GamePad R3";
KEY_PADLSHOULDER_SHP	= "GamePad L1";
KEY_PADRSHOULDER_SHP	= "GamePad R1";
KEY_PADLTRIGGER_SHP		= "GamePad L2";
KEY_PADRTRIGGER_SHP		= "GamePad R2";
KEY_PADFORWARD_SHP		= "GamePad Options";
KEY_PADBACK_SHP			= "GamePad TouchPad";
KEY_PADSOCIAL_SHP		= "GamePad Share";

-- "Generic" GamePad abbreviated button labels
KEY_ABBR_PADDUP				= "u";
KEY_ABBR_PADDRIGHT			= "r";
KEY_ABBR_PADDDOWN			= "d";
KEY_ABBR_PADDLEFT			= "l";
KEY_ABBR_PAD1				= "1";
KEY_ABBR_PAD2				= "2";
KEY_ABBR_PAD3				= "3";
KEY_ABBR_PAD4				= "4";
KEY_ABBR_PAD5				= "5";
KEY_ABBR_PAD6				= "6";
KEY_ABBR_PADLSTICK			= "Li";
KEY_ABBR_PADRSTICK			= "Ri";
KEY_ABBR_PADLSHOULDER		= "Ls";
KEY_ABBR_PADRSHOULDER		= "Rs";
KEY_ABBR_PADLTRIGGER		= "Lt";
KEY_ABBR_PADRTRIGGER		= "Rt";
KEY_ABBR_PADLSTICKUP		= "Lu";
KEY_ABBR_PADLSTICKRIGHT		= "Lr";
KEY_ABBR_PADLSTICKDOWN		= "Ld";
KEY_ABBR_PADLSTICKLEFT		= "Ll";
KEY_ABBR_PADRSTICKUP		= "Ru";
KEY_ABBR_PADRSTICKRIGHT		= "Rr";
KEY_ABBR_PADRSTICKDOWN		= "Rd";
KEY_ABBR_PADRSTICKLEFT		= "Rl";
KEY_ABBR_PADPADDLE1			= "p1";
KEY_ABBR_PADPADDLE2			= "p2";
KEY_ABBR_PADPADDLE3			= "p3";
KEY_ABBR_PADPADDLE4			= "p4";
KEY_ABBR_PADFORWARD			= "Fw";
KEY_ABBR_PADBACK			= "Bk";
KEY_ABBR_PADSYSTEM			= "Sy";
KEY_ABBR_PADSOCIAL			= "So";
-- "Letters" abbreviated label style specializations
KEY_ABBR_PAD1_LTR			= "A";
KEY_ABBR_PAD2_LTR			= "B";
KEY_ABBR_PAD3_LTR			= "X";
KEY_ABBR_PAD4_LTR			= "Y";
KEY_ABBR_PADLSHOULDER_LTR	= "LB";
KEY_ABBR_PADRSHOULDER_LTR	= "RB";
KEY_ABBR_PADFORWARD_LTR		= "St";
KEY_ABBR_PADBACK_LTR		= "Bk";
-- "Reverse" abbreviated label style specializations
KEY_ABBR_PAD1_REV			= "B";
KEY_ABBR_PAD2_REV			= "A";
KEY_ABBR_PAD3_REV			= "Y";
KEY_ABBR_PAD4_REV			= "X";
KEY_ABBR_PADLSHOULDER_REV	= "L";
KEY_ABBR_PADRSHOULDER_REV	= "R";
KEY_ABBR_PADLTRIGGER_REV	= "ZL";
KEY_ABBR_PADRTRIGGER_REV	= "ZR";
KEY_ABBR_PADFORWARD_REV		= "+";
KEY_ABBR_PADBACK_REV		= "-";
-- "Shapes" abbreviated label style specializations
KEY_ABBR_PAD1_SHP			= "X";
KEY_ABBR_PAD2_SHP			= "O";
KEY_ABBR_PAD3_SHP			= "S";
KEY_ABBR_PAD4_SHP			= "T";
KEY_ABBR_PADLSTICK_SHP		= "L3";
KEY_ABBR_PADRSTICK_SHP		= "R3";
KEY_ABBR_PADLSHOULDER_SHP	= "L1";
KEY_ABBR_PADRSHOULDER_SHP	= "R1";
KEY_ABBR_PADLTRIGGER_SHP	= "L2";
KEY_ABBR_PADRTRIGGER_SHP	= "R2";
KEY_ABBR_PADFORWARD_SHP		= "Op";
KEY_ABBR_PADBACK_SHP		= "Tp";
KEY_ABBR_PADSOCIAL_SHP		= "Sh";

WOW_PROJECT_MAINLINE = 1;
WOW_PROJECT_CLASSIC = 2;
WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5;
WOW_PROJECT_ID = WOW_PROJECT_BURNING_CRUSADE_CLASSIC;