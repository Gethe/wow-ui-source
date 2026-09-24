NUM_STATS = 5;
MAX_SPELL_SCHOOLS = 7;

CR_UNUSED_1 = 1;
CR_DEFENSE_SKILL = 2;
CR_DODGE = 3;
CR_PARRY = 4;
CR_BLOCK = 5;
CR_HIT_MELEE = 6;
CR_HIT_RANGED = 7;
CR_HIT_SPELL = 8;
CR_CRIT_MELEE = 9;
CR_CRIT_RANGED = 10;
CR_CRIT_SPELL = 11;
CR_CORRUPTION = 12;
CR_CORRUPTION_RESISTANCE = 13;
CR_SPEED = 14;
COMBAT_RATING_RESILIENCE_CRIT_TAKEN = 15;
COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN = 16;
CR_LIFESTEAL = 17;
CR_HASTE_MELEE = 18;
CR_HASTE_RANGED = 19;
CR_HASTE_SPELL = 20;
CR_AVOIDANCE = 21;
CR_UNUSED_2 = 22;
CR_WEAPON_SKILL_RANGED = 23;
CR_EXPERTISE = 24;
CR_ARMOR_PENETRATION = 25;
CR_MASTERY = 26;
CR_UNUSED_3 = 27;
CR_UNUSED_4 = 28;
CR_VERSATILITY_DAMAGE_DONE = 29;
CR_VERSATILITY_DAMAGE_TAKEN = 31;

ATTACK_POWER_MAGIC_NUMBER = 3.5;
BLOCK_PER_STRENGTH = 0.5;
BASE_MOVEMENT_SPEED = 7;
CREATURE_HP_PER_STA = 10;

local BreakUpLargeNumbers = BreakUpLargeNumbers;

--Pet scaling:
HUNTER_PET_BONUS = {};
HUNTER_PET_BONUS["PET_BONUS_RAP_TO_AP"] = 0.22;
HUNTER_PET_BONUS["PET_BONUS_RAP_TO_SPELLDMG"] = 0.1287;
HUNTER_PET_BONUS["PET_BONUS_STAM"] = 0.3;
HUNTER_PET_BONUS["PET_BONUS_RES"] = 0.4;
HUNTER_PET_BONUS["PET_BONUS_ARMOR"] = 0.3;
HUNTER_PET_BONUS["PET_BONUS_SPELLDMG_TO_SPELLDMG"] = 0.0;
HUNTER_PET_BONUS["PET_BONUS_SPELLDMG_TO_AP"] = 0.0;
HUNTER_PET_BONUS["PET_BONUS_INT"] = 0.0;
HUNTER_PET_BONUS["PET_BONUS_AP_CONVERSION"] = 0.3;

WARLOCK_PET_BONUS = {};
WARLOCK_PET_BONUS["PET_BONUS_RAP_TO_AP"] = 0.0;
WARLOCK_PET_BONUS["PET_BONUS_RAP_TO_SPELLDMG"] = 0.0;
WARLOCK_PET_BONUS["PET_BONUS_STAM"] = 0.0; -- Pets no longer have primary attributes
WARLOCK_PET_BONUS["PET_BONUS_RES"] = 1.00;
WARLOCK_PET_BONUS["PET_BONUS_ARMOR"] = 0.35;
WARLOCK_PET_BONUS["PET_BONUS_SPELLDMG_TO_SPELLDMG"] = 0.1;
WARLOCK_PET_BONUS["PET_BONUS_SPELLDMG_TO_AP"] = 0.17;
WARLOCK_PET_BONUS["PET_BONUS_INT"] = 0.0; -- Pets no longer have primary attributes
WARLOCK_PET_BONUS["PET_BONUS_AP_CONVERSION"] = 0.17;

PLAYER_DISPLAYED_TITLES = 6;
PLAYER_TITLE_HEIGHT = 22;

DEFAULT_PET_MODEL_SCENE_ID = 1156;

EQUIPMENTSET_BUTTON_HEIGHT = 44;

local itemSlotButtons = {};

MOVING_STAT_CATEGORY = nil;

local StatCategoryFrames = {};

local STRIPE_COLOR = {r=0.9, g=0.9, b=1};

MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY = 10;

local ProfessionEquipError =
{
	[Enum.Profession.Blacksmithing] = PAPERDOLL_AUTO_EQUIP_BLACKSMITHING_ONLY,
	[Enum.Profession.Leatherworking] = PAPERDOLL_AUTO_EQUIP_LEATHERWORKING_ONLY,
	[Enum.Profession.Alchemy] = PAPERDOLL_AUTO_EQUIP_ALCHEMY_ONLY,
	[Enum.Profession.Herbalism] = PAPERDOLL_AUTO_EQUIP_HERBALISM_ONLY,
	[Enum.Profession.Cooking] = PAPERDOLL_AUTO_EQUIP_COOKING_ONLY,
	[Enum.Profession.Mining] = PAPERDOLL_AUTO_EQUIP_MINING_ONLY,
	[Enum.Profession.Tailoring] = PAPERDOLL_AUTO_EQUIP_TAILORING_ONLY,
	[Enum.Profession.Engineering] = PAPERDOLL_AUTO_EQUIP_ENGINEERING_ONLY,
	[Enum.Profession.Enchanting] = PAPERDOLL_AUTO_EQUIP_ENCHANTING_ONLY,
	[Enum.Profession.Fishing] = PAPERDOLL_AUTO_EQUIP_FISHING_ONLY,
	[Enum.Profession.Skinning] = PAPERDOLL_AUTO_EQUIP_SKINNING_ONLY,
	[Enum.Profession.Jewelcrafting] = PAPERDOLL_AUTO_EQUIP_JEWELCRAFTING_ONLY,
	[Enum.Profession.Inscription] = PAPERDOLL_AUTO_EQUIP_INSCRIPTION_ONLY,
};

function GetPaperDollSideBarFrame(tabIndex)
	if tabIndex == 1 then
		return CharacterFrame:GetStatsPane();
	elseif tabIndex == 2 then
		return PaperDollFrame.EquipmentManagerPane;
	elseif tabIndex == 3 then
		return CharacterStatsPanePetScrollBox;
	end
end

PAPERDOLL_STATINFO = {

	-- General
	["HEALTH"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetHealth(statFrame, unit); end
	},
	["POWER"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetPower(statFrame, unit); end
	},
	["ALTERNATEMANA"] = {
		-- Only appears for Druids when in shapeshift form
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetAlternateMana(statFrame, unit); end
	},
	["ITEMLEVEL"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetItemLevel(statFrame, unit); end
	},
	["MOVESPEED"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetMovementSpeed(statFrame, unit); end
	},

	-- Base stats
	["STRENGTH"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_STRENGTH); end
	},
	["AGILITY"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_AGILITY); end
	},
	["INTELLECT"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_INTELLECT); end
	},
	["STAMINA"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_STAMINA); end
	},
	["SPIRIT"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_SPIRIT); end
	},


	-- Enhancements
	["CRITCHANCE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetCritChance(statFrame, unit); end
	},
	["HASTE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetHaste(statFrame, unit); end
	},
	["MASTERY"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetMastery(statFrame, unit); end
	},
	["VERSATILITY"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetVersatility(statFrame, unit); end
	},
	["LIFESTEAL"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetLifesteal(statFrame, unit); end
	},
	["AVOIDANCE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetAvoidance(statFrame, unit); end
	},
	["SPEED"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetSpeed(statFrame, unit); end
	},
	["ARMORPEN"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetArmorPenetration(statFrame, unit); end
	},

	-- Attack
	["ATTACK_DAMAGE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetDamage(statFrame, unit); end
	},
	["ATTACK_AP"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetAttackPower(statFrame, unit); end
	},
	["RANGED_ATTACK_AP"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetRangedAttackPower(statFrame, unit); end
	},
	["ATTACK_ATTACKSPEED"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetAttackSpeed(statFrame, unit); end
	},
	["ENERGY_REGEN"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetEnergyRegen(statFrame, unit); end
	},
	["RUNE_REGEN"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetRuneRegen(statFrame, unit); end
	},
	["FOCUS_REGEN"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetFocusRegen(statFrame, unit); end
	},
	["MAINHAND_DAMAGE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetMainhandDamage(statFrame, unit); end
	},
	["OFFHAND_DAMAGE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetOffhandDamage(statFrame, unit); end
	},
	["RANGED_DAMAGE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetRangedDamage(statFrame, unit); end
	},
	["EXPERTISE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetExpertise(statFrame, unit, true); end
	},
	["HITCHANCE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetHitChance(statFrame, unit); end
	},
	["HITCHANCE_MELEE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetMeleeHitChance(statFrame, unit); end
	},
	["HITCHANCE_RANGED"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetRangedHitChance(statFrame, unit); end
	},
	["HITCHANCE_SPELL"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetSpellHitChance(statFrame, unit); end
	},


	-- Spell
	["SPELLPOWER"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetSpellPower(statFrame, unit); end
	},
	["SPELLHEALING"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetSpellHealing(statFrame, unit); end
	},
	["MANAREGEN"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetManaRegen(statFrame, unit); end
	},
	["SPELLPENETRATION"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetSpellPenetration(statFrame, unit); end
	},

	-- Defense
	["DEFENSE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetDefense(statFrame, unit); end
	},
	["ARMOR"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetArmor(statFrame, unit); end
	},
	["DODGE"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetDodge(statFrame, unit); end
	},
	["PARRY"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetParry(statFrame, unit); end
	},
	["BLOCK"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetBlock(statFrame, unit); end
	},
	["STAGGER"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetStagger(statFrame, unit); end
	},

	-- Resistances
	["HOLY_RESIST"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetResistance(statFrame, unit, Enum.Damageclass.Holy); end
	},
	["FIRE_RESIST"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetResistance(statFrame, unit, Enum.Damageclass.Fire); end
	},
	["NATURE_RESIST"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetResistance(statFrame, unit, Enum.Damageclass.Nature); end
	},
	["FROST_RESIST"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetResistance(statFrame, unit, Enum.Damageclass.Frost); end
	},
	["SHADOW_RESIST"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetResistance(statFrame, unit, Enum.Damageclass.Shadow); end
	},
	["ARCANE_RESIST"] = {
		updateFunc = function(statFrame, unit) return PaperDollFrame_SetResistance(statFrame, unit, Enum.Damageclass.Arcane); end
	},

	-- Weapon Skills
	["WEAPON_SKILL"] = {
		updateFunc = function(statFrame, unit, id) return PaperDollFrame_SetWeaponSkill(statFrame, unit, id); end
	},
};

-- Task 67449: Hit and Expertise are being removed from items, so all players receive a 7.5% reduced miss chance,
--			   a 15% reduced spell miss chance, a 7.5% reduced enemy dodge chance, and a 4.5% reduced enemy parry chance
BASE_MISS_CHANCE_PHYSICAL = {
	[0] = -4.5;
	[1] = -3.0;
	[2] = -1.5;
	[3] = 0.0;
};

BASE_MISS_CHANCE_SPELL = {
	[0] = -9.0;
	[1] = -6.0;
	[2] = -3.0;
	[3] = 0.0;
};

BASE_ENEMY_DODGE_CHANCE = {
	[0] = -4.5;
	[1] = -3.0;
	[2] = -1.5;
	[3] = 0.0;
};

BASE_ENEMY_PARRY_CHANCE = {
	[0] = -1.5;
	[1] = 0.0;
	[2] = 1.5;
	[3] = 3.0;
};

DUAL_WIELD_HIT_PENALTY = 19.0;

function PaperDollFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterUnitEvent("UNIT_STATS", "player");
	self:RegisterUnitEvent("UNIT_RANGEDDAMAGE", "player");
	self:RegisterUnitEvent("UNIT_RANGED_ATTACK_POWER", "player");
	self:RegisterUnitEvent("UNIT_ATTACK", "player");
	self:RegisterUnitEvent("UNIT_SPELL_HASTE", "player");
	self:RegisterUnitEvent("UNIT_PET", "player");
	self:RegisterUnitEvent("UNIT_PET_EXPERIENCE", "player");
	self:RegisterEvent("PET_STATS_UPDATE");
	self:RegisterUnitEvent("UNIT_RESISTANCES", "player");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("COMBAT_RATING_UPDATE");
	self:RegisterEvent("MASTERY_UPDATE");
	self:RegisterEvent("SPEED_UPDATE");
	self:RegisterEvent("LIFESTEAL_UPDATE");
	self:RegisterEvent("AVOIDANCE_UPDATE");
	self:RegisterEvent("KNOWN_TITLES_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE");
	self:RegisterEvent("PLAYER_DAMAGE_DONE_MODS");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self:RegisterUnitEvent("UNIT_DAMAGE", "player");
	self:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player");
	self:RegisterUnitEvent("UNIT_MAXHEALTH", "player");
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("SPELL_POWER_CHANGED");
	self:RegisterEvent("CHARACTER_ITEM_FIXUP_NOTIFICATION");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("GX_RESTARTED");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");

	-- flyout settings
	PaperDollItemsFrame.flyoutSettings = {
		onClickFunc = PaperDollFrameItemFlyoutButton_OnClick,
		getItemsFunc = PaperDollFrameItemFlyout_GetItems,
		postGetItemsFunc = PaperDollFrameItemFlyout_PostGetItems,
		hasPopouts = true,
		parent = PaperDollFrame,
		anchorX = 0,
		anchorY = -3,
		verticalAnchorX = 0,
		verticalAnchorY = 0,
	};

	-- trial edition
	if( GameLimitedMode_IsActive() ) then
		CharacterTrialLevelErrorText:SetText(CAPPED_LEVEL_TRIAL);
	end

	PaperDollSidebarTab1.Icon:SetTexCoord(0.03125, 0.96875, 0.03125, 0.96875);
	PaperDollSidebarTab1.Icon:SetSize(36, 33);
	PaperDollSidebarTab1.Icon:SetPoint("CENTER", 0, 0);

	PaperDollSidebarTab3.Icon:SetSize(36, 33);
	PaperDollSidebarTab3.Icon:SetPoint("CENTER", 0, 0);

	self:RegisterForInterfaceTransitions();
end

function PaperDoll_IsEquippedSlot(slot)
	if ( slot ) then
		slot = tonumber(slot);
		if ( slot ) then
			if (EQUIPPED_FIRST and EQUIPPED_LAST) then
				return slot >= EQUIPPED_FIRST and slot <= EQUIPPED_LAST;
			else
				return slot >= INVSLOT_FIRST_EQUIPPED and slot <= INVSLOT_LAST_EQUIPPED;
			end
		end
	end

	return false;
end

-- This makes sure the update only happens once at the end of the frame
function PaperDollFrame_QueuedUpdate(self)
	self:SetScript("OnUpdate", nil);
	PaperDollFrame_UpdateStats();
end

function PaperDollFrame_OnEvent(self, event, ...)
	local unit = ...;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		SetPortraitTexture(PaperDollSidebarTab1.Icon, "player");
		return;
	elseif ( event == "PORTRAITS_UPDATED" ) then
		SetPortraitTexture(PaperDollSidebarTab1.Icon, "player");
		return;
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( unit == "player" ) then
			SetPortraitTexture(PaperDollSidebarTab1.Icon, "player");
		end
		return;
	elseif ( event == "GX_RESTARTED" ) then
		return;
	elseif ( event == "UNIT_MODEL_CHANGED" and unit == "player" ) then
		PaperDollFrame_SetPlayer();
		return;
	elseif ( event == "KNOWN_TITLES_UPDATE" or (event == "UNIT_NAME_UPDATE" and unit == "player")) then
		if (PaperDollFrame.TitleManagerPane:IsShown()) then
			PaperDollTitlesPane_Update();
		end
	end

	if ( not self:IsVisible() ) then
		return;
	end

	if ( unit == "player" ) then
		if ( event == "UNIT_LEVEL" ) then
			PaperDollFrame_SetLevel();
		elseif ( event == "UNIT_DAMAGE" or
				event == "UNIT_ATTACK_SPEED" or
				event == "UNIT_RANGEDDAMAGE" or
				event == "UNIT_ATTACK" or
				event == "UNIT_STATS" or
				event == "UNIT_RANGED_ATTACK_POWER" or
				event == "UNIT_SPELL_HASTE" or
				event == "UNIT_MAXHEALTH" or
				event == "UNIT_AURA" or
				event == "UNIT_RESISTANCES") then
			self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
		end
	end

	if event == "UNIT_PET" then
		PaperDollFrame_UpdateSidebarTabs();

		if HasPetUI() then
			if PetPaperDollPetHappinessInfo:IsShown() then
				PaperDollFrame_SetPet();
				PaperDollFrame_SetPetLevel(); -- Also updates the "Level 60 Imp" text as well
			end
		else
			PaperDollFrame_SetSidebar(PaperDollSidebarTabs, PaperDollSidebarTab1:GetID());
		end
	end

	if event == "UNIT_PET_EXPERIENCE" then
		PaperDollFrame_UpdateSidebarTabs();

		if HasPetUI() then
			if PetPaperDollPetHappinessInfo:IsShown() then
				PaperDollFrame_SetPetLevel();
			end
		end
	end

	if event == "PET_STATS_UPDATE" and CharacterStatsPanePetScrollBox:IsShown() then
		self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
	end

	if ( event == "COMBAT_RATING_UPDATE" or
			event == "MASTERY_UPDATE" or
			event == "SPEED_UPDATE" or
			event == "LIFESTEAL_UPDATE" or
			event == "AVOIDANCE_UPDATE" or
			event == "BAG_UPDATE" or
			event == "PLAYER_EQUIPMENT_CHANGED" or
			event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" or
			event == "PLAYER_DAMAGE_DONE_MODS" or
			event == "PLAYER_TARGET_CHANGED") then
		self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
	elseif (event == "PLAYER_TALENT_UPDATE") then
		PaperDollFrame_SetLevel();
		self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
	elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then
		PaperDollFrame_UpdateStats();
	elseif ( event == "SPELL_POWER_CHANGED" ) then
		self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
	elseif ( event == "TRIAL_STATUS_UPDATE" ) then
		PaperDollFrame_SetLevel();
	end
