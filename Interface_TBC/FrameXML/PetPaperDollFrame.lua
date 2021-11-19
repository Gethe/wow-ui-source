NUM_PET_RESISTANCE_TYPES = 5;
NUM_PET_STATS = 5;

function PetPaperDollFrame_OnLoad(self)
	self:RegisterEvent("PET_UI_UPDATE");
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterEvent("PET_UI_CLOSE");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_PET_EXPERIENCE");
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_RESISTANCES");
	self:RegisterEvent("UNIT_STATS");
	self:RegisterEvent("UNIT_DAMAGE");
	self:RegisterEvent("UNIT_RANGEDDAMAGE");
	self:RegisterEvent("UNIT_ATTACK_SPEED");
	self:RegisterEvent("UNIT_ATTACK_POWER");
	self:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
	self:RegisterEvent("UNIT_DEFENSE");
	self:RegisterEvent("UNIT_ATTACK");
	self:RegisterEvent("UNIT_PET_TRAINING_POINTS");
	PetTab_Update();
end

function PetPaperDollFrame_OnEvent(self, event, arg1, ...)
	if ( event == "PET_UI_UPDATE" or event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and arg1 == "player") ) then
		if ( PetPaperDollFrame:IsVisible() and not HasPetUI() ) then
			ToggleCharacter("PetPaperDollFrame");
		end
		PetTab_Update();
		PetPaperDollFrame_Update();
	elseif ( event == "PET_UI_CLOSE" ) then
		if ( PetPaperDollFrame:IsVisible() ) then
			ToggleCharacter("PetPaperDollFrame");
		end
		PetTab_Update();
	elseif ( event == "UNIT_PET_EXPERIENCE" ) then
		PetExpBar_Update();
	elseif ( arg1 == "pet" ) then
		PetPaperDollFrame_Update();
	end
end

function PetPaperDollFrame_OnShow()
	CharacterNameText:Hide();
	PetNameText:Show();
	PetNameText:SetText(UnitName("pet"));
	PetPaperDollFrame_Update()
end

function PetPaperDollFrame_OnHide()
	CharacterNameText:Show();
	PetNameText:Hide();
end

function PetPaperDollFrame_Update()
	local hasPetUI, canGainXP = HasPetUI();
	if ( not hasPetUI ) then
		return;
	end
	PetModelFrame:SetUnit("pet");
	if ( UnitCreatureFamily("pet") ) then
		PetLevelText:SetText(format(UNIT_LEVEL_TEMPLATE,UnitLevel("pet")).." "..UnitCreatureFamily("pet"));
	end
	PetLoyaltyText:SetText(GetPetLoyalty());
	PetExpBar_Update();
	PetPaperDollFrame_SetResistances();
	PetPaperDollFrame_SetStats();
	PaperDollFrame_SetDamage(PetDamageFrame, "Pet");
	PaperDollFrame_SetArmor(PetArmorFrame, "Pet");
	PaperDollFrame_SetAttackPower(PetAttackPowerFrame, "Pet");
	PetPaperDollFrame_SetSpellBonusDamage();

	if ( canGainXP ) then
		PetPaperDollPetInfo:Show();
		local totalPoints, spent = GetPetTrainingPoints();
		PetTrainingPointText:SetText(totalPoints - spent);
		PetTrainingPointText:Show();
		PetTrainingPointLabel:Show();
	else
		PetPaperDollPetInfo:Hide();
		PetTrainingPointText:Hide();
		PetTrainingPointLabel:Hide();
	end
end

