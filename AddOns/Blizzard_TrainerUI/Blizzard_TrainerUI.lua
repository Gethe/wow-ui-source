
CLASS_TRAINER_SKILLS_DISPLAYED = 11;
CLASS_TRAINER_SKILL_HEIGHT = 16;
MAX_LEARNABLE_PROFESSIONS = 2;

-- Trainer Filter Default Values
TRAINER_FILTER_AVAILABLE = 1;
TRAINER_FILTER_UNAVAILABLE = 1;
TRAINER_FILTER_USED = 0;

SKILL_TEXT_WIDTH = 270;

StaticPopupDialogs["CONFIRM_PROFESSION"] = {
	text = format(PROFESSION_CONFIRMATION1, "XXX"),
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		BuyTrainerService(ClassTrainerFrame.selectedService);
		ClassTrainerFrame.showSkillDetails = nil; 
		ClassTrainer_SetSelection(ClassTrainerFrame.selectedService);
		ClassTrainerFrame_Update();
	end,
	OnShow = function(self)
		local profCount = GetNumPrimaryProfessions();
		if ( profCount == 0 ) then
			_G[self:GetName().."Text"]:SetText(format(PROFESSION_CONFIRMATION1, GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService)));
		else
			_G[self:GetName().."Text"]:SetText(format(PROFESSION_CONFIRMATION2, GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService)));
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

function ClassTrainerFrame_OnLoad(self)
	self:RegisterEvent("TRAINER_UPDATE");
	self:RegisterEvent("TRAINER_DESCRIPTION_UPDATE");
	self:RegisterEvent("TRAINER_SERVICE_INFO_NAME_UPDATE");
	self:RegisterEvent("ADDON_LOADED");
	ClassTrainerDetailScrollFrame.scrollBarHideable = 1;
end