end

function PaperDollFrame_SetLevel()
	local primaryTalentTree = C_SpecializationInfo.GetSpecialization();
	local classDisplayName, class, classID = UnitClass("player");
	local classColorString = RAID_CLASS_COLORS[class].colorStr;
	local specName, _;

	if (primaryTalentTree and C_SpecializationInfo.IsSpecSelectionEnabled(classID)) then
		_, specName = C_SpecializationInfo.GetSpecializationInfo(primaryTalentTree, false, false, nil, UnitSex("player"));
	end

	local level = UnitLevel("player");
	local effectiveLevel = UnitEffectiveLevel("player");

	if ( effectiveLevel ~= level ) then
		level = EFFECTIVE_LEVEL_FORMAT:format(effectiveLevel, level);
	end

	if (specName and specName ~= "") then
		CharacterLevelText:SetFormattedText(PLAYER_LEVEL, level, classColorString, specName, classDisplayName);
	else
		CharacterLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, level, classColorString, classDisplayName);
	end

	local showTrialCap = false;
	if (GameLimitedMode_IsActive()) then
		local rLevel = GetRestrictedAccountData();
		if (UnitLevel("player") >= rLevel) then
			showTrialCap = true;
		end
	end

	CharacterTrialLevelErrorText:SetShown(showTrialCap);

	PetLoyaltyText:Hide();
end

function PaperDollFrame_SetPetLevel()
	if not HasPetUI() then
		return;
	end
	if ( UnitCreatureFamily("pet") ) then
		CharacterLevelText:SetFormattedText(UNIT_TYPE_LEVEL_TEMPLATE, UnitLevel("pet"), UnitCreatureFamily("pet"));
	end

	local exp, expNeeded = GetPetExperience();

	if expNeeded > 0 then
		PetPaperDollFrameExpBar:Show();
	else
		PetPaperDollFrameExpBar:Hide();
	end

	if C_PetInfo.GetPetLoyalty() then
		CharacterLevelText:SetFormattedText(UNIT_TYPE_LEVEL_TEMPLATE, UnitLevel("pet"), UnitCreatureFamily("pet") or "");
		PetLoyaltyText:SetText(C_PetInfo.GetPetLoyalty());
		PetLoyaltyText:Show();
		PaperDollLevelInfo:SetHeight(40);
	else
		PetLoyaltyText:Hide();
		PaperDollLevelInfo:SetHeight(20);
	end

end

function GetEnemyDodgeChance(levelOffset)
	if (levelOffset < 0 or levelOffset > 3) then
		return 0;
	end
	local chance = BASE_ENEMY_DODGE_CHANCE[levelOffset];
	local offhandChance = BASE_ENEMY_DODGE_CHANCE[levelOffset];
	local rangedChance = BASE_ENEMY_DODGE_CHANCE[levelOffset];
	local expertisePct, offhandExpertisePct, rangedExpertisePct = GetExpertise();
	chance = chance - expertisePct;
	offhandChance = offhandChance - offhandExpertisePct;
	rangedChance = rangedChance - rangedExpertisePct;

	if (chance < 0) then
		chance = 0;
	elseif (chance > 100) then
		chance = 100;
	end
	if (offhandChance < 0) then
		offhandChance = 0;
	elseif (offhandChance > 100) then
		offhandChance = 100;
	end
	if (rangedChance < 0) then
		rangedChance = 0;
	elseif (rangedChance > 100) then
		rangedChance = 100;
	end
	return chance, offhandChance, rangedChance;
end

function GetEnemyParryChance(levelOffset)
	if (levelOffset < 0 or levelOffset > 3) then
		return 0;
	end
	local chance = BASE_ENEMY_PARRY_CHANCE[levelOffset];
	local offhandChance = BASE_ENEMY_PARRY_CHANCE[levelOffset];
	local expertisePct, offhandExpertisePct = GetExpertise();
	local mainhandDodge = BASE_ENEMY_DODGE_CHANCE[levelOffset];
	local offhandDodge = BASE_ENEMY_DODGE_CHANCE[levelOffset];

	expertisePct = expertisePct - mainhandDodge;
	if ( expertisePct < 0 ) then
		expertisePct = 0;
	end
	chance = chance - expertisePct;
	if (chance < 0) then
		chance = 0;
	elseif (chance > 100) then
		chance = 100;
	end

	offhandExpertisePct = offhandExpertisePct - offhandDodge;
	if ( offhandExpertisePct < 0 ) then
		offhandExpertisePct = 0;
	end
	offhandChance = offhandChance - offhandExpertisePct;
	if (offhandChance < 0) then
		offhandChance = 0;
	elseif (offhandChance > 100) then
		offhandChance = 100;
	end

	return chance, offhandChance;
end

function PaperDollFrame_SetHealth(statFrame, unit)
	if (not unit) then
		unit = "player";
	end
	local health = UnitHealthMax(unit);
	local healthText = BreakUpLargeNumbers(health);
	PaperDollFrame_SetLabelAndText(statFrame, HEALTH, healthText, false, health);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, HEALTH).." "..healthText..FONT_COLOR_CODE_CLOSE;
	if (unit == "player") then
		statFrame.tooltip2 = STAT_HEALTH_TOOLTIP;
	elseif (unit == "pet") then
		statFrame.tooltip2 = STAT_HEALTH_PET_TOOLTIP;
	end
	statFrame:Show();

	return health;
end

function PaperDollFrame_SetPower(statFrame, unit)
	if (not unit) then
		unit = "player";
	end
	local powerType, powerToken = UnitPowerType(unit);
	local power = UnitPowerMax(unit) or 0;
	local powerText = BreakUpLargeNumbers(power);
	if (powerToken and _G[powerToken]) then
		PaperDollFrame_SetLabelAndText(statFrame, _G[powerToken], powerText, false, power);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G[powerToken]).." "..powerText..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = _G["STAT_"..powerToken.."_TOOLTIP"];
		statFrame:Show();
	else
		statFrame:Hide();
	end

	return power;
end

function PaperDollFrame_SetAlternateMana(statFrame, unit)
	if (not unit) then
		unit = "player";
	end
	local _, class = UnitClass(unit);
	if (class ~= "DRUID" and (class ~= "MONK" or C_SpecializationInfo.GetSpecialization() ~= SPEC_MONK_MISTWEAVER)) then
		statFrame:Hide();
		return;
	end
	local powerType, powerToken = UnitPowerType(unit);
	if (powerToken == "MANA") then
		statFrame:Hide();
		return;
	end

	local power = UnitPowerMax(unit, 0);
	local powerText = BreakUpLargeNumbers(power);
	PaperDollFrame_SetLabelAndText(statFrame, MANA, powerText, false, power);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MANA).." "..powerText..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = _G["STAT_MANA_TOOLTIP"];
	statFrame:Show();

	return power;
end

function PaperDollFrame_SetStat(statFrame, unit, statIndex)

	local stat;
	local effectiveStat;
	local posBuff;
	local negBuff;
	stat, effectiveStat, posBuff, negBuff = UnitStat(unit, statIndex);

	local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
	local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat);
	PaperDollFrame_SetStatTooltip(statFrame, statName, stat, effectiveStatDisplay, posBuff, negBuff);

	-- If there are any negative buffs then show the main number in red even if there are
	-- positive buffs. Otherwise show in green.
	if ( negBuff < 0 and not GetPVPGearStatRules() ) then
		effectiveStatDisplay = RED_FONT_COLOR_CODE..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
	end

	PaperDollFrame_SetLabelAndText(statFrame, statName, effectiveStatDisplay, false, effectiveStat);
	PaperDollFrame_SetStatTooltip2(statFrame, statName, statIndex, effectiveStat, unit);
	statFrame:Show();

	return effectiveStat;
end

function PaperDollFrame_SetResistance(statFrame, unit, damageClass)
	local baseResistance, realResistance, effectiveResistance, bonusResistance = UnitResistance(unit, damageClass);
	local nameToken =  _G["RESISTANCE"..(damageClass).."_NAME"];
	PaperDollFrame_SetLabelAndText(statFrame, nameToken, BreakUpLargeNumbers(effectiveResistance), false, effectiveResistance);

	PaperDollFrame_SetResistanceTooltips(statFrame, nameToken, effectiveResistance, unit, damageClass);

	return effectiveResistance;
end

function PaperDollFrame_SetWeaponSkill(statFrame, unit, skillID)
	local skillInfo = C_SkillInfo.GetSkillLineInfoByID(skillID);

	if skillInfo then
		local text;
		if ( skillInfo.modifier == 0 ) then
			text = skillInfo.rank.."/"..skillInfo.maxRank;
		else
			text = skillInfo.rank.." ("..skillInfo.modifier..")/"..skillInfo.maxRank;
		end

		PaperDollFrame_SetLabelAndText(statFrame, skillInfo.name, text, false, skillInfo.value);
	end

	statFrame.tooltip = nil;
	statFrame.tooltip2 = nil;

	return skillInfo.value and skillInfo.value or 0;
end

function PaperDollFrame_SetDefense(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end
	local base, modifier = UnitDefenseSkill(unit);

	local posBuff = 0;
	local negBuff = 0;
	if ( modifier > 0 ) then
		posBuff = modifier;
	elseif ( modifier < 0 ) then
		negBuff = modifier;
	end

	local valueText, tooltipText = PaperDollFormatStat(DEFENSE, base, posBuff, negBuff);
	PaperDollFrame_SetLabelAndText(statFrame, DEFENSE, valueText, false, base);
	statFrame.tooltip = tooltipText;

	return base;
end

function PaperDollFrame_SetStagger(statFrame, unit)
	local stagger, staggerAgainstTarget = C_PaperDollInfo.GetStaggerPercentage(unit);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_STAGGER, BreakUpLargeNumbers(stagger), true, stagger);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAGGER).." "..string.format("%.2F%%",stagger)..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(STAT_STAGGER_TOOLTIP, stagger);
	if (staggerAgainstTarget) then
		statFrame.tooltip3 = format(STAT_STAGGER_TARGET_TOOLTIP, staggerAgainstTarget);
	else
		statFrame.tooltip3 = nil;
	end

	statFrame:Show();

	return stagger;
end

function PaperDollFrame_SetDodge(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide();
		return;
	end

	local chance = GetDodgeChance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_DODGE, format("%.1f%%", chance), false, chance);
	PaperDollFrame_SetDodgeTooltip(statFrame, chance);
	PaperDollFrame_SetDodgeTooltip2(statFrame, chance);
	statFrame:Show();

	return chance;
end

function PaperDollFrame_SetBlock(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide();
		return;
	end

	local chance = GetBlockChance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_BLOCK, chance, true, chance);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BLOCK_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;

	local shieldBlockArmor = GetShieldBlock();
	local blockArmorReduction = PaperDollFrame_GetArmorReduction(shieldBlockArmor, UnitEffectiveLevel(unit));
	local blockArmorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(shieldBlockArmor);

	statFrame.tooltip2 = CR_BLOCK_TOOLTIP:format(blockArmorReduction);
	if (blockArmorReductionAgainstTarget) then
		statFrame.tooltip3 = format(STAT_BLOCK_TARGET_TOOLTIP, blockArmorReductionAgainstTarget);
	else
		statFrame.tooltip3 = nil;
	end
	statFrame:Show();

	return chance;
end

function PaperDollFrame_SetParry(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide();
		return;
	end

	local chance = GetParryChance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, format("%.1f%%", chance), false, chance);
	PaperDollFrame_SetParryTooltip(statFrame, chance);
	PaperDollFrame_SetParryTooltip2(statFrame, chance)
	statFrame:Show();

	return chance;
end

function PaperDollFrame_SetResilience(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide();
		return;
	end

	local resilienceRating = BreakUpLargeNumbers(GetCombatRating(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN));
	local ratingBonus = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN);
	local damageReduction = ratingBonus + GetModResilienceDamageReduction();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_RESILIENCE, damageReduction, true, damageReduction);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_RESILIENCE).." "..format("%.2F%%", damageReduction)..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = RESILIENCE_TOOLTIP .. format(STAT_RESILIENCE_BASE_TOOLTIP, resilienceRating,
									ratingBonus);
	statFrame:Show();

	return damageReduction;
end

local function GetRangedDamage(unit)
	local attackTime, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage(unit);
	return minDamage, maxDamage, nil, nil, 0, 0, percent;
end

local function GetAppropriateDamage(unit)
	if IsRangedWeapon() then
		return GetRangedDamage(unit);
	else
		return UnitDamage(unit);
	end
end

function PaperDollFrame_GetDamage(unit, damageFunc, invType)
	local mainHandSpeed, offHandSpeed, rangedSpeed = UnitAttackSpeed(unit);
	local damageTable = { damageFunc(unit) };
	local minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent;

	local speed = mainHandSpeed; -- Want to default it to something

	if invType == INVTYPE_WEAPONMAINHAND then
		minDamage = damageTable[1];
		maxDamage = damageTable[2];
		speed = mainHandSpeed;
	elseif invType == INVTYPE_WEAPONOFFHAND then
		minDamage = damageTable[3];
		maxDamage = damageTable[4];
		speed = offHandSpeed;
	elseif invType == INVTYPE_RANGED then
		minDamage = damageTable[1];
		maxDamage = damageTable[2];
		speed = rangedSpeed;
	end

	physicalBonusPos = damageTable[5];
	physicalBonusNeg = damageTable[6];
	percent = damageTable[7];

	-- remove decimal points for display values
	local displayMin = max(floor(minDamage),1);
	local displayMinLarge = BreakUpLargeNumbers(displayMin);
	local displayMax = max(ceil(maxDamage),1);
	local displayMaxLarge = BreakUpLargeNumbers(displayMax);

	-- calculate base damage
	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local totalBonus = (fullDamage - baseDamage);
	-- set tooltip text with base damage
	local damageTooltip = BreakUpLargeNumbers(max(floor(minDamage),1)).." - "..BreakUpLargeNumbers(max(ceil(maxDamage),1));

	local colorPos = "|cff20ff20";
	local colorNeg = "|cffff2020";

	-- epsilon check
	if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
		totalBonus = 0.0;
	end

	local valueString;
	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then
			valueString = displayMinLarge.." - "..displayMaxLarge;
		else
			valueString = displayMinLarge.."-"..displayMaxLarge;
		end
	else
		-- set bonus color and display
		local color;
		if ( totalBonus > 0 ) then
			color = colorPos;
		else
			color = colorNeg;
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then
			valueString = color..displayMinLarge.." - "..displayMaxLarge.."|r";
		else
			valueString = color..displayMinLarge.."-"..displayMaxLarge.."|r";
		end
		if ( physicalBonusPos > 0 ) then
			damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
	end

	return valueString, displayMin, displayMax, damageTooltip, speed;
end

local function PaperDollFrame_CalculateDPS(minDamage, maxDamage, speed)
	minDamage = minDamage or 0;
	maxDamage = maxDamage or 0;
	speed = speed or 1;

	return (minDamage + maxDamage) / (2.0 * speed);
