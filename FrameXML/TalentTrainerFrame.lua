TALENTS_DISPLAYED = 11;
TALENT_TRAINER_SKILL_HEIGHT = 16;

function TalentTrainerFrame_OnLoad()
	this:RegisterEvent("TRAINER_UPDATE");
	this:RegisterEvent("TRAINER_CLOSED");
	this:RegisterEvent("TRAINER_SHOW");
	this:RegisterEvent("CHARACTER_POINTS_CHANGED");
	TalentTrainer_HideSkillDetails();
end

function TalentTrainerFrame_OnEvent()
	if ( IsTalentTrainer() ) then
		if ( event == "TRAINER_UPDATE" ) then
			TalentTrainerTrainButton:Disable();
			if ( this:IsVisible() ) then
				if ( GetTrainerSelectionIndex() > 1 ) then
					if ( GetTrainerSelectionIndex() > GetNumTrainerServices() ) then
						FauxScrollFrame_SetOffset(TalentTrainerListScrollFrame, 0);
						TalentTrainerListScrollFrameScrollBar:SetValue(0);
					end
					TalentTrainer_SetSelection(GetTrainerSelectionIndex());
				else
					TalentTrainer_SelectFirstLearnableSkill();
				end
				TalentTrainerFrame_Update();
			end
		elseif ( event == "TRAINER_SHOW" ) then
			TalentTrainerTrainButton:Disable();
			TalentTrainerListScrollFrameScrollBar:SetMinMaxValues(0, 0); 
			TalentTrainerListScrollFrameScrollBar:SetValue(0);
			TalentTrainer_SelectFirstLearnableSkill();
			TalentTrainerSortButton_OnShow(TalentTrainerAvailableButton, "available");
			TalentTrainerSortButton_OnShow(TalentTrainerUnavailableButton, "unavailable");
			TalentTrainerFrame_Update();
			UpdateMicroButtons();
		elseif ( event == "CHARACTER_POINTS_CHANGED" ) then
			local cp1, cp2 = UnitCharacterPoints("player");
			TalentTrainerTalentPointsText:SetText(cp1);
		end
	end
	if ( event == "TRAINER_CLOSED" ) then
		this:Hide();
	end
end

