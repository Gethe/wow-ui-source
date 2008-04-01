NUM_PET_RESISTANCE_TYPES = 5;
NUM_PET_STATS = 5;

function PetPaperDollFrame_OnLoad()
	this:RegisterEvent("PET_UI_UPDATE");
	this:RegisterEvent("PET_UI_CLOSE");
	this:RegisterEvent("PLAYER_PET_CHANGED");
	this:RegisterEvent("UNIT_PET_EXPERIENCE");
	this:RegisterEvent("UNIT_MODEL_CHANGED");
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_RESISTANCES");
	this:RegisterEvent("UNIT_STATS");
	this:RegisterEvent("UNIT_DAMAGE");
	this:RegisterEvent("UNIT_RANGEDDAMAGE");
	this:RegisterEvent("UNIT_ATTACK_SPEED");
	this:RegisterEvent("UNIT_ATTACK_POWER");
	this:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
	this:RegisterEvent("UNIT_DEFENSE");
	this:RegisterEvent("UNIT_ATTACK");
	this:RegisterEvent("UNIT_PET_TRAINING_POINTS");
	PetAttackFrameLabel:SetText(TEXT(ATTACK_COLON));
	PetDamageFrameLabel:SetText(TEXT(DAMAGE_COLON));
	PetAttackPowerFrameLabel:SetText(TEXT(ATTACK_POWER_COLON));
	PetDefenseFrameLabel:SetText(TEXT(DEFENSE_COLON));
	PetArmorFrameLabel:SetText(TEXT(ARMOR_COLON));
	SetTextStatusBarTextPrefix(PetPaperDollFrameExpBar, TEXT(XP));
end

function PetPaperDollFrame_OnEvent()
	if ( event == "PET_UI_UPDATE" or event == "PLAYER_PET_CHANGED" ) then
		PetTab_Update();
		PetPaperDollFrame_Update();
	elseif ( event == "PET_UI_CLOSE" ) then
		PetTab_Update();
		HideUIPanel(this:GetParent());
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
	if ( not HasPetUI() ) then
		return;
	end
	PetModelFrame:SetUnit("pet");
	if ( UnitCreatureFamily("pet") ) then
		PetLevelText:SetText(format(TEXT(UNIT_LEVEL_TEMPLATE),UnitLevel("pet")).." "..UnitCreatureFamily("pet"));
	end
	PetLoyaltyText:SetText(GetPetLoyalty());
	local totalPoints, spent = GetPetTrainingPoints();
	PetTrainingPointText:SetText(totalPoints - spent);
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
		text = getglobal("PetMagicResText"..i);
		frame = getglobal("PetMagicResFrame"..i);
		
		base, resistance, positive, negative = UnitResistance("pet", frame:GetID());

		frame.tooltip = TEXT(getglobal("RESISTANCE"..frame:GetID().."_NAME"));
	
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
		label:SetText(TEXT(getglobal("SPELL_STAT"..(i-1).."_NAME"))..":");
		stat, effectiveStat, posBuff, negBuff = UnitStat("pet", i);
		-- Set the tooltip text
		local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..getglobal("SPELL_STAT"..(i-1).."_NAME").." ";

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
	end
end

function PetExpBar_Update()
	local currXP, nextXP = GetPetExperience();
	PetPaperDollFrameExpBar:SetMinMaxValues(min(0, currXP), nextXP);
	PetPaperDollFrameExpBar:SetValue(currXP);
end

function PetTab_Update()
	-- If doesn't have a petUI then disable the pet tab and return
	if ( not HasPetUI() ) then
		CharacterFrameTab2:Hide();
		CharacterFrameTab3:SetPoint("LEFT", "CharacterFrameTab2", "LEFT", 0, 0);
		if ( PetPaperDollFrame:IsVisible() ) then
			HideUIPanel(CharacterFrame);
		end
		return;
	else
		CharacterFrameTab2:Show();
		CharacterFrameTab3:SetPoint("LEFT", "CharacterFrameTab2", "RIGHT", -15, 0);
	end
end
