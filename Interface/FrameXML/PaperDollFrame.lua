NUM_STATS = 5;
NUM_SHOPPING_TOOLTIPS = 2;
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
MANA_PER_INTELLECT = 15;
BASE_MOVEMENT_SPEED = 7;
CREATURE_HP_PER_STA = 10;

local BreakUpLargeNumbers = BreakUpLargeNumbers;

--Pet scaling:
HUNTER_PET_BONUS = {};
HUNTER_PET_BONUS["PET_BONUS_RAP_TO_AP"] = 0.22;
HUNTER_PET_BONUS["PET_BONUS_RAP_TO_SPELLDMG"] = 0.1287;
HUNTER_PET_BONUS["PET_BONUS_STAM"] = 0.3;
HUNTER_PET_BONUS["PET_BONUS_RES"] = 0.4;
HUNTER_PET_BONUS["PET_BONUS_ARMOR"] = 0.7;
HUNTER_PET_BONUS["PET_BONUS_SPELLDMG_TO_SPELLDMG"] = 0.0;
HUNTER_PET_BONUS["PET_BONUS_SPELLDMG_TO_AP"] = 0.0;
HUNTER_PET_BONUS["PET_BONUS_INT"] = 0.0;

WARLOCK_PET_BONUS = {};
WARLOCK_PET_BONUS["PET_BONUS_RAP_TO_AP"] = 0.0;
WARLOCK_PET_BONUS["PET_BONUS_RAP_TO_SPELLDMG"] = 0.0;
WARLOCK_PET_BONUS["PET_BONUS_STAM"] = 0.3;
WARLOCK_PET_BONUS["PET_BONUS_RES"] = 0.4;
WARLOCK_PET_BONUS["PET_BONUS_ARMOR"] = 1.00;
WARLOCK_PET_BONUS["PET_BONUS_SPELLDMG_TO_SPELLDMG"] = 0.15;
WARLOCK_PET_BONUS["PET_BONUS_SPELLDMG_TO_AP"] = 0.57;
WARLOCK_PET_BONUS["PET_BONUS_INT"] = 0.3;

PLAYER_DISPLAYED_TITLES = 6;
PLAYER_TITLE_HEIGHT = 22;

EQUIPMENTSET_BUTTON_HEIGHT = 44;

local itemSlotButtons = {};

MOVING_STAT_CATEGORY = nil;

local StatCategoryFrames = {};

local STRIPE_COLOR = {r=0.9, g=0.9, b=1};

MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY = 10;

PAPERDOLL_SIDEBARS = {
	{
		name=PAPERDOLL_SIDEBAR_STATS;
		icon = nil;  -- Uses the character portrait
		texCoords = {0.109375, 0.890625, 0.09375, 0.90625};
		disabledTooltip = nil;
		IsActive = function() return true; end
	},
	{
		name=PAPERDOLL_SIDEBAR_TITLES;
		icon = "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs";
		texCoords = {0.01562500, 0.53125000, 0.32421875, 0.46093750};
		disabledTooltip = NO_TITLES_TOOLTIP;
		IsActive = function()
			-- You always have the "No Title" title so you need to have more than one to have an option.
			return #GetKnownTitles() > 1;
		end
	},
	{
		name=PAPERDOLL_EQUIPMENTMANAGER;
		icon = "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs";
		texCoords = {0.01562500, 0.53125000, 0.46875000, 0.60546875};
		disabledTooltip = function()
			local _, failureReason = C_LFGInfo.CanPlayerUseLFD();
			return failureReason;
		end;
		IsActive = function()
			return C_EquipmentSet.GetNumEquipmentSets() > 0 or C_LFGInfo.CanPlayerUseLFD();
		end
	},
};

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

function GetPaperDollSideBarFrame(index)
	if index == 1 then
		return CharacterStatsPane;
	elseif index == 2 then
		return PaperDollFrame.TitleManagerPane;
	elseif index == 3 then
		return PaperDollFrame.EquipmentManagerPane;
	end
end

