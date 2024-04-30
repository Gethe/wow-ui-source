EQUIPPED_FIRST = 1;
EQUIPPED_LAST = 19;

NUM_RESISTANCE_TYPES = 5;
NUM_STATS = 5;
MAX_SPELL_SCHOOLS = 7;

CR_WEAPON_SKILL = 1;
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
CR_STURDINESS = 22;
CR_UNUSED_7 = 23;
CR_EXPERTISE = 24;
CR_ARMOR_PENETRATION = 25;
CR_MASTERY = 26;

ATTACK_POWER_MAGIC_NUMBER = 14;
BLOCK_PER_STRENGTH = 0.5;
MANA_PER_INTELLECT = 15;
BASE_MOVEMENT_SPEED = 7;

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
local VERTICAL_FLYOUTS = { [16] = true, [17] = true, [18] = true }

local itemSlotButtons = {};

local STATCATEGORY_PADDING = 4;
local STATCATEGORY_MOVING_INDENT = 4;

MOVING_STAT_CATEGORY = nil;

local StatCategoryFrames = {};

local STRIPE_COLOR = {r=0.9, g=0.9, b=1};

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
	["DRUIDMANA"] = {
		-- Only appears for Druids when in shapeshift form
		updateFunc = function(statFrame, unit) PaperDollFrame_SetDruidMana(statFrame, unit); end
	},
	["MASTERY"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetMastery(statFrame, unit); end
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
	["SPIRIT"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_SPIRIT); end 
	},
	
	-- Melee
	["MELEE_DAMAGE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetDamage(statFrame, unit); end
	},
	["MELEE_DPS"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetMeleeDPS(statFrame, unit); end
	},
	["MELEE_AP"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetAttackPower(statFrame, unit); end
	},
	["MELEE_ATTACKSPEED"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetAttackSpeed(statFrame, unit); end
	},
	["HASTE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetMeleeHaste(statFrame, unit); end
	},
	["HITCHANCE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetMeleeHitChance(statFrame, unit); end
	}, 
	["CRITCHANCE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetMeleeCritChance(statFrame, unit); end
	},
	["EXPERTISE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetExpertise(statFrame, unit); end
	}, 
	["ENERGY_REGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetEnergyRegen(statFrame, unit); end
	},
	["RUNE_REGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetRuneRegen(statFrame, unit); end
	},
	
	-- Ranged
	["RANGED_DAMAGE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetRangedDamage(statFrame, unit); end
	},
	["RANGED_DPS"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetRangedDPS(statFrame, unit); end
	},
	["RANGED_AP"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetRangedAttackPower(statFrame, unit); end
	},
	["RANGED_ATTACKSPEED"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetRangedAttackSpeed(statFrame, unit); end
	},
	["RANGED_CRITCHANCE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetRangedCritChance(statFrame, unit); end
	},
	["RANGED_HITCHANCE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetRangedHitChance(statFrame, unit); end
	}, 
	["RANGED_HASTE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetRangedHaste(statFrame, unit); end
	},
	["FOCUS_REGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetFocusRegen(statFrame, unit); end
	},
	
	-- Spell
	["SPELLDAMAGE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellBonusDamage(statFrame, unit); end
	},
	["SPELLHEALING"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellBonusHealing(statFrame, unit); end
	},
	["SPELL_HASTE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellHaste(statFrame, unit); end
	},
	["SPELL_HITCHANCE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellHitChance(statFrame, unit); end
	},
	["SPELL_PENETRATION"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellPenetration(statFrame, unit); end
	},
	["MANAREGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetManaRegen(statFrame, unit); end
	},
	["COMBATMANAREGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetCombatManaRegen(statFrame, unit); end
	},
	["SPELLCRIT"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellCritChance(statFrame, unit); end
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
	["RESILIENCE_REDUCTION"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetResilience(statFrame, unit); end
	},
	["RESILIENCE_CRIT"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetResilience(statFrame, unit); end
	},
	
	-- Resistance
	["ARCANE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetResistance(statFrame, unit, 6); end
	},
	["FIRE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetResistance(statFrame, unit, 2); end
	},
	["FROST"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetResistance(statFrame, unit, 3); end
	},
	["NATURE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetResistance(statFrame, unit, 4); end
	},
	["SHADOW"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetResistance(statFrame, unit, 5); end
	},
};

-- Warning: Avoid changing the IDs, since this will screw up the cvars that remember which categories a player has collapsed
PAPERDOLL_STATCATEGORIES = {
	["GENERAL"] = {
			id = 1,
			stats = { 
				"HEALTH",
				"DRUIDMANA",  -- Only appears for Druids when in bear/cat form
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
				"STAMINA",
				"INTELLECT",
				"SPIRIT"
			}
	},
					
	["MELEE"] = {
			id = 3,
			stats = {
				"MELEE_DAMAGE", 
				"MELEE_DPS", 
				"MELEE_AP", 
				"MELEE_ATTACKSPEED", 
				"HASTE", 
				"ENERGY_REGEN",
				"RUNE_REGEN",
				"HITCHANCE", 
				"CRITCHANCE", 
				"EXPERTISE", 
				"MASTERY",
			}
	},
				
	["RANGED"] = {
			id = 4,
			stats = {
				"RANGED_DAMAGE", 
				"RANGED_DPS", 
				"RANGED_AP", 
				"RANGED_ATTACKSPEED", 
				"RANGED_HASTE",
				"FOCUS_REGEN",
				"RANGED_HITCHANCE",
				"RANGED_CRITCHANCE", 
				"MASTERY",
			}
	},
				
	["SPELL"] = {
			id = 5,
			stats = {
				"SPELLDAMAGE",    -- If Damage and Healing are the same, this changes to Spell Power
				"SPELLHEALING",    -- If Damage and Healing are the same, this is hidden
				"SPELL_HASTE", 
				"SPELL_HITCHANCE",
				"SPELL_PENETRATION",
				"MANAREGEN",
				"COMBATMANAREGEN",
				"SPELLCRIT",
				"MASTERY",
			}
	},
			
	["DEFENSE"] = {
			id = 6,
			stats = {
				"ARMOR", 
				"DODGE",
				"PARRY", 
				"BLOCK",
				"RESILIENCE_REDUCTION", 
				--"RESILIENCE_CRIT",
			}
	},

	["RESISTANCE"] = {
			id = 7,
			stats = {
				"ARCANE", 
				"FIRE", 
				"FROST", 
				"NATURE", 
				"SHADOW",
			}
	},
};

PAPERDOLL_STATCATEGORY_DEFAULTORDER = {
	"GENERAL",
	"ATTRIBUTES",
	"MELEE",
	"RANGED",
	"SPELL",
	"DEFENSE",
	"RESISTANCE",
};

BASE_MISS_CHANCE_PHYSICAL = {
	[0] = 5.0;
	[1] = 5.5;
	[2] = 6.0;
	[3] = 8.0;
};

BASE_MISS_CHANCE_SPELL = {
	[0] = 4.0;
	[1] = 5.0;
	[2] = 6.0;
	[3] = 17.0;
};

BASE_ENEMY_DODGE_CHANCE = {
	[0] = 5.0;
	[1] = 5.5;
	[2] = 6.0;
	[3] = 6.5;
};

BASE_ENEMY_PARRY_CHANCE = {
	[0] = 5.0;
	[1] = 5.5;
	[2] = 6.0;
	[3] = 14.0;
};

DUAL_WIELD_HIT_PENALTY = 19.0;

