EQUIPPED_FIRST = 1;
EQUIPPED_LAST = 19;

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
CR_MULTISTRIKE = 12;
CR_READINESS = 13;
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

local STATCATEGORY_PADDING = 4;
local STATCATEGORY_MOVING_INDENT = 4;

MOVING_STAT_CATEGORY = nil;

local StatCategoryFrames = {};

local STRIPE_COLOR = {r=0.9, g=0.9, b=1};

CLASS_MASTERY_SPELLS = {
	["DEATHKNIGHT"] = 86471,
	["DRUID"] = 86470 ,
	["HUNTER"] = 86472,
	["MAGE"] = 86473,
	["PALADIN"] = 86474,
	["PRIEST"] = 86475,
	["ROGUE"] = 86476, 
	["SHAMAN"] = 86477,
	["WARLOCK"] = 86478,
	["WARRIOR"] = 86479,
};

PAPERDOLL_SIDEBARS = {
	{
		name=PAPERDOLL_SIDEBAR_STATS;
		frame="CharacterStatsPane";
		icon = nil;  -- Uses the character portrait
		texCoords = {0.109375, 0.890625, 0.09375, 0.90625};
	},
	{
		name=PAPERDOLL_SIDEBAR_TITLES;
		frame="PaperDollTitlesPane";
		icon = "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs";
		texCoords = {0.01562500, 0.53125000, 0.32421875, 0.46093750};
	},
	{
		name=PAPERDOLL_EQUIPMENTMANAGER;
		frame="PaperDollEquipmentManagerPane";
		icon = "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs";
		texCoords = {0.01562500, 0.53125000, 0.46875000, 0.60546875};
	},
};

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
	["SPIRIT"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_SPIRIT); end 
	},
	["BONUS_ARMOR"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetBonusArmor(statFrame, unit); end
	},
	["MULTISTRIKE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetMultistrike(statFrame, unit); end
	},
	["LIFESTEAL"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetLifesteal(statFrame, unit); end
	},
	["VERSATILITY"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetVersatility(statFrame, unit); end
	},
	["AVOIDANCE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetAvoidance(statFrame, unit); end
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
};

-- Warning: Avoid changing the IDs, since this will screw up the cvars that remember which categories a player has collapsed
PAPERDOLL_STATCATEGORIES = {
	["GENERAL"] = {
		id = 1,
		stats = { 
			"HEALTH",
			"ALTERNATEMANA",  -- Druids when in bear/cat form and Mistweaver Monks
			"POWER",
			"ITEMLEVEL",
			"MOVESPEED",
		}
	},
						
	["ATTRIBUTES"] = {
		id = 2,
		stats = {
			"STRENGTH",
			"AGILITY",
			"INTELLECT",
			"STAMINA",
		}
	},
	
	["ENHANCEMENTS"] = {
		id = 7,
		stats = {
			"CRITCHANCE",
			"HASTE",
			"MASTERY",
			"SPIRIT",
			"BONUS_ARMOR",
			"MULTISTRIKE",
			"LIFESTEAL",
			"VERSATILITY",
			"AVOIDANCE",
		}
	},

	["ATTACK"] = {
		id = 8,
		stats = {
			"ATTACK_DAMAGE", 
			"ATTACK_AP", 
			"ATTACK_ATTACKSPEED", 
			"ENERGY_REGEN",
			"RUNE_REGEN",
			"FOCUS_REGEN",
		}
	},
				
	["SPELL"] = {
		id = 5,
		stats = {
			"SPELLPOWER",
			"MANAREGEN",
		}
	},
			
	["DEFENSE"] = {
		id = 6,
		stats = {
			"ARMOR", 
			"DODGE",
			"PARRY", 
			"BLOCK",
		}
	},
};

PAPERDOLL_STATCATEGORY_DEFAULTORDER = {
	"GENERAL",
	"ATTRIBUTES",
	"ENHANCEMENTS",
	"ATTACK",
	"SPELL",
	"DEFENSE",
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

function PaperDollFrame_OnLoad (self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED");
	self:RegisterEvent("UNIT_MODEL_CHANGED");
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
	self:RegisterEvent("MULTISTRIKE_UPDATE");
	self:RegisterEvent("SPEED_UPDATE");
	self:RegisterEvent("LIFESTEAL_UPDATE");
	self:RegisterEvent("AVOIDANCE_UPDATE");
	self:RegisterEvent("KNOWN_TITLES_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("PLAYER_BANKSLOTS_CHANGED");
	self:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE");
	self:RegisterEvent("PLAYER_DAMAGE_DONE_MODS");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self:RegisterUnitEvent("UNIT_DAMAGE", "player");
	self:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player");
	self:RegisterUnitEvent("UNIT_MAXHEALTH", "player");
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("SPELL_POWER_CHANGED");
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
	
	if( GameLimitedMode_IsActive() ) then
		CharacterTrialLevelErrorText:SetText(CAPPED_LEVEL_TRIAL);
	end
end

function PaperDoll_IsEquippedSlot (slot)
	if ( slot ) then
		slot = tonumber(slot);
		if ( slot ) then
			return slot >= EQUIPPED_FIRST and slot <= EQUIPPED_LAST;
		end
	end
	return false;
end

function CharacterModelFrame_OnMouseUp (self, button)
	if ( button == "LeftButton" ) then
		AutoEquipCursorItem();
	end
	Model_OnMouseUp(self, button);
end

-- This makes sure the update only happens once at the end of the frame
function PaperDollFrame_QueuedUpdate(self)
	self:SetScript("OnUpdate", nil);
	PaperDollFrame_UpdateStats();
end

function PaperDollFrame_OnEvent (self, event, ...)
	local unit = ...;
	if ( event == "PLAYER_ENTERING_WORLD" or
		event == "UNIT_MODEL_CHANGED" and unit == "player" ) then
		CharacterModelFrame:SetUnit("player", false);
		return;
	elseif ( event == "KNOWN_TITLES_UPDATE" or (event == "UNIT_NAME_UPDATE" and unit == "player")) then
		if (PaperDollTitlesPane:IsShown()) then
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
			event == "MULTISTRIKE_UPDATE" or 
			event == "SPEED_UPDATE" or 
			event == "LIFESTEAL_UPDATE" or 
			event == "AVOIDANCE_UPDATE" or 
			event == "BAG_UPDATE" or 
			event == "PLAYER_EQUIPMENT_CHANGED" or 
			event == "PLAYER_BANKSLOTS_CHANGED" or 
			event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" or 
			event == "PLAYER_DAMAGE_DONE_MODS") then
		self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
	elseif (event == "VARIABLES_LOADED") then
		if (GetCVar("characterFrameCollapsed") ~= "0") then
			CharacterFrame_Collapse();
		else
			CharacterFrame_Expand();
		end
		
		local activeSpec = GetActiveSpecGroup();
		if (activeSpec == 1) then
			PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, "statCategoryOrder", "statCategoriesCollapsed", "player");
		else
			PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, "statCategoryOrder_2", "statCategoriesCollapsed_2", "player");
		end
	elseif (event == "PLAYER_TALENT_UPDATE") then
		PaperDollFrame_SetLevel();
		self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
	elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then
		local activeSpec = GetActiveSpecGroup();
		if (activeSpec == 1) then
			PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, "statCategoryOrder", "statCategoriesCollapsed", "player");
		else
			PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, "statCategoryOrder_2", "statCategoriesCollapsed_2", "player");
		end
	elseif ( event == "SPELL_POWER_CHANGED" ) then
		self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
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
	if (showTrialCap) then
		CharacterTrialLevelErrorText:Show();
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
	health = BreakUpLargeNumbers(health);
	PaperDollFrame_SetLabelAndText(statFrame, HEALTH, health, false);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, HEALTH).." "..health..FONT_COLOR_CODE_CLOSE;
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
	power = BreakUpLargeNumbers(power);
	if (powerToken and _G[powerToken]) then
		PaperDollFrame_SetLabelAndText(statFrame, _G[powerToken], power, false);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G[powerToken]).." "..power..FONT_COLOR_CODE_CLOSE;
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
	power = BreakUpLargeNumbers(power);
	PaperDollFrame_SetLabelAndText(statFrame, MANA, power, false);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MANA).." "..power..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = _G["STAT_MANA_TOOLTIP"];
	statFrame:Show();
end