PAPERDOLL_STATINFO = {

	-- General
	["HEALTH"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetHealth(statFrame, unit); end
	},
	["POWER"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetPower(statFrame, unit); end
	},
	["ALTERNATEMANA"] = {
		-- Only appears for Druids when in shapeshift form
		updateFunc = function(statFrame, unit) PaperDollFrame_SetAlternateMana(statFrame, unit); end
	},
	["ITEMLEVEL"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetItemLevel(statFrame, unit); end
	},
	["MOVESPEED"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetMovementSpeed(statFrame, unit); end
	},

	-- Base stats
	["STRENGTH"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_STRENGTH); end
	},
	["AGILITY"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_AGILITY); end
	},
	["INTELLECT"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_INTELLECT); end
	},
	["STAMINA"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_STAMINA); end
	},

	-- Enhancements
	["CRITCHANCE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetCritChance(statFrame, unit); end
	},
	["HASTE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetHaste(statFrame, unit); end
	},
	["MASTERY"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetMastery(statFrame, unit); end
	},
	["VERSATILITY"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetVersatility(statFrame, unit); end
	},
	["LIFESTEAL"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetLifesteal(statFrame, unit); end
	},
	["AVOIDANCE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetAvoidance(statFrame, unit); end
	},
	["SPEED"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetSpeed(statFrame, unit); end
	},

	-- Attack
	["ATTACK_DAMAGE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetDamage(statFrame, unit); end
	},
	["ATTACK_AP"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetAttackPower(statFrame, unit); end
	},
	["ATTACK_ATTACKSPEED"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetAttackSpeed(statFrame, unit); end
	},
	["ENERGY_REGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetEnergyRegen(statFrame, unit); end
	},
	["RUNE_REGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetRuneRegen(statFrame, unit); end
	},
	["FOCUS_REGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetFocusRegen(statFrame, unit); end
	},

	-- Spell
	["SPELLPOWER"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellPower(statFrame, unit); end
	},
	["MANAREGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetManaRegen(statFrame, unit); end
	},

	-- Defense
	["ARMOR"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetArmor(statFrame, unit); end
	},
	["DODGE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetDodge(statFrame, unit); end
	},
	["PARRY"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetParry(statFrame, unit); end
	},
	["BLOCK"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetBlock(statFrame, unit); end
	},
	["STAGGER"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetStagger(statFrame, unit); end
	},
};

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
	self:RegisterEvent("UNIT_STATS");
	self:RegisterEvent("UNIT_RANGEDDAMAGE");
	self:RegisterEvent("UNIT_ATTACK_POWER");
	self:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
	self:RegisterEvent("UNIT_ATTACK");
	self:RegisterEvent("UNIT_SPELL_HASTE");
	self:RegisterEvent("UNIT_RESISTANCES");
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
	local width = CharacterTrialLevelErrorText:GetWidth();
	if ( width > 190 ) then
		CharacterTrialLevelErrorText:SetPoint("TOP", CharacterLevelText, "BOTTOM", -((width-190)/2), 2);
	end
	if( GameLimitedMode_IsActive() ) then
		CharacterTrialLevelErrorText:SetText(CAPPED_LEVEL_TRIAL);
	end
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
	if ( event == "PLAYER_ENTERING_WORLD" or event == "GX_RESTARTED") then
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
	local primaryTalentTree = GetSpecialization();
	local classDisplayName, class = UnitClass("player");
	local classColorString = RAID_CLASS_COLORS[class].colorStr;
	local specName, _;

	if (primaryTalentTree) then
		_, specName = GetSpecializationInfo(primaryTalentTree, nil, nil, nil, UnitSex("player"));
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
	if (showTrialCap) then
		CharacterLevelText:SetPoint("CENTER", PaperDollFrame, "TOP", 0, -36);
	else
		CharacterLevelText:SetPoint("CENTER", PaperDollFrame, "TOP", 0, -42);
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
end

function PaperDollFrame_SetAlternateMana(statFrame, unit)
	if (not unit) then
		unit = "player";
	end
	local _, class = UnitClass(unit);
	if (class ~= "DRUID" and (class ~= "MONK" or GetSpecialization() ~= SPEC_MONK_MISTWEAVER)) then
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
end