function PaperDollFrame_OnLoad (self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED");
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_RESISTANCES");
	self:RegisterEvent("UNIT_STATS");
	self:RegisterEvent("UNIT_DAMAGE");
	self:RegisterEvent("UNIT_RANGEDDAMAGE");
	self:RegisterEvent("UNIT_ATTACK_SPEED");
	self:RegisterEvent("UNIT_ATTACK_POWER");
	self:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
	self:RegisterEvent("UNIT_ATTACK");
	self:RegisterEvent("UNIT_SPELL_HASTE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("COMBAT_RATING_UPDATE");
	self:RegisterEvent("MASTERY_UPDATE");
	self:RegisterEvent("KNOWN_TITLES_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE");
	self:RegisterEvent("PLAYER_DAMAGE_DONE_MODS");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self:RegisterEvent("UNIT_MAXHEALTH");
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
		elseif ( event == "UNIT_DAMAGE" or event == "UNIT_ATTACK_SPEED" or event == "UNIT_RANGEDDAMAGE" or event == "UNIT_ATTACK" or event == "UNIT_STATS" or event == "UNIT_RANGED_ATTACK_POWER" or event == "UNIT_RESISTANCES" or event == "UNIT_SPELL_HASTE" or event == "UNIT_MAXHEALTH" ) then
			self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
		end
	end
	
	if ( event == "COMBAT_RATING_UPDATE" or event=="MASTERY_UPDATE" or event == "BAG_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYERBANKSLOTS_CHANGED" or event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" or event == "PLAYER_DAMAGE_DONE_MODS") then
		self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
	elseif (event == "VARIABLES_LOADED") then
		if (GetCVar("characterFrameCollapsed") ~= "0") then
			CharacterFrame:Collapse();
		else
			CharacterFrame:Expand();
		end
		
		local activeSpec = GetActiveTalentGroup();
		if (activeSpec == 1) then
			PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, "statCategoryOrder", "statCategoriesCollapsed", "player");
		else
			PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, "statCategoryOrder_2", "statCategoriesCollapsed_2", "player");
		end
	elseif (event == "PLAYER_TALENT_UPDATE") then
		PaperDollFrame_SetLevel();
		self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
	elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then
		PaperDollFrame_UpdateStats();
	end
end

function PaperDollFrame_SetLevel()
	local primaryTalentTree = GetPrimaryTalentTree();
	local classDisplayName, class = UnitClass("player"); 
	local classColor = RAID_CLASS_COLORS[class];
	local classColorString = format("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255);
	local specName, _;
	
	if (primaryTalentTree) then
		_, specName = GetTalentTabInfo(primaryTalentTree);
	end
	
	if (specName and specName ~= "") then
		CharacterLevelText:SetFormattedText(PLAYER_LEVEL, UnitLevel("player"), classColorString, specName, classDisplayName);
	else
		CharacterLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, UnitLevel("player"), classColorString, classDisplayName);
	end
	
	-- Hack: if the string is very long, move it a bit so that it has more room (although it will no longer be centered)
	if (CharacterLevelText:GetWidth() > 210) then
		if (CharacterFrameInsetRight:IsVisible()) then
			CharacterLevelText:SetPoint("TOP", -10, -36);
		else
			CharacterLevelText:SetPoint("TOP", 10, -36);
		end
	else
		CharacterLevelText:SetPoint("TOP", 0, -36);
	end
	
	if IsTrialAccount() then
		local rLevel = GetRestrictedAccountData();
		if UnitLevel("player") >= rLevel then
			CharacterTrialLevelErrorText:Show();
		end
	end
end

function GetMeleeMissChance(levelOffset, special)
	if (levelOffset < 0 or levelOffset > 3) then
		return 0;
	end
	local chance = BASE_MISS_CHANCE_PHYSICAL[levelOffset];
	chance = chance - GetCombatRatingBonus(CR_HIT_MELEE) - GetHitModifier();
	if (IsDualWielding() and not special) then
		chance = chance + DUAL_WIELD_HIT_PENALTY;
	end
	if (chance < 0) then
		chance = 0;
	elseif (chance > 100) then
		chance = 100;
	end
	return chance;
end

function GetRangedMissChance(levelOffset, special)
	if (levelOffset < 0 or levelOffset > 3) then
		return 0;
	end
	local chance = BASE_MISS_CHANCE_PHYSICAL[levelOffset];
	chance = chance - GetCombatRatingBonus(CR_HIT_RANGED) - GetHitModifier();
	if (chance < 0) then
		chance = 0;
	elseif (chance > 100) then
		chance = 100;
	end
	return chance;
end

function GetSpellMissChance(levelOffset, special)
	if (levelOffset < 0 or levelOffset > 3) then
		return 0;
	end
	local chance = BASE_MISS_CHANCE_SPELL[levelOffset];
	chance = chance - GetCombatRatingBonus(CR_HIT_SPELL) - GetSpellHitModifier();
	if (chance < 0) then
		chance = 0;
	elseif (chance > 100) then
		chance = 100;
	end
	return chance;
end

function GetEnemyDodgeChance(levelOffset)
	if (levelOffset < 0 or levelOffset > 3) then
		return 0;
	end
	local chance = BASE_ENEMY_DODGE_CHANCE[levelOffset];
	local offhandChance = BASE_ENEMY_DODGE_CHANCE[levelOffset];
	local expertisePct, offhandExpertisePct = GetExpertisePercent();
	chance = chance - expertisePct;
	offhandChance = offhandChance - offhandExpertisePct;
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
	return chance, offhandChance;
end

function GetEnemyParryChance(levelOffset)
	if (levelOffset < 0 or levelOffset > 3) then
		return 0;
	end
	local chance = BASE_ENEMY_PARRY_CHANCE[levelOffset];
	local offhandChance = BASE_ENEMY_PARRY_CHANCE[levelOffset];
	local expertisePct, offhandExpertisePct = GetExpertisePercent();
	chance = chance - expertisePct;
	offhandChance = offhandChance - offhandExpertisePct;
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

function PaperDollFrame_SetDruidMana(statFrame, unit)
	if (not unit) then
		unit = "player";
	end
	local _, class = UnitClass(unit);
	if (class ~= "DRUID") then
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
	local label = _G[statFrame:GetName().."Label"];
	local text = _G[statFrame:GetName().."StatText"];
	local stat;
	local effectiveStat;
	local posBuff;
	local negBuff;
	stat, effectiveStat, posBuff, negBuff = UnitStat(unit, statIndex);
	local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
	label:SetText(format(STAT_FORMAT, statName));
	
	-- Set the tooltip text
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." ";

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		text:SetText(effectiveStat);
		statFrame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE;
	else 
		tooltipText = tooltipText..effectiveStat;
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
		statFrame.tooltip = tooltipText;

		-- If there are any negative buffs then show the main number in red even if there are
		-- positive buffs. Otherwise show in green.
		if ( negBuff < 0 ) then
			text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
		else
			text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
		end
	end
	statFrame.tooltip2 = _G["DEFAULT_STAT"..statIndex.."_TOOLTIP"];
	
	if (unit == "player") then
		local _, unitClass = UnitClass("player");
		unitClass = strupper(unitClass);
		
		if ( statIndex == LE_UNIT_STAT_STRENGTH ) then
			local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
			statFrame.tooltip2 = format(statFrame.tooltip2, attackPower);
		elseif ( statIndex == LE_UNIT_STAT_AGILITY ) then
			local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
			if ( attackPower > 0 ) then
				statFrame.tooltip2 = format(STAT_TOOLTIP_BONUS_AP, attackPower) .. format(statFrame.tooltip2, GetCritChanceFromAgility("player"));
			else
				statFrame.tooltip2 = format(statFrame.tooltip2, GetCritChanceFromAgility("player"));
			end
		elseif ( statIndex == LE_UNIT_STAT_STAMINA ) then
			local baseStam = min(20, effectiveStat);
			local moreStam = effectiveStat - baseStam;
			statFrame.tooltip2 = format(statFrame.tooltip2, (baseStam + (moreStam*UnitHPPerStamina("player")))*GetUnitMaxHealthModifier("player"));
		elseif ( statIndex == LE_UNIT_STAT_INTELLECT ) then
			if ( UnitHasMana("player") ) then
				local baseInt = min(20, effectiveStat);
				local moreInt = effectiveStat - baseInt
				if (GetOverrideSpellPowerByAP() > 0) then
					statFrame.tooltip2 = format(STAT4_NOSPELLPOWER_TOOLTIP, baseInt + moreInt*MANA_PER_INTELLECT, GetSpellCritChanceFromIntellect("player"));
				else
					statFrame.tooltip2 = format(statFrame.tooltip2, baseInt + moreInt*MANA_PER_INTELLECT, max(0, effectiveStat-10), GetSpellCritChanceFromIntellect("player"));
				end
			else
				statFrame.tooltip2 = STAT_USELESS_TOOLTIP;
			end
		elseif ( statIndex == LE_UNIT_STAT_SPIRIT ) then
			-- All mana regen stats are displayed as mana/5 sec.
			if ( UnitHasMana("player") ) then
				local regen = GetUnitManaRegenRateFromSpirit("player");
				regen = floor( regen * 5.0 );
				statFrame.tooltip2 = format(MANA_REGEN_FROM_SPIRIT, regen);
			else
				statFrame.tooltip2 = STAT_USELESS_TOOLTIP;
			end
		end
	elseif (unit == "pet") then
		if ( statIndex == LE_UNIT_STAT_STRENGTH ) then
			local attackPower = effectiveStat-20;
			statFrame.tooltip2 = format(statFrame.tooltip2, attackPower);
		elseif ( statIndex == LE_UNIT_STAT_AGILITY ) then
			statFrame.tooltip2 = format(statFrame.tooltip2, GetCritChanceFromAgility("pet"));
		elseif ( statIndex == LE_UNIT_STAT_STAMINA ) then
			local expectedHealthGain = (((stat - posBuff - negBuff)-20)*10+20)*GetUnitHealthModifier("pet");
			local realHealthGain = ((effectiveStat-20)*10+20)*GetUnitHealthModifier("pet");
			local healthGain = (realHealthGain - expectedHealthGain)*GetUnitMaxHealthModifier("pet");
			statFrame.tooltip2 = format(statFrame.tooltip2, healthGain);
		elseif ( statIndex == LE_UNIT_STAT_INTELLECT ) then
			if ( UnitHasMana("pet") ) then
				local manaGain = ((effectiveStat-20)*15+20)*GetUnitPowerModifier("pet");
				statFrame.tooltip2 = format(statFrame.tooltip2, manaGain, max(0, effectiveStat-10), GetSpellCritChanceFromIntellect("pet"));
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

function PaperDollFrame_SetResistance(statFrame, unit, resistanceIndex)
	local base, resistance, positive, negative = UnitResistance(unit, resistanceIndex);
	local resistanceNameShort = _G["SPELL_SCHOOL"..resistanceIndex.."_CAP"];
	local resistanceName = _G["RESISTANCE"..resistanceIndex.."_NAME"];
	local resistanceIconCode = "|TInterface\\PaperDollInfoFrame\\SpellSchoolIcon"..(resistanceIndex+1)..":0|t";
	_G[statFrame:GetName().."Label"]:SetText(resistanceIconCode.." "..format(STAT_FORMAT, resistanceNameShort));
	local text = _G[statFrame:GetName().."StatText"];
	PaperDollFormatStat(resistanceName, base, positive, negative, statFrame, text);
	statFrame.tooltip = resistanceIconCode.." "..HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, resistanceName).." "..resistance..FONT_COLOR_CODE_CLOSE;
	
	if ( positive ~= 0 or negative ~= 0 ) then
		statFrame.tooltip = statFrame.tooltip.. " ( "..HIGHLIGHT_FONT_COLOR_CODE..base;
		if( positive > 0 ) then
			statFrame.tooltip = statFrame.tooltip..GREEN_FONT_COLOR_CODE.." +"..positive;
		end
		if( negative < 0 ) then
			statFrame.tooltip = statFrame.tooltip.." "..RED_FONT_COLOR_CODE..negative;
		end
		statFrame.tooltip = statFrame.tooltip..FONT_COLOR_CODE_CLOSE.." )";
	end
	
	statFrame.tooltip2 = format(RESISTANCE_TOOLTIP_SUBTEXT, _G["SPELL_SCHOOL"..resistanceIndex.."_CAP"], ResistancePercent(resistance, UnitLevel(unit)));