function PaperDollFrame_SetStat(statFrame, unit, statIndex)
	local label = _G[statFrame:GetName().."Label"];
	local text = _G[statFrame:GetName().."StatText"];
	local stat;
	local effectiveStat;
	local posBuff;
	local negBuff;
	stat, effectiveStat, posBuff, negBuff = UnitStat(unit, statIndex);
	local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
	label:SetText(format(STAT_FORMAT, statName));
	local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat);
	-- Set the tooltip text
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." ";

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		text:SetText(effectiveStatDisplay);
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
		if ( negBuff < 0 ) then
			text:SetText(RED_FONT_COLOR_CODE..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE);
		else
			text:SetText(GREEN_FONT_COLOR_CODE..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE);
		end
	end
	statFrame.tooltip2 = _G["DEFAULT_STAT"..statIndex.."_TOOLTIP"];
	
	if (unit == "player") then
		local _, unitClass = UnitClass("player");
		unitClass = strupper(unitClass);
		
		local primaryStat, spec;
		spec = GetSpecialization();
		if (spec) then
			primaryStat = select(7, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")));
		end
		-- Strength
		if ( statIndex == LE_UNIT_STAT_STRENGTH ) then
			local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
			if (HasAPEffectsSpellPower()) then
				statFrame.tooltip2 = STAT_TOOLTIP_BONUS_AP_SP;
			end
			if (not primaryStat or primaryStat == LE_UNIT_STAT_STRENGTH) then
				statFrame.tooltip2 = format(statFrame.tooltip2, BreakUpLargeNumbers(attackPower));
			else
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			end
		-- Agility
		elseif ( statIndex == LE_UNIT_STAT_AGILITY ) then
			local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
			local tooltip = STAT_TOOLTIP_BONUS_AP;
			if (HasAPEffectsSpellPower()) then
				tooltip = STAT_TOOLTIP_BONUS_AP_SP;
			end
			if (not primaryStat or primaryStat == LE_UNIT_STAT_AGILITY) then
				statFrame.tooltip2 = format(tooltip, BreakUpLargeNumbers(attackPower));
			else
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			end
		-- Stamina
		elseif ( statIndex == LE_UNIT_STAT_STAMINA ) then
			statFrame.tooltip2 = format(statFrame.tooltip2, BreakUpLargeNumbers(((effectiveStat*UnitHPPerStamina("player")))*GetUnitMaxHealthModifier("player")));
		-- Intellect
		elseif ( statIndex == LE_UNIT_STAT_INTELLECT ) then
			if ( UnitHasMana("player") ) then
				if (HasAPEffectsSpellPower()) then
					statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
				else
					local result, druid = HasSPEffectsAttackPower();
					if (result and druid) then
						statFrame.tooltip2 = format(STAT_TOOLTIP_SP_AP_DRUID, max(0, effectiveStat), max(0, effectiveStat));
					elseif (result) then
						statFrame.tooltip2 = format(STAT_TOOLTIP_BONUS_AP_SP, max(0, effectiveStat));
					elseif (not primaryStat or primaryStat == LE_UNIT_STAT_INTELLECT) then
						statFrame.tooltip2 = format(statFrame.tooltip2, max(0, effectiveStat));
					else
						statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
					end
				end
			else
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			end
		-- Spirit
		elseif ( statIndex == LE_UNIT_STAT_SPIRIT ) then
			-- All mana regen stats are displayed as mana/5 sec.
			local _, isNegatedForSpec = GetUnitManaRegenRateFromSpirit("player");
			local _, regen = GetManaRegen();
			if ( UnitHasMana("player") and not isNegatedForSpec ) then
				regen = BreakUpLargeNumbers( floor( regen * 5.0 ) );
				statFrame.tooltip2 = format(MANA_REGEN_FROM_SPIRIT, regen);
			else
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			end
		end
	elseif (unit == "pet") then
		if ( statIndex == LE_UNIT_STAT_STRENGTH ) then
			local attackPower = BreakUpLargeNumbers(effectiveStat);
			statFrame.tooltip2 = format(statFrame.tooltip2, attackPower);
		elseif ( statIndex == LE_UNIT_STAT_AGILITY ) then
			statFrame.tooltip2 = format(statFrame.tooltip2, GetCritChanceFromAgility("pet"));
		elseif ( statIndex == LE_UNIT_STAT_STAMINA ) then
			local expectedHealthGain = (((stat - posBuff - negBuff))*CREATURE_HP_PER_STA)*GetUnitHealthModifier("pet");
			local realHealthGain = (effectiveStat*CREATURE_HP_PER_STA)*GetUnitHealthModifier("pet");
			local healthGain = BreakUpLargeNumbers((realHealthGain - expectedHealthGain)*GetUnitMaxHealthModifier("pet"));
			statFrame.tooltip2 = format(statFrame.tooltip2, healthGain);
		elseif ( statIndex == LE_UNIT_STAT_INTELLECT ) then
			if ( UnitHasMana("pet") ) then
				local manaGain = BreakUpLargeNumbers((effectiveStat*15)*GetUnitPowerModifier("pet"));
				statFrame.tooltip2 = format(statFrame.tooltip2, manaGain, max(0, effectiveStat), GetSpellCritChanceFromIntellect("pet"));
			else
				statFrame.tooltip2 = nil;
			end
		elseif ( statIndex == LE_UNIT_STAT_SPIRIT ) then
			statFrame.tooltip2 = "";
			if ( UnitHasMana("pet") ) then
				statFrame.tooltip2 = format(MANA_REGEN_FROM_SPIRIT, GetUnitManaRegenRateFromSpirit("pet"));
			end
		end
	end
	statFrame:Show();
end

function CharacterArmor_OnEnter (self)
	if (MOVING_STAT_CATEGORY) then return; end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.tooltip);
	
	GameTooltip:AddLine(self.tooltip2);
	GameTooltip:Show();
end

function PaperDollFrame_SetArmor(statFrame, unit)
	local baselineArmor, effectiveArmor, armor, posBuff, negBuff = UnitArmor(unit);
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, ARMOR));
	local text = _G[statFrame:GetName().."StatText"];

    local bonusArmor = UnitBonusArmor(unit);
    local nonBonusArmor = effectiveArmor - bonusArmor;

    if ( nonBonusArmor < baselineArmor) then
        baselineArmor = nonBonusArmor
    end

	PaperDollFrame_SetLabelAndText(statFrame, STAT_ARMOR, effectiveArmor, false);
    local baseArmorReduction = PaperDollFrame_GetArmorReduction(baselineArmor, UnitEffectiveLevel(unit));
    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit));
	
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ARMOR).." "..string.format("%s", effectiveArmor)..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(STAT_ARMOR_BASE_TOOLTIP, baseArmorReduction);
	
	if (bonusArmor > 0) then
		statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(STAT_ARMOR_TOTAL_TOOLTIP, armorReduction);
	end

	if ( unit == "player" ) then
		local petBonus = ComputePetBonus("PET_BONUS_ARMOR", effectiveArmor );
		if( petBonus > 0 ) then
			statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_ARMOR, petBonus);
		end
	end
	
	statFrame:SetScript("OnEnter", CharacterArmor_OnEnter);
	statFrame:Show();
end

function PaperDollFrame_SetBonusArmor(statFrame, unit)
	local _, effectiveArmor, _, posBuff, negBuff = UnitArmor(unit);
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, ARMOR));
	local text = _G[statFrame:GetName().."StatText"];

	local bonusArmor, isNegatedForSpec = UnitBonusArmor(unit);

	PaperDollFrame_SetLabelAndText(statFrame, STAT_BONUS_ARMOR, bonusArmor, false);
	local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit));
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BONUS_ARMOR).." "..string.format("%s", bonusArmor)..FONT_COLOR_CODE_CLOSE;

	local hasAura, percent = GetBladedArmorEffect();

	if (hasAura) then
		statFrame.tooltip2 = format(STAT_ARMOR_BONUS_ARMOR_BLADED_ARMOR_TOOLTIP, armorReduction, (bonusArmor * (percent / 100)));
	elseif (not isNegatedForSpec) then
		statFrame.tooltip2 = format(STAT_ARMOR_TOTAL_TOOLTIP, armorReduction);
	else
		statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
	end
	
	statFrame:SetScript("OnEnter", CharacterArmor_OnEnter);
	statFrame:Show();
end

function PaperDollFrame_SetDodge(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide();
		return;
	end
	
	local chance = GetDodgeChance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_DODGE, chance, 1);
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
	PaperDollFrame_SetLabelAndText(statFrame, STAT_BLOCK, chance, 1);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BLOCK_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_BLOCK_TOOLTIP, GetShieldBlock());
	statFrame:Show();
end

function PaperDollFrame_SetParry(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide();
		return;
	end
	
	local chance = GetParryChance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, chance, 1);
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
	PaperDollFrame_SetLabelAndText(statFrame, STAT_RESILIENCE, damageReduction, 1);
	
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
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, DAMAGE));
	local text = _G[statFrame:GetName().."StatText"];
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

	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			text:SetText(displayMinLarge.." - "..displayMaxLarge);	
		else
			text:SetText(displayMinLarge.."-"..displayMaxLarge);
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
			text:SetText(color..displayMinLarge.." - "..displayMaxLarge.."|r");	
		else
			text:SetText(color..displayMinLarge.."-"..displayMaxLarge.."|r");
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
	
	statFrame:SetScript("OnEnter", CharacterDamageFrame_OnEnter);
	
	statFrame:Show();
end

function PaperDollFrame_SetAttackSpeed(statFrame, unit)
	local meleeHaste = GetMeleeHaste();
	local speed, offhandSpeed = UnitAttackSpeed(unit);

--	speed = format("%.2F", speed);
	if ( offhandSpeed ) then
		offhandSpeed = format("%.2F", offhandSpeed);
	end
	local text;	
	if ( offhandSpeed ) then
		text =  BreakUpLargeNumbers(speed).." / ".. offhandSpeed;
	else
		text =  BreakUpLargeNumbers(speed);
	end
	PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, text);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..text..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste));
	
	statFrame:Show();
end

function PaperDollFrame_SetAttackPower(statFrame, unit)
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_ATTACK_POWER));
	local text = _G[statFrame:GetName().."StatText"];
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
	if (GetOverrideAPBySpellPower() ~= nil) then
		local holySchool = 2;
		-- Start at 2 to skip physical damage
		spellPower = GetSpellBonusDamage(holySchool);		
		for i=(holySchool+1), MAX_SPELL_SCHOOLS do
			spellPower = min(spellPower, GetSpellBonusDamage(i));
		end
		spellPower = min(spellPower, GetSpellBonusHealing()) * GetOverrideAPBySpellPower();

		PaperDollFormatStat(tag, spellPower, 0, 0, statFrame, text);
		damageBonus = BreakUpLargeNumbers(spellPower / ATTACK_POWER_MAGIC_NUMBER);
	else
		PaperDollFormatStat(tag, base, posBuff, negBuff, statFrame, text);
	end
	
	local effectiveAP = max(0,base + posBuff + negBuff);
	if (GetOverrideSpellPowerByAP() ~= nil) then
		statFrame.tooltip2 = format(MELEE_ATTACK_POWER_SPELL_POWER_TOOLTIP, damageBonus, BreakUpLargeNumbers(effectiveAP * GetOverrideSpellPowerByAP() + 0.5));
	else
		statFrame.tooltip2 = format(tooltip, damageBonus);
	end
	statFrame:Show();