function PaperDollFrame_SetStat(statFrame, unit, statIndex)
	if (unit ~= "player") then
		statFrame:Hide();
		return;
	end

	local stat;
	local effectiveStat;
	local posBuff;
	local negBuff;
	stat, effectiveStat, posBuff, negBuff = UnitStat(unit, statIndex);

	local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat);
	-- Set the tooltip text
	local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." ";

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		statFrame.tooltip = tooltipText..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
	else
		tooltipText = tooltipText..effectiveStatDisplay;
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
		statFrame.tooltip = tooltipText;

		-- If there are any negative buffs then show the main number in red even if there are
		-- positive buffs. Otherwise show in green.
		if ( negBuff < 0 and not GetPVPGearStatRules() ) then
			effectiveStatDisplay = RED_FONT_COLOR_CODE..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
		end
	end
	PaperDollFrame_SetLabelAndText(statFrame, statName, effectiveStatDisplay, false, effectiveStat);
	statFrame.tooltip2 = _G["DEFAULT_STAT"..statIndex.."_TOOLTIP"];

	if (unit == "player") then
		local _, unitClass = UnitClass("player");
		unitClass = strupper(unitClass);

		local primaryStat, spec, role;
		spec = GetSpecialization();
		if (spec) then
			role = GetSpecializationRole(spec);
			primaryStat = select(6, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")));
		end
		-- Strength
		if ( statIndex == LE_UNIT_STAT_STRENGTH ) then
			local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
			if (HasAPEffectsSpellPower()) then
				statFrame.tooltip2 = STAT_TOOLTIP_BONUS_AP_SP;
			end
			if (not primaryStat or primaryStat == LE_UNIT_STAT_STRENGTH) then
				statFrame.tooltip2 = format(statFrame.tooltip2, BreakUpLargeNumbers(attackPower));
				if ( role == "TANK" ) then
					local increasedParryChance = GetParryChanceFromAttribute();
					if ( increasedParryChance > 0 ) then
						statFrame.tooltip2 = statFrame.tooltip2.."|n|n"..format(CR_PARRY_BASE_STAT_TOOLTIP, increasedParryChance);
					end
				end
			else
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			end
		-- Agility
		elseif ( statIndex == LE_UNIT_STAT_AGILITY ) then
			if (not primaryStat or primaryStat == LE_UNIT_STAT_AGILITY) then
				statFrame.tooltip2 = HasAPEffectsSpellPower() and STAT_TOOLTIP_BONUS_AP_SP or STAT_TOOLTIP_BONUS_AP;
				if ( role == "TANK" ) then
					local increasedDodgeChance = GetDodgeChanceFromAttribute();
					if ( increasedDodgeChance > 0 ) then
						statFrame.tooltip2 = statFrame.tooltip2.."|n|n"..format(CR_DODGE_BASE_STAT_TOOLTIP, increasedDodgeChance);
					end
				end
			else
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			end
		-- Stamina
		elseif ( statIndex == LE_UNIT_STAT_STAMINA ) then
			statFrame.tooltip2 = format(statFrame.tooltip2, BreakUpLargeNumbers(((effectiveStat*UnitHPPerStamina("player")))*GetUnitMaxHealthModifier("player")));
		-- Intellect
		elseif ( statIndex == LE_UNIT_STAT_INTELLECT ) then
			if ( HasAPEffectsSpellPower() ) then
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			elseif ( HasSPEffectsAttackPower() ) then
					statFrame.tooltip2 = STAT_TOOLTIP_BONUS_AP_SP;
			elseif ( not primaryStat or primaryStat == LE_UNIT_STAT_INTELLECT ) then
				statFrame.tooltip2 = format(statFrame.tooltip2, max(0, effectiveStat));
			else
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			end
		end
	end
	statFrame:Show();
end

function PaperDollFrame_SetArmor(statFrame, unit)
	local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor(unit);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_ARMOR, BreakUpLargeNumbers(effectiveArmor), false, effectiveArmor);
    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit));
	local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ARMOR).." "..BreakUpLargeNumbers(effectiveArmor)..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(STAT_ARMOR_TOOLTIP, armorReduction);
	if (armorReductionAgainstTarget) then
		statFrame.tooltip3 = format(STAT_ARMOR_TARGET_TOOLTIP, armorReductionAgainstTarget);
	else
		statFrame.tooltip3 = nil;
	end
	statFrame:Show();
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
end

function PaperDollFrame_SetDodge(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide();
		return;
	end

	local chance = GetDodgeChance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_DODGE, chance, true, chance);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
	statFrame:Show();
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
end

function PaperDollFrame_SetParry(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide();
		return;
	end

	local chance = GetParryChance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, chance, true, chance);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
	statFrame:Show();
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
end

local function GetAppropriateDamage(unit)
	if IsRangedWeapon() then
		local attackTime, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage(unit);
		return minDamage, maxDamage, nil, nil, 0, 0, percent;
	else
		return UnitDamage(unit);
	end
end

function PaperDollFrame_SetDamage(statFrame, unit)
	local speed, offhandSpeed = UnitAttackSpeed(unit);
	local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = GetAppropriateDamage(unit);

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

	local value;
	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then
			value = displayMinLarge.." - "..displayMaxLarge;
		else
			value = displayMinLarge.."-"..displayMaxLarge;
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
			value = color..displayMinLarge.." - "..displayMaxLarge.."|r";
		else
			value = color..displayMinLarge.."-"..displayMaxLarge.."|r";
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
	PaperDollFrame_SetLabelAndText(statFrame, DAMAGE, value, false, displayMax);
	statFrame.damage = damageTooltip;
	statFrame.attackSpeed = speed;
	statFrame.unit = unit;

	-- If there's an offhand speed then add the offhand info to the tooltip
	if ( offhandSpeed and minOffHandDamage and maxOffHandDamage ) then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local offhandDamageTooltip = BreakUpLargeNumbers(max(floor(minOffHandDamage),1)).." - "..BreakUpLargeNumbers(max(ceil(maxOffHandDamage),1));
		if ( physicalBonusPos > 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
		statFrame.offhandDamage = offhandDamageTooltip;
		statFrame.offhandAttackSpeed = offhandSpeed;
	else
		statFrame.offhandAttackSpeed = nil;
	end

	statFrame.onEnterFunc = CharacterDamageFrame_OnEnter;

	statFrame:Show();
end

function PaperDollFrame_SetAttackSpeed(statFrame, unit)
	local meleeHaste = GetMeleeHaste();
	local speed, offhandSpeed = UnitAttackSpeed(unit);

	local displaySpeed = format("%.2F", speed);
	if ( offhandSpeed ) then
		offhandSpeed = format("%.2F", offhandSpeed);
	end
	if ( offhandSpeed ) then
		displaySpeed =  BreakUpLargeNumbers(displaySpeed).." / ".. offhandSpeed;
	else
		displaySpeed =  BreakUpLargeNumbers(displaySpeed);
	end
	PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste));

	statFrame:Show();
end