end

function PaperDollFrame_SetMainhandDamage(statFrame, unit)

	local displayName = (unit == "pet" and DAMAGE) or INVTYPE_WEAPONMAINHAND;

	local valueString, displayMin, displayMax, damageTooltip, speed = PaperDollFrame_GetDamage(unit, UnitDamage, INVTYPE_WEAPONMAINHAND);
	PaperDollFrame_SetLabelAndText(statFrame, displayName, valueString, false, displayMax);
	statFrame.damage = damageTooltip;
	statFrame.dps = string.format("%.1f", PaperDollFrame_CalculateDPS(displayMin, displayMax, speed));
	statFrame.attackSpeed = speed;
	statFrame.unit = unit;

	statFrame.onEnterFunc = CharacterDamageFrame_OnEnter;

	return displayMax;
end

function PaperDollFrame_SetOffhandDamage(statFrame, unit)

	if not IsDualWielding() then
		return 0;
	end

	local valueString, displayMin, displayMax, damageTooltip, speed = PaperDollFrame_GetDamage(unit, UnitDamage, INVTYPE_WEAPONOFFHAND);
	PaperDollFrame_SetLabelAndText(statFrame, INVTYPE_WEAPONOFFHAND, valueString, false, displayMax);
	statFrame.damage = damageTooltip;
	statFrame.dps = string.format("%.1f", PaperDollFrame_CalculateDPS(displayMin, displayMax, speed));
	statFrame.attackSpeed = speed;
	statFrame.tooltipLabel = INVTYPE_WEAPONOFFHAND;
	statFrame.unit = unit;

	statFrame.onEnterFunc = CharacterDamageFrame_OnEnter;

	return displayMax;
end

function PaperDollFrame_SetRangedDamage(statFrame, unit)

	if not PAPER_DOLL_FRAME_SHOW_RANGED_IF_UNEQUIPPED and unit == "player" and IsRangedWeapon() == false then
		return 0;
	end

	local valueString, displayMin, displayMax, damageTooltip, speed = PaperDollFrame_GetDamage(unit, GetRangedDamage, INVTYPE_RANGED);
	PaperDollFrame_SetLabelAndText(statFrame, INVTYPE_RANGED, valueString, false, displayMax);
	statFrame.damage = damageTooltip;
	statFrame.dps = string.format("%.1f", PaperDollFrame_CalculateDPS(displayMin, displayMax, speed));
	statFrame.attackSpeed = speed;
	statFrame.tooltipLabel = INVTYPE_RANGED;
	statFrame.unit = unit;

	statFrame.onEnterFunc = CharacterDamageFrame_OnEnter;

	return displayMax;
end

function PaperDollFrame_SetDamage(statFrame, unit)

	local valueString, displayMin, displayMax, damageTooltip, speed = PaperDollFrame_GetDamage(unit, GetAppropriateDamage);
	PaperDollFrame_SetLabelAndText(statFrame, DAMAGE, valueString, false, displayMax);
	statFrame.damage = damageTooltip;
	statFrame.attackSpeed = speed;
	statFrame.tooltipLabel = nil;
	statFrame.unit = unit;

	-- If there's an offhand speed then add the offhand info to the tooltip
	local offhandDamageString, offhandSpeed = PaperDollFrame_GetOffhandDamage(unit, GetAppropriateDamage);
	if offhandDamageString then
		statFrame.offhandDamage = offhandDamageString;
		statFrame.offhandAttackSpeed = offhandSpeed;
	end

	statFrame.onEnterFunc = CharacterDamageFrame_OnEnter;

	statFrame:Show();

	return displayMax;
end

function PaperDollFrame_SetAttackSpeed(statFrame, unit)
	local meleeHaste = GetMeleeHaste();
	local speed, offhandSpeed = UnitAttackSpeed(unit);

	local displaySpeed = format("%.2F", speed);
	if ( offhandSpeed ) then
		offhandSpeed = format("%.2F", offhandSpeed);
	end
	if ( offhandSpeed ) then
		displaySpeed =  displaySpeed.." / ".. offhandSpeed
	end
	PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste));

	statFrame:Show();

	return speed;
end

function PaperDollFrame_SetSpellPower(statFrame, unit)

	local _, className = UnitClass(unit);

	local minModifier = 0;
	local maxModifier = 0;

	if (unit == "player") then
		local holySchool = 2;
		-- Start at 2 to skip physical damage
		minModifier = GetSpellBonusDamage(holySchool);

		if (statFrame.bonusDamage) then
			table.wipe(statFrame.bonusDamage);
		else
			statFrame.bonusDamage = {};
		end
		statFrame.bonusDamage[holySchool] = minModifier;
		for i=(holySchool+1), MAX_SPELL_SCHOOLS do
			local bonusDamage = GetSpellBonusDamage(i);
			minModifier = min(minModifier, bonusDamage);
			maxModifier = max(maxModifier, bonusDamage);
			statFrame.bonusDamage[i] = bonusDamage;
		end
	elseif (unit == "pet") then
		minModifier = GetPetSpellBonusDamage();
		maxModifier = minModifier;
		statFrame.bonusDamage = nil;
	end

	PaperDollFrame_SetLabelAndText(statFrame, STAT_SPELLPOWER, BreakUpLargeNumbers(minModifier), false, minModifier);
	statFrame.tooltip = STAT_SPELLPOWER;

	if unit ~= "pet" then
		statFrame.tooltip2 = string.format(STAT_SPELLPOWER_TOOLTIP, maxModifier);
	else
		statFrame.tooltip2 = string.format(STAT_SPELLPOWER_PET_TOOLTIP, maxModifier);
	end

	statFrame.minModifier = minModifier;
	statFrame.unit = unit;
	statFrame.onEnterFunc = CharacterSpellBonusDamage_OnEnter;
	statFrame:Show();

	return minModifier;
end

function PaperDollFrame_SetSpellPenetration(statFrame, unit)

	local _, className = UnitClass(unit);

	local spellPen = GetSpellPenetration();

	if not UnitIsPlayer(unit) or spellPen == 0 then
		return 0;
	end

	local resistanceAverage = GetSpellPenetration() * 0.75 / (UnitLevel("player") * 5);
	local negativeResistanceAverage = resistanceAverage / 2.0;

	PaperDollFrame_SetLabelAndText(statFrame, format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPELL_PENETRATION) , spellPen, false, spellPen);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPELL_PENETRATION .. " " .. spellPen) .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = string.format(SPELL_PENETRATION_TOOLTIP, spellPen, resistanceAverage, negativeResistanceAverage);

	return tonumber(spellPen);
end

function PaperDollFrame_SetSpellHealing(statFrame, unit)
	local _, className = UnitClass(unit);

	local bonusHealing = GetSpellBonusHealing();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_SPELLHEALING, BreakUpLargeNumbers(bonusHealing), false, bonusHealing);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPELLHEALING).." "..BreakUpLargeNumbers(bonusHealing)..FONT_COLOR_CODE_CLOSE
	statFrame.tooltip2 = string.format(STAT_SPELLHEALING_TOOLTIP, bonusHealing);

	return bonusHealing;
end

local function GetSecondaryBonus(rating, base, bonusCoeff)
	-- For Legion Remix Timerunners, secondary stat bonuses all come from auras not actual stats
	-- BonusCoeff is only from mastery, all other call sights should be 1
	-- default bonus coeff call sights where we don't use this
	if PlayerIsTimerunning() then
		return base;
	end

	if not bonusCoeff then
		bonusCoeff = 1;
	end
	return (GetCombatRatingBonus(rating) * bonusCoeff);
end

function PaperDollFrame_SetEnergyRegen(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local powerType, powerToken = UnitPowerType(unit);
	if (powerToken ~= "ENERGY") then
		statFrame:Hide();
		return;
	end

	local regenRate = GetPowerRegen();
	local regenRateText = BreakUpLargeNumbers(regenRate);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_ENERGY_REGEN, regenRateText, false, regenRate);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_ENERGY_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = STAT_ENERGY_REGEN_TOOLTIP;
	statFrame:Show();

	return regenRate;
end

function PaperDollFrame_SetFocusRegen(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local powerType, powerToken = UnitPowerType(unit);
	if (powerToken ~= "FOCUS") then
		statFrame:Hide();
		return;
	end

	local regenRate = GetPowerRegen();
	local regenRateText = BreakUpLargeNumbers(regenRate);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_FOCUS_REGEN, regenRateText, false, regenRate);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_FOCUS_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = STAT_FOCUS_REGEN_TOOLTIP;
	statFrame:Show();

	return regenRate;
end

function PaperDollFrame_SetRuneRegen(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local _, class = UnitClass(unit);
	if (class ~= "DEATHKNIGHT") then
		statFrame:Hide();
		return;
	end

	local _, regenRate = GetRuneCooldown(1); -- Assuming they are all the same for now
	local regenRateText = (format(STAT_RUNE_REGEN_FORMAT, regenRate));
	PaperDollFrame_SetLabelAndText(statFrame, STAT_RUNE_REGEN, regenRateText, false, regenRate);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_RUNE_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = STAT_RUNE_REGEN_TOOLTIP;
	statFrame:Show();

	return regenRate;
end

function PaperDollFrame_SetManaRegen(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	if ( UnitPowerMax("player", Enum.PowerType.Mana) <= 0 ) then
		PaperDollFrame_SetLabelAndText(statFrame, MANA_REGEN, NOT_APPLICABLE, false, 0);
		statFrame.tooltip = nil;
		return;
	end

	local base, combat = GetManaRegen();
	-- All mana regen stats are displayed as mana/5 sec.
	base = floor(base * 5.0);
	combat = floor(combat * 5.0);
	local baseText = BreakUpLargeNumbers(base);
	local combatText = BreakUpLargeNumbers(combat);
	-- Combat mana regen is most important to the player, so we display it as the main value
	PaperDollFrame_SetLabelAndText(statFrame, MANA_REGEN, combatText, false, combat);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MANA_REGEN) .. " " .. combatText .. FONT_COLOR_CODE_CLOSE;
	-- Base (out of combat) regen is displayed only in the subtext of the tooltip
	statFrame.tooltip2 = format(MANA_REGEN_TOOLTIP, baseText);
	statFrame:Show();

	return combat;
end

function Mastery_OnEnter(statFrame)
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");

	local _, class = UnitClass("player");
	local mastery, bonusCoeff = GetMasteryEffect();
	local masteryBonus = GetSecondaryBonus(CR_MASTERY, mastery, bonusCoeff);

	local primaryTalentTree = C_SpecializationInfo.GetSpecialization();
	if (primaryTalentTree) then
		local masterySpells = C_SpecializationInfo.GetSpecializationMasterySpells(primaryTalentTree)
		local hasAddedAnyMasterySpell = false;
		for i, masterySpell in ipairs(masterySpells) do
			if hasAddedAnyMasterySpell then
				GameTooltip:AppendInfoWithSpacer("GetSpellByID", masterySpell);
			else
				GameTooltip:AppendInfo("GetSpellByID", masterySpell);
				hasAddedAnyMasterySpell = true;
			end
		end
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_MASTERY)), masteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	else
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_MASTERY)), masteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(STAT_MASTERY_TOOLTIP_NO_TALENT_SPEC, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
	end
	statFrame.UpdateTooltip = statFrame.onEnterFunc;
	GameTooltip:Show();
end

function PaperDollFrame_SetMastery(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local mastery = GetMasteryEffect();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_MASTERY, mastery, true, mastery);
	statFrame.onEnterFunc = Mastery_OnEnter;
	statFrame:Show();

	return mastery;
end

-- Task 68016: Speed increases run speed
function PaperDollFrame_SetSpeed(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local speed = GetSpeed();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_SPEED, speed, true, speed);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPEED) .. " " .. format("%.2F%%", speed) .. FONT_COLOR_CODE_CLOSE;

	statFrame.tooltip2 = format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED));

	statFrame:Show();

	return speed;
end

-- Task 68016: Lifesteal returns a portion of all damage done as health
function PaperDollFrame_SetLifesteal(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local lifesteal = GetLifesteal();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_LIFESTEAL, lifesteal, true, lifesteal);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL) .. " " .. format("%.2F%%", lifesteal) .. FONT_COLOR_CODE_CLOSE;

	statFrame.tooltip2 = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)), GetCombatRatingBonus(CR_LIFESTEAL));

	statFrame:Show();

	return lifesteal;
end

-- Task 68016: Avoidance reduces AoE damage taken
function PaperDollFrame_SetAvoidance(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local avoidance = GetAvoidance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_AVOIDANCE, avoidance, true, avoidance);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVOIDANCE) .. " " .. format("%.2F%%", avoidance) .. FONT_COLOR_CODE_CLOSE;

	statFrame.tooltip2 = format(CR_AVOIDANCE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_AVOIDANCE)), GetCombatRatingBonus(CR_AVOIDANCE));

	statFrame:Show();

	return avoidance;
end

function PaperDollFrame_SetVersatility(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_VERSATILITY, versatilityDamageBonus, true, versatilityDamageBonus);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_VERSATILITY)..FONT_COLOR_CODE_CLOSE;

	statFrame.tooltip2 = format(CR_VERSATILITY_TOOLTIP, versatilityDamageBonus, versatilityDamageTakenReduction, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction);

	statFrame:Show();

	return versatilityDamageBonus;
end

function PaperDollFrame_SetItemLevel(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel();
	local minItemLevel = C_PaperDollInfo.GetMinItemLevel();

	local displayItemLevel = math.max(minItemLevel or 0, avgItemLevelEquipped);

	displayItemLevel = floor(displayItemLevel);
	avgItemLevel = floor(avgItemLevel);

	PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, displayItemLevel, false, displayItemLevel);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..avgItemLevel;
	if ( displayItemLevel ~= avgItemLevel ) then
		statFrame.tooltip = statFrame.tooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, avgItemLevelEquipped);
	end
	statFrame.tooltip = statFrame.tooltip .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP;

	if ( avgItemLevel ~= avgItemLevelPvP ) then
		statFrame.tooltip2 = statFrame.tooltip2.."\n\n"..STAT_AVERAGE_PVP_ITEM_LEVEL:format(avgItemLevelPvP);
	end

	return displayItemLevel;
end

function MovementSpeed_OnEnter(statFrame)
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MOVEMENT_SPEED).." "..format("%d%%", statFrame.speed+0.5)..FONT_COLOR_CODE_CLOSE);

	GameTooltip:AddLine(format(STAT_MOVEMENT_GROUND_TOOLTIP, statFrame.runSpeed+0.5));
	if (PaperDollFrame_ShowFlightSpeed() and statFrame.unit ~= "pet") then
		GameTooltip:AddLine(format(STAT_MOVEMENT_FLIGHT_TOOLTIP, statFrame.flightSpeed+0.5));
	end
	GameTooltip:AddLine(format(STAT_MOVEMENT_SWIM_TOOLTIP, statFrame.swimSpeed+0.5));
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED)));
	GameTooltip:Show();

	statFrame.UpdateTooltip = MovementSpeed_OnEnter;
end

function MovementSpeed_OnUpdate(statFrame, elapsedTime)
	local unit = statFrame.unit;
	local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed(unit);
	runSpeed = runSpeed/BASE_MOVEMENT_SPEED*100;
	flightSpeed = flightSpeed/BASE_MOVEMENT_SPEED*100;
	swimSpeed = swimSpeed/BASE_MOVEMENT_SPEED*100;

	-- Pets seem to always actually use run speed
	if (unit == "pet") then
		swimSpeed = runSpeed;
	end

	-- Determine whether to display running, flying, or swimming speed
	local speed = runSpeed;
	local swimming = IsSwimming(unit);
	if (swimming) then
		speed = swimSpeed;
	elseif (IsFlying(unit)) then
		speed = flightSpeed;
	end

	-- Hack so that your speed doesn't appear to change when jumping out of the water
	if (IsFalling(unit)) then
		if (statFrame.wasSwimming) then
			speed = swimSpeed;
		end
	else
		statFrame.wasSwimming = swimming;
	end

	local valueText = format("%d%%", speed+0.5);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_MOVEMENT_SPEED, valueText, false, speed);
	statFrame.speed = speed;
	statFrame.runSpeed = runSpeed;
	statFrame.flightSpeed = flightSpeed;
	statFrame.swimSpeed = swimSpeed;
end

