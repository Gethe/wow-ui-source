SKILLS_TO_DISPLAY = 12;
SKILLFRAME_SKILL_HEIGHT = 15;

function SkillFrame_OnShow()
	SkillFrame_UpdateSkills();
end

function SkillFrame_OnLoad()
	this:RegisterEvent("SKILL_LINES_CHANGED");
	this:RegisterEvent("CHARACTER_POINTS_CHANGED");
	SkillListScrollFrameScrollBar:SetValue(0);
	SetSelectedSkill(0);
	SkillFrame.statusBarClickedID = 0;
	SkillFrame.showSkillDetails = nil;
	SkillFrame_UpdateSkills();
end

function SkillFrame_OnEvent(event)
	if ( SkillFrame:IsVisible() ) then
		SkillFrame_UpdateSkills();
	end
end

function SkillFrame_SetStatusBar(statusBarID, skillIndex, numSkills, adjustedSkillPoints)
	-- Get info
	local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType = GetSkillLineInfo(skillIndex);
	skillRankStart = skillRank;
	skillRank = skillRank + numTempPoints;

	-- Skill bar objects
	local statusBar = getglobal("SkillRankFrame"..statusBarID);
	local statusBarLabel = "SkillRankFrame"..statusBarID;
	local statusBarSkillRank = getglobal("SkillRankFrame"..statusBarID.."SkillRank");
	local statusBarName = getglobal("SkillRankFrame"..statusBarID.."SkillName");
	local statusBarBorder = getglobal("SkillRankFrame"..statusBarID.."Border");
	local statusBarBackground = getglobal("SkillRankFrame"..statusBarID.."Background");
	local statusBarFillBar = getglobal("SkillRankFrame"..statusBarID.."FillBar");

	statusBarFillBar:Hide();

	-- Header objects
	local skillRankFrameBorderTexture = getglobal("SkillRankFrame"..statusBarID.."Border");
	local skillTypeLabelText = getglobal("SkillTypeLabel"..statusBarID);
	
	-- Frame width vars
	local skillRankFrameWidth = 0;

	-- Hide or show skill bar
	if ( skillName == "" ) then
		statusBar:Hide();
		skillTypeLabelText:Hide();
		return;
	end

	-- Is header
	if ( header ) then
		skillTypeLabelText:Show();
		skillTypeLabelText:SetText(skillName);
		skillTypeLabelText.skillIndex = skillIndex;
		skillRankFrameBorderTexture:Hide();
		statusBar:Hide();
		local normalTexture = getglobal("SkillTypeLabel"..statusBarID.."NormalTexture");
		if ( isExpanded ) then
			skillTypeLabelText:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
		else
			skillTypeLabelText:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
		end
		skillTypeLabelText.isExpanded = isExpanded;
		return;
	else
		skillTypeLabelText:Hide();
		skillRankFrameBorderTexture:Show();
		statusBar:Show();
	end
	
	-- Set skillbar info
	statusBar.skillIndex = skillIndex;
	statusBarName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	statusBarSkillRank:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	statusBarSkillRank:ClearAllPoints();
	statusBarSkillRank:SetPoint("LEFT", "SkillRankFrame"..statusBarID.."SkillName", "RIGHT", 13, 0);
	statusBarSkillRank:SetJustifyH("LEFT");
	
	-- Anchor the text to the left by default
	statusBarName:ClearAllPoints();
	statusBarName:SetPoint("LEFT", statusBar:GetName(), "LEFT", 6, 1);

	-- Lock border color if skill is selected
	if (skillIndex == GetSelectedSkill()) then
		statusBarBorder:LockHighlight();
	else
		statusBarBorder:UnlockHighlight();
	end

	-- Set bar color depending on skill cost
	if (skillCostType == 1) then
		statusBar:SetStatusBarColor(0.0, 0.75, 0.0, 0.5);
		statusBarBackground:SetVertexColor(0.0, 0.5, 0.0, 0.5);
		statusBarFillBar:SetVertexColor(0.0, 1.0, 0.0, 0.5);
	elseif (skillCostType == 2) then
		statusBar:SetStatusBarColor(0.75, 0.75, 0.0, 0.5);
		statusBarBackground:SetVertexColor(0.75, 0.75, 0.0, 0.5);
		statusBarFillBar:SetVertexColor(1.0, 1.0, 0.0, 0.5);
	elseif (skillCostType == 3) then
		statusBar:SetStatusBarColor(0.75, 0.0, 0.0, 0.5);
		statusBarBackground:SetVertexColor(0.75, 0.0, 0.0, 0.5);
		statusBarFillBar:SetVertexColor(1.0, 0.0, 0.0, 0.5);
	else
		statusBar:SetStatusBarColor(0.5, 0.5, 0.5, 0.5);
		statusBarBackground:SetVertexColor(0.5, 0.5, 0.5, 0.5);
		statusBarFillBar:SetVertexColor(1.0, 1.0, 1.0, 0.5);
	end

	-- Default width
	skillRankFrameWidth = 256;

	statusBarName:SetText(skillName);

	-- Show and hide skill up arrows
	if ( stepCost ) then
		-- If is a learnable skill
		-- Set cost, text, and color
		statusBar:SetMinMaxValues(0, 1);
		statusBar:SetValue(0);
		statusBar:SetStatusBarColor(0.25, 0.25, 0.25);
		statusBarBackground:SetVertexColor(0.75, 0.75, 0.75, 0.5);
		statusBarName:SetText(format(LEARN_SKILL_TEMPLATE,skillName));
		statusBarName:ClearAllPoints();
		statusBarName:SetPoint("LEFT", statusBar:GetName(), "LEFT", 15, 1);
		statusBarSkillRank:SetText("");

		-- If skill is too high level
		if ( UnitLevel("player") < minLevel ) then
			statusBar:SetValue(0);
			statusBarSkillRank:SetText(format(TEXT(LEVEL_GAINED),skillLevel));
			statusBarSkillRank:ClearAllPoints();
			statusBarSkillRank:SetPoint("RIGHT", "SkillDetailStatusBar", "RIGHT",-13, 0);
			statusBarSkillRank:SetJustifyH("RIGHT");
			statusBarName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			statusBarSkillRank:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			return;
		end

	elseif ( rankCost or (numTempPoints > 0) ) then
		-- If is a skill that can be trained up
		if ( not rankCost ) then
			rankCost = 0;
		end

		statusBarName:SetText(skillName);

		-- Setwidth value
		skillRankFrameWidth = 215;
	else
		-- Normal skill
		statusBarName:SetText(skillName);
		statusBar:SetStatusBarColor(0.0, 0.0, 1.0, 0.5);
		statusBarBackground:SetVertexColor(0.0, 0.0, 0.75, 0.5);
	end

	if ( skillMaxRank == 1 ) then
		-- If max rank in a skill is 1 assume that its a proficiency
		statusBar:SetMinMaxValues(0, 1);
		statusBar:SetValue(1);
		statusBar:SetStatusBarColor(0.5, 0.5, 0.5);
		statusBarSkillRank:SetText("");
		statusBarBackground:SetVertexColor(1.0, 1.0, 1.0, 0.5);
	elseif ( skillMaxRank > 0 ) then
		statusBar:SetMinMaxValues(0, skillMaxRank);
		statusBar:SetValue(skillRankStart);
		if (numTempPoints > 0) then
			local fillBarWidth = (skillRank / skillMaxRank) * statusBar:GetWidth();
			statusBarFillBar:SetPoint("TOPRIGHT", statusBarLabel, "TOPLEFT", fillBarWidth, 0);
			statusBarFillBar:Show();
		else
			statusBarFillBar:Hide();
		end
		if ( skillModifier == 0 ) then
			statusBarSkillRank:SetText(skillRank.."/"..skillMaxRank);
		else
			local color = RED_FONT_COLOR_CODE;
			if ( skillModifier > 0 ) then
				color = GREEN_FONT_COLOR_CODE.."+"
			end
			statusBarSkillRank:SetText(skillRank.." ("..color..skillModifier..FONT_COLOR_CODE_CLOSE..")/"..skillMaxRank);
		end
	end