function TalentTrainerFrame_Update()
	TalentTrainerGreetingText:SetText(GetTrainerGreetingText());
	local numTrainerServices = GetNumTrainerServices();
	local skillOffset = FauxScrollFrame_GetOffset(TalentTrainerListScrollFrame);
	
	-- If no spells then clear everything out
	if ( numTrainerServices == 0 ) then
		TalentTrainerCollapseAllButton:Disable();
	else
		TalentTrainerCollapseAllButton:Enable();
	end

	-- If selectedService is nil hide everything
	if ( TalentTrainerFrame.selectedService and (GetTrainerServiceInfo(TalentTrainerFrame.selectedService) ~= nil)) then
		TalentTrainer_ShowSkillDetails();
	end

	-- ScrollFrame update
	FauxScrollFrame_Update(TalentTrainerListScrollFrame, numTrainerServices, TALENTS_DISPLAYED, TALENT_TRAINER_SKILL_HEIGHT, TalentTrainerSkillHighlightFrame, 293, 316 )
	
	-- Adjust filter bar and hide the money frame if showing the talent trainer
	local cp1, cp2 = UnitCharacterPoints("player");
	TalentTrainerTalentPointsText:SetText(cp1);
	TalentTrainerTalentPointsText:Show();
	TalentTrainerTalentPoints:Show();
	
	TalentTrainerSkillHighlightFrame:Hide();
	-- Fill in the skill buttons
	for i=1, TALENTS_DISPLAYED, 1 do
		local skillIndex = i + skillOffset;
		local skillButton = getglobal("TalentTrainerSkill"..i);
		local serviceName, serviceSubText, serviceType, isExpanded;
		if ( skillIndex <= numTrainerServices ) then	
			serviceName, serviceSubText, serviceType, isExpanded = GetTrainerServiceInfo(skillIndex);
			if ( not serviceName ) then
				serviceName = "";
			end
			-- Set button widths if scrollbar is shown or hidden
			if ( TalentTrainerListScrollFrame:IsVisible() ) then
				skillButton:SetWidth(293);
			else
				skillButton:SetWidth(323);
			end
			local skillCost = getglobal("TalentTrainerSkill"..i.."Cost");
			local skillSubText = getglobal("TalentTrainerSkill"..i.."SubText");
			-- Type stuff
			if ( serviceType == "header" ) then
				skillCost:Hide();
				skillButton:SetText(serviceName);
				skillButton:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				skillSubText:Hide();
				if ( isExpanded ) then
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
				else
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				end
				getglobal("TalentTrainerSkill"..i.."Highlight"):SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
			else
				skillButton:SetNormalTexture("");
				getglobal("TalentTrainerSkill"..i.."Highlight"):SetTexture("");
				skillButton:SetText("  "..serviceName);
				if ( serviceSubText and serviceSubText ~= "" ) then
					skillSubText:SetText(format(TEXT(PARENS_TEMPLATE), serviceSubText));
					skillSubText:SetPoint("LEFT", "TalentTrainerSkill"..i.."Text", "RIGHT", 10, 0);
					skillSubText:Show();
				else
					skillSubText:Hide();
				end
				
				-- Cost Stuff
				local moneyCost, cpCost1, cpCost2 = GetTrainerServiceCost(skillIndex);
				if ( cpCost2 > 0 ) then
					skillCost:SetText(format(TEXT(TRAINER_LIST_SP),cpCost2));
					skillCost:Show();
				elseif ( cpCost1 > 0 ) then
					if ( serviceType ) then
					
					end
					skillCost:SetText(format(TEXT(TRAINER_LIST_TP), cpCost1));
					skillCost:Show();
				else
					skillCost:Hide();
				end
				if ( serviceType == "available" ) then
					skillButton:SetTextColor(0, 1.0, 0);
					skillCost:SetTextColor(0, 1.0, 0);
					TalentTrainer_SetSubTextColor(skillButton, 0, 0.6, 0);
					skillButton.r = 0;
				elseif ( serviceType == "used" ) then
					skillButton:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
					TalentTrainer_SetSubTextColor(skillButton, 0.6, 0.6, 0.6);
					
					skillCost:Hide();
				else
					skillButton:SetTextColor(0.9, 0, 0);
					skillCost:SetTextColor(0.9, 0, 0);
					TalentTrainer_SetSubTextColor(skillButton, 0.6, 0, 0);
				end
			end
			skillButton:SetID(skillIndex);
			skillButton:Show();
			-- Place the highlight and lock the highlight state
			if ( TalentTrainerFrame.selectedService and GetTrainerSelectionIndex() == skillIndex ) then
				TalentTrainerSkillHighlightFrame:SetPoint("TOPLEFT", "TalentTrainerSkill"..i, "TOPLEFT", 0, 0);
				TalentTrainerSkillHighlightFrame:Show();
				skillButton:LockHighlight();
				TalentTrainer_SetSubTextColor(skillButton, 1.0, 1.0, 1.0);
				skillCost:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			else
				skillButton:UnlockHighlight();
			end
		else
			skillButton:Hide();
		end
	end
		
	-- Set the expand/collapse all button texture
	local numHeaders = 0;
	local notExpanded = 0;
	-- Somewhat redundant loop, but cleaner than the alternatives
	for i=1, numTrainerServices, 1 do
		local skillIndex = i;
		local serviceName, serviceSubText, serviceType, isExpanded = GetTrainerServiceInfo(skillIndex);
		if ( serviceName and serviceType == "header" ) then
			numHeaders = numHeaders + 1;
			if ( not isExpanded ) then
				notExpanded = notExpanded + 1;
			end
		end
	end
	-- If all headers are not expanded then show collapse button, otherwise show the expand button
	if ( notExpanded ~= numHeaders ) then
		TalentTrainerCollapseAllButton.collapsed = nil;
		TalentTrainerCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
	else
		TalentTrainerCollapseAllButton.collapsed = 1;
		TalentTrainerCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
	end
end

function TalentTrainer_SelectFirstLearnableSkill()
	if ( GetNumTrainerServices() > 0 ) then
		TalentTrainerFrame.showSkillDetails = 1;
		TalentTrainer_SetSelection(2);
		FauxScrollFrame_SetOffset(TalentTrainerListScrollFrame, 0);	
	else
		TalentTrainerFrame.showSkillDetails = nil;
		TalentTrainer_SetSelection();
	end
	TalentTrainerListScrollFrameScrollBar:SetValue(0);
end