function PaperDollFrame_SetMovementSpeed(statFrame, unit)
	statFrame.wasSwimming = nil;
	statFrame.unit = unit;
	statFrame:Show();
	MovementSpeed_OnUpdate(statFrame);

	statFrame.onEnterFunc = MovementSpeed_OnEnter;

	return true;
end

function CharacterSpellBonusDamage_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, self.tooltip).." "..BreakUpLargeNumbers(self.minModifier)..FONT_COLOR_CODE_CLOSE);

	for i=2, MAX_SPELL_SCHOOLS do
		if (self.bonusDamage and self.bonusDamage[i] ~= self.minModifier) then
			GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G["DAMAGE_SCHOOL"..i]).." "..self.bonusDamage[i]..FONT_COLOR_CODE_CLOSE, nil, nil, nil, true );
			GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..i);
		end
	end

	GameTooltip:AddLine(self.tooltip2, nil, nil, nil, true );

	if (self.bonusDamage and self.unit == "player") then
		local petStr, damage;
		if (self.bonusDamage[6] == self.minModifier and self.bonusDamage[3] == self.minModifier) then
			petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG;
			damage = self.minModifier;
		elseif( self.bonusDamage[6] > self.bonusDamage[3] ) then
			petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG_SHADOW;
			damage = self.bonusDamage[6];
		else
			petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG_FIRE;
			damage = self.bonusDamage[3];
		end

		local petBonusAP = math.floor(ComputePetBonus("PET_BONUS_SPELLDMG_TO_AP", damage ));
		local petBonusDmg = math.floor(ComputePetBonus("PET_BONUS_SPELLDMG_TO_SPELLDMG", damage ));
		if( petBonusAP > 0 or petBonusDmg > 0 ) then
			GameTooltip:AddLine(format(petStr, petBonusAP, petBonusDmg), nil, nil, nil, true );
		end
	end
	GameTooltip:Show();
end

function PaperDollFrame_SetPlayer()
	ModelSceneUtil.SetUpCharacterSheetScene(CharacterModelScene);
end

function PaperDollFrame_OnShow(self)
	CharacterStatsPane.initialOffsetY = 0;
	PaperDollFrame_SetLevel();
	PaperDollFrame_UpdateStats();

	if (UnitHasRelicSlot("player")) then
		CharacterAmmoSlot:Hide();
	else
		CharacterAmmoSlot:Show();
	end

	PaperDollFrame_SetSidebar(PaperDollSidebarTabs, PaperDollSidebarTab1:GetID());
	CharacterFrame:Expand();

	SetPaperDollBackground(CharacterModelScene, "player");
	PaperDollBgDesaturate(true);
	PaperDollSidebarTabs:SetShown(not CharacterFrame:IsRightPaneCollapsed());

	if not InputUtil.IsGamepadUIEnabled() then
		CharacterModelScene.ControlFrame:Show();
	end
	CharacterModelScene.ControlFrame:SetModelScene(CharacterModelScene);

	PaperDollFrame_SetPlayer();
	self:RegisterEvent("UNIT_MODEL_CHANGED");

	local shown = true;
	EventRegistry:TriggerEvent("PaperDollFrame.VisibilityUpdated", shown);
end

function PaperDollFrame_OnHide(self)
	CharacterStatsPane.initialOffsetY = 0;
	CharacterFrame:Collapse();
	PaperDollSidebarTabs:Hide();
	PaperDollFrame_HideInventoryFixupComplete(self);
	self:UnregisterEvent("UNIT_MODEL_CHANGED");

	local shown = false;
	EventRegistry:TriggerEvent("PaperDollFrame.VisibilityUpdated", shown);
end

function PaperDollFrame_ClearIgnoredSlots()
	C_EquipmentSet.ClearIgnoredSlotsForSave();
	for k, button in next, itemSlotButtons do
		if ( button.ignored ) then
			button.ignored = nil;
			PaperDollItemSlotButton_Update(button);
		end
	end
end

function PaperDollFrame_IgnoreSlotsForSet(setID)
	local set = C_EquipmentSet.GetIgnoredSlots(setID);
	for slot, ignored in pairs(set) do
		if ( ignored ) then
			C_EquipmentSet.IgnoreSlotForSave(slot);
			itemSlotButtons[slot].ignored = true;
		else
			C_EquipmentSet.UnignoreSlotForSave(slot);
			itemSlotButtons[slot].ignored = false;
		end
		PaperDollItemSlotButton_Update(itemSlotButtons[slot]);
	end
end

function PaperDollFrame_IgnoreSlot(slot)
	C_EquipmentSet.IgnoreSlotForSave(slot);
	itemSlotButtons[slot].ignored = true;
	PaperDollItemSlotButton_Update(itemSlotButtons[slot]);
end

function PaperDollFrame_UpdateCorruptedItemGlows(glow)
	for _, button in next, itemSlotButtons do
		if button.HasPaperDollAzeriteItemOverlay then
			button:UpdateCorruptedGlow(ItemLocation:CreateFromEquipmentSlot(button:GetID()), glow);
		end
	end
end

PaperDollFrameMixin = {};

function PaperDollFrameMixin:RepairSingleItemContextAction()
	local button = SmartNavigation:GetCurrentButton();
	button:Click();
end

function PaperDollFrameMixin:IsRepairSingleItemButtonContextActionValid()
	local button = SmartNavigation:GetCurrentButton();
	if InRepairMode() then
		local itemID = button:GetID();
		local durability, maxDurability = GetInventoryItemDurability(itemID);
		return durability and maxDurability and durability < maxDurability;
	end
	return false;
end

function PaperDollFrameMixin:OpenEquipmentFlyoutForFocusedButton()
	local equipmentSlot = SmartNavigation:GetCurrentButton();
	local equipmentSlotPopoutButton = equipmentSlot.popoutButton;
	equipmentSlotPopoutButton:Click();
end

function PaperDollFrameMixin:IsOpenEquipmentFlyoutButtonContextActionValid()
	local button = SmartNavigation:GetCurrentButton();

	-- Invalidate action if single repair is active.
	if InRepairMode() or SpellCanTargetItem() then
		return false;
	end

	local getItemsFunc = self.ItemsFrame.flyoutSettings.getItemsFunc;
	local postGetItemsFunc = self.ItemsFrame.flyoutSettings.postGetItemsFunc;
	local itemsTable = {};
	local itemID = button:GetID();
	getItemsFunc(itemID, itemsTable);

	if (next(itemsTable) ~= nil) then
		return true;
	end

	if (postGetItemsFunc) then
		local specialItemsTable = {};
		--[[
			We don't really care about the buttons that are added, just that there is
			something that will display in the equipment flyout when opened for smart nav
			to land on.
		]]
		local numSpecialItemsAdded = postGetItemsFunc(button, specialItemsTable, 0);
		return numSpecialItemsAdded > 0;
	end

	return false;
end

function PaperDollFrameMixin:FocusCharacterView()
	CharacterFrame:FocusCharacterView();
end

function PaperDollFrameMixin:ShowCharacterViewLegend()
	self.CharacterViewerFooter:ShowAndActivateBindings();
	GamepadMode.ActivateBindingGroup(self.characterViewerBindings);
	self.stickUpdateFrame:SetScript("OnUpdate", self.stickUpdateFrame.Update);
	self.CharacterModelScene.GamepadFocusIndicator:Show();
end

function PaperDollFrameMixin:HideCharacterViewLegend()
	self.CharacterViewerFooter:HideAndDeactivateBindings();
	GamepadMode.DeactivateBindingGroup(self.characterViewerBindings);
	self.stickUpdateFrame:SetScript("OnUpdate", nil);
	self.CharacterModelScene.GamepadFocusIndicator:Hide();
end

function PaperDollFrameMixin:ResetCharacterView()
	self.CharacterModelScene:Reset();
end

function PaperDollFrameMixin:ExitCharacterView()
	CharacterFrame:UnfocusCharacterView();
end

function PaperDollFrameMixin:OnLeftStick(inX, inY)
	self.panVector:SetXY(inX, inY);
	self.panVector:ScaleBy(150);

	return false;
end

function PaperDollFrameMixin:OnRightStick(inX, inY)
	self.zoomSpeed = inY * 1;
	self.rotationSpeed = inX * 5;

	return false;
end

function PaperDollFrameMixin:UpdateForSticks(delta)
	local camera = self.CharacterModelScene:GetActiveCamera();
	if camera and camera:GetCameraType() == "OrbitCamera" then
		local panX, panY = self.panVector:GetXY();

		camera:HandleMouseMovement(ORBIT_CAMERA_MOUSE_PAN_HORIZONTAL, panX * delta);
		camera:HandleMouseMovement(ORBIT_CAMERA_MOUSE_PAN_VERTICAL, -panY * delta);
		camera:HandleMouseMovement(ORBIT_CAMERA_MOUSE_MODE_YAW_ROTATION, self.rotationSpeed * delta);
		camera:HandleMouseMovement(ORBIT_CAMERA_MOUSE_MODE_ZOOM, self.zoomSpeed * delta);
	end
end

function PaperDollFrameMixin:SetupGamepad()

	-- Character Viewer Actions
	self.panVector = CreateVector2D(0,0);
	self.zoomSpeed = 0;
	self.rotationSpeed = 0;

	-- Making separte frame to handle the stick updates as the paperdoll frame already uses its update to handle updating after events.
	self.stickUpdateFrame = CreateFrame("Frame", nil, self);
	self.stickUpdateFrame.Update = function(_, delta)
		self:UpdateForSticks(delta);
	end

	self.characterViewerBindings = GamepadMode.CreateBindingGroup("CharacterViewerBindings");
	self.characterViewerBindings:BlockDpadAndFaceButtons();
	self.characterViewerBindings:AddAxisBinding(GAMEPAD_STICK_LEFT, GenerateClosure(self.OnLeftStick, self));
	self.characterViewerBindings:AddAxisBinding(GAMEPAD_STICK_RIGHT, GenerateClosure(self.OnRightStick, self));
	self.characterViewerBindings:AddFunctionBinding(GAMEPAD_FACE_TOP, GenerateClosure(self.ResetCharacterView, self));
	self.characterViewerBindings:AddFunctionBinding(GAMEPAD_FACE_RIGHT, GenerateClosure(self.ExitCharacterView, self));

	local panCharacterViewer = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_LEFT, nil, FRAME_ACTION_PAN);
	local zoomTurnCharacterViewer = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT, nil, ACTION_LABEL_ZOOM_SLASH_ROTATE);
	local resetCharacterViewer = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, nil, ACTION_LABEL_RESET_VIEW);

	self.CharacterViewerFooter = GamepadSharedUtility.CreatePromptedBindingFooter(CharacterFrame, "CharacterViewerFooter");
	self.CharacterViewerFooter:SetAnchorOffsets(0, -40);
	self.CharacterViewerFooter:AddPromptedBinding(panCharacterViewer);
	self.CharacterViewerFooter:AddPromptedBinding(zoomTurnCharacterViewer);
	self.CharacterViewerFooter:AddPromptedBinding(resetCharacterViewer);
	self.CharacterViewerFooter:AddStandardBackPrompt();
	self.CharacterViewerFooter:Finalize();
end

function PaperDollFrameMixin:InitializeGamepad()
	self.CharacterModelScene.ControlFrame:Hide();
end

function PaperDollFrameMixin:UninitializeGamepad()
	self.CharacterModelScene.ControlFrame:Show();
end

function PaperDollFrameMixin:RegisterForInterfaceTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function PaperDollFrameMixin:GetFirstRepairableItem()
	if not InRepairMode() then
		return nil;
	end

	local function IsRepairable(button)
		local itemID = button:GetID();
		local durability, maxDurability = GetInventoryItemDurability(itemID);
		return durability and maxDurability and durability < maxDurability;
	end

	for _, v in ipairs(self.ItemsFrame.EquipmentSlots) do
		if IsRepairable(v) then
			return v;
		end
	end

	for _, v in ipairs(self.ItemsFrame.WeaponSlots) do
		if IsRepairable(v) then
			return v;
		end
	end

	return nil;
end

function PaperDollFrameMixin:OnSubframeFocus()
	local repairableItemButton = self:GetFirstRepairableItem();
	if repairableItemButton then
		SmartNavigation:SelectButton(repairableItemButton);
	end
end

function PaperDollFrameMixin:CreateGamepadPromptedBindings()
	local promptedBindings = {};

	local function ToggleCompareFunc()
		if C_CVar.GetCVarBool("alwaysCompareItems") then
			C_CVar.SetCVar("alwaysCompareItems", 0);
		else
			C_CVar.SetCVar("alwaysCompareItems", 1);
		end
	end

	local function IsToggleCompareCheckedFunc()
		return C_CVar.GetCVarBool("alwaysCompareItems");
	end

	local function BindItemFunc()
		GamepadMode.FrameControlsManager:UnsuspendAllFrames();

		local focusedButton = SmartNavigation:GetCurrentButton();
		local itemID = GetInventoryItemID("player", focusedButton:GetID());
		GamepadActionBarEditFrame:BindItem(itemID);
	end

	local function IsBindItemValidFunc()
		local button = SmartNavigation:GetCurrentButton();
		local item = Item:CreateFromEquipmentSlot(button:GetID());
		if item then
			local itemID = item:GetItemID();
			if itemID then
				local itemSpell = C_Item.GetItemSpell(itemID);
				local isEquippable = C_Item.IsEquippableItem(itemID);

				if (itemSpell or isEquippable) then
					return true;
				end
			end
		end
		return false;
	end

	local function UseItemFunc()
		GamepadMode.FrameControlsManager:UnsuspendAllFrames();

		local focusedButton = SmartNavigation:GetCurrentButton();
		if focusedButton then
			focusedButton:Click("RightButton");
		end
	end

	local function CanUseItemFunc()
		local button = SmartNavigation:GetCurrentButton();
		local item = Item:CreateFromEquipmentSlot(button:GetID());
		if item then
			local itemID = item:GetItemID();
			if itemID then
				if C_Item.IsUsableItem(itemID) then
					return true;
				end
			end
		end
		return false;
	end

	local function CanApplyItemEnchant()
		local button = SmartNavigation:GetCurrentButton();
		local location = button:GetItemLocation();
		local isEnchanting = ItemButtonUtil.GetItemContext() == ItemButtonUtil.ItemContextEnum.Enchanting;
		return location and location:IsValid() and isEnchanting and C_Item.DoesItemMatchTargetEnchantingSpell(location);
	end

	local function CanTargetItem()
		if not SpellCanTargetItem() then
			return false;
		end

		-- If we're enchanting, we're already covered by CanApplyItemEnchant, which is more strict
		local button = SmartNavigation:GetCurrentButton();
		local location = button:GetItemLocation();
		local isEnchanting = ItemButtonUtil.GetItemContext() == ItemButtonUtil.ItemContextEnum.Enchanting;
		return location and location:IsValid() and not isEnchanting;
	end

	local function ClickButton()
		local button = SmartNavigation:GetCurrentButton();
		button:Click();
	end

	local repairSingleItem = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, GenerateClosure(self.RepairSingleItemContextAction, self), CONTEXT_ACTION_LABEL_REPAIR);
	repairSingleItem:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	repairSingleItem:AddCondition(GenerateClosure(self.IsRepairSingleItemButtonContextActionValid, self));
	repairSingleItem:AddButtonContext("ButtonContext_PaperDollItemSlotButton");

	local applyEnchant = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, ClickButton, CONTEXT_ACTION_LABEL_APPLY);
	applyEnchant:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	applyEnchant:AddButtonContext("ButtonContext_PaperDollItemSlotButton");
	applyEnchant:AddCondition(CanApplyItemEnchant);

	local targetItem = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, ClickButton, ACTION_LABEL_SELECT);
	targetItem:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	targetItem:AddButtonContext("ButtonContext_PaperDollItemSlotButton");
	targetItem:AddCondition(CanTargetItem);

	local openEquipmentFlyout = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, GenerateClosure(self.OpenEquipmentFlyoutForFocusedButton, self), ACTION_LABEL_SELECT);
	openEquipmentFlyout:AddCondition(GenerateClosure(self.IsOpenEquipmentFlyoutButtonContextActionValid, self));
	openEquipmentFlyout:AddButtonContext("ButtonContext_PaperDollItemSlotButton");

	local openCharacterViewer = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, GenerateClosure(self.FocusCharacterView, self), CONTEXT_ACTION_LABEL_CHARACTER_VIEWER);
	openCharacterViewer:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	openCharacterViewer:AddButtonContext("ButtonContext_PaperDollItemSlotButton");
	openCharacterViewer:AddButtonContext("ButtonContext_PaperDollLabel");

	local moreEquipmentActions = GamepadSharedUtility.CreateMoreActionsPromptedBinding(GAMEPAD_FACE_TOP);
	moreEquipmentActions:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	moreEquipmentActions:AddButtonContext("ButtonContext_PaperDollItemSlotButton");
	moreEquipmentActions:AddMoreActionsEntry(FRAME_ACTION_TOGGLE_ITEM_COMPARE, ToggleCompareFunc, nil, IsToggleCompareCheckedFunc);
	moreEquipmentActions:AddMoreActionsEntry(CONTEXT_ACTION_LABEL_BIND_TO_GAMEPAD_ACTION_BAR, BindItemFunc, IsBindItemValidFunc, nil);
	moreEquipmentActions:AddMoreActionsEntry(CONTEXT_ACTION_LABEL_USE, UseItemFunc, CanUseItemFunc, nil);

	table.insert(promptedBindings, repairSingleItem);
	table.insert(promptedBindings, applyEnchant);
	table.insert(promptedBindings, targetItem);
	table.insert(promptedBindings, openEquipmentFlyout);
	table.insert(promptedBindings, openCharacterViewer);
	table.insert(promptedBindings, moreEquipmentActions);

	return promptedBindings;