end

function PaperDollFrame_SetArmor(statFrame, unit)
	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor(unit);
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, ARMOR));
	local text = _G[statFrame:GetName().."StatText"];

	PaperDollFormatStat(ARMOR, base, posBuff, negBuff, statFrame, text);
	local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitLevel(unit));
	statFrame.tooltip2 = format(DEFAULT_STATARMOR_TOOLTIP, armorReduction);
	
	if ( unit == "player" ) then
		local petBonus = ComputePetBonus("PET_BONUS_ARMOR", effectiveArmor );
		if( petBonus > 0 ) then
			statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_ARMOR, petBonus);
		end
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
	statFrame.tooltip2 = format(CR_BLOCK_TOOLTIP, GetCombatRating(CR_BLOCK), GetCombatRatingBonus(CR_BLOCK), GetShieldBlock());
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

	local resilienceRating = GetCombatRating(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN);
	local resilienceRatingText = BreakUpLargeNumbers(resilienceRating);
	local ratingBonus = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_RESILIENCE, resilienceRatingText, false, resilienceRating);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_RESILIENCE).." "..resilienceRatingText..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(RESILIENCE_TOOLTIP, 
								ratingBonus);
	statFrame:Show();
end

function PaperDollFrame_SetDamage(statFrame, unit)
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, DAMAGE));
	local text = _G[statFrame:GetName().."StatText"];
	local speed, offhandSpeed = UnitAttackSpeed(unit);
	
	local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage(unit);

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
	local damagePerSecond = (max(fullDamage,1) / speed);
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
	statFrame.dps = damagePerSecond;
	statFrame.unit = unit;
	
	-- If there's an offhand speed then add the offhand info to the tooltip
	if ( offhandSpeed and minOffHandDamage and maxOffHandDamage ) then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed);
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
		statFrame.offhandDps = offhandDamagePerSecond;
	else
		statFrame.offhandAttackSpeed = nil;
	end
	
	statFrame:SetScript("OnEnter", CharacterDamageFrame_OnEnter);
	
	statFrame:Show();
end

