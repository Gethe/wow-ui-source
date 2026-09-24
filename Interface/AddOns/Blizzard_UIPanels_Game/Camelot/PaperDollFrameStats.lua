
local BLOCK_VALUE_PER_STRENGTH = 20;
local ARMOR_PER_AGILITY = 2;
local BASE_ENEMY_MISS_CHANCE = 5.0;
local BASE_ENEMY_CRIT_CHANCE = 5.0;
local CRUSHING_BLOW_MIN_SKILL_DIFF = 15;
local SKILL_RANKS_PER_SKILL_LEVEL = 5;
ATTACK_POWER_MAGIC_NUMBER = 14;

PRIMARY_ATTRIBUTE_CATEGORY = 2;

BASE_ENEMY_DODGE_CHANCE = {
	[0] = 5.0;
	[1] = 5.5;
	[2] = 6.0;
	[3] = 6.5;
};

local WEAPON_SUBCLASS_TO_SKILL_ID = {
	[Enum.ItemWeaponSubclass.Sword1H]	= 43,	-- Swords
	[Enum.ItemWeaponSubclass.Axe1H]		= 44,	-- Axes
	[Enum.ItemWeaponSubclass.Bows]		= 45,	-- Bows
	[Enum.ItemWeaponSubclass.Guns]		= 46,	-- Guns
	[Enum.ItemWeaponSubclass.Mace1H]	= 54,	-- Maces
	[Enum.ItemWeaponSubclass.Sword2H]	= 55,	-- Two-Handed Swords
	[Enum.ItemWeaponSubclass.Staff]		= 136,	-- Staves
	[Enum.ItemWeaponSubclass.Mace2H]	= 160,	-- Two-Handed Maces
	[Enum.ItemWeaponSubclass.Axe2H]		= 172,	-- Two-Handed Axes
	[Enum.ItemWeaponSubclass.Dagger]	= 173,	-- Daggers
	[Enum.ItemWeaponSubclass.Thrown]	= 176,	-- Thrown
	[Enum.ItemWeaponSubclass.Crossbow]	= 226,	-- Crossbows
	[Enum.ItemWeaponSubclass.Wand]		= 228,	-- Wands
	[Enum.ItemWeaponSubclass.Polearm]	= 229,	-- Polearms
	[Enum.ItemWeaponSubclass.Unarmed]	= 162,	-- Fist Weapons
};

local FERAL_WEAPON_SKILL = 3014;

local DAMAGE_TOOLTIP_LABEL_TO_SLOT = {
	[INVTYPE_WEAPONMAINHAND]	= INVSLOT_MAINHAND,
	[INVTYPE_WEAPONOFFHAND]		= INVSLOT_OFFHAND,
	[INVTYPE_RANGED]			= INVSLOT_RANGED,
};

local function ClampPercentage(value)
	return math.max(0.0, math.min(100.0, value));
end

local function GetEffectiveDefenseSkill(unit)
	local baseDefenseSkill, defenseModifier = UnitDefenseSkill(unit);
	return math.max(0, baseDefenseSkill + defenseModifier), baseDefenseSkill, defenseModifier;
end

local function GetEnemySkillDifference(levelOffset, defenseSkill)
	local playerLevel = UnitLevel("player");
	local enemyWeaponSkill = (playerLevel + levelOffset) * SKILL_RANKS_PER_SKILL_LEVEL;
	return enemyWeaponSkill - defenseSkill;
end

local function GetEnemyChanceToMiss(levelOffset, defenseSkill)
	local skillDiff = GetEnemySkillDifference(levelOffset, defenseSkill);
	local chanceToBeMissed = BASE_ENEMY_MISS_CHANCE - (skillDiff * 0.04);
	return ClampPercentage(chanceToBeMissed);
end

local function GetEnemyCritChance(levelOffset, defenseSkill)
	local skillDiff = GetEnemySkillDifference(levelOffset, defenseSkill);
	return ClampPercentage(BASE_ENEMY_CRIT_CHANCE + (skillDiff * 0.04));
end