function PaperDollFrame_SetAttackPower(statFrame, unit)
	local base, posBuff, negBuff;

	local rangedWeapon = IsRangedWeapon();

	local tag, tooltip;
	if ( rangedWeapon ) then
		base, posBuff, negBuff = UnitRangedAttackPower(unit);
		tag, tooltip = RANGED_ATTACK_POWER, RANGED_ATTACK_POWER_TOOLTIP;
	else
	 	base, posBuff, negBuff = UnitAttackPower(unit);
	 	tag, tooltip = MELEE_ATTACK_POWER, MELEE_ATTACK_POWER_TOOLTIP;
	end

	local damageBonus =  BreakUpLargeNumbers(max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER);
	local spellPower = 0;
	local value, valueText, tooltipText;
	if (GetOverrideAPBySpellPower() ~= nil) then
		local holySchool = 2;
		-- Start at 2 to skip physical damage
		spellPower = GetSpellBonusDamage(holySchool);
		for i=(holySchool+1), MAX_SPELL_SCHOOLS do
			spellPower = min(spellPower, GetSpellBonusDamage(i));
		end
		spellPower = min(spellPower, GetSpellBonusHealing()) * GetOverrideAPBySpellPower();

		value = spellPower;
		valueText, tooltipText = PaperDollFormatStat(tag, spellPower, 0, 0);
		damageBonus = BreakUpLargeNumbers(spellPower / ATTACK_POWER_MAGIC_NUMBER);
	else
		value = base;
		valueText, tooltipText = PaperDollFormatStat(tag, base, posBuff, negBuff);
	end
	PaperDollFrame_SetLabelAndText(statFrame, STAT_ATTACK_POWER, valueText, false, value);
	statFrame.tooltip = tooltipText;

	local effectiveAP = max(0,base + posBuff + negBuff);
	if (GetOverrideSpellPowerByAP() ~= nil) then
		statFrame.tooltip2 = format(MELEE_ATTACK_POWER_SPELL_POWER_TOOLTIP, damageBonus, BreakUpLargeNumbers(effectiveAP * GetOverrideSpellPowerByAP() + 0.5));
	else
		statFrame.tooltip2 = format(tooltip, damageBonus);
	end
	statFrame:Show();
end

function PaperDollFrame_SetSpellPower(statFrame, unit)
	local minModifier = 0;

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
			statFrame.bonusDamage[i] = bonusDamage;
		end
	elseif (unit == "pet") then
		minModifier = GetPetSpellBonusDamage();
		statFrame.bonusDamage = nil;
	end

	PaperDollFrame_SetLabelAndText(statFrame, STAT_SPELLPOWER, BreakUpLargeNumbers(minModifier), false, minModifier);
	statFrame.tooltip = STAT_SPELLPOWER;
	statFrame.tooltip2 = STAT_SPELLPOWER_TOOLTIP;

	statFrame.minModifier = minModifier;
	statFrame.unit = unit;
	statFrame.onEnterFunc = CharacterSpellBonusDamage_OnEnter;
	statFrame:Show();
end

function PaperDollFrame_SetCritChance(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local rating;
	local spellCrit, rangedCrit, meleeCrit;
	local critChance;

	-- Start at 2 to skip physical damage
	local holySchool = 2;
	local minCrit = GetSpellCritChance(holySchool);
	statFrame.spellCrit = {};
	statFrame.spellCrit[holySchool] = minCrit;
	local spellCrit;
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i);
		minCrit = min(minCrit, spellCrit);
		statFrame.spellCrit[i] = spellCrit;
	end
	spellCrit = minCrit
	rangedCrit = GetRangedCritChance();
	meleeCrit = GetCritChance();

	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit;
		rating = CR_CRIT_SPELL;
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit;
		rating = CR_CRIT_RANGED;
	else
		critChance = meleeCrit;
		rating = CR_CRIT_MELEE;
	end

	PaperDollFrame_SetLabelAndText(statFrame, STAT_CRITICAL_STRIKE, critChance, true, critChance);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE)..FONT_COLOR_CODE_CLOSE;
	local extraCritChance = GetCombatRatingBonus(rating);
	local extraCritRating = GetCombatRating(rating);
	if (GetCritChanceProvidesParryEffect()) then
		statFrame.tooltip2 = format(CR_CRIT_PARRY_RATING_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating));
	else
		statFrame.tooltip2 = format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance);
	end
	statFrame:Show();
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
end


function PaperDollFrame_SetHaste(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local haste = GetHaste();
	local rating = CR_HASTE_MELEE;

	local hasteFormatString;
	if (haste < 0 and not GetPVPGearStatRules()) then
		hasteFormatString = RED_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE;
	else
		hasteFormatString = "%s";
	end

	PaperDollFrame_SetLabelAndText(statFrame, STAT_HASTE, format(hasteFormatString, format("%d%%", haste + 0.5)), false, haste);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE)..FONT_COLOR_CODE_CLOSE;

	local _, class = UnitClass(unit);
	statFrame.tooltip2 = _G["STAT_HASTE_"..class.."_TOOLTIP"];
	if (not statFrame.tooltip2) then
		statFrame.tooltip2 = STAT_HASTE_TOOLTIP;
	end
	statFrame.tooltip2 = statFrame.tooltip2 .. format(STAT_HASTE_BASE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(rating)), GetCombatRatingBonus(rating));

	statFrame:Show();
