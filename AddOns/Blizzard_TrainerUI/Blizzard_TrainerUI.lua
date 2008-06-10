
CLASS_TRAINER_SKILLS_DISPLAYED = 11;
CLASS_TRAINER_SKILL_HEIGHT = 16;
MAX_LEARNABLE_PROFESSIONS = 2;

-- Trainer Filter Default Values
TRAINER_FILTER_AVAILABLE = 1;
TRAINER_FILTER_UNAVAILABLE = 1;
TRAINER_FILTER_USED = 0;


UIPanelWindows["ClassTrainerFrame"] = { area = "left", pushable = 0 };

StaticPopupDialogs["CONFIRM_PROFESSION"] = {
	text = TEXT(format(PROFESSION_CONFIRMATION1, "XXX")),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		BuyTrainerService(ClassTrainerFrame.selectedService);
		ClassTrainerFrame.showSkillDetails = nil;
		ClassTrainer_SetSelection(ClassTrainerFrame.selectedService);
		ClassTrainerFrame_Update();
	end,
	OnShow = function()
		local cp1, cp2 = UnitCharacterPoints("player");
		if ( cp2 < MAX_LEARNABLE_PROFESSIONS ) then
			getglobal(this:GetName().."Text"):SetText(format(PROFESSION_CONFIRMATION2, GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService)));
		else
			getglobal(this:GetName().."Text"):SetText(format(PROFESSION_CONFIRMATION1, GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService)));
		end
	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
};

function ClassTrainerFrame_Show()
	ShowUIPanel(ClassTrainerFrame);
	if ( not ClassTrainerFrame:IsVisible() ) then
		CloseTrainer();
		return;
	end

	ClassTrainerTrainButton:Disable();
	--Reset scrollbar
	ClassTrainerListScrollFrameScrollBar:SetMinMaxValues(0, 0); 
	ClassTrainerListScrollFrameScrollBar:SetValue(0);

	ClassTrainer_SelectFirstLearnableSkill();
	ClassTrainerFrame_Update();
	UpdateMicroButtons();
	
end

function ClassTrainerFrame_Hide()
	HideUIPanel(ClassTrainerFrame);
end

function ClassTrainerFrame_OnLoad()
	this:RegisterEvent("TRAINER_UPDATE");
	this:RegisterEvent("ADDON_LOADED");
	ClassTrainerDetailScrollFrame.scrollBarHideable = 1;
end

function ClassTrainerFrame_OnEvent()
	if ( event == "ADDON_LOADED" and arg1 == "Blizzard_TrainerUI" ) then
		SetTrainerServiceTypeFilter("available", TRAINER_FILTER_AVAILABLE);
		SetTrainerServiceTypeFilter("unavailable", TRAINER_FILTER_UNAVAILABLE);
		SetTrainerServiceTypeFilter("used", TRAINER_FILTER_USED);
	end
	if ( not this:IsVisible() ) then
		return;
	end
	if ( event == "TRAINER_UPDATE" ) then
		if ( GetTrainerSelectionIndex() > 1 ) then
			if ( GetTrainerSelectionIndex() > GetNumTrainerServices() ) then
				FauxScrollFrame_SetOffset(ClassTrainerListScrollFrame, 0);
				ClassTrainerListScrollFrameScrollBar:SetValue(0);
			end
			ClassTrainer_SetSelection(GetTrainerSelectionIndex());
		else
			ClassTrainer_SelectFirstLearnableSkill();
		end
		ClassTrainerFrame_Update();
	end
end