end

function PaperDollItemSlotButton_OnLoad(self)
	local level = self:GetFrameLevel();

	if self.popoutButton then
		self.popoutButton:SetFrameLevel(level - 3);
	end

	if self.BorderFrame then
		self.BorderFrame:SetFrameLevel(level - 2);
	end

	local slotName = PaperDollItemSlotButton_GetSlotName(self);


	if (C_PaperDollInfo.IsRangedSlotShown()) then
		if (slotName == "MainHandSlot") then
			self:SetPoint("BOTTOM", CharacterFrame.LeftPaneHost, -60, 30);
		end
	else
		if (slotName == "MainHandSlot") then
			self:SetPoint("BOTTOM", CharacterFrame.LeftPaneHost, -40, 30);
		end

		if (slotName == "RangedSlot") then
			self:Hide();
			return;
		end
	end

	if (C_PaperDollInfo.AmmoNeeded() == false) then
		if(slotName == "AmmoSlot") then
			self:Hide();
			return;
		end
	end

	local id, textureName, checkRelic = C_PaperDollInfo.GetInventorySlotInfo(slotName);

	EnchantingItemButtonAnimMixin.OnLoad(self);

	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	self:SetID(id);

	local texture = self.icon;
	texture:SetTexture(textureName);
	self.backgroundTextureName = textureName;
	self.checkRelic = checkRelic;
	self.UpdateTooltip = PaperDollItemSlotButton_OnUpdate;
	itemSlotButtons[id] = self;
	self.verticalFlyout = VERTICAL_FLYOUTS[id];

	local popoutButton = self.popoutButton;
	if ( popoutButton ) then
		local flyoutDirection = self.flyoutDirection;
		popoutButton:ClearAllPoints();
		if ( flyoutDirection == "LEFT" ) then
			popoutButton:SetPoint("RIGHT", self, "LEFT", -5, 0);
		elseif ( flyoutDirection == "UP" ) then
			popoutButton:SetPoint("BOTTOM", self, "TOP", 0, 5);
		elseif ( flyoutDirection == "DOWN" ) then
			popoutButton:SetPoint("TOP", self, "BOTTOM", 0, -5);
		else
			popoutButton:SetPoint("LEFT", self, "RIGHT", 5, 0);
		end
	end

	local function GetItemLocationCallback()
		return ItemLocation:CreateFromEquipmentSlot(self:GetID());
	end
	EnchantingItemButtonAnimMixin.SetItemLocationCallback(self, GetItemLocationCallback);
end

function PaperDollItemSlotButton_GetSlotName(self)
	local name = self:GetName();
	return (name and strsub(name, 10)) or self.slotName;
end

local PAPERDOLL_FRAME_EVENTS = {
	"PLAYER_EQUIPMENT_CHANGED",
	"MERCHANT_UPDATE",
	"PLAYERBANKSLOTS_CHANGED",
	"ITEM_LOCK_CHANGED",
	"CURSOR_CHANGED",
	"UPDATE_INVENTORY_ALERTS",
	"AZERITE_ITEM_POWER_LEVEL_CHANGED",
	"AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED",
	"UNIT_INVENTORY_CHANGED",
	"BAG_UPDATE",
};

function PaperDollItemSlotButton_OnShow(self, isBag)
	EnchantingItemButtonAnimMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, PAPERDOLL_FRAME_EVENTS);

	if ( not isBag ) then
		self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	end
	PaperDollItemSlotButton_Update(self);
end

function PaperDollItemSlotButton_OnModifableClick(self, button)
	if IsModifiedClick() then
		PaperDollItemSlotButton_OnModifiedClick(self, button);
	else
		PaperDollItemSlotButton_OnClick(self, button);
	end
end

function PaperDollItemSlotButton_OnDragStart(self)
	PaperDollItemSlotButton_OnClick(self, "LeftButton");
end

function PaperDollItemSlotButton_OnReceiveDrag(self)
	PaperDollItemSlotButton_OnClick(self, "LeftButton");
end

function PaperDollItemSlotButton_OnHide(self)
	EnchantingItemButtonAnimMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, PAPERDOLL_FRAME_EVENTS);

	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
end

function PaperDollItemSlotButton_OnEvent(self, event, ...)
	EnchantingItemButtonAnimMixin.OnEvent(self, event, ...);

	local arg1 = ...;

	if ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		local equipmentSlot, hasCurrent = ...;
		if ( self:GetID() == equipmentSlot ) then
			PaperDollItemSlotButton_Update(self);
		end
	elseif ( event == "UNIT_INVENTORY_CHANGED" ) then
		if( arg1 == "player" ) then
			PaperDollItemSlotButton_Update(self);
		end
		return;
	elseif ( event == "BAG_UPDATE" ) then
		PaperDollItemSlotButton_Update(self);
		return;
	elseif ( event == "ITEM_LOCK_CHANGED" ) then
		local bagOrSlotIndex, slotIndex = ...;
		if ( not slotIndex and bagOrSlotIndex == self:GetID() ) then
			PaperDollItemSlotButton_UpdateLock(self);
		end
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		PaperDollItemSlotButton_Update(self);
	elseif ( event == "CURSOR_CHANGED" ) then
		if C_PaperDollInfo.CursorCanGoInSlot(self:GetID()) then
			self:LockHighlight();
		else
			self:UnlockHighlight();
		end
	elseif ( event == "UPDATE_INVENTORY_ALERTS" ) then
		PaperDollItemSlotButton_Update(self);
	elseif ( event == "MODIFIER_STATE_CHANGED" ) then
		if ( IsModifiedClick("SHOWITEMFLYOUT") and self:IsMouseOver() ) then
			PaperDollItemSlotButton_OnEnter(self);
		end
	elseif event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" then
		local azeriteItemLocation, oldPowerLevel, newPowerLevel, azeriteItemID = ...;
		if azeriteItemLocation:IsEqualToEquipmentSlot(self:GetID()) then
			PaperDollItemSlotButton_Update(self);
		end
	elseif event == "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED" then
		local item = ...;
		PaperDollItemSlotButton_Update(self);
	end
end

function PaperDollItemSlotButton_SetAutoEquipSlotIDs(...)
	local slots = {...};
	local slotIDs = {};
	for index, slot in ipairs(slots) do
		table.insert(slotIDs, slot.slotID);
		slot.autoEquipSlotIDs = slotIDs;
	end
end

function PaperDollItemSlotButton_OnClick(self, button)
	MerchantFrame_ResetRefundItem();
	if ( button == "LeftButton" ) then
		local type = GetCursorInfo();
		if ( type == "merchant" and MerchantFrame.extendedCost ) then
			MerchantFrame_ConfirmExtendedItemCost(MerchantFrame.extendedCost);
		else
			local validateAutoEquip = CursorHasItem() and self.autoEquipSlotIDs;
			-- If there isn't any special auto equip requirement, we can continue calling PickupInventoryItem,
			-- otherwise, we need to first verify that the cursor item could occupy any of the desired slots before
			-- we allow PickupInventoryItem to auto-equip for us.
			local canPickupInventoryItem = not validateAutoEquip;
			if ( validateAutoEquip ) then
				for index, slotID in ipairs(self.autoEquipSlotIDs) do
					if ( C_PaperDollInfo.CursorCanGoInSlot(slotID) ) then
						canPickupInventoryItem = true;
						break;
					end
				end
			end

			if ( canPickupInventoryItem ) then
				PickupInventoryItem(self:GetID());
			end

			if ( validateAutoEquip and not canPickupInventoryItem ) then
				local profession = C_TradeSkillUI.GetProfessionByInventorySlot(self:GetID());
				local tag = profession and ProfessionEquipError[profession] or nil;
				if tag then
					UIErrorsFrame:AddExternalErrorMessage(tag);
				end
			end

			if ( CursorHasItem() ) then
				MerchantFrame_SetRefundItem(self, 1);
			end
		end
	else
		UseInventoryItem(self:GetID());
	end
end

function PaperDollItemSlotButton_OnModifiedClick(self, button)
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(self:GetID());
	if ( IsModifiedClick("EXPANDITEM") ) then
		if C_Item.DoesItemExist(itemLocation) then
			if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
				if C_Item.CanViewItemPowers(itemLocation) then
					OpenAzeriteEmpoweredItemUIFromItemLocation(itemLocation);
				else
					UIErrorsFrame:AddExternalErrorMessage(AZERITE_PREVIEW_UNAVAILABLE_FOR_CLASS);
				end
				return;
			end

			local heartItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
			if heartItemLocation and heartItemLocation:IsEqualTo(itemLocation) then
				OpenAzeriteEssenceUIFromItemLocation(itemLocation);
				return;
			end

			SocketInventoryItem(self:GetID());
		end
		return;
	end
	if ( HandleModifiedItemClick(GetInventoryItemLink("player", self:GetID()), itemLocation) ) then
		return;
	end
end

function PaperDollItemSlotButton_Update(self)
	local textureName = GetInventoryItemTexture("player", self:GetID());
	local cooldown = self.Cooldown;
	local hasItem = textureName ~= nil;
	if ( hasItem ) then
		SetItemButtonTexture(self, textureName);
		SetItemButtonCount(self, GetInventoryItemCount("player", self:GetID()));
		if ( GetInventoryItemBroken("player", self:GetID())
		  or GetInventoryItemEquippedUnusable("player", self:GetID()) ) then
			SetItemButtonTextureVertexColor(self, 0.9, 0, 0);
			SetItemButtonNormalTextureVertexColor(self, 0.9, 0, 0);
		else
			SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
			SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
		end
		if ( cooldown ) then
			local start, duration, enable = GetInventoryItemCooldown("player", self:GetID());
			CooldownFrame_Set(cooldown, start, duration, enable);
		end
	else
		textureName = self.backgroundTextureName;
		if ( self.checkRelic and UnitHasRelicSlot("player") ) then
			textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
		end
		SetItemButtonTexture(self, textureName);
		SetItemButtonCount(self, 0);
		SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
		SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
		if ( cooldown ) then
			cooldown:Hide();
		end
	end

	if self.SocketDisplay then
		self.SocketDisplay:SetItem(GetInventoryItemLink("player", self:GetID()));
	end

	self:UpdateItemContextMatching();

	local quality = GetInventoryItemQuality("player", self:GetID());
	local suppressOverlays = self.HasPaperDollAzeriteItemOverlay;
	SetItemButtonQuality(self, quality, GetInventoryItemID("player", self:GetID()), suppressOverlays);
	SetItemCraftingQualityOverlay(self, GetInventoryItemLink("player", self:GetID()));

	if (not PaperDollFrame.EquipmentManagerPane:IsShown()) then
		self.ignored = nil;
	end

	if self.ignoreTexture then
		self.ignoreTexture:SetShown(self.ignored);
	end

	if self.HasPaperDollAzeriteItemOverlay then
		self:SetAzeriteItem(hasItem and ItemLocation:CreateFromEquipmentSlot(self:GetID()) or nil);
	end

	PaperDollItemSlotButton_UpdateLock(self);

	-- Update repair all button status
	MerchantFrame_UpdateGuildBankRepair();
	MerchantFrame_UpdateCanRepairAll();
end

function PaperDollItemSlotButton_UpdateLock(self)
	SetItemButtonDesaturated(self, IsInventoryItemLocked(self:GetID()));
end

function PaperDollItemSlotButton_OnUpdate(self)
	PaperDollItemSlotButton_OnEnter(self);

	if InRepairMode() then
		CharacterFrame:RefreshFooters();
	end
end