local function GetEnemyCrushingBlowChance(levelOffset, defenseSkill)
	local playerLevel = UnitLevel("player");
	local skillDiff = GetEnemySkillDifference(levelOffset, math.min(defenseSkill, playerLevel * SKILL_RANKS_PER_SKILL_LEVEL));
	if skillDiff < CRUSHING_BLOW_MIN_SKILL_DIFF then
		return 0.0;
	end

	return ClampPercentage((skillDiff * 2.0) - 15.0);
end

local function AddDefenseChanceTable(label, chanceFunc, defenseSkill, startLevelDiff, endLevelDiff)
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(STAT_ATTACKER_LEVEL, label, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	local playerLevel = UnitLevel("player");
	for levelDiff = startLevelDiff, endLevelDiff do
		local enemyLevel = playerLevel + levelDiff;
		if (levelDiff == 3) then
			enemyLevel = enemyLevel.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
		end

		GameTooltip:AddDoubleLine("      "..enemyLevel, format("%.1F%%", chanceFunc(levelDiff, defenseSkill)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end

local function CharacterArmorFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.tooltip);
	if (self.tooltip2) then
		GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	if (self.tooltip3) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(self.tooltip3, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	if (self.tooltip4) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(self.tooltip4, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	
	GameTooltip:Show();
end

function CharacterDefenseFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.tooltip);
	if (self.tooltip2) then
		GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	if (self.tooltip3) then
		GameTooltip:AddLine(self.tooltip3, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end

	GameTooltip:Show();
end

function PaperDollFrame_SetDodgeTooltip(statFrame, dodgeChance)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.1F", dodgeChance).."%"..FONT_COLOR_CODE_CLOSE;
end

function PaperDollFrame_SetDodgeTooltip2(statFrame, dodgeChance)
	statFrame.tooltip2 = format(CR_DODGE_BASE_STAT_TOOLTIP, dodgeChance);
end

function PaperDollFrame_SetParryTooltip(statFrame, parryChance)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.1F", parryChance).."%"..FONT_COLOR_CODE_CLOSE;
end

function PaperDollFrame_SetParryTooltip2(statFrame, parryChance)
	statFrame.tooltip2 = format(CR_PARRY_BASE_STAT_TOOLTIP, parryChance);
end

function PaperDollFrame_ShowFlightSpeed()
	return false;
end

function PaperDollFrame_SetArmorPenetration(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local armorPenetration = GetArmorPenetration();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_ARMOR_PENETRATION, format("%d", armorPenetration), false, armorPenetration);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_ARMOR_PENETRATION).." "..format("%d", armorPenetration)..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(ARMOR_PENETRATION_TOOLTIP, armorPenetration);
	statFrame:Show();

	return armorPenetration;
end

function PaperDollFrame_SetHaste(statFrame, unit)
	local meleeHaste = 0;
	local rangedHaste = 0;
	local spellHaste = UnitSpellHaste(unit);

	if unit == "player" then
		meleeHaste = GetMeleeHaste();
		local baseRangedHaste, ammoHaste = GetRangedHaste();
		rangedHaste = baseRangedHaste + ammoHaste;
	elseif unit == "pet" then
		meleeHaste = GetPetMeleeHaste();
		rangedHaste = 0;
	end

	local maxHaste = max(meleeHaste, rangedHaste, spellHaste);

	local maxHasteText = format("%.1f%%", maxHaste);

	PaperDollFrame_SetLabelAndText(statFrame, STAT_HASTE, maxHasteText, false, maxHasteText);

	statFrame.unit = unit;
	statFrame.onEnterFunc = function (self) CharacterHasteFrame_OnEnter(self, meleeHaste, rangedHaste, spellHaste) end;

	return maxHaste;
end

function CharacterHasteFrame_OnEnter(self, meleeHaste, rangedHaste, spellHaste)
	local maxHaste = max(meleeHaste, rangedHaste, spellHaste);
	local _, classFileName = UnitClass(self.unit);
	local isRangedClass = classFileName == "WARRIOR" or classFileName == "HUNTER" or classFileName == "ROGUE";
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE).." "..format("%.1F%%", maxHaste)..FONT_COLOR_CODE_CLOSE);

	if meleeHaste > 0 then
		GameTooltip:AddLine(format(CR_HASTE_MELEE_TOOLTIP, meleeHaste), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
	end
	if rangedHaste > 0 and isRangedClass then
		GameTooltip:AddLine(format(CR_HASTE_RANGED_TOOLTIP, rangedHaste), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
	end
	if spellHaste > 0 then
		GameTooltip:AddLine(format(CR_HASTE_SPELL_TOOLTIP, spellHaste), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
	end

	GameTooltip:Show();

end

function ExpectedSpellResistance(casterLevel, resistance)
	return 0.75 * resistance / (casterLevel * 5);
end


function PaperDollFrame_SetResistanceTooltips(statFrame, nameToken, effectiveResistance, unit, damageClass)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. nameToken.." "..effectiveResistance .. FONT_COLOR_CODE_CLOSE;

	local unitLevel = UnitLevel(unit);

	local expectedResist = ExpectedSpellResistance(unitLevel, effectiveResistance);

	statFrame.tooltip2 = format(RESISTANCE_TOOLTIP_SUBTEXT, _G["RESISTANCE_TYPE"..damageClass], unitLevel, math.floor(expectedResist * 100));
end

local function PaperDollStatFrame_OnEnter(self)
	if ( not self.tooltip ) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.tooltip);

	if ( self.tooltip2 ) then
		GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, self.lineWrap);
	end

	GameTooltip:Show();
end

function PaperDollFrame_SetStatTooltip2(statFrame, statName, statIndex, effectiveStat, unit)
	-- Get class specific tooltip for that stat
	local _, classFileName = UnitClass("player");
	local primaryStat = PAPERDOLL_STATCATEGORIES[PRIMARY_ATTRIBUTE_CATEGORY].stats[statIndex].stat;
	local classStatText = _G[strupper(classFileName).."_"..strupper(primaryStat).."_".."TOOLTIP"];
	-- If can't find one use the default
	if ( not classStatText ) then
		classStatText = _G["DEFAULT".."_"..strupper(primaryStat).."_".."TOOLTIP"];
	end

	statFrame.lineWrap = false;

	if statIndex == LE_UNIT_STAT_INTELLECT then
		local spellCrit = GetSpellCritChanceFromStat(statIndex, effectiveStat) * 100.0;

		if classFileName == "WARRIOR" or classFileName == "ROGUE" then
			classStatText = string.format(classStatText, spellCrit);
		else
			local manaBonus = math.min(INTELLECT_BREAK, effectiveStat);
			manaBonus = manaBonus + (math.max(INTELLECT_BREAK, effectiveStat) - INTELLECT_BREAK) * MANA_PER_INTELLECT;

			classStatText = string.format(classStatText, tostring(manaBonus), spellCrit);
		end
	elseif statIndex == LE_UNIT_STAT_STAMINA then
		local bonus = math.min(STAMINA_BREAK, effectiveStat);
		local perStaminaBonus = (math.max(STAMINA_BREAK, effectiveStat) - STAMINA_BREAK) * UnitHPPerStamina("player");
		bonus = bonus + perStaminaBonus;
		classStatText = string.format(classStatText, tostring(bonus));
	elseif statIndex == LE_UNIT_STAT_SPIRIT then

		statFrame.lineWrap = true;

		local spiritStandingPenalty = 0.75;

		local healthRegenFromSpirit = GetHealthRegenFromSpirit() * spiritStandingPenalty; -- Assume player is standing
		local manaRegenFromSpirit = GetManaRegenFromSpirit();

		local healthRegen = GetHealthRegen();
		local manaRegen = GetManaRegen();

		if classFileName == "WARRIOR" or classFileName == "ROGUE" then
			classStatText = string.format(classStatText, healthRegenFromSpirit * 5, healthRegen * 5);
		else
			classStatText = string.format(classStatText, healthRegenFromSpirit * 5, manaRegenFromSpirit * 5, healthRegen * 5, manaRegen * 5);
		end

		classStatText = string.format("%s\n\n%s", classStatText, SPIRIT_STANDING_WARNING);

	elseif statIndex == LE_UNIT_STAT_STRENGTH then
		classStatText = string.format(classStatText, GetAttackPowerForStat(statIndex, effectiveStat), math.floor(effectiveStat / BLOCK_VALUE_PER_STRENGTH));
	elseif statIndex == LE_UNIT_STAT_AGILITY then
		
		local increasedDodgeChance = GetDodgeChanceFromAttribute() * 100.0;
		local increasedArmor = effectiveStat * ARMOR_PER_AGILITY;
		local increasedMeleeCritChance = GetCritChanceFromStat(statIndex, effectiveStat) * 100.0;
		local increasedRangedCritChance = increasedMeleeCritChance;
		local increasedAttackPower = GetAttackPowerForStat(statIndex, effectiveStat);
		local increasedRangedAttackPower = GetRangedAttackPowerForStat(statIndex, effectiveStat);

		if classFileName == "ROGUE" then
			classStatText = string.format(classStatText, increasedMeleeCritChance, increasedAttackPower, increasedRangedAttackPower, increasedArmor, increasedDodgeChance);
		elseif classFileName == "HUNTER" then
			classStatText = string.format(classStatText, increasedRangedCritChance, increasedAttackPower, increasedRangedAttackPower, increasedArmor, increasedDodgeChance);
		elseif classFileName == "DRUID" then
			local catFormAgility = effectiveStat;
			classStatText = string.format(classStatText, increasedMeleeCritChance, catFormAgility, increasedArmor, increasedDodgeChance);
		elseif classFileName == "WARRIOR" then
			classStatText = string.format(classStatText, increasedRangedCritChance, increasedRangedAttackPower, increasedArmor, increasedDodgeChance);
		else
			classStatText = string.format(classStatText, increasedMeleeCritChance, increasedArmor, increasedDodgeChance);
		end
	end

	statFrame.tooltip2 = classStatText;
	statFrame.onEnterFunc = PaperDollStatFrame_OnEnter;
end

function PaperDollFrame_SetDefense(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end

	local maxDefense = UnitLevel(unit) * SKILL_RANKS_PER_SKILL_LEVEL;

	local STAT_PER_DEFENSE = 0.04;

	local effectiveDefenseSkill, baseDefenseSkill, defenseModifier = GetEffectiveDefenseSkill(unit);
	local posBuff = 0;
	local negBuff = 0;
	if ( defenseModifier > 0 ) then
		posBuff = defenseModifier;
	elseif ( defenseModifier < 0 ) then
		negBuff = defenseModifier;
	end

	local effectiveDefense = math.max(effectiveDefenseSkill - maxDefense, 0);

	local valueText, tooltipText = PaperDollFormatStat(DEFENSE, baseDefenseSkill, posBuff, negBuff);
	PaperDollFrame_SetLabelAndText(statFrame, DEFENSE, valueText .. " / " .. maxDefense, false, effectiveDefenseSkill);
	statFrame.tooltip = tooltipText;
	statFrame.tooltip2 = format(DEFAULT_STATDEFENSE_TOOLTIP, effectiveDefense * STAT_PER_DEFENSE, effectiveDefense * STAT_PER_DEFENSE);
	statFrame.tooltip3 = nil;
	statFrame.effectiveDefenseSkill = effectiveDefenseSkill;
	statFrame.onEnterFunc = CharacterDefenseFrame_OnEnter;

	return effectiveDefenseSkill;
end

function PaperDollFrame_SetAttackPower(statFrame, unit, rangedWeapon)
	local base, posBuff, negBuff;

	local isPet = unit == "pet";

	local _, classFileName = UnitClass("player");

	local extraFormatNumber;
	local tag, tooltip;
	if isPet then
		base, posBuff, negBuff = UnitAttackPower(unit);
		tag, tooltip = MELEE_ATTACK_POWER, _G["MELEE_ATTACK_POWER_PET_" .. classFileName ..  "_TOOLTIP"] or "";
		extraFormatNumber = ComputePetBonus("PET_BONUS_AP_CONVERSION", 100.0); 
	elseif ( rangedWeapon ) then
		base, posBuff, negBuff = UnitRangedAttackPower(unit);
		tag, tooltip = RANGED_ATTACK_POWER, RANGED_ATTACK_POWER_TOOLTIP;
	else
		base, posBuff, negBuff = UnitAttackPower(unit);
		tag, tooltip = MELEE_ATTACK_POWER, _G[classFileName.."_MELEE_ATTACK_POWER_TOOLTIP"] or MELEE_ATTACK_POWER_TOOLTIP;
	end

	local damageBonus =  BreakUpLargeNumbers(max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER);
	local spellPower = 0;
	local value, valueText, tooltipText;
	if (GetOverrideAPBySpellPower() > 0) then
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

	local label = rangedWeapon and RANGED_ATTACK_POWER or STAT_ATTACK_POWER;

	PaperDollFrame_SetLabelAndText(statFrame, label, valueText, false, value);
	statFrame.tooltip = tooltipText;

	local effectiveAP = max(0,base + posBuff + negBuff);
	if (GetOverrideSpellPowerByAP() > 0 and unit == "player") then
		statFrame.tooltip2 = format(MELEE_ATTACK_POWER_SPELL_POWER_TOOLTIP, damageBonus, BreakUpLargeNumbers(effectiveAP * GetOverrideSpellPowerByAP() + 0.5));
	else
		statFrame.tooltip2 = format(tooltip, damageBonus, extraFormatNumber);
	end

	statFrame:Show();

	return value;
end

function PaperDollFrame_SetRangedAttackPower(statFrame, unit)
	return PaperDollFrame_SetAttackPower(statFrame, unit, true);
end

function PaperDollFrame_SetBlock(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide();
		return;
	end

	local chance = GetBlockChance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_BLOCK, chance, true, chance);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BLOCK_CHANCE).." "..string.format("%.1F", chance).."%"..FONT_COLOR_CODE_CLOSE;

	local shieldBlockValue = GetShieldBlock();

	statFrame.tooltip2 = STAT_BLOCK_VALUE_FLAT_TOOLTIP:format(chance, shieldBlockValue);
	statFrame.tooltip3 = nil;

	statFrame:Show();

	return chance;
end

function CharacterHitFrame_OnEnter(self, meleeHit, rangedHit, spellHit, hitLabel)
	local maxHit = max(meleeHit, rangedHit, spellHit);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, hitLabel).." "..format("%.1F%%", maxHit)..FONT_COLOR_CODE_CLOSE);

	local meleeMissChances = { 5.0, 5.2, 5.4, 9.0 };
	local spellMissChances = { 4.0, 5.0, 6.0, 17.0 };
	local playerLevel = UnitLevel("player");
	local _, classFileName = UnitClass("player");
	local usesRangedHit = classFileName == "WARRIOR" or classFileName == "HUNTER" or classFileName == "ROGUE";

	if meleeHit > 0 then
		GameTooltip:AddLine(format(CR_HIT_MELEE_TOOLTIP, meleeHit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
	end
	if rangedHit > 0 and usesRangedHit then
		GameTooltip:AddLine(format(CR_HIT_RANGED_TOOLTIP, rangedHit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
	end
	if spellHit > 0 then
		GameTooltip:AddLine(format(CR_HIT_SPELL_TOOLTIP, spellHit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
	end

	local hitCapTooltip = _G["CR_" .. classFileName .. "_HIT_CAP_TOOLTIP"] or CR_DEFAULT_HIT_CAP_TOOLTIP;

	GameTooltip:AddLine(format(hitCapTooltip, playerLevel), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);

	GameTooltip:Show();
end

function PaperDollFrame_SetArmor(statFrame, unit)
	local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor(unit);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_ARMOR, BreakUpLargeNumbers(effectiveArmor), false, effectiveArmor);
	local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit));
	local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ARMOR).." "..BreakUpLargeNumbers(effectiveArmor)..FONT_COLOR_CODE_CLOSE;

	if unit == "pet" then
		local multiplier = ComputePetBonus("PET_BONUS_ARMOR", 100.0);

		statFrame.tooltip2 = format(STAT_ARMOR_PET_TOOLTIP, armorReduction, multiplier);
	else
		statFrame.tooltip2 = format(STAT_ARMOR_TOOLTIP, armorReduction);
	end

	if (armorReductionAgainstTarget) then
		statFrame.tooltip3 = format(STAT_ARMOR_TARGET_TOOLTIP, armorReductionAgainstTarget);
	else
		statFrame.tooltip3 = nil;
	end
	statFrame.tooltip4 = format(ARMOR_MAX_EFFECTIVENESS_TOOLTIP);
	statFrame.effectiveArmor = effectiveArmor;
	statFrame.unit = unit;
	statFrame.onEnterFunc = CharacterArmorFrame_OnEnter;
	statFrame:Show();

	return effectiveArmor;
end

function PaperDollFrame_SetHitChance(statFrame, unit)

	local meleeHit, rangedHit, spellHit;

	if unit == "player" then
		meleeHit = GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier();
		rangedHit = GetCombatRatingBonus(CR_HIT_RANGED) + GetRangedHitModifier();
		spellHit = GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier();
	elseif unit == "pet" then
		meleeHit = GetPetHitChanceModifier();
		rangedHit = meleeHit;
		spellHit = GetPetSpellHitChanceModifier();
	else
		meleeHit = 0;
		rangedHit = 0;
		spellHit = 0;
	end

	local maxHit = max(meleeHit, rangedHit, spellHit);

	PaperDollFrame_SetLabelAndText(statFrame, STAT_HIT_CHANCE, string.format("%.1F%%", maxHit), false, maxHit);
	statFrame.onEnterFunc = function(self) CharacterHitFrame_OnEnter(self, meleeHit, rangedHit, spellHit, STAT_HIT_CHANCE) end;

	return maxHit;
end

function CharacterCritChanceFrame_OnEnter(self, meleeCrit, rangedCrit, spellCrit)
	local maxCrit = max(meleeCrit, rangedCrit, spellCrit);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE).." "..format("%.1F%%", maxCrit)..FONT_COLOR_CODE_CLOSE);
	
	local _, classFileName = UnitClass("player");

	local playersClass = classFileName;

	if self.unit == "pet" then
		classFileName = "PET";
	end

	local isRangedClass = classFileName == "WARRIOR" or classFileName == "HUNTER" or classFileName == "ROGUE";

	GameTooltip:AddLine(format(STAT_CRIT_MELEE, meleeCrit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
	
	if isRangedClass then
		GameTooltip:AddLine(format(STAT_CRIT_RANGED, rangedCrit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
	end

	GameTooltip:AddLine(format(STAT_CRIT_SPELL, spellCrit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
	
	local critBonusTooltip;

	if self.unit == "pet" then
		critBonusTooltip = _G["STAT_" .. playersClass .. "_" .. classFileName .. "_CRIT_BONUS"] or STAT_CRIT_BONUS;
	else
		critBonusTooltip = _G["STAT_" .. classFileName .. "_CRIT_BONUS"] or STAT_CRIT_BONUS;
	end

	GameTooltip:AddLine(" ");
	GameTooltip:SetMinimumWidth(275);

	GameTooltip:AddLine(format(critBonusTooltip), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	
	GameTooltip:Show();
end

function PaperDollFrame_SetCritChance(statFrame, unit)
	local spellCrit = GetSpellCritChance();
	local rangedCrit = GetRangedCritChance();
	local meleeCrit = GetCritChance();
	local critChance = max(spellCrit, rangedCrit, meleeCrit);

	critChance = format("%.1f%%", critChance);

	PaperDollFrame_SetLabelAndText(statFrame, STAT_CRITICAL_STRIKE, critChance, false, critChance);

	statFrame.unit = unit;

	statFrame.onEnterFunc = function (self) CharacterCritChanceFrame_OnEnter(self, meleeCrit, rangedCrit, spellCrit) end;
	
	statFrame:Show();

	return critChance;
end

function PaperDollFrame_ExpertiseOnEnter(statFrame)

	if (MOVING_STAT_CATEGORY) then return; end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");

	local expertise, offhandExpertise, rangedExpertise = GetExpertise();
	expertise = format("%.1F%%", expertise);
	offhandExpertise = format("%.1F%%", offhandExpertise);
	rangedExpertise = format("%.1F%%", rangedExpertise);

	local expertiseDisplay;
	if (IsDualWielding()) then
		expertiseDisplay = expertise.." / "..offhandExpertise;
	else
		expertiseDisplay = expertise;
	end

	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G["COMBAT_RATING_NAME"..CR_EXPERTISE]).." "..expertiseDisplay..FONT_COLOR_CODE_CLOSE);

	local expertiseTooltip = (category == "MELEE") and CR_EXPERTISE_TOOLTIP or CR_RANGED_EXPERTISE_TOOLTIP;
	GameTooltip:AddLine(format(expertiseTooltip, expertiseDisplay), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	
	GameTooltip:Show();
end

function PaperDollFrame_SetExpertise(statFrame, unit, usePercent)
	if ( unit ~= "player" ) then
		return 0;
	end
	
	local expertise, offhandExpertise, rangedExpertise = GetExpertise();

	local maxExpertise = max(expertise, offhandExpertise, rangedExpertise);

	if usePercent then
		expertise = format("%.1F%%", expertise);
		offhandExpertise = format("%.1F%%", offhandExpertise);
		rangedExpertise = format("%.1F%%", rangedExpertise);
	end
	local speed, offhandSpeed = UnitAttackSpeed(unit);
	local text;
	if( offhandSpeed ) then
		text = expertise.." / "..offhandExpertise;
	else
		text = expertise;
	end
	PaperDollFrame_SetLabelAndText(statFrame, STAT_EXPERTISE, text, false, expertise);
	PaperDollFrame_SetOnEnter(statFrame, PaperDollFrame_ExpertiseOnEnter)

	return maxExpertise;
end

local function PaperDollFrame_GetEquippedWeaponSkillID(slotID)

	if GetShapeshiftForm() ~= 0 and select(2, UnitClass("player")) == "DRUID" then
		return FERAL_WEAPON_SKILL;
	end

	local itemID = GetInventoryItemID("player", slotID);
	if not itemID then
		return 162; -- Unarmed
	end

	local _, _, _, _, _, classID, subclassID = C_Item.GetItemInfoInstant(itemID);
	if classID ~= Enum.ItemClass.Weapon then
		return nil;
	end

	return WEAPON_SUBCLASS_TO_SKILL_ID[subclassID];
end

local function PaperDollFrame_AddWeaponSkillLine(slotID)

	local skillLineID = PaperDollFrame_GetEquippedWeaponSkillID(slotID);

	if not skillLineID then
		return;
	end

	local skillText = nil;

	local skillInfo = C_SkillInfo.GetSkillLineInfoByID(skillLineID);
	if skillInfo then
		local rankText;
		if ( skillInfo.modifier == 0 ) then
			rankText = skillInfo.rank.."/"..skillInfo.maxRank;
		else
			rankText = skillInfo.rank.." ("..skillInfo.modifier..")/"..skillInfo.maxRank;
		end

		GameTooltip:AddDoubleLine(format(WEAPON_SKILL_PAPERDOLLFRAME_FORMAT, skillInfo.name), rankText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end

local PaperDollFrame_DefaultDamageOnEnter = CharacterDamageFrame_OnEnter;
function CharacterDamageFrame_OnEnter(self)
	PaperDollFrame_DefaultDamageOnEnter(self);
	
	if self.unit ~= "pet" then
		local slotID = DAMAGE_TOOLTIP_LABEL_TO_SLOT[self.tooltipLabel] or INVSLOT_MAINHAND;
		PaperDollFrame_AddWeaponSkillLine(slotID);
	end

	GameTooltip:Show();
end