function ClassTrainerFrame_OnEvent(self, event, ...)
	if ( event == "ADDON_LOADED" and arg1 == "Blizzard_TrainerUI" ) then
		SetTrainerServiceTypeFilter("available", TRAINER_FILTER_AVAILABLE);
		SetTrainerServiceTypeFilter("unavailable", TRAINER_FILTER_UNAVAILABLE);
		SetTrainerServiceTypeFilter("used", TRAINER_FILTER_USED);
	end
	if ( not self:IsVisible() ) then
		return;
	end
	if ( event == "TRAINER_UPDATE" ) then
		if ( GetTrainerSelectionIndex() > 1 ) then
			if ( GetTrainerSelectionIndex() > GetNumTrainerServices() + 1) then
				FauxScrollFrame_SetOffset(ClassTrainerListScrollFrame, 0);
				ClassTrainerListScrollFrameScrollBar:SetValue(0);
			end

			-- Our selected index may no longer be "available". If so, try to select the next "available"
			-- index relative to our last position.
			if self.renewSelection then
				local currentSelection = ClassTrainerFrame.selectedService;
				local currentServiceType = select(3, GetTrainerServiceInfo(currentSelection));
				local numServices = GetNumTrainerServices();
				
				if currentServiceType ~= "available" then
					-- Collapsed groups already accounted for in sorting prior to the event.
					while currentSelection <= numServices do
						currentSelection = currentSelection + 1;
						local serviceType = select(3, GetTrainerServiceInfo(currentSelection));
						if serviceType == "available" then
							self.renewSelection = nil;
							break;
						end
					end
				end
				
				if currentSelection <= numServices then
					self.showSkillDetails = true;
					ClassTrainer_SetSelection(currentSelection);
					
					-- Keep the entry in view.
					local lastVisible = FauxScrollFrame_GetOffset(ClassTrainerListScrollFrame) + CLASS_TRAINER_SKILLS_DISPLAYED;
					if currentSelection > lastVisible then
						local offset = math.max(0, currentSelection - CLASS_TRAINER_SKILLS_DISPLAYED);
						FauxScrollFrame_SetOffset(ClassTrainerListScrollFrame, offset);
					end
				end
			end
		else
			ClassTrainer_SelectFirstLearnableSkill();
		end
		ClassTrainerFrame_Update();
	elseif ( event == "TRAINER_DESCRIPTION_UPDATE" ) then
		ClassTrainer_SetSelection(GetTrainerSelectionIndex());
	elseif ( event == "TRAINER_SERVICE_INFO_NAME_UPDATE" ) then
		-- It would be really cool if I could uniquely identify the button associated
		-- with a particular spell here, and only update the name on that button.
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
		local skillButton = _G["ClassTrainerSkill"..i]; 
		local serviceName, serviceSubText, serviceType, isExpanded;
		local moneyCost;
		if ( skillIndex <= numTrainerServices ) then	
			serviceName, serviceSubText, serviceType, isExpanded = GetTrainerServiceInfo(skillIndex);
			if ( not serviceName ) then
				serviceName = UNKNOWN;
			end
			-- Set button widths if scrollbar is shown or hidden
			if ( ClassTrainerListScrollFrame:IsVisible() ) then
				skillButton:SetWidth(293);
			else
				skillButton:SetWidth(323);
			end
			local skillSubText = _G["ClassTrainerSkill"..i.."SubText"];
			-- Type stuff
			if ( serviceType == "header" ) then
				local skillText = _G["ClassTrainerSkill"..i.."Text"];
				skillText:SetText(serviceName);
				skillText:SetWidth(0);
				skillButton:SetNormalFontObject("GameFontNormal");

				skillSubText:Hide();
				if ( isExpanded ) then
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
				else
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				end
				_G["ClassTrainerSkill"..i.."Highlight"]:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
			else
				skillButton:SetNormalTexture("");
				_G["ClassTrainerSkill"..i.."Highlight"]:SetTexture("");
				local skillText = _G["ClassTrainerSkill"..i.."Text"];
				skillText:SetText("  "..serviceName);
				if ( serviceSubText and serviceSubText ~= "" ) then
					skillSubText:SetText(format(PARENS_TEMPLATE, serviceSubText));
					skillSubText:SetPoint("LEFT", "ClassTrainerSkill"..i.."Text", "RIGHT", 10, 0);
					skillSubText:Show();
					skillText:SetWidth(0);
				else
					skillSubText:Hide();

					-- A bit of a hack. If there's no subtext, we'll set a width to ensure that we don't overflow.
					skillText:SetWidth(SKILL_TEXT_WIDTH);
				end
				
				-- Cost Stuff
				moneyCost, _ = GetTrainerServiceCost(skillIndex);
				if ( serviceType == "available" ) then
					skillButton:SetNormalFontObject("GameFontNormalLeftGreen");
					ClassTrainer_SetSubTextColor(skillButton, 0, 0.6, 0);
				elseif ( serviceType == "used" ) then
					skillButton:SetNormalFontObject("GameFontDisable");
					ClassTrainer_SetSubTextColor(skillButton, 0.5, 0.5, 0.5);
				else
					skillButton:SetNormalFontObject("GameFontNormalLeftRed");
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
	ClassTrainerListScrollFrame:SetVerticalScroll(0);
end