function PaperDollItemSlotButton_OnEnter(self)
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	EquipmentFlyout_UpdateFlyout(self);
	if ( not EquipmentFlyout_SetTooltipAnchor(self) ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end

	local suppressComparison = true;
	ItemUtil.DisplayEquipSlotTooltip(self, GameTooltip, self:GetID(), suppressComparison, self.checkRelic);

	local itemLocation = ItemLocation:CreateFromEquipmentSlot(self:GetID());
	if itemLocation and itemLocation:IsValid() then
		local itemLocationValid = itemLocation:IsValid();
		SetCursorHoveredItem(itemLocation);
	end

	CursorUpdate(self);
end

function PaperDollItemSlotButton_OnLeave(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	GameTooltip:Hide();

	ClearCursorHoveredItem();
	ResetCursor();
end

function PaperDollStatTooltip(self)
	if ( not self.tooltip ) then
		return;
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.tooltip);
	if ( self.tooltip2 ) then
		GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	if ( self.tooltip3 ) then
		GameTooltip:AddLine(self.tooltip3, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	GameTooltip:Show();
end

function FormatPaperDollTooltipStat(name, base, posBuff, negBuff)
	local effective = BreakUpLargeNumbers(max(0,base + posBuff + negBuff));
	local text = HIGHLIGHT_FONT_COLOR_CODE..name.." "..effective;
	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		text = text..FONT_COLOR_CODE_CLOSE;
	else
		if ( posBuff > 0 or negBuff < 0 ) then
			text = text.." ("..base..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			text = text..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			text = text..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			text = text..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
	end
	return text;
end

function PaperDollFormatStat(name, base, posBuff, negBuff)
	local effectiveText = BreakUpLargeNumbers(max(0,base + posBuff + negBuff));
	local text = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT,name).." "..effectiveText;
	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		text = text..FONT_COLOR_CODE_CLOSE;
	else
		if ( posBuff > 0 or negBuff < 0 ) then
			text = text.." ("..base..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			text = text..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			text = text..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			text = text..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end

		-- if there is a negative buff then show the main number in red, even if there are
		-- positive buffs. Otherwise show the number in green
		if ( negBuff < 0 and not GetPVPGearStatRules() ) then
			effectiveText = RED_FONT_COLOR_CODE..effectiveText..FONT_COLOR_CODE_CLOSE;
		end
	end
	return effectiveText, text;
end

function CharacterAttackFrame_OnEnter(self)
	-- Main hand weapon
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(INVTYPE_WEAPONMAINHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine(self.weaponSkill);
	GameTooltip:AddLine(self.weaponRating);
	-- Check for offhand weapon
	if ( self.offhandSkill ) then
		GameTooltip:AddLine("\n");
		GameTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddLine(self.offhandSkill);
		GameTooltip:AddLine(self.offhandRating);
	end
	GameTooltip:Show();
end

function CharacterDamageFrame_OnEnter(self)
	-- Main hand weapon
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if ( self.unit == "pet" ) then
		GameTooltip:SetText(INVTYPE_WEAPONMAINHAND_PET, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		local tooltipLabel = self.tooltipLabel and self.tooltipLabel or INVTYPE_WEAPONMAINHAND;
		GameTooltip:SetText(tooltipLabel, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	GameTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", self.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), self.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);

	if PAPER_DOLL_FRAME_SHOW_DPS then
		GameTooltip:AddDoubleLine(format(STAT_FORMAT, STAT_DPS_SHORT), self.dps, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	-- Check for offhand weapon
	if ( self.offhandAttackSpeed ) then
		GameTooltip:AddLine("\n");
		GameTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", self.offhandAttackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), self.offhandDamage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	GameTooltip:Show();
end

function PaperDollFrame_GetArmorReduction(armor, attackerLevel)
	return C_PaperDollInfo.GetArmorEffectiveness(armor, attackerLevel) * 100;
end

function PaperDollFrame_GetArmorReductionAgainstTarget(armor)
	local armorEffectiveness = C_PaperDollInfo.GetArmorEffectivenessAgainstTarget(armor);
	if ( armorEffectiveness ) then
		return armorEffectiveness * 100;
	end
end

function PaperDollFrame_UpdateStats()
	local statsPane = CharacterFrame:GetStatsPane();
	if statsPane == CharacterStatsPaneScrollBox then
		statsPane:UpdateStats();
	else
		PaperDollFrame_UpdateStatsInternal();
	end

	if HasPetUI() and CharacterStatsPanePetScrollBox then
		CharacterStatsPanePetScrollBox:UpdateStats();
	end
end

function PaperDollFrame_UpdateStatsInternal()
	local level = UnitLevel("player");
	local categoryYOffset = 0;
	local statYOffset = 0;

	if ( level >= MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY ) then
		PaperDollFrame_SetItemLevel(CharacterStatsPane.ItemLevelFrame, "player");
		CharacterStatsPane.ItemLevelFrame.Value:SetTextColor(GetItemLevelColor());
		CharacterStatsPane.ItemLevelCategory:Show();
		CharacterStatsPane.ItemLevelFrame:Show();
		CharacterStatsPane.AttributesCategory:ClearAllPoints();
		CharacterStatsPane.AttributesCategory:SetPoint("TOP", CharacterStatsPane.ItemLevelFrame, "BOTTOM", 0, 0);
	else
		CharacterStatsPane.ItemLevelCategory:Hide();
		CharacterStatsPane.ItemLevelFrame:Hide();
		CharacterStatsPane.AttributesCategory:ClearAllPoints();
		CharacterStatsPane.AttributesCategory:SetPoint("TOP", CharacterStatsPane, "TOP", 0, -2);
		categoryYOffset = -11;
		statYOffset = -5;
	end

	local spec, role;
	spec = C_SpecializationInfo.GetSpecialization();
	if spec then
		role = GetSpecializationRoleEnum(spec);
	end

	CharacterStatsPane.statsFramePool:ReleaseAll();
	-- we need a stat frame to first do the math to know if we need to show the stat frame
	-- so effectively we'll always pre-allocate
	local statFrame = CharacterStatsPane.statsFramePool:Acquire();

	local lastAnchor;

	for catIndex = 1, #PAPERDOLL_STATCATEGORIES do
		local catFrame = CharacterStatsPane[PAPERDOLL_STATCATEGORIES[catIndex].categoryFrame];
		local numStatInCat = 0;
		for statIndex = 1, #PAPERDOLL_STATCATEGORIES[catIndex].stats do
			local stat = PAPERDOLL_STATCATEGORIES[catIndex].stats[statIndex];
			local showStat = true;
			if ( showStat and stat.primary and spec ) then
				local primaryStat = select(6, C_SpecializationInfo.GetSpecializationInfo(spec, false, false, nil, UnitSex("player")));
				if ( stat.primary ~= primaryStat ) then
					showStat = false;
				end
			end
			if ( showStat and stat.roles ) then
				local foundRole = false;
				for _, statRole in pairs(stat.roles) do
					if ( role == statRole ) then
						foundRole = true;
						break;
					end
				end
				showStat = foundRole;
			end
			if ( showStat and stat.showFunc ) then
				showStat = stat.showFunc();
			end
			if ( showStat ) then
				statFrame.onEnterFunc = nil;
				statFrame.UpdateTooltip = nil;
				statFrame.tooltip3 = nil;
				PAPERDOLL_STATINFO[stat.stat].updateFunc(statFrame, "player");
				if ( not stat.hideAt or stat.hideAt ~= statFrame.numericValue ) then
					if ( numStatInCat == 0 ) then
						if ( lastAnchor ) then
							catFrame:SetPoint("TOP", lastAnchor, "BOTTOM", 0, categoryYOffset);
						end
						lastAnchor = catFrame;
						statFrame:SetPoint("TOP", catFrame, "BOTTOM", 0, -2);
					else
						statFrame:SetPoint("TOP", lastAnchor, "BOTTOM", 0, statYOffset);
					end
					numStatInCat = numStatInCat + 1;
					statFrame.Background:SetShown((numStatInCat % 2) == 0);
					lastAnchor = statFrame;
					-- done with this stat frame, get the next one
					statFrame = CharacterStatsPane.statsFramePool:Acquire();
				end
			end
		end
		catFrame:SetShown(numStatInCat > 0);
	end
	-- release the current stat frame
	CharacterStatsPane.statsFramePool:Release(statFrame);
end

function PaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage, numericValue)
	if ( statFrame.Label ) then
		statFrame.Label:SetText(format(STAT_FORMAT, label));
	end
	if ( isPercentage ) then
		text = format("%d%%", numericValue + 0.5);
	end
	statFrame.Value:SetText(text);
	statFrame.numericValue = numericValue;
end

function PaperDollFrame_SetOnEnter(statFrame, func)
	statFrame.onEnterFunc = func;
end

function ComputePetBonus(stat, value)
	local temp, unitClass = UnitClass("player");
	unitClass = strupper(unitClass);
	if( unitClass == "WARLOCK" ) then
		if( WARLOCK_PET_BONUS[stat] ) then
			return value * WARLOCK_PET_BONUS[stat];
		else
			return 0;
		end
	elseif( unitClass == "HUNTER" ) then
		if( HUNTER_PET_BONUS[stat] ) then
			return value * HUNTER_PET_BONUS[stat];
		else
			return 0;
		end
	end

	return 0;
end

function PaperDollFrameItemFlyoutButton_OnClick(self)
	if ( self.location == EQUIPMENTFLYOUT_IGNORESLOT_LOCATION ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local slot = EquipmentFlyoutFrame.button;
		C_EquipmentSet.IgnoreSlotForSave(slot:GetID());
		slot.ignored = true;
		PaperDollItemSlotButton_Update(slot);
		EquipmentFlyout_Show(slot);
		PaperDollFrame.EquipmentManagerPane.SaveSet:Enable();
	elseif ( self.location == EQUIPMENTFLYOUT_UNIGNORESLOT_LOCATION ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local slot = EquipmentFlyoutFrame.button;
		C_EquipmentSet.UnignoreSlotForSave(slot:GetID());
		slot.ignored = nil;
		PaperDollItemSlotButton_Update(slot);
		EquipmentFlyout_Show(slot);
		PaperDollFrame.EquipmentManagerPane.SaveSet:Enable();
	elseif ( self.location == EQUIPMENTFLYOUT_PLACEINBAGS_LOCATION ) then
		if ( UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[EquipmentFlyoutFrame.button:GetID()] ) then
			UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
			return;
		end
		local action = EquipmentManager_UnequipItemInSlot(EquipmentFlyoutFrame.button:GetID());
		EquipmentManager_RunAction(action);
	elseif ( self.location ) then
		if ( UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[EquipmentFlyoutFrame.button:GetID()] ) then
			UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
			return;
		end
		local action = EquipmentManager_EquipItemByLocation(self.location, self.id);
		EquipmentManager_RunAction(action);
	end
end

function PaperDollFrameItemFlyout_GetItems(paperDollItemSlot, itemTable)
	GetInventoryItemsForSlot(paperDollItemSlot, itemTable);
end

function PaperDollFrameItemFlyout_PostGetItems(itemSlotButton, itemDisplayTable, numItems)
	if (PaperDollFrame.EquipmentManagerPane:IsShown() and (PaperDollFrame.EquipmentManagerPane.selectedSetID or GearManagerPopupFrame:IsShown())) then
		if ( not itemSlotButton.ignored ) then
			tinsert(itemDisplayTable, 1, EQUIPMENTFLYOUT_IGNORESLOT_LOCATION);
		else
			tinsert(itemDisplayTable, 1, EQUIPMENTFLYOUT_UNIGNORESLOT_LOCATION);
		end
		numItems = numItems + 1;
	end
	if ( GetInventoryItemTexture("player", itemSlotButton:GetID()) ~= nil ) then
		tinsert(itemDisplayTable, 1, EQUIPMENTFLYOUT_PLACEINBAGS_LOCATION);
		numItems = numItems + 1;
	end
	return numItems;
end

function GearSetEditButton_OnMouseDown(self, button)
	self.texture:SetPoint("TOPLEFT", 1, -1);

	local parentButton = self:GetParent();

	local function GetSetID()
		return parentButton.setID;
	end

	local function IsSelected(i)
		return C_EquipmentSet.GetEquipmentSetAssignedSpec(GetSetID()) == i;
	end

	local function SetSelected(i)
		local currentSpecIndex = C_EquipmentSet.GetEquipmentSetAssignedSpec(GetSetID());
		if ( currentSpecIndex ~= i ) then
			C_EquipmentSet.AssignSpecToEquipmentSet(GetSetID(), i);
		else
			C_EquipmentSet.UnassignEquipmentSetSpec(GetSetID());
		end

		GearSetButton_UpdateSpecInfo(parentButton);
		PaperDollEquipmentManagerPane_Update(true);
	end

	MenuUtil.CreateContextMenu(PaperDollFrame.EquipmentManagerPane, function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PAPERDOLL_FRAME");

		rootDescription:CreateButton(EQUIPMENT_SET_EDIT, function()
			GearSetButton_OpenPopup(parentButton);
		end);
	end);
end

GearSetButtonMixin = {};

function GearSetButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self.icon:SetTexCoord(0.03125, 0.96875, 0.03125, 0.96875);
end

function GearSetButtonMixin:OnSmartNavSelect()
	--[[
		Activate the gear set on smart nav hover because on click is reserved for opening
		the context menu. Make sure to not activate the button when returning from editing
		equipment ignores or landing on the new set button.
	]]
	if (self.setID and PaperDollFrame.EquipmentManagerPane.selectedSetID ~= self.setID) then
		if (self.GetElementData) then
			--[[
				This button still has element data and therefore is a valid set button.
				This case can occur during normal navigation or when the button that was just
				deleted was not the last button in the scroll list.
			]]
			self:Click();
		else
			--[[
				This case is reached when the last button in the scrollbox was just deleted,
				and Smart Nav has returned to the now invalid button. To fix this we just need
				to focus the next valid button above us which is either another set button or
				the new set button.
			]]
			local scrollBox = PaperDollFrame.EquipmentManagerPane.ScrollBox;
			local gearSetButtons = scrollBox:GetFrames();
			SmartNavigation:SelectButton(gearSetButtons[scrollBox:GetFrameCount()])
		end
	end
end

function GearSetButton_SetSpecInfo(self, specID)
	if ( specID and specID > 0 ) then
		self.specID = specID;
		local id, name, description, texture, role, class = GetSpecializationInfoByID(specID);
		self.SpecIcon:SetTexture(texture);
		self.SpecIcon:Show();
		self.SpecRing:Show();
	else
		self.specID = nil;
		self.SpecIcon:Hide();
		self.SpecRing:Hide();
	end

end

function GearSetButton_UpdateSpecInfo(self)
	if ( not self.setID ) then
		GearSetButton_SetSpecInfo(self, nil);
		return;
	end

	local specIndex = C_EquipmentSet.GetEquipmentSetAssignedSpec(self.setID);
	if ( not specIndex ) then
		GearSetButton_SetSpecInfo(self, nil);
		return;
	end

	local specID = C_SpecializationInfo.GetSpecializationInfo(specIndex);
	GearSetButton_SetSpecInfo(self, specID);
end

function GearSetButton_OnClick(self, button, down)
	--if ( self.setID ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);		-- inappropriately named, but a good sound.
		PaperDollFrame.EquipmentManagerPane.selectedSetID = self.setID;
		PaperDollEquipmentManagerPane_SetButtonSelected(self, true);
		-- mark the ignored slots
		PaperDollFrame_ClearIgnoredSlots();
		PaperDollFrame_IgnoreSlotsForSet(self.setID);
		PaperDollEquipmentManagerPane_Update();
		GearManagerPopupFrame:Hide();
	--else
		-- This is the "New Set" button
		--GearManagerPopupFrame.mode = IconSelectorPopupFrameModes.New;
		--GearManagerPopupFrame:Show();
		--PaperDollFrame.EquipmentManagerPane.selectedSetID = nil;
		--PaperDollFrame_ClearIgnoredSlots();
		--PaperDollEquipmentManagerPane_Update();
		---- Ignore shirt and tabard by default
		--PaperDollFrame_IgnoreSlot(4);
		--PaperDollFrame_IgnoreSlot(19);
	--end
	StaticPopup_Hide("CONFIRM_SAVE_EQUIPMENT_SET");
	StaticPopup_Hide("CONFIRM_OVERWRITE_EQUIPMENT_SET");
end

function GearSetButton_OnDoubleClick(self)
	if ( self.setID ) then
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);			-- inappropriately named, but a good sound.
		EquipmentManager_EquipSet(self.setID);
	end
end

function GearSetButton_OnEnter(self)
	if ( self.setID ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		GameTooltip:SetEquipmentSet(self.setID);
	end
end

function GearSetButton_OnDrag(self)
	if ( self.setID ) then
		C_EquipmentSet.PickupEquipmentSet(self.setID);
	end
end

function GearSetButton_OpenPopup(self, openedFromContextActionMenu)
	GearManagerPopupFrame.mode = IconSelectorPopupFrameModes.Edit;
	GearManagerPopupFrame.setID = self.setID;
	GearManagerPopupFrame.origName = self.text:GetText();
	GearManagerPopupFrame.openedFromContextActionMenu = openedFromContextActionMenu;
	GearManagerPopupFrame:Show();
end

GearManagerPopupFrameMixin = {};

function GearManagerPopupFrameMixin:OnShow()
	IconSelectorPopupFrameTemplateMixin.OnShow(self);
	self.BorderBox.IconSelectorEditBox:SetFocus();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	self.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Equipment);
	self:SetIconFilter(IconSelectorPopupFrameIconFilterTypes.All);
	self:Update();
	self.BorderBox.IconSelectorEditBox:OnTextChanged();

	local function OnIconSelected(selectionIndex, icon)
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon);

		-- Index is not yet set, but we know if an icon in IconSelector was selected it was in the list, so set directly.
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_CLICK);
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetFontObject(GameFontHighlightSmall);
	end
	self.IconSelector:SetSelectedCallback(OnIconSelected);
end

function GearManagerPopupFrameMixin:OnHide()
	IconSelectorPopupFrameTemplateMixin.OnHide(self);

	self.setID = nil;
	if PaperDollFrame.EquipmentManagerPane.selectedSetID == nil then
		PaperDollFrame_ClearIgnoredSlots();
	end

	self.iconDataProvider:Release();
	self.iconDataProvider = nil;
end

function GearManagerPopupFrameMixin:Update()
	if ( self.mode == IconSelectorPopupFrameModes.New ) then
		self.origName = "";
		self.BorderBox.IconSelectorEditBox:SetText("");
		local initialIndex = 1;
		self.IconSelector:SetSelectedIndex(initialIndex);
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self:GetIconByIndex(initialIndex));
	elseif ( self.mode == IconSelectorPopupFrameModes.Edit ) then
		local name, texture = C_EquipmentSet.GetEquipmentSetInfo(self.setID);
		self.BorderBox.IconSelectorEditBox:SetText(name);
		self.BorderBox.IconSelectorEditBox:HighlightText();

		self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(texture));
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(texture);
	end

	local getSelection = GenerateClosure(self.GetIconByIndex, self);
	local getNumSelections = GenerateClosure(self.GetNumIcons, self);
	self.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections);
	self.IconSelector:ScrollToSelectedIndex();

	self:SetSelectedIconText();
end

function GearManagerPopupFrameMixin:OkayButton_OnClick()
	IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick(self);

	local iconTexture = self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture();
	local text = self.BorderBox.IconSelectorEditBox:GetText();

	local setID = C_EquipmentSet.GetEquipmentSetID(text);
	if ( setID ) then
		if (self.mode == IconSelectorPopupFrameModes.Edit and text ~= self.origName)  then
			-- Not allowed to overwrite an existing set by doing a rename
			UIErrorsFrame:AddMessage(EQUIPMENT_SETS_CANT_RENAME, 1.0, 0.1, 0.1, 1.0);
			return;
		elseif ( self.mode == IconSelectorPopupFrameModes.New ) then
			local dialog = StaticPopup_Show("CONFIRM_OVERWRITE_EQUIPMENT_SET", text, nil, setID);
			if ( dialog ) then
				dialog.selectedIcon = iconTexture;
			else
				UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
			end
			return;
		end
	elseif ( C_EquipmentSet.GetNumEquipmentSets() >= MAX_EQUIPMENT_SETS_PER_PLAYER and self.mode == IconSelectorPopupFrameModes.New ) then
		UIErrorsFrame:AddMessage(EQUIPMENT_SETS_TOO_MANY, 1.0, 0.1, 0.1, 1.0);
		return;
	end

	if ( self.mode == IconSelectorPopupFrameModes.New ) then
		C_EquipmentSet.CreateEquipmentSet(text, iconTexture);
	else
		local selectedSetID = C_EquipmentSet.GetEquipmentSetID(self.origName);
		PaperDollFrame.EquipmentManagerPane.selectedSetID = selectedSetID;
		C_EquipmentSet.ModifyEquipmentSet(selectedSetID, text, iconTexture);
	end