function ClassTrainerFrame_Update()
	SetPortraitTexture(ClassTrainerFramePortrait, "npc");
	ClassTrainerNameText:SetText(UnitName("npc"));
	ClassTrainerGreetingText:SetText(GetTrainerGreetingText());
	local numTrainerServices = GetNumTrainerServices();
	local skillOffset = FauxScrollFrame_GetOffset(ClassTrainerListScrollFrame);
	
	-- If no spells then clear everything out
	if ( numTrainerServices == 0 ) then
		ClassTrainerCollapseAllButton:Disable();
	else
		ClassTrainerCollapseAllButton:Enable();
	end

	-- If selectedService is nil hide everything
	if ( not ClassTrainerFrame.selectedService ) then
		ClassTrainer_HideSkillDetails();
	end

	-- Change the setup depending on if its a class trainer or tradeskill trainer
	if ( IsTradeskillTrainer() ) then
		ClassTrainer_SetToTradeSkillTrainer();
	else
		ClassTrainer_SetToClassTrainer();
	end

	-- ScrollFrame update
	FauxScrollFrame_Update(ClassTrainerListScrollFrame, numTrainerServices, CLASS_TRAINER_SKILLS_DISPLAYED, CLASS_TRAINER_SKILL_HEIGHT, nil, nil, nil, ClassTrainerSkillHighlightFrame, 293, 316 )
	
	--ClassTrainerUsedButton:Show();
	ClassTrainerMoneyFrame:Show();
	

	ClassTrainerSkillHighlightFrame:Hide();
	-- Fill in the skill buttons
	for i=1, CLASS_TRAINER_SKILLS_DISPLAYED, 1 do
		local skillIndex = i + skillOffset;
		local skillButton = getglobal("ClassTrainerSkill"..i); 
		local serviceName, serviceSubText, serviceType, isExpanded;
		local moneyCost, cpCost1, cpCost2;
		if ( skillIndex <= numTrainerServices ) then	
			serviceName, serviceSubText, serviceType, isExpanded = GetTrainerServiceInfo(skillIndex);
			if ( not serviceName ) then
				serviceName = TEXT(UNKNOWN);
			end
			-- Set button widths if scrollbar is shown or hidden
			if ( ClassTrainerListScrollFrame:IsVisible() ) then
				skillButton:SetWidth(293);
			else
				skillButton:SetWidth(323);
			end
			local skillSubText = getglobal("ClassTrainerSkill"..i.."SubText");
			-- Type stuff
			if ( serviceType == "header" ) then
				skillButton:SetText(serviceName);
				skillButton:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				skillSubText:Hide();
				if ( isExpanded ) then
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
				else
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				end
				getglobal("ClassTrainerSkill"..i.."Highlight"):SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
			else
				skillButton:SetNormalTexture("");
				getglobal("ClassTrainerSkill"..i.."Highlight"):SetTexture("");
				skillButton:SetText("  "..serviceName);
				if ( serviceSubText and serviceSubText ~= "" ) then
					skillSubText:SetText(format(TEXT(PARENS_TEMPLATE), serviceSubText));
					skillSubText:SetPoint("LEFT", "ClassTrainerSkill"..i.."Text", "RIGHT", 10, 0);
					skillSubText:Show();
				else
					skillSubText:Hide();
				end
				
				-- Cost Stuff
				moneyCost, cpCost1, cpCost2 = GetTrainerServiceCost(skillIndex);
				if ( serviceType == "available" ) then
					skillButton:SetTextColor(0, 1.0, 0);
					ClassTrainer_SetSubTextColor(skillButton, 0, 0.6, 0);
					skillButton.r = 0;
				elseif ( serviceType == "used" ) then
					skillButton:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					ClassTrainer_SetSubTextColor(skillButton, 0.5, 0.5, 0.5);
				else
					skillButton:SetTextColor(0.9, 0, 0);
					ClassTrainer_SetSubTextColor(skillButton, 0.6, 0, 0);
				end		
			end
			skillButton:SetID(skillIndex);
			skillButton:Show();
			-- Place the highlight and lock the highlight state
			if ( ClassTrainerFrame.selectedService and GetTrainerSelectionIndex() == skillIndex ) then
				ClassTrainerSkillHighlightFrame:SetPoint("TOPLEFT", "ClassTrainerSkill"..i, "TOPLEFT", 0, 0);
				ClassTrainerSkillHighlightFrame:Show();
				skillButton:LockHighlight();
				ClassTrainer_SetSubTextColor(skillButton, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				if ( moneyCost and moneyCost > 0 ) then
					ClassTrainerCostLabel:Show();
				end
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
	local showDetails = nil;
	-- Somewhat redundant loop, but cleaner than the alternatives
	for i=1, numTrainerServices, 1 do
		local serviceName, serviceSubText, serviceType, isExpanded = GetTrainerServiceInfo(i);
		if ( serviceName and serviceType == "header" ) then
			numHeaders = numHeaders + 1;
			if ( not isExpanded ) then
				notExpanded = notExpanded + 1;
			end
		end
		-- Show details if selected skill is visible
		if ( ClassTrainerFrame.selectedService and GetTrainerSelectionIndex() == i ) then
			showDetails = 1;
		end
	end
	-- Show skill details if the skill is visible
	if ( showDetails ) then
		ClassTrainer_ShowSkillDetails();
	else	
		ClassTrainer_HideSkillDetails();
	end
	-- If all headers are not expanded then show collapse button, otherwise show the expand button
	if ( notExpanded ~= numHeaders ) then
		ClassTrainerCollapseAllButton.collapsed = nil;
		ClassTrainerCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
	else
		ClassTrainerCollapseAllButton.collapsed = 1;
		ClassTrainerCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
	end
end

function ClassTrainer_SelectFirstLearnableSkill()
	if ( GetNumTrainerServices() > 0 ) then
		ClassTrainerFrame.showSkillDetails = 1;
		ClassTrainer_SetSelection(2);
		FauxScrollFrame_SetOffset(ClassTrainerListScrollFrame, 0)		
	else
		ClassTrainerFrame.showSkillDetails = nil;
		ClassTrainer_SetSelection();
	end
	ClassTrainerListScrollFrameScrollBar:SetValue(0);
end

function ClassTrainer_SetSelection(id)
	-- General Info
	if ( not id ) then
		ClassTrainer_HideSkillDetails();
		return;
	end
	local serviceName, serviceSubText, serviceType, isExpanded = GetTrainerServiceInfo(id);

	ClassTrainerSkillHighlightFrame:Show();
	
	if ( serviceType == "available" ) then
		ClassTrainerSkillHighlight:SetVertexColor(0, 1.0, 0);
	elseif ( serviceType == "used" ) then
		ClassTrainerSkillHighlight:SetVertexColor(0.5, 0.5, 0.5);
	elseif ( serviceType == "unavailable" ) then
		ClassTrainerSkillHighlight:SetVertexColor(0.9, 0, 0);
	else
		-- Is header, so collapse or expand header
		ClassTrainerSkillHighlightFrame:Hide();
		if ( isExpanded ) then
			CollapseTrainerSkillLine(id);
		else
			ExpandTrainerSkillLine(id);
		end
		return;
	end
	if ( ClassTrainerFrame.showSkillDetails ) then
		ClassTrainer_ShowSkillDetails();
	else
		ClassTrainer_HideSkillDetails();
		return;
	end

	if ( not serviceName ) then
		serviceName = TEXT(UNKNOWN);
	end
	ClassTrainerSkillName:SetText(serviceName);
	if ( not serviceSubText ) then
		serviceSubText = "";
	end
	ClassTrainerSubSkillName:SetText(format(TEXT(PARENS_TEMPLATE), serviceSubText));
	ClassTrainerFrame.selectedService = id;
	SelectTrainerService(id);
	ClassTrainerSkillIcon:SetNormalTexture(GetTrainerServiceIcon(id));
	-- Build up the requirements string
	local requirements = "";
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
		ClassTrainerSkillRequirements:SetText(REQUIRES_LABEL.." "..requirements);
	else
		ClassTrainerSkillRequirements:SetText("");
	end
	-- Money Frame and cost
	local moneyCost, cpCost1, cpCost2 = GetTrainerServiceCost(id);
	local cp1, cp2 = UnitCharacterPoints("player");
	local unavailable, skillPointCost;
	if ( moneyCost == 0 ) then
		ClassTrainerDetailMoneyFrame:Hide();
		ClassTrainerCostLabel:Hide();
		ClassTrainerSkillDescription:SetPoint("TOPLEFT", "ClassTrainerCostLabel", "TOPLEFT", 0, 0);
	else
		ClassTrainerDetailMoneyFrame:Show();
		ClassTrainerCostLabel:Show();
		ClassTrainerSkillDescription:SetPoint("TOPLEFT", "ClassTrainerCostLabel", "BOTTOMLEFT", 0, -10);
		if ( GetMoney() >= moneyCost ) then
			SetMoneyFrameColor("ClassTrainerDetailMoneyFrame", 1.0, 1.0, 1.0);
		else
			SetMoneyFrameColor("ClassTrainerDetailMoneyFrame", 1.0, 0.1, 0.1);
			unavailable = 1;
		end
	end
	
	MoneyFrame_Update("ClassTrainerDetailMoneyFrame", moneyCost);
	if ( cpCost2 > 0 ) then
		ClassTrainerFrame.showDialog = 1;
		if ( cp2 < cpCost2 and serviceType ~= "used" ) then
			unavailable = 1;
		end
	elseif ( cpCost1 > 0 ) then
		ClassTrainerFrame.showDialog = 1;
		if ( cp1 < cpCost1 and serviceType ~= "used" ) then
			unavailable = 1;
		end
	else
		ClassTrainerFrame.showDialog = nil;
	end
	ClassTrainerSkillDescription:SetText( GetTrainerServiceDescription(id) );
	if ( serviceType == "available" and not unavailable ) then
		ClassTrainerTrainButton:Enable();
	else
		ClassTrainerTrainButton:Disable();
	end

	-- Determine what type of spell to display
	local isLearnSpell;
	local isPetLearnSpell;
	isLearnSpell, isPetLearnSpell = IsTrainerServiceLearnSpell(id);
	if ( isLearnSpell ) then
		if ( isPetLearnSpell ) then
			ClassTrainerSkillName:SetText(ClassTrainerSkillName:GetText() ..TEXT(TRAINER_PET_SPELL_LABEL));
		end
	end
	ClassTrainerDetailScrollFrame:UpdateScrollChildRect();

	-- Close the confirmation dialog if you choose a different skill
	if ( StaticPopup_Visible("CONFIRM_PROFESSION") ) then
		StaticPopup_Hide("CONFIRM_PROFESSION");
	end
end

function ClassTrainerSkillButton_OnClick(button)
	if ( button == "LeftButton" ) then
		ClassTrainerFrame.selectedService = this:GetID();
		ClassTrainerFrame.showSkillDetails = 1;
		ClassTrainer_SetSelection(this:GetID());
		ClassTrainerFrame_Update();
	end
end

function ClassTrainerTrainButton_OnClick()
	if ( IsTradeskillTrainer() and ClassTrainerFrame.showDialog) then
		StaticPopup_Show("CONFIRM_PROFESSION");
	else
		BuyTrainerService(ClassTrainerFrame.selectedService);
		ClassTrainerFrame.showSkillDetails = nil;
		ClassTrainer_SetSelection(ClassTrainerFrame.selectedService);
		ClassTrainerFrame_Update();
	end
end

function ClassTrainer_SetSubTextColor(button, r, g, b)
	button.r = r;
	button.g = g;
	button.b = b;
	getglobal(button:GetName().."SubText"):SetTextColor(r, g, b);
end

function ClassTrainerCollapseAllButton_OnClick()
	if (this.collapsed) then
		this.collapsed = nil;
		ExpandTrainerSkillLine(0);
	else
		this.collapsed = 1;
		ClassTrainerListScrollFrameScrollBar:SetValue(0);
		CollapseTrainerSkillLine(0);
	end
end

function ClassTrainer_HideSkillDetails()
	ClassTrainerSkillName:Hide();
	ClassTrainerSkillIcon:Hide();
	ClassTrainerSkillRequirements:Hide();
	ClassTrainerSkillDescription:Hide();
	ClassTrainerDetailMoneyFrame:Hide();
	ClassTrainerCostLabel:Hide();
end

function ClassTrainer_ShowSkillDetails()
	ClassTrainerSkillName:Show();
	ClassTrainerSkillIcon:Show();
	ClassTrainerSkillRequirements:Show();
	ClassTrainerSkillDescription:Show();
	ClassTrainerDetailMoneyFrame:Show();
	--ClassTrainerCostLabel:Show();
end

function ClassTrainer_SetToTradeSkillTrainer()
	CLASS_TRAINER_SKILLS_DISPLAYED = 10;
	ClassTrainerSkill11:Hide();
	ClassTrainerListScrollFrame:SetHeight(168);
	ClassTrainerDetailScrollFrame:SetHeight(135);
	local cp1, cp2 = UnitCharacterPoints("player");
	ClassTrainerHorizontalBarLeft:SetPoint("TOPLEFT", "ClassTrainerFrame", "TOPLEFT", 15, -259);
end

function ClassTrainer_SetToClassTrainer()
	CLASS_TRAINER_SKILLS_DISPLAYED = 11;
	ClassTrainerListScrollFrame:SetHeight(184);
	ClassTrainerDetailScrollFrame:SetHeight(119);
	ClassTrainerHorizontalBarLeft:SetPoint("TOPLEFT", "ClassTrainerFrame", "TOPLEFT", 15, -275);
end

-- Dropdown functions
function ClassTrainerFrameFilterDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, ClassTrainerFrameFilterDropDown_Initialize);
	UIDropDownMenu_SetText(FILTER, this);
	UIDropDownMenu_SetWidth(130, ClassTrainerFrameFilterDropDown);