function PetPaperDollFrame_SetResistances()
	local resistance;
	local positive;
	local negative;
	local base;
	local index;
	local text;
	local frame;
	for i=1, NUM_PET_RESISTANCE_TYPES, 1 do
		index = i + 1;
		if ( i == NUM_PET_RESISTANCE_TYPES ) then
			index = 1;
		end
		text = _G["PetMagicResText"..i];
		frame = _G["PetMagicResFrame"..i];
		
		base, resistance, positive, negative = UnitResistance("pet", frame:GetID());

		frame.tooltip = _G["RESISTANCE"..frame:GetID().."_NAME"];
	
		-- resistances can now be negative. Show Red if negative, Green if positive, white otherwise
		if( resistance < 0 ) then
			text:SetText(RED_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
		elseif( resistance == 0 ) then
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
	end
end

function PetPaperDollFrame_SetStats()
	for i=1, NUM_PET_STATS, 1 do
		local label = getglobal("PetStatFrame"..i.."Label");
		local text = getglobal("PetStatFrame"..i.."StatText");
		local frame = getglobal("PetStatFrame"..i);
		local stat;
		local effectiveStat;
		local posBuff;
		local negBuff;
		label:SetText(getglobal("SPELL_STAT"..i.."_NAME")..":");
		stat, effectiveStat, posBuff, negBuff = UnitStat("pet", i);
		-- Set the tooltip text
		local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..getglobal("SPELL_STAT"..i.."_NAME").." ";

		if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
			text:SetText(effectiveStat);
			frame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE;
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
			frame.tooltip = tooltipText;

			-- If there are any negative buffs then show the main number in red even if there are
			-- positive buffs. Otherwise show in green.
			if ( negBuff < 0 ) then
				text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
			else
				text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
			end
		end
		
		-- Second tooltip line
		frame.tooltip2 = getglobal("DEFAULT_STAT"..i.."_TOOLTIP");
		if ( i == 1 ) then
			local attackPower = 2*effectiveStat-20;
			frame.tooltip2 = format(frame.tooltip2, attackPower);
		elseif ( i == 2 ) then
			local newLineIndex = strfind(frame.tooltip2, "|n")+1;
			frame.tooltip2 = strsub(frame.tooltip2, 1, newLineIndex);
			frame.tooltip2 = format(frame.tooltip2, GetCritChanceFromAgility("pet"));
		elseif ( i == 3 ) then
			local expectedHealthGain = (((stat - posBuff - negBuff)-20)*10+20)*GetUnitHealthModifier("pet");
			local realHealthGain = ((effectiveStat-20)*10+20)*GetUnitHealthModifier("pet");
			local healthGain = (realHealthGain - expectedHealthGain)*GetUnitMaxHealthModifier("pet");
			frame.tooltip2 = format(frame.tooltip2, healthGain);
		elseif ( i == 4 ) then
			if ( UnitHasMana("pet") ) then
				local manaGain = ((effectiveStat-20)*15+20)*GetUnitPowerModifier("pet");
				frame.tooltip2 = format(frame.tooltip2, manaGain, GetSpellCritChanceFromIntellect("pet"));
			else
				local newLineIndex = strfind(frame.tooltip2, "|n")+2;
				frame.tooltip2 = strsub(frame.tooltip2, newLineIndex);
				frame.tooltip2 = format(frame.tooltip2, GetSpellCritChanceFromIntellect("pet"));
			end
		elseif ( i == 5 ) then
			frame.tooltip2 = format(frame.tooltip2, GetUnitHealthRegenRateFromSpirit("pet"));
			if ( UnitHasMana("pet") ) then
				frame.tooltip2 = frame.tooltip2.."\n"..format(MANA_REGEN_FROM_SPIRIT, GetUnitManaRegenRateFromSpirit("pet"));
			end
		end
	end
end

function PetPaperDollFrame_SetSpellBonusDamage()
	local unitClass = UnitClass("player");
	unitClass = strupper(unitClass);
	local spellDamageBonus = 0;
	if( unitClass == "WARLOCK" ) then
		local bonusFireDamage = GetSpellBonusDamage(3);
		local bonusShadowDamage = GetSpellBonusDamage(6);
		if ( bonusShadowDamage > bonusFireDamage ) then
			spellDamageBonus =  ComputePetBonus("PET_BONUS_SPELLDMG_TO_SPELLDMG", bonusShadowDamage);
		else
			spellDamageBonus =  ComputePetBonus("PET_BONUS_SPELLDMG_TO_SPELLDMG", bonusFireDamage);
		end
	elseif( unitClass == "HUNTER" ) then
		local base, posBuff, negBuff = UnitRangedAttackPower("player");
		local totalAP = base+posBuff+negBuff;
		spellDamageBonus = ComputePetBonus( "PET_BONUS_RAP_TO_SPELLDMG", totalAP );
	end
	local spellDamageBonusText = format("%d",spellDamageBonus);

	PetSpellDamageFrameLabel:SetText(SPELL_BONUS_COLON);
	if ( spellDamageBonus > 0 ) then
		spellDamageBonusText = GREEN_FONT_COLOR_CODE.."+"..spellDamageBonusText..FONT_COLOR_CODE_CLOSE;
	elseif( spellDamageBonus < 0 ) then
		spellDamageBonusText = RED_FONT_COLOR_CODE..spellDamageBonusText..FONT_COLOR_CODE_CLOSE;
	end

	PetSpellDamageFrameStatText:SetText(spellDamageBonusText);
	PetSpellDamageFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..SPELL_BONUS..FONT_COLOR_CODE_CLOSE.." "..spellDamageBonusText;
	PetSpellDamageFrame.tooltip2 = DEFAULT_STATSPELLBONUS_TOOLTIP;

	PetSpellDamageFrame:Show();
end

function PetExpBar_Update()
	local currXP, nextXP = GetPetExperience();
	PetPaperDollFrameExpBar:SetMinMaxValues(min(0, currXP), nextXP);
	PetPaperDollFrameExpBar:SetValue(currXP);
	if (nextXP == 0) then
		PetPaperDollFrameExpBar:Hide();
	else
		PetPaperDollFrameExpBar:Show();
	end
end

function PetTab_Update()
	-- If doesn't have a petUI then disable the pet tab and return
	if ( not HasPetUI() ) then
		CharacterFrameTab2:Hide();
		CharacterFrameTab3:SetPoint("LEFT", "CharacterFrameTab2", "LEFT", 0, 0);
	else
		CharacterFrameTab2:Show();
		CharacterFrameTab3:SetPoint("LEFT", "CharacterFrameTab2", "RIGHT", -16, 0);
	end
end