end

PaperDollEquipmentManagerPaneMixin = {};

function PaperDollEquipmentManagerPaneMixin:RegisterForInterfaceTransitions()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function PaperDollEquipmentManagerPaneMixin:InitializeGamepad()
	self.EquipSet:Hide();
	self.SaveSet:Hide();

	local scrollBox = self.ScrollBox;
	local scrollBar = self.ScrollBar;

	-- Update the scrollbox and scrollbar to use the empty space the buttons used.
	scrollBox:ClearAllPoints();
	scrollBox:SetPoint("TOPLEFT", CharacterFrame.InsetRight, "TOPLEFT", 4, -5);
	scrollBox:SetHeight(352);

	scrollBar:ClearAllPoints();
	scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 8, 0);
	scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMLEFT", 8, 0);
end

function PaperDollEquipmentManagerPaneMixin:UninitializeGamepad()
	self.EquipSet:Show();
	self.SaveSet:Show();

	local scrollBox = self.ScrollBox;
	local scrollBar = self.ScrollBar;

	-- Revert gamepad scrollbox and scrollbar changes back to MKB mode.
	scrollBox:ClearAllPoints();
	scrollBox:SetPoint("TOPLEFT", CharacterFrame.InsetRight, "TOPLEFT", 4, -27);
	scrollBox:SetHeight(331);

	scrollBar:ClearAllPoints();
	scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 8, 17);
	scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMLEFT", 8, 30);
end

function PaperDollEquipmentManagerPaneMixin:GetButtonToLandOnWhenCharacterFrameRightSideSwapOccurs()
	-- Focus the selected set button or the new slot button if none are selected.
	local scrollBox = PaperDollFrame.EquipmentManagerPane.ScrollBox;

	--[[
		If there isn't a selected set id which should only occur when creating a new set or
		focusing on the character frame for the first time in gamepad mode,
		then focus the top button which can either be a set or the new set button
	]]
	if (not self.selectedSetID) then
		local gearSetButtons = scrollBox:GetFrames();
		return gearSetButtons[1];
	end

	--[[
		Ensure that the button associated with the selected set id is visible so it
		can be evaluated in the loop below. While smart nav typically handles this
		when the cursor moves to different buttons while focused on the scrollbox, the
		player could have scrolled the box using the mouse while smart nav was not focused
		on the scrollbox causing the selected set button to be hidden.
	]]
	for elementDataIndex, equipmentSetID  in ipairs(self.equipmentSetIDs) do
		if (equipmentSetID == self.selectedSetID) then
			local elementData = scrollBox:FindElementData(elementDataIndex);
			scrollBox:ScrollToElementData(elementData, nil, nil, true);
			break;
		end
	end

	local gearSetButtons = scrollBox:GetFrames();

	-- Return the gear set button with the selected index.
	for _, gearSetButton in ipairs(gearSetButtons) do
		if (gearSetButton.setID == self.selectedSetID) then
			-- SmartNavigation runs additional scroll logic to make sure that navigation doesn't break.
			return SmartNavigation:HandleScroll(gearSetButton, self.ScrollBox);
		end
	end
end

function PaperDollEquipmentManagerPaneMixin:CreateGamepadPromptedBindings()
	local promptedBindings = {};

	local function IsOpenGearSetValid()
		local button = SmartNavigation:GetCurrentButton();
		return button.setID ~= nil;
	end

	--local function IsCreateGearSetValid()
	--	local button = SmartNavigation:GetCurrentButton();
	--	return button.setID == nil; -- The new set button doesn't have a set id, while all other gear set buttons do.
	--end

	local function EquipGearSet()
		PaperDollEquipmentManagerPaneEquipSet_OnClick(self.EquipSet);
	end

	local function SaveGearSet()
		PaperDollEquipmentManagerPaneSaveSet_OnClick(self.SaveSet);
	end

	-- FIXME ADD SUPPORT
	local function NewGearSet()
		PaperDollEquipmentManagerPaneNewSet_OnClick(self.NewSet)
	end

	local function BindGearSetToGamepadActionBars()
		GamepadMode.FrameControlsManager:UnsuspendAllFrames();

		local focusedButton = SmartNavigation:GetCurrentButton();
		if (focusedButton and focusedButton.setID) then
			if not GamepadMode.FrameControlsManager:IsFrameSuspended() then
				GamepadMode.FrameControlsManager:SuspendFrame();
			end
			GamepadActionBarEditFrame:BindEquipmentSet(focusedButton.setID);
		end
	end

	local function DeleteGearSet()
		GamepadMode.FrameControlsManager:UnsuspendAllFrames();

		local focusedButton = SmartNavigation:GetCurrentButton();
		if focusedButton then
			focusedButton.DeleteButton:Click();
		end
	end

	local function OpenChangeNameAndIconSubmenu()
		GamepadMode.FrameControlsManager:UnsuspendAllFrames();

		local focusedButton = SmartNavigation:GetCurrentButton();
		if focusedButton then
			local openedFromContextActionMenu = true;
			GearSetButton_OpenPopup(focusedButton, openedFromContextActionMenu);
		end
	end

	-- FIXME CHANGE SUPPORT
	--local createGearSet = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, nil, ACTION_LABEL_SELECT);
	--createGearSet:AddCondition(IsCreateGearSetValid);
	--createGearSet:AddButtonContext("ButtonContext_GearSetButton");

	local openEquipmentSetMenu = GamepadSharedUtility.CreateMoreActionsPromptedBinding(GAMEPAD_FACE_BOTTOM);
	openEquipmentSetMenu:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	openEquipmentSetMenu:AddCondition(IsOpenGearSetValid);
	openEquipmentSetMenu:AddButtonContext("ButtonContext_GearSetButton");
	openEquipmentSetMenu:AddMoreActionsEntry(ACTION_LABEL_EQUIP_SET, EquipGearSet);
	openEquipmentSetMenu:AddMoreActionsEntry(ACTION_LABEL_SAVE_SET, SaveGearSet);
	-- FIXME ADD SUPPORT
	--openEquipmentSetMenu:AddMoreActionsEntry(ACTION_LABEL_NEW_SET, NewGearSet);
	openEquipmentSetMenu:AddMoreActionsEntry(ACTION_LABEL_BIND_SET, BindGearSetToGamepadActionBars);
	openEquipmentSetMenu:AddMoreActionsEntry(ACTION_LABEL_CHANGE_NAME_AND_ICON_FOR_SET, OpenChangeNameAndIconSubmenu);
	openEquipmentSetMenu:AddMoreActionsEntry(ACTION_LABEL_DELETE_SET, DeleteGearSet);

	-- FIXME CHANGE SUPPORT
	--table.insert(promptedBindings, createGearSet);
	table.insert(promptedBindings, openEquipmentSetMenu);

	return promptedBindings;
end

function PaperDollEquipmentManagerPane_OnLoad(self)
	local buttonFrameLevel = self:GetFrameLevel()+3;
	self.EquipSet:SetFrameLevel(buttonFrameLevel);
	self.SaveSet:SetFrameLevel(buttonFrameLevel);

	self:RegisterEvent("EQUIPMENT_SWAP_FINISHED");
	self:RegisterEvent("EQUIPMENT_SETS_CHANGED");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("BAG_UPDATE");

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("GearSetButtonTemplate", function(button, elementData)
		PaperDollEquipmentManagerPane_InitButton(button, elementData);
		if (InputUtil.IsGamepadUIEnabled()) then
			SmartNavigation_MarkFrameFocusable(button);
			SmartNavigation_RegisterOutgoingDirNavCallback(
				button,
				SMART_NAV_INPUT_DIRECTION.LEFT,
				GenerateClosure(CharacterFrameMixin.SwapToLeftSide, CharacterFrame)
			);
		end
	end);
	view:SetPadding(0,0,3,0,2);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self:RegisterForInterfaceTransitions();
end

function PaperDollEquipmentManagerPane_OnUpdate(self)
	local isGamepadUIEnabled = InputUtil.IsGamepadUIEnabled();
	local currentSmartNavButton;
	if (isGamepadUIEnabled) then
		currentSmartNavButton = SmartNavigation:GetCurrentButton();
	end

	local function MKB_UpdateEquipmentSetButton(button)
		if (button:IsMouseOver()) then
			if (button.setID) then
				button.DeleteButton:Show();
				button.EditButton:Show();
			else
				button.DeleteButton:Hide();
				button.EditButton:Hide();
			end
			button.HighlightBar:Show();
		else
			button.DeleteButton:Hide();
			button.EditButton:Hide();
			button.HighlightBar:Hide();
		end
	end

	local function Gamepad_UpdateEquipmentSetButton(button)
		if (button == currentSmartNavButton) then
			button.HighlightBar:Show();
		else
			button.HighlightBar:Hide();
		end

		button.EditButton:Hide();
		button.DeleteButton:Hide();
	end

	local setButtonUpdateFunc = MKB_UpdateEquipmentSetButton;
	if (isGamepadUIEnabled) then
		setButtonUpdateFunc = Gamepad_UpdateEquipmentSetButton;
	end

	self.ScrollBox:ForEachFrame(setButtonUpdateFunc);

	if (self.queuedUpdate) then
		PaperDollEquipmentManagerPane_Update();
		self.queuedUpdate = false;
	end
end

function PaperDollEquipmentManagerPane_OnShow(self)
	PaperDollEquipmentManagerPane_Update(true);
	EquipmentFlyoutPopoutButton_ShowAll();
end

function PaperDollEquipmentManagerPane_OnEvent(self, event, ...)

	if ( event == "EQUIPMENT_SWAP_FINISHED" ) then
		local completed, setID = ...;
		if ( completed ) then
			PlaySound(SOUNDKIT.PUT_DOWN_SMALL_CHAIN); -- plays the equip sound for plate mail
			if (self:IsShown()) then
				self.selectedSetID = setID;
				PaperDollEquipmentManagerPane_Update();
			end
		end
	end


	if (self:IsShown()) then
		if ( event == "EQUIPMENT_SETS_CHANGED" ) then
			PaperDollEquipmentManagerPane_Update(true);
		elseif ( event == "PLAYER_EQUIPMENT_CHANGED" or event == "BAG_UPDATE" ) then
			-- This queues the update to only happen once at the end of the frame
			self.queuedUpdate = true;
		end
	end
end

function PaperDollEquipmentManagerPane_OnHide(self)
	EquipmentFlyoutPopoutButton_HideAll();
	PaperDollFrame_ClearIgnoredSlots();
	GearManagerPopupFrame:Hide();
	StaticPopup_Hide("CONFIRM_SAVE_EQUIPMENT_SET");
	StaticPopup_Hide("CONFIRM_OVERWRITE_EQUIPMENT_SET");
end

function SortEquipmentSetIDs(equipmentSetIDs)
	local sortedIDs = {};

	-- Add all the spec-assigned sets first because they should appear first.
	for i, equipmentSetID in ipairs(equipmentSetIDs) do
		if C_EquipmentSet.GetEquipmentSetAssignedSpec(equipmentSetID) then
			sortedIDs[#sortedIDs + 1] = equipmentSetID;
		end
	end

	for i, equipmentSetID in ipairs(equipmentSetIDs) do
		if not C_EquipmentSet.GetEquipmentSetAssignedSpec(equipmentSetID) then
			sortedIDs[#sortedIDs + 1] = equipmentSetID;
		end
	end

	return sortedIDs;
end

function PaperDollEquipmentManagerPane_SetButtonSelected(button, selected)
	if selected then
		button.SelectedBar:Show();
	else
		button.SelectedBar:Hide();
	end
end

function PaperDollEquipmentManagerPane_InitButton(button, elementData)
	--if elementData.addSetButton then
	--	button.setID = nil;
	--	button.text:SetText(PAPERDOLL_NEWEQUIPMENTSET);
	--	button.text:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
	--	button.icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus");
	--	button.icon:SetSize(30, 30);
	--	button.icon:SetPoint("LEFT", 7, 0);
	--	button.Check:Hide();
	--	button.SelectedBar:Hide();
	--else
	local index = elementData.index;

	local equipmentSetIDs = PaperDollFrame.EquipmentManagerPane.equipmentSetIDs;
	local equipmentSetIndex = equipmentSetIDs[index];
	local numRows = #equipmentSetIDs;
	local name, texture, setID, isEquipped, _, _, _, numLost = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetIndex);
	button.setID = setID;
	button.text:SetText(name);
	if (numLost > 0) then
		button.text:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	else
		button.text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	if (texture) then
		button.icon:SetTexture(texture);
	else
		button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
	end

	local currentSelectionID = PaperDollFrame.EquipmentManagerPane.selectedSetID;
	local selected = currentSelectionID and button.setID == currentSelectionID;
	PaperDollEquipmentManagerPane_SetButtonSelected(button, selected);

	if (isEquipped) then
		button.Check:Show();
	else
		button.Check:Hide();
	end
	button.icon:SetSize(36, 36);
	button.icon:SetPoint("LEFT", 4, 0);
	--end

	GearSetButton_UpdateSpecInfo(button);
end

function PaperDollEquipmentManagerPane_Update(equipmentSetsDirty)

	local _, setID, isEquipped;
	if (PaperDollFrame.EquipmentManagerPane.selectedSetID) then
		_, _, setID, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(PaperDollFrame.EquipmentManagerPane.selectedSetID);
	end

	if (setID) then
		if (isEquipped) then
			PaperDollFrame.EquipmentManagerPane.SaveSet:Disable();
			PaperDollFrame.EquipmentManagerPane.EquipSet:Disable();
		else
			PaperDollFrame.EquipmentManagerPane.SaveSet:Enable();
			PaperDollFrame.EquipmentManagerPane.EquipSet:Enable();
		end
		PaperDollFrame_IgnoreSlotsForSet(setID);
	else
		PaperDollFrame.EquipmentManagerPane.SaveSet:Disable();
		PaperDollFrame.EquipmentManagerPane.EquipSet:Disable();

		-- Clear selected equipment set if it doesn't exist
		if (PaperDollFrame.EquipmentManagerPane.selectedSetID) then
			PaperDollFrame.EquipmentManagerPane.selectedSetID = nil;
			PaperDollFrame_ClearIgnoredSlots();
		end
	end

	if ( equipmentSetsDirty ) then
		PaperDollFrame.EquipmentManagerPane.equipmentSetIDs = SortEquipmentSetIDs(C_EquipmentSet.GetEquipmentSetIDs());
	end

	local dataProvider = CreateDataProvider();
	local numSets = #PaperDollFrame.EquipmentManagerPane.equipmentSetIDs;

	for index = 1, numSets do
		dataProvider:Insert({index=index});
	end

	PaperDollFrame.EquipmentManagerPane.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function PaperDollEquipmentManagerPaneSaveSet_OnClick(self)
	local selectedSetID = PaperDollFrame.EquipmentManagerPane.selectedSetID
	if (selectedSetID) then
		local selectedSetName = C_EquipmentSet.GetEquipmentSetInfo(selectedSetID);
		local dialog = StaticPopup_Show("CONFIRM_SAVE_EQUIPMENT_SET", selectedSetName, nil, selectedSetID);
		if ( not dialog ) then
			UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
		end
	end
end

function PaperDollEquipmentManagerPaneEquipSet_OnClick(self)
	local selectedSetID = PaperDollFrame.EquipmentManagerPane.selectedSetID;
	if ( selectedSetID) then
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);			-- inappropriately named, but a good sound.
		EquipmentManager_EquipSet(selectedSetID);
	end
end