end

function PaperDollFrame_SetSpellPower(statFrame, unit)
	local text = _G[statFrame:GetName().."StatText"];
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
		
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_SPELLPOWER));
	statFrame.tooltip = STAT_SPELLPOWER;
	statFrame.tooltip2 = STAT_SPELLPOWER_TOOLTIP;
	
	text:SetText(BreakUpLargeNumbers(minModifier));
	statFrame.minModifier = minModifier;
	statFrame.unit = unit;
	statFrame:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter);
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

	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_CRITICAL_STRIKE));
	local text = _G[statFrame:GetName().."StatText"];
	
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
		
	critChance = format("%.2F%%", critChance);
	text:SetText(critChance);
		
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE).." "..critChance..FONT_COLOR_CODE_CLOSE;
	if (GetCritChanceProvidesParryEffect()) then
		local critChance = GetCombatRatingBonus(rating);
		local critRating = GetCombatRating(rating);
		statFrame.tooltip2 = format(CR_CRIT_PARRY_RATING_TOOLTIP, BreakUpLargeNumbers(critRating), critChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, critRating));
	else
		statFrame.tooltip2 = format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(rating)), GetCombatRatingBonus(rating));
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
	regenRate = BreakUpLargeNumbers(regenRate);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_ENERGY_REGEN, regenRate, false);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_ENERGY_REGEN).." "..regenRate..FONT_COLOR_CODE_CLOSE;
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
	regenRate = BreakUpLargeNumbers(regenRate);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_FOCUS_REGEN, regenRate, false);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_FOCUS_REGEN).." "..regenRate..FONT_COLOR_CODE_CLOSE;
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
	regenRate = (format(STAT_RUNE_REGEN_FORMAT, regenRate));
	PaperDollFrame_SetLabelAndText(statFrame, STAT_RUNE_REGEN, regenRate, false);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_RUNE_REGEN).." "..regenRate..FONT_COLOR_CODE_CLOSE;
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

	if (haste < 0) then
		haste = RED_FONT_COLOR_CODE..format("%.2F%%", haste)..FONT_COLOR_CODE_CLOSE;
	else
		haste = "+"..format("%.2F%%", haste);
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_HASTE));	
	local text = _G[statFrame:GetName().."StatText"];
	text:SetText(haste);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE) .. " " .. haste .. FONT_COLOR_CODE_CLOSE;
	
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
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, MANA_REGEN));
	local text = _G[statFrame:GetName().."StatText"];
	if ( not UnitHasMana("player") ) then
		text:SetText(NOT_APPLICABLE);
		statFrame.tooltip = nil;
		return;
	end
	
	local base, combat = GetManaRegen();
	-- All mana regen stats are displayed as mana/5 sec.
	base = BreakUpLargeNumbers(floor( base * 5.0 ));
	combat = BreakUpLargeNumbers(floor( combat * 5.0 ));
	-- Combat mana regen is most important to the player, so we display it as the main value
	text:SetText(combat);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MANA_REGEN) .. " " .. combat .. FONT_COLOR_CODE_CLOSE;
	-- Base (out of combat) regen is displayed only in the subtext of the tooltip
	statFrame.tooltip2 = format(MANA_REGEN_TOOLTIP, base);
	statFrame:Show();
end

function Mastery_OnEnter(statFrame)
	if (MOVING_STAT_CATEGORY) then return; end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");
	
	local _, class = UnitClass("player");
	local mastery, bonusCoeff = GetMasteryEffect();
	local masteryBonus = GetCombatRatingBonus(CR_MASTERY) * bonusCoeff;
	
	local title = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MASTERY).." "..format("%.2F%%", mastery)..FONT_COLOR_CODE_CLOSE;
	if (masteryBonus > 0) then
		title = title..HIGHLIGHT_FONT_COLOR_CODE.." ("..format("%.2F%%", mastery-masteryBonus)..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..format("%.2F%%", masteryBonus)..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
	end
	GameTooltip:SetText(title);
	
	local primaryTalentTree = GetSpecialization();
	if (primaryTalentTree) then
		local masterySpell, masterySpell2 = GetSpecializationMasterySpells(primaryTalentTree);
		if (masterySpell) then
			GameTooltip:AddSpellByID(masterySpell);
		end
		if (masterySpell2) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddSpellByID(masterySpell2);
		end
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, GetCombatRating(CR_MASTERY), masteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	else
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, GetCombatRating(CR_MASTERY), masteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(STAT_MASTERY_TOOLTIP_NO_TALENT_SPEC, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
	end
	GameTooltip:Show();
end

function PaperDollFrame_SetMastery(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	if (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_MASTERY));
	local text = _G[statFrame:GetName().."StatText"];
	local mastery = GetMasteryEffect();
	mastery = format("%.2F%%", mastery);
	text:SetText(mastery);
	statFrame:SetScript("OnEnter", Mastery_OnEnter);
	statFrame:Show();
end

-- Task 68016: Multistrike gives damaging attacks and heals a chance to repeat the damage or healing at 30% effectiveness
function PaperDollFrame_SetMultistrike(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_MULTISTRIKE));
	local text = _G[statFrame:GetName().."StatText"];
	local multistrike = GetMultistrike();
	multistrike = format("%.2F%%", multistrike);
	text:SetText(multistrike);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MULTISTRIKE) .. " " .. multistrike .. FONT_COLOR_CODE_CLOSE;
	
	statFrame.tooltip2 = format(CR_MULTISTRIKE_TOOLTIP, GetMultistrike(), GetMultistrikeEffect(), BreakUpLargeNumbers(GetCombatRating(CR_MULTISTRIKE)), GetCombatRatingBonus(CR_MULTISTRIKE));

	statFrame:Show();
end

-- Task 68016: Readiness reduces the cooldown of core class/spec abilities
function Readiness_OnEnter(statFrame)
	if (MOVING_STAT_CATEGORY) then return; end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");
	
	local title = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_READINESS).." "..format("%.2F%%", GetReadiness())..FONT_COLOR_CODE_CLOSE;

	GameTooltip:SetText(title);
	
	local primaryTalentTree = GetSpecialization();
	if (primaryTalentTree) then
		local readinessSpell = GetSpecializationReadinessSpell(primaryTalentTree);
		if (readinessSpell) then
			GameTooltip:AddSpellByID(readinessSpell);
		end

		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(format(CR_READINESS_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_READINESS)), GetCombatRatingBonus(CR_READINESS)));
	else
		GameTooltip:AddLine(CR_READINESS_TOOLTIP_NO_TALENT_SPEC, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
	end
	GameTooltip:Show();
end

-- Task 68016: Readiness reduces the cooldown of core class/spec abilities
function PaperDollFrame_SetReadiness(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_READINESS));
	local text = _G[statFrame:GetName().."StatText"];
	local readiness = GetReadiness();
	readiness = format("%.2F%%", readiness);
	text:SetText(readiness);
	statFrame:SetScript("OnEnter", Readiness_OnEnter);
	statFrame:Show();
end

-- Task 68016: Speed increases run speed
function PaperDollFrame_SetSpeed(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_SPEED));
	local text = _G[statFrame:GetName().."StatText"];
	local speed = GetSpeed();
	speed = format("%.2F%%", speed);
	text:SetText(speed);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPEED) .. " " .. speed .. FONT_COLOR_CODE_CLOSE;
	
	statFrame.tooltip2 = format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED));

	statFrame:Show();
end

-- Task 68016: Lifesteal returns a portion of all damage done as health
function PaperDollFrame_SetLifesteal(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_LIFESTEAL));
	local text = _G[statFrame:GetName().."StatText"];
	local lifesteal = GetLifesteal();
	lifesteal = format("%.2F%%", lifesteal);
	text:SetText(lifesteal);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL) .. " " .. lifesteal .. FONT_COLOR_CODE_CLOSE;
	
	statFrame.tooltip2 = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)), GetCombatRatingBonus(CR_LIFESTEAL));

	statFrame:Show();
end

-- Task 68016: Avoidance reduces AoE damage taken
function PaperDollFrame_SetAvoidance(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_AVOIDANCE));
	local text = _G[statFrame:GetName().."StatText"];
	local avoidance = GetAvoidance();
	avoidance = format("%.2F%%", avoidance);
	text:SetText(avoidance);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVOIDANCE) .. " " .. avoidance .. FONT_COLOR_CODE_CLOSE;
	
	statFrame.tooltip2 = format(CR_AVOIDANCE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_AVOIDANCE)), GetCombatRatingBonus(CR_AVOIDANCE));

	statFrame:Show();
end

function PaperDollFrame_SetVersatility(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_VERSATILITY));
	local text = _G[statFrame:GetName().."StatText"];
	local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
	local versatilityLabel = format("%.2F%%", versatilityDamageBonus);
	text:SetText(versatilityLabel);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(VERSATILITY_TOOLTIP_FORMAT, STAT_VERSATILITY, versatilityDamageBonus, versatilityDamageTakenReduction) .. FONT_COLOR_CODE_CLOSE;
	
	statFrame.tooltip2 = format(CR_VERSATILITY_TOOLTIP, versatilityDamageBonus, versatilityDamageTakenReduction, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction);

	statFrame:Show();
end

function PaperDollFrame_SetItemLevel(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_AVERAGE_ITEM_LEVEL));
	local text = _G[statFrame:GetName().."StatText"];
	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel();
	avgItemLevel = floor(avgItemLevel);
	avgItemLevelEquipped = floor(avgItemLevelEquipped);
	text:SetText(avgItemLevelEquipped .. " / " .. avgItemLevel);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..avgItemLevel;
	if ( avgItemLevelEquipped ~= avgItemLevel ) then
		statFrame.tooltip = statFrame.tooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, avgItemLevelEquipped);
	end
	statFrame.tooltip = statFrame.tooltip .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP;

	if ( avgItemLevel ~= avgItemLevelPvP ) then
		statFrame.tooltip2 = statFrame.tooltip2.."\n\n"..STAT_AVERAGE_PVP_ITEM_LEVEL:format(avgItemLevelPvP);
	end