end

function PaperDollFrame_SetManaRegen(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	if ( not UnitHasMana("player") ) then
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
end

function Mastery_OnEnter(statFrame)
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");

	local _, class = UnitClass("player");
	local mastery, bonusCoeff = GetMasteryEffect();
	local masteryBonus = GetCombatRatingBonus(CR_MASTERY) * bonusCoeff;

	local primaryTalentTree = GetSpecialization();
	if (primaryTalentTree) then
		local masterySpell, masterySpell2 = GetSpecializationMasterySpells(primaryTalentTree);
		if (masterySpell) then
			GameTooltip:AppendInfo("GetSpellByID", masterySpell);
		end
		if (masterySpell2) then
			GameTooltip:AppendInfoWithSpacer("GetSpellByID", masterySpell2);
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
end

function MovementSpeed_OnEnter(statFrame)
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MOVEMENT_SPEED).." "..format("%d%%", statFrame.speed+0.5)..FONT_COLOR_CODE_CLOSE);

	GameTooltip:AddLine(format(STAT_MOVEMENT_GROUND_TOOLTIP, statFrame.runSpeed+0.5));
	if (statFrame.unit ~= "pet") then
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
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	statFrame.wasSwimming = nil;
	statFrame.unit = unit;
	statFrame:Show();
	MovementSpeed_OnUpdate(statFrame);

	statFrame.onEnterFunc = MovementSpeed_OnEnter;
end

function CharacterSpellBonusDamage_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, self.tooltip).." "..BreakUpLargeNumbers(self.minModifier)..FONT_COLOR_CODE_CLOSE);

	for i=2, MAX_SPELL_SCHOOLS do
		if (self.bonusDamage and self.bonusDamage[i] ~= self.minModifier) then
			GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G["DAMAGE_SCHOOL"..i]).." "..self.bonusDamage[i]..FONT_COLOR_CODE_CLOSE);
			GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..i);
		end
	end

	GameTooltip:AddLine(self.tooltip2);

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

		local petBonusAP = ComputePetBonus("PET_BONUS_SPELLDMG_TO_AP", damage );
		local petBonusDmg = ComputePetBonus("PET_BONUS_SPELLDMG_TO_SPELLDMG", damage );
		if( petBonusAP > 0 or petBonusDmg > 0 ) then
			GameTooltip:AddLine(format(petStr, petBonusAP, petBonusDmg), nil, nil, nil, true );
		end
	end
	GameTooltip:Show();
end

local CHARACTER_SHEET_MODEL_SCENE_ID = 595;
function PaperDollFrame_SetPlayer()
	CharacterModelScene:ReleaseAllActors();
	CharacterModelScene:TransitionToModelSceneID(CHARACTER_SHEET_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);

	local form = GetShapeshiftFormID();
	local creatureDisplayID = C_PlayerInfo.GetDisplayID();
	local nativeDisplayID = C_PlayerInfo.GetNativeDisplayID();
	if form and creatureDisplayID ~= 0 and not UnitOnTaxi("player") then
		local actorTag = ANIMAL_FORMS[form] and ANIMAL_FORMS[form].actorTag or nil;
		if actorTag then
			local actor = CharacterModelScene:GetPlayerActor(actorTag);
			if actor then
				-- We need to SetModelByCreatureDisplayID() for Shapeshift forms if:
				-- 1. We have a form active (already checked above)
				-- 2. The display granted by that form is *not* our native Player display (e.g. anything *but* Glyph of Stars)
				-- 3. The Player is *not* mirror imaged
				-- 4. The Player *is* currently their native race (e.g. *not* using a transform Toy of some kind)
				local displayIDIsNative = (creatureDisplayID == nativeDisplayID);
				local displayRaceIsNative = C_PlayerInfo.IsDisplayRaceNative();
				local isMirrorImage = C_PlayerInfo.IsMirrorImage();
				local useShapeshiftDisplayID = (not displayIDIsNative and not isMirrorImage and displayRaceIsNative);
				if useShapeshiftDisplayID then
					actor:SetModelByCreatureDisplayID(creatureDisplayID, true);
					actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
					return;
				end
			end
		end
	end

	local actor = CharacterModelScene:GetPlayerActor();
	if actor then
		local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
		local sheatheWeapon = GetSheathState() == 1;
		local autodress = true;
		local hideWeapon = false;
		local useNativeForm = not inAlternateForm;
		actor:SetModelByUnit("player", sheatheWeapon, autodress, hideWeapon, useNativeForm);
		actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
	end
end

function PaperDollFrame_OnShow(self)
	CharacterStatsPane.initialOffsetY = 0;
	CharacterFrame:SetTitle(UnitPVPName("player"));
	PaperDollFrame_SetLevel();
	PaperDollFrame_UpdateStats();
	CharacterFrame_Expand();

	SetPaperDollBackground(CharacterModelScene, "player");
	PaperDollBgDesaturate(true);
	PaperDollSidebarTabs:Show();

	CharacterModelScene.ControlFrame:Show();
	CharacterModelScene.ControlFrame:SetModelScene(CharacterModelScene);

	PaperDollFrame_SetPlayer();
	self:RegisterEvent("UNIT_MODEL_CHANGED");