end

function SkillDetailFrame_SetStatusBar(skillIndex, adjustedSkillPoints)
	-- Get info
	local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription = GetSkillLineInfo(skillIndex);	
	local skillRankStart = skillRank;
	skillRank = skillRank + numTempPoints;

	-- Skill bar objects
	local statusBar = getglobal("SkillDetailStatusBar");
	local statusBarBackground = getglobal("SkillDetailStatusBarBackground");
	local statusBarSkillRank = getglobal("SkillDetailStatusBarSkillRank");
	local statusBarName = getglobal("SkillDetailStatusBarSkillName");
	local statusBarUnlearnButton = getglobal("SkillDetailStatusBarUnlearnButton");
	local statusBarLeftArrow = getglobal("SkillDetailStatusBarLeftArrow");
	local statusBarRightArrow = getglobal("SkillDetailStatusBarRightArrow");
	local statusBarLearnSkillButton = getglobal("SkillDetailStatusBarLearnSkillButton");
	local statusBarFillBar = getglobal("SkillDetailStatusBarFillBar");

	-- Frame width vars
	local skillRankFrameWidth = 0;

	-- Hide or show skill bar
	if ( not skillName or skillName == "" ) then
		statusBar:Hide();
		return;
	else
		statusBar:Show();
	end

	-- Hide or show abandon button
	if ( isAbandonable ) then
		statusBarUnlearnButton:Show();
		statusBarUnlearnButton.skillName = skillName;
		statusBarUnlearnButton.index = index;
	else
		statusBarUnlearnButton:Hide();
	end
		
	-- Set skillbar info
	statusBar.skillIndex = skillIndex;
	statusBarName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	statusBarSkillRank:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	statusBarSkillRank:ClearAllPoints();
	statusBarSkillRank:SetPoint("LEFT", "SkillDetailStatusBarSkillName", "RIGHT", 13, 0);
	statusBarSkillRank:SetJustifyH("LEFT");
	
	-- Hide the learn skill button by default
	statusBarLearnSkillButton:Hide();

	-- Anchor the text to the left by default
	statusBarName:ClearAllPoints();
	statusBarName:SetPoint("LEFT", statusBar:GetName(), "LEFT", 6, 1);

	-- Set bar color depending on skill cost
	local skillType = "";
	if (skillCostType == 1) then
		statusBar:SetStatusBarColor(0.0, 0.75, 0.0, 0.5);
		statusBarBackground:SetVertexColor(0.0, 0.75, 0.0, 0.5);
		statusBarFillBar:SetVertexColor(0.0, 1.0, 0.0, 0.5);
	elseif (skillCostType == 2) then
		statusBar:SetStatusBarColor(0.75, 0.75, 0.0, 0.5);
		statusBarBackground:SetVertexColor(0.75, 0.75, 0.0, 0.5);
		statusBarFillBar:SetVertexColor(1.0, 1.0, 0.0, 0.5);
	elseif (skillCostType == 3) then
		statusBar:SetStatusBarColor(0.75, 0.0, 0.0, 0.5);
		statusBarBackground:SetVertexColor(0.75, 0.0, 0.0, 0.5);
		statusBarFillBar:SetVertexColor(1.0, 0.0, 0.0, 0.5);