end

function ClassTrainerFrameFilterDropDown_Initialize()
	-- Available button
	local info = {};
	local checked = nil;
	if ( GetTrainerServiceTypeFilter("available") ) then
		checked = 1;
	end
	info.text = GREEN_FONT_COLOR_CODE..AVAILABLE..FONT_COLOR_CODE_CLOSE;
	info.value = "available";
	info.func = ClassTrainerFrameFilterDropDown_OnClick;
	info.checked = checked;
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);

	-- Unavailable button
	info = {};
	checked = nil;
	if ( GetTrainerServiceTypeFilter("unavailable") ) then
		checked = 1;
	end
	info.text = RED_FONT_COLOR_CODE..UNAVAILABLE..FONT_COLOR_CODE_CLOSE;
	info.value = "unavailable";
	info.func = ClassTrainerFrameFilterDropDown_OnClick;
	info.checked = checked;
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);

	-- Unavailable button
	info = {};
	checked = nil;
	if ( GetTrainerServiceTypeFilter("used") ) then
		checked = 1;
	end
	info.text = GRAY_FONT_COLOR_CODE..USED..FONT_COLOR_CODE_CLOSE;
	info.value = "used";
	info.func = ClassTrainerFrameFilterDropDown_OnClick;
	info.checked = checked;
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);
end

function ClassTrainerFrameFilterDropDown_OnClick()	
	if ( UIDropDownMenuButton_GetChecked() ) then
		setglobal("TRAINER_FILTER_"..strupper(this.value), 0);
		SetTrainerServiceTypeFilter(this.value, 0);
	else
		setglobal("TRAINER_FILTER_"..strupper(this.value), 1);
		SetTrainerServiceTypeFilter(this.value, 1);
	end
	
	ClassTrainerListScrollFrameScrollBar:SetValue(0);
end