end

function PaperDollFrame_OnHide(self)
	CharacterStatsPane.initialOffsetY = 0;
	CharacterFrame_Collapse();
	PaperDollSidebarTabs:Hide();
	PaperDollFrame_HideInventoryFixupComplete(self);
	self:UnregisterEvent("UNIT_MODEL_CHANGED");
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

function PaperDollItemSlotButton_OnLoad(self)
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	
	local slotName = PaperDollItemSlotButton_GetSlotName(self);
	local id, textureName, checkRelic = GetInventorySlotInfo(slotName);
	self:SetID(id);

	local texture = self.icon;
	texture:SetTexture(textureName);
	self.backgroundTextureName = textureName;
	self.checkRelic = checkRelic;
	self.UpdateTooltip = PaperDollItemSlotButton_OnEnter;
	itemSlotButtons[id] = self;
	self.verticalFlyout = VERTICAL_FLYOUTS[id];

	local popoutButton = self.popoutButton;
	if ( popoutButton ) then
		if ( self.verticalFlyout ) then
			popoutButton:SetHeight(16);
			popoutButton:SetWidth(38);

			popoutButton:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0.5, 0);
			popoutButton:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 1, 0.5);
			popoutButton:ClearAllPoints();
			popoutButton:SetPoint("TOP", self, "BOTTOM", 0, 4);
		else
			popoutButton:SetHeight(38);
			popoutButton:SetWidth(16);

			popoutButton:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0);
			popoutButton:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5);
			popoutButton:ClearAllPoints();
			popoutButton:SetPoint("LEFT", self, "RIGHT", -8, 0);
		end
	end
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
};

function PaperDollItemSlotButton_OnShow(self, isBag)
	FrameUtil.RegisterFrameForEvents(self, PAPERDOLL_FRAME_EVENTS);

	if ( not isBag ) then
		self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	end
	PaperDollItemSlotButton_Update(self);
end

function PaperDollItemSlotButton_OnHide(self)
	FrameUtil.UnregisterFrameForEvents(self, PAPERDOLL_FRAME_EVENTS);

	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
end

function PaperDollItemSlotButton_OnEvent(self, event, ...)
	if ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		local equipmentSlot, hasCurrent = ...;
		if ( self:GetID() == equipmentSlot ) then
			PaperDollItemSlotButton_Update(self);
		end
	elseif ( event == "ITEM_LOCK_CHANGED" ) then
		local bagOrSlotIndex, slotIndex = ...;
		if ( not slotIndex and bagOrSlotIndex == self:GetID() ) then
			PaperDollItemSlotButton_UpdateLock(self);
		end
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		PaperDollItemSlotButton_Update(self);
	elseif ( event == "CURSOR_CHANGED" ) then
		if C_PaperDollInfo.CanCursorCanGoInSlot(self:GetID()) then
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
					if ( C_PaperDollInfo.CanCursorCanGoInSlot(slotID) ) then
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
		local textureName = self.backgroundTextureName;
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