end

function MovementSpeed_OnEnter(statFrame)
	if (MOVING_STAT_CATEGORY) then return; end
	
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
	
	statFrame.Value:SetFormattedText("%d%%", speed+0.5);
	statFrame.speed = speed;
	statFrame.runSpeed = runSpeed;
	statFrame.flightSpeed = flightSpeed;
	statFrame.swimSpeed = swimSpeed;
end

function PaperDollFrame_SetMovementSpeed(statFrame, unit)
	statFrame.Label:SetText(format(STAT_FORMAT, STAT_MOVEMENT_SPEED));
	
	statFrame.wasSwimming = nil;
	statFrame.unit = unit;
	MovementSpeed_OnUpdate(statFrame);
	
	statFrame:SetScript("OnEnter", MovementSpeed_OnEnter);
	statFrame:SetScript("OnUpdate", MovementSpeed_OnUpdate);
end

function CharacterSpellBonusDamage_OnEnter (self)
	if (MOVING_STAT_CATEGORY) then return; end
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

function PaperDollFrame_OnShow (self)
	CharacterStatsPane.initialOffsetY = 0;
	CharacterFrameTitleText:SetText(UnitPVPName("player"));
	PaperDollFrame_SetLevel();
	local activeSpec = GetActiveSpecGroup();
	if (activeSpec == 1) then
		PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, "statCategoryOrder", "statCategoriesCollapsed", "player");
	else
		PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, "statCategoryOrder_2", "statCategoriesCollapsed_2", "player");
	end
	if (GetCVar("characterFrameCollapsed") ~= "0") then
		CharacterFrame_Collapse();
	else
		CharacterFrame_Expand();
	end
	CharacterFrameExpandButton:Show();
	CharacterFrameExpandButton.collapseTooltip = STATS_COLLAPSE_TOOLTIP;
	CharacterFrameExpandButton.expandTooltip = STATS_EXPAND_TOOLTIP;
	
	SetPaperDollBackground(CharacterModelFrame, "player");
	PaperDollBgDesaturate(true);
	PaperDollSidebarTabs:Show();
end
 
function PaperDollFrame_OnHide (self)
	CharacterStatsPane.initialOffsetY = 0;
	CharacterFrame_Collapse();
	CharacterFrameExpandButton:Hide();
	if (MOVING_STAT_CATEGORY) then
		PaperDollStatCategory_OnDragStop(MOVING_STAT_CATEGORY);
	end
	PaperDollSidebarTabs:Hide();
end

function PaperDollFrame_ClearIgnoredSlots ()
	EquipmentManagerClearIgnoredSlotsForSave();		
	for k, button in next, itemSlotButtons do
		if ( button.ignored ) then
			button.ignored = nil;
			PaperDollItemSlotButton_Update(button);
		end
	end
end

function PaperDollFrame_IgnoreSlotsForSet (setName)
	local set = GetEquipmentSetIgnoreSlots(setName);
	for slot, ignored in pairs(set) do
		if ( ignored ) then
			EquipmentManagerIgnoreSlotForSave(slot);
			itemSlotButtons[slot].ignored = true;
		else
			EquipmentManagerUnignoreSlotForSave(slot);
			itemSlotButtons[slot].ignored = false;
		end
		PaperDollItemSlotButton_Update(itemSlotButtons[slot]);
	end
end

function PaperDollFrame_IgnoreSlot(slot)
	EquipmentManagerIgnoreSlotForSave(slot);
	itemSlotButtons[slot].ignored = true;
	PaperDollItemSlotButton_Update(itemSlotButtons[slot]);
end

function PaperDollItemSlotButton_OnLoad (self)
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	local slotName = self:GetName();
	local id, textureName, checkRelic = GetInventorySlotInfo(strsub(slotName,10));
	self:SetID(id);
	local texture = _G[slotName.."IconTexture"];
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

function PaperDollItemSlotButton_OnShow (self, isBag)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("MERCHANT_UPDATE");
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("CURSOR_UPDATE");
	self:RegisterEvent("SHOW_COMPARE_TOOLTIP");
	self:RegisterEvent("UPDATE_INVENTORY_ALERTS");
	if ( not isBag ) then
		self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	end
	PaperDollItemSlotButton_Update(self);
end

