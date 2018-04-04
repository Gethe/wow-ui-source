CHARACTER_FACING_INCREMENT = 2;
MAX_RACES = 18;
MAX_CLASSES_PER_RACE = 12;
MAX_DISPLAYED_CLASSES_PER_RACE = 12;

NUM_CHAR_CUSTOMIZATIONS = 9;
MIN_CHAR_NAME_LENGTH = 2;
CHARACTER_CREATE_ROTATION_START_X = nil;
CHARACTER_CREATE_INITIAL_FACING = nil;
NUM_PREVIEW_FRAMES = 14;
WORGEN_RACE_ID = 22;
PANDAREN_RACE_ID = 24;
PANDAREN_ALLIANCE_RACE_ID = 25;
PANDAREN_HORDE_RACE_ID = 26;

PAID_CHARACTER_CUSTOMIZATION = 1;
PAID_RACE_CHANGE = 2;
PAID_FACTION_CHANGE = 3;
PAID_SERVICE_CHARACTER_ID = nil;
PAID_SERVICE_TYPE = nil;

PREVIEW_FRAME_HEIGHT = 130;
PREVIEW_FRAME_X_OFFSET = 16;
PREVIEW_FRAME_Y_OFFSET = -7;

local FACTION_GROUP_HORDE = 0;
local FACTION_GROUP_ALLIANCE = 1;

FACTION_BACKDROP_COLOR_TABLE = {
	["Alliance"] = {0.5, 0.5, 0.5, 0.09, 0.09, 0.19, 0, 0, 0.2, 0.29, 0.33, 0.91},
	["Horde"] = {0.5, 0.2, 0.2, 0.19, 0.05, 0.05, 0.2, 0, 0, 0.90, 0.05, 0.07},
	["Player"] = {0.2, 0.5, 0.2, 0.05, 0.2, 0.05, 0.05, 0.2, 0.05, 1, 1, 1},
};
FRAMES_TO_BACKDROP_COLOR = {
	"CharacterCreateCharacterRace",
	"CharacterCreateCharacterClass",
--	"CharacterCreateCharacterFaction",
	"CharacterCreateNameEdit",
};
RACE_ICON_TCOORDS = {
	["HUMAN_MALE"]		= {0, 0.125, 0, 0.25},
	["DWARF_MALE"]		= {0.125, 0.25, 0, 0.25},
	["GNOME_MALE"]		= {0.25, 0.375, 0, 0.25},
	["NIGHTELF_MALE"]	= {0.375, 0.5, 0, 0.25},

	["TAUREN_MALE"]		= {0, 0.125, 0.25, 0.5},
	["SCOURGE_MALE"]	= {0.125, 0.25, 0.25, 0.5},
	["TROLL_MALE"]		= {0.25, 0.375, 0.25, 0.5},
	["ORC_MALE"]		= {0.375, 0.5, 0.25, 0.5},

	["HUMAN_FEMALE"]	= {0, 0.125, 0.5, 0.75},
	["DWARF_FEMALE"]	= {0.125, 0.25, 0.5, 0.75},
	["GNOME_FEMALE"]	= {0.25, 0.375, 0.5, 0.75},
	["NIGHTELF_FEMALE"]	= {0.375, 0.5, 0.5, 0.75},

	["TAUREN_FEMALE"]	= {0, 0.125, 0.75, 1.0},
	["SCOURGE_FEMALE"]	= {0.125, 0.25, 0.75, 1.0},
	["TROLL_FEMALE"]	= {0.25, 0.375, 0.75, 1.0},
	["ORC_FEMALE"]		= {0.375, 0.5, 0.75, 1.0},

	["BLOODELF_MALE"]	= {0.5, 0.625, 0.25, 0.5},
	["BLOODELF_FEMALE"]	= {0.5, 0.625, 0.75, 1.0},

	["DRAENEI_MALE"]	= {0.5, 0.625, 0, 0.25},
	["DRAENEI_FEMALE"]	= {0.5, 0.625, 0.5, 0.75},

	["GOBLIN_MALE"]		= {0.629, 0.750, 0.25, 0.5},
	["GOBLIN_FEMALE"]	= {0.629, 0.750, 0.75, 1.0},

	["WORGEN_MALE"]		= {0.629, 0.750, 0, 0.25},
	["WORGEN_FEMALE"]	= {0.629, 0.750, 0.5, 0.75},

	["PANDAREN_MALE"]	= {0.756, 0.881, 0, 0.25},
	["PANDAREN_FEMALE"]	= {0.756, 0.881, 0.5, 0.75},

	["NIGHTBORNE_MALE"]	= {0.375, 0.5, 0, 0.25},
	["NIGHTBORNE_FEMALE"]	= {0.375, 0.5, 0.5, 0.75},

	["HIGHMOUNTAINTAUREN_MALE"]		= {0, 0.125, 0.25, 0.5},
	["HIGHMOUNTAINTAUREN_FEMALE"]	= {0, 0.125, 0.75, 1.0},

	["VOIDELF_MALE"]	= {0.5, 0.625, 0.25, 0.5},
	["VOIDELF_FEMALE"]	= {0.5, 0.625, 0.75, 1.0},

	["LIGHTFORGEDDRAENEI_MALE"]	= {0.5, 0.625, 0, 0.25},
	["LIGHTFORGEDDRAENEI_FEMALE"]	= {0.5, 0.625, 0.5, 0.75},

	["DARKIRONDWARF_MALE"]		= {0.125, 0.25, 0, 0.25},
	["DARKIRONDWARF_FEMALE"]	= {0.125, 0.25, 0.5, 0.75},

	["MAGHARORC_MALE"]			= {0.375, 0.5, 0.25, 0.5},
	["MAGHARORC_FEMALE"]		= {0.375, 0.5, 0.75, 1.0},

	["ZANDALARITROLL_MALE"]		= {0.25, 0.375, 0.25, 0.5},
	["ZANDALARITROLL_FEMALE"]	= {0.25, 0.375, 0.75, 1.0},
};

CHARCREATE_CLASS_TOOLTIP = {};

CHARCREATE_CLASS_INFO = {
	WARRIOR	= {
		spells = {
			{name = CLASS_WARRIOR_SPELLNAME1, desc = CLASS_WARRIOR_SPELLDESC1, texture = [[Interface\Icons\inv_sword_48]]}, -- Execute
			{name = CLASS_WARRIOR_SPELLNAME2, desc = CLASS_WARRIOR_SPELLDESC2, texture = [[Interface\Icons\ability_warrior_charge]]}, -- Charge
			{name = CLASS_WARRIOR_SPELLNAME3, desc = CLASS_WARRIOR_SPELLDESC3, texture = [[Interface\Icons\ability_warrior_shieldwall]]}, -- Sheild Wall
		},
	},
	PALADIN = {
		spells = {
			{name = CLASS_PALADIN_SPELLNAME1, desc = CLASS_PALADIN_SPELLDESC1, texture = [[Interface\Icons\Spell_Holy_AvengersShield]]}, -- Avenger’s Shield
			{name = CLASS_PALADIN_SPELLNAME2, desc = CLASS_PALADIN_SPELLDESC2, texture = [[Interface\Icons\ability_paladin_beaconoflight]]}, -- Beacon of Light
			{name = CLASS_PALADIN_SPELLNAME3, desc = CLASS_PALADIN_SPELLDESC3, texture = [[Interface\Icons\spell_holy_divineshield]]}, -- Divine Shield
		},
	},
	HUNTER = {
		spells = {
			{name = CLASS_HUNTER_SPELLNAME1, desc = CLASS_HUNTER_SPELLDESC1, texture = [[Interface\Icons\inv_spear_07]]}, -- Aimed Shot
			{name = CLASS_HUNTER_SPELLNAME2, desc = CLASS_HUNTER_SPELLDESC2, texture = [[Interface\Icons\ability_hunter_beastcall]]}, -- Call Pet
			{name = CLASS_HUNTER_SPELLNAME3, desc = CLASS_HUNTER_SPELLDESC3, texture = [[Interface\Icons\spell_yorsahj_bloodboil_black]]}, -- Tar Trap
		},
	},
	ROGUE = {
		spells = {
			{name = CLASS_ROGUE_SPELLNAME1, desc = CLASS_ROGUE_SPELLDESC1, texture = [[Interface\Icons\ability_cheapshot]]}, -- Cheap Shot
			{name = CLASS_ROGUE_SPELLNAME2, desc = CLASS_ROGUE_SPELLDESC2, texture = [[Interface\Icons\ability_rogue_dualweild]]}, -- Deadly Poison
			{name = CLASS_ROGUE_SPELLNAME3, desc = CLASS_ROGUE_SPELLDESC3, texture = [[Interface\Icons\ability_stealth]]}, -- Stealth
		},
	},
	PRIEST = {
		spells = {
			{name = CLASS_PRIEST_SPELLNAME1, desc = CLASS_PRIEST_SPELLDESC1, texture = [[Interface\Icons\spell_holy_powerwordshield]]}, -- Power Word: Shield
			{name = CLASS_PRIEST_SPELLNAME2, desc = CLASS_PRIEST_SPELLDESC2, texture = [[Interface\Icons\spell_holy_prayerofhealing02]]}, -- Prayer of Healing
			{name = CLASS_PRIEST_SPELLNAME3, desc = CLASS_PRIEST_SPELLDESC3, texture = [[Interface\Icons\spell_shadow_shadowwordpain]]}, -- Shadow Word: Pain
		},
	},
	SHAMAN = {
		spells = {
			{name = CLASS_SHAMAN_SPELLNAME1, desc = CLASS_SHAMAN_SPELLDESC1, texture = [[Interface\Icons\spell_nature_healingwavegreater]]}, -- Chain Heal
			{name = CLASS_SHAMAN_SPELLNAME2, desc = CLASS_SHAMAN_SPELLDESC2, texture = [[Interface\Icons\spell_fire_elemental_totem]]}, -- Fire Elemental
			{name = CLASS_SHAMAN_SPELLNAME3, desc = CLASS_SHAMAN_SPELLDESC3, texture = [[Interface\Icons\spell_nature_lightning]]}, -- Lightning Bolt
		},
	},
	MAGE = {
		spells = {
			{name = CLASS_MAGE_SPELLNAME1, desc = CLASS_MAGE_SPELLDESC1, texture = [[Interface\Icons\spell_arcane_blink]]}, -- Blink
			{name = CLASS_MAGE_SPELLNAME2, desc = CLASS_MAGE_SPELLDESC2, texture = [[Interface\Icons\spell_frost_icestorm]]}, -- Blizzard
			{name = CLASS_MAGE_SPELLNAME3, desc = CLASS_MAGE_SPELLDESC3, texture = [[Interface\Icons\spell_fire_flamebolt]]}, -- Fireball
		},
	},
	WARLOCK = {
		spells = {
			{name = CLASS_WARLOCK_SPELLNAME1, desc = CLASS_WARLOCK_SPELLDESC1, texture = [[Interface\Icons\spell_shadow_lifedrain02]]}, -- Drain Life
			{name = CLASS_WARLOCK_SPELLNAME2, desc = CLASS_WARLOCK_SPELLDESC2, texture = [[Interface\Icons\spell_shadow_soulgem]]}, -- Soulstone
			{name = CLASS_WARLOCK_SPELLNAME3, desc = CLASS_WARLOCK_SPELLDESC3, texture = [[Interface\Icons\spell_nature_removecurse]]}, -- Summon Demon
		},
	},
	MONK = {
		spells = {
			{name = CLASS_MONK_SPELLNAME1, desc = CLASS_MONK_SPELLDESC1, texture = [[Interface\Icons\monk_ability_fistoffury]]}, -- Fists of Fury
			{name = CLASS_MONK_SPELLNAME2, desc = CLASS_MONK_SPELLDESC2, texture = [[Interface\Icons\achievement_brewery_2]]}, -- Keg Smash
			{name = CLASS_MONK_SPELLNAME3, desc = CLASS_MONK_SPELLDESC3, texture = [[Interface\Icons\ability_monk_roll]]}, -- Roll
		},
	},
	DRUID = {
		spells = {
			{name = CLASS_DRUID_SPELLNAME1, desc = CLASS_DRUID_SPELLDESC1, texture = [[Interface\Icons\Ability_Racial_BearForm]]}, -- Bear Form
			{name = CLASS_DRUID_SPELLNAME2, desc = CLASS_DRUID_SPELLDESC2, texture = [[Interface\Icons\Ability_Druid_CatForm]]}, -- Cat Form
			{name = CLASS_DRUID_SPELLNAME3, desc = CLASS_DRUID_SPELLDESC3, texture = [[Interface\Icons\Spell_Nature_HealingTouch]]}, -- Healing Touch
		},
	},
	DEMONHUNTER = {
		spells = {
			{name = CLASS_DEMONHUNTER_SPELLNAME1, desc = CLASS_DEMONHUNTER_SPELLDESC1, texture = [[Interface\Icons\ability_demonhunter_felrush]]}, -- Fel Rush
			{name = CLASS_DEMONHUNTER_SPELLNAME2, desc = CLASS_DEMONHUNTER_SPELLDESC2, texture = [[Interface\Icons\ability_demonhunter_eyebeam]]}, -- Eye Beam
			{name = CLASS_DEMONHUNTER_SPELLNAME3, desc = CLASS_DEMONHUNTER_SPELLDESC3, texture = [[Interface\Icons\ability_demonhunter_metamorphasisdps]]}, -- Metamorphosis
		},
	},
	DEATHKNIGHT = {
		spells = {
			{name = CLASS_DEATHKNIGHT_SPELLNAME1, desc = CLASS_DEATHKNIGHT_SPELLDESC1, texture = [[Interface\Icons\Spell_DeathKnight_ArmyOfTheDead]]}, -- Army of the Dead
			{name = CLASS_DEATHKNIGHT_SPELLNAME2, desc = CLASS_DEATHKNIGHT_SPELLDESC2, texture = [[Interface\Icons\Spell_Shadow_DeathAndDecay]]}, -- Death and Decay
			{name = CLASS_DEATHKNIGHT_SPELLNAME3, desc = CLASS_DEATHKNIGHT_SPELLDESC3, texture = [[Interface\Icons\Spell_DeathKnight_Strangulate]]}, -- Death Grip
		},
	},
}