function PaperDollItemSlotButton_OnEnter(self)
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	EquipmentFlyout_UpdateFlyout(self);
	if ( not EquipmentFlyout_SetTooltipAnchor(self) ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end

	local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", self:GetID());
	if ( not hasItem ) then
		-- This SetOwner is needed because calling SetInventoryItem now hides tooltip if there is no item
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local asRelic = self.checkRelic and UnitHasRelicSlot("player");
		if asRelic then
			GameTooltip:SetText(_G[RELICSLOT]);
		else
			local slotName = PaperDollItemSlotButton_GetSlotName(self);
			GameTooltip:SetText(_G[strupper(slotName)]);
			GameTooltip:Show();
		end
	end
	CursorUpdate(self);
end

function PaperDollItemSlotButton_OnLeave(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	GameTooltip:Hide();
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
		GameTooltip:SetText(INVTYPE_WEAPONMAINHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	GameTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", self.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), self.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
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
	spec = GetSpecialization();
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
				local primaryStat = select(6, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")));
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

function GearSetEditButton_OnLoad(self)
	self.Dropdown = GearSetEditButtonDropDown;
	UIDropDownMenu_Initialize(self.Dropdown, nil, "MENU");
	UIDropDownMenu_SetInitializeFunction(self.Dropdown, GearSetEditButtonDropDown_Initialize);
end

function GearSetEditButton_OnMouseDown(self, button)
	self.texture:SetPoint("TOPLEFT", 1, -1);

	GearSetButton_OnClick(self:GetParent(), button);

	if ( self.Dropdown.gearSetButton ~= self:GetParent() ) then
		HideDropDownMenu(1);
		self.Dropdown.gearSetButton = self:GetParent();
	end

	ToggleDropDownMenu(1, nil, self.Dropdown, self, 0, 0);
end

function GearSetEditButtonDropDown_Initialize(dropdownFrame, level, menuList)
	local gearSetButton = dropdownFrame.gearSetButton;
	local info = UIDropDownMenu_CreateInfo();
	info.text = EQUIPMENT_SET_EDIT;
	info.notCheckable = true;
	info.func = function() GearSetButton_OpenPopup(gearSetButton); end;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.text = EQUIPMENT_SET_ASSIGN_TO_SPEC;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	local equipmentSetID = gearSetButton.setID;
	for i = 1, GetNumSpecializations() do
		info = UIDropDownMenu_CreateInfo();
		info.checked = function()
			return C_EquipmentSet.GetEquipmentSetAssignedSpec(equipmentSetID) == i;
		end;

		info.func = function()
			local currentSpecIndex = C_EquipmentSet.GetEquipmentSetAssignedSpec(equipmentSetID);
			if ( currentSpecIndex ~= i ) then
				C_EquipmentSet.AssignSpecToEquipmentSet(equipmentSetID, i);
			else
				C_EquipmentSet.UnassignEquipmentSetSpec(equipmentSetID);
			end

			GearSetButton_UpdateSpecInfo(gearSetButton);
			PaperDollEquipmentManagerPane_Update(true);
		end;

		local specID = GetSpecializationInfo(i);
		info.text = select(2, GetSpecializationInfoByID(specID));
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
end

function GearSetButton_SetSpecInfo(self, specID)
	if ( specID and specID > 0 ) then
		self.specID = specID;
		local id, name, description, texture, role, class = GetSpecializationInfoByID(specID);
		SetPortraitToTexture(self.SpecIcon, texture);
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

	local specID = GetSpecializationInfo(specIndex);
	GearSetButton_SetSpecInfo(self, specID);
end

function GearSetButton_OnClick(self, button, down)
	if ( self.setID ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);		-- inappropriately named, but a good sound.
		PaperDollFrame.EquipmentManagerPane.selectedSetID = self.setID;
		-- mark the ignored slots
		PaperDollFrame_ClearIgnoredSlots();
		PaperDollFrame_IgnoreSlotsForSet(self.setID);
		PaperDollEquipmentManagerPane_Update();
		GearManagerPopupFrame:Hide();
	else
		-- This is the "New Set" button
		GearManagerPopupFrame.mode = IconSelectorPopupFrameModes.New;
		GearManagerPopupFrame:Show();
		PaperDollFrame.EquipmentManagerPane.selectedSetID = nil;
		PaperDollFrame_ClearIgnoredSlots();
		PaperDollEquipmentManagerPane_Update();
		-- Ignore shirt and tabard by default
		PaperDollFrame_IgnoreSlot(4);
		PaperDollFrame_IgnoreSlot(19);
	end
	StaticPopup_Hide("CONFIRM_SAVE_EQUIPMENT_SET");
	StaticPopup_Hide("CONFIRM_OVERWRITE_EQUIPMENT_SET");
end

function GearSetButton_OnEnter(self)
	if ( self.setID ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		GameTooltip:SetEquipmentSet(self.setID);
	end
end

function GearSetButton_OpenPopup(self)
	GearManagerPopupFrame.mode = IconSelectorPopupFrameModes.Edit;
	GearManagerPopupFrame.setID = self.setID;
	GearManagerPopupFrame.origName = self.text:GetText();
	GearManagerPopupFrame:Show();
end

GearManagerPopupFrameMixin = {};

function GearManagerPopupFrameMixin:OnShow()
	IconSelectorPopupFrameTemplateMixin.OnShow(self);
	self.BorderBox.IconSelectorEditBox:SetFocus();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	self.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Equipment);
	self.BorderBox.IconTypeDropDown:SetSelectedValue(IconSelectorPopupFrameIconFilterTypes.All);
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
		local name, texture = C_EquipmentSet.GetEquipmentSetInfo(PaperDollFrame.EquipmentManagerPane.selectedSetID);
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
			local dialog = StaticPopup_Show("CONFIRM_OVERWRITE_EQUIPMENT_SET", text);
			if ( dialog ) then
				dialog.data = setID;
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

function PaperDollEquipmentManagerPane_OnLoad(self)
	self:RegisterEvent("EQUIPMENT_SWAP_FINISHED");
	self:RegisterEvent("EQUIPMENT_SETS_CHANGED");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("BAG_UPDATE");

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("GearSetButtonTemplate", function(button, elementData)
		PaperDollEquipmentManagerPane_InitButton(button, elementData);
	end);
	view:SetPadding(0,0,3,0,2);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function PaperDollEquipmentManagerPane_OnUpdate(self)
	self.ScrollBox:ForEachFrame(function(button)
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
	end);

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
	if elementData.addSetButton then
		button.setID = nil;
		button.text:SetText(PAPERDOLL_NEWEQUIPMENTSET);
		button.text:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		button.icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus");
		button.icon:SetSize(30, 30);
		button.icon:SetPoint("LEFT", 7, 0);
		button.Check:Hide();
		button.SelectedBar:Hide();
	else
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

		if (index == 1) then
			button.BgTop:Show();
			button.BgMiddle:SetPoint("TOP", button.BgTop, "BOTTOM");
		else
			button.BgTop:Hide();
			button.BgMiddle:SetPoint("TOP");
		end

		if (equipmentSetIndex == numRows) then
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

	if (numSets < MAX_EQUIPMENT_SETS_PER_PLAYER) then
		dataProvider:Insert({addSetButton=true}); -- "Add New Set" button
	end

	PaperDollFrame.EquipmentManagerPane.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function PaperDollEquipmentManagerPaneSaveSet_OnClick(self)
	local selectedSetID = PaperDollFrame.EquipmentManagerPane.selectedSetID
	if (selectedSetID) then
		local selectedSetName = C_EquipmentSet.GetEquipmentSetInfo(selectedSetID);
		local dialog = StaticPopup_Show("CONFIRM_SAVE_EQUIPMENT_SET", selectedSetName);
		if ( dialog ) then
			dialog.data = selectedSetID;
		else
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
	local race, fileName = UnitRace(unit);
	local texture = DressUpTexturePath(fileName);
	model.BackgroundTopLeft:SetTexture(texture..1);
	model.BackgroundTopRight:SetTexture(texture..2);
	model.BackgroundBotLeft:SetTexture(texture..3);
	model.BackgroundBotRight:SetTexture(texture..4);

	-- HACK - Adjust background brightness for different races
	if ( strupper(fileName) == "BLOODELF") then
		model.BackgroundOverlay:SetAlpha(0.8);
	elseif (strupper(fileName) == "NIGHTELF") then
		model.BackgroundOverlay:SetAlpha(0.6);
	elseif ( strupper(fileName) == "SCOURGE") then
		model.BackgroundOverlay:SetAlpha(0.3);
	elseif ( strupper(fileName) == "TROLL" or strupper(fileName) == "ORC") then
		model.BackgroundOverlay:SetAlpha(0.6);
	elseif ( strupper(fileName) == "WORGEN" ) then
		model.BackgroundOverlay:SetAlpha(0.5);
	elseif ( strupper(fileName) == "GOBLIN" ) then
		model.BackgroundOverlay:SetAlpha(0.6);
	else
		model.BackgroundOverlay:SetAlpha(0.7);
	end
end

function PaperDollBgDesaturate(on)
	CharacterModelFrameBackgroundTopLeft:SetDesaturated(on);
	CharacterModelFrameBackgroundTopRight:SetDesaturated(on);
	CharacterModelFrameBackgroundBotLeft:SetDesaturated(on);
	CharacterModelFrameBackgroundBotRight:SetDesaturated(on);
end

function PaperDollFrame_UpdateSidebarTabs()
	for i = 1, #PAPERDOLL_SIDEBARS do
		local tab = _G["PaperDollSidebarTab"..i];
		if (tab) then
			local frame = GetPaperDollSideBarFrame(i);
			if (frame:IsShown()) then
				tab.Hider:Hide();
				tab.Highlight:Hide();
				tab.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.78906250, 0.95703125);
			else
				tab.Hider:Show();
				tab.Highlight:Show();
				tab.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.61328125, 0.78125000);
				if ( PAPERDOLL_SIDEBARS[i].IsActive() ) then
					tab:Enable();
				else
					tab:Disable();
				end
			end
		end
	end
end

function PaperDollFrame_SetSidebar(self, index)
	local frame = GetPaperDollSideBarFrame(index);
	if (not frame:IsShown()) then
		for i = 1, #PAPERDOLL_SIDEBARS do
			local frame = GetPaperDollSideBarFrame(i);
			frame:Hide();
		end
		frame:Show();
		PaperDollFrame.currentSideBar = frame;
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		PaperDollFrame_UpdateSidebarTabs();
	end
end

function PaperDollFrame_SidebarTab_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, PAPERDOLL_SIDEBARS[self:GetID()].name);
	if not self:IsEnabled() and self.disabledTooltip then
		local disabledTooltipText = GetValueOrCallFunction(self, "disabledTooltip");
		GameTooltip_AddErrorLine(GameTooltip, disabledTooltipText, true);
	end
	GameTooltip:Show();
end

local inventoryFixupVersionToTutorialIndex =
{
	{
		seenIndex = LE_FRAME_TUTORIAL_INVENTORY_FIXUP_EXPANSION_LEGION,
		checkIndex = LE_FRAME_TUTORIAL_INVENTORY_FIXUP_CHECK_EXPANSION_LEGION,
	},
};

local function CheckFixupStates(fixupVersion)
	local tutorialIndices = fixupVersion and inventoryFixupVersionToTutorialIndex[fixupVersion];

	-- Set the appropriate index to check, this is how the client knows the user's
	-- inventory was fixed up at some point in the past, but hasn't seen the tutorial yet.
	if tutorialIndices and tutorialIndices.checkIndex then
		SetCVarBitfield("closedInfoFrames", tutorialIndices.checkIndex, true);
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

PaperDollItemSlotButtonMixin = {}

function PaperDollItemSlotButtonMixin:GetItemContextMatchResult()
	return ItemButtonUtil.GetItemContextMatchResultForItem(ItemLocation:CreateFromEquipmentSlot(self:GetID()));
end