--		skillType = "Tertiary Skill:";
	end

	-- Set skill description text
	SkillDetailDescriptionText:SetText(format(SKILL_DESCRIPTION,skillType,skillDescription));

	-- Default width
	skillRankFrameWidth = 256;

	-- Show and hide skill up arrows
	if ( stepCost ) then
		-- If is a learnable skill
		-- Color red or green depending on if its affordable or not
		local color = RED_FONT_COLOR_CODE;
		if ( adjustedSkillPoints >= stepCost ) then
			color = GREEN_FONT_COLOR_CODE;
		end

		-- Set cost, text, and color
		statusBar:SetMinMaxValues(0, 1);
		statusBar:SetValue(1);
		statusBar:SetStatusBarColor(0.0, 0.0, 1.0, 0.5);
		statusBarName:SetText(format(LEARN_SKILL_TEMPLATE,skillName));
		statusBarName:ClearAllPoints();
		statusBarName:SetPoint("CENTER", statusBar:GetName(), "CENTER", 0, 1);
		statusBarSkillRank:SetText("");
		statusBarFillBar:Hide();
		statusBarLearnSkillButton:Show();
		statusBarLeftArrow:Hide();
		statusBarRightArrow:Hide();

		-- Set skill learnable cost text
		if ( stepCost == 1 ) then
			SkillDetailCostText:SetText(format(SKILL_LEARNING_COST_SINGULAR,color,stepCost));
		else
			SkillDetailCostText:SetText(format(SKILL_LEARNING_COST,color,stepCost));
		end
		SkillDetailCostText:Show();

		-- If skill is too high level
		if ( UnitLevel("player") < minLevel ) then
			statusBar:SetValue(0);
			statusBarSkillRank:SetText(format(TEXT(LEVEL_GAINED),skillLevel));
			statusBarSkillRank:ClearAllPoints();
			statusBarSkillRank:SetPoint("RIGHT", "SkillDetailStatusBar", "RIGHT",-13, 0);
			statusBarSkillRank:SetJustifyH("RIGHT");
			statusBarName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			statusBarSkillRank:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			statusBarLeftArrow:Hide();
			statusBarRightArrow:Hide();
			return;
		end

	elseif ( rankCost or (numTempPoints > 0) ) then
		-- If is a skill that can be trained up
		if ( not rankCost ) then
			rankCost = 0;
		end

		statusBarLeftArrow:Show();
		statusBarRightArrow:Show();

		-- Color red or green depending on if its affordable or not
		local color = RED_FONT_COLOR_CODE;
		if ( adjustedSkillPoints >= rankCost ) then
			color = GREEN_FONT_COLOR_CODE;
		end

		-- Set skill increment cost text
		if ( skillRank == skillMaxRank ) then
			color = "|cff888888";
		end
		if ( rankCost == 1 ) then
			SkillDetailCostText:SetText(format(SKILL_INCREMENT_COST_SINGULAR,color,rankCost));
		else
			SkillDetailCostText:SetText(format(SKILL_INCREMENT_COST,color,rankCost));
		end
		SkillDetailCostText:Show();

		if ( numTempPoints > 0 ) then
			statusBarLeftArrow:Enable();
		else
			statusBarLeftArrow:Disable();
		end
		if ( (adjustedSkillPoints >= rankCost) and (rankCost ~= 0) and (skillRank ~= skillMaxRank) ) then
			statusBarRightArrow:Enable();
		else
			statusBarRightArrow:Disable();
		end
	
		statusBarName:SetText(skillName);

		-- Setwidth value
		skillRankFrameWidth = 215;
	else
		-- Normal skill
		statusBarName:SetText(skillName);
		statusBar:SetStatusBarColor(0.0, 0.0, 1.0, 0.5);
		statusBarBackground:SetVertexColor(0.0, 0.0, 0.75, 0.5);

		statusBarLeftArrow:Hide();
		statusBarRightArrow:Hide();

		SkillDetailCostText:Hide();
	end
	
	if ( SkillDetailCostText:IsVisible() ) then
		SkillDetailDescriptionText:SetPoint("TOP", "SkillDetailCostText", "BOTTOM", 0, -10 );
	else
		SkillDetailDescriptionText:SetPoint("TOP", "SkillDetailCostText", "TOP", 0, 0 );
	end

	if ( skillMaxRank == 1 ) then
		-- If max rank in a skill is 1 assume that its a proficiency
		statusBar:SetMinMaxValues(0, 1);
		statusBar:SetValue(1);
		statusBar:SetStatusBarColor(0.5, 0.5, 0.5);
		statusBarSkillRank:SetText("");
		statusBarBackground:SetVertexColor(1.0, 1.0, 1.0, 0.5);
		statusBarLeftArrow:Hide();
		statusBarRightArrow:Hide();
		statusBarFillBar:Hide();
	elseif ( skillMaxRank > 0 ) then
		statusBar:SetMinMaxValues(0, skillMaxRank);
		statusBar:SetValue(skillRankStart);
		if (numTempPoints > 0) then
			local fillBarWidth = (skillRank / skillMaxRank) * statusBar:GetWidth();
			statusBarFillBar:SetPoint("TOPRIGHT", "SkillDetailStatusBar", "TOPLEFT", fillBarWidth, 0);
			statusBarFillBar:Show();
		else
			statusBarFillBar:Hide();
		end
		if ( skillModifier == 0 ) then
			statusBarSkillRank:SetText(skillRank.."/"..skillMaxRank);
		else
			local color = RED_FONT_COLOR_CODE;
			if ( skillModifier > 0 ) then
				color = GREEN_FONT_COLOR_CODE.."+"
			end
			statusBarSkillRank:SetText(skillRank.." ("..color..skillModifier..FONT_COLOR_CODE_CLOSE..")/"..skillMaxRank);
		end
	end