function TalentTrainer_SetSelection(id)
	if ( TalentTrainerFrame.showSkillDetails ) then
		TalentTrainer_ShowSkillDetails();
	else
		TalentTrainer_HideSkillDetails();
		return;
	end
	-- General Info
	local serviceName, serviceSubText, serviceType, isExpanded = GetTrainerServiceInfo(id);
	TalentTrainerSkillHighlightFrame:Show();
	if ( serviceType == "available" ) then
		TalentTrainerSkillHighlight:SetVertexColor(0, 1.0, 0);
	elseif ( serviceType == "used" ) then
		TalentTrainerSkillHighlight:SetVertexColor(0.5, 0.5, 0.5);
	elseif ( serviceType == "unavailable" ) then
		TalentTrainerSkillHighlight:SetVertexColor(0.9, 0, 0);
	elseif ( serviceType == "header" ) then
		-- Is header, so collapse or expand header
		TalentTrainerSkillHighlightFrame:Hide();
		if ( isExpanded ) then
			CollapseTrainerSkillLine(id);
		else
			ExpandTrainerSkillLine(id);
		end
		return;
	else
		-- If serviceType is none of the above then the client probably hasn't received the talent data yet
		return;
	end
	if ( not serviceName ) then
		serviceName = TEXT(UNKNOWN);
	end
	TalentTrainerSkillName:SetText(serviceName);
	TalentTrainerSubSkillName:SetText(format(TEXT(PARENS_TEMPLATE), serviceSubText));
	TalentTrainerFrame.selectedService = id;
	SelectTrainerService(id);
	if ( GetTrainerSelectionIndex() > GetNumTrainerServices() ) then
		return;
	end
	TalentTrainerSkillIcon:SetNormalTexture(GetTrainerServiceIcon(id));
	-- Build up the requirements string
	local requirements = "";
	TalentTrainerSkillRequirements:Hide();
	-- Level Requirements
	local reqLevel = GetTrainerServiceLevelReq(id);
	local separator = "";
	if ( reqLevel > 1 ) then
		separator = ", ";
		if ( isPetLearnSpell ) then
			if ( UnitLevel("pet") >= reqLevel ) then
				requirements = requirements..format(TEXT(TRAINER_PET_LEVEL), reqLevel);
			else
				requirements = requirements..format(TEXT(TRAINER_PET_LEVEL_RED), reqLevel);
			end
		else
			if ( UnitLevel("player") >= reqLevel ) then
				requirements = requirements..format(TEXT(TRAINER_REQ_LEVEL), reqLevel);
			else
				requirements = requirements..format(TEXT(TRAINER_REQ_LEVEL_RED), reqLevel);
			end
		end
	end
	-- Skill Requirements
	local skill, rank, hasReq = GetTrainerServiceSkillReq(id);
	if ( skill ) then
		if ( hasReq ) then
			requirements = requirements..separator..format(TEXT(TRAINER_REQ_SKILL_RANK), skill, rank );
		else
			requirements = requirements..separator..format(TEXT(TRAINER_REQ_SKILL_RANK_RED), skill, rank );
		end
		separator = ", ";
	end
	-- Ability Requirements
	local numRequirements = GetTrainerServiceNumAbilityReq(id);
	local ability, abilityName, abilitySubText, abilityType;
	if ( numRequirements > 0 ) then
		for i=1, numRequirements, 1 do
			ability, hasReq = GetTrainerServiceAbilityReq(id, i);
			abilityName, abilitySubText, abilityType = GetTrainerServiceInfo(id);
			if ( hasReq or (abilityType == "used") ) then
				requirements = requirements..separator..format(TEXT(TRAINER_REQ_ABILITY), ability );
			else
				requirements = requirements..separator..format(TEXT(TRAINER_REQ_ABILITY_RED), ability );
			end
			separator = ", ";
		end
	end
	-- Step Requirements
	local step, met = GetTrainerServiceStepReq(id);
	if ( step ) then
		if ( met ) then
			requirements = requirements..separator..format(TEXT(TRAINER_REQ_ABILITY), step );
		else 
			requirements = requirements..separator..format(TEXT(TRAINER_REQ_ABILITY_RED), step );
		end
	end
	if ( requirements ~= "" ) then
		TalentTrainerSkillRequirements:SetText(REQUIRES_LABEL.." "..requirements);
		TalentTrainerSkillRequirements:Show();
	else
		TalentTrainerSkillRequirements:SetText(" ");
	end
	-- Money Frame and cost
	local moneyCost, cpCost1, cpCost2 = GetTrainerServiceCost(id);
	local cp1, cp2 = UnitCharacterPoints("player");
	local unavailable, skillPointCost;
	if ( moneyCost == 0 ) then
		TalentTrainerDetailMoneyFrame:Hide();
	else
		TalentTrainerDetailMoneyFrame:Show();
		if ( GetMoney() >= moneyCost ) then
			SetMoneyFrameColor("TalentTrainerDetailMoneyFrame", 1.0, 1.0, 1.0);
		else
			SetMoneyFrameColor("TalentTrainerDetailMoneyFrame", 1.0, 0.1, 0.1);
			unavailable = 1;
		end
	end
	
	MoneyFrame_Update("TalentTrainerDetailMoneyFrame", moneyCost);
	if ( cpCost2 > 0 ) then
		if ( cp2 >= cpCost2 or serviceType == "used" ) then
			skillPointCost = format(TEXT(TRAINER_COST_SP),cpCost2);
		else
			skillPointCost = format(TEXT(TRAINER_COST_SP_RED),cpCost2);
			unavailable = 1;
		end
		if ( moneyCost > 0 ) then
			skillPointCost = skillPointCost..", ";
		end
	elseif ( cpCost1 > 0 ) then
		if ( cp1 >= cpCost1 or serviceType == "used" ) then
			skillPointCost = format(TEXT(TRAINER_COST_TP),cpCost1);
		else
			skillPointCost = format(TEXT(TRAINER_COST_TP_RED),cpCost1);
			unavailable = 1;
		end
		if ( moneyCost > 0 ) then
			skillPointCost = skillPointCost..", ";
		end
	end
	TalentTrainerSkillDescription:SetText( GetTrainerServiceDescription(id) );
	if ( serviceType == "available" and not unavailable ) then
		TalentTrainerTrainButton:Enable();
	else
		TalentTrainerTrainButton:Disable();
	end

	-- Determine what type of spell to display
	local isLearnSpell;
	local isPetLearnSpell;
	isLearnSpell, isPetLearnSpell = IsTrainerServiceLearnSpell(id);
	if ( isLearnSpell ) then
		if ( isPetLearnSpell ) then
			TalentTrainerSkillName:SetText(TalentTrainerSkillName:GetText() ..TEXT(TRAINER_PET_SPELL_LABEL));
		end
	end
	TalentTrainerDetailScrollFrame:UpdateScrollChildRect();
	-- Show or hide scrollbar
	if ((TalentTrainerDetailScrollFrameScrollBarScrollUpButton:IsEnabled() == 0) and (TalentTrainerDetailScrollFrameScrollBarScrollDownButton:IsEnabled() == 0) ) then
		TalentTrainerDetailScrollFrameScrollBar:Hide();
		TalentTrainerDetailScrollFrameTop:Hide();
		TalentTrainerDetailScrollFrameBottom:Hide();
	else
		TalentTrainerDetailScrollFrameScrollBar:Show();
		TalentTrainerDetailScrollFrameTop:Show();
		TalentTrainerDetailScrollFrameBottom:Show();
	end