function PaperDollFrame_SetMeleeDPS(statFrame, unit)
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_DPS_SHORT));
	local text = _G[statFrame:GetName().."StatText"];
	local speed, offhandSpeed = UnitAttackSpeed(unit);
	
	local minDamage;
	local maxDamage; 
	local minOffHandDamage;
	local maxOffHandDamage; 
	local physicalBonusPos;
	local physicalBonusNeg;
	local percent;
	minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage(unit);
	local displayMin = max(floor(minDamage),1);
	local displayMax = max(ceil(maxDamage),1);

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local totalBonus = (fullDamage - baseDamage);
	local damagePerSecond = (max(fullDamage,1) / speed);
	local damageTooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
	
	local colorPos = "|cff20ff20";
	local colorNeg = "|cffff2020";
	local text;

	-- epsilon check
	if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
		totalBonus = 0.0;
	end

	if ( totalBonus == 0 ) then
		text = format("%.1F", damagePerSecond);
	else
		local color;
		if ( totalBonus > 0 ) then
			color = colorPos;
		else
			color = colorNeg;
		end
		text = color..format("%.1F", damagePerSecond).."|r";
	end
	
	-- If there's an offhand speed then add the offhand info
	if ( offhandSpeed ) then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed);
		local offhandTotalBonus = (offhandFullDamage - offhandBaseDamage);
		
		-- epsilon check
		if ( offhandTotalBonus < 0.1 and offhandTotalBonus > -0.1 ) then
			offhandTotalBonus = 0.0;
		end
		local separator = " / ";
		if (damagePerSecond > 1000 and offhandDamagePerSecond > 1000) then
			separator = "/";
		end
		if ( offhandTotalBonus == 0 ) then
			text = text..separator..format("%.1F", offhandDamagePerSecond);
		else
			local color;
			if ( offhandTotalBonus > 0 ) then
				color = colorPos;
			else
				color = colorNeg;
			end
			text = text..separator..color..format("%.1F", offhandDamagePerSecond).."|r";	
		end
	end
	
	statFrame.Value:SetText(text);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..DAMAGE_PER_SECOND..FONT_COLOR_CODE_CLOSE;
	statFrame:Show();
end

function PaperDollFrame_SetRangedDPS(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_DPS_SHORT));
	local text = _G[statFrame:GetName().."StatText"];

	-- If no ranged attack then set to n/a
	local hasRelic = UnitHasRelicSlot(unit);	
	local rangedTexture = GetInventoryItemTexture("player", 18);
	if ( rangedTexture and not hasRelic ) then
		PaperDollFrame.noRanged = nil;
	else
		text:SetText(NOT_APPLICABLE);
		PaperDollFrame.noRanged = 1;
		statFrame.damage = nil;
		return;
	end

	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage(unit);
	
	-- Round to the third decimal place (i.e. 99.9 percent)
	percent = math.floor(percent  * 10^3 + 0.5) / 10^3
	local displayMin = max(floor(minDamage),1);
	local displayMax = max(ceil(maxDamage),1);

	local baseDamage;
	local fullDamage;
	local totalBonus;
	local damagePerSecond;
	local tooltip;

	if ( HasWandEquipped() ) then
		baseDamage = (minDamage + maxDamage) * 0.5;
		fullDamage = baseDamage * percent;
		totalBonus = 0;
		if( rangedAttackSpeed == 0 ) then
			damagePerSecond = 0;
		else
			damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
		end
		tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
	else
		minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

		baseDamage = (minDamage + maxDamage) * 0.5;
		fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		totalBonus = (fullDamage - baseDamage);
		if( rangedAttackSpeed == 0 ) then
			damagePerSecond = 0;
		else
			damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
		end
		tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
	end

	if ( totalBonus == 0 ) then
		text:SetText( format("%.1F", damagePerSecond));
	else
		local colorPos = "|cff20ff20";
		local colorNeg = "|cffff2020";
		local color;
		if ( totalBonus > 0 ) then
			color = colorPos;
		else
			color = colorNeg;
		end
		text:SetText(color..format("%.1F", damagePerSecond).."|r");
		if ( physicalBonusPos > 0 ) then
			tooltip = tooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			tooltip = tooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			tooltip = tooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			tooltip = tooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
		--statFrame.tooltip2 = tooltip.." "..format(DPS_TEMPLATE, damagePerSecond);
	end

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..DAMAGE_PER_SECOND..FONT_COLOR_CODE_CLOSE;
	statFrame:Show();
end

function PaperDollFrame_SetAttackSpeed(statFrame, unit)
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
	
	statFrame:Show();
end

function PaperDollFrame_SetAttackPower(statFrame, unit)
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_ATTACK_POWER));
	local text = _G[statFrame:GetName().."StatText"];
	local base, posBuff, negBuff = UnitAttackPower(unit);

	PaperDollFormatStat(MELEE_ATTACK_POWER, base, posBuff, negBuff, statFrame, text);
	local damageBonus = max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER;
	local effectiveAP = max(0,base + posBuff + negBuff);
	if (GetOverrideSpellPowerByAP() > 0) then
		statFrame.tooltip2 = format(MELEE_ATTACK_POWER_SPELL_POWER_TOOLTIP, damageBonus, effectiveAP * GetOverrideSpellPowerByAP() + 0.5);
	else
		statFrame.tooltip2 = format(MELEE_ATTACK_POWER_TOOLTIP, damageBonus);
	end
	statFrame:Show();
end

function PaperDollFrame_SetRangedAttack(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local hasRelic = UnitHasRelicSlot(unit);
	local rangedAttackBase, rangedAttackMod = UnitRangedAttack(unit);
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, COMBAT_RATING_NAME1));
	local text = _G[statFrame:GetName().."StatText"];

	-- If no ranged texture then set stats to n/a
	local rangedTexture = GetInventoryItemTexture("player", 18);
	if ( rangedTexture and not hasRelic ) then
		PaperDollFrame.noRanged = nil;
	else
		text:SetText(NOT_APPLICABLE);
		PaperDollFrame.noRanged = 1;
		statFrame.tooltip = nil;
		return;
	end
	
	if( rangedAttackMod == 0 ) then
		text:SetText(rangedAttackBase);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, COMBAT_RATING_NAME1).." "..rangedAttackBase..FONT_COLOR_CODE_CLOSE;
	else
		local color = RED_FONT_COLOR_CODE;
		if( rangedAttackMod > 0 ) then
	  		color = GREEN_FONT_COLOR_CODE;
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, COMBAT_RATING_NAME1).." "..(rangedAttackBase + rangedAttackMod).." ("..rangedAttackBase..color.." +"..rangedAttackMod..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")";
		else
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, COMBAT_RATING_NAME1).." "..(rangedAttackBase + rangedAttackMod).." ("..rangedAttackBase..color.." "..rangedAttackMod..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")";
		end
		text:SetText(color..(rangedAttackBase + rangedAttackMod)..FONT_COLOR_CODE_CLOSE);
	end
	local total = GetCombatRating(CR_WEAPON_SKILL) + GetCombatRating(CR_WEAPON_SKILL_RANGED);
	statFrame.tooltip2 = format(WEAPON_SKILL_RATING, total);
	if ( total > 0 ) then
		statFrame.tooltip2 = statFrame.tooltip2..format(WEAPON_SKILL_RATING_BONUS, GetCombatRatingBonus(CR_WEAPON_SKILL) + GetCombatRatingBonus(CR_WEAPON_SKILL_RANGED));
	end
	statFrame:Show();
end

function PaperDollFrame_SetRangedDamage(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, DAMAGE));
	local text = _G[statFrame:GetName().."StatText"];

	-- If no ranged attack then set to n/a
	local hasRelic = UnitHasRelicSlot(unit);	
	local rangedTexture = GetInventoryItemTexture("player", 18);
	if ( rangedTexture and not hasRelic ) then
		PaperDollFrame.noRanged = nil;
	else
		text:SetText(NOT_APPLICABLE);
		PaperDollFrame.noRanged = 1;
		statFrame.damage = nil;
		return;
	end

	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage(unit);
	
	-- Round to the third decimal place (i.e. 99.9 percent)
	percent = math.floor(percent  * 10^3 + 0.5) / 10^3
	local displayMin = max(floor(minDamage),1);
	local displayMax = max(ceil(maxDamage),1);

	local baseDamage;
	local fullDamage;
	local totalBonus;
	local damagePerSecond;
	local tooltip;

	if ( HasWandEquipped() ) then
		baseDamage = (minDamage + maxDamage) * 0.5;
		fullDamage = baseDamage * percent;
		totalBonus = 0;
		if( rangedAttackSpeed == 0 ) then
			damagePerSecond = 0;
		else
			damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
		end
		tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
	else
		minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

		baseDamage = (minDamage + maxDamage) * 0.5;
		fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		totalBonus = (fullDamage - baseDamage);
		if( rangedAttackSpeed == 0 ) then
			damagePerSecond = 0;
		else
			damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
		end
		tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
	end

	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			text:SetText(displayMin.." - "..displayMax);	
		else
			text:SetText(displayMin.."-"..displayMax);
		end
	else
		local colorPos = "|cff20ff20";
		local colorNeg = "|cffff2020";
		local color;
		if ( totalBonus > 0 ) then
			color = colorPos;
		else
			color = colorNeg;
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			text:SetText(color..displayMin.." - "..displayMax.."|r");	
		else
			text:SetText(color..displayMin.."-"..displayMax.."|r");
		end
		if ( physicalBonusPos > 0 ) then
			tooltip = tooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			tooltip = tooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			tooltip = tooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			tooltip = tooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
		statFrame.tooltip = tooltip.." "..format(DPS_TEMPLATE, damagePerSecond);
	end
	statFrame.attackSpeed = rangedAttackSpeed;
	statFrame.damage = tooltip;
	statFrame.dps = damagePerSecond;
	statFrame:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter);
	statFrame:Show();
end

function PaperDollFrame_SetRangedAttackSpeed(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local displaySpeed;

	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		displaySpeed = NOT_APPLICABLE;
		statFrame.tooltip = nil;
	else
		local attackTime, _, _, _, _, _ = UnitRangedDamage(unit);
		displaySpeed = BreakUpLargeNumbers(format("%.2F", attackTime));
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
	end
	PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, attackTime);

	statFrame:Show();
end

function PaperDollFrame_SetRangedAttackPower(statFrame, unit)
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_ATTACK_POWER));
	local text = _G[statFrame:GetName().."StatText"];
	local base, posBuff, negBuff = UnitRangedAttackPower(unit);

	PaperDollFormatStat(RANGED_ATTACK_POWER, base, posBuff, negBuff, statFrame, text);
	local totalAP = base+posBuff+negBuff;
	statFrame.tooltip2 = format(RANGED_ATTACK_POWER_TOOLTIP, max((totalAP), 0)/ATTACK_POWER_MAGIC_NUMBER);
	local petAPBonus = ComputePetBonus( "PET_BONUS_RAP_TO_AP", totalAP );
	if( petAPBonus > 0 ) then
		statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER, petAPBonus);
	end
	
	local petSpellDmgBonus = ComputePetBonus( "PET_BONUS_RAP_TO_SPELLDMG", totalAP );
	if( petSpellDmgBonus > 0 ) then
		statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_SPELLDAMAGE, petSpellDmgBonus);
	end
	
	statFrame:Show();
end

function PaperDollFrame_SetSpellBonusDamage(statFrame, unit)
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
	
	local spellHealing = GetSpellBonusHealing();
	if (spellHealing == minModifier) then
		_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_SPELLPOWER));
		statFrame.tooltip = STAT_SPELLPOWER;
		statFrame.tooltip2 = STAT_SPELLPOWER_TOOLTIP;
	else
		_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_SPELLDAMAGE));
		statFrame.tooltip = STAT_SPELLDAMAGE;
		statFrame.tooltip2 = STAT_SPELLDAMAGE_TOOLTIP;
	end
	
	text:SetText(minModifier);
	statFrame.minModifier = minModifier;
	statFrame.unit = unit;
	statFrame:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter);
	statFrame:Show();
end

function PaperDollFrame_SetSpellBonusHealing(statFrame, unit)
	local text = _G[statFrame:GetName().."StatText"];
	local minDamage = 0;
	
	if (unit == "player") then
		local holySchool = 2;
		-- Start at 2 to skip physical damage
		minDamage = GetSpellBonusDamage(holySchool);		
		for i=(holySchool+1), MAX_SPELL_SCHOOLS do
			minDamage = min(minDamage, GetSpellBonusDamage(i));
		end
	elseif (unit == "pet") then
		--Healing is not needed for pets (see bug  238141)
		--minDamage = GetPetSpellBonusDamage();
		statFrame:Hide();
		return;
	end
	statFrame.bonusDamage = nil;
	
	local spellHealing = GetSpellBonusHealing();
	if (spellHealing == minDamage) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_SPELLHEALING));
	statFrame.tooltip = STAT_SPELLHEALING;
	statFrame.tooltip2 = STAT_SPELLHEALING_TOOLTIP;
	text:SetText(spellHealing);
	statFrame.minModifier = spellHealing;
	statFrame.unit = unit;
	statFrame:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter);
	statFrame:Show();
end

function PaperDollFrame_SetSpellCritChance(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, SPELL_CRIT_CHANCE));
	local text = _G[statFrame:GetName().."StatText"];
	local holySchool = 2;
	-- Start at 2 to skip physical damage
	local minCrit = GetSpellCritChance(holySchool);
	statFrame.spellCrit = {};
	statFrame.spellCrit[holySchool] = minCrit;
	local spellCrit;
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i);
		minCrit = min(minCrit, spellCrit);
		statFrame.spellCrit[i] = spellCrit;
	end
	minCrit = format("%.2F%%", minCrit);
	text:SetText(minCrit);
	statFrame.minCrit = minCrit;
	statFrame:SetScript("OnEnter", CharacterSpellCritChance_OnEnter);
	statFrame:Show();
end

function PaperDollFrame_SetMeleeCritChance(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, MELEE_CRIT_CHANCE));
	local text = _G[statFrame:GetName().."StatText"];
	local critChance = GetCritChance();
	critChance = format("%.2F%%", critChance);
	text:SetText(critChance);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MELEE_CRIT_CHANCE).." "..critChance..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_CRIT_MELEE_TOOLTIP, GetCombatRating(CR_CRIT_MELEE), GetCombatRatingBonus(CR_CRIT_MELEE));
end

function PaperDollFrame_SetRangedCritChance(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, RANGED_CRIT_CHANCE));
	local text = _G[statFrame:GetName().."StatText"];
	local critChance = GetRangedCritChance();
	critChance = format("%.2F%%", critChance);
	text:SetText(critChance);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, RANGED_CRIT_CHANCE).." "..critChance..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_CRIT_RANGED_TOOLTIP, GetCombatRating(CR_CRIT_RANGED), GetCombatRatingBonus(CR_CRIT_RANGED));
end

function MeleeHitChance_OnEnter(statFrame)

	if (MOVING_STAT_CATEGORY) then return; end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");
	local hitChance = GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier();
	if (hitChance >= 0) then
		hitChance = format("+%.2F%%", hitChance);
	else
		hitChance = RED_FONT_COLOR_CODE..format("%.2F%%", hitChance)..FONT_COLOR_CODE_CLOSE;
	end
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HIT_CHANCE).." "..hitChance..FONT_COLOR_CODE_CLOSE);
	GameTooltip:AddLine(format(STAT_HIT_MELEE_TOOLTIP, GetCombatRating(CR_HIT_MELEE), GetCombatRatingBonus(CR_HIT_MELEE)));
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	if (IsDualWielding()) then
		GameTooltip:AddLine(STAT_HIT_NORMAL_ATTACKS, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	local playerLevel = UnitLevel("player");
	for i=0, 3 do
		local missChance = format("%.2F%%", GetMeleeMissChance(i, false));
		local level = playerLevel + i;
			if (i == 3) then
				level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
			end
		GameTooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	
	if (IsDualWielding()) then
		GameTooltip:AddLine(STAT_HIT_SPECIAL_ATTACKS, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		for i=0, 3 do
			local missChance = format("%.2F%%", GetMeleeMissChance(i, true));
			local level = playerLevel + i;
			if (i == 3) then
				level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
			end
			GameTooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
	end
	
	GameTooltip:Show();
end

function PaperDollFrame_SetMeleeHitChance(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_HIT_CHANCE));
	local text = _G[statFrame:GetName().."StatText"];
	local hitChance = GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier();
	if (hitChance >= 0) then
		hitChance = format("+%.2F%%", hitChance);
	else
		hitChance = RED_FONT_COLOR_CODE..format("%.2F%%", hitChance)..FONT_COLOR_CODE_CLOSE;
	end
	text:SetText(hitChance);
	statFrame:SetScript("OnEnter", MeleeHitChance_OnEnter);
	statFrame:Show();
end

function RangedHitChance_OnEnter(statFrame)

	if (MOVING_STAT_CATEGORY) then return; end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");
	local hitChance = GetCombatRatingBonus(CR_HIT_RANGED) + GetHitModifier();
	if (hitChance >= 0) then
		hitChance = format("+%.2F%%", hitChance);
	else
		hitChance = RED_FONT_COLOR_CODE..format("%.2F%%", hitChance)..FONT_COLOR_CODE_CLOSE;
	end
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HIT_CHANCE).." "..hitChance..FONT_COLOR_CODE_CLOSE);
	GameTooltip:AddLine(format(STAT_HIT_RANGED_TOOLTIP, GetCombatRating(CR_HIT_RANGED), GetCombatRatingBonus(CR_HIT_RANGED)));
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	local playerLevel = UnitLevel("player");
	for i=0, 3 do
		local missChance = format("%.2F%%", GetRangedMissChance(i));
		local level = playerLevel + i;
			if (i == 3) then
				level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
			end
		GameTooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
		
	GameTooltip:Show();
end

function PaperDollFrame_SetRangedHitChance(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_HIT_CHANCE));
	local text = _G[statFrame:GetName().."StatText"];
	local hitChance = GetCombatRatingBonus(CR_HIT_RANGED) + GetHitModifier();
	if (hitChance >= 0) then
		hitChance = format("+%.2F%%", hitChance);
	else
		hitChance = RED_FONT_COLOR_CODE..format("%.2F%%", hitChance)..FONT_COLOR_CODE_CLOSE;
	end
	text:SetText(hitChance);
	statFrame:SetScript("OnEnter", RangedHitChance_OnEnter);
	statFrame:Show();
end

function SpellHitChance_OnEnter(statFrame)

	if (MOVING_STAT_CATEGORY) then return; end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");
	local hitChance = GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier();
	if (hitChance >= 0) then
		hitChance = format("+%.2F%%", hitChance);
	else
		hitChance = RED_FONT_COLOR_CODE..format("%.2F%%", hitChance)..FONT_COLOR_CODE_CLOSE;
	end
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HIT_CHANCE).." "..hitChance..FONT_COLOR_CODE_CLOSE);
	GameTooltip:AddLine(format(STAT_HIT_SPELL_TOOLTIP, GetCombatRating(CR_HIT_SPELL), GetCombatRatingBonus(CR_HIT_SPELL)));
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	local playerLevel = UnitLevel("player");
	for i=0, 3 do
		local missChance = format("%.2F%%", GetSpellMissChance(i));
		local level = playerLevel + i;
			if (i == 3) then
				level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
			end
		GameTooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
		
	GameTooltip:Show();
end

function PaperDollFrame_SetSpellHitChance(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_HIT_CHANCE));
	local text = _G[statFrame:GetName().."StatText"];
	local hitChance = GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier();
	if (hitChance >= 0) then
		hitChance = format("+%.2F%%", hitChance);
	else
		hitChance = RED_FONT_COLOR_CODE..format("%.2F%%", hitChance)..FONT_COLOR_CODE_CLOSE;
	end
	text:SetText(hitChance);
	statFrame:SetScript("OnEnter", SpellHitChance_OnEnter);
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


