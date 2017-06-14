CHARACTER_FACING_INCREMENT = 2;
MAX_RACES = 14;
MAX_CLASSES_PER_RACE = 12;
MAX_DISPLAYED_CLASSES_PER_RACE = 12;

NUM_CHAR_CUSTOMIZATIONS = 9;
MIN_CHAR_NAME_LENGTH = 2;
CHARACTER_CREATE_ROTATION_START_X = nil;
CHARACTER_CREATE_INITIAL_FACING = nil;
NUM_PREVIEW_FRAMES = 14;
WORGEN_RACE_ID = 6;
PANDAREN_RACE_ID = 13;

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
	[2] = {
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
	},
	[3] = {
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
	}
};

CHAR_CUSTOMIZE_HAIR_COLOR = 4;
CHAR_CUSTOMIZE_TATTOO_COLOR = 9;

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
		CharacterCreate_SelectCharacterType(LE_CHARACTER_CREATE_TYPE_NORMAL);
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

	SetCharCustomizeFrame("CharacterCreate");

	for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
		_G["CharCreateCustomizationButton"..i].text:SetText(_G["CHAR_CUSTOMIZATION"..i.."_DESC"]);
	end

	-- Color edit box backdrop
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE["Alliance"];
	CharacterCreateNameEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	CharacterCreateNameEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);

	CharacterCreateFrame.state = "CLASSRACE";

	CharCreatePreviewFrame.previews = { };

	local classes = GetAvailableClasses();
	for idx, classData in pairs(classes) do
		-- Class Button Tooltip
		local classIndex = classData.fileName;
		CHARCREATE_CLASS_TOOLTIP[classIndex] = {
			name = classData.className;
			roles = _G["CLASS_INFO_"..classIndex.."_ROLE_TT"];
			description = "|n".._G["CLASS_"..classIndex].."|n|n";
			footer = CLASS_INFO_MORE_INFO_HINT;
		};

		-- Class More Info Data
		local classInfo = CHARCREATE_CLASS_INFO[classIndex];
		classInfo.name = classData.className;
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

    if (not IsDemonHunterAvailable()) then
        MAX_DISPLAYED_CLASSES_PER_RACE = 11;
        for i=1, MAX_CLASSES_PER_RACE, 1 do
            local button = _G["CharCreateClassButton"..i];
            button:SetSize(44, 44);
        end
        CharCreateClassButton12:Hide();
        CharCreateClassButton6:SetPoint("TOPLEFT", CharCreateClassButton11, "BOTTOMLEFT", 0, -18);
    end
	CharCreateClassInfoFrameScrollFrameScrollChildInfoText.topPadding = 18;
	CharCreateClassInfoFrameScrollFrameScrollChild.Spells = {};
end