end

function TalentTrainerSkillButton_OnClick(button)
	if ( button == "LeftButton" ) then
		TalentTrainerFrame.selectedService = this:GetID();
		TalentTrainerFrame.showSkillDetails = 1;
		TalentTrainer_SetSelection(this:GetID());
		TalentTrainerFrame_Update();
	end
end

function TalentTrainerTrainButton_OnClick()
	BuyTrainerService(TalentTrainerFrame.selectedService);
	TalentTrainerFrame.showSkillDetails = nil;
	TalentTrainer_SetSelection(TalentTrainerFrame.selectedService);
	TalentTrainerFrame_Update();
end

function TalentTrainer_SetSubTextColor(button, r, g, b)
	button.r = r;
	button.g = g;
	button.b = b;
	getglobal(button:GetName().."SubText"):SetTextColor(r, g, b);
end

function TalentTrainerSkillButton_OnEnter()
	getglobal(this:GetName().."SubText"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end

function TalentTrainerSkillButton_OnLeave()
	getglobal(this:GetName().."SubText"):SetTextColor(this.r, this.g, this.b);
end

function TalentTrainerSortButton_OnClick(type)
	if ( this:GetChecked() ) then
		SetTrainerServiceTypeFilter(type, 1);
	else
		SetTrainerServiceTypeFilter(type, 0);
	end
end

function TalentTrainerSortButton_OnShow(button, type)
	if ( GetTrainerServiceTypeFilter(type) ) then
		button:SetChecked(1);
	else
		button:SetChecked(0);
	end
end

function TalentTrainerCollapseAllButton_OnClick()
	if (this.collapsed) then
		this.collapsed = nil;
		ExpandTrainerSkillLine(0);
	else
		this.collapsed = 1;
		TalentTrainerListScrollFrameScrollBar:SetValue(0);
		CollapseTrainerSkillLine(0);
	end
end

function TalentTrainer_HideSkillDetails()
	TalentTrainerSkillName:Hide();
	TalentTrainerSkillIcon:Hide();
	TalentTrainerSkillRequirements:Hide();
	TalentTrainerSkillDescription:Hide();
	TalentTrainerDetailMoneyFrame:Hide();
	TalentTrainerCostLabel:Hide();
end

function TalentTrainer_ShowSkillDetails()
	TalentTrainerSkillName:Show();
	TalentTrainerSkillIcon:Show();
	TalentTrainerSkillRequirements:Show();
	TalentTrainerSkillDescription:Show();
	TalentTrainerDetailMoneyFrame:Show();
	TalentTrainerCostLabel:Show();
end

function IsTalentTrainerTabSelected()
	if ( PanelTemplates_GetSelectedTab(CharacterFrame) == 2 ) then
		return 1;
	else
		return nil;
	end
end