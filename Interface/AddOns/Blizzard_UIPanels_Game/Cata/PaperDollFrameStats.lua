function Expertise_OnEnter(statFrame)

	if (MOVING_STAT_CATEGORY) then return; end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");

	-- Expertise and expertise percent values are the same from MoP onward, but the values are different
	-- prior to MoP, hence why we need both here.
	local expertise, offhandExpertise, rangedExpertise = GetExpertise();
	local expertisePercent, offhandExpertisePercent, rangedExpertisePercent = GetExpertisePercent();
	expertisePercent = format("%.2F%%", expertisePercent);
	offhandExpertisePercent = format("%.2F%%", offhandExpertisePercent);
	rangedExpertisePercent = format("%.2F%%", rangedExpertisePercent);

	local category = statFrame:GetParent().Category;
	
	local expertiseDisplay, expertisePercentDisplay;
	if (category == "MELEE" and IsDualWielding()) then
		expertiseDisplay = expertise.." / "..offhandExpertise;
		expertisePercentDisplay = expertisePercent.." / "..offhandExpertisePercent;
	elseif (category == "RANGED") then
		expertiseDisplay = rangedExpertise;
		expertisePercentDisplay = rangedExpertisePercent;
	else
		expertiseDisplay = expertise;
		expertisePercentDisplay = expertisePercent;
	end
	
	local expertiseTooltip;
	if (category == "MELEE") then
		expertiseTooltip = CR_EXPERTISE_TOOLTIP;
	else
		expertiseTooltip = CR_RANGED_EXPERTISE_TOOLTIP;
	end

	if ClassicExpansionAtLeast(LE_EXPANSION_MISTS_OF_PANDARIA) then
		GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G["COMBAT_RATING_NAME"..CR_EXPERTISE]).." "..expertisePercentDisplay..FONT_COLOR_CODE_CLOSE);
	else
		GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G["COMBAT_RATING_NAME"..CR_EXPERTISE]).." "..expertiseDisplay..FONT_COLOR_CODE_CLOSE);
	end
	
	GameTooltip:AddLine(format(expertiseTooltip, expertisePercentDisplay, BreakUpLargeNumbers(GetCombatRating(CR_EXPERTISE)), GetCombatRatingBonus(CR_EXPERTISE)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	GameTooltip:AddLine(" ");
	
	-- Dodge chance
	GameTooltip:AddDoubleLine(STAT_TARGET_LEVEL, DODGE_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	local playerLevel = UnitLevel("player");
	for i=0, 3 do
		local mainhandDodge, offhandDodge, rangedDodge = GetEnemyDodgeChance(i);
		mainhandDodge = format("%.2F%%", mainhandDodge);
		offhandDodge = format("%.2F%%", offhandDodge);
		rangedDodge = format("%.2F%%", rangedDodge);
		local level = playerLevel + i;
		if (i == 3) then
			level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
		end
		local dodgeDisplay;
		if (category == "MELEE" and IsDualWielding() and mainhandDodge ~= offhandDodge) then
			dodgeDisplay = mainhandDodge.." / "..offhandDodge;
		elseif (category == "RANGED") then
			dodgeDisplay = rangedDodge.."  ";
		else
			dodgeDisplay = mainhandDodge.."  ";
		end
		GameTooltip:AddDoubleLine("      "..level, dodgeDisplay.."  ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	
	-- Parry chance
	if ( category == "MELEE" ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddDoubleLine(STAT_TARGET_LEVEL, PARRY_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
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
	end
		
	GameTooltip:Show();
end

function PaperDollFrame_SetExpertise(statFrame, unit, usePercent)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	local category = statFrame:GetParent().Category;

	local expertise, offhandExpertise, rangedExpertise = GetExpertise();
	if usePercent then
		expertise = format("%.2F%%", expertise);
		offhandExpertise = format("%.2F%%", offhandExpertise);
		rangedExpertise = format("%.2F%%", rangedExpertise);
	end
	local speed, offhandSpeed = UnitAttackSpeed(unit);
	local text;
	if( category == "MELEE" and offhandSpeed ) then
		text = expertise.." / "..offhandExpertise;
	elseif (category == "RANGED") then
		text = rangedExpertise;
	else
		text = expertise;
	end
	PaperDollFrame_SetLabelAndText(statFrame, STAT_EXPERTISE, text, false, expertise);
	PaperDollFrame_SetOnEnter(statFrame, Expertise_OnEnter)
	statFrame:Show();

	return expertise;
end