function PaperDollItemSlotButton_OnHide (self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("MERCHANT_UPDATE");
	self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("CURSOR_UPDATE");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self:UnregisterEvent("SHOW_COMPARE_TOOLTIP");
	self:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
end

function PaperDollItemSlotButton_OnEvent (self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		if ( self:GetID() == arg1 ) then
			PaperDollItemSlotButton_Update(self);
		end
	elseif ( event == "ITEM_LOCK_CHANGED" ) then
		if ( not arg2 and arg1 == self:GetID() ) then
			PaperDollItemSlotButton_UpdateLock(self);
		end
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		PaperDollItemSlotButton_Update(self);
	elseif ( event == "CURSOR_UPDATE" ) then
		if ( CursorCanGoInSlot(self:GetID()) ) then
			self:LockHighlight();
		else
			self:UnlockHighlight();
		end
	elseif ( event == "SHOW_COMPARE_TOOLTIP" ) then
		if ( (arg1 ~= self:GetID()) or (arg2 > NUM_SHOPPING_TOOLTIPS) ) then
			return;
		end

		local tooltip = _G["ShoppingTooltip"..arg2];
		local anchor = "ANCHOR_RIGHT";
		if ( arg2 > 1 ) then
			anchor = "ANCHOR_BOTTOMRIGHT";
		end
		tooltip:SetOwner(self, anchor);
		local hasItem, hasCooldown = tooltip:SetInventoryItem("player", self:GetID());
		if ( not hasItem ) then
			tooltip:Hide();
		end
	elseif ( event == "UPDATE_INVENTORY_ALERTS" ) then
		PaperDollItemSlotButton_Update(self);
	elseif ( event == "MODIFIER_STATE_CHANGED" ) then
		if ( IsModifiedClick("SHOWITEMFLYOUT") and self:IsMouseOver() ) then
			PaperDollItemSlotButton_OnEnter(self);
		end
	end
end

function PaperDollItemSlotButton_OnClick (self, button)
	MerchantFrame_ResetRefundItem();
	if ( button == "LeftButton" ) then
		local type = GetCursorInfo();
		if ( type == "merchant" and MerchantFrame.extendedCost ) then
			MerchantFrame_ConfirmExtendedItemCost(MerchantFrame.extendedCost);
		else
			PickupInventoryItem(self:GetID());
			if ( CursorHasItem() ) then
				MerchantFrame_SetRefundItem(self, 1);
			end
		end
	else
		UseInventoryItem(self:GetID());
	end
end

function PaperDollItemSlotButton_OnModifiedClick (self, button)
	if ( HandleModifiedItemClick(GetInventoryItemLink("player", self:GetID())) ) then
		return;
	end
	if ( IsModifiedClick("SOCKETITEM") ) then
		SocketInventoryItem(self:GetID());
	end
end

function PaperDollItemSlotButton_Update (self)
	local textureName = GetInventoryItemTexture("player", self:GetID());
	local cooldown = _G[self:GetName().."Cooldown"];
	if ( textureName ) then
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
			CooldownFrame_SetTimer(cooldown, start, duration, enable);
		end
		self.hasItem = 1;
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
		self.hasItem = nil;
	end
	
	local quality = GetInventoryItemQuality("player", self:GetID());
	if (quality and quality > LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
		self.IconBorder:Show();
		self.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
	else
		self.IconBorder:Hide();
	end
	
	if (not PaperDollEquipmentManagerPane:IsShown()) then
		self.ignored = nil;
	end
	
	if ( self.ignored and self.ignoreTexture ) then
		self.ignoreTexture:Show();
	elseif ( self.ignoreTexture ) then
		self.ignoreTexture:Hide();
	end

	PaperDollItemSlotButton_UpdateLock(self);

	-- Update repair all button status
	MerchantFrame_UpdateGuildBankRepair();
	MerchantFrame_UpdateCanRepairAll();
end

function PaperDollItemSlotButton_UpdateLock (self)
	if ( IsInventoryItemLocked(self:GetID()) ) then
		--this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		SetItemButtonDesaturated(self, true);
	else 
		--this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
		SetItemButtonDesaturated(self, false);
	end
end

function PaperDollItemSlotButton_OnEnter (self)
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	EquipmentFlyout_UpdateFlyout(self);
	if ( not EquipmentFlyout_SetTooltipAnchor(self) ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", self:GetID());
	if ( not hasItem ) then
		local text = _G[strupper(strsub(self:GetName(), 10))];
		if ( self.checkRelic and UnitHasRelicSlot("player") ) then
			text = RELICSLOT;
		end
		GameTooltip:SetText(text);
	end
	if ( InRepairMode() and repairCost and (repairCost > 0) ) then
		GameTooltip:AddLine(REPAIR_COST, nil, nil, nil, true);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	else
		CursorUpdate(self);
	end
end

function PaperDollItemSlotButton_OnLeave (self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	GameTooltip:Hide();
	ResetCursor();
end

function PaperDollStatTooltip (self)
	if (MOVING_STAT_CATEGORY ~= nil) then return; end
	if ( not self.tooltip ) then
		return;
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.tooltip);
	if ( self.tooltip2 ) then
		GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
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

function ColorPaperDollStat(base, posBuff, negBuff)
	local stat;
	local effective = BreakUpLargeNumbers(max(0,base + posBuff + negBuff));
	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		stat = effective;
	else 
		
		-- if there is a negative buff then show the main number in red, even if there are
		-- positive buffs. Otherwise show the number in green
		if ( negBuff < 0 ) then
			stat = RED_FONT_COLOR_CODE..effective..FONT_COLOR_CODE_CLOSE;
		else
			stat = GREEN_FONT_COLOR_CODE..effective..FONT_COLOR_CODE_CLOSE;
		end
	end
	return stat;
end

function PaperDollFormatStat(name, base, posBuff, negBuff, frame, textString)
	local effective = BreakUpLargeNumbers(max(0,base + posBuff + negBuff));
	local text = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT,name).." "..effective;
	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		text = text..FONT_COLOR_CODE_CLOSE;
		textString:SetText(effective);
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
		if ( negBuff < 0 ) then
			textString:SetText(RED_FONT_COLOR_CODE..effective..FONT_COLOR_CODE_CLOSE);
		else
			textString:SetText(GREEN_FONT_COLOR_CODE..effective..FONT_COLOR_CODE_CLOSE);
		end
	end
	frame.tooltip = text;
end

function CharacterAttackFrame_OnEnter (self)
	if (MOVING_STAT_CATEGORY) then return; end
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

function CharacterDamageFrame_OnEnter (self)
	if (MOVING_STAT_CATEGORY) then return; end
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
	return GetArmorEffectiveness(armor, attackerLevel) * 100;
end

function PaperDollFrame_CollapseStatCategory(categoryFrame)
	if (not categoryFrame.collapsed) then
		categoryFrame.collapsed = true;
		local index = 1;
		while (_G[categoryFrame:GetName().."Stat"..index]) do 
			_G[categoryFrame:GetName().."Stat"..index]:Hide();
			index = index + 1;
		end
		categoryFrame.CollapsedIcon:Show();
		categoryFrame.ExpandedIcon:Hide();
		categoryFrame:SetHeight(18);
		PaperDollFrame_UpdateStatScrollChildHeight();
		categoryFrame.BgMinimized:Show();
		categoryFrame.BgTop:Hide();
		categoryFrame.BgMiddle:Hide();
		categoryFrame.BgBottom:Hide();
	end
end

function PaperDollFrame_ExpandStatCategory(categoryFrame)
	if (categoryFrame.collapsed) then
		categoryFrame.collapsed = false;
		categoryFrame.CollapsedIcon:Hide();
		categoryFrame.ExpandedIcon:Show();
		PaperDollFrame_UpdateStatCategory(categoryFrame);
		PaperDollFrame_UpdateStatScrollChildHeight();
		categoryFrame.BgMinimized:Hide();
		categoryFrame.BgTop:Show();
		categoryFrame.BgMiddle:Show();
		categoryFrame.BgBottom:Show();
	end
end

function PaperDollFrame_UpdateStatCategory(categoryFrame)
	if (not categoryFrame.Category) then
		categoryFrame:Hide();
		return;
	end
	
	local categoryInfo = PAPERDOLL_STATCATEGORIES[categoryFrame.Category];
	
	categoryFrame.NameText:SetText(_G["STAT_CATEGORY_"..categoryFrame.Category]);
	
	if (categoryFrame.collapsed) then
		return;
	end
	
	local stat;
	local totalHeight = categoryFrame.NameText:GetHeight() + 10;
	local numVisible = 0;
	if (categoryInfo) then
		local prevStatFrame = nil;
		for index, stat in next, categoryInfo.stats do
			local statInfo = PAPERDOLL_STATINFO[stat];
			if (statInfo) then
				local statFrame = _G[categoryFrame:GetName().."Stat"..numVisible+1];
				if (not statFrame) then
					statFrame = CreateFrame("FRAME", categoryFrame:GetName().."Stat"..numVisible+1, categoryFrame, "StatFrameTemplate");
					if (prevStatFrame) then
						statFrame:SetPoint("TOPLEFT", prevStatFrame, "BOTTOMLEFT", 0, 0);
						statFrame:SetPoint("TOPRIGHT", prevStatFrame, "BOTTOMRIGHT", 0, 0);
					end
				end
				statFrame:Show();
				-- Reset tooltip script in case it's been changed
				statFrame:SetScript("OnEnter", PaperDollStatTooltip);
				statFrame.tooltip = nil;
				statFrame.tooltip2 = nil;
				statFrame.UpdateTooltip = nil;
				statFrame:SetScript("OnUpdate", nil);
				statInfo.updateFunc(statFrame, CharacterStatsPane.unit);
				if (statFrame:IsShown()) then
					numVisible = numVisible+1;
					totalHeight = totalHeight + statFrame:GetHeight();
					prevStatFrame = statFrame;
					-- Update Tooltip
					if (GameTooltip:GetOwner() == statFrame) then
						statFrame:GetScript("OnEnter")(statFrame);
					end
				end
			end
		end
	end
	
	local i;
	for index=1, numVisible do
		if (index%2 == 0) then
			local statFrame = _G[categoryFrame:GetName().."Stat"..index];
			if (not statFrame.Bg) then
				statFrame.Bg = statFrame:CreateTexture(statFrame:GetName().."Bg", "BACKGROUND");
				statFrame.Bg:SetPoint("LEFT", categoryFrame, "LEFT", 1, 0);
				statFrame.Bg:SetPoint("RIGHT", categoryFrame, "RIGHT", 0, 0);
				statFrame.Bg:SetPoint("TOP");
				statFrame.Bg:SetPoint("BOTTOM");
				statFrame.Bg:SetTexture(STRIPE_COLOR.r, STRIPE_COLOR.g, STRIPE_COLOR.b);
				statFrame.Bg:SetAlpha(0.1);
			end
		end
	end
	
	-- Hide all other stats
	local index = numVisible + 1;
	while (_G[categoryFrame:GetName().."Stat"..index]) do 
		_G[categoryFrame:GetName().."Stat"..index]:Hide();
		index = index + 1;
	end
	
	-- Hack to fix category frames that only have 1 item in them
	if (totalHeight < 44) then
		categoryFrame.BgBottom:SetHeight(totalHeight - 2);
	else
		categoryFrame.BgBottom:SetHeight(46);
	end
	
	categoryFrame:SetHeight(totalHeight);
end

function PaperDollFrame_UpdateStats()
	local index = 1;
	while(_G["CharacterStatsPaneCategory"..index]) do
		PaperDollFrame_UpdateStatCategory(_G["CharacterStatsPaneCategory"..index]);
		index = index + 1;
	end
	PaperDollFrame_UpdateStatScrollChildHeight();
end

function PaperDollFrame_UpdateStatScrollChildHeight()
	local index = 1;
	local totalHeight = 0;
	while(_G["CharacterStatsPaneCategory"..index]) do
		if (_G["CharacterStatsPaneCategory"..index]:IsShown()) then
			totalHeight = totalHeight + _G["CharacterStatsPaneCategory"..index]:GetHeight() + STATCATEGORY_PADDING;
		end
		index = index + 1;
	end
	CharacterStatsPaneScrollChild:SetHeight(totalHeight+10-(CharacterStatsPane.initialOffsetY or 0));
end

function PaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage)
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, label));
	if ( isPercentage ) then
		text = format("%.2F%%", text);
	end
	_G[statFrame:GetName().."StatText"]:SetText(text);
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

function PaperDoll_FindCategoryById(id)
	for categoryName, category in pairs(PAPERDOLL_STATCATEGORIES) do
		if (category.id == id) then
			return categoryName;
		end
	end
	return nil;
end