MODEL_CAMERA_CONFIG = {
	[0] = {
		["Draenei"] = { tx = 0.191, ty = -0.015, tz = 2.302, cz = 2.160, distance = 1.116, light =  0.80 },
		["NightElf"] = { tx = 0.095, ty = -0.008, tz = 2.240, cz = 2.045, distance = 0.830, light =  0.85 },
		["Scourge"] = { tx = 0.094, ty = -0.172, tz = 1.675, cz = 1.478, distance = 0.726, light =  0.80 },
		["Orc"] = { tx = 0.346, ty = -0.001, tz = 1.878, cz = 1.793, distance = 1.074, light =  0.80 },
		["Gnome"] = { tx = 0.051, ty = 0.015, tz = 0.845, cz = 0.821, distance = 0.821, light =  0.85 },
		["Dwarf"] = { tx = 0.037, ty = 0.009, tz = 1.298, cz = 1.265, distance = 0.839, light =  0.85 },
		["Tauren"] = { tx = 0.516, ty = -0.003, tz = 1.654, cz = 1.647, distance = 1.266, light =  0.80 },
		["Troll"] = { tx = 0.402, ty = 0.016, tz = 2.076, cz = 1.980, distance = 0.943, light =  0.75 },
		["Worgen"] = { tx = 0.473, ty = 0.012, tz = 1.972, cz = 1.570, distance = 1.423, light =  0.80 },
		["WorgenAlt"] = { tx = 0.055, ty = 0.006, tz = 1.863, cz = 1.749, distance = 0.714, light =  0.75 },
		["BloodElf"] = { tx = 0.009, ty = -0.120, tz = 1.914, cz = 1.712, distance = 0.727, light =  0.80 },
		["Human"] = { tx = 0.055, ty = 0.006, tz = 1.863, cz = 1.749, distance = 0.714, light =  0.75 },
		["Pandaren"] = { tx = 0.046, ty = -0.020, tz = 2.125, cz = 2.201, distance = 1.240, light =  0.90 },
		["Goblin"] = { tx = 0.127, ty = -0.022, tz = 1.104, cz = 1.009, distance = 0.830, light =  0.80 },
		["NightElf6"] = { tx = 0, ty = 0, tz = 1.95, cz = 1.792, distance = 1.75, light =  0.80 },
		["NightElf7"] = { tx = 0.095, ty = -0.008, tz = 2.240, cz = 2.045, distance = 1.230, light =  0.85 },
        ["NightElf9"] = { tx = 0, ty = 0, tz = 1.95, cz = 1.792, distance = 1.75, light =  0.80 },
		["BloodElf6"] = { tx = -0.1, ty = 0, tz = 1.6, cz = 1.792, distance = 1.65, light =  0.80 },
		["BloodElf7"] = { tx = 0.009, ty = -0.120, tz = 1.914, cz = 1.712, distance = 1.127, light =  0.80 },
        ["BloodElf9"] = { tx = -0.1, ty = 0, tz = 1.6, cz = 1.792, distance = 1.65, light =  0.80 },
		["Nightborne"] = { tx = 0.095, ty = -0.008, tz = 2.240, cz = 2.045, distance = 0.830, light =  0.85 },
		["HighmountainTauren"] = { tx = 0.516, ty = -0.003, tz = 1.654, cz = 1.647, distance = 1.266, light =  0.80 },
		["VoidElf"] = { tx = 0.009, ty = -0.120, tz = 1.914, cz = 1.712, distance = 0.727, light =  0.80 },
		["LightforgedDraenei"] = { tx = 0.191, ty = -0.015, tz = 2.302, cz = 2.160, distance = 1.116, light =  0.80 },
		["Nightborne6"] = { tx = 0, ty = 0, tz = 1.95, cz = 1.792, distance = 1.75, light =  0.85 },
		["LightforgedDraenei6"] = { tx = 0, ty = 0, tz = 1.642, cz = 1.792, distance = 2.692, light =  0.80 },
		["HighmountainTauren6"] = { tx = -0.216, ty = -0.203, tz = 1.654, cz = 1.647, distance = 3.566, light =  0.80 },
		["ZandalariTroll"] = { tx = 0.402, ty = 0.016, tz = 2.076, cz = 1.980, distance = 0.943, light =  0.75 },
		["DarkIronDwarf"] = { tx = 0.037, ty = 0.009, tz = 1.298, cz = 1.265, distance = 0.839, light =  0.85 },
		["MagharOrc"] = { tx = 0.346, ty = -0.001, tz = 1.878, cz = 1.793, distance = 1.074, light =  0.80 },
	},
	[1] = {
		["Draenei"] = { tx = 0.155, ty = 0.009, tz = 2.177, cz = 1.971, distance = 0.734, light =  0.75 },
		["NightElf"] = { tx = 0.071, ty = 0.034, tz = 2.068, cz = 2.055, distance = 0.682, light =  0.85 },
		["Scourge"] = { tx = 0.198, ty = 0.001, tz = 1.669, cz = 1.509, distance = 0.563, light =  0.75 },
		["Orc"] = { tx = -0.069, ty = -0.007, tz = 1.863, cz = 1.718, distance = 0.585, light =  0.75 },
		["Gnome"] = { tx = 0.031, ty = 0.009, tz = 0.787, cz = 0.693, distance = 0.726, light =  0.85 },
		["Dwarf"] = { tx = -0.060, ty = -0.010, tz = 1.326, cz = 1.343, distance = 0.720, light =  0.80 },
		["Tauren"] = { tx = 0.337, ty = -0.008, tz = 1.918, cz = 1.855, distance = 0.891, light =  0.75 },
		["Troll"] = { tx = 0.031, ty = -0.082, tz = 2.226, cz = 2.248, distance = 0.674, light =  0.75 },
		["Worgen"] = { tx = 0.067, ty = -0.044, tz = 2.227, cz = 2.013, distance = 1.178, light =  0.80 },
		["WorgenAlt"] = { tx = -0.044, ty = -0.015, tz = 1.755, cz = 1.689, distance = 0.612, light =  0.75 },
		["BloodElf"] = { tx = -0.072, ty = 0.009, tz = 1.789, cz = 1.792, distance = 0.717, light =  0.80 },
		["Human"] = { tx = -0.044, ty = -0.015, tz = 1.755, cz = 1.689, distance = 0.612, light =  0.75 },
		["Pandaren"] = { tx = 0.122, ty = -0.002, tz = 1.999, cz = 1.925, distance = 1.065, light =  0.90 },
		["Goblin"] = { tx = -0.076, ty = 0.006, tz = 1.191, cz = 1.137, distance = 0.970, light =  0.80 },
		["NightElf6"] = { tx = 0, ty = 0, tz = 1.85, cz = 1.792, distance = 1.6, light =  0.80 },
		["NightElf7"] = { tx = 0.071, ty = 0.034, tz = 2.068, cz = 2.055, distance = 1.082, light =  0.85 },
        ["NightElf9"] = { tx = 0, ty = 0, tz = 1.85, cz = 1.792, distance = 1.6, light =  0.80 },
		["BloodElf6"] = { tx = 0, ty = 0, tz = 1.55, cz = 1.792, distance = 1.2, light =  0.80 },
		["BloodElf7"] = { tx = -0.072, ty = 0.009, tz = 1.789, cz = 1.792, distance = 1.117, light =  0.80 },
        ["BloodElf9"] = { tx = 0, ty = 0, tz = 1.55, cz = 1.792, distance = 1.2, light =  0.80 },
		["Nightborne"] = { tx = 0.071, ty = 0.034, tz = 2.068, cz = 2.055, distance = 0.682, light =  0.85 },
		["HighmountainTauren"] = { tx = 0.337, ty = -0.008, tz = 1.918, cz = 1.855, distance = 0.891, light =  0.75 },
		["VoidElf"] = { tx = -0.072, ty = 0.009, tz = 1.789, cz = 1.792, distance = 0.717, light =  0.80 },
		["LightforgedDraenei"] = { tx = 0.155, ty = 0.009, tz = 2.177, cz = 1.971, distance = 0.734, light =  0.75 },
		["Nightborne6"] = { tx = 0, ty = 0, tz = 1.85, cz = 1.792, distance = 1.6, light =  0.85 },
		["LightforgedDraenei6"] = { tx = -0.271, ty = 0, tz = 1.642, cz = 1.971, distance = 1.492, light =  0.80 },
		["HighmountainTauren6"] = { tx = 0.137, ty = -0.008, tz = 1.918, cz = 1.855, distance = 1.591, light =  0.75 },
		["ZandalariTroll"] = { tx = 0.031, ty = -0.082, tz = 2.226, cz = 2.248, distance = 0.674, light =  0.75 },
		["DarkIronDwarf"] = { tx = -0.060, ty = -0.010, tz = 1.326, cz = 1.343, distance = 0.720, light =  0.80 },
		["MagharOrc"] = { tx = -0.069, ty = -0.007, tz = 1.863, cz = 1.718, distance = 0.585, light =  0.75 },
	}
};

local classTrialResultToString = {
	[LE_CHARACTER_UPGRADE_RESULT_DB_ERROR] = CLASS_TRIAL_CREATE_RESULT_ERROR_DB_ERROR,
	[LE_CHARACTER_UPGRADE_RESULT_TRIAL_THROTTLE_HOUR] = CLASS_TRIAL_CREATE_RESULT_ERROR_THROTTLE_HOUR,
	[LE_CHARACTER_UPGRADE_RESULT_TRIAL_THROTTLE_DAY] = CLASS_TRIAL_CREATE_RESULT_ERROR_THROTTLE_DAY,
	[LE_CHARACTER_UPGRADE_RESULT_TRIAL_THROTTLE_WEEK] = CLASS_TRIAL_CREATE_RESULT_ERROR_THROTTLE_WEEK,
	[LE_CHARACTER_UPGRADE_RESULT_TRIAL_THROTTLE_ACCOUNT] = CLASS_TRIAL_CREATE_RESULT_ERROR_THROTTLE_ACCOUNT,
	[LE_CHARACTER_UPGRADE_RESULT_BOX_LEVEL] = CLASS_TRIAL_CREATE_RESULT_ERROR_BOX_LEVEL,
	[LE_CHARACTER_UPGRADE_RESULT_TRIAL_BOOST_DISABLED] = CLASS_TRIAL_CREATE_RESULT_ERROR_BOOST_DISABLED,
	[LE_CHARACTER_UPGRADE_RESULT_TRIAL_ACCOUNT] = CLASS_TRIAL_CREATE_RESULT_ERROR_TRIAL_ACCOUNT,
	[LE_CHARACTER_UPGRADE_RESULT_UPGRADE_PENDING] = CLASS_TRIAL_CREATE_RESULT_ERROR_UPGRADE_PENDING,
	[LE_CHARACTER_UPGRADE_RESULT_INVALID_CHARACTER] = CLASS_TRIAL_CREATE_RESULT_ERROR_INVALID_CHARACTER,
	[LE_CHARACTER_UPGRADE_RESULT_NOT_FRESH_CHARACTER] = CLASS_TRIAL_CREATE_RESULT_ERROR_NOT_FRESH_CHARACTER,
}

local function HandleClassTrialCreateResult(result)
	local resultMessage = classTrialResultToString[result];
	if resultMessage then
		GlueDialog_Show("OKAY", resultMessage);
		CharacterCreate_SelectCharacterType(Enum.CharacterCreateType.Normal);
	end
end

function CharacterCreate_OnLoad(self)
	self:RegisterEvent("RANDOM_CHARACTER_NAME_RESULT");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("CHARACTER_CREATION_RESULT");
	self:RegisterEvent("CUSTOMIZE_CHARACTER_STARTED");
	self:RegisterEvent("CUSTOMIZE_CHARACTER_RESULT");
	self:RegisterEvent("RACE_FACTION_CHANGE_STARTED");
	self:RegisterEvent("RACE_FACTION_CHANGE_RESULT");
	self:RegisterEvent("CLASS_TRIAL_CHARACTER_CREATE_RESULT");

	self:SetSequence(0);
	self:SetCamera(0);

	CharacterCreate.numRaces = 0;
	CharacterCreate.selectedRace = 0;
	CharacterCreate.numClasses = 0;
	CharacterCreate.selectedClass = 0;
	CharacterCreate.selectedGender = 0;

	CharacterCreate.allianceFramePool = CreateFramePool("CHECKBUTTON", CharCreateRaceButtonsFrame.AllianceRaces, "CharCreateRaceButtonTemplate");
	CharacterCreate.hordeFramePool = CreateFramePool("CHECKBUTTON", CharCreateRaceButtonsFrame.HordeRaces, "CharCreateRaceButtonTemplate");
	CharacterCreate.neutralFramePool = CreateFramePool("CHECKBUTTON", CharCreateRaceButtonsFrame.NeutralRaces, "CharCreateRaceButtonTemplate");
	CharacterCreate.classFramePool = CreateFramePool("CHECKBUTTON", CharCreateClassFrame.ClassIcons, "CharCreateClassButtonTemplate");

	C_CharacterCreation.SetCurrentRaceMode(Enum.CharacterCreateRaceMode.Normal);

	C_CharacterCreation.SetCharCustomizeFrame("CharacterCreate");
	CharacterCreate_UpdateCustomizationOptions();

	-- Color edit box backdrop
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE["Alliance"];
	CharacterCreateNameEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	CharacterCreateNameEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);

	CharacterCreateFrame.state = "CLASSRACE";

	CharCreatePreviewFrame.previews = { };

	local classes = C_CharacterCreation.GetAvailableClasses();
	for idx, classData in pairs(classes) do
		-- Class Button Tooltip
		local classIndex = classData.fileName;
		CHARCREATE_CLASS_TOOLTIP[classIndex] = {
			name = classData.name;
			roles = _G["CLASS_INFO_"..classIndex.."_ROLE_TT"];
			description = "|n".._G["CLASS_"..classIndex].."|n|n";
			footer = CLASS_INFO_MORE_INFO_HINT;
		};

		-- Class More Info Data
		local classInfo = CHARCREATE_CLASS_INFO[classIndex];
		classInfo.name = classData.name;
		local bulletIndex = 0;
		local tempText = _G["CLASS_INFO_"..classIndex..bulletIndex];
		local bulletText = "";
		while ( tempText ) do
			bulletText = bulletText..tempText.."|n|n";
			bulletIndex = bulletIndex + 1;
			tempText = _G["CLASS_INFO_"..classIndex..bulletIndex];
		end
		classInfo.bulletText = bulletText;
		classInfo.description = _G["CLASS_"..classIndex];
	end

	CharCreateClassInfoFrameScrollFrameScrollChildInfoText.topPadding = 18;
	CharCreateClassInfoFrameScrollFrameScrollChild.Spells = {};
end