function ClassTrainer_SetSelection(id)
	-- General Info
	if ( not id ) then
		ClassTrainer_HideSkillDetails();
		return;
	end
	local serviceName, serviceSubText, serviceType, isExpanded = GetTrainerServiceInfo(id);

	ClassTrainerSkillHighlightFrame:Show();
	
	-- When we have an available entry selected, we flag our selection to be sanitized
	-- when receiving an update event. This event occurs when the list is collapsed or expanded,
	-- and if entries are learned. In each of those cases, we can't trust our current position
	-- to be an "available" entry, and we attempt to reselect an appropriate entry when possible.
	if ( serviceType == "available" ) then
		ClassTrainerSkillHighlight:SetVertexColor(0, 1.0, 0);
		ClassTrainerFrame.renewSelection = true;
	elseif ( serviceType == "used" ) then
		ClassTrainerSkillHighlight:SetVertexColor(0.5, 0.5, 0.5);
		ClassTrainerFrame.renewSelection = false;
	elseif ( serviceType == "unavailable" ) then
		ClassTrainerSkillHighlight:SetVertexColor(0.9, 0, 0);
		ClassTrainerFrame.renewSelection = false;
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
		serviceName = UNKNOWN;
	end
	ClassTrainerSkillName:SetText(serviceName);
	if ( not serviceSubText ) then
		serviceSubText = "";
	end
	ClassTrainerSubSkillName:SetText(PARENS_TEMPLATE:format(serviceSubText));
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
				requirements = requirements..format((TRAINER_PET_LEVEL), reqLevel);
			else
				requirements = requirements..format((TRAINER_PET_LEVEL_RED), reqLevel);
			end
		else
			if ( UnitLevel("player") >= reqLevel ) then
				requirements = requirements..format((TRAINER_REQ_LEVEL), reqLevel);
			else
				requirements = requirements..format((TRAINER_REQ_LEVEL_RED), reqLevel);
			end
		end
	end
	-- Skill Requirements
	local skill, rank, hasReq = GetTrainerServiceSkillReq(id);
	if ( skill ) then
		if ( hasReq ) then
			requirements = requirements..separator..format((TRAINER_REQ_SKILL_RANK), skill, rank);
		else
			requirements = requirements..separator..format((TRAINER_REQ_SKILL_RANK_RED), skill, rank);
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
			if (ability) then
				if ( hasReq or (abilityType == "used") ) then
					requirements = requirements..separator..format((TRAINER_REQ_ABILITY), ability);
				else
					requirements = requirements..separator..format((TRAINER_REQ_ABILITY_RED), ability);
				end
			end
			separator = ", ";
		end
	end
	if ( requirements ~= "" ) then
		ClassTrainerSkillRequirements:SetText(REQUIRES_LABEL.." "..requirements);
	else
		ClassTrainerSkillRequirements:SetText("");
	end
	-- Money Frame and cost
	local moneyCost, isProfession = GetTrainerServiceCost(id);
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
			SetMoneyFrameColor("ClassTrainerDetailMoneyFrame", "white");
		else
			SetMoneyFrameColor("ClassTrainerDetailMoneyFrame", "red");
			unavailable = 1;
		end
	end

	MoneyFrame_Update("ClassTrainerDetailMoneyFrame", moneyCost);
	if (isProfession) then
		ClassTrainerFrame.showDialog = true;
		local profCount = GetNumPrimaryProfessions();
		if profCount >= 2 then
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
			ClassTrainerSkillName:SetText(ClassTrainerSkillName:GetText() ..TRAINER_PET_SPELL_LABEL);
		end
	end
	ClassTrainerDetailScrollFrame:UpdateScrollChildRect();

	-- Close the confirmation dialog if you choose a different skill
	if ( StaticPopup_Visible("CONFIRM_PROFESSION") ) then
		StaticPopup_Hide("CONFIRM_PROFESSION");
	end
end

function ClassTrainerSkillButton_OnClick(self)
	ClassTrainerFrame.selectedService = self:GetID();
	ClassTrainerFrame.showSkillDetails = 1;
	ClassTrainer_SetSelection(self:GetID());
	ClassTrainerFrame_Update();
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
	button.subR = r;
	button.subG = g;
	button.subB = b;
	_G[button:GetName().."SubText"]:SetTextColor(r, g, b);
end

function ClassTrainerCollapseAllButton_OnClick(self)
	if (self.collapsed) then
		self.collapsed = nil;
		ExpandTrainerSkillLine(0);
	else
		self.collapsed = 1;
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
function ClassTrainerFrameFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, ClassTrainerFrameFilterDropDown_Initialize);
	UIDropDownMenu_SetText(self, FILTER);
	UIDropDownMenu_SetWidth(self, 130);
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
	info.classicChecks = true;
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
	info.classicChecks = true;
	UIDropDownMenu_AddButton(info);

	-- Already Known button
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
	info.classicChecks = true;
	UIDropDownMenu_AddButton(info);
end

function ClassTrainerFrameFilterDropDown_OnClick(self)	
	if ( UIDropDownMenuButton_GetChecked(self) ) then
		setglobal("TRAINER_FILTER_"..strupper(self.value), 1);
		SetTrainerServiceTypeFilter(self.value, 1);
	else
		setglobal("TRAINER_FILTER_"..strupper(self.value), 0);
		SetTrainerServiceTypeFilter(self.value, 0);
	end
	
	ClassTrainerListScrollFrameScrollBar:SetValue(0);
end