function CharacterCreate_OnShow()
	InitializeCharacterScreenData();
	SetInCharacterCreate(true);

	for i=1, MAX_CLASSES_PER_RACE, 1 do
		local button = _G["CharCreateClassButton"..i];
		button:Enable();
		SetButtonDesaturated(button, false)
	end
	for i=1, MAX_RACES, 1 do
		local button = _G["CharCreateRaceButton"..i];
		button:Enable();
		SetButtonDesaturated(button, false)
	end

	if ( PAID_SERVICE_TYPE ) then
		CustomizeExistingCharacter( PAID_SERVICE_CHARACTER_ID );
		CharacterCreateNameEdit:SetText( PaidChange_GetName() );
	else
		--randomly selects a combination
		ResetCharCustomize();
		CharacterCreateNameEdit:SetText("");
		CharCreateRandomizeButton:Show();
	end

	-- Pandarens doing paid faction change
	if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE and GetSelectedRace() == PANDAREN_RACE_ID ) then
		PandarenFactionButtons_Show();
	else
		PandarenFactionButtons_Hide();
	end

	CharacterCreateEnumerateRaces();

	SetCharacterRace(GetSelectedRace());

	CharacterCreateEnumerateClasses();

	local _,_,index = GetSelectedClass();
	SetCharacterClass(index);

	SetCharacterGender(GetSelectedSex())

	-- Hair customization stuff
	CharacterCreate_UpdateHairCustomization();
	CharacterCreate_UpdateDemonHunterCustomization();

	SetCharacterCreateFacing(-15);

	-- setup customization
	CharacterChangeFixup();

	SetFaceCustomizeCamera(false);

	CharacterCreateFrame_UpdateRecruitInfo();
	CharacterCreate_SelectCharacterType(GetCharacterCreateType());

	if( IsKioskGlueEnabled() ) then
		local kioskModeData = KioskModeSplash_GetModeData();
		if (not kioskModeData) then
			-- This shouldn't happen, why don't have we have mode data?
			GlueParent_SetScreen("kioskmodesplash");
			return;
		end
		local available = {};
		for k, v in pairs(kioskModeData.races) do
			if (v) then
				tinsert(available, k);
			end
		end

		local rid = KioskModeSplash_GetIDForSelection("races", available[math.random(1, #available)]);
		SetSelectedRace(rid);
		SetCharacterRace(rid);

		CharacterCreateEnumerateClasses();

		local currentRace = GetSelectedRace();
		local available = {};
		for k, v in pairs(kioskModeData.classes) do
			if (v) then
				local id = KioskModeSplash_GetIDForSelection("classes", k);
				if (IsClassAllowedInKioskMode(id) and IsRaceClassValid(currentRace, id)) then
					tinsert(available, k);
				end
			end
		end

		local cid = KioskModeSplash_GetIDForSelection("classes", available[math.random(1, #available)]);

		KioskModeCheckTrial(cid);
		SetSelectedClass(cid);
		SetCharacterClass(cid);
		SetCharacterRace(GetSelectedRace());

		RandomizeCharCustomization(true);
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
			CharacterCreateNameEdit:SetText(GenerateRandomName());
		else
			-- Succeeded.  Use what the server sent.
			CharacterCreateNameEdit:SetText(name);
		end
		CharacterCreateRandomName:Enable();
		PlaySound("gsCharacterCreationLook");
	elseif ( event == "UPDATE_EXPANSION_LEVEL" ) then
		-- Expansion level changed while online, so enable buttons as needed
		if ( CharacterCreateFrame:IsShown() ) then
			CharacterCreateEnumerateRaces();
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
		CHARACTER_CREATE_INITIAL_FACING = GetCharacterCreateFacing();
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
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition();
		SetCharacterCreateFacing(GetCharacterCreateFacing() + diff);
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
		if ( faction == FACTION_GROUP_HORDE ) then
			RecruitAFriendFactionHighlight:SetPoint("TOPLEFT", CharCreateRaceButton7, "TOPLEFT", -17, 35);
			RecruitAFriendFactionHighlight:SetPoint("BOTTOMRIGHT", CharCreateRaceButton11, "BOTTOMRIGHT", 17, -29);
			ShowGlowyDialog(RecruitAFriendFactionNotice, RECRUIT_A_FRIEND_FACTION_SUGGESTION_HORDE, true);
			RecruitAFriendFactionNotice:SetPoint("LEFT", CharCreateRaceButton8, "RIGHT", 40, 0);
		else
			RecruitAFriendFactionHighlight:SetPoint("TOPLEFT", CharCreateRaceButton1, "TOPLEFT", -17, 35);
			RecruitAFriendFactionHighlight:SetPoint("BOTTOMRIGHT", CharCreateRaceButton6, "BOTTOMRIGHT", 17, -29);
			ShowGlowyDialog(RecruitAFriendFactionNotice, RECRUIT_A_FRIEND_FACTION_SUGGESTION_ALLIANCE, true);
			RecruitAFriendFactionNotice:SetPoint("LEFT", CharCreateRaceButton2, "RIGHT", 40, 0);
		end
		RecruitAFriendFactionHighlight:Show();
		RecruitAFriendPandaHighlight:Show();
	else
		RecruitAFriendFactionHighlight:Hide();
		RecruitAFriendPandaHighlight:Hide();
		RecruitAFriendFactionNotice:Hide();
	end
end

function CharacterCreateEnumerateRaces()
	local races = GetAvailableRaces();

	CharacterCreate.numRaces = #races;
	if ( CharacterCreate.numRaces > MAX_RACES ) then
		message("Too many races!  Update MAX_RACES");
		return;
	end

	local gender;
	if ( GetSelectedSex() == SEX_MALE ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end

	local index = 1;
	for i=1, CharacterCreate.numRaces do
		local button = _G["CharCreateRaceButton"..index];
		if ( not button  ) then
			return;
		end

		local name = races[i].name;
		local raceIndex = strupper(races[i].fileName);
		local coords = RACE_ICON_TCOORDS[raceIndex.."_"..gender];
		button.NormalTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		button.PushedTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		button.nameFrame.text:SetText(name);

		local kioskModeData = IsKioskGlueEnabled() and KioskModeSplash_GetModeData();
		local disableTexture = button.DisableTexture;
		if ( races[i].enabled and (not kioskModeData or kioskModeData.races[raceIndex]) ) then
			button:Enable();
			SetButtonDesaturated(button);
			button.name = name;
			button.tooltip = name;
			disableTexture:Hide();
		else
			button:Disable();
			SetButtonDesaturated(button, true);
			button.name = name;
			if (IsKioskGlueEnabled()) then
				button.tooltip = RACE_DISABLED_KIOSK_MODE;
			else
				local disabledReason = _G[raceIndex.."_DISABLED"];
				if ( disabledReason ) then
					button.tooltip = name.."|n"..disabledReason;
				else
					button.tooltip = nil;
				end
			end
			disableTexture:SetShown(IsKioskGlueEnabled());
		end
		index = index + 1;
	end
	for i=CharacterCreate.numRaces + 1, MAX_RACES, 1 do
		_G["CharCreateRaceButton"..i]:Hide();
	end
end

local function UpdateClassButtonEnabledState(button, classID, classData)
	local kioskModeData = IsKioskGlueEnabled() and KioskModeSplash_GetModeData();
	local disableTexture = button.DisableTexture;

	if ( classData.enabled == true ) then
		if (IsKioskGlueEnabled() and (not IsClassAllowedInKioskMode(classID) or not kioskModeData.classes[classData.fileName])) then
			button:Disable();
			SetButtonDesaturated(button, true);
			button.tooltip.footer = CLASS_DISABLED_KIOSK_MODE;
			disableTexture:Show();
		elseif (IsRaceClassValid(CharacterCreate.selectedRace, classID)) then
			button:Enable();
			SetButtonDesaturated(button, false);
			button.tooltip.footer = CLASS_INFO_MORE_INFO_HINT;
			disableTexture:Hide();
		else
			button:Disable();
			SetButtonDesaturated(button, true);
			local validRaces = GetValidRacesForClass(button:GetID());
			validRaces = table.concat(validRaces, ", ");
			button.tooltip.footer = WrapTextInColorCode(CLASS_DISABLED, "ffff0000") .. "|n|n" .. WrapTextInColorCode(validRaces, "ffff0000");
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

	button.nameFrame.text:SetText(classData.className);
	button.tooltip = CHARCREATE_CLASS_TOOLTIP[classData.fileName];
	button.classFilename = classData.fileName;

	UpdateClassButtonEnabledState(button, classID, classData);
end

function CharacterCreateEnumerateClasses()
	local classes = GetAvailableClasses();

	CharacterCreate.numClasses = #classes;

	if ( CharacterCreate.numClasses > MAX_CLASSES_PER_RACE ) then
		message("Too many classes!  Update MAX_CLASSES_PER_RACE");
		return;
	end

	local index = 1;
	for classID, classData in pairs(classes) do
		local button = _G["CharCreateClassButton"..index];

        if (index <= MAX_DISPLAYED_CLASSES_PER_RACE) then
    		button:Show();
        end

		SetupClassButton(button, classID, classData);
		index = index + 1;
	end

	for i=CharacterCreate.numClasses + 1, MAX_CLASSES_PER_RACE, 1 do
		_G["CharCreateClassButton"..i]:Hide();
	end
end

function SetCharacterRace(id)
	CharacterCreate.selectedRace = id;
	for i=1, CharacterCreate.numRaces, 1 do
		_G["CharCreateRaceButton"..i]:SetChecked(i == id);
	end

	local name, faction = GetFactionForRace(CharacterCreate.selectedRace);

	-- during a paid service we have to set alliance/horde for neutral races
	-- hard-coded for Pandaren because of alliance/horde pseudo buttons
	local canProceed = true;
	if ( id == PANDAREN_RACE_ID and PAID_SERVICE_TYPE ) then
		local _, currentFaction = PaidChange_GetCurrentFaction();
		if ( PaidChange_GetCurrentRaceIndex() == PANDAREN_RACE_ID and PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
			-- this is an original pandaren staying or becoming selected
			-- check the pseudo-buttons
			faction = PandarenFactionButtons_GetSelectedFaction();
			if ( faction == currentFaction ) then
				canProceed = false;
			end
		else
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
	else
		PandarenFactionButtons_ClearSelection();
	end
	CharCreate_EnableNextButton(canProceed);

	-- Cache current selected faction information in the case where user is applying a trial boost
	CharacterCreate.selectedFactionID = FACTION_IDS[faction];

	-- Set background
	SetBackgroundModel(CharacterCreate, GetCreateBackgroundModel(faction));

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
	local race, fileString = GetNameForRace();
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
	if (HasAlteredForm()) then
		SetPortraitTexture(CharacterCreateAlternateFormTopPortrait, 22, GetSelectedSex());
		SetPortraitTexture(CharacterCreateAlternateFormBottomPortrait, 23, GetSelectedSex());
		CharacterCreateAlternateFormTop:Show();
		CharacterCreateAlternateFormBottom:Show();
		if( IsViewingAlteredForm() ) then
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

function SetCharacterClass(id)
	CharacterCreate.selectedClass = id;
	for i=1, CharacterCreate.numClasses, 1 do
		local button = _G["CharCreateClassButton"..i];
		if ( i == id ) then
			button:SetChecked(true);
		else
			button:SetChecked(false);
			button.selection:Hide();
		end
	end

	-- class info
	local frame = CharCreateClassInfoFrame;
	local scrollFrame = frame.scrollFrame.scrollChild;
	local className, classFileName = GetSelectedClass();
	frame.title:SetText(className);

	-- hide spell icons
	for _, spellIcon in pairs(scrollFrame.Spells) do
		spellIcon:Hide();
		spellIcon.layoutIndex = nil;
	end

	-- display spell icons
	local layoutIndexCount = 2; -- bullet text is always at layout index 1
	if (#CHARCREATE_CLASS_INFO[classFileName].spells > 0) then
		scrollFrame.AbilityText:Show();
		scrollFrame.AbilityText.layoutIndex = layoutIndexCount;
		layoutIndexCount = layoutIndexCount + 1;
		for idx, spell in pairs(CHARCREATE_CLASS_INFO[classFileName].spells) do
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

	scrollFrame.bulletText:SetText(CHARCREATE_CLASS_INFO[classFileName].bulletText);
	scrollFrame.infoText:SetText(CHARCREATE_CLASS_INFO[classFileName].description);
	scrollFrame.infoText.layoutIndex = layoutIndexCount;

	CharacterCreate_InfoTemplate_Resize(frame);
	CharCreateClassInfoFrameScrollFrameScrollBar:SetValue(0);

	CharacterCreate_UpdateCharacterTypeButtons();
end

function CharacterCreate_OnChar()
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
	UpdateCustomizationScene();
end

function CharacterCreate_Finish()
	PlaySound("gsCharacterCreationCreateChar");

	if ( PAID_SERVICE_TYPE ) then
		GlueDialog_Show("CONFIRM_PAID_SERVICE");
	else
		if( IsKioskModeEnabled() ) then
			KioskModeSplash_SetAutoEnterWorld(true);
		end

		-- if using templates, pandaren must pick a faction
		local _, faction = GetFactionForRace(CharacterCreate.selectedRace);
		if ( ( IsUsingCharacterTemplate() or IsForcingCharacterTemplate() ) and ( faction ~= "Alliance" and faction ~= "Horde" ) ) then
			CharacterTemplateConfirmDialog:Show();
		else
			CreateCharacter(CharacterCreateNameEdit:GetText());
		end
	end
end

function CharacterCreate_Back()
	if ( CharacterCreateFrame.state == "CUSTOMIZATION" ) then
		PlaySound("gsCharacterCreationCancel");
		CharacterCreateFrame.state = "CLASSRACE"
		CharCreateClassFrame:Show();
		CharCreateRaceFrame:Show();
		CharCreateMoreInfoButton:Show();
		CharCreateCustomizationFrame:Hide();
		CharCreatePreviewFrame:Hide();
		CharCreateOkayButton:SetText(CUSTOMIZE);
		CharacterCreateNameEdit:Hide();
		CharacterCreateRandomName:Hide();

		CharacterCreate_UpdateClassTrialCustomizationFrames();

		--back to awesome gear
		SetSelectedPreviewGearType(1);

		-- back to normal camera
		SetFaceCustomizeCamera(false);
	else
		if( IsKioskGlueEnabled() ) then
			PlaySound("gsCharacterCreationCancel");
			GlueParent_SetScreen("kioskmodesplash");
		else
			if CharacterUpgrade_IsCreatedCharacterTrialBoost() then
				CharacterUpgrade_ResetBoostData();
			end

			PlaySound("gsCharacterCreationCancel");
			CHARACTER_SELECT_BACK_FROM_CREATE = true;
			GlueParent_SetScreen("charselect");
		end
	end
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
		PlaySound("gsCharacterSelectionCreateNew");
		CharCreateClassFrame:Hide();
		CharCreateRaceFrame:Hide();
		CharCreateMoreInfoButton:Hide();
		CharCreateCustomizationFrame:Show();
		CharCreatePreviewFrame:Show();
		CharacterTemplateConfirmDialog:Hide();

		CharacterCreate_UpdateClassTrialCustomizationFrames();

		CharCreate_PrepPreviewModels();
		if ( CharacterCreateFrame.customizationType ) then
			CharCreate_ResetFeaturesDisplay();
		else
			CharCreateSelectCustomizationType(1);
		end

		CharCreateOkayButton:SetText(FINISH);
		CharacterCreateNameEdit:Show();
		if ( ALLOW_RANDOM_NAME_BUTTON ) then
			CharacterCreateRandomName:Show();
		end

		--You just went to customization mode - show the boring start gear
		SetSelectedPreviewGearType(0);

		-- set cam
		if (CharacterCreateFrame.customizationType and CharacterCreateFrame.customizationType > 1) then
			SetFaceCustomizeCamera(true);
		else
			SetFaceCustomizeCamera(false);
		end
	else
		CharacterCreate_Finish();
	end
end

function CharCreateCustomizationFrame_UpdateButtons ()
	-- check each button and hide it if there are no values select
	local numButtons = 0;
	local lastGood = 0;
	local isSkinVariantHair = GetSkinVariationIsHairColor(CharacterCreate.selectedRace);
	local isDefaultSet = false;
	local checkedButton = 1;

	-- check if this was set, if not, default to 1
	if ( CharacterCreateFrame.customizationType == 0 or CharacterCreateFrame.customizationType == nil ) then
		CharacterCreateFrame.customizationType = 1;
	end
	for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
		if ( ( GetNumFeatureVariationsForType(i) <= 1 ) or ( isSkinVariantHair and i == CHAR_CUSTOMIZE_HAIR_COLOR ) ) then
			_G["CharCreateCustomizationButton"..i]:Hide();
		else
			_G["CharCreateCustomizationButton"..i]:Show();
			_G["CharCreateCustomizationButton"..i]:SetChecked(false); -- we will handle default selection
			-- this must be done since a selected button can 'disappear' when swapping genders
			if ( not isDefaultSet and CharacterCreateFrame.customizationType == i) then
				isDefaultSet = true;
				checkedButton = i;
			end
            -- set your anchor to be the last good, this currently means button 1 HAS to be shown
           if (i > 1) then
                -- Hack for Demon Hunter tattoo colors
                if (i == CHAR_CUSTOMIZE_TATTOO_COLOR) then
					-- 6 is tattoos, 7 is horn style, 9 is tattoo color
                    CharCreateCustomizationButton9:SetPoint("TOP", CharCreateCustomizationButton6, "BOTTOM");
                    CharCreateCustomizationButton7:SetPoint("TOP", CharCreateCustomizationButton9, "BOTTOM");
                else
                    _G["CharCreateCustomizationButton"..i]:SetPoint( "TOP",_G["CharCreateCustomizationButton"..lastGood]:GetName() , "BOTTOM");
                end
			end
            if (i ~= CHAR_CUSTOMIZE_TATTOO_COLOR) then
    			lastGood = i;
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
	local warningText = AdvancedCharacterCreationWarningStrings[classButton:GetID()] or AdvancedCharacterCreationWarningStrings.GenericWarning;
	GlueDialog_Show("ADVANCED_CHARACTER_CREATION_WARNING", warningText, classButton);
end

function CharacterClass_SelectClass(self, forceAccept)
	if( self:IsEnabled() ) then
		if (IsKioskGlueEnabled()) then
			KioskModeCheckTrial(self:GetID());
		end

		PlaySound("gsCharacterCreationClass");
		local _,_,currClass = GetSelectedClass();
		local id = self:GetID();
		if ( currClass ~= id ) then
			if (IsAdvancedClass(id) and not (HasSufficientExperienceForAdvancedCreation() or forceAccept)) then
				ShowAdvancedCharacterCreationWarning(self);
				self:SetChecked(false);
				return;
			end

			SetSelectedClass(id);
			SetCharacterClass(id);
			SetCharacterRace(GetSelectedRace());
			CharacterChangeFixup();
			local demonHunterID = CLASS_NAME_BUTTON_ID_MAP["DEMONHUNTER"];
			if (currClass == demonHunterID or id == demonHunterID) then
				RandomizeCharCustomization(true);
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

function CharacterRace_OnClick(self, id, forceSelect)
	if( self:IsEnabled() ) then
		PlaySound("gsCharacterCreationClass");
		if ( GetSelectedRace() ~= id or forceSelect ) then
			SetSelectedRace(id);
			SetCharacterRace(id);
			SetCharacterGender(GetSelectedSex());
			SetCharacterCreateFacing(-15);
			CharacterCreateEnumerateClasses();
			if (IsKioskGlueEnabled()) then
				local kioskModeData = KioskModeSplash_GetModeData();
				local available = {};
				for k, v in pairs(kioskModeData.classes) do
					if (v) then
						local cid = KioskModeSplash_GetIDForSelection("classes", k);
						if (IsClassAllowedInKioskMode(cid) and IsRaceClassValid(id, cid)) then
							tinsert(available, k);
						end
					end
				end

				local fcid = KioskModeSplash_GetIDForSelection("classes", available[math.random(1, #available)]);
				KioskModeCheckTrial(fcid);
				SetSelectedClass(fcid);
				SetCharacterClass(fcid);
				SetCharacterRace(GetSelectedRace());
			else
				local _,_,classID = GetSelectedClass();
				if ( PAID_SERVICE_TYPE ) then
					classID = PaidChange_GetCurrentClassID();
					SetSelectedClass(classID);	-- selecting a race would have changed class to default
				end
				SetCharacterClass(classID);
			end

			-- Hair customization stuff
			CharacterCreate_UpdateHairCustomization();

			CharacterChangeFixup();
		else
			self:SetChecked(true);
		end
	else
		self:SetChecked(false);
	end
end

local currentGender;

function SetCharacterGender(sex)
	if sex == currentGender then
		return;
	end

	currentGender = sex;

	local gender;
	SetSelectedSex(sex);
	if ( sex == SEX_MALE ) then
		CharCreateMaleButton:SetChecked(true);
		CharCreateFemaleButton:SetChecked(false);
	else
		CharCreateMaleButton:SetChecked(false);
		CharCreateFemaleButton:SetChecked(true);
	end

	-- Update race images to reflect gender
	CharacterCreateEnumerateRaces();
	CharacterCreateEnumerateClasses();
 	SetCharacterRace(GetSelectedRace());

	local _,_,classID = GetSelectedClass();
	if ( PAID_SERVICE_TYPE ) then
		classID = PaidChange_GetCurrentClassID();
		PandarenFactionButtons_SetTextures();
	end
	SetCharacterClass(classID);

	CharacterCreate_UpdateHairCustomization();
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
	PlaySound("gsCharacterCreationLook");
	CycleCharCustomization(id, -1);
end

function CharacterCustomization_Right(id)
	PlaySound("gsCharacterCreationLook");
	CycleCharCustomization(id, 1);
end

function CharacterCreate_GenerateRandomName(button)
	button:Disable();
	CharacterCreateNameEdit:SetText("...");
	RequestRandomName();
end

function CharacterCreate_Randomize()
	PlaySound("gsCharacterCreationLook");
	RandomizeCharCustomization();
	CharCreate_ResetFeaturesDisplay();
end

function CharacterCreateRotateRight_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() + CHARACTER_FACING_INCREMENT);
		CharCreate_RotatePreviews();
	end
end

function CharacterCreateRotateLeft_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() - CHARACTER_FACING_INCREMENT);
		CharCreate_RotatePreviews();
	end
end

function CharacterCreate_UpdateHairCustomization()
	CharCreateCustomizationButton3.text:SetText(_G["HAIR_"..GetHairCustomization().."_STYLE"]);
	CharCreateCustomizationButton4.text:SetText(_G["HAIR_"..GetHairCustomization().."_COLOR"]);
	CharCreateCustomizationButton5.text:SetText(_G["FACIAL_HAIR_"..GetFacialHairCustomization()]);
end

function CharacterCreate_UpdateDemonHunterCustomization()
	-- Buttons 6, 7, 8 and 9 are for the demon hunter and have hardcoded strings
	CharCreateCustomizationButton6.text:SetText(DEMONHUNTER_TATTOO_STYLE);
	CharCreateCustomizationButton7.text:SetText(DEMONHUNTER_HORN_STYLE);
	CharCreateCustomizationButton8.text:SetText(DEMONHUNTER_BLINDFOLD_STYLE);
    CharCreateCustomizationButton9.text:SetText(DEMONHUNTER_TATTOO_COLOR);
end

function KioskModeCheckTrial(classID)
	if (IsKioskGlueEnabled()) then
		local kioskModeData = KioskModeSplash_GetModeData();
		if (not kioskModeData) then -- why?
			return;
		end
		local useTrial = nil;
		if (kioskModeData.trial and kioskModeData.trial.enabled) then
			useTrial = true;
			for i, v in ipairs(kioskModeData.trial.ignoreClasses) do
				local id = CLASS_NAME_BUTTON_ID_MAP[v];
				if (id == classID) then
					useTrial = nil;
					break;
				end
			end
		end
		if (useTrial) then
			CharacterUpgrade_BeginNewCharacterCreation(LE_CHARACTER_CREATE_TYPE_TRIAL_BOOST);
		else
			CharacterUpgrade_ResetBoostData();
		end
	end
end

function SetButtonDesaturated(button, desaturated)
	if ( not button ) then
		return;
	end
	local icon = button:GetNormalTexture();
	if ( not icon ) then
		return;
	end

	icon:SetDesaturated(desaturated);
end

function CharacterChangeFixup()
	if ( PAID_SERVICE_TYPE ) then
		-- no class changing as a paid service
		CharCreateClassFrame:SetAlpha(0.5);
		for i=1, MAX_CLASSES_PER_RACE, 1 do
			if (CharacterCreate.selectedClass ~= i) then
				local button = _G["CharCreateClassButton"..i];
				button:Disable();
				SetButtonDesaturated(button, true);
			end
		end

		local numAllowedRaces = 0;
		for i=1, MAX_RACES, 1 do
			local allow = false;
			if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
				local faction = PaidChange_GetCurrentFaction();
				if ( (i == PaidChange_GetCurrentRaceIndex()) or ((GetFactionForRace(i) ~= faction) and (IsRaceClassValid(i,CharacterCreate.selectedClass))) ) then
					allow = true;
				end
			elseif ( PAID_SERVICE_TYPE == PAID_RACE_CHANGE ) then
				local faction = PaidChange_GetCurrentFaction();
				if ( (i == PaidChange_GetCurrentRaceIndex()) or ((GetFactionForRace(i) == faction or IsNeutralRace(i)) and (IsRaceClassValid(i,CharacterCreate.selectedClass))) ) then
					allow = true
				end
			elseif ( PAID_SERVICE_TYPE == PAID_CHARACTER_CUSTOMIZATION ) then
				if ( i == CharacterCreate.selectedRace ) then
					allow = true
				end
			end
			if (not allow) then
				local button = _G["CharCreateRaceButton"..i];
				button:Disable();
				SetButtonDesaturated(button, true);
			else
				numAllowedRaces = numAllowedRaces + 1;
			end
		end
		if ( numAllowedRaces > 1 ) then
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
		SetFaceCustomizeCamera(true);
	else
		SetFaceCustomizeCamera(false);
	end
end

function CharCreate_ResetFeaturesDisplay()
	SetPreviewFramesFeature(CharacterCreateFrame.customizationType);
	-- set the previews scrollframe container height
	-- since the first and the last previews need to be in the center position when scrolled all the way
	-- to the top or to the bottom, there will be gaps of height equal to 2 previews on each side
	local numTotalButtons = GetNumFeatureVariations() + 4;
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
	local _, class = GetSelectedClass();
	if ( class == "DEATHKNIGHT" or displayFrame.lastClass == "DEATHKNIGHT" ) and ( class ~= displayFrame.lastClass ) then
		reloadModels = true;
	end
	displayFrame.lastClass = class;

	-- always clear the featureType
	for index, previewFrame in pairs(displayFrame.previews) do
		previewFrame.featureType = 0;
		-- force model reload in some cases
		if ( reloadModels or rebuildPreviews ) then
			previewFrame.race = nil;
			previewFrame.gender = nil;
		end
		if ( rebuildPreviews ) then
			SetPreviewFrame(previewFrame.model:GetName(), index);
		end
	end
end

function CharCreate_DisplayPreviewModels(selectionIndex)
	if ( not selectionIndex ) then
		selectionIndex = GetSelectedFeatureVariation();
	end

	local displayFrame = CharCreatePreviewFrame;
	local previews = displayFrame.previews;
	local numVariations = GetNumFeatureVariations();
	local currentFeatureType = CharacterCreateFrame.customizationType;

	local race = GetSelectedRace();
	local gender = GetSelectedSex();

	-- HACK: Worgen fix for portrait camera position
	local cameraID = 0;
	if ( race == WORGEN_RACE_ID and gender == SEX_MALE and not IsViewingAlteredForm() ) then
		cameraID = 1;
	end

	-- get data for target/camera/light
	local _, raceFileName = GetNameForRace();
	if ( IsViewingAlteredForm() ) then
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
				SetPreviewFrame(previewFrame.model:GetName(), index);
			end
			-- load model if needed, may have been cleared by different race/gender selection
			if ( previewFrame.race ~= race or previewFrame.gender ~= gender or previewFrame.currentCamera ~= config) then
				SetPreviewFrameModel(index);
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
			-- need to reset the model if it was last used to preview a different feature
			if ( previewFrame.featureType ~= currentFeatureType ) then
				ResetPreviewFrameModel(index);
				ShowPreviewFrameVariation(index);
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
		local facing = ((GetCharacterCreateFacing())/ -180) * math.pi;
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
	local numVariations = GetNumFeatureVariations();
	local startIndex = GetSelectedFeatureVariation();
	local endIndex = startIndex + delta;
	if ( endIndex < 1 or endIndex > numVariations ) then
		return;
	end
	PlaySound("gsCharacterCreationClass");
	CharCreatePreviewFrame_SelectFeatureVariation(endIndex);
end

function CharCreatePreviewFrameButton_OnClick(self)
	PlaySound("gsCharacterCreationClass");
	CharCreatePreviewFrame_SelectFeatureVariation(self.index);
end

function CharCreatePreviewFrame_SelectFeatureVariation(endIndex)
	local self = CharCreatePreviewFrame;
	if ( self.animating ) then
		if ( not self.queuedIndex ) then
			self.queuedIndex = endIndex;
		end
	else
		local startIndex = GetSelectedFeatureVariation();
		SelectFeatureVariation(endIndex);
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
				SelectFeatureVariation(newIndex);
				CharCreatePreviewFrame_UpdateStyleButtons();
				CharCreatePreviewFrame_StartAnimating(self.endIndex, newIndex);
                CharCreateCustomizationFrame_UpdateButtons(); -- Demon Hunters may need updated buttons
			end
		end
	end
end

function CharCreatePreviewFrame_UpdateStyleButtons()
	local selectionIndex = GetSelectedFeatureVariation();
	local numVariations = GetNumFeatureVariations();
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

-- pandaren stuff related to faction change
function CharCreate_EnableNextButton(enabled)
	local button = CharCreateOkayButton;
	button:SetEnabled(enabled);
	button.Arrow:SetDesaturated(not enabled);
	button.TopGlow:SetShown(enabled);
	button.BottomGlow:SetShown(enabled);
end

function PandarenFactionButtons_OnLoad(self)
	self.PandarenButton = CharCreateRaceButton13;
end

function PandarenFactionButtons_Show()
	local frame = CharCreatePandarenFactionFrame;
	-- set the name
	local raceName = GetNameForRace();
	frame.AllianceButton.nameFrame.text:SetText(raceName);
	frame.AllianceButton.tooltip = raceName;
	frame.HordeButton.nameFrame.text:SetText(raceName);
	frame.HordeButton.tooltip = raceName;
	-- set the texture
	PandarenFactionButtons_SetTextures();
	-- set selected button
	local _, faction = PaidChange_GetCurrentFaction();
	-- deselect first in case of multiple pandaren faction changes
	PandarenFactionButtons_ClearSelection();
	frame[faction.."Button"]:SetChecked(true);
	-- show the frame on top of the normal pandaren button
	frame:Show();
	frame:SetFrameLevel(frame.PandarenButton:GetFrameLevel() + 2);
	CharCreate_EnableNextButton(false);
end

function PandarenFactionButtons_Hide()
	CharCreatePandarenFactionFrame:Hide();
	CharCreate_EnableNextButton(true);
end

function PandarenFactionButtons_SetTextures()
	local gender;
	if ( GetSelectedSex() == SEX_MALE ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end
	local coords = RACE_ICON_TCOORDS["PANDAREN_"..gender];
	CharCreatePandarenFactionFrameAllianceButtonNormalTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	CharCreatePandarenFactionFrameAllianceButtonPushedTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	CharCreatePandarenFactionFrameHordeButtonNormalTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	CharCreatePandarenFactionFrameHordeButtonPushedTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
end

function PandarenFactionButtons_ClearSelection()
	CharCreatePandarenFactionFrame.AllianceButton:SetChecked(false);
	CharCreatePandarenFactionFrame.HordeButton:SetChecked(false);
end

function PandarenFactionButtons_GetSelectedFaction()
	if ( CharCreatePandarenFactionFrame.AllianceButton:GetChecked() ) then
		return "Alliance";
	elseif ( CharCreatePandarenFactionFrame.HordeButton:GetChecked() ) then
		return "Horde";
	end
end

function PandarenFactionButton_OnClick(self)
	PandarenFactionButtons_ClearSelection();
	self:SetChecked(true);
	CharacterRace_OnClick(CharCreatePandarenFactionFrame.PandarenButton, CharCreatePandarenFactionFrame.PandarenButton:GetID(), true);
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

	if not IsKioskGlueEnabled() and CharacterUpgrade_IsCreatedCharacterTrialBoost() and not CharacterCreate_IsTrialBoostAllowedForClass(self.classFilename) then
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

local classTypeData = {
	["DEATHKNIGHT"] = { startingLevel = 55, allowBoost = true, },
	["DEMONHUNTER"] = { startingLevel = 98, allowBoost = false, },
	["DEFAULT"] = { startingLevel = 1, allowBoost = true, },
};

local function GetClassTypeData(classFilename)
	return classTypeData[classFilename] or classTypeData["DEFAULT"];
end

local function IsBoostAllowed(classFilename)
	return C_CharacterServices.IsTrialBoostEnabled() and GetClassTypeData(classFilename).allowBoost;
end

local function UpdateLevelText(button, classFilename)
	local startingLevel;

	if button.characterType == LE_CHARACTER_CREATE_TYPE_TRIAL_BOOST then
		startingLevel = 100;
		button:SetEnabled(IsBoostAllowed(classFilename));
	elseif button.characterType == LE_CHARACTER_CREATE_TYPE_NORMAL then
		startingLevel = GetClassTypeData(classFilename).startingLevel;
	end

	button.levelText:SetText(CHARACTER_TYPE_FRAME_STARTING_LEVEL:format(startingLevel));
end

function CharacterCreate_TypeButtonOnLoad(self)
	self.typeText:SetText(self.titleText);
end

function CharacterCreate_UpdateCharacterTypeButtons()
	local _, classFilename = GetSelectedClass();

	for index, button in ipairs(CharCreateCharacterTypeFrame.typeButtons) do
		UpdateLevelText(button, classFilename);
	end

	if CharCreateCharacterTypeFrame:IsShown() then
		local isTrialBoost = GetCharacterCreateType() == LE_CHARACTER_CREATE_TYPE_TRIAL_BOOST;
		if isTrialBoost and not IsBoostAllowed(classFilename) then
			CharacterCreate_SelectCharacterType(LE_CHARACTER_CREATE_TYPE_NORMAL);
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
	if (characterType == LE_CHARACTER_CREATE_TYPE_BOOST)
	 or (not CharCreateCharacterTypeFrame.allowShowing)
	 or (not C_CharacterServices.IsTrialBoostEnabled())
	 or (PAID_SERVICE_TYPE ~= nil)
	 or IsUsingCharacterTemplate()
	 or IsForcingCharacterTemplate()
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

	characterType = characterType or LE_CHARACTER_CREATE_TYPE_NORMAL;

	SetCharacterCreateType(characterType);
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

	if (characterType == LE_CHARACTER_CREATE_TYPE_TRIAL_BOOST) then
		C_SharedCharacterServices.QueryClassTrialBoostResult();
	end
end

function CharacterCreate_TypeButtonOnClick(self)
	PlaySound("gsCharacterCreationClass"); -- TODO: Get more appropriate sound for this?
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
	local _, classFilename, classID = GetSelectedClass();
	local isTrialBoost = CharacterUpgrade_IsCreatedCharacterTrialBoost();
	local isCustomization = CharacterCreateFrame.state == "CUSTOMIZATION";
	local showTrialFrames = isTrialBoost and isCustomization and IsBoostAllowed(classFilename);

	local showSpecializations = showTrialFrames;
	local showFactions = showTrialFrames and IsNeutralRace(CharacterCreate.selectedRace);

	if showSpecializations then
		-- HACK:  GetSelectedSex and GetCharacterInfo return different enum types, this arbitrary - 1 compensates.
		-- TODO: Reconcile enums?
		local gender = GetSelectedSex() - 1;
		local allowAllSpecs = false;

		CharCreateSelectSpecFrame.classFilename = classFilename;
		CharacterServices_UpdateSpecializationButtons(classID, gender, CharCreateSelectSpecFrame, CharCreateSelectSpecFrame, allowAllSpecs, isTrialBoost);

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
local finalizeRequirements;

local function InitializeRequirementsFlow()
	if not finalizeRequirements then
		finalizeRequirements = CreateFromMixins(RequirementsFlowMixin);

		local setCompleteEnabled = function(enabled)
			CharCreate_EnableNextButton(enabled);
		end

		finalizeRequirements:Initialize(CharCreateOkayButton, setCompleteEnabled);

		finalizeRequirements:AddRequirement(FINALIZE_REQ_HAS_SPEC, CHARACTER_CREATION_REQUIREMENTS_PICK_SPEC);
		finalizeRequirements:AddRequirement(FINALIZE_REQ_HAS_FACTION, CHARACTER_CREATION_REQUIREMENTS_PICK_FACTION);
		finalizeRequirements:AddRequirement(FINALIZE_REQ_HAS_NAME, CHARACTER_CREATION_REQUIREMENTS_PICK_NAME);
	end
end

function CharacterCreate_UpdateOkayButton()
	InitializeRequirementsFlow();

	if CharacterCreateFrame.state == "CUSTOMIZATION" then
		finalizeRequirements:InstallScripts();
		finalizeRequirements:SetRequirementComplete(FINALIZE_REQ_HAS_NAME, CharacterCreateNameEdit:GetText() ~= "");

		local isTrialBoost = CharacterUpgrade_IsCreatedCharacterTrialBoost();
		finalizeRequirements:SetRequirementComplete(FINALIZE_REQ_HAS_SPEC, not isTrialBoost or CharCreateSelectSpecFrame.selected ~= nil);
		finalizeRequirements:SetRequirementComplete(FINALIZE_REQ_HAS_FACTION, not isTrialBoost or CharacterCreate_GetSelectedFaction() ~= nil);
		finalizeRequirements:UpdateInstructions();
	else
		finalizeRequirements:RemoveScripts();
		CharCreate_EnableNextButton(true);
	end
end

function CharacterCreate_IsTrialBoostAllowedForClass(classFilename)
	return IsBoostAllowed(classFilename);
end

function CharacterCreate_GetSelectedFaction()
	return CharacterCreate.selectedFactionID or CharCreateSelectFactionFrame.selected;
end