EQUIPPED_FIRST = 1;
EQUIPPED_LAST = 19;

NUM_RESISTANCE_TYPES = 5;
NUM_STATS = 5;
NUM_SHOPPING_TOOLTIPS = 2;
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
CR_RESILIENCE_CRIT_TAKEN = 15;
CR_RESILIENCE_PLAYER_DAMAGE_TAKEN = 16;
CR_HASTE_MELEE = 18;
CR_HASTE_RANGED = 19;
CR_HASTE_SPELL = 20;
CR_EXPERTISE = 24;

ATTACK_POWER_MAGIC_NUMBER = 14;
BLOCK_PER_STRENGTH = 0.05;
HEALTH_PER_STAMINA = 10;
ARMOR_PER_AGILITY = 2;
MANA_PER_INTELLECT = 15;
MANA_REGEN_PER_SPIRIT = 0.2;
DODGE_PARRY_BLOCK_PERCENT_PER_DEFENSE = 0.04;
BASE_MOVEMENT_SPEED = 7;

--Pet scaling:
HUNTER_PET_BONUS = {};
HUNTER_PET_BONUS["PET_BONUS_RAP_TO_AP"] = 0.22;
HUNTER_PET_BONUS["PET_BONUS_RAP_TO_SPELLDMG"] = 0.1287;
HUNTER_PET_BONUS["PET_BONUS_STAM"] = 0.3;
HUNTER_PET_BONUS["PET_BONUS_RES"] = 0.4;
HUNTER_PET_BONUS["PET_BONUS_ARMOR"] = 0.35;
HUNTER_PET_BONUS["PET_BONUS_SPELLDMG_TO_SPELLDMG"] = 0.0;
HUNTER_PET_BONUS["PET_BONUS_SPELLDMG_TO_AP"] = 0.0;
HUNTER_PET_BONUS["PET_BONUS_INT"] = 0.0;

WARLOCK_PET_BONUS = {};
WARLOCK_PET_BONUS["PET_BONUS_RAP_TO_AP"] = 0.0;
WARLOCK_PET_BONUS["PET_BONUS_RAP_TO_SPELLDMG"] = 0.0;
WARLOCK_PET_BONUS["PET_BONUS_STAM"] = 0.3;
WARLOCK_PET_BONUS["PET_BONUS_RES"] = 0.4;
WARLOCK_PET_BONUS["PET_BONUS_ARMOR"] = 0.35;
WARLOCK_PET_BONUS["PET_BONUS_SPELLDMG_TO_SPELLDMG"] = 0.15;
WARLOCK_PET_BONUS["PET_BONUS_SPELLDMG_TO_AP"] = 0.57;
WARLOCK_PET_BONUS["PET_BONUS_INT"] = 0.3;

PLAYERSTAT_DROPDOWN_OPTIONS = {
	"PLAYERSTAT_BASE_STATS",
	"PLAYERSTAT_MELEE_COMBAT",
	"PLAYERSTAT_RANGED_COMBAT",
	"PLAYERSTAT_SPELL_COMBAT",
	"PLAYERSTAT_DEFENSES",
};

--[[ GENERAL FUNCTIONS ]]

function PaperDollFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_RESISTANCES");
	self:RegisterEvent("UNIT_STATS");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterUnitEvent("UNIT_MAXHEALTH", "player");
	self:RegisterEvent("UNIT_DAMAGE");
	self:RegisterEvent("UNIT_RANGEDDAMAGE");
	self:RegisterEvent("PLAYER_DAMAGE_DONE_MODS");
	self:RegisterEvent("UNIT_ATTACK_SPEED");
	self:RegisterEvent("UNIT_ATTACK_POWER");
	self:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
	self:RegisterEvent("UNIT_ATTACK");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("COMBAT_RATING_UPDATE");
end

function PaperDollFrame_OnShow(self)
	PaperDollFrame_SetLevel();
	PaperDollFrame_UpdateStats();

	if ( UnitHasRelicSlot("player") ) then
		CharacterAmmoSlot:Hide();
	else
		CharacterAmmoSlot:Show();
	end

	PlayerTitleDropDown:SetShown(PlayerTitleDropDown_IsTitleAvailable());

	local currentTitle = GetCurrentTitle();
	if ( currentTitle == 0 ) then
		UIDropDownMenu_SetText(PlayerTitleDropDown, PAPERDOLL_SELECT_TITLE);	
	elseif ( currentTitle == -1 ) then
		UIDropDownMenu_SetText(PlayerTitleDropDown, NONE);	
	else
		UIDropDownMenu_SetText(PlayerTitleDropDown, GetTitleName(currentTitle));	
	end
end

function PaperDollFrame_OnEvent(self, event, ...)
	local unit = ...;
	if ( event == "PLAYER_ENTERING_WORLD" or
		event == "UNIT_MODEL_CHANGED" and unit == "player" ) then
		CharacterModelFrame:SetUnit("player", false);
		return;
	end

	if ( event == "VARIABLES_LOADED" ) then
		-- Set defaults if invalid settings for the dropdowns
		local playerStatLeftDropDownValue = GetCVar("playerStatLeftDropdown");
		local playerStatRightDropDownValue = GetCVar("playerStatRightDropdown");
		local playerStatLeftDropDownValueValid, playerStatRightDropDownValueValid = false, false;

		for i=1, getn(PLAYERSTAT_DROPDOWN_OPTIONS) do
			if (PLAYERSTAT_DROPDOWN_OPTIONS[i] == playerStatLeftDropDownValue) then
				playerStatLeftDropDownValueValid = true;
			end
			if (PLAYERSTAT_DROPDOWN_OPTIONS[i] == playerStatRightDropDownValue) then
				playerStatRightDropDownValueValid = true;
			end
		end

		if ( not playerStatLeftDropDownValueValid or not playerStatRightDropDownValueValid ) then
			local temp, classFileName = UnitClass("player");
			classFileName = strupper(classFileName);
			SetCVar("playerStatLeftDropdown", "PLAYERSTAT_BASE_STATS");
			if ( classFileName == "MAGE" or classFileName == "PRIEST" or classFileName == "WARLOCK" or classFileName == "DRUID" ) then
				SetCVar("playerStatRightDropdown", "PLAYERSTAT_SPELL_COMBAT");
			elseif ( classFileName == "HUNTER" ) then
				SetCVar("playerStatRightDropdown", "PLAYERSTAT_RANGED_COMBAT");
			else
				SetCVar("playerStatRightDropdown", "PLAYERSTAT_MELEE_COMBAT");
			end
		end

		playerStatLeftDropDownValue = GetCVar("playerStatLeftDropdown");
		playerStatRightDropDownValue = GetCVar("playerStatRightDropdown");
		UIDropDownMenu_SetSelectedValue(PlayerStatFrameLeftDropDown, playerStatLeftDropDownValue);
		UIDropDownMenu_SetText(PlayerStatFrameLeftDropDown, _G[playerStatLeftDropDownValue]);
		UIDropDownMenu_SetSelectedValue(PlayerStatFrameRightDropDown, playerStatRightDropDownValue);
		UIDropDownMenu_SetText(PlayerStatFrameRightDropDown, _G[playerStatRightDropDownValue]);

		PaperDollFrame_UpdateStats();
	end

	if ( not self:IsVisible() ) then
		return;
	end

	if ( unit == "player" ) then
		if ( event == "UNIT_LEVEL" ) then
			PaperDollFrame_SetLevel();
		elseif ( event == "UNIT_DAMAGE" or
				event == "PLAYER_DAMAGE_DONE_MODS" or
				event == "UNIT_ATTACK_SPEED" or
				event == "UNIT_RANGEDDAMAGE" or
				event == "UNIT_ATTACK" or
				event == "UNIT_RESISTANCES" or
				event == "UNIT_STATS" or
				event == "UNIT_AURA" or
				event == "UNIT_MAXHEALTH" or
				event == "UNIT_ATTACK_POWER" or
				event == "UNIT_RANGED_ATTACK_POWER" or
				event == "SKILL_LINES_CHANGED" or
				event == "COMBAT_RATING_UPDATE") then
			self:SetScript("OnUpdate", PaperDollFrame_QueuedUpdate);
		end
	end
end

-- This makes sure the update only happens once at the end of the frame
function PaperDollFrame_QueuedUpdate(self)
	self:SetScript("OnUpdate", nil);
	PaperDollFrame_UpdateStats();
end

function PaperDollFrame_SetLevel()
	CharacterLevelText:SetFormattedText(PLAYER_LEVEL, UnitLevel("player"), UnitRace("player"), UnitClass("player"));
end

function PaperDoll_IsEquippedSlot(slot)
	if ( slot ) then
		slot = tonumber(slot);
		if ( slot ) then
			return slot >= EQUIPPED_FIRST and slot <= EQUIPPED_LAST;
		end
	end
	return false;
end

--[[ STAT DROPDOWN FUNCTIONS ]]

function PlayerStatFrameLeftDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, PlayerStatFrameLeftDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, GetCVar("playerStatLeftDropdown"));
	UIDropDownMenu_SetWidth(self, 99);
	UIDropDownMenu_JustifyText(self, "LEFT");
end

function PlayerStatFrameLeftDropDown_Initialize(self)
	-- Setup buttons
	local info = UIDropDownMenu_CreateInfo();
	local checked;
	local cvarValue = GetCVar("playerStatLeftDropdown");
	for i=1, getn(PLAYERSTAT_DROPDOWN_OPTIONS) do
		if ( PLAYERSTAT_DROPDOWN_OPTIONS[i] == cvarValue ) then
			checked = 1;
		else
			checked = nil;
		end
		info.text = getglobal(PLAYERSTAT_DROPDOWN_OPTIONS[i]);
		info.func = PlayerStatFrameLeftDropDown_OnClick;
		info.value = PLAYERSTAT_DROPDOWN_OPTIONS[i];
		info.checked = checked;
		info.owner = UIDROPDOWNMENU_OPEN_MENU;
		UIDropDownMenu_AddButton(info);
	end
end

function PlayerStatFrameLeftDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value);
	SetCVar("playerStatLeftDropdown", self.value);
	UpdatePaperdollStats("PlayerStatFrameLeft", self.value);
end

function PlayerStatFrameRightDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, PlayerStatFrameRightDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, GetCVar("playerStatRightDropdown"));
	UIDropDownMenu_SetWidth(self, 99);
	UIDropDownMenu_JustifyText(self, "LEFT");
end

function PlayerStatFrameRightDropDown_Initialize(self)
	-- Setup buttons
	local info = UIDropDownMenu_CreateInfo();
	local checked;
	local cvarValue = GetCVar("playerStatRightDropdown");
	for i=1, getn(PLAYERSTAT_DROPDOWN_OPTIONS) do
		if ( PLAYERSTAT_DROPDOWN_OPTIONS[i] == cvarValue ) then
			checked = 1;
		else
			checked = nil;
		end
		info.text = getglobal(PLAYERSTAT_DROPDOWN_OPTIONS[i]);
		info.func = PlayerStatFrameRightDropDown_OnClick;
		info.value = PLAYERSTAT_DROPDOWN_OPTIONS[i];
		info.checked = checked;
		info.owner = UIDROPDOWNMENU_OPEN_MENU;
		UIDropDownMenu_AddButton(info);
	end
end

function PlayerStatFrameRightDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value);
	SetCVar("playerStatRightDropdown", self.value);
	UpdatePaperdollStats("PlayerStatFrameRight", self.value);
end

-- Player title dropdown functions
function PlayerTitleDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, PlayerTitleDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, GetCurrentTitle());
	UIDropDownMenu_SetWidth(self, 160);
	UIDropDownMenu_JustifyText(self, "LEFT");
	PlayerTitleDropDownLeft:SetHeight(50);
	PlayerTitleDropDownMiddle:SetHeight(50);
	PlayerTitleDropDownRight:SetHeight(50);
	PlayerTitleDropDownButton:SetPoint("TOPRIGHT", PlayerTitleDropDownRight, "TOPRIGHT", -16, -12);
end

function PlayerTitleDropDown_IsTitleAvailable()
	for index = 1, GetNumTitles() do
		if IsTitleKnown(index) then
			return true;
		end
	end
	return false;
end

function PlayerTitleDropDown_Initialize()
	-- Setup buttons
	local info = UIDropDownMenu_CreateInfo();
	local checked;
	local currentTitle = GetCurrentTitle();
	local titleName;
	for i=1, GetNumTitles() do
		-- Changed to base 0 for simplicity, change when the opportunity arrises.
		if ( IsTitleKnown(i) ) then
			if ( i == currentTitle ) then
				checked = 1;
			else
				checked = nil;
			end
			titleName = GetTitleName(i);
			info.text = titleName;
			info.func = PlayerTitleDropDown_OnClick;
			info.value = i;
			UIDropDownMenu_AddButton(info);
		end
	end
	-- Add none button
	if ( currentTitle == 0 or currentTitle == -1 ) then
		checked = 1;
	else
		checked = nil;
	end
	info.text = NONE;
	info.func = PlayerTitleDropDown_OnClick;
	info.value = -1;
	info.checked = checked;
	UIDropDownMenu_AddButton(info);
end

function PlayerTitleDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(PlayerTitleDropDown, self.value);
	SetCurrentTitle(self.value);
end

--[[ STAT UPDATING FUNCTIONS ]]

function PaperDollFrame_UpdateStats()
	PaperDollFrame_SetResistances();
	UpdatePaperdollStats("PlayerStatFrameLeft", GetCVar("playerStatLeftDropdown"));	
	UpdatePaperdollStats("PlayerStatFrameRight", GetCVar("playerStatRightDropdown"));
end

function PaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage)
	getglobal(statFrame:GetName().."Label"):SetText(label..":");
	if ( isPercentage ) then
		text = format("%.2f%%", text);
	end
	getglobal(statFrame:GetName().."StatText"):SetText(text);
end

function UpdatePaperdollStats(prefix, index)
	local stat1 = _G[prefix..1];
	local stat2 = _G[prefix..2];
	local stat3 = _G[prefix..3];
	local stat4 = _G[prefix..4];
	local stat5 = _G[prefix..5];
	local stat6 = _G[prefix..6];

	-- reset any OnEnter scripts that may have been changed
	stat1:SetScript("OnEnter", PaperDollStatTooltip);
	stat2:SetScript("OnEnter", PaperDollStatTooltip);
	stat4:SetScript("OnEnter", PaperDollStatTooltip);

	stat6:Show();

	if ( index == "PLAYERSTAT_BASE_STATS" ) then
		PaperDollFrame_SetStat(stat1, 1);
		PaperDollFrame_SetStat(stat2, 2);
		PaperDollFrame_SetStat(stat3, 3);
		PaperDollFrame_SetStat(stat4, 4);
		PaperDollFrame_SetStat(stat5, 5);
		PaperDollFrame_SetArmor(stat6);
	elseif ( index == "PLAYERSTAT_MELEE_COMBAT" ) then
		PaperDollFrame_SetDamage(stat1);
		stat1:SetScript("OnEnter", CharacterDamageFrame_OnEnter);
		PaperDollFrame_SetAttackSpeed(stat2);
		PaperDollFrame_SetAttackPower(stat3);
		PaperDollFrame_SetRating(stat4, CR_HIT_MELEE);
		PaperDollFrame_SetMeleeCritChance(stat5);
		PaperDollFrame_SetExpertise(stat6);
	elseif ( index == "PLAYERSTAT_RANGED_COMBAT" ) then
		PaperDollFrame_SetRangedDamage(stat1);
		stat1:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter);
		PaperDollFrame_SetRangedAttackSpeed(stat2);
		PaperDollFrame_SetRangedAttackPower(stat3);
		PaperDollFrame_SetRating(stat4, CR_HIT_RANGED);
		PaperDollFrame_SetRangedCritChance(stat5);
		stat6:Hide();
	elseif ( index == "PLAYERSTAT_SPELL_COMBAT" ) then
		PaperDollFrame_SetSpellBonusDamage(stat1);
		stat1:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter);
		PaperDollFrame_SetSpellBonusHealing(stat2);
		PaperDollFrame_SetRating(stat3, CR_HIT_SPELL);
		PaperDollFrame_SetSpellCritChance(stat4);
		stat4:SetScript("OnEnter", CharacterSpellCritChance_OnEnter);
		PaperDollFrame_SetSpellHaste(stat5);
		PaperDollFrame_SetManaRegen(stat6);
	elseif ( index == "PLAYERSTAT_DEFENSES" ) then
		PaperDollFrame_SetArmor(stat1);
		PaperDollFrame_SetDefense(stat2);
		PaperDollFrame_SetDodge(stat3);
		PaperDollFrame_SetParry(stat4);
		PaperDollFrame_SetBlock(stat5);
		PaperDollFrame_SetResilience(stat6);
	end

	-- Shouldn't really be necessary, since the VARIABLES_LOADED should take care of this on startup and the OnClick should handle it from there.
	-- But this covers us to be safe.
	UIDropDownMenu_SetText(_G[prefix.."DropDown"], _G[index]);
end

function PaperDollFrame_SetStat(statFrame, statIndex)
	local label = getglobal(statFrame:GetName().."Label");
	local text = getglobal(statFrame:GetName().."StatText");
	local stat;
	local effectiveStat;
	local posBuff;
	local negBuff;
	stat, effectiveStat, posBuff, negBuff = UnitStat("player", statIndex);
	local statName = getglobal("SPELL_STAT"..statIndex.."_NAME");
	label:SetText(statName..":");
	
	-- Set the tooltip text
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..statName.." ";

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
	statFrame.tooltip2 = getglobal("DEFAULT_STAT"..statIndex.."_TOOLTIP");
	local _, unitClass = UnitClass("player");
	unitClass = strupper(unitClass);
	
	if ( statIndex == 1 ) then
		local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
		statFrame.tooltip2 = format(statFrame.tooltip2, attackPower);
		if ( unitClass == "WARRIOR" or unitClass == "SHAMAN" or unitClass == "PALADIN" ) then
			statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format( STAT_BLOCK_TOOLTIP, effectiveStat*BLOCK_PER_STRENGTH );
		end
	elseif ( statIndex == 3 ) then
		local baseStam = min(20, effectiveStat);
		local moreStam = effectiveStat - baseStam;
		statFrame.tooltip2 = format(statFrame.tooltip2, (baseStam + (moreStam*HEALTH_PER_STAMINA))*GetUnitMaxHealthModifier("player"));
		local petStam = ComputePetBonus("PET_BONUS_STAM", effectiveStat );
		if( petStam > 0 ) then
			statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_STAMINA,petStam);
		end
	elseif ( statIndex == 2 ) then
		local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
		if ( attackPower > 0 ) then
			statFrame.tooltip2 = format(STAT_ATTACK_POWER, attackPower) .. format(statFrame.tooltip2, GetCritChanceFromAgility("player"), effectiveStat*ARMOR_PER_AGILITY);
		else
			statFrame.tooltip2 = format(statFrame.tooltip2, GetCritChanceFromAgility("player"), effectiveStat*ARMOR_PER_AGILITY);
		end
	elseif ( statIndex == 4 ) then
		local baseInt = min(20, effectiveStat);
		local moreInt = effectiveStat - baseInt
		if ( UnitHasMana("player") ) then
			statFrame.tooltip2 = format(statFrame.tooltip2, baseInt + moreInt*MANA_PER_INTELLECT, GetSpellCritChanceFromIntellect("player"));
		else
			statFrame.tooltip2 = nil;
		end
		local petInt = ComputePetBonus("PET_BONUS_INT", effectiveStat );
		if( petInt > 0 ) then
			if ( not statFrame.tooltip2 ) then
				statFrame.tooltip2 = "";
			end
			statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_INTELLECT,petInt);
		end
	elseif ( statIndex == 5 ) then
		-- All mana regen stats are displayed as mana/5 sec.
		statFrame.tooltip2 = format(statFrame.tooltip2, GetUnitHealthRegenRateFromSpirit("player"));
		if ( UnitHasMana("player") ) then
			local regen = GetUnitManaRegenRateFromSpirit("player");
			regen = floor( regen * 5.0 );
			statFrame.tooltip2 = statFrame.tooltip2.."\n"..format(MANA_REGEN_FROM_SPIRIT, regen);
		end
	end
end


function PaperDollFrame_SetRating(statFrame, ratingIndex)
	local label = getglobal(statFrame:GetName().."Label");
	local text = getglobal(statFrame:GetName().."StatText");
	local statName = getglobal("COMBAT_RATING_NAME"..ratingIndex);
	label:SetText(statName..":");
	local rating = GetCombatRating(ratingIndex);
	local ratingBonus = GetCombatRatingBonus(ratingIndex);
	text:SetText(rating);

	-- Set the tooltip text
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..statName.." "..rating..FONT_COLOR_CODE_CLOSE;
	-- Can probably axe this if else tree if all rating tooltips follow the same format
	if ( ratingIndex == CR_HIT_MELEE ) then
		statFrame.tooltip2 = format(CR_HIT_MELEE_TOOLTIP, UnitLevel("player"), ratingBonus, GetArmorPenetration());
	elseif ( ratingIndex == CR_HIT_RANGED ) then
		statFrame.tooltip2 = format(CR_HIT_RANGED_TOOLTIP, UnitLevel("player"), ratingBonus, GetArmorPenetration());
	elseif ( ratingIndex == CR_DODGE ) then
		statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, ratingBonus);
	elseif ( ratingIndex == CR_PARRY ) then
		statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, ratingBonus);
	elseif ( ratingIndex == CR_BLOCK ) then
		statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, ratingBonus);
	elseif ( ratingIndex == CR_HIT_SPELL ) then
		statFrame.tooltip2 = format(CR_HIT_SPELL_TOOLTIP, UnitLevel("player"), ratingBonus, GetSpellPenetration(), GetSpellPenetration());
	elseif ( ratingIndex == CR_CRIT_SPELL ) then
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
		minCrit = format("%.2f%%", minCrit);
		statFrame.minCrit = minCrit;
	elseif ( ratingIndex == CR_EXPERTISE ) then
		statFrame.tooltip2 = format(CR_EXPERTISE_TOOLTIP, ratingBonus);
	else
		statFrame.tooltip2 = HIGHLIGHT_FONT_COLOR_CODE..getglobal("COMBAT_RATING_NAME"..ratingIndex).." "..rating;	
	end
end

function PaperDollFrame_SetResistances()
	for i=1, NUM_RESISTANCE_TYPES, 1 do
		local resistance;
		local positive;
		local negative;
		local resistanceLevel;
		local base;
		local text = getglobal("MagicResText"..i);
		local frame = getglobal("MagicResFrame"..i);
		
		base, resistance, positive, negative = UnitResistance("player", frame:GetID());
		local petBonus = ComputePetBonus( "PET_BONUS_RES", resistance );

		local resistanceName = getglobal("RESISTANCE"..(frame:GetID()).."_NAME");
		frame.tooltip = resistanceName.." "..resistance;

		-- resistances can now be negative. Show Red if negative, Green if positive, white otherwise
		if( abs(negative) > positive ) then
			text:SetText(RED_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
		elseif( abs(negative) == positive ) then
			text:SetText(resistance);
		else
			text:SetText(GREEN_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
		end

		if ( positive ~= 0 or negative ~= 0 ) then
			-- Otherwise build up the formula
			frame.tooltip = frame.tooltip.. " ( "..HIGHLIGHT_FONT_COLOR_CODE..base;
			if( positive > 0 ) then
				frame.tooltip = frame.tooltip..GREEN_FONT_COLOR_CODE.." +"..positive;
			end
			if( negative < 0 ) then
				frame.tooltip = frame.tooltip.." "..RED_FONT_COLOR_CODE..negative;
			end
			frame.tooltip = frame.tooltip..FONT_COLOR_CODE_CLOSE.." )";
		end
		local unitLevel = UnitLevel("player");
		unitLevel = max(unitLevel, 20);
		local magicResistanceNumber = resistance/unitLevel;
		if ( magicResistanceNumber > 5 ) then
			resistanceLevel = RESISTANCE_EXCELLENT;
		elseif ( magicResistanceNumber > 3.75 ) then
			resistanceLevel = RESISTANCE_VERYGOOD;
		elseif ( magicResistanceNumber > 2.5 ) then
			resistanceLevel = RESISTANCE_GOOD;
		elseif ( magicResistanceNumber > 1.25 ) then
			resistanceLevel = RESISTANCE_FAIR;
		elseif ( magicResistanceNumber > 0 ) then
			resistanceLevel = RESISTANCE_POOR;
		else
			resistanceLevel = RESISTANCE_NONE;
		end
		frame.tooltipSubtext = format(RESISTANCE_TOOLTIP_SUBTEXT, getglobal("RESISTANCE_TYPE"..frame:GetID()), unitLevel, resistanceLevel);
		
		if( petBonus > 0 ) then
			frame.tooltipSubtext = frame.tooltipSubtext .. "\n" .. format(PET_BONUS_TOOLTIP_RESISTANCE, petBonus);
		end
	end
end

function PaperDollFrame_SetArmor(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end
	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor(unit);
	getglobal(statFrame:GetName().."Label"):SetText(ARMOR_COLON);
	local text = getglobal(statFrame:GetName().."StatText");

	PaperDollFormatStat(ARMOR, base, posBuff, negBuff, statFrame, text);
	local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitLevel(unit));
	statFrame.tooltip2 = format(DEFAULT_STATARMOR_TOOLTIP, armorReduction);
	
	if ( unit == "player" ) then
		local petBonus = ComputePetBonus("PET_BONUS_ARMOR", effectiveArmor );
		if( petBonus > 0 ) then
			statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_ARMOR, petBonus);
		end
	end
end

function PaperDollFrame_SetDefense(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end
	local base, modifier = UnitDefense(unit);
	local posBuff = 0;
	local negBuff = 0;
	if ( modifier > 0 ) then
		posBuff = modifier;
	elseif ( modifier < 0 ) then
		negBuff = modifier;
	end
	getglobal(statFrame:GetName().."Label"):SetText(DEFENSE_COLON);
	local text = getglobal(statFrame:GetName().."StatText");

	PaperDollFormatStat(DEFENSE, base, posBuff, negBuff, statFrame, text);
	local defensePercent = GetDodgeBlockParryChanceFromDefense();
	statFrame.tooltip2 = format(DEFAULT_STATDEFENSE_TOOLTIP, GetCombatRating(CR_DEFENSE_SKILL), GetCombatRatingBonus(CR_DEFENSE_SKILL), defensePercent, defensePercent);
end

function PaperDollFrame_SetDodge(statFrame)
	local chance = GetDodgeChance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_DODGE, chance, 1);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("DODGE_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
end

function PaperDollFrame_SetBlock(statFrame)
	local chance = GetBlockChance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_BLOCK, chance, 1);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("BLOCK_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_BLOCK_TOOLTIP, GetCombatRating(CR_BLOCK), GetCombatRatingBonus(CR_BLOCK), GetShieldBlock());
end

function PaperDollFrame_SetParry(statFrame)
	local chance = GetParryChance();
	PaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, chance, 1);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("PARRY_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
end

function GetDodgeBlockParryChanceFromDefense()
	local base, modifier = UnitDefense("player");
	--local defensePercent = DODGE_PARRY_BLOCK_PERCENT_PER_DEFENSE * modifier;
	local defensePercent = DODGE_PARRY_BLOCK_PERCENT_PER_DEFENSE * ((base + modifier) - (UnitLevel("player")*5));
	defensePercent = max(defensePercent, 0);
	return defensePercent;
end

function PaperDollFrame_SetResilience(statFrame)
	local resilience = GetCombatRating(CR_RESILIENCE_CRIT_TAKEN);
	local bonus = GetCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN);

	PaperDollFrame_SetLabelAndText(statFrame, STAT_RESILIENCE, resilience);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..STAT_RESILIENCE.." "..resilience..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(RESILIENCE_TOOLTIP, bonus, min(bonus * 2, 25.00), bonus);
end

function PaperDollFrame_SetDamage(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end
	getglobal(statFrame:GetName().."Label"):SetText(DAMAGE_COLON);
	local text = getglobal(statFrame:GetName().."StatText");
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

	if (percent == 0) then
		minDamage = 0;
		maxDamage = 0;
	else
		minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;
	end

	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local totalBonus = (fullDamage - baseDamage);
	local damagePerSecond;
	if speed == 0 then
		damagePerSecond = 0;
	else
		damagePerSecond = (max(fullDamage,1) / speed);
	end
	local damageTooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
	
	local colorPos = "|cff20ff20";
	local colorNeg = "|cffff2020";

	-- epsilon check
	if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
		totalBonus = 0.0;
	end

	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			text:SetText(displayMin.." - "..displayMax);	
		else
			text:SetText(displayMin.."-"..displayMax);
		end
	else
		
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
	statFrame.dps = damagePerSecond;
	
	-- If there's an offhand speed then add the offhand info to the tooltip
	if ( offhandSpeed ) then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local offhandDamagePerSecond;
		if offhandSpeed == 0 then
			offhandDamagePerSecond = 0;
		else
			offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed);
		end
		local offhandDamageTooltip = max(floor(minOffHandDamage),1).." - "..max(ceil(maxOffHandDamage),1);
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
end

function PaperDollFrame_SetAttackSpeed(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end
	local speed, offhandSpeed = UnitAttackSpeed(unit);
	speed = format("%.2f", speed);
	if ( offhandSpeed ) then
		offhandSpeed = format("%.2f", offhandSpeed);
	end
	local text;	
	if ( offhandSpeed ) then
		text = speed.." / "..offhandSpeed;
	else
		text = speed;
	end
	PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, text);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..ATTACK_SPEED.." "..text..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_MELEE), GetCombatRatingBonus(CR_HASTE_MELEE));
end

function PaperDollFrame_SetAttackPower(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end	
	getglobal(statFrame:GetName().."Label"):SetText(ATTACK_POWER_COLON);
	local text = getglobal(statFrame:GetName().."StatText");
	local base, posBuff, negBuff = UnitAttackPower(unit);

	PaperDollFormatStat(MELEE_ATTACK_POWER, base, posBuff, negBuff, statFrame, text);
	statFrame.tooltip2 = format(MELEE_ATTACK_POWER_TOOLTIP, max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER);
end

function PaperDollFrame_SetAttackBothHands(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end
	local mainHandAttackBase, mainHandAttackMod, offHandAttackBase, offHandAttackMod = UnitAttackBothHands(unit);

	getglobal(statFrame:GetName().."Label"):SetText(COMBAT_RATING_NAME1..":");
	local text = getglobal(statFrame:GetName().."StatText");

	if( mainHandAttackMod == 0 ) then
		text:SetText(mainHandAttackBase);
	else
		local color = RED_FONT_COLOR_CODE;
		if( mainHandAttackMod > 0 ) then
			color = GREEN_FONT_COLOR_CODE;
		end
		text:SetText(color..(mainHandAttackBase + mainHandAttackMod)..FONT_COLOR_CODE_CLOSE);
	end

	if( mainHandAttackMod == 0 ) then
		statFrame.weaponSkill = COMBAT_RATING_NAME1.." "..mainHandAttackBase;
	else
		local color = RED_FONT_COLOR_CODE;
		statFrame.weaponSkill = COMBAT_RATING_NAME1.." "..(mainHandAttackBase + mainHandAttackMod).." ("..mainHandAttackBase..color.." "..mainHandAttackMod..")";
		if( mainHandAttackMod > 0 ) then
			color = GREEN_FONT_COLOR_CODE;
			statFrame.weaponSkill = COMBAT_RATING_NAME1.." "..(mainHandAttackBase + mainHandAttackMod).." ("..mainHandAttackBase..color.." +"..mainHandAttackMod..FONT_COLOR_CODE_CLOSE..")";
		end
	end

	local total = GetCombatRating(CR_WEAPON_SKILL) + GetCombatRating(CR_WEAPON_SKILL_MAINHAND);
	statFrame.weaponRating = format(WEAPON_SKILL_RATING, total);
	if ( total > 0 ) then
		statFrame.weaponRating = statFrame.weaponRating..format(WEAPON_SKILL_RATING_BONUS, GetCombatRatingBonus(CR_WEAPON_SKILL) + GetCombatRatingBonus(CR_WEAPON_SKILL_MAINHAND));
	end

	local speed, offhandSpeed = UnitAttackSpeed(unit);
	if ( offhandSpeed ) then
		if( offHandAttackMod == 0 ) then
			statFrame.offhandSkill = COMBAT_RATING_NAME1.." "..offHandAttackBase;
		else
			local color = RED_FONT_COLOR_CODE;
			statFrame.offhandSkill = COMBAT_RATING_NAME1.." "..(offHandAttackBase + offHandAttackMod).." ("..offHandAttackBase..color.." "..offHandAttackMod..")";
			if( offHandAttackMod > 0 ) then
				color = GREEN_FONT_COLOR_CODE;
				statFrame.offhandSkill = COMBAT_RATING_NAME1.." "..(offHandAttackBase + offHandAttackMod).." ("..offHandAttackBase..color.." +"..offHandAttackMod..FONT_COLOR_CODE_CLOSE..")";
			end
		end

		total = GetCombatRating(CR_WEAPON_SKILL) + GetCombatRating(CR_WEAPON_SKILL_OFFHAND);
		statFrame.offhandRating = format(WEAPON_SKILL_RATING, total);
		if ( total > 0 ) then
			statFrame.offhandRating = statFrame.offhandRating..format(WEAPON_SKILL_RATING_BONUS, GetCombatRatingBonus(CR_WEAPON_SKILL) + GetCombatRatingBonus(CR_WEAPON_SKILL_OFFHAND));
		end
	else
		statFrame.offhandSkill = nil;
	end
end

function PaperDollFrame_SetRangedAttack(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	elseif ( unit == "pet" ) then
		return;
	end

	local hasRelic = UnitHasRelicSlot(unit);
	local rangedAttackBase, rangedAttackMod = UnitRangedAttack(unit);
	getglobal(statFrame:GetName().."Label"):SetText(COMBAT_RATING_NAME1..":");
	local text = getglobal(statFrame:GetName().."StatText");

	-- If no ranged texture then set stats to n/a
	local rangedTexture = GetInventoryItemTexture("player", 18);
	if ( rangedTexture and not hasRelic ) then
		PaperDollFrame.noRanged = nil;
	else
		text:SetText(NOT_APPLICABLE);
		PaperDollFrame.noRanged = 1;
		statFrame.tooltip = nil;
	end
	if ( not rangedTexture or hasRelic ) then
		return;
	end
	
	if( rangedAttackMod == 0 ) then
		text:SetText(rangedAttackBase);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..COMBAT_RATING_NAME1.." "..rangedAttackBase..FONT_COLOR_CODE_CLOSE;
	else
		local color = RED_FONT_COLOR_CODE;
		if( rangedAttackMod > 0 ) then
	  		color = GREEN_FONT_COLOR_CODE;
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..COMBAT_RATING_NAME1.." "..(rangedAttackBase + rangedAttackMod).." ("..rangedAttackBase..color.." +"..rangedAttackMod..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")";
		else
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..COMBAT_RATING_NAME1.." "..(rangedAttackBase + rangedAttackMod).." ("..rangedAttackBase..color.." "..rangedAttackMod..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")";
		end
		text:SetText(color..(rangedAttackBase + rangedAttackMod)..FONT_COLOR_CODE_CLOSE);
	end
	local total = GetCombatRating(CR_WEAPON_SKILL) + GetCombatRating(CR_WEAPON_SKILL_RANGED);
	statFrame.tooltip2 = format(WEAPON_SKILL_RATING, total);
	if ( total > 0 ) then
		statFrame.tooltip2 = statFrame.tooltip2..format(WEAPON_SKILL_RATING_BONUS, GetCombatRatingBonus(CR_WEAPON_SKILL) + GetCombatRatingBonus(CR_WEAPON_SKILL_RANGED));
	end
end

function PaperDollFrame_SetRangedDamage(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	elseif ( unit == "pet" ) then
		return;
	end
	getglobal(statFrame:GetName().."Label"):SetText(DAMAGE_COLON);
	local text = getglobal(statFrame:GetName().."StatText");

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
		damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
		tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
	else
		minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

		baseDamage = (minDamage + maxDamage) * 0.5;
		fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		totalBonus = (fullDamage - baseDamage);
		if (rangedAttackSpeed == 0) then
		-- Egan's Blaster!!!
			damagePerSecond = math.huge;
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
end

function PaperDollFrame_SetRangedAttackSpeed(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	elseif ( unit == "pet" ) then
		return;
	end
	local text;
	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		text = NOT_APPLICABLE;
		statFrame.tooltip = nil;
	else
		text = UnitRangedDamage(unit);
		text = format("%.2f", text);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..ATTACK_SPEED.." "..text..FONT_COLOR_CODE_CLOSE;
	end
	PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, text);
	statFrame.tooltip2 = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_RANGED), GetCombatRatingBonus(CR_HASTE_RANGED));
end

function PaperDollFrame_SetRangedAttackPower(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end	
	getglobal(statFrame:GetName().."Label"):SetText(ATTACK_POWER_COLON);
	local text = getglobal(statFrame:GetName().."StatText");
	local base, posBuff, negBuff = UnitRangedAttackPower(unit);

	PaperDollFormatStat(RANGED_ATTACK_POWER, base, posBuff, negBuff, statFrame, text);
	local totalAP = base+posBuff+negBuff;
	statFrame.tooltip2 = format(RANGED_ATTACK_POWER_TOOLTIP, max((totalAP), 0)/ATTACK_POWER_MAGIC_NUMBER);
	local petAPBonus = ComputePetBonus( "PET_BONUS_RAP_TO_AP", totalAP );
	if( petAPBonus > 0 ) then
		statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER, math.floor(petAPBonus));
	end
	
	local petSpellDmgBonus = ComputePetBonus( "PET_BONUS_RAP_TO_SPELLDMG", totalAP );
	if( petSpellDmgBonus > 0 ) then
		statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_SPELLDAMAGE, math.floor(petSpellDmgBonus));
	end
end

function PaperDollFrame_SetSpellBonusDamage(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(BONUS_DAMAGE..":");
	local text = getglobal(statFrame:GetName().."StatText");
	local holySchool = 2;
	-- Start at 2 to skip physical damage
	local minModifier = GetSpellBonusDamage(holySchool);
	statFrame.bonusDamage = {};
	statFrame.bonusDamage[holySchool] = minModifier;
	local bonusDamage;
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		bonusDamage = GetSpellBonusDamage(i);
		minModifier = min(minModifier, bonusDamage);
		statFrame.bonusDamage[i] = bonusDamage;
	end
	text:SetText(minModifier);
	statFrame.minModifier = minModifier;
end

function PaperDollFrame_SetSpellCritChance(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(SPELL_CRIT_CHANCE..":");
	local text = getglobal(statFrame:GetName().."StatText");
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
	-- Add agility contribution
	--minCrit = minCrit + GetSpellCritChanceFromIntellect();
	minCrit = format("%.2f%%", minCrit);
	text:SetText(minCrit);
	statFrame.minCrit = minCrit;
end

function PaperDollFrame_SetMeleeCritChance(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(MELEE_CRIT_CHANCE..":");
	local text = getglobal(statFrame:GetName().."StatText");
	local critChance = GetCritChance();-- + GetCritChanceFromAgility();
	critChance = format("%.2f%%", critChance);
	text:SetText(critChance);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..MELEE_CRIT_CHANCE.." "..critChance..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_CRIT_MELEE_TOOLTIP, GetCombatRating(CR_CRIT_MELEE), GetCombatRatingBonus(CR_CRIT_MELEE));
end

function PaperDollFrame_SetRangedCritChance(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(RANGED_CRIT_CHANCE..":");
	local text = getglobal(statFrame:GetName().."StatText");
	local critChance = GetRangedCritChance();-- + GetCritChanceFromAgility();
	critChance = format("%.2f%%", critChance);
	text:SetText(critChance);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..RANGED_CRIT_CHANCE.." "..critChance..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_CRIT_RANGED_TOOLTIP, GetCombatRating(CR_CRIT_RANGED), GetCombatRatingBonus(CR_CRIT_RANGED));
end

function PaperDollFrame_SetSpellBonusHealing(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(BONUS_HEALING..":");
	local text = getglobal(statFrame:GetName().."StatText");
	local bonusHealing = GetSpellBonusHealing();
	text:SetText(bonusHealing);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. BONUS_HEALING .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 =format(BONUS_HEALING_TOOLTIP, bonusHealing);
end

function PaperDollFrame_SetSpellPenetration(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(SPELL_PENETRATION..":");
	local text = getglobal(statFrame:GetName().."StatText");
	text:SetText(GetSpellPenetration());
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. SPELL_PENETRATION .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = SPELL_PENETRATION_TOOLTIP;
end

function PaperDollFrame_SetSpellHaste(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(SPELL_HASTE..":");
	local text = getglobal(statFrame:GetName().."StatText");
	text:SetText(GetCombatRating(CR_HASTE_SPELL));
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. SPELL_HASTE .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(SPELL_HASTE_TOOLTIP, GetCombatRatingBonus(CR_HASTE_SPELL));
end

function PaperDollFrame_SetManaRegen(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(MANA_REGEN..":");
	local text = getglobal(statFrame:GetName().."StatText");
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
	statFrame.tooltip2 = format(MANA_REGEN_TOOLTIP, base, casting);
end

function PaperDollFrame_SetExpertise(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end
	local expertise, offhandExpertise = GetExpertise();
	local speed, offhandSpeed = UnitAttackSpeed(unit);
	local text;
	if( offhandSpeed ) then
		text = expertise.." / "..offhandExpertise;
	else
		text = expertise;
	end
	PaperDollFrame_SetLabelAndText(statFrame, STAT_EXPERTISE, text);
	
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("COMBAT_RATING_NAME"..CR_EXPERTISE).." "..text..FONT_COLOR_CODE_CLOSE;
	
	local expertisePercent, offhandExpertisePercent = GetExpertisePercent();
	expertisePercent = format("%.2f", expertisePercent);
	if( offhandSpeed ) then
		offhandExpertisePercent = format("%.2f", offhandExpertisePercent);
		text = expertisePercent.."% / "..offhandExpertisePercent.."%";
	else
		text = expertisePercent.."%";
	end
	statFrame.tooltip2 = format(CR_EXPERTISE_TOOLTIP, text, GetCombatRating(CR_EXPERTISE), GetCombatRatingBonus(CR_EXPERTISE));
end

function CharacterSpellBonusDamage_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..BONUS_DAMAGE.." "..self.minModifier..FONT_COLOR_CODE_CLOSE);
	for i=2, MAX_SPELL_SCHOOLS do
		GameTooltip:AddDoubleLine(getglobal("DAMAGE_SCHOOL"..i), self.bonusDamage[i], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..i);
	end
	
	local petStr, damage;
	if( self.bonusDamage[6] > self.bonusDamage[3] ) then
		petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG_SHADOW;
		damage = self.bonusDamage[6];
	else
		petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG_FIRE;
		damage = self.bonusDamage[3];
	end
	
	local petBonusAP = ComputePetBonus("PET_BONUS_SPELLDMG_TO_AP", damage );
	local petBonusDmg = ComputePetBonus("PET_BONUS_SPELLDMG_TO_SPELLDMG", damage );
	if( petBonusAP > 0 or petBonusDmg > 0 ) then
		GameTooltip:AddLine("\n" .. format(petStr, petBonusAP, petBonusDmg), nil, nil, nil, 1 );
	end
	GameTooltip:Show();
end

function CharacterSpellCritChance_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..COMBAT_RATING_NAME11.." "..GetCombatRating(11)..FONT_COLOR_CODE_CLOSE);
	local spellCrit;
	for i=2, MAX_SPELL_SCHOOLS do
		spellCrit = format("%.2f", self.spellCrit[i]);
		spellCrit = spellCrit.."%";
		GameTooltip:AddDoubleLine(getglobal("DAMAGE_SCHOOL"..i), spellCrit, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..i);
	end
	GameTooltip:Show();
end

function CharacterDamageFrame_OnEnter(self)
	-- Main hand weapon
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(INVTYPE_WEAPONMAINHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2F", self.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(DAMAGE_COLON, self.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1F", self.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	-- Check for offhand weapon
	if ( self.offhandAttackSpeed ) then
		GameTooltip:AddLine(" "); -- Blank line.
		GameTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2F", self.offhandAttackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(DAMAGE_COLON, self.offhandDamage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1F", self.offhandDps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	GameTooltip:Show();
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

function CharacterRangedDamageFrame_OnEnter(self)
	if ( not self.damage ) then
		return;
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(INVTYPE_RANGED, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2F", self.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(DAMAGE_COLON, self.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1F", self.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:Show();
end

function PaperDollFrame_GetArmorReduction(armor, attackerLevel)
	local levelModifier = attackerLevel;
	if ( levelModifier > 59 ) then
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

	return format("%.2f", (temp*100));
end

function PaperDollFormatStat(name, base, posBuff, negBuff, frame, textString)
	local effective = max(0,base + posBuff + negBuff);
	local text = HIGHLIGHT_FONT_COLOR_CODE..name.." "..effective;
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

function PaperDollStatTooltip(self)
	if ( not self.tooltip ) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.tooltip, 1.0, 1.0, 1.0);
	if ( self.tooltip2 ) then
		GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
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

--[[ ITEM SLOT FUNCTIONS ]]

function PaperDollItemSlotButton_OnLoad(self)
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
end

function PaperDollItemSlotButton_OnShow(self, isBag)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("CURSOR_UPDATE");
	self:RegisterEvent("UPDATE_INVENTORY_ALERTS");
	if ( not isBag ) then
		self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	end
	PaperDollItemSlotButton_Update(self);
end

function PaperDollItemSlotButton_OnHide(self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("CURSOR_UPDATE");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
end

function PaperDollItemSlotButton_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		if ( self:GetID() == arg1 ) then
			PaperDollItemSlotButton_Update(self);
		end
	elseif ( event == "UNIT_INVENTORY_CHANGED" ) then
		if ( arg1 == "player" ) then
			PaperDollItemSlotButton_Update(self);
		end
		return;
	elseif ( event == "BAG_UPDATE" ) then
		PaperDollItemSlotButton_Update(self);
		return;
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
	elseif ( event == "UPDATE_INVENTORY_ALERTS" ) then
		PaperDollItemSlotButton_Update(self);
	end
end

function PaperDollItemSlotButton_OnClick(self, button)
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

function PaperDollItemSlotButton_OnModifiedClick(self, button)
	if ( IsModifiedClick("EXPANDITEM") ) then
		local itemLocation = ItemLocation:CreateFromEquipmentSlot(self:GetID());
		if C_Item.DoesItemExist(itemLocation) then
			SocketInventoryItem(self:GetID());
		end
		return;
	end
	if ( HandleModifiedItemClick(GetInventoryItemLink("player", self:GetID())) ) then
		return;
	end
end

function PaperDollItemSlotButton_Update(self)
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
			CooldownFrame_Set(cooldown, start, duration, enable);
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

	PaperDollItemSlotButton_UpdateLock(self);

	-- Update repair all button status
	MerchantFrame_UpdateCanRepairAll();
end

function PaperDollItemSlotButton_UpdateLock(self)
	if ( IsInventoryItemLocked(self:GetID()) ) then
		SetItemButtonDesaturated(self, true);
	else
		SetItemButtonDesaturated(self, false);
	end
end

function PaperDollItemSlotButton_OnEnter(self)
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", self:GetID(), nil, true);
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

function PaperDollItemSlotButton_OnLeave(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	GameTooltip:Hide();
	ResetCursor();
end