end

function SkillFrame_UpdateSkills()
	local numSkills = GetNumSkillLines();
	local adjustedSkillPoints = GetAdjustedSkillPoints();
	local offset = FauxScrollFrame_GetOffset(SkillListScrollFrame) + 1;
	local index = 1;
	for i=offset,  offset + SKILLS_TO_DISPLAY - 1 do
		if ( i <= numSkills ) then
			SkillFrame_SetStatusBar(index, i, numSkills, adjustedSkillPoints);
		else
			break;
		end
		index = index + 1;
	end

	-- Update the expand/collapse all button
	SkillFrameCollapseAllButton.isExpanded = 1;
	SkillFrameCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
	for i=1, numSkills do
		local temp, header, isExpanded = GetSkillLineInfo(i);
		if ( header ) then
			-- If one header is not expanded then set isExpanded to false and break
			if ( not isExpanded ) then
				SkillFrameCollapseAllButton.isExpanded = nil;
				SkillFrameCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				break;
			end
		end
	end

	-- Hide unused bars
	for i=index, SKILLS_TO_DISPLAY do
		getglobal("SkillRankFrame"..i):Hide();
		getglobal("SkillTypeLabel"..i):Hide();
	end

	local talentPoints, currSkillPoints = UnitCharacterPoints("player");

	-- Update skill points
	SkillFrame.UpdatedSkillPoints = GetAdjustedSkillPoints();

	-- Update scrollFrame
	FauxScrollFrame_Update(SkillListScrollFrame, numSkills, SKILLS_TO_DISPLAY, SKILLFRAME_SKILL_HEIGHT );
	
	SkillDetailScrollFrame:UpdateScrollChildRect();

	SkillDetailFrame_SetStatusBar(GetSelectedSkill(),adjustedSkillPoints)
end

function SkillBar_OnClick()
	SkillFrame.statusBarClickedID = this:GetParent():GetID() + FauxScrollFrame_GetOffset(SkillListScrollFrame);
	SetSelectedSkill(SkillFrame.statusBarClickedID);
	SkillFrame.showSkillDetails = 1
	SkillFrame_UpdateSkills();
end
