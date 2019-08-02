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
	PaperDollFrame_SetDamage("pet", "Pet");
	PaperDollFrame_SetRangedDamage("pet", "Pet");
	PaperDollFrame_SetAttackPower("pet", "Pet");
	PaperDollFrame_SetRangedAttackPower("pet", "Pet");
	PaperDollFrame_SetArmor("pet", "Pet");
	PaperDollFrame_SetAttackBothHands("pet", "Pet");
	PaperDollFrame_SetDefense("pet", "Pet");

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
		local label = _G["PetStatFrame"..i.."Label"];
		local text = _G["PetStatFrame"..i.."StatText"];
		local frame = _G["PetStatFrame"..i];
		local stat;
		local effectiveStat;
		local posBuff;
		local negBuff;
		label:SetText(_G["SPELL_STAT"..(i).."_NAME"]..":");
		stat, effectiveStat, posBuff, negBuff = UnitStat("pet", i);

		-- Set the tooltip text
		local tooltipText = HIGHLIGHT_FONT_COLOR_CODE.._G["SPELL_STAT"..(i).."_NAME"].." ";
		-- Get class specific tooltip for that stat
		local temp, classFileName = UnitClass("pet");
		local classStatText = _G[strupper(classFileName).."_"..frame.stat.."_".."TOOLTIP"];
		-- If can't find one use the default
		if ( not classStatText ) then
			classStatText = _G["DEFAULT".."_"..frame.stat.."_".."TOOLTIP"];
		end

		--[[ In 1.12, UnitStat didn't report positive / negative buffs for units that weren't the active player.
			 To replicate this, we just won't include modifiers (e.g. green / red coloring) in the UI. ]]
		text:SetText(effectiveStat);
		frame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE;
		frame.tooltip2 = classStatText;
	end
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