function PaperDoll_InitStatCategories(defaultOrder, orderCVarName, collapsedCVarName, unit)
	local category;
	local order = defaultOrder;
	
	-- Load order from cvar
	if (orderCVarName) then
		local orderString = GetCVar(orderCVarName);
		local savedOrder = {};
		if (orderString and orderString ~= "") then
			 for i in gmatch(orderString, "%d+,?") do
				i = gsub(i, ",", "");
				i = tonumber(i);
				if (i) then
					local categoryName = PaperDoll_FindCategoryById(i);
					if (categoryName) then
						tinsert(savedOrder, categoryName);
					end
				end
			 end
			 
			-- Validate the saved order
			local valid = true;
			if (#savedOrder == #defaultOrder) then
				for i, category1 in next, defaultOrder do
					local found = false;
					for j, category2 in next, savedOrder do
						if (category1 == category2) then
							found = true;
							break;
						end
					end
					if (not found) then
						valid = false;
						break;
					end
				end
			else
				valid = false;
			end
			
			if (valid) then
				order = savedOrder;
			else
				SetCVar(orderCVarName, "");
			end
		end
	end
	
	-- Initialize stat frames
	table.wipe(StatCategoryFrames);
	for index=1, #order do
		local frame = _G["CharacterStatsPaneCategory"..index];
		assert(frame);
		tinsert(StatCategoryFrames, frame);
		frame.Category = order[index];
		frame:Show();
		
		-- Expand or collapse
		local categoryInfo = PAPERDOLL_STATCATEGORIES[frame.Category];
		if (categoryInfo and collapsedCVarName and GetCVarBitfield(collapsedCVarName, categoryInfo.id)) then
			PaperDollFrame_CollapseStatCategory(frame);
		else
			PaperDollFrame_ExpandStatCategory(frame);
		end
	end
	
	-- Hide unused stat frames
	local index = #order+1;
	while(_G["CharacterStatsPaneCategory"..index]) do
		_G["CharacterStatsPaneCategory"..index]:Hide();
		_G["CharacterStatsPaneCategory"..index].Category = nil;
		index = index + 1;
	end	
	
	-- Set up stats data
	CharacterStatsPane.defaultOrder = defaultOrder;
	CharacterStatsPane.orderCVarName = orderCVarName;
	CharacterStatsPane.collapsedCVarName = collapsedCVarName;
	CharacterStatsPane.unit = unit;
	
	-- Update
	PaperDoll_UpdateCategoryPositions();
	PaperDollFrame_UpdateStats();
end

function PaperDoll_SaveStatCategoryOrder()

	if (not CharacterStatsPane.orderCVarName) then
		return;
	end

	-- Check if the current order matches the default order
	if (CharacterStatsPane.defaultOrder and #CharacterStatsPane.defaultOrder == #StatCategoryFrames) then
		local same = true;
		for index=1, #StatCategoryFrames do
			if (StatCategoryFrames[index].Category ~= CharacterStatsPane.defaultOrder[index]) then
				same = false;
				break;
			end
		end
		if (same) then
			-- The same, set cvar to nothing
			SetCVar(CharacterStatsPane.orderCVarName, "");
			return;
		end
	end
		
	local cvarString = "";
	for index=1, #StatCategoryFrames do
		if (index ~= #StatCategoryFrames) then
			cvarString = cvarString..PAPERDOLL_STATCATEGORIES[StatCategoryFrames[index].Category].id..",";
		else
			cvarString = cvarString..PAPERDOLL_STATCATEGORIES[StatCategoryFrames[index].Category].id;
		end
	end
	SetCVar(CharacterStatsPane.orderCVarName, cvarString);
end

function PaperDoll_UpdateCategoryPositions()
	local prevFrame = nil;
	for index = 1, #StatCategoryFrames do
		local frame = StatCategoryFrames[index];
		frame:ClearAllPoints();
	end
	
	for index = 1, #StatCategoryFrames do
		local frame = StatCategoryFrames[index];
		
		-- Indent the one we are currently dragging
		local xOffset = 0;
		if (frame == MOVING_STAT_CATEGORY) then
			xOffset = STATCATEGORY_MOVING_INDENT;
		elseif (prevFrame and prevFrame == MOVING_STAT_CATEGORY) then
			xOffset = -STATCATEGORY_MOVING_INDENT;
		end
		
		if (prevFrame) then
			frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0+xOffset, -STATCATEGORY_PADDING);
		else
			frame:SetPoint("TOPLEFT", 1+xOffset, -STATCATEGORY_PADDING+(CharacterStatsPane.initialOffsetY or 0));
		end
		prevFrame = frame;
	end
end

function PaperDoll_MoveCategoryUp(self)
	for index = 2, #StatCategoryFrames do
		if (StatCategoryFrames[index] == self) then
			tremove(StatCategoryFrames, index);
			tinsert(StatCategoryFrames, index-1, self);
			break;
		end
	end
	
	PaperDoll_UpdateCategoryPositions();
	PaperDoll_SaveStatCategoryOrder();
end

function PaperDoll_MoveCategoryDown(self)
	for index = 1, #StatCategoryFrames-1 do
		if (StatCategoryFrames[index] == self) then
			tremove(StatCategoryFrames, index);
			tinsert(StatCategoryFrames, index+1, self);
			break;
		end
	end
	PaperDoll_UpdateCategoryPositions();
	PaperDoll_SaveStatCategoryOrder();
end

function PaperDollStatCategory_OnDragUpdate(self)
	local _, cursorY = GetCursorPosition();
	cursorY = cursorY*GetScreenHeightScale();
	
	local myIndex = nil;
	local insertIndex = nil;
	local closestPos;
	
	-- Find position that will put the dragged frame closest to the cursor
	for index=1, #StatCategoryFrames+1 do -- +1 is to check the very last position at the bottom
		if (StatCategoryFrames[index] == self) then
			myIndex = index;
		end

		local frameY;
		if (index <= #StatCategoryFrames) then
			frameY = StatCategoryFrames[index]:GetTop();
		else
			frameY = StatCategoryFrames[#StatCategoryFrames]:GetBottom();
		end
		frameY = frameY - 8;  -- compensate for height of the toolbar area
		if (myIndex and index > myIndex) then
			-- Remove height of the dragged frame, since it's going to be moved out of it's current position
			frameY = frameY + self:GetHeight();
		end
		if (not closestPos or abs(cursorY - frameY)<closestPos) then
			insertIndex = index;
			closestPos = abs(cursorY-frameY);
		end
	end
	
	if (insertIndex > myIndex) then
		insertIndex = insertIndex - 1;
	end
	
	if ( myIndex ~= insertIndex) then
		tremove(StatCategoryFrames, myIndex);
		tinsert(StatCategoryFrames, insertIndex, self);
		PaperDoll_UpdateCategoryPositions();
	end
end

function PaperDollStatCategory_OnDragStart(self)
	MOVING_STAT_CATEGORY = self;
	PaperDoll_UpdateCategoryPositions();
	GameTooltip:Hide();
	self:SetScript("OnUpdate", PaperDollStatCategory_OnDragUpdate);
	local i;
	local frame;
	for i, frame in next, StatCategoryFrames do
		if (frame ~= self) then
			frame:SetAlpha(0.6);
		end
	end
end

function PaperDollStatCategory_OnDragStop(self)
	MOVING_STAT_CATEGORY = nil;
	PaperDoll_UpdateCategoryPositions();
	self:SetScript("OnUpdate", nil);
	local i;
	local frame;
	for i, frame in next, StatCategoryFrames do
		if (frame ~= self) then
			frame:SetAlpha(1);
		end
	end
	PaperDoll_SaveStatCategoryOrder();
end

function PaperDollFrameItemFlyoutButton_OnClick (self)
	if ( self.location == EQUIPMENTFLYOUT_IGNORESLOT_LOCATION ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		local slot = EquipmentFlyoutFrame.button;
		EquipmentManagerIgnoreSlotForSave(slot:GetID());
		slot.ignored = true;
		PaperDollItemSlotButton_Update(slot);
		EquipmentFlyout_Show(slot);
		PaperDollEquipmentManagerPaneSaveSet:Enable();
	elseif ( self.location == EQUIPMENTFLYOUT_UNIGNORESLOT_LOCATION ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		local slot = EquipmentFlyoutFrame.button;
		EquipmentManagerUnignoreSlotForSave(slot:GetID());
		slot.ignored = nil;
		PaperDollItemSlotButton_Update(slot);
		EquipmentFlyout_Show(slot);
		PaperDollEquipmentManagerPaneSaveSet:Enable();
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
	if (PaperDollEquipmentManagerPane:IsShown() and (PaperDollEquipmentManagerPane.selectedSetName or GearManagerDialogPopup:IsShown())) then 
		if ( not itemSlotButton.ignored ) then
			tinsert(itemDisplayTable, 1, EQUIPMENTFLYOUT_IGNORESLOT_LOCATION);
		else
			tinsert(itemDisplayTable, 1, EQUIPMENTFLYOUT_UNIGNORESLOT_LOCATION);
		end
		numItems = numItems + 1;
	end
	if ( itemSlotButton.hasItem ) then
		tinsert(itemDisplayTable, 1, EQUIPMENTFLYOUT_PLACEINBAGS_LOCATION);
		numItems = numItems + 1;
	end
	return numItems;
end

function GearSetButton_OnClick (self, button, down)
	if ( self.name and self.name ~= "" ) then
		PlaySound("igMainMenuOptionCheckBoxOn");		-- inappropriately named, but a good sound.
		PaperDollEquipmentManagerPane.selectedSetName = self.name;
		-- mark the ignored slots
		PaperDollFrame_ClearIgnoredSlots();
		PaperDollFrame_IgnoreSlotsForSet(self.name);
		PaperDollEquipmentManagerPane_Update();
		GearManagerDialogPopup:Hide();
	else
		-- This is the "New Set" button
		GearManagerDialogPopup:Show();
		PaperDollEquipmentManagerPane.selectedSetName = nil;
		PaperDollFrame_ClearIgnoredSlots();
		PaperDollEquipmentManagerPane_Update();
		-- Ignore shirt and tabard by default
		PaperDollFrame_IgnoreSlot(4);
		PaperDollFrame_IgnoreSlot(19);
	end
	StaticPopup_Hide("CONFIRM_SAVE_EQUIPMENT_SET");
	StaticPopup_Hide("CONFIRM_OVERWRITE_EQUIPMENT_SET");
end

function GearSetButton_OnEnter (self)
	if ( self.name and self.name ~= "" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		GameTooltip:SetEquipmentSet(self.name);
	end
end

NUM_GEARSET_ICONS_SHOWN = 15;
NUM_GEARSET_ICONS_PER_ROW = 5;
NUM_GEARSET_ICON_ROWS = 3;
GEARSET_ICON_ROW_HEIGHT = 36;
local EM_ICON_FILENAMES = {};

function GearManagerDialogPopup_OnLoad (self)
	self.buttons = {};
	
	local rows = 0;
	
	local button = CreateFrame("CheckButton", "GearManagerDialogPopupButton1", GearManagerDialogPopup, "GearSetPopupButtonTemplate");
	button:SetPoint("TOPLEFT", 24, -85);
	button:SetID(1);
	tinsert(self.buttons, button);
	
	local lastPos;
	for i = 2, NUM_GEARSET_ICONS_SHOWN do
		button = CreateFrame("CheckButton", "GearManagerDialogPopupButton" .. i, GearManagerDialogPopup, "GearSetPopupButtonTemplate");
		button:SetID(i);
		
		lastPos = (i - 1) / NUM_GEARSET_ICONS_PER_ROW;
		if ( lastPos == math.floor(lastPos) ) then
			button:SetPoint("TOPLEFT", self.buttons[i-NUM_GEARSET_ICONS_PER_ROW], "BOTTOMLEFT", 0, -8);
		else
			button:SetPoint("TOPLEFT", self.buttons[i-1], "TOPRIGHT", 10, 0);
		end
		tinsert(self.buttons, button);
	end

	self.SetSelection = function(self, fTexture, Value)
		if(fTexture) then
			self.selectedTexture = Value;
			self.selectedIcon = nil;
		else
			self.selectedTexture = nil;
			self.selectedIcon = Value;
		end
	end
end

function GearManagerDialogPopup_OnShow (self)
	PlaySound("igCharacterInfoOpen");
	self.name = nil;
	self.isEdit = false;
	RecalculateGearManagerDialogPopup();
end

function GearManagerDialogPopup_OnHide (self)
	GearManagerDialogPopup.name = nil;
	GearManagerDialogPopup:SetSelection(true, nil);
	GearManagerDialogPopupEditBox:SetText("");
	if (not PaperDollEquipmentManagerPane.selectedSetName) then
		PaperDollFrame_ClearIgnoredSlots();
	end
	EM_ICON_FILENAMES = nil;
	collectgarbage();
end

function RecalculateGearManagerDialogPopup(setName, iconTexture)
	local popup = GearManagerDialogPopup;
	if ( setName and setName ~= "") then
		GearManagerDialogPopupEditBox:SetText(setName);
		GearManagerDialogPopupEditBox:HighlightText(0);
	else
		GearManagerDialogPopupEditBox:SetText("");
	end
	
	if (iconTexture) then
		popup:SetSelection(true, iconTexture);
	else
		popup:SetSelection(false, 1);
	end
	
	--[[ 
	Scroll and ensure that any selected equipment shows up in the list.
	When we first press "save", we want to make sure any selected equipment set shows up in the list, so that
	the user can just make his changes and press Okay to overwrite.
	To do this, we need to find the current set (by icon) and move the offset of the GearManagerDialogPopup
	to display it. Issue ID: 171220
	]]
	RefreshEquipmentSetIconInfo();
	local totalItems = #EM_ICON_FILENAMES;
	local texture, _;
	if(popup.selectedTexture) then
		local foundIndex = nil;
		for index=1, totalItems do
			texture = GetEquipmentSetIconInfo(index);
			if ( texture == popup.selectedTexture ) then
				foundIndex = index;
				break;
			end
		end
		if (foundIndex == nil) then

			foundIndex = 1;

		end
		-- now make it so we always display at least NUM_GEARSET_ICON_ROWS of data
		local offsetnumIcons = floor((totalItems-1)/NUM_GEARSET_ICONS_PER_ROW);
		local offset = floor((foundIndex-1) / NUM_GEARSET_ICONS_PER_ROW);
		offset = offset + min((NUM_GEARSET_ICON_ROWS-1), offsetnumIcons-offset) - (NUM_GEARSET_ICON_ROWS-1);
		if(foundIndex<=NUM_GEARSET_ICONS_SHOWN) then
			offset = 0;			--Equipment all shows at the same place.
		end
		FauxScrollFrame_OnVerticalScroll(GearManagerDialogPopupScrollFrame, offset*GEARSET_ICON_ROW_HEIGHT, GEARSET_ICON_ROW_HEIGHT, nil);
	else
		FauxScrollFrame_OnVerticalScroll(GearManagerDialogPopupScrollFrame, 0, GEARSET_ICON_ROW_HEIGHT, nil);
	end
	GearManagerDialogPopup_Update();
end

--[[
RefreshEquipmentSetIconInfo() counts how many uniquely textured inventory items the player has equipped. 
]]
function RefreshEquipmentSetIconInfo ()
	EM_ICON_FILENAMES = {};
	EM_ICON_FILENAMES[1] = "INV_MISC_QUESTIONMARK";
	local index = 2;

	for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local itemTexture = GetInventoryItemTexture("player", i);
		if ( itemTexture ) then
			EM_ICON_FILENAMES[index] = gsub( strupper(itemTexture), "INTERFACE\\ICONS\\", "" );
			if(EM_ICON_FILENAMES[index]) then
				index = index + 1;
				--[[
				Currently checks all for duplicates, even though only rings, trinkets, and weapons may be duplicated. 
				This version is clean and maintainable.
				]]
				for j=INVSLOT_FIRST_EQUIPPED, (index-1) do
					if(EM_ICON_FILENAMES[index] == EM_ICON_FILENAMES[j]) then
						EM_ICON_FILENAMES[index] = nil;
						index = index - 1;
						break;
					end
				end
			end
		end
	end
	GetLooseMacroItemIcons(EM_ICON_FILENAMES);
	GetLooseMacroIcons(EM_ICON_FILENAMES);
	GetMacroItemIcons(EM_ICON_FILENAMES);
	GetMacroIcons(EM_ICON_FILENAMES);
end


--[[ 
GetEquipmentSetIconInfo(index) determines the texture and real index of a regular index
	Input: 	index = index into a list of equipped items followed by the macro items. Only tricky part is the equipped items list keeps changing.
	Output: the associated texture for the item, and a index relative to the join point between the lists, i.e. negative for the equipped items
			and positive for the macro items//
]]
function GetEquipmentSetIconInfo(index)
	return EM_ICON_FILENAMES[index];

end

function GearManagerDialogPopup_Update ()
	RefreshEquipmentSetIconInfo();

	local popup = GearManagerDialogPopup;
	local buttons = popup.buttons;
	local offset = FauxScrollFrame_GetOffset(GearManagerDialogPopupScrollFrame) or 0;
	local button;	
	-- Icon list
	local texture, index, button, realIndex, _;
	for i=1, NUM_GEARSET_ICONS_SHOWN do
		local button = buttons[i];
		index = (offset * NUM_GEARSET_ICONS_PER_ROW) + i;
		if ( index <= #EM_ICON_FILENAMES ) then
			texture = GetEquipmentSetIconInfo(index);
			-- button.name:SetText(index); --dcw
			if(type(texture) == "number") then
				button.icon:SetToFileData(texture);
			else
				button.icon:SetTexture("INTERFACE\\ICONS\\"..texture);
			end	
			button:Show();
			if ( index == popup.selectedIcon ) then
				button:SetChecked(true);
			elseif ( texture == popup.selectedTexture ) then
				button:SetChecked(true);
				popup:SetSelection(false, index);
			else
				button:SetChecked(false);
			end
		else
			button.icon:SetTexture("");
			button:Hide();
		end
		
	end
	
	-- Scrollbar stuff
	FauxScrollFrame_Update(GearManagerDialogPopupScrollFrame, ceil(#EM_ICON_FILENAMES / NUM_GEARSET_ICONS_PER_ROW) , NUM_GEARSET_ICON_ROWS, GEARSET_ICON_ROW_HEIGHT );
end

function GearManagerDialogPopupOkay_Update ()
	local popup = GearManagerDialogPopup;
	local button = GearManagerDialogPopupOkay;
	
	if ( (popup.selectedIcon or popup.isEdit) and popup.name ) then
		button:Enable();
	else
		button:Disable();
	end
end

function GearManagerDialogPopupOkay_OnClick (self, button, pushed)
	local popup = GearManagerDialogPopup;
	local iconTexture = GetEquipmentSetIconInfo(popup.selectedIcon);

	if ( GetEquipmentSetInfoByName(popup.name) ) then	
		if (popup.isEdit and popup.name ~= popup.origName)  then
			-- Not allowed to overwrite an existing set by doing a rename
			UIErrorsFrame:AddMessage(EQUIPMENT_SETS_CANT_RENAME, 1.0, 0.1, 0.1, 1.0);
			return;
		elseif (not popup.isEdit) then
			local dialog = StaticPopup_Show("CONFIRM_OVERWRITE_EQUIPMENT_SET", popup.name);
			if ( dialog ) then
				dialog.data = popup.name;
				dialog.selectedIcon = GetEquipmentSetIconInfo(popup.selectedIcon);
			else
				UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
			end
			return;
		end
	elseif ( GetNumEquipmentSets() >= MAX_EQUIPMENT_SETS_PER_PLAYER and not popup.isEdit) then
		UIErrorsFrame:AddMessage(EQUIPMENT_SETS_TOO_MANY, 1.0, 0.1, 0.1, 1.0);
		return;
	end
	
	if (popup.isEdit) then
		--Modifying a set
		PaperDollEquipmentManagerPane.selectedSetName = popup.name;
		ModifyEquipmentSet(popup.origName, popup.name, iconTexture);
	else
		-- Saving a new set
		SaveEquipmentSet(popup.name, iconTexture);
	end
	popup:Hide();
end

function GearManagerDialogPopupCancel_OnClick ()
	GearManagerDialogPopup:Hide();
end

function GearSetPopupButton_OnClick (self, button)
	local popup = GearManagerDialogPopup;
	local offset = FauxScrollFrame_GetOffset(GearManagerDialogPopupScrollFrame) or 0;
	popup.selectedIcon = (offset * NUM_GEARSET_ICONS_PER_ROW) + self:GetID();
 	popup.selectedTexture = nil;
	GearManagerDialogPopup_Update();
	GearManagerDialogPopupOkay_Update();
end

function PaperDollEquipmentManagerPane_OnLoad(self)
	HybridScrollFrame_OnLoad(self);
	self.update = PaperDollEquipmentManagerPane_Update;	
	HybridScrollFrame_CreateButtons(self, "GearSetButtonTemplate", 2, -(self.EquipSet:GetHeight()+4));
	
	self:RegisterEvent("EQUIPMENT_SWAP_FINISHED");
	self:RegisterEvent("EQUIPMENT_SETS_CHANGED");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("BAG_UPDATE");
end

function PaperDollEquipmentManagerPane_OnUpdate(self)
	for i = 1, #self.buttons do
		local button = self.buttons[i];
		if (button:IsMouseOver()) then
			if (button.name) then
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
	if (self.queuedUpdate) then
		PaperDollEquipmentManagerPane_Update();
		self.queuedUpdate = false;
	end
end

function PaperDollEquipmentManagerPane_OnShow(self)
	PaperDollEquipmentManagerPane_Update();
	EquipmentFlyoutPopoutButton_ShowAll();
end

function PaperDollEquipmentManagerPane_OnEvent(self, event, ...)

	if ( event == "EQUIPMENT_SWAP_FINISHED" ) then
		local completed, setName = ...;
		if ( completed ) then
			PlaySoundKitID(1212); -- plays the equip sound for plate mail
			if (self:IsShown()) then
				self.selectedSetName = setName;
				PaperDollEquipmentManagerPane_Update();
			end
		end
	end


	if (self:IsShown()) then
		if ( event == "EQUIPMENT_SETS_CHANGED" ) then
			PaperDollEquipmentManagerPane_Update();
		elseif ( event == "PLAYER_EQUIPMENT_CHANGED" or event == "BAG_UPDATE" ) then
			-- This queues the update to only happen once at the end of the frame
			self.queuedUpdate = true;
		end
	end
end

function PaperDollEquipmentManagerPane_OnHide(self)
	EquipmentFlyoutPopoutButton_HideAll();
	PaperDollFrame_ClearIgnoredSlots();
	GearManagerDialogPopup:Hide();
	StaticPopup_Hide("CONFIRM_SAVE_EQUIPMENT_SET");
	StaticPopup_Hide("CONFIRM_OVERWRITE_EQUIPMENT_SET");
end

function PaperDollEquipmentManagerPane_Update()

	local _, setID, isEquipped = GetEquipmentSetInfoByName(PaperDollEquipmentManagerPane.selectedSetName or "");
	if (setID) then
		if (isEquipped) then
			PaperDollEquipmentManagerPaneSaveSet:Disable();
			PaperDollEquipmentManagerPaneEquipSet:Disable();
		else
			PaperDollEquipmentManagerPaneSaveSet:Enable();
			PaperDollEquipmentManagerPaneEquipSet:Enable();
		end
	else
		PaperDollEquipmentManagerPaneSaveSet:Disable();
		PaperDollEquipmentManagerPaneEquipSet:Disable();
		
		-- Clear selected equipment set if it doesn't exist
		if (PaperDollEquipmentManagerPane.selectedSetName) then
			PaperDollEquipmentManagerPane.selectedSetName = nil;
			PaperDollFrame_ClearIgnoredSlots();
		end
	end

	local numSets = GetNumEquipmentSets();
	local numRows = numSets;
	if (numSets < MAX_EQUIPMENT_SETS_PER_PLAYER) then
		numRows = numRows + 1;  -- "Add New Set" button
	end

	HybridScrollFrame_Update(PaperDollEquipmentManagerPane, numRows * EQUIPMENTSET_BUTTON_HEIGHT + PaperDollEquipmentManagerPaneEquipSet:GetHeight() + 20 , PaperDollEquipmentManagerPane:GetHeight());
	
	local scrollOffset = HybridScrollFrame_GetOffset(PaperDollEquipmentManagerPane);
	local buttons = PaperDollEquipmentManagerPane.buttons;
	local selectedName = PaperDollEquipmentManagerPane.selectedSetName;
	local name, texture, button, numLost;
	for i = 1, #buttons do
		if (i+scrollOffset <= numRows) then
			button = buttons[i];
			buttons[i]:Show();
			button:Enable();
			
			if (i+scrollOffset <= numSets) then
				-- Normal equipment set button
				name, texture, setID, isEquipped, _, _, _, numLost = GetEquipmentSetInfo(i+scrollOffset);
				button.name = name;
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
							
				if (selectedName and button.name == selectedName) then
					button.SelectedBar:Show();
				else
					button.SelectedBar:Hide();
				end
				
				if (isEquipped) then
					button.Check:Show();
				else
					button.Check:Hide();
				end
				button.icon:SetSize(36, 36);
				button.icon:SetPoint("LEFT", 4, 0);
			else
				-- This is the Add New button
				button.name = nil;
				button.text:SetText(PAPERDOLL_NEWEQUIPMENTSET);
				button.text:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				button.icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus");
				button.icon:SetSize(30, 30);
				button.icon:SetPoint("LEFT", 7, 0);
				button.Check:Hide();
				button.SelectedBar:Hide();
			end
			
			if ((i+scrollOffset) == 1) then
				buttons[i].BgTop:Show();
				buttons[i].BgMiddle:SetPoint("TOP", buttons[i].BgTop, "BOTTOM");
			else
				buttons[i].BgTop:Hide();
				buttons[i].BgMiddle:SetPoint("TOP");
			end
			
			if ((i+scrollOffset) == numRows) then
				buttons[i].BgBottom:Show();
				buttons[i].BgMiddle:SetPoint("BOTTOM", buttons[i].BgBottom, "TOP");
			else
				buttons[i].BgBottom:Hide();
				buttons[i].BgMiddle:SetPoint("BOTTOM");
			end
			
			if ((i+scrollOffset)%2 == 0) then
				buttons[i].Stripe:SetTexture(STRIPE_COLOR.r, STRIPE_COLOR.g, STRIPE_COLOR.b);
				buttons[i].Stripe:SetAlpha(0.1);
				buttons[i].Stripe:Show();
			else
				buttons[i].Stripe:Hide();
			end
		else
			buttons[i]:Hide();
		end
	end
end

function PaperDollEquipmentManagerPaneSaveSet_OnClick (self)
	local selectedSetName = PaperDollEquipmentManagerPane.selectedSetName
	if (selectedSetName and selectedSetName ~= "") then
		local dialog = StaticPopup_Show("CONFIRM_SAVE_EQUIPMENT_SET", selectedSetName);
		if ( dialog ) then
			dialog.data = selectedSetName;
		else
			UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
		end
	end
end

function PaperDollEquipmentManagerPaneEquipSet_OnClick (self)
	local selectedSetName = PaperDollEquipmentManagerPane.selectedSetName;
	if ( selectedSetName and selectedSetName ~= "") then
		PlaySound("igCharacterInfoTab");			-- inappropriately named, but a good sound.
		EquipmentManager_EquipSet(selectedSetName);
	end
end

function PaperDollTitlesPane_OnLoad(self)
	HybridScrollFrame_OnLoad(self);
	self.update = PaperDollTitlesPane_UpdateScrollFrame;	
	HybridScrollFrame_CreateButtons(self, "PlayerTitleButtonTemplate", 2, -4);
end

function PaperDollTitlesPane_UpdateScrollFrame()
	local buttons = PaperDollTitlesPane.buttons;
	local playerTitles = PaperDollTitlesPane.titles;
	local numButtons = #buttons;
	local scrollOffset = HybridScrollFrame_GetOffset(PaperDollTitlesPane);	
	local playerTitle;
	for i = 1, numButtons do
		playerTitle = playerTitles[i + scrollOffset];
		if ( playerTitle ) then
			buttons[i]:Show();
			buttons[i].text:SetText(playerTitle.name);
			buttons[i].titleId = playerTitle.id;
			if ( PaperDollTitlesPane.selected == playerTitle.id ) then
				buttons[i].Check:Show();
				buttons[i].SelectedBar:Show();
			else
				buttons[i].Check:Hide();
				buttons[i].SelectedBar:Hide();
			end
			
			if ((i+scrollOffset) == 1) then
				buttons[i].BgTop:Show();
				buttons[i].BgMiddle:SetPoint("TOP", buttons[i].BgTop, "BOTTOM");
			else
				buttons[i].BgTop:Hide();
				buttons[i].BgMiddle:SetPoint("TOP");
			end
			
			if ((i+scrollOffset) == #playerTitles) then
				buttons[i].BgBottom:Show();
				buttons[i].BgMiddle:SetPoint("BOTTOM", buttons[i].BgBottom, "TOP");
			else
				buttons[i].BgBottom:Hide();
				buttons[i].BgMiddle:SetPoint("BOTTOM");
			end
			
			if ((i+scrollOffset)%2 == 0) then
				buttons[i].Stripe:SetTexture(STRIPE_COLOR.r, STRIPE_COLOR.g, STRIPE_COLOR.b);
				buttons[i].Stripe:SetAlpha(0.1);
				buttons[i].Stripe:Show();
			else
				buttons[i].Stripe:Hide();
			end
		else
			buttons[i]:Hide();
		end
	end
end

local function PlayerTitleSort(a, b) return a.name < b.name; end 

function PaperDollTitlesPane_Update()
	local playerTitles = { };
	local currentTitle = GetCurrentTitle();		
	local titleCount = 1;
	local buttons = PaperDollTitlesPane.buttons;
	local fontstringText = buttons[1].text;
	local fontstringWidth;			
	local playerTitle = false;
	local tempName = 0;
	PaperDollTitlesPane.selected = -1;
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
				if ( i == currentTitle ) then
					PaperDollTitlesPane.selected = i;
				end					
				fontstringText:SetText(playerTitles[titleCount].name);
			end
		end
	end

	table.sort(playerTitles, PlayerTitleSort);
	playerTitles[1].name = PLAYER_TITLE_NONE;
	PaperDollTitlesPane.titles = playerTitles;	

	HybridScrollFrame_Update(PaperDollTitlesPane, titleCount * PLAYER_TITLE_HEIGHT + 20 , PaperDollTitlesPane:GetHeight());
	PaperDollTitlesPane_UpdateScrollFrame();
end

function PlayerTitleButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOff");
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
			if (_G[PAPERDOLL_SIDEBARS[i].frame]:IsShown()) then
				tab.Hider:Hide();
				tab.Highlight:Hide();
				tab.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.78906250, 0.95703125);
			else
				tab.Hider:Show();
				tab.Highlight:Show();
				tab.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.61328125, 0.78125000);
			end
		end
	end
end

function PaperDollFrame_SetSidebar(self, index)
	if (not _G[PAPERDOLL_SIDEBARS[index].frame]:IsShown()) then
		for i = 1, #PAPERDOLL_SIDEBARS do
			_G[PAPERDOLL_SIDEBARS[i].frame]:Hide();
		end
		_G[PAPERDOLL_SIDEBARS[index].frame]:Show();
		PaperDollFrame.currentSideBar = _G[PAPERDOLL_SIDEBARS[index].frame];
		PlaySound("igMainMenuOptionCheckBoxOff");
		PaperDollFrame_UpdateSidebarTabs();
	end
end