function CharacterCreate_OnShow()
	InitializeCharacterScreenData();
	SetInCharacterCreate(true);

	CharacterCreate.allianceFramePool:ReleaseAll();
	CharacterCreate.hordeFramePool:ReleaseAll();
	CharacterCreate.neutralFramePool:ReleaseAll();

	if ( PAID_SERVICE_TYPE ) then
		C_CharacterCreation.CustomizeExistingCharacter( PAID_SERVICE_CHARACTER_ID );
		CharacterCreateNameEdit:SetText( C_PaidServices.GetName() );
	else
		--randomly selects a combination
		C_CharacterCreation.ResetCharCustomize();
		CharacterCreateNameEdit:SetText("");
		CharCreateRandomizeButton:Show();
	end

	-- Pandarens doing paid faction change
	if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE and C_CharacterCreation.GetSelectedRace() == PANDAREN_RACE_ID ) then
		PandarenFactionButtons_Show();
	else
		PandarenFactionButtons_Hide();
	end

	CharCreateRaceButtonsFrame.ClassicBanners:Show();
	CharCreateRaceButtonsFrame.AlliedRaceBanners:Hide();
	C_CharacterCreation.SetCurrentRaceMode(Enum.CharacterCreateRaceMode.Normal);
	if (PAID_SERVICE_TYPE) then
		local raceID = C_PaidServices.GetCurrentRaceID();
		local raceData = C_CharacterCreation.GetRaceDataByID(raceID);
		if (raceData.isAlliedRace) then
			CharCreateRaceButtonsFrame.ClassicBanners:Hide();
			CharCreateRaceButtonsFrame.AlliedRaceBanners:Show();
			C_CharacterCreation.SetCurrentRaceMode(Enum.CharacterCreateRaceMode.AlliedRace);
		end
	end

	CharacterCreateEnumerateRaces(true);

	SetCharacterRace(C_CharacterCreation.GetSelectedRace());

	CharacterCreateEnumerateClasses();

	local classData = C_CharacterCreation.GetSelectedClass();
	SetCharacterClass(classData.classID);

	SetCharacterGender(C_CharacterCreation.GetSelectedSex())

	-- Hair customization stuff
	CharacterCreate_UpdateCustomizationOptions();

	C_CharacterCreation.SetCharacterCreateFacing(-15);

	-- setup customization
	CharacterChangeFixup();

	C_CharacterCreation.SetFaceCustomizeCamera(false);

	CharacterCreateFrame_UpdateRecruitInfo();
	CharacterCreate_SelectCharacterType(C_CharacterCreation.GetCharacterCreateType());

	if( IsKioskGlueEnabled() ) then
		local kioskModeData = KioskModeSplash_GetModeData();
		if (not kioskModeData) then
			-- This shouldn't happen, why don't have we have mode data?
			GlueParent_SetScreen("kioskmodesplash");
			return;
		end
		local available = {};
		local raceList = KioskModeSplash_GetRaceList(); 
		for k, v in pairs(raceList) do
			if (v) then
				tinsert(available, k);
			end
		end

		local rid = KioskModeSplash_GetIDForSelection("races", available[math.random(1, #available)]);

		C_CharacterCreation.SetSelectedRace(rid);
		SetCharacterRace(rid);
		
		CharacterCreateEnumerateClasses();
		local available = {};
		for k, v in pairs(kioskModeData.classes) do
			if (v) then
				local id = KioskModeSplash_GetIDForSelection("classes", k);
				if (C_CharacterCreation.IsClassAllowedInKioskMode(id) and C_CharacterCreation.IsRaceClassValid(rid, id)) then
					tinsert(available, k);
				end
			end
		end

		local cid = KioskModeSplash_GetIDForSelection("classes", available[math.random(1, #available)]);
		
		KioskModeCheckHighLevel(cid);
		C_CharacterCreation.SetSelectedClass(cid);
		SetCharacterClass(cid);

		C_CharacterCreation.RandomizeCharCustomization(true);
		KioskModeSplash_SetAutoEnterWorld(false);
	end
end

function CharacterCreate_OnHide()
	PAID_SERVICE_CHARACTER_ID = nil;
	PAID_SERVICE_TYPE = nil;
	CharCreateCharacterTypeFrame.currentCharacterType = nil;

	if ( CharacterCreateFrame.state == "CUSTOMIZATION" ) then
		CharacterCreate_Back();
	end
	-- character previews will need to be redone if coming back to character create. One reason is all the memory used for
	-- tracking the frames (on the c side) will get released if the user returns to the login screen
	CharCreatePreviewFrame.rebuildPreviews = true;
	SetInCharacterCreate(false);
end

function CharacterCreate_OnEvent(self, event, ...)
	if ( event == "RANDOM_CHARACTER_NAME_RESULT" ) then
		local success, name = ...;
		if ( not success ) then
			-- Failed.  Generate a random name locally.
			CharacterCreateNameEdit:SetText(C_CharacterCreation.GenerateRandomName());
		else
			-- Succeeded.  Use what the server sent.
			CharacterCreateNameEdit:SetText(name);
		end
		CharacterCreateRandomName:Enable();
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	elseif ( event == "UPDATE_EXPANSION_LEVEL" ) then
		-- Expansion level changed while online, so enable buttons as needed
		if ( CharacterCreateFrame:IsShown() ) then
			CharacterCreateEnumerateRaces(true);
			CharacterCreateEnumerateClasses();
		end
	elseif ( event == "CHARACTER_CREATION_RESULT" ) then
		local success, errorCode = ...;
		if ( success ) then
			if (CharacterUpgrade_IsCreatedCharacterTrialBoost() and IsConnectedToServer()) then
				CharacterSelect_SetPendingTrialBoost(true, CharacterCreate_GetSelectedFaction(), CharCreateSelectSpecFrame.selected);
			end

			CharacterSelect.selectLast = true;
			GlueParent_SetScreen("charselect");
		else
			CharCreate_RefreshNextButton();
			GlueDialog_Show("OKAY", _G[errorCode]);
		end
	elseif ( event == "CUSTOMIZE_CHARACTER_STARTED" ) then
		GlueDialog_Show("PAID_SERVICE_IN_PROGRESS", CHAR_CUSTOMIZE_IN_PROGRESS);
	elseif ( event == "CUSTOMIZE_CHARACTER_RESULT" ) then
		local success, err = ...;
		if ( success ) then
			GlueDialog_Hide("PAID_SERVICE_IN_PROGRESS");
			GlueParent_SetScreen("charselect");
		else
			GlueDialog_Show("OKAY", _G[err]);
		end
	elseif ( event == "RACE_FACTION_CHANGE_STARTED" ) then
		local changeType = ...;
		if ( changeType == "RACE" ) then
			GlueDialog_Show("PAID_SERVICE_IN_PROGRESS", RACE_CHANGE_IN_PROGRESS);
		elseif ( changeType == "FACTION" ) then
			GlueDialog_Show("PAID_SERVICE_IN_PROGRESS", FACTION_CHANGE_IN_PROGRESS);
		end
	elseif ( event == "RACE_FACTION_CHANGE_RESULT" ) then
		local success, err = ...;
		if ( success ) then
			GlueDialog_Hide("PAID_SERVICE_IN_PROGRESS");
			GlueParent_SetScreen("charselect");
		else
			GlueDialog_Show("OKAY", _G[err]);
		end
	elseif ( event == "CLASS_TRIAL_CHARACTER_CREATE_RESULT" ) then
		local result = ...
		HandleClassTrialCreateResult(result);
	end
end

function CharacterCreateFrame_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition();
		CHARACTER_CREATE_INITIAL_FACING = C_CharacterCreation.GetCharacterCreateFacing();
	end
end

function CharacterCreateFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = nil
	end
end

function CharacterCreateFrame_OnUpdate(self, elapsed)
	if ( CHARACTER_CREATE_ROTATION_START_X ) then
		local x = GetCursorPosition();
		local diff = (x - CHARACTER_CREATE_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_CREATE_ROTATION_START_X = x;
		C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + diff);
		CharCreate_RotatePreviews();
	end
	CharacterCreateWhileMouseDown_Update(elapsed);
end

local function ShowGlowyDialog(dialog, text, showOKButton)
	dialog.Text:SetText(text);
	dialog.OkayButton:SetShown(showOKButton);
	dialog:Show();
end

function CharacterCreateFrame_UpdateRecruitInfo()
	local active, faction = C_RecruitAFriend.GetRecruitInfo();
	if ( active and not PAID_SERVICE_TYPE ) then
		local anchorFrame, notice;
		if ( faction == FACTION_GROUP_HORDE ) then
			anchorFrame = CharCreateRaceButtonsFrame.HordeRaces;
			notice = RECRUIT_A_FRIEND_FACTION_SUGGESTION_HORDE;
		else
			anchorFrame = CharCreateRaceButtonsFrame.AllianceRaces;
			notice = RECRUIT_A_FRIEND_FACTION_SUGGESTION_ALLIANCE;
		end
		RecruitAFriendFactionHighlight:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", -17, 10);
		RecruitAFriendFactionHighlight:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 17, -6);
		ShowGlowyDialog(RecruitAFriendFactionNotice, notice, true);
		RecruitAFriendFactionNotice:SetPoint("LEFT", anchorFrame, "TOPRIGHT", 35, -95);
		RecruitAFriendFactionHighlight:Show();
		RecruitAFriendPandaHighlight:SetShown(C_CharacterCreation.GetCurrentRaceMode() == Enum.CharacterCreateRaceMode.Normal);
		local raceID = CharacterCreate_GetRandomRace();

		if (raceID) then
			CharCreateSelectRace(raceID, true);
			return true;		
		end
	else
		RecruitAFriendFactionHighlight:Hide();
		RecruitAFriendPandaHighlight:Hide();
		RecruitAFriendFactionNotice:Hide();
	end
	return false;
end

-- For these races, the names are shortened for the atlas
local fixedRaceAtlasNames = {
	["highmountaintauren"] = "highmountain",
	["lightforgeddraenei"] = "lightforged",
	["scourge"] = "undead"
};

function GetRaceAtlas(raceName, gender)
	if (fixedRaceAtlasNames[raceName]) then
		raceName = fixedRaceAtlasNames[raceName];
	end
	return ("raceicon-%s-%s"):format(raceName, gender);
end

function CharacterCreate_GetRandomRace()
	local races = C_CharacterCreation.GetAvailableRaces();

	local kioskModeData = IsKioskGlueEnabled() and KioskModeSplash_GetModeData();
	local raceList = kioskModeData and KioskModeSplash_GetRaceList();
	-- Filter the list if were in kiosk mode
	races = tFilter(races, function(v) return not raceList or raceList[strupper(v.fileName)] end, true);
	
	if (PAID_SERVICE_TYPE) then
		local classID = C_PaidServices.GetCurrentClassID();
		local faction = C_CharacterCreation.GetFactionForRace(C_PaidServices.GetCurrentRaceID());
		if (PAID_SERVICE_TYPE == PAID_FACTION_CHANGE) then
			races = tFilter(races, function(raceData) return raceData.enabled and C_CharacterCreation.IsRaceClassValid(raceData.raceID, classID) and faction ~= C_CharacterCreation.GetFactionForRace(raceData.raceID) end, true);
		elseif (PAID_SERVICE_TYPE == PAID_RACE_CHANGE) then
			races = tFilter(races, function(raceData) return raceData.enabled and C_CharacterCreation.IsRaceClassValid(raceData.raceID, classID) and faction == C_CharacterCreation.GetFactionForRace(raceData.raceID) end, true);
		else
			return nil;
		end
	end

	local active, faction = C_RecruitAFriend.GetRecruitInfo();
	if (active) then
		local classID = C_CharacterCreation.GetSelectedClass().classID;
		local matchFaction = faction == FACTION_GROUP_HORDE and "Horde" or "Alliance";
		races = tFilter(races, function(raceData) return raceData.enabled and C_CharacterCreation.IsRaceClassValid(raceData.raceID, classID) and matchFaction == select(2,C_CharacterCreation.GetFactionForRace(raceData.raceID)) end, true);
	end

	if (#races == 0) then
		return nil;
	elseif (#races == 1) then
		return races[1].raceID;
	else
		return races[math.random(1, #races)].raceID;
	end
end

function CharacterCreateEnumerateRaces(modeChange)
	local races = C_CharacterCreation.GetAvailableRaces();

	if ( #races > MAX_RACES ) then
		message("Too many races!  Update MAX_RACES");
		while ( #races > MAX_RACES ) do
			races[#races] = nil;
		end
	end
	CharacterCreate.numRaces = #races;

	local gender;
	if ( C_CharacterCreation.GetSelectedSex() == Enum.Unitsex.Male ) then
		gender = "male";
	else
		gender = "female";
	end

	ResetRaceSelections();
	CharacterCreate.allianceFramePool:ReleaseAll();
	CharacterCreate.hordeFramePool:ReleaseAll();
	CharacterCreate.neutralFramePool:ReleaseAll();

	local indexRef = {
		["alliance"] = 1,
		["horde"] = 1,
		["neutral"] = 1
	}

	for i, raceData in pairs(races) do
		local key, pool = GetFactionAndFramePoolInfoForRaceID(raceData.raceID);
		local button = pool:Acquire();
		if ( not button  ) then
			return;
		end

		button.layoutIndex = indexRef[key];
		button.raceID = raceData.raceID;

		local name = raceData.name;
		local atlas = GetRaceAtlas(strlower(raceData.fileName), gender);
		button.NormalTexture:SetAtlas(atlas);
		button.PushedTexture:SetAtlas(atlas);
		button.nameFrame.text:SetText(name);
		
		local kioskModeData = IsKioskGlueEnabled() and KioskModeSplash_GetModeData();
		local raceList = kioskModeData and KioskModeSplash_GetRaceList();
		local disableTexture = button.DisableTexture;

		local hiddenInKiosk = false;
		if ( raceData.enabled and (not raceList or raceList[strupper(raceData.fileName)]) ) then
			button:Enable();
			SetButtonDesaturated(button);
			button.name = name;
			button.tooltip = name;
			disableTexture:Hide();
		else
			if (C_CharacterCreation.ShouldShowAlliedRacesButton() and C_CharacterCreation.GetCurrentRaceMode() == Enum.CharacterCreateRaceMode.AlliedRace and not IsKioskModeEnabled()) then
				button:Enable();
			else
				button:Disable();
				if (C_CharacterCreation.GetCurrentRaceMode() == Enum.CharacterCreateRaceMode.AlliedRace and IsKioskModeEnabled()) then
					hiddenInKiosk = true;
				end
			end
			SetButtonDesaturated(button, true);
			button.name = name;
			if (IsKioskGlueEnabled()) then
				button.tooltip = RACE_DISABLED_KIOSK_MODE;
			else
				local disabledReason = _G[strupper(raceData.fileName).."_DISABLED"];
				if ( disabledReason ) then
					button.tooltip = name.."|n"..disabledReason;
				else
					button.tooltip = nil;
				end
			end
			disableTexture:SetShown(IsKioskGlueEnabled());
		end
		button:SetShown(not hiddenInKiosk);
		indexRef[key] = indexRef[key] + 1;
	end
	
	if ( PAID_SERVICE_TYPE ) then
		if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE and C_CharacterCreation.GetCurrentRaceMode() == Enum.CharacterCreateRaceMode.Normal and C_CharacterCreation.IsRaceClassValid(PANDAREN_RACE_ID, C_PaidServices.GetCurrentClassID())) then
			PandarenFactionButtons_Show();
		else
			PandarenFactionButtons_Hide();
		end
		CharacterChangeFixup();
	end

	CharacterCreate_UpdateAlliedRaceButton();
	CharCreateRaceButtonsFrame.AllianceRaces:Layout();
	CharCreateRaceButtonsFrame.HordeRaces:Layout();
	CharCreateRaceButtonsFrame.NeutralRaces:Layout();

	if (modeChange) then
		local raceSelected = CharacterCreateFrame_UpdateRecruitInfo();
		if (not raceSelected) then
			local raceID = CharacterCreate_GetRandomRace();

			if (raceID) then
				CharCreateSelectRace(raceID, true);
			end
		end
	end
end

function GetFactionAndFramePoolInfoForRaceID(raceID)
	local _, faction = C_CharacterCreation.GetFactionForRace(raceID);
	local key = "alliance";
	if (C_CharacterCreation.IsNeutralRace(raceID)) then
		key = "neutral";
	elseif (faction == "Horde") then
		key = "horde";
	end

	local pool = CharacterCreate[key.."FramePool"];
	return key, pool;
end

function FindButtonForRaceID(raceID)
	local key, pool = GetFactionAndFramePoolInfoForRaceID(raceID);

	for frame in pool:EnumerateActive() do
		if frame.raceID == raceID then
			return frame;
		end
	end

	return nil;
end

function FindButtonForClassID(classID)
	for frame in CharacterCreate.classFramePool:EnumerateActive() do
		if frame.classID == classID then
			return frame;
		end
	end

	return nil;
end

local function UpdateClassButtonEnabledState(button, classID, classData)
	local kioskModeData = IsKioskGlueEnabled() and KioskModeSplash_GetModeData();
	local disableTexture = button.DisableTexture;

	if ( classData.enabled == true ) then
		if (IsKioskGlueEnabled() and (not C_CharacterCreation.IsClassAllowedInKioskMode(classID) or not kioskModeData.classes[classData.fileName])) then
			button:Disable();
			SetButtonDesaturated(button, true);
			button.tooltip.footer = CLASS_DISABLED_KIOSK_MODE;
			disableTexture:Show();
		elseif (C_CharacterCreation.IsRaceClassValid(CharacterCreate.selectedRace, classID)) then
			button:Enable();
			SetButtonDesaturated(button, false);
			button.tooltip.footer = CLASS_INFO_MORE_INFO_HINT;
			disableTexture:Hide();
		else
			button:Disable();
			SetButtonDesaturated(button, true);
			local validRaces = C_CharacterCreation.GetValidRacesForClass(button.classID);
			local validRaceNames = {};
			for i, raceData in ipairs(validRaces) do
				tinsert(validRaceNames, raceData.name);
			end
			local validRaceConcat = table.concat(validRaceNames, ", ");
			button.tooltip.footer = WrapTextInColorCode(CLASS_DISABLED, "ffff0000") .. "|n|n" .. WrapTextInColorCode(validRaceConcat, "ffff0000");
			disableTexture:Show();
		end
	else
		button:Disable();
		SetButtonDesaturated(button, true);
		local reason;
		if ( classData.disableReason ) then
			if ( classData.disableReason == LE_DEMON_HUNTER_CREATION_DISABLED_REASON_HAVE_DH ) then
				reason = DEMON_HUNTER_RESTRICTED_HAS_DEMON_HUNTER;
			elseif ( classData.disableReason == LE_DEMON_HUNTER_CREATION_DISABLED_REASON_NEED_LEVEL_70 ) then
				reason = DEMON_HUNTER_RESTRICTED_NEED_LEVEL_70;
			elseif ( classData.disableReason == LE_DEMON_HUNTER_INVALID_CLASS_FOR_BOOST) then
				reason = CANNOT_CREATE_CURRENT_CLASS_WITH_BOOST;
			end
		elseif ( classData.fileName ) then
			reason = _G[classData.fileName.."_DISABLED"];
		end

		if ( reason ) then
			button.tooltip.footer = "|cffff0000".. reason .."|r";
		end

		disableTexture:Show();
	end
end

local function SetupClassButton(button, classID, classData)
	local left, right, top, bottom = unpack(CLASS_ICON_TCOORDS[classData.fileName]);

	button.NormalTexture:SetTexCoord(left, right, top, bottom);
	button.PushedTexture:SetTexCoord(left, right, top, bottom);

	button.nameFrame.text:SetText(classData.name);
	button.tooltip = CHARCREATE_CLASS_TOOLTIP[classData.fileName];
	button.classFilename = classData.fileName;
	button.classID = classID;

	UpdateClassButtonEnabledState(button, classID, classData);
end

function CharacterCreateEnumerateClasses()
	local classes = C_CharacterCreation.GetAvailableClasses();

	CharacterCreate.numClasses = #classes;

	if ( CharacterCreate.numClasses > MAX_CLASSES_PER_RACE ) then
		message("Too many classes!  Update MAX_CLASSES_PER_RACE");
		return;
	end

	local pool = CharacterCreate.classFramePool;
	pool:ReleaseAll();
	for index, classData in pairs(classes) do
		classID = classData.classID;
		local button = pool:Acquire();
		button.layoutIndex = index;
		if (classID == C_CharacterCreation.GetClassIDFromName("DEATHKNIGHT")) then
			button.layoutIndex = 99;
		end
		SetButtonDesaturated(button, false);
		button:Show();

		SetupClassButton(button, classID, classData);
	end

	if (not C_CharacterCreation.CanCreateDemonHunter()) then
        MAX_DISPLAYED_CLASSES_PER_RACE = 11;
        for button in CharacterCreate.classFramePool:EnumerateActive() do
            button:SetSize(44, 44);
        end
		local button = FindButtonForClassID(C_CharacterCreation.GetClassIDFromName("DEMONHUNTER"));
		if ( button ) then
			button:Hide();
		end
		CharCreateClassFrame.ClassIcons:Layout();
    end

	CharCreateClassFrame.ClassIcons:Layout();
end

function ResetRaceSelections()
	for frame in CharacterCreate.allianceFramePool:EnumerateActive() do
		frame:SetChecked(false);
	end
	for frame in CharacterCreate.hordeFramePool:EnumerateActive() do
		frame:SetChecked(false);
	end
	for frame in CharacterCreate.neutralFramePool:EnumerateActive() do
		frame:SetChecked(false);
	end
end

local function CanProceedThroughCharacterCreate()
	-- during a paid service we have to set alliance/horde for neutral races
	-- hard-coded for Pandaren because of alliance/horde pseudo buttons
	local name, faction = C_CharacterCreation.GetFactionForRace(CharacterCreate.selectedRace);
	local canProceed = true;
	if ( IsPandarenRace(C_CharacterCreation.GetSelectedRace()) and PAID_SERVICE_TYPE ) then
		local _, currentFaction = C_PaidServices.GetCurrentFaction();
		if ( IsPandarenRace(C_PaidServices.GetCurrentRaceID()) and PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
			-- this is an original pandaren staying or becoming selected
			-- check the pseudo-buttons
			faction = PandarenFactionButtons_GetSelectedFaction();
			if ( faction == currentFaction ) then
				canProceed = false;
			end
		end
		if (canProceed) then
			-- for faction change use the opposite faction of current character
			if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
				if ( currentFaction == "Horde" ) then
					faction = "Alliance";
				elseif ( currentFaction == "Alliance" ) then
					faction = "Horde";
				end
			-- for race change and customization use the same faction as current character
			else
				faction = currentFaction;
			end
		end
	end
	
	return canProceed, faction;
end

function SetCharacterRace(id)
	CharacterCreate.selectedRace = id;
	ResetRaceSelections();

	local frame = FindButtonForRaceID(id);
	if frame then
		frame:SetChecked(true);
	end

	local canProceed, faction = CanProceedThroughCharacterCreate();
	local raceData = C_CharacterCreation.GetRaceDataByID(id);
	local alliedRacePreview = false;
	if (raceData and raceData.isAlliedRace and not raceData.enabled) then
		alliedRacePreview = true;
	end
	CharacterCreate_SetAlliedRacePreview(alliedRacePreview);
	CharCreate_EnableNextButton(canProceed);

	if ( CharacterCreate.selectedRace ~= PANDAREN_ALLIANCE_RACE_ID and CharacterCreate.selectedRace ~= PANDAREN_HORDE_RACE_ID or not PAID_SERVICE_TYPE) then
		PandarenFactionButtons_ClearSelection();
	end
	
	-- Cache current selected faction information in the case where user is applying a trial boost
	CharacterCreate.selectedFactionID = FACTION_IDS[faction];

	-- Set background
	SetBackgroundModel(CharacterCreate, C_CharacterCreation.GetCreateBackgroundModel(faction));

	-- Set backdrop colors based on faction
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE[faction];
	CharCreateRaceFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateClassFrame.Panel.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateCustomizationFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreatePreviewFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateCustomizationFrame.BannerTop:SetVertexColor(backdropColor[10], backdropColor[11], backdropColor[12]);
	CharCreateCustomizationFrame.BannerMiddle:SetVertexColor(backdropColor[10], backdropColor[11], backdropColor[12]);
	CharCreateCustomizationFrame.BannerBottom:SetVertexColor(backdropColor[10], backdropColor[11], backdropColor[12]);
	CharacterCreateNameEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	CharCreateRaceInfoFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateClassInfoFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateCharacterTypeFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateSelectSpecFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);

	-- race info
	local frame = CharCreateRaceInfoFrame;
	local race, fileString = C_CharacterCreation.GetNameForRace(C_CharacterCreation.GetSelectedRace());
	frame.title:SetText(race);
	fileString = strupper(fileString);

	local abilityIndex = 1;
	local tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	local abilityText = "";
	while ( tempText ) do
		abilityText = abilityText..tempText.."\n\n";
		abilityIndex = abilityIndex + 1;
		tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	end
	CharCreateRaceInfoFrameScrollFrameScrollBar:SetValue(0);
	CharCreateRaceInfoFrame.scrollFrame.scrollChild.infoText:SetText(_G["RACE_INFO_"..fileString]);
	if ( abilityText and abilityText ~= "" ) then
		CharCreateRaceInfoFrame.scrollFrame.scrollChild.bulletText:SetText(abilityText);
	else
		CharCreateRaceInfoFrame.scrollFrame.scrollChild.bulletText:SetText("");
	end
	CharacterCreate_InfoTemplate_Resize(CharCreateRaceInfoFrame);

	-- Altered form
	if (C_CharacterCreation.HasAlteredForm()) then
		C_CharacterCreation.SetPortraitTexture(CharacterCreateAlternateFormTopPortrait, 22, C_CharacterCreation.GetSelectedSex());
		C_CharacterCreation.SetPortraitTexture(CharacterCreateAlternateFormBottomPortrait, 23, C_CharacterCreation.GetSelectedSex());
		CharacterCreateAlternateFormTop:Show();
		CharacterCreateAlternateFormBottom:Show();
		if( C_CharacterCreation.IsViewingAlteredForm() ) then
			CharacterCreateAlternateFormTop:SetChecked(false);
			CharacterCreateAlternateFormBottom:SetChecked(true);
		else
			CharacterCreateAlternateFormTop:SetChecked(true);
			CharacterCreateAlternateFormBottom:SetChecked(false);
		end
	else
		CharacterCreateAlternateFormTop:Hide();
		CharacterCreateAlternateFormBottom:Hide();
	end
end

function ResetClassSelections()
	for frame in CharacterCreate.classFramePool:EnumerateActive() do
		frame:SetChecked(false);
	end
end

function SetCharacterClass(id)
	CharacterCreate.selectedClass = id;
	ResetClassSelections();

	local frame = FindButtonForClassID(id);
	if frame then
		frame:SetChecked(true);
	end

	-- class info
	local frame = CharCreateClassInfoFrame;
	local scrollFrame = frame.scrollFrame.scrollChild;
	local classInfo = C_CharacterCreation.GetSelectedClass();
	frame.title:SetText(classInfo.name);

	-- hide spell icons
	for _, spellIcon in pairs(scrollFrame.Spells) do
		spellIcon:Hide();
		spellIcon.layoutIndex = nil;
	end

	-- display spell icons
	local layoutIndexCount = 2; -- bullet text is always at layout index 1
	if (#CHARCREATE_CLASS_INFO[classInfo.fileName].spells > 0) then
		scrollFrame.AbilityText:Show();
		scrollFrame.AbilityText.layoutIndex = layoutIndexCount;
		layoutIndexCount = layoutIndexCount + 1;
		for idx, spell in pairs(CHARCREATE_CLASS_INFO[classInfo.fileName].spells) do
			local spellIcon = scrollFrame.Spells[idx];
			if ( not spellIcon ) then
				spellIcon = CreateFrame("FRAME", "CharCreateClassInfoFrameSpell"..idx, scrollFrame, "CharacterCreateSpellIconTemplate");
			end
			spellIcon.tooltip = spell;
			spellIcon.layoutIndex = layoutIndexCount;
			layoutIndexCount = layoutIndexCount + 1;

			spellIcon.Icon:SetTexture(spell.texture);
			spellIcon.Text:SetText(spell.name);
			spellIcon:Show();
		end
	else
		scrollFrame.AbilityText:Hide();
	end

	scrollFrame.bulletText:SetText(CHARCREATE_CLASS_INFO[classInfo.fileName].bulletText);
	scrollFrame.infoText:SetText(CHARCREATE_CLASS_INFO[classInfo.fileName].description);
	scrollFrame.infoText.layoutIndex = layoutIndexCount;

	CharacterCreate_InfoTemplate_Resize(frame);
	CharCreateClassInfoFrameScrollFrameScrollBar:SetValue(0);

	CharacterCreate_UpdateCharacterTypeButtons();
end

function CharacterCreate_OnChar()
end

function CharacterCreate_GetValidAlliedRacePaidServiceOptions()
	local validOptions = C_CharacterCreation.GetAvailableRaces(Enum.CharacterCreateRaceMode.AlliedRace);

	local classID = C_PaidServices.GetCurrentClassID();
	local faction = C_PaidServices.GetCurrentFaction();
	local level = C_PaidServices.GetCurrentLevel();

	if (not level or level < 20) then
		return nil;
	end

	if (PAID_SERVICE_TYPE == PAID_FACTION_CHANGE) then
		validOptions = tFilter(validOptions, function(raceData) return raceData.enabled and C_CharacterCreation.IsRaceClassValid(raceData.raceID, classID) and faction ~= C_CharacterCreation.GetFactionForRace(raceData.raceID) end, true);
	elseif (PAID_SERVICE_TYPE == PAID_RACE_CHANGE) then
		validOptions = tFilter(validOptions, function(raceData) return raceData.enabled and C_CharacterCreation.IsRaceClassValid(raceData.raceID, classID) and faction == C_CharacterCreation.GetFactionForRace(raceData.raceID) end, true);
	else
		validOptions = nil;
	end

	return validOptions;
end

function CharacterCreate_UpdateAlliedRaceButton()
	local kioskModeHide = IsKioskGlueEnabled() and KioskModeSplash_GetMode() == "newcharacter";
	local shouldShow = C_CharacterCreation.ShouldShowAlliedRacesButton() and C_CharacterCreation.GetCurrentRaceMode() == Enum.CharacterCreateRaceMode.Normal and CharacterCreateFrame.state == "CLASSRACE" and not kioskModeHide;

	if (shouldShow and PAID_SERVICE_TYPE) then
		local validOptions = CharacterCreate_GetValidAlliedRacePaidServiceOptions();
		shouldShow = validOptions and #validOptions > 0;
	end

	CharCreateAlliedRacesButton:SetShown(shouldShow);
end

function CharacterCreate_OnKeyDown(self, key)
	if ( key == "ESCAPE" ) then
		CharacterCreate_Back();
	elseif ( key == "ENTER" ) then
		CharacterCreate_TryForward();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function CharacterCreate_UpdateModel(self)
	C_CharacterCreation.UpdateCustomizationScene();
end

function CharacterCreate_Finish()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CREATE_CHAR);

	if ( PAID_SERVICE_TYPE ) then
		GlueDialog_Show("CONFIRM_PAID_SERVICE");
	else
		if( IsKioskModeEnabled() ) then
			KioskModeSplash_SetAutoEnterWorld(true);
		end

		-- if using templates, pandaren must pick a faction
		local _, faction = C_CharacterCreation.GetFactionForRace(CharacterCreate.selectedRace);
		if ( ( C_CharacterCreation.IsUsingCharacterTemplate() or C_CharacterCreation.IsForcingCharacterTemplate() ) and ( faction ~= "Alliance" and faction ~= "Horde" ) ) then
			CharacterTemplateConfirmDialog:Show();
		else
			C_CharacterCreation.CreateCharacter(CharacterCreateNameEdit:GetText());
		end
	end
end

function CharacterCreate_Back()
	if ( CharacterCreateFrame.state == "CUSTOMIZATION" ) then
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CANCEL);
		CharacterCreateFrame.state = "CLASSRACE"
		CharCreateClassFrame:Show();
		CharCreateRaceFrame:Show();
		CharCreateMoreInfoButton:Show();
		CharCreateCustomizationFrame:Hide();
		CharCreatePreviewFrame:Hide();
		CharacterCreateNameEdit:Hide();
		CharacterCreateRandomName:Hide();

		CharacterCreate_UpdateAlliedRaceButton();
		CharacterCreate_UpdateClassTrialCustomizationFrames();

		--back to awesome gear
		C_CharacterCreation.SetSelectedPreviewGearType(Enum.PreviewGearType.Awesome);

		-- back to normal camera
		C_CharacterCreation.SetFaceCustomizeCamera(false);
	elseif (C_CharacterCreation.GetCurrentRaceMode() == Enum.CharacterCreateRaceMode.AlliedRace and (not PAID_SERVICE_TYPE or PAID_SERVICE_TYPE ~= PAID_CHARACTER_CUSTOMIZATION)) then
		C_CharacterCreation.SetCurrentRaceMode(Enum.CharacterCreateRaceMode.Normal);
		CharacterCreate_UpdateAlliedRaceButton();	
		CharCreateRaceButtonsFrame.ClassicBanners:Show();
		CharCreateRaceButtonsFrame.AlliedRaceBanners:Hide();
		CharacterCreateEnumerateRaces(true);
	else
		if( IsKioskGlueEnabled() ) then
			PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CANCEL);
			GlueParent_SetScreen("kioskmodesplash");
		else
			if CharacterUpgrade_IsCreatedCharacterTrialBoost() then
				CharacterUpgrade_ResetBoostData();
			end

			PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CANCEL);
			CHARACTER_SELECT_BACK_FROM_CREATE = true;
			GlueParent_SetScreen("charselect");
		end
	end
	CharCreate_RefreshNextButton();
end

function CharacterCreate_TryForward()
	-- TODO: Add feedback/error popup if this can't proceed?
	if CharCreateOkayButton:IsEnabled() then
		CharacterCreate_Forward();
	end
end

function CharacterCreate_Forward()
	if ( CharacterCreateFrame.state == "CLASSRACE" ) then
		CharacterCreateFrame.state = "CUSTOMIZATION"
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
		CharCreateClassFrame:Hide();
		CharCreateRaceFrame:Hide();
		CharCreateMoreInfoButton:Hide();
		CharCreateCustomizationFrame:Show();
		CharCreatePreviewFrame:Show();
		CharacterTemplateConfirmDialog:Hide();
		
		CharacterCreate_UpdateAlliedRaceButton();
		CharacterCreate_UpdateClassTrialCustomizationFrames();

		CharCreate_PrepPreviewModels();

		--You just went to customization mode - show the boring start gear
		C_CharacterCreation.SetSelectedPreviewGearType(Enum.PreviewGearType.Starting);

		if ( CharacterCreateFrame.customizationType ) then
			CharCreate_ResetFeaturesDisplay();
		else
			CharCreateSelectCustomizationType(1);
		end

		CharCreateOkayButton:SetText(FINISH);
		CharacterCreateNameEdit:Show();
		if ( ALLOW_RANDOM_NAME_BUTTON and not CharacterCreate_IsAlliedRacePreview() ) then
			CharacterCreateRandomName:Show();
		end

		-- set cam
		if (CharacterCreateFrame.customizationType and CharacterCreateFrame.customizationType > 1) then
			C_CharacterCreation.SetFaceCustomizeCamera(true);
		else
			C_CharacterCreation.SetFaceCustomizeCamera(false);
		end
	else
		CharacterCreate_Finish();
		CharCreate_EnableNextButton(false);
	end
end

function CharCreateCustomizationFrame_UpdateButtons ()
	-- check each button and hide it if there are no values select
	local numButtons = 0;
	local lastGood = 0;
	local isSkinVariantHair = C_CharacterCreation.GetSkinVariationIsHairColor(CharacterCreate.selectedRace);
	local isDefaultSet = false;
	local checkedButton = 1;

	-- check if this was set, if not, default to 1
	if ( CharacterCreateFrame.customizationType == 0 or CharacterCreateFrame.customizationType == nil ) then
		CharacterCreateFrame.customizationType = 1;
	end
	for i=Enum.CharCustomizeMeta.MinValue, Enum.CharCustomizeMeta.MaxValue do
		local frameIndex = i+1;
		-- note the code relies on button 1 (skin color) being shown, forcing it to show for work in progress races
		if ( ( (i ~= Enum.CharCustomize.Skin) and (C_CharacterCreation.GetNumFeatureVariations(i) <= 1) ) or ( isSkinVariantHair and i == Enum.CharCustomize.HairColor ) ) then
			_G["CharCreateCustomizationButton"..frameIndex]:Hide();
		else
			_G["CharCreateCustomizationButton"..frameIndex]:Show();
			_G["CharCreateCustomizationButton"..frameIndex]:SetChecked(false); -- we will handle default selection
			-- this must be done since a selected button can 'disappear' when swapping genders
			if ( not isDefaultSet and CharacterCreateFrame.customizationType == frameIndex) then
				isDefaultSet = true;
				checkedButton = frameIndex;
			end
            -- set your anchor to be the last good, this currently means button 1 (skin color) HAS to be shown
            if (i > Enum.CharCustomize.Skin) then
                -- Hack for Demon Hunter tattoo colors
                if (i == Enum.CharCustomize.CustomOptionTattooColor) then
					-- 6 is tattoos, 7 is horn style, 9 is tattoo color
                    CharCreateCustomizationButton9:SetPoint("TOP", CharCreateCustomizationButton6, "BOTTOM");
                    CharCreateCustomizationButton7:SetPoint("TOP", CharCreateCustomizationButton9, "BOTTOM");
                else
					_G["CharCreateCustomizationButton"..frameIndex]:SetPoint( "TOP",_G["CharCreateCustomizationButton"..lastGood]:GetName() , "BOTTOM");
                end
			end
            if (i ~= Enum.CharCustomize.CustomOptionTattooColor) then
    			lastGood = frameIndex;
            end
			numButtons = numButtons + 1;
		end
	end


	if (not isDefaultSet) then
		CharacterCreateFrame.customizationType = 1;
		checkedButton = 1;
	end

	local lastGoodButtonName = "CharCreateCustomizationButton"..lastGood;
	local lastGoodButton = _G[lastGoodButtonName];

	_G["CharCreateCustomizationButton"..checkedButton]:SetChecked(true);

	-- Set banner height depending on number of buttons to accomodate male Pandaren and demon hunter
	local buttonHeight = CharCreateCustomizationButton1:GetHeight();
	CharCreateCustomizationFrame.BannerMiddle:SetHeight(10 + (numButtons - 1) * buttonHeight);

	if (lastGoodButton) then
		CharCreateRandomizeButton:SetPoint("TOP", lastGoodButton:GetName(), "BOTTOM", 0, 0);
	end
end

local AdvancedCharacterCreationWarningStrings = {
	[6]	= ADVANCED_CHARACTER_CREATION_WARNING_DIALOG_TEXT_DEATHKNIGHT,
	[12] = ADVANCED_CHARACTER_CREATION_WARNING_DIALOG_TEXT_DEMONHUNTER,
	GenericWarning = ADVANCED_CHARACTER_CREATION_WARNING_DIALOG_TEXT_GENERIC,
};

local function ShowAdvancedCharacterCreationWarning(classButton)
	local warningText = AdvancedCharacterCreationWarningStrings[classButton.classID] or AdvancedCharacterCreationWarningStrings.GenericWarning;
	GlueDialog_Show("ADVANCED_CHARACTER_CREATION_WARNING", warningText, classButton);
end

function CharacterClass_SelectClass(self, forceAccept)
	if( self:IsEnabled() ) then
		if (IsKioskGlueEnabled()) then
			KioskModeCheckHighLevel(self.classID);
		end

		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
		local currClassInfo = C_CharacterCreation.GetSelectedClass();
		local id = self.classID;
		if ( currClassInfo.classID ~= id ) then
			if (C_CharacterCreation.IsAdvancedClass(id) and not (C_CharacterCreation.HasSufficientExperienceForAdvancedCreation() or forceAccept)) then
				ShowAdvancedCharacterCreationWarning(self);
				self:SetChecked(false);
				return;
			end

			C_CharacterCreation.SetSelectedClass(id);
			SetCharacterClass(id);
			SetCharacterRace(C_CharacterCreation.GetSelectedRace());
			CharacterChangeFixup();
			local demonHunterID = C_CharacterCreation.GetClassIDFromName("DEMONHUNTER");
			if (currClass == demonHunterID or id == demonHunterID) then
				C_CharacterCreation.RandomizeCharCustomization(true);
			end
		else
			self:SetChecked(true);
		end
	else
		self:SetChecked(false);
	end
	if ( CharCreateMoreInfoButton.infoShown ) then
		CharacterCreateTooltip:Hide();
	end
end

function CharacterClass_OnClick(self)
	CharacterClass_SelectClass(self, IsKioskModeEnabled());
end

function CharCreateSelectRace(id, forceSelect)
	if ( C_CharacterCreation.GetSelectedRace() ~= id or forceSelect ) then
		C_CharacterCreation.SetSelectedRace(id);
		SetCharacterRace(id);
		SetCharacterGender(C_CharacterCreation.GetSelectedSex());
		C_CharacterCreation.SetCharacterCreateFacing(-15);
		CharacterCreateEnumerateClasses();
		if (IsKioskGlueEnabled()) then
			local kioskModeData = KioskModeSplash_GetModeData();
			local available = {};
			for k, v in pairs(kioskModeData.classes) do
				if (v) then
					local cid = KioskModeSplash_GetIDForSelection("classes", k);
					if (C_CharacterCreation.IsClassAllowedInKioskMode(cid) and C_CharacterCreation.IsRaceClassValid(id, cid)) then
						tinsert(available, k);
					end
				end
			end

			local fcid = KioskModeSplash_GetIDForSelection("classes", available[math.random(1, #available)]);
			KioskModeCheckHighLevel(fcid);
			C_CharacterCreation.SetSelectedClass(fcid);
			SetCharacterClass(fcid);
			SetCharacterRace(C_CharacterCreation.GetSelectedRace());
		else
			local classInfo = C_CharacterCreation.GetSelectedClass();
			local classID = classInfo.classID;
			if ( PAID_SERVICE_TYPE ) then
				classID = C_PaidServices.GetCurrentClassID();
				C_CharacterCreation.SetSelectedClass(classID);	-- selecting a race would have changed class to default
			end
			SetCharacterClass(classID);
		end

		-- Hair customization stuff
		CharacterCreate_UpdateCustomizationOptions();

		CharacterChangeFixup();

		return true;
	end

	return false;
end

function CharacterRace_OnClick(self, id, forceSelect)
	if( self:IsEnabled() ) then
		PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
		if (not CharCreateSelectRace(id, forceSelect)) then
			self:SetChecked(true);
		end
	else
		self:SetChecked(false);
	end
end

function CharCreateAlliedRacesButton_OnClick(self)
	local raceMode = C_CharacterCreation.GetCurrentRaceMode();
	C_CharacterCreation.SetCurrentRaceMode(Enum.CharacterCreateRaceMode.AlliedRace);
	CharCreateRaceButtonsFrame.ClassicBanners:Hide();
	CharCreateRaceButtonsFrame.AlliedRaceBanners:Show();
	self:Hide();
	CharacterCreateEnumerateRaces(true);
end

local currentGender;

function SetCharacterGender(sex)
	if sex == currentGender then
		return;
	end

	currentGender = sex;

	local gender;
	C_CharacterCreation.SetSelectedSex(sex);
	if ( sex == Enum.Unitsex.Male ) then
		CharCreateMaleButton:SetChecked(true);
		CharCreateFemaleButton:SetChecked(false);
	else
		CharCreateMaleButton:SetChecked(false);
		CharCreateFemaleButton:SetChecked(true);
	end

	-- Update race images to reflect gender
	CharacterCreateEnumerateRaces();
	CharacterCreateEnumerateClasses();
 	SetCharacterRace(C_CharacterCreation.GetSelectedRace());

	local classInfo = C_CharacterCreation.GetSelectedClass();
	local classID = classInfo.classID;
	if ( PAID_SERVICE_TYPE ) then
		classID = C_PaidServices.GetCurrentClassID();
		PandarenFactionButtons_SetTextures();
	end
	SetCharacterClass(classID);

	CharacterCreate_UpdateCustomizationOptions();
	CharacterChangeFixup();

	-- Update preview models if on customization step
	if ( CharCreatePreviewFrame:IsShown() ) then
		CharCreateCustomizationFrame_UpdateButtons(); -- buttons may need to reset for dirty Pandarens
		CharCreate_PrepPreviewModels();
		CharCreate_ResetFeaturesDisplay();
	end

	CharacterCreate_UpdateClassTrialCustomizationFrames();
end

function CharacterCustomization_Left(id)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	CycleCharCustomization(id, -1);
end

function CharacterCustomization_Right(id)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	CycleCharCustomization(id, 1);
end

function CharacterCreate_GenerateRandomName(button)
	button:Disable();
	CharacterCreateNameEdit:SetText("...");
	C_CharacterCreation.RequestRandomName();
end

function CharacterCreate_Randomize()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	C_CharacterCreation.RandomizeCharCustomization();
	CharCreate_ResetFeaturesDisplay();
end

function CharacterCreateRotateRight_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + CHARACTER_FACING_INCREMENT);
		CharCreate_RotatePreviews();
	end
end

function CharacterCreateRotateLeft_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() - CHARACTER_FACING_INCREMENT);
		CharCreate_RotatePreviews();
	end
end

function CharacterCreate_UpdateCustomizationOptions()
	for i=Enum.CharCustomizeMeta.MinValue, Enum.CharCustomizeMeta.MaxValue do
		_G["CharCreateCustomizationButton"..(i+1)].text:SetText(C_CharacterCreation.GetCustomizationDetails(i));
	end
end

function KioskModeCheckHighLevel(classID)
	if (IsKioskGlueEnabled()) then
		local kioskModeData = KioskModeSplash_GetModeData();
		if (not kioskModeData) then -- why?
			return;
		end
		CharacterUpgrade_ResetBoostData();
		C_CharacterCreation.ClearCharacterTemplate();
		if (kioskModeData.trial) then
			local useTrial = nil;
			if (kioskModeData.trial.enabled) then
				useTrial = true;
				for i, classFilename in ipairs(kioskModeData.trial.ignoreClasses) do
					local id = C_CharacterCreation.GetClassIDFromName(classFilename);
					if (id == classID) then
						useTrial = nil;
						break;
					end
				end
			end
			if (useTrial) then
				CharacterUpgrade_BeginNewCharacterCreation(Enum.CharacterCreateType.TrialBoost);
			else
				CharacterUpgrade_ResetBoostData();
			end
		elseif (kioskModeData.template) then
			local useTemplate = nil;
			if (kioskModeData.template.enabled) then
				useTemplate = kioskModeData.template.index;
				for i, classFilename in ipairs(kioskModeData.template.ignoreClasses) do
					local id = C_CharacterCreation.GetClassIDFromName(classFilename);
					if (id == classID) then
						useTemplate = nil;
						break;
					end
				end
			end
			if (useTemplate) then
				C_CharacterCreation.SetCharacterTemplate(useTemplate);
			else
				C_CharacterCreation.ClearCharacterTemplate();
			end
		end
	end
end

function SetButtonDesaturated(button, desaturated)
	if ( not button ) then
		return;
	end
	local icon = button:GetNormalTexture();
	if ( icon ) then
		icon:SetDesaturated(desaturated);
	end

	-- Allied races in preview are "enabled"
	local pushed = button:GetPushedTexture();
	if ( pushed ) then
		pushed:SetDesaturated(desaturated);
	end
end

local function CharacterChangeFixupRaceHelper(button)
	local allow = false;
	local id = button.raceID;
	local classID = C_PaidServices.GetCurrentClassID();
	if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
		local faction = C_PaidServices.GetCurrentFaction();
		if ( (id == C_PaidServices.GetCurrentRaceID()) or ((C_CharacterCreation.GetFactionForRace(id) ~= faction) and (C_CharacterCreation.IsRaceClassValid(id,classID))) ) then
			allow = true;
		end
	elseif ( PAID_SERVICE_TYPE == PAID_RACE_CHANGE ) then
		local faction = C_PaidServices.GetCurrentFaction();
		if ( (id == C_PaidServices.GetCurrentRaceID()) or ((C_CharacterCreation.GetFactionForRace(id) == faction or C_CharacterCreation.IsNeutralRace(id)) and (C_CharacterCreation.IsRaceClassValid(id,classID))) ) then
			allow = true
		end
	elseif ( PAID_SERVICE_TYPE == PAID_CHARACTER_CUSTOMIZATION ) then
		if ( id == CharacterCreate.selectedRace ) then
			allow = true
		end
	end
	if (not allow) then
		button:Disable();
		SetButtonDesaturated(button, true);
	else
		button:Enable();
		SetButtonDesaturated(button, false);
	end
	return allow;
end

local function FixupPool(pool)
	local numAllowedRaces = 0;
	for button in pool:EnumerateActive() do
		local allowed = CharacterChangeFixupRaceHelper(button);
		if (allowed) then
			numAllowedRaces = numAllowedRaces + 1;
		end
	end
	return numAllowedRaces;
end

local function FixupClasses()
	local classData = C_CharacterCreation.GetSelectedClass();
	for button in CharacterCreate.classFramePool:EnumerateActive() do
		if (button.classID ~= classData.classID) then
			button:Disable();
			SetButtonDesaturated(button, true);
		end
	end
end

function CharacterChangeFixup()
	if ( PAID_SERVICE_TYPE ) then
		-- no class changing as a paid service
		CharCreateClassFrame:SetAlpha(0.5);
		
		FixupClasses();

		local numAllowedRaces = FixupPool(CharacterCreate.allianceFramePool) + FixupPool(CharacterCreate.hordeFramePool) + FixupPool(CharacterCreate.neutralFramePool);
		
		if ( numAllowedRaces > 0 ) then
			CharCreateRaceButtonsFrame:SetAlpha(1);
		else
			CharCreateRaceButtonsFrame:SetAlpha(0.5);
		end
	else
		CharCreateRaceButtonsFrame:SetAlpha(1);
		CharCreateClassFrame:SetAlpha(1);
	end
end

function CharCreateSelectCustomizationType(newType)
	-- deselect previous type selection
	if ( CharacterCreateFrame.customizationType and CharacterCreateFrame.customizationType ~= newType ) then
		_G["CharCreateCustomizationButton"..CharacterCreateFrame.customizationType]:SetChecked(false);
	end
	_G["CharCreateCustomizationButton"..newType]:SetChecked(true);
	CharacterCreateFrame.customizationType = newType;
	CharCreate_ResetFeaturesDisplay();

	-- Use face camera for everything except Skin Color and Tattoos
	-- DWNOTE: tattoos are mostly upper body so it actually seems better zoomed in
	if (newType > 1) then --  and newType ~= 5) then
		C_CharacterCreation.SetFaceCustomizeCamera(true);
	else
		C_CharacterCreation.SetFaceCustomizeCamera(false);
	end
end

function CharCreate_ResetFeaturesDisplay()
	C_CharacterCreation.SetPreviewFramesFeature(CharacterCreateFrame.customizationType);
	-- set the previews scrollframe container height
	-- since the first and the last previews need to be in the center position when scrolled all the way
	-- to the top or to the bottom, there will be gaps of height equal to 2 previews on each side
	local numTotalButtons = C_CharacterCreation.GetNumFeatureVariations() + 4;
	CharCreatePreviewFrame.scrollFrame.container:SetHeight(numTotalButtons * PREVIEW_FRAME_HEIGHT - PREVIEW_FRAME_Y_OFFSET);

	for _, previewFrame in pairs(CharCreatePreviewFrame.previews) do
		previewFrame.featureType = 0;
	end

	CharCreate_DisplayPreviewModels();
end

function CharCreate_PrepPreviewModels(reloadModels)
	local displayFrame = CharCreatePreviewFrame;

	-- clear models if rebuildPreviews got flagged
	local rebuildPreviews = displayFrame.rebuildPreviews;
	displayFrame.rebuildPreviews = nil;

	-- need to reload models class was swapped to or from DK
	local classInfo = C_CharacterCreation.GetSelectedClass();
	if ( classInfo.fileName == "DEATHKNIGHT" or displayFrame.lastClassID == C_CharacterCreation.GetClassIDFromName("DEATHKNIGHT") ) and ( classInfo.classID ~= displayFrame.lastClassID ) then
		reloadModels = true;
	end
	displayFrame.lastClassID = classInfo.classID;

	-- always clear the featureType
	for index, previewFrame in pairs(displayFrame.previews) do
		previewFrame.featureType = 0;
		-- force model reload in some cases
		if ( reloadModels or rebuildPreviews ) then
			previewFrame.race = nil;
			previewFrame.gender = nil;
		end
		if ( rebuildPreviews ) then
			C_CharacterCreation.SetPreviewFrame(previewFrame.model:GetName(), index);
		end
	end
end

function CharCreate_DisplayPreviewModels(selectionIndex)
	if ( not selectionIndex ) then
		selectionIndex = C_CharacterCreation.GetSelectedFeatureVariation();
	end

	local displayFrame = CharCreatePreviewFrame;
	local previews = displayFrame.previews;
	local numVariations = C_CharacterCreation.GetNumFeatureVariations();
	local currentFeatureType = CharacterCreateFrame.customizationType;

	local race = C_CharacterCreation.GetSelectedRace();
	local gender = C_CharacterCreation.GetSelectedSex();

	-- HACK: Worgen fix for portrait camera position
	local cameraID = 0;
	if ( race == WORGEN_RACE_ID and gender == Enum.Unitsex.Male and not C_CharacterCreation.IsViewingAlteredForm() ) then
		cameraID = 1;
	end

	-- get data for target/camera/light
	local _, raceFileName = C_CharacterCreation.GetNameForRace(C_CharacterCreation.GetSelectedRace());
	if ( C_CharacterCreation.IsViewingAlteredForm() ) then
		raceFileName = raceFileName.."Alt";
	end

	local config = MODEL_CAMERA_CONFIG[gender][raceFileName..currentFeatureType];
	if (not config) then
		config = MODEL_CAMERA_CONFIG[gender][raceFileName];
	end

	-- selection index is the center preview
	-- there are 2 previews above and 2 below, and will pad it out to 1 more on each side, for a total of 7 previews to set up
	for index = selectionIndex - 3, selectionIndex + 3 do
		-- there is empty space both at the beginning and at end of the list, each gap the height of 2 previews
		if ( index > 0 and index <= numVariations ) then
			local previewFrame = previews[index];
			-- create button if we don't have it yet
			if ( not previewFrame ) then
				previewFrame = CreateFrame("FRAME", "PreviewFrame"..index, displayFrame.scrollFrame.container, "CharCreatePreviewFrameTemplate");
				-- index + 1 because of 2 gaps at the top and -1 for the current preview
				previewFrame:SetPoint("TOPLEFT", PREVIEW_FRAME_X_OFFSET, (index + 1) * -PREVIEW_FRAME_HEIGHT + PREVIEW_FRAME_Y_OFFSET);
				previewFrame.button.index = index;
				previews[index] = previewFrame;
				C_CharacterCreation.SetPreviewFrame(previewFrame.model:GetName(), index);
			end
			-- load model if needed, may have been cleared by different race/gender selection
			if ( previewFrame.race ~= race or previewFrame.gender ~= gender or previewFrame.currentCamera ~= config) then
				C_CharacterCreation.UpdatePreviewFrameModel(index);
				previewFrame.race = race;
				previewFrame.gender = gender;
				previewFrame.currentCamera = config;
				-- apply settings
				local model = previewFrame.model;
				model:SetCustomCamera(cameraID);
				local scale = model:GetWorldScale();
				model:SetCameraTarget(config.tx * scale, config.ty * scale, config.tz * scale);
				model:SetCameraDistance(config.distance * scale);
				local cx, cy, cz = model:GetCameraPosition();
				model:SetCameraPosition(cx, cy, config.cz * scale);
				model:SetLight(true, false, 0, 0, 0, config.light, 1.0, 1.0, 1.0);
			end
			if ( previewFrame.featureType ~= currentFeatureType ) then
				C_CharacterCreation.UpdatePreviewFrameModel(index);
				previewFrame.featureType = currentFeatureType;
			end
			previewFrame:Show();
		else
			-- need to hide tail previews when going to features with fewer styles
			if ( previews[index] ) then
				previews[index]:Hide();
			end
		end
	end
	displayFrame.border.number:SetText(selectionIndex);
	displayFrame.selectionIndex = selectionIndex;
	CharCreate_RotatePreviews();
	CharCreatePreviewFrame_UpdateStyleButtons();
	-- scroll to center the selection
	if ( not displayFrame.animating ) then
		displayFrame.scrollFrame:SetVerticalScroll((selectionIndex - 1) * PREVIEW_FRAME_HEIGHT);
	end
end


function CharCreate_RotatePreviews()
	if ( CharCreatePreviewFrame:IsShown() ) then
		local facing = ((C_CharacterCreation.GetCharacterCreateFacing())/ -180) * math.pi;
		local previews = CharCreatePreviewFrame.previews;
		for index = CharCreatePreviewFrame.selectionIndex - 3, CharCreatePreviewFrame.selectionIndex + 3 do
			local previewFrame = previews[index];
			if ( previewFrame and previewFrame.model:HasCustomCamera() ) then
				previewFrame.model:SetCameraFacing(facing);
			end
		end
	end
end

function CharCreate_ChangeFeatureVariation(delta)
	local numVariations = C_CharacterCreation.GetNumFeatureVariations();
	local startIndex = C_CharacterCreation.GetSelectedFeatureVariation();
	local endIndex = startIndex + delta;
	if ( endIndex < 1 or endIndex > numVariations ) then
		return;
	end
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	CharCreatePreviewFrame_SelectFeatureVariation(endIndex);
end

function CharCreatePreviewFrameButton_OnClick(self)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	CharCreatePreviewFrame_SelectFeatureVariation(self.index);
end

function CharCreatePreviewFrame_SelectFeatureVariation(endIndex)
	local self = CharCreatePreviewFrame;
	if ( self.animating ) then
		if ( not self.queuedIndex ) then
			self.queuedIndex = endIndex;
		end
	else
		local startIndex = C_CharacterCreation.GetSelectedFeatureVariation();
		C_CharacterCreation.SelectFeatureVariation(endIndex);
		CharCreatePreviewFrame_UpdateStyleButtons();
		CharCreatePreviewFrame_StartAnimating(startIndex, endIndex);
        CharCreateCustomizationFrame_UpdateButtons(); -- Demon Hunters may need updated buttons
	end
end

function CharCreatePreviewFrame_StartAnimating(startIndex, endIndex)
	local self = CharCreatePreviewFrame;
	if ( self.animating ) then
		return;
	else
		self.startIndex = startIndex;
		self.currentIndex = startIndex;
		self.endIndex = endIndex;
		self.queuedIndex = nil;
		self.direction = 1;
		if ( self.startIndex > self.endIndex ) then
			self.direction = -1;
		end
		self.movedTotal = 0;
		self.moveUntilUpdate = PREVIEW_FRAME_HEIGHT;
		self.animating = true;
	end
end

function CharCreatePreviewFrame_StopAnimating()
	local self = CharCreatePreviewFrame;
	if ( self.animating ) then
		self.animating = false;
	end
end

local ANIMATION_SPEED = 5;
function CharCreatePreviewFrame_OnUpdate(self, elapsed)
	if ( self.animating ) then
		local moveIncrement = PREVIEW_FRAME_HEIGHT * elapsed * ANIMATION_SPEED;
		self.movedTotal = self.movedTotal + moveIncrement;
		self.scrollFrame:SetVerticalScroll((self.startIndex - 1) * PREVIEW_FRAME_HEIGHT + self.movedTotal * self.direction);
		self.moveUntilUpdate = self.moveUntilUpdate - moveIncrement;
		if ( self.moveUntilUpdate <= 0 ) then
			self.currentIndex = self.currentIndex + self.direction;
			self.moveUntilUpdate = PREVIEW_FRAME_HEIGHT;
			-- reset movedTotal to account for rounding errors
			self.movedTotal = abs(self.startIndex - self.currentIndex) * PREVIEW_FRAME_HEIGHT;
			CharCreate_DisplayPreviewModels(self.currentIndex);
		end
		if ( self.currentIndex == self.endIndex ) then
			self.animating = false;
			CharCreate_DisplayPreviewModels();
			if ( self.queuedIndex ) then
				local newIndex = self.queuedIndex;
				self.queuedIndex = nil;
				C_CharacterCreation.SelectFeatureVariation(newIndex);
				CharCreatePreviewFrame_UpdateStyleButtons();
				CharCreatePreviewFrame_StartAnimating(self.endIndex, newIndex);
                CharCreateCustomizationFrame_UpdateButtons(); -- Demon Hunters may need updated buttons
			end
		end
	end
end

function CharCreatePreviewFrame_UpdateStyleButtons()
	local selectionIndex = C_CharacterCreation.GetSelectedFeatureVariation();
	local numVariations = C_CharacterCreation.GetNumFeatureVariations();
	if ( selectionIndex == 1 ) then
		CharCreateStyleUpButton:SetEnabled(false);
		CharCreateStyleUpButton.arrow:SetDesaturated(true);
	else
		CharCreateStyleUpButton:SetEnabled(true);
		CharCreateStyleUpButton.arrow:SetDesaturated(false);
	end
	if ( selectionIndex == numVariations ) then
		CharCreateStyleDownButton:SetEnabled(false);
		CharCreateStyleDownButton.arrow:SetDesaturated(true);
	else
		CharCreateStyleDownButton:SetEnabled(true);
		CharCreateStyleDownButton.arrow:SetDesaturated(false);
	end
end

local TotalTime = 0;
local KeepScrolling = nil;
local TIME_TO_SCROLL = 0.5;
function CharacterCreateWhileMouseDown_OnMouseDown(direction)
	TIME_TO_SCROLL = 0.5;
	TotalTime = 0;
	KeepScrolling = direction;
end
function CharacterCreateWhileMouseDown_OnMouseUp()
	KeepScrolling = nil;
end
function CharacterCreateWhileMouseDown_Update(elapsed)
	if ( KeepScrolling ) then
		TotalTime = TotalTime + elapsed;
		if ( TotalTime >= TIME_TO_SCROLL ) then
			CharCreate_ChangeFeatureVariation(KeepScrolling);
			TIME_TO_SCROLL = 0.25;
			TotalTime = 0;
		end
	end
end

-- Updates the "forward" button based on various creation states.
function CharCreate_EnableNextButton(enabled)
	local button = CharCreateOkayButton;
	button:SetEnabled(enabled);
	button.Arrow:SetDesaturated(not enabled);
	button.TopGlow:SetShown(enabled);
	button.BottomGlow:SetShown(enabled);
	if (CharacterCreateFrame.state == "CUSTOMIZATION") then
		button:SetText(FINISH);
	elseif (CharacterCreate_IsAlliedRacePreview()) then
		button:SetText(PREVIEW);
	elseif (enabled) then
		button:SetText(CUSTOMIZE);
	end
end

function CharCreate_RefreshNextButton()
	CharCreate_EnableNextButton(CanProceedThroughCharacterCreate());
end

function IsPandarenRace(raceID)
	return raceID == PANDAREN_RACE_ID or raceID == PANDAREN_ALLIANCE_RACE_ID or raceID == PANDAREN_HORDE_RACE_ID;
end

function PandarenFactionButtons_Show()
	local frame = CharCreatePandarenFactionFrame;
	-- set the name
	local raceName = C_CharacterCreation.GetNameForRace(PANDAREN_RACE_ID);
	
	--Set up the alliance button for faction change specific change. 
	local allianceButton = CharCreateRaceButtonsFrame.AllianceRaces.Pandaren;
	allianceButton.raceID = PANDAREN_ALLIANCE_RACE_ID;
	allianceButton.nameFrame.text:SetText(raceName);
	allianceButton.tooltip = raceName;
	allianceButton:Enable();
	SetButtonDesaturated(allianceButton, false);
	allianceButton:Show();
	
	--Set up the horde button for faction change specific change. 
	local hordeButton = CharCreateRaceButtonsFrame.HordeRaces.Pandaren;
	hordeButton.nameFrame.text:SetText(raceName);
	hordeButton.tooltip = raceName;
	hordeButton:Enable();
	SetButtonDesaturated(hordeButton, false);
	hordeButton.raceID = PANDAREN_HORDE_RACE_ID;
	hordeButton:Show();
	
	-- set the texture
	PandarenFactionButtons_SetTextures();
	-- set selected button
	local _, faction = C_PaidServices.GetCurrentFaction();
	
	if (faction == "Alliance") then
		allianceButton:Disable();
		SetButtonDesaturated(allianceButton, true);
	else
		hordeButton:Disable();
		SetButtonDesaturated(hordeButton, true);
	end

	local raceID = C_PaidServices.GetCurrentRaceID();
	
	if (not IsPandarenRace(raceID)) then
		if (faction == "Alliance") then
			allianceButton:Disable();
			SetButtonDesaturated(allianceButton, true);
		else
			hordeButton:Disable();
			SetButtonDesaturated(hordeButton, true);
		end
	else
		-- deselect first in case of multiple pandaren faction changes
		PandarenFactionButtons_ClearSelection();
		if (faction == "Alliance") then
			allianceButton:SetChecked(true);
		else
			hordeButton:SetChecked(true);
		end
	end
	frame:Show();
	frame:SetFrameLevel(CharCreateRaceButtonsFrame.AllianceRaces.Pandaren:GetFrameLevel() - 2);
	CharCreateRaceButtonsFrame.NeutralRaces:Hide();
	CharCreateRaceButtonsFrame.AllianceRaces:Layout();
	CharCreateRaceButtonsFrame.HordeRaces:Layout();
	CharCreate_EnableNextButton(false);
end

function PandarenFactionButtons_Hide()
	CharCreatePandarenFactionFrame:Hide();
	local allianceButton = CharCreateRaceButtonsFrame.AllianceRaces.Pandaren;
	local hordeButton = CharCreateRaceButtonsFrame.HordeRaces.Pandaren;
	allianceButton:Hide();
	hordeButton:Hide();
	CharCreateRaceButtonsFrame.NeutralRaces:Show();
	CharCreateRaceButtonsFrame.AllianceRaces:Layout();
	CharCreateRaceButtonsFrame.HordeRaces:Layout();
	CharCreate_EnableNextButton(true);
end

function PandarenFactionButtons_SetTextures()
	local gender;
	if ( C_CharacterCreation.GetSelectedSex() == Enum.Unitsex.Male ) then
		gender = "male";
	else
		gender = "female";
	end
	local allianceButton = CharCreateRaceButtonsFrame.AllianceRaces.Pandaren;
	local hordeButton = CharCreateRaceButtonsFrame.HordeRaces.Pandaren;
	local atlas = GetRaceAtlas("pandaren", gender);
	allianceButton.NormalTexture:SetAtlas(atlas);
	allianceButton.PushedTexture:SetAtlas(atlas);
	hordeButton.NormalTexture:SetAtlas(atlas);
	hordeButton.PushedTexture:SetAtlas(atlas);
end

function PandarenFactionButtons_ClearSelection()
	local allianceButton = CharCreateRaceButtonsFrame.AllianceRaces.Pandaren;
	local hordeButton = CharCreateRaceButtonsFrame.HordeRaces.Pandaren;
	allianceButton:SetChecked(false);
	hordeButton:SetChecked(false);
end

function PandarenFactionButtons_GetSelectedFaction()
	if ( CharCreateRaceButtonsFrame.AllianceRaces.Pandaren:GetChecked() ) then
		return "Alliance";
	elseif ( CharCreateRaceButtonsFrame.HordeRaces.Pandaren:GetChecked() ) then
		return "Horde";
	end
end

function PandarenFactionButton_OnClick(self)
	PandarenFactionButtons_ClearSelection();
	self:SetChecked(true);
	CharacterRace_OnClick(self, self.raceID, true);
end

---------------------------------------------
-- CharCreateRaceButton script functions
---------------------------------------------
function CharCreateRaceButton_OnEnter(self)
	local raceData = C_CharacterCreation.GetRaceDataByID(self.raceID);
	CharacterCreateTooltip:SetOwner(self, "ANCHOR_RIGHT", 8, -5);
	CharacterCreateTooltip:SetText(raceData.name, 1, 1, 1, 1, true);
	if (raceData.isAlliedRace) then
		local hasExpansion, hasAchievement = C_CharacterCreation.GetAlliedRaceCreationRequirements(self.raceID);
		if (not hasExpansion) then
			CharacterCreateTooltip:AddLine(CHARACTER_CREATION_REQUIREMENTS_NEED_8_0, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1, true);
		end
		if (not hasAchievement) then
			CharacterCreateTooltip:AddLine(CHARACTER_CREATION_REQUIREMENTS_NEED_ACHIEVEMENT, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1, true);
		end	
	end
end

function CharCreateRaceButton_OnLeave(self)
	CharacterCreateTooltip:Hide();
end

---------------------------------------------
-- CharCreateClassButton script functions
---------------------------------------------
function CharCreateClassButton_OnEnter(self)
	if CharCreateMoreInfoButton.infoShown and self:GetChecked() then
		return;
	end

	CharacterCreateTooltip:SetOwner(self, "ANCHOR_LEFT", -8, -5);
	CharacterCreateTooltip:SetText(self.tooltip.name, 1, 1, 1, 1, true);
	CharacterCreateTooltip:AddLine(self.tooltip.roles, 0.510, 0.773, 1, 1, true);
	CharacterCreateTooltip:AddLine(self.tooltip.description, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, true);
	CharacterCreateTooltip:AddLine(self.tooltip.footer, nil, nil, nil, nil, true);

	local raceData = C_CharacterCreation.GetRaceDataByID(C_CharacterCreation.GetSelectedRace());
	local classData = C_CharacterCreation.GetClassDataByID(self.classID);
	if not IsKioskGlueEnabled() and CharacterUpgrade_IsCreatedCharacterTrialBoost() and not CharacterCreate_IsTrialBoostAllowedForClass(classData, raceData) then
		CharacterCreateTooltip:AddLine(CHARACTER_TYPE_FRAME_TRIAL_BOOST_CHARACTER_TOOLTIP_INVALID, 1, 0, 0, 1, true);
	end
end

function CharCreateClassButton_OnLeave(self)
	CharacterCreateTooltip:Hide();
end

---------------------------------------------
-- CharacterCreateSpellIcon script functions
---------------------------------------------
function CharacterCreateSpellIcon_OnEnter(self)
	CharacterCreateTooltip:SetOwner(self, "ANCHOR_LEFT", 8, -4);
	CharacterCreateTooltip:SetText(self.tooltip.name, 1, 1, 1, 1);
	CharacterCreateTooltip:AddLine(self.tooltip.desc, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, true);
end

function CharacterCreateSpellIcon_OnLeave(self)
	CharacterCreateTooltip:Hide();
end

---------------------------------------------
-- CharacterCreate_InfoTemplate script functions
---------------------------------------------
function CharacterCreate_InfoTemplate_Resize(frame)
	if ( frame:IsVisible() ) then
		frame.scrollFrame.scrollChild:Layout();
		local height = frame.headerTex:GetTop() - frame.scrollFrame.scrollChild.infoText:GetBottom() + 33; -- 33 pixels to account for the anchor offsets
		height = min( frame.maxHeight, max(frame.minHeight, height));
		frame:SetHeight(height);
	end
end

function CharacterCreate_InfoTemplate_OnShow(self)
	CharacterCreate_InfoTemplate_Resize(self);
end

---------------------------------------------
-- CharacterCreate Type Button script functions
---------------------------------------------

local function IsBoostAllowed(classInfo, raceData)
	return C_CharacterServices.IsTrialBoostEnabled() and classInfo.allowBoost and raceData.enabled;
end

local function UpdateLevelText(button, classInfo, raceData)
	button.levelText:SetText(CHARACTER_TYPE_FRAME_STARTING_LEVEL:format(CharacterCreate_GetStartingLevel(button.characterType == Enum.CharacterCreateType.TrialBoost)));
end

function CharacterCreate_TypeButtonOnLoad(self)
	self.typeText:SetText(self.titleText);
end

function CharacterCreate_TypeButtonOnEnter(self)
	GlueTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10);
	GlueTooltip:SetText(CHARACTER_TYPE_FRAME_TRIAL_BOOST_CHARACTER);
	GlueTooltip:AddLine(CHARACTER_TYPE_FRAME_TRIAL_BOOST_CHARACTER_TOOLTIP:format(C_CharacterCreation.GetTrialBoostStartingLevel()), 1, 1, 1, 1, true);

	if not self:IsEnabled() then
		local classData = C_CharacterCreation.GetSelectedClass();
		if (not classData.allowBoost) then
			GlueTooltip:AddLine(CHARACTER_TYPE_FRAME_TRIAL_BOOST_CHARACTER_TOOLTIP_INVALID, 1, 0, 0, 1, true);
		end

		local raceData = C_CharacterCreation.GetRaceDataByID(C_CharacterCreation.GetSelectedRace());
		if (not raceData.enabled) then
			GlueTooltip:AddLine(CHARACTER_TYPE_FRAME_TRIAL_BOOST_CHARACTER_TOOLTIP_INVALID_ALLIED_RACE, 1, 0, 0, 1, true);
		end
	end
end

function CharacterCreate_GetStartingLevel(forTrialBoost)
	if ( forTrialBoost ) then
		return C_CharacterCreation.GetTrialBoostStartingLevel();
	else
		local classInfo = C_CharacterCreation.GetSelectedClass();
		local raceData = C_CharacterCreation.GetRaceDataByID(C_CharacterCreation.GetSelectedRace());
		return max(classInfo.startingLevel, raceData.startingLevel);
	end
end

function CharacterCreate_UpdateCharacterTypeButtons()
	local classInfo = C_CharacterCreation.GetSelectedClass();
	local raceData = C_CharacterCreation.GetRaceDataByID(C_CharacterCreation.GetSelectedRace());
	for index, button in ipairs(CharCreateCharacterTypeFrame.typeButtons) do
		UpdateLevelText(button, classInfo, raceData);
		if (button.characterType == Enum.CharacterCreateType.TrialBoost) then
			button:SetEnabled(IsBoostAllowed(classInfo, raceData));
		end
	end

	if CharCreateCharacterTypeFrame:IsShown() then
		local isTrialBoost = C_CharacterCreation.GetCharacterCreateType() == Enum.CharacterCreateType.TrialBoost;
		if isTrialBoost and not IsBoostAllowed(classInfo, raceData) then
			CharacterCreate_SelectCharacterType(Enum.CharacterCreateType.Normal);
		end
	end
end

local function LookupCharacterTypeButton(characterType)
	for index, button in ipairs(CharCreateCharacterTypeFrame.typeButtons) do
		if (button.characterType == characterType) then
			return button;
		end
	end
end

local function SelectCharacterTypeButton(selectedCharacterType)
	-- TODO: Implement radio button group...this handles unchecking the one that wasn't selected.
	for index, button in ipairs(CharCreateCharacterTypeFrame.typeButtons) do
		button:SetChecked(button.characterType == selectedCharacterType);
	end
end

local function ShouldHideCharacterTypeFrame(characterType)
	if (characterType == Enum.CharacterCreateType.Boost)
	 or (not CharCreateCharacterTypeFrame.allowShowing)
	 or (not C_CharacterServices.IsTrialBoostEnabled())
	 or (PAID_SERVICE_TYPE ~= nil)
	 or C_CharacterCreation.IsUsingCharacterTemplate()
	 or C_CharacterCreation.IsForcingCharacterTemplate()
	 or IsKioskModeEnabled() then
		return true;
	end

	return false;
end

function CharacterCreate_SetAllowCharacterTypeFrame(allow)
	CharCreateCharacterTypeFrame.allowShowing = allow;
end

function CharacterCreate_SelectCharacterType(characterType)
	if (CharCreateCharacterTypeFrame.currentCharacterType == characterType) then
		return;
	end

	characterType = characterType or Enum.CharacterCreateType.Normal;

	C_CharacterCreation.SetCharacterCreateType(characterType);
	CharCreateCharacterTypeFrame.currentCharacterType = characterType;

	-- If this character is actually being created because a boost token is being used, then there's no reason to display
	-- character type selection, because of the current flow, this boost will actually be consumed.
	if ShouldHideCharacterTypeFrame(characterType) then
		CharCreateCharacterTypeFrame:Hide();
		return;
	end

	CharCreateCharacterTypeFrame:Show();

	SelectCharacterTypeButton(characterType);
	CharacterUpgrade_SetupFlowForNewCharacter(characterType);
	CharacterCreate_UpdateClassTrialCustomizationFrames();
	CharacterCreateEnumerateClasses();

	if (characterType == Enum.CharacterCreateType.TrialBoost) then
		C_SharedCharacterServices.QueryClassTrialBoostResult();
	end
end

function CharacterCreate_TypeButtonOnClick(self)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS); -- TODO: Get more appropriate sound for this?
	CharacterCreate_SelectCharacterType(self.characterType);
end

function CharacterCreate_TypeButtonOnDisable(self)
	self.typeText:SetTextColor(.5, .5, .5, 1);
	self.levelText:SetTextColor(.5, .5, .5, 1);
end

function CharacterCreate_TypeButtonOnEnable(self)
	self.typeText:SetTextColor(1, .78, 0, 1);
	self.levelText:SetTextColor(1, 1, 1, 1);
end

local function SelectSpecFrame_OnUpdateSpecButtons(self, allowAllSpecs)
	if not allowAllSpecs then
		ClickRecommendedSpecButton(self);
	end
end

function SelectSpecFrame_OnLoad(self)
	local trialBoostSpecButtonLayoutData = {
		initialAnchor = { point = "TOPLEFT", relativeKey = "Title", relativePoint = "BOTTOM", x = -88, y = -25 },
		subsequentAnchor = { point = "TOP", relativePoint = "BOTTOM", x = 0, y = -35 },
		buttonInsets = { 0, -170, -20, -20 },
		specNameWidth = 115,
		specNameFont = "GameFontNormalMed2",
	}

	self.specButtonClickedCallback = CharacterCreate_UpdateOkayButton;
	self.OnUpdateSpecButtons = SelectSpecFrame_OnUpdateSpecButtons;
	self.layoutData = trialBoostSpecButtonLayoutData;
	self.selected = nil;
end

function SelectSpecFrame_OnHide(self)
	self.selected = nil;
end

function SelectFactionFrame_OnLoad(self)
	self.factionButtonClickedCallback = CharacterCreate_UpdateOkayButton;
	self.selected = nil;
end

function SelectFactionFrame_OnHide(self)
	self.selected = nil;
end

function CharacterCreate_UpdateClassTrialCustomizationFrames()
	local classInfo = C_CharacterCreation.GetSelectedClass();
	local raceData = C_CharacterCreation.GetRaceDataByID(C_CharacterCreation.GetSelectedRace());
	local isTrialBoost = CharacterUpgrade_IsCreatedCharacterTrialBoost();
	local isCustomization = CharacterCreateFrame.state == "CUSTOMIZATION";
	local showTrialFrames = isTrialBoost and isCustomization and IsBoostAllowed(classInfo, raceData);

	local showSpecializations = showTrialFrames;
	local showFactions = showTrialFrames and C_CharacterCreation.IsNeutralRace(CharacterCreate.selectedRace);

	if showSpecializations then
		local gender = C_CharacterCreation.GetSelectedSex();
		local allowAllSpecs = false;

		CharCreateSelectSpecFrame.classFilename = classInfo.fileName;
		CharacterServices_UpdateSpecializationButtons(classInfo.classID, gender+1, CharCreateSelectSpecFrame, CharCreateSelectSpecFrame, allowAllSpecs, isTrialBoost);

		local frameTop, frameBottom = CharCreateSelectSpecFrame:GetTop(), CharCreateSelectSpecFrame:GetBottom();
		for index, button in pairs(CharCreateSelectSpecFrame.SpecButtons) do
			if (button and button:IsShown()) then
				frameBottom = button.RoleIcon:GetBottom();
			end
		end

		CharCreateSelectSpecFrame:SetHeight(frameTop - frameBottom + 25); -- Arbitrary offset for frame padding
	end

	if showFactions then
		CharacterServices_UpdateFactionButtons(CharCreateSelectFactionFrame, CharCreateSelectFactionFrame);
	end

	CharCreateSelectSpecFrame:SetShown(showSpecializations);
	CharCreateSelectFactionFrame:SetShown(showFactions);

	CharacterCreate_UpdateOkayButton();
end

local RequirementsFlowMixin = {};

function RequirementsFlowMixin:Initialize(completeButton, setCompleteButtonEnabledCallback)
	self.completeButton = completeButton;
	self.setCompleteButtonEnabledCallback = setCompleteButtonEnabledCallback;
	self.requirements = {};
end

function RequirementsFlowMixin:InstallScripts()
	-- Currently the only system using this object has no OnEnter script for the completeButton,
	-- ideally this would hook any existing script.

	self.completeButton:SetScript("OnEnter", function() self:DisplayTooltip() end);
	self.completeButton:SetScript("OnLeave", function() self:HideTooltip() end);
end

function RequirementsFlowMixin:RemoveScripts()
	self.completeButton:SetScript("OnEnter", nil);
	self.completeButton:SetScript("OnLeave", nil);
end

function RequirementsFlowMixin:DisplayTooltip()
	-- Only need a tooltip if there are incomplete requirements
	if self:GetFirstIncompleteRequirement() then
		GlueTooltip:SetText("");
		GlueTooltip:SetOwner(self.completeButton, "ANCHOR_TOP");

		for requirementID, requirementData in ipairs(self.requirements) do
			if not requirementData.complete then
				GlueTooltip:AddLine(requirementData.description, 1, 0, 0, 1);
			end
		end
	else
		self:HideTooltip();
	end
end

function RequirementsFlowMixin:HideTooltip()
	GlueTooltip:Hide();
end

function RequirementsFlowMixin:AddRequirement(requirementID, description)
	self.requirements[requirementID] = { complete = false, description = description };
end

function RequirementsFlowMixin:SetRequirementComplete(requirementID, complete)
	self.requirements[requirementID].complete = complete;
end

function RequirementsFlowMixin:SetAllComplete(complete)
	for id, _ in pairs(self.requirements) do
		self:SetRequirementComplete(id, complete);
	end
end

function RequirementsFlowMixin:GetFirstIncompleteRequirement()
	for requirementID, requirementData in ipairs(self.requirements) do
		if not requirementData.complete then
			return requirementID;
		end
	end

	return nil;
end

function RequirementsFlowMixin:UpdateInstructions()
	local firstIncompleteRequirement = self:GetFirstIncompleteRequirement();
	self.setCompleteButtonEnabledCallback(firstIncompleteRequirement == nil);

	if firstIncompleteRequirement and GetMouseFocus() == self.completeButton then
		local script = self.completeButton:GetScript("OnEnter");
		if script then
			script();
		end
	end
end

local FINALIZE_REQ_HAS_SPEC = 1
local FINALIZE_REQ_HAS_FACTION = 2
local FINALIZE_REQ_HAS_NAME = 3
local FINALIZE_REQ_ALLIED_RACE_EXPANSION = 4
local FINALIZE_REQ_ALLIED_RACE_ACHIEVEMENT = 5

local finalizeRequirements;

local function InitializeRequirementsFlow()
	if not finalizeRequirements then
		finalizeRequirements = CreateFromMixins(RequirementsFlowMixin);

		local setCompleteEnabled = function(enabled)
			CharCreate_EnableNextButton(enabled);
		end

		finalizeRequirements:Initialize(CharCreateOkayButton, setCompleteEnabled);

		finalizeRequirements:AddRequirement(FINALIZE_REQ_ALLIED_RACE_EXPANSION, CHARACTER_CREATION_REQUIREMENTS_NEED_8_0);
		finalizeRequirements:AddRequirement(FINALIZE_REQ_ALLIED_RACE_ACHIEVEMENT, CHARACTER_CREATION_REQUIREMENTS_NEED_ACHIEVEMENT);
		finalizeRequirements:AddRequirement(FINALIZE_REQ_HAS_SPEC, CHARACTER_CREATION_REQUIREMENTS_PICK_SPEC);
		finalizeRequirements:AddRequirement(FINALIZE_REQ_HAS_FACTION, CHARACTER_CREATION_REQUIREMENTS_PICK_FACTION);
		finalizeRequirements:AddRequirement(FINALIZE_REQ_HAS_NAME, CHARACTER_CREATION_REQUIREMENTS_PICK_NAME);
	end
end

function CharacterCreate_UpdateOkayButton()
	InitializeRequirementsFlow();

	if CharacterCreateFrame.state == "CUSTOMIZATION" then
		finalizeRequirements:InstallScripts();
		finalizeRequirements:SetAllComplete(true);
		finalizeRequirements:SetRequirementComplete(FINALIZE_REQ_HAS_NAME, CharacterCreateNameEdit:GetText() ~= "");
		if (CharacterCreate_IsAlliedRacePreview()) then
			local hasExpansion, hasAchievement = C_CharacterCreation.GetAlliedRaceCreationRequirements(C_CharacterCreation.GetSelectedRace());
			finalizeRequirements:SetRequirementComplete(FINALIZE_REQ_ALLIED_RACE_EXPANSION, hasExpansion);
			finalizeRequirements:SetRequirementComplete(FINALIZE_REQ_ALLIED_RACE_ACHIEVEMENT, hasAchievement);
			finalizeRequirements:SetRequirementComplete(FINALIZE_REQ_HAS_NAME, true);
		else
			local isTrialBoost = CharacterUpgrade_IsCreatedCharacterTrialBoost();
			finalizeRequirements:SetRequirementComplete(FINALIZE_REQ_HAS_SPEC, not isTrialBoost or CharCreateSelectSpecFrame.selected ~= nil);
			finalizeRequirements:SetRequirementComplete(FINALIZE_REQ_HAS_FACTION, not isTrialBoost or CharacterCreate_GetSelectedFaction() ~= nil);
		end
		finalizeRequirements:UpdateInstructions();
	else
		finalizeRequirements:RemoveScripts();
		CharCreate_EnableNextButton(CanProceedThroughCharacterCreate());
	end
end

function CharacterCreate_IsTrialBoostAllowedForClass(classInfo, raceData)
	return IsBoostAllowed(classInfo, raceData);
end

function CharacterCreate_GetSelectedFaction()
	return CharacterCreate.selectedFactionID or CharCreateSelectFactionFrame.selected;
end

local isAlliedRacePreview;

function CharacterCreate_SetAlliedRacePreview(preview)
	isAlliedRacePreview = preview;

	CharacterCreate_UpdatePreview();
end

function CharacterCreate_IsAlliedRacePreview()
	return isAlliedRacePreview;
end

function CharacterCreate_UpdatePreview()
	CharacterCreateNameEdit:SetEnabled(not isAlliedRacePreview);
end