function PaperDollEquipmentManagerPaneNewSet_OnClick()
	GearManagerPopupFrame.mode = IconSelectorPopupFrameModes.New;
	GearManagerPopupFrame:Show();
	PaperDollFrame.EquipmentManagerPane.selectedSetID = nil;
	PaperDollFrame_ClearIgnoredSlots();
	PaperDollEquipmentManagerPane_Update();
	-- Ignore shirt and tabard by default
	PaperDollFrame_IgnoreSlot(4);
	PaperDollFrame_IgnoreSlot(19);
end

function PaperDollTitlesPane_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("PlayerTitleButtonTemplate", function(button, elementData)
		PaperDollTitlesPane_InitButton(button, elementData);
	end);
	view:SetPadding(4,0,2,0,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function PaperDollTitlesPane_SetButtonSelected(button, selected)
	if ( selected ) then
		button.Check:Show();
		button.SelectedBar:Show();
	else
		button.Check:Hide();
		button.SelectedBar:Hide();
	end
end

function PaperDollTitlesPane_InitButton(button, elementData)
	local index = elementData.index;
	local playerTitle = elementData.playerTitle;
	button.text:SetText(playerTitle.name);
	button.titleId = playerTitle.id;

	local selected = PaperDollFrame.TitleManagerPane.selected == playerTitle.id;
	PaperDollTitlesPane_SetButtonSelected(button, selected);

	if (index == 1) then
		button.BgTop:Show();
		button.BgMiddle:SetPoint("TOP", button.BgTop, "BOTTOM");
	else
		button.BgTop:Hide();
		button.BgMiddle:SetPoint("TOP");
	end

	local playerTitles = PaperDollFrame.TitleManagerPane.titles;
	if (index == #playerTitles) then
		button.BgBottom:Show();
		button.BgMiddle:SetPoint("BOTTOM", button.BgBottom, "TOP");
	else
		button.BgBottom:Hide();
		button.BgMiddle:SetPoint("BOTTOM");
	end

	if (index % 2 == 0) then
		button.Stripe:SetColorTexture(STRIPE_COLOR.r, STRIPE_COLOR.g, STRIPE_COLOR.b);
		button.Stripe:SetAlpha(0.1);
		button.Stripe:Show();
	else
		button.Stripe:Hide();
	end
end

function PaperDollTitlesPane_UpdateScrollBox()
	local dataProvider = CreateDataProvider();
	for index, playerTitle in ipairs(PaperDollFrame.TitleManagerPane.titles) do
		dataProvider:Insert({index=index, playerTitle=playerTitle});
	end
	PaperDollFrame.TitleManagerPane.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

local function PlayerTitleSort(a, b) return a.name < b.name; end

function GetKnownTitles()
	local playerTitles = { };
	local titleCount = 1;
	local playerTitle = false;
	local tempName = 0;
	local selectedTitle = -1;
	playerTitles[1] = { };
	-- reserving space for None so it doesn't get sorted out of the top position
	playerTitles[1].name = "       ";
	playerTitles[1].id = -1;
	for i = 1, GetNumTitles() do
		if ( IsTitleKnown(i) ) then
			tempName, playerTitle = GetTitleName(i);
			if ( tempName and playerTitle ) then
				titleCount = titleCount + 1;
				playerTitles[titleCount] = playerTitles[titleCount] or { };
				playerTitles[titleCount].name = strtrim(tempName);
				playerTitles[titleCount].id = i;
			end
		end
	end

	return playerTitles, selectedTitle;
end

function PaperDollTitlesPane_Update()
	local currentTitle = GetCurrentTitle();
	local playerTitles = GetKnownTitles();
	if ( currentTitle > 0 and currentTitle <= GetNumTitles() and IsTitleKnown(currentTitle) ) then
		PaperDollFrame.TitleManagerPane.selected = currentTitle;
	else
		PaperDollFrame.TitleManagerPane.selected = -1;
	end

	table.sort(playerTitles, PlayerTitleSort);
	playerTitles[1].name = PLAYER_TITLE_NONE;
	PaperDollFrame.TitleManagerPane.titles = playerTitles;

	PaperDollTitlesPane_UpdateScrollBox();
end

function PlayerTitleButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	SetCurrentTitle(self.titleId);
end

function SetTitleByName(name)
	name = strlower(name);
	for i = 1, GetNumTitles() do
		if ( IsTitleKnown(i) ) then
			local title = GetTitleName(i);
			title = strlower(strtrim(title));
			if(title:find(name) == 1) then
				SetCurrentTitle(i);
				return true;
			end
		end
	end
	return false;
end

function SetPaperDollBackground(model, unit)
	local _race, fileName = UnitRace(unit);
	local texture = DressUpTexturePath(fileName);
	model.BackgroundTopLeft:SetTexture(texture..1);
	model.BackgroundTopRight:SetTexture(texture..2);
	model.BackgroundBotLeft:SetTexture(texture..3);
	model.BackgroundBotRight:SetTexture(texture..4);
end

function PaperDollBgDesaturate(on)
	CharacterModelFrameBackgroundTopLeft:SetDesaturated(on);
	CharacterModelFrameBackgroundTopRight:SetDesaturated(on);
	CharacterModelFrameBackgroundBotLeft:SetDesaturated(on);
	CharacterModelFrameBackgroundBotRight:SetDesaturated(on);
end

function PaperDollFrame_UpdateSidebarTabLayout()
	local hasPet = HasPetUI();
	local tab1 = PaperDollSidebarTab1;
	local tab2 = PaperDollSidebarTab2;
	local tab3 = PaperDollSidebarTab3;

	if not tab1 or not tab2 or not tab3 then
		return;
	end

	tab3:SetShown(hasPet);

	tab1:ClearAllPoints();
	tab2:ClearAllPoints();
	tab3:ClearAllPoints();

	if hasPet then
		-- Preserve the original 3-tab anchor rules from XML.
		tab2:SetPoint("TOP", PaperDollSidebarTabs, "TOP", 0, -5);
		tab3:SetPoint("LEFT", tab2, "RIGHT", 0, 0);
		tab1:SetPoint("RIGHT", tab2, "LEFT", 0, 0);
	else
		-- Recenter tab1 + tab2 as a two-tab group when no pet tab is available.
		local centerOffset = tab2:GetWidth() * 0.5;
		tab2:SetPoint("TOP", PaperDollSidebarTabs, "TOP", centerOffset, -5);
		tab1:SetPoint("RIGHT", tab2, "LEFT", 0, 0);
	end
end

function PaperDollFrame_UpdateSidebarTabs()
	PaperDollFrame_UpdateSidebarTabLayout();

	for i = 1, #PAPERDOLL_SIDEBARS do
		local tab = _G["PaperDollSidebarTab"..i];
		if (tab and tab:IsShown()) then
			if i == 1 and tab.Icon then
				SetPortraitTexture(tab.Icon, "player");
			end

			local frame = GetPaperDollSideBarFrame(i);
			local isSelected = frame:IsShown();
			tab:SetChecked(isSelected);
			if isSelected then
				PaperDollFrame.selectedTab = i;
			end

			if ( PAPERDOLL_SIDEBARS[i].IsActive() ) then
				tab:Enable();
				tab.isDisabled = false;
			else
				tab:Disable();
				tab.isDisabled = true;
			end
		end
	end
end

function PaperDollFrame_SetSidebar(self, index)
	local frame = GetPaperDollSideBarFrame(index);
	if (not frame:IsShown()) then
		for i = 1, #PAPERDOLL_SIDEBARS do
			local barFrame = GetPaperDollSideBarFrame(i);
			barFrame:Hide();
		end

		if index == 3 then
			CharacterFrameRightPaneHostStoneBg:SetAtlas("UI-Character-Info-Stat-StoneBG2", true);
		else
			CharacterFrameRightPaneHostStoneBg:SetAtlas("UI-Character-Info-Stat-StoneBG", true);
		end

		frame:Show();
		PaperDollFrame_ShowSidebar(frame);
		PaperDollFrame.currentSideBar = frame;
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		PaperDollFrame_UpdateSidebarTabs();
	end
end

function PaperDollFrame_OnModelLoaded(frame, actor)
	actor:Show();
end

function PaperDollFrame_SetPet()
	if not HasPetUI() then
		return;
	end
	local modelScene = C_PetInfo.GetPetUIModelSceneID();

	if not modelScene or modelScene == 0 then
		modelScene = DEFAULT_PET_MODEL_SCENE_ID;
	end

	CharacterModelScene:ReleaseAllActors();
	local forceSceneChange = true;
	CharacterModelScene:TransitionToModelSceneID(modelScene, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);
	local actor = CharacterModelScene:GetActorByTag("pet");
	if actor then
		actor:Hide();
		actor:SetOnModelLoadedCallback(GenerateClosure(PaperDollFrame_OnModelLoaded, frame, actor));
		actor:SetModelByUnitCreatureDisplayID("pet");
	end
end

function PaperDollFrame_ShowSidebar(frame)
	if frame == CharacterStatsPanePetScrollBox then
		-- Show pet model and elements
		PaperDollItemsFrame:Hide();

		PetPaperDollFrameExpBar:Show();

		PaperDollFrame_SetPetLevel();

		PaperDollFrame_SetPet();
	else
		-- Restore character elements when switching back
		PaperDollItemsFrame:Show();

		PetPaperDollFrameExpBar:Hide();

		PaperDollFrame_SetLevel();

		PaperDollFrame_SetPlayer();

		ModelSceneUtil.SetPlayerActor(CharacterModelScene);

		-- The sidebar updates after the main PaperDollFrame is shown, so we need to wait for this before parsing gamepad focus.
		if InputUtil.IsGamepadUIEnabled() then
			SmartNavigation:SelectTopLeftButton();
		end
	end
end

local inventoryFixupVersionToTutorialIndex =
{
	{
		seenIndex = LE_FRAME_TUTORIAL_INVENTORY_FIXUP_EXPANSION_LEGION,
		checkIndex = LE_FRAME_TUTORIAL_INVENTORY_FIXUP_CHECK_EXPANSION_LEGION,
	},
};

local function CheckFixupStates(fixupVersion)
	local fixupTutorialIndices = fixupVersion and inventoryFixupVersionToTutorialIndex[fixupVersion];

	-- Set the appropriate index to check, this is how the client knows the user's
	-- inventory was fixed up at some point in the past, but hasn't seen the tutorial yet.
	if fixupTutorialIndices and fixupTutorialIndices.checkIndex then
		SetCVarBitfield("closedInfoFrames", fixupTutorialIndices.checkIndex, true);
	end

	-- Return the any matching tutorial that the user hasn't seen
	for expansionID, tutorialIndices in pairs(inventoryFixupVersionToTutorialIndex) do
		local doCheck = GetCVarBitfield("closedInfoFrames", tutorialIndices.checkIndex);
		local seenTutorial = GetCVarBitfield("closedInfoFrames", tutorialIndices.seenIndex);
		if doCheck and not seenTutorial then
			return tutorialIndices.seenIndex;
		end
	end
end

function PaperDollFrame_HideInventoryFixupComplete(self)
	HelpTip:Hide(self, PAPERDOLL_INVENTORY_FIXUP_COMPLETE);
	MicroButtonPulseStop(CharacterMicroButton);
end

PaperDollItemSlotButtonBaseMixin = {};

function PaperDollItemSlotButtonBaseMixin:SetTooltipAnchor(tooltip)
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
end

PaperDollItemSlotButtonMixin = CreateFromMixins(PaperDollItemSlotButtonBaseMixin);

function PaperDollItemSlotButtonMixin:GetItemContextMatchResult()
	return ItemButtonUtil.GetItemContextMatchResultForItem(ItemLocation:CreateFromEquipmentSlot(self:GetID()));
end

PaperDollItemSocketDisplayMixin = CreateFromMixins(PaperDollItemSlotButtonBaseMixin);

function PaperDollItemSocketDisplayMixin:SetItem(item)
	-- Currently only showing socket display for timerunning characters
	local showSocketDisplay = item ~= nil and PlayerIsTimerunning();
	self:SetShown(showSocketDisplay);

	if not showSocketDisplay then
		return;
	end

	local numSockets = C_Item.GetItemNumSockets(item);
	for index, slot in ipairs(self.Slots) do
		slot:SetShown(index <= numSockets);

		-- Can get gemID without the gem being loaded in item sparse (can't use GetItemGem)
		local gemID = C_Item.GetItemGemID(item, index);
		local hasGem = gemID ~= nil;

		slot.Gem:SetShown(hasGem);

		if hasGem then
			local gemItem = Item:CreateFromItemID(gemID);

			-- Prevent edge case a different gem was previously shown, but new gem not cached yet
			if not gemItem:IsItemDataCached() then
				slot.Gem:SetTexture();
			end

			-- Icon requires item sparse, need to use a callback if not loaded
			gemItem:ContinueOnItemLoad(function()
				local gemIcon = C_Item.GetItemIconByID(gemID);
				slot.Gem:SetTexture(gemIcon);
			end);
		end
	end

	self:Layout();
end

PaperDollSidebarTabMixin = {};

function PaperDollSidebarTabMixin:OnLoad()
	if PAPERDOLL_SIDEBARS[self:GetID()].atlas then
		self.Icon:SetAtlas(PAPERDOLL_SIDEBARS[self:GetID()].atlas);
	elseif PAPERDOLL_SIDEBARS[self:GetID()].icon then
		self.Icon:SetTexture(PAPERDOLL_SIDEBARS[self:GetID()].icon);
		local tcoords = PAPERDOLL_SIDEBARS[self:GetID()].texCoords;
		self.Icon:SetTexCoord(tcoords[1], tcoords[2], tcoords[3], tcoords[4]);
	end

	self.disabledTooltip = PAPERDOLL_SIDEBARS[self:GetID()].disabledTooltip;

	if PAPERDOLL_SIDEBARS[self:GetID()].OnLoad then
		PAPERDOLL_SIDEBARS[self:GetID()].OnLoad(self);
	end
end

function PaperDollSidebarTabMixin:OnClick()
	PaperDollFrame_SetSidebar(self, self:GetID());
	if InputUtil.IsGamepadUIEnabled() and SmartNavigation:GetActiveFrame() == CharacterFrame then
		SmartNavigation_SelectScrollBoxCurrentOrTop(PaperDollFrame.currentSideBar.ScrollBox);
	end
end

function PaperDollSidebarTabMixin:OnEnable()
	self:SetAlpha(1);
	self.Icon:SetDesaturation(0);
end

function PaperDollSidebarTabMixin:OnDisable()
	self:SetAlpha(0.5);
	self.Icon:SetDesaturation(1);
end

function PaperDollSidebarTabMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, PAPERDOLL_SIDEBARS[self:GetID()].name);
	if not self:IsEnabled() and self.disabledTooltip then
		local disabledTooltipText = GetValueOrCallFunction(self, "disabledTooltip");
		GameTooltip_AddErrorLine(GameTooltip, disabledTooltipText, true);
	end
	GameTooltip:Show();
end

function PaperDollSidebarTabMixin:OnLeave()
	GameTooltip:Hide();
end

function PaperDollSidebarTabMixin:OnEvent(event, ...)
	if PAPERDOLL_SIDEBARS[self:GetID()].OnEvent then
		PAPERDOLL_SIDEBARS[self:GetID()].OnEvent(self, event, ...);
	end
end

function PaperDollAmmoSlotButton_OnLoad(self)
	self.maxDisplayCount = 999;
	PaperDollItemSlotButton_OnLoad(self);
	self.IconBorder:Hide();
end

function PaperDollAmmoSlotButton_OnShow(self)
	PaperDollItemSlotButton_OnShow(self);
	self.IconBorder:Hide();
end

PaperDollTertiaryButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function PaperDollTertiaryButtonMixin:OnButtonStateChanged()
	local atlas;
	if not self:IsEnabled() then
		atlas = "common-button-tertiary-disabled";
	elseif self:IsDownOver() then
		atlas = "common-button-tertiary-pressed";
	elseif self:IsOver() then
		atlas = "common-button-tertiary-hover";
	else
		atlas ="common-button-tertiary-normal";
	end

	self.StateTexture:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

PetExpColoredProgressBarMixin = CreateFromMixins(ColoredProgressBarMixin);

function PetExpColoredProgressBarMixin:OnLoad()
	ColoredProgressBarMixin.OnLoad(self);

	self:SetFillTextureByColorType(ColoredProgressBarMixin.ColorType.Green);
end

function PetExpColoredProgressBarMixin:OnUpdate()
	local currXP, nextXP = GetPetExperience();
	local percent = 0;
	if nextXP ~= 0 then
		percent = currXP / nextXP;
	end

	self:SetText(string.format("XP %s/%s", currXP, nextXP));
	self:SetFillPercent(percent);
end