function PaperDollFrame_SetMeleeHaste(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	local haste = GetMeleeHaste();
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
	statFrame.tooltip2 = _G["STAT_HASTE_MELEE_"..class.."_TOOLTIP"];
	if (not statFrame.tooltip2) then
		statFrame.tooltip2 = STAT_HASTE_MELEE_TOOLTIP;
	end
	statFrame.tooltip2 = statFrame.tooltip2 .. format(STAT_HASTE_BASE_TOOLTIP, GetCombatRating(CR_HASTE_MELEE), GetCombatRatingBonus(CR_HASTE_MELEE));
	
	statFrame:Show();
end

function PaperDollFrame_SetRangedHaste(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	local haste = GetRangedHaste();
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
	statFrame.tooltip2 = _G["STAT_HASTE_RANGED_"..class.."_TOOLTIP"];
	if (not statFrame.tooltip2) then
		statFrame.tooltip2 = STAT_HASTE_RANGED_TOOLTIP;
	end
	statFrame.tooltip2 = statFrame.tooltip2 .. format(STAT_HASTE_BASE_TOOLTIP, GetCombatRating(CR_HASTE_RANGED), GetCombatRatingBonus(CR_HASTE_RANGED));

	statFrame:Show();
end

function PaperDollFrame_SetSpellPenetration(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, SPELL_PENETRATION));
	local text = _G[statFrame:GetName().."StatText"];
	local spellPenetration = GetSpellPenetration();
	text:SetText(spellPenetration);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE ..SPELL_PENETRATION.. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(SPELL_PENETRATION_TOOLTIP, spellPenetration, spellPenetration);
	statFrame:Show();
end

function PaperDollFrame_SetSpellHaste(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	local haste = UnitSpellHaste(unit);
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
	statFrame.tooltip2 = _G["STAT_HASTE_SPELL_"..class.."_TOOLTIP"];
	if (not statFrame.tooltip2) then
		statFrame.tooltip2 = STAT_HASTE_SPELL_TOOLTIP;
	end
	statFrame.tooltip2 = statFrame.tooltip2 .. format(STAT_HASTE_BASE_TOOLTIP, GetCombatRating(CR_HASTE_SPELL), GetCombatRatingBonus(CR_HASTE_SPELL));

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
	
	local base, casting = GetManaRegen();
	-- All mana regen stats are displayed as mana/5 sec.
	base = floor( base * 5.0 );
	casting = floor( casting * 5.0 );
	text:SetText(base);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. MANA_REGEN .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(MANA_REGEN_TOOLTIP, base);
	statFrame:Show();
end

function PaperDollFrame_SetCombatManaRegen(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, MANA_REGEN_COMBAT));
	local text = _G[statFrame:GetName().."StatText"];
	if ( not UnitHasMana("player") ) then
		text:SetText(NOT_APPLICABLE);
		statFrame.tooltip = nil;
		return;
	end
	
	local base, casting = GetManaRegen();
	-- All mana regen stats are displayed as mana/5 sec.
	base = floor( base * 5.0 );
	casting = floor( casting * 5.0 );
	text:SetText(casting);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. MANA_REGEN_COMBAT .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(MANA_COMBAT_REGEN_TOOLTIP, casting);
	statFrame:Show();
end

function Expertise_OnEnter(statFrame)

	if (MOVING_STAT_CATEGORY) then return; end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");
	local expertise, offhandExpertise = GetExpertise();
	local expertisePercent, offhandExpertisePercent = GetExpertisePercent();
	expertisePercent = format("%.2F", expertisePercent);
	offhandExpertisePercent = format("%.2F", offhandExpertisePercent);
	
	local expertiseDisplay, expertisePercentDisplay;
	if (IsDualWielding()) then
		expertiseDisplay = expertise.." / "..offhandExpertise;
		expertisePercentDisplay = expertisePercent.."% / "..offhandExpertisePercent.."%";
	else
		expertiseDisplay = expertise;
		expertisePercentDisplay = expertisePercent.."%";
	end
	
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G["COMBAT_RATING_NAME"..CR_EXPERTISE]).." "..expertiseDisplay..FONT_COLOR_CODE_CLOSE);
	GameTooltip:AddLine(format(CR_EXPERTISE_TOOLTIP, expertisePercentDisplay, GetCombatRating(CR_EXPERTISE), GetCombatRatingBonus(CR_EXPERTISE)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	GameTooltip:AddLine(" ");
	
	-- Dodge chance
	GameTooltip:AddDoubleLine(STAT_TARGET_LEVEL, DODGE_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	local playerLevel = UnitLevel("player");
	for i=0, 3 do
		local mainhandDodge, offhandDodge = GetEnemyDodgeChance(i);
		mainhandDodge = format("%.2F%%", mainhandDodge);
		offhandDodge = format("%.2F%%", offhandDodge);
		local level = playerLevel + i;
		if (i == 3) then
			level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
		end
		local dodgeDisplay;
		if (IsDualWielding() and mainhandDodge ~= offhandDodge) then
			dodgeDisplay = mainhandDodge.." / "..offhandDodge;
		else
			dodgeDisplay = mainhandDodge.."  ";
		end
		GameTooltip:AddDoubleLine("      "..level, dodgeDisplay.."  ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	
	-- Parry chance
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(STAT_TARGET_LEVEL, PARRY_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	local playerLevel = UnitLevel("player");
	for i=0, 3 do
		local mainhandParry, offhandParry = GetEnemyParryChance(i);
		mainhandParry = format("%.2F%%", mainhandParry);
		offhandParry = format("%.2F%%", offhandParry);
		local level = playerLevel + i;
		if (i == 3) then
			level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
		end
		local parryDisplay;
		if (IsDualWielding() and mainhandParry ~= offhandParry) then
			parryDisplay = mainhandParry.." / "..offhandParry;
		else
			parryDisplay = mainhandParry.."  ";
		end
		GameTooltip:AddDoubleLine("      "..level, parryDisplay.."  ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
		
	GameTooltip:Show();
end

function PaperDollFrame_SetExpertise(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	local expertisePct, offhandExpertisePct = GetExpertise();
	local speed, offhandSpeed = UnitAttackSpeed(unit);
	local text;
	if( offhandSpeed ) then
		text = expertisePct.." / "..offhandExpertisePct;
	else
		text = expertisePct;
	end
	PaperDollFrame_SetLabelAndText(statFrame, STAT_EXPERTISE, text, true, expertisePct);
	statFrame:SetScript("OnEnter", Expertise_OnEnter);
	statFrame:Show();
end

function Mastery_OnEnter(statFrame)
	if (MOVING_STAT_CATEGORY) then return; end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");
	
	local _, class = UnitClass("player");
	local mastery = GetMastery();
	local masteryBonus = GetCombatRatingBonus(CR_MASTERY);
	
	local title = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MASTERY).." "..format("%.2F", mastery)..FONT_COLOR_CODE_CLOSE;
	if (masteryBonus > 0) then
		title = title..HIGHLIGHT_FONT_COLOR_CODE.." ("..format("%.2F", mastery-masteryBonus)..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..format("%.2F", masteryBonus)..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")";
	end
	GameTooltip:SetText(title);
	
	local masteryKnown = IsSpellKnown(CLASS_MASTERY_SPELLS[class]);
	local primaryTalentTree = GetPrimaryTalentTree();
	if (masteryKnown and primaryTalentTree) then
		local masterySpell, masterySpell2 = GetTalentTreeMasterySpells(primaryTalentTree);
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
		if (masteryKnown) then
			GameTooltip:AddLine(STAT_MASTERY_TOOLTIP_NO_TALENT_SPEC, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		else
			GameTooltip:AddLine(STAT_MASTERY_TOOLTIP_NOT_KNOWN, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		end
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
	local mastery = GetMastery();
	mastery = format("%.2F", mastery);
	text:SetText(mastery);
	statFrame:SetScript("OnEnter", Mastery_OnEnter);
	statFrame:Show();
end

function PaperDollFrame_SetItemLevel(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	_G[statFrame:GetName().."Label"]:SetText(format(STAT_FORMAT, STAT_AVERAGE_ITEM_LEVEL));
	local text = _G[statFrame:GetName().."StatText"];
	local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel();
	avgItemLevel = floor(avgItemLevel);
	avgItemLevelEquipped = floor(avgItemLevelEquipped);
	text:SetText(avgItemLevelEquipped .. " / " .. avgItemLevel);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..avgItemLevel;
	if (avgItemLevelEquipped ~= avgItemLevel) then
		statFrame.tooltip = statFrame.tooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, avgItemLevelEquipped);
	end
	statFrame.tooltip = statFrame.tooltip .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP;
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
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, self.tooltip).." "..self.minModifier..FONT_COLOR_CODE_CLOSE);

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
			GameTooltip:AddLine(format(petStr, petBonusAP, petBonusDmg), nil, nil, nil, 1 );
		end
	end
	GameTooltip:Show();
end

function CharacterSpellCritChance_OnEnter (self)
	if (MOVING_STAT_CATEGORY) then return; end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, SPELL_CRIT_CHANCE).." "..self.minCrit..FONT_COLOR_CODE_CLOSE);
	local spellCrit;
	for i=2, MAX_SPELL_SCHOOLS do
		spellCrit = format("%.2F%%", self.spellCrit[i]);
		if (spellCrit ~= self.minCrit) then
			GameTooltip:AddDoubleLine(_G["DAMAGE_SCHOOL"..i], spellCrit, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..i);
		end
	end
	GameTooltip:AddLine(format(CR_CRIT_SPELL_TOOLTIP, GetCombatRating(CR_CRIT_SPELL), GetCombatRatingBonus(CR_CRIT_SPELL)));
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

function PaperDollFrame_OnShow (self)
	CharacterStatsPane.initialOffsetY = 0;
	PaperDollFrame_SetLevel();
	local activeSpec = GetActiveTalentGroup();
	if (activeSpec == 1) then
		PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, "statCategoryOrder", "statCategoriesCollapsed", "player");
	else
		PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, "statCategoryOrder_2", "statCategoriesCollapsed_2", "player");
	end	
	PaperDollFrame_UpdateStats();
	if (GetCVar("characterFrameCollapsed") ~= "0") then
		CharacterFrame:Collapse();
	else
		CharacterFrame:Expand();
	end
	CharacterFrameExpandButton:Show();
	CharacterFrameExpandButton.collapseTooltip = STATS_COLLAPSE_TOOLTIP;
	CharacterFrameExpandButton.expandTooltip = STATS_EXPAND_TOOLTIP;

	SetPaperDollBackground(CharacterModelScene, "player");
	PaperDollBgDesaturate(true);
	PaperDollSidebarTabs:Show();

	CharacterModelScene.ControlFrame:Show();
	CharacterModelScene.ControlFrame:SetModelScene(CharacterModelScene);

	PaperDollFrame_SetPlayer();
	self:RegisterEvent("UNIT_MODEL_CHANGED");
end
 
function PaperDollFrame_OnHide (self)
	CharacterStatsPane.initialOffsetY = 0;
	CharacterFrame:Collapse();
	CharacterFrameExpandButton:Hide();
	if (MOVING_STAT_CATEGORY) then
		PaperDollStatCategory_OnDragStop(MOVING_STAT_CATEGORY);
	end
	PaperDollSidebarTabs:Hide();
	self:UnregisterEvent("UNIT_MODEL_CHANGED");
	
end

function PaperDollFrame_ClearIgnoredSlots ()
	C_EquipmentSet.ClearIgnoredSlotsForSave();		
	for k, button in next, itemSlotButtons do
		if ( button.ignored ) then
			button.ignored = nil;
			PaperDollItemSlotButton_Update(button);
		end
	end
end

function PaperDollFrame_IgnoreSlotsForSet (setID)
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

function PaperDollItemSlotButton_OnLoad (self)
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
};

function PaperDollItemSlotButton_OnShow(self, isBag)
	FrameUtil.RegisterFrameForEvents(self, PAPERDOLL_FRAME_EVENTS);

	if ( not isBag ) then
		self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	end
	PaperDollItemSlotButton_Update(self);
end

function PaperDollItemSlotButton_OnHide (self)
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
		if ( CursorCanGoInSlot(self:GetID()) ) then
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

function PaperDollItemSlotButton_OnClick (self, button)
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

function PaperDollItemSlotButton_OnModifiedClick (self, button)
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(self:GetID());
	if ( IsModifiedClick("SOCKETITEM") or IsModifiedClick("EXPANDITEM") ) then
		SocketInventoryItem(self:GetID());
	end
	if ( HandleModifiedItemClick(GetInventoryItemLink("player", self:GetID()), itemLocation) ) then
		return;
	end
end

function PaperDollItemSlotButton_Update(self)
	local textureName = GetInventoryItemTexture("player", self:GetID());
	local cooldown = _G[self:GetName().."Cooldown"];
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

	-- TODO CLASS-28842: MainMenuBarBagButtons.xml calls into PaperDollItemSlotButton_OnShow, which calls
	-- this function. In mainline, MainMenuBarBagButtons properly inherits from ItemButton, but not Classic yet.
	-- This line can be uncommented once Classic updates MainMenuBarBagButtons.
	--self:UpdateItemContextMatching();

	if (not PaperDollFrame.EquipmentManagerPane:IsShown()) then
		self.ignored = nil;
	end

	if self.ignoreTexture then
		self.ignoreTexture:SetShown(self.ignored);
	end

	PaperDollItemSlotButton_UpdateLock(self);

	-- Update repair all button status
	MerchantFrame_UpdateGuildBankRepair();
	MerchantFrame_UpdateCanRepairAll();
end

function PaperDollItemSlotButton_UpdateLock (self)
	if ( IsInventoryItemLocked(self:GetID()) ) then
		SetItemButtonDesaturated(self, 1);
	else 
		SetItemButtonDesaturated(self, nil);
	end
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
			GameTooltip:SetText(RELICSLOT);
		else
			local slotName = PaperDollItemSlotButton_GetSlotName(self);
			GameTooltip:SetText(_G[strupper(slotName)]);
			GameTooltip:Show();
		end
	end
	if ( InRepairMode() and repairCost and (repairCost > 0) ) then
		GameTooltip:AddLine(REPAIR_COST, "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	else
		CursorUpdate(self);
	end
end

function PaperDollItemSlotButton_OnLeave(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	GameTooltip:Hide();
	ResetCursor();
end

function PaperDollStatTooltip(self)
	if (MOVING_STAT_CATEGORY ~= nil) then return; end
	if ( not self.tooltip ) then
		return;
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.tooltip);
	if ( self.tooltip2 ) then
		GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	end
	GameTooltip:Show();
end

function FormatPaperDollTooltipStat(name, base, posBuff, negBuff)
	local effective = max(0,base + posBuff + negBuff);
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
	local effective = max(0,base + posBuff + negBuff);
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
	local effective = max(0,base + posBuff + negBuff);
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
	GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE_PER_SECOND), format("%.1F", self.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	-- Check for offhand weapon
	if ( self.offhandAttackSpeed ) then
		GameTooltip:AddLine("\n");
		GameTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", self.offhandAttackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), self.offhandDamage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE_PER_SECOND), format("%.1F", self.offhandDps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	GameTooltip:Show();
end

function CharacterRangedDamageFrame_OnEnter (self)
	if (MOVING_STAT_CATEGORY) then return; end
	if ( not self.damage ) then
		return;
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(INVTYPE_RANGED, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", self.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), self.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE_PER_SECOND), format("%.1F", self.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:Show();
end

function PaperDollFrame_GetArmorReduction(armor, attackerLevel)
	local levelModifier = attackerLevel;
	if ( levelModifier > 80 ) then
		levelModifier = levelModifier + (4.5 * (levelModifier-59)) + (20 * (levelModifier - 80));
	elseif ( levelModifier > 59 ) then
		levelModifier = levelModifier + (4.5 * (levelModifier-59));
	end
	local temp = 0.1*armor/(8.5*levelModifier + 40);
	temp = temp/(1+temp);

	if ( temp > 0.75 ) then
		return 75;
	end

	if ( temp < 0 ) then
		return 0;
	end

	return temp*100;
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
					statFrame = CreateFrame("FRAME", categoryFrame:GetName().."Stat"..numVisible+1, categoryFrame, "CharacterStatFrameTemplate");
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
	CharacterStatsPane.ScrollBox.Contents:Layout();
	CharacterStatsPane.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
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
	GearSetButton_OpenPopup(self:GetParent());
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

function GearSetButton_OnClick (self, button, down)
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

function GearSetButton_OnEnter (self)
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
	GearManagerPopupFrame.IconSelector:SetSize(494, 362);

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

function PaperDollEquipmentManagerPaneSaveSet_OnClick (self)
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

function PaperDollEquipmentManagerPaneEquipSet_OnClick (self)
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

PaperDollItemSlotButtonMixin = {}

function PaperDollItemSlotButtonMixin:GetItemContextMatchResult()
	return ItemButtonUtil.GetItemContextMatchResultForItem(ItemLocation:CreateFromEquipmentSlot(self:GetID()));
end
