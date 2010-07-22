
CLASS_TRAINER_SKILLS_DISPLAYED = 7;
CLASS_TRAINER_SKILL_BUTTON_WIDTH = 316
CLASS_TRAINER_SKILL_BARBUTTON_WIDTH = 293
CLASS_TRAINER_SKILL_HEIGHT = 47;
MAX_LEARNABLE_PROFESSIONS = 2;

-- Trainer Filter Default Values
TRAINER_FILTER_AVAILABLE = 1;
TRAINER_FILTER_UNAVAILABLE = 1;
TRAINER_FILTER_USED = 0;


TRADESKILL_SERVICE_STEP_LUA = 1;


UIPanelWindows["ClassTrainerFrame"] = { area = "left", pushable = 0};

StaticPopupDialogs["CONFIRM_PROFESSION"] = {
	text = format(PROFESSION_CONFIRMATION1, "XXX"),
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		BuyTrainerService(ClassTrainerFrame.selectedService);
		ClassTrainerFrame.showSkillDetails = 1;
		ClassTrainerFrame.showDialog = nil;		
		ClassTrainer_SetSelection(GetTrainerSelectionIndex());
		ClassTrainerFrame_Update();
	end,
	OnShow = function(self)
		local prof1, prof2 = GetProfessions();
		if ( prof1 and not prof2 ) then
			self.text:SetFormattedText(PROFESSION_CONFIRMATION2, GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService));
		elseif ( not prof1 ) then
			self.text:SetFormattedText(PROFESSION_CONFIRMATION1, GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService));
		end
	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
};

function ClassTrainerFrame_Show()
	ShowUIPanel(ClassTrainerFrame);
	if ( not ClassTrainerFrame:IsShown() ) then
		CloseTrainer();
		return;
	end

	ClassTrainerFrame.selectedService = nil;
	ClassTrainerTrainButton:Disable();
	--Reset scrollbar
	ClassTrainerListScrollFrameScrollBar:SetMinMaxValues(0, 0); 
	ClassTrainerListScrollFrameScrollBar:SetValue(0);
	ClassTrainer_SelectNearestLearnableSkill();
	ClassTrainerFrame_Update();
	UpdateMicroButtons();
end

function ClassTrainerFrame_Hide()
	HideUIPanel(ClassTrainerFrame);
end

function ClassTrainerFrame_OnLoad(self)
	SetPortraitTexture(ClassTrainerFramePortrait, "npc");
	self:RegisterEvent("TRAINER_UPDATE");
	self:RegisterEvent("TRAINER_DESCRIPTION_UPDATE");
	
	self.BG:SetPoint("TOPLEFT", ClassTrainerSkill1, "TOPLEFT", 0, 0);
	self.BG:SetPoint("BOTTOMRIGHT", ClassTrainerSkill7, "BOTTOMRIGHT", 0, 0);
	
end


function ClassTrainerFrame_OnShow(self)
	PlaySound("igCharacterInfoOpen");
	ClassTrainerListScrollFrame:SetHeight(self.Inset:GetHeight());
	ClassTrainerTrainButton:Disable();
end


function ClassTrainerFrame_OnEvent(self, event, ...)
	if ( event == "TRAINER_UPDATE" ) then
		ClassTrainer_SelectNearestLearnableSkill();
		ClassTrainerFrame_Update();
	elseif ( event == "TRAINER_DESCRIPTION_UPDATE" ) then
		ClassTrainer_SetSelection(GetTrainerSelectionIndex());
	end
end


function ClassTrainerFrame_Update()
	ClassTrainerFrameTitleText:SetText(UnitName("npc"));
	--ClassTrainerGreetingText:SetText(GetTrainerGreetingText());
	local numTrainerServices = GetNumTrainerServices();
	

	-- ScrollFrame update
	FauxScrollFrame_Update(ClassTrainerListScrollFrame, numTrainerServices, CLASS_TRAINER_SKILLS_DISPLAYED, CLASS_TRAINER_SKILL_HEIGHT, nil, nil, nil, 
											ClassTrainerFrameInset, CLASS_TRAINER_SKILL_BARBUTTON_WIDTH, CLASS_TRAINER_SKILL_BUTTON_WIDTH );
	local skillOffset = FauxScrollFrame_GetOffset(ClassTrainerListScrollFrame);
	

	local selected = GetTrainerSelectionIndex();
	local playerMoney = GetMoney();

	local isTradeSkill = IsTradeskillTrainer();
	
	
	local _, _, _, _, _, topServiceLine = GetTrainerServiceInfo(1);
	local tradeSkillDisplay = (topServiceLine == TRADESKILL_SERVICE_STEP_LUA) and isTradeSkill;
	if tradeSkillDisplay then
		ClassTrainerSkill1:SetHeight(39);			
		ClassTrainerSkill2:SetPoint("TOPLEFT", ClassTrainerSkill1, "BOTTOMLEFT", 0, -10);
		ClassTrainerListScrollFrame:SetPoint("TOPRIGHT", ClassTrainerSkill2, "TOPRIGHT", 0, 2);
		ClassTrainerFrame.BG:SetPoint("TOPLEFT", ClassTrainerSkill2, "TOPLEFT", 0, 0);		
		if numTrainerServices > CLASS_TRAINER_SKILLS_DISPLAYED then
			ClassTrainerFrame.BG:SetPoint("BOTTOMRIGHT", ClassTrainerSkill7, "BOTTOMRIGHT", 0, 0);
		else
			ClassTrainerFrame.BG:SetPoint("BOTTOMRIGHT", ClassTrainerFrame.bottomInset, "BOTTOMRIGHT", 0, 0);
		end
		
		ClassTrainerFrame.bottomInset:Show();
		ClassTrainerFrame.Inset:SetPoint("BOTTOMRIGHT", ClassTrainerFrame, "TOPRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_ATTIC_OFFSET-47);
	else		
		ClassTrainerSkill1:SetHeight(47);			
		ClassTrainerSkill2:SetPoint("TOPLEFT", ClassTrainerSkill1, "BOTTOMLEFT", 0, 0);
		ClassTrainerListScrollFrame:SetPoint("TOPRIGHT", ClassTrainerSkill1, "TOPRIGHT", 0, 2);
		ClassTrainerFrame.BG:SetPoint("TOPLEFT", ClassTrainerSkill1, "TOPLEFT", 0, 0);
		if numTrainerServices > CLASS_TRAINER_SKILLS_DISPLAYED then
			ClassTrainerFrame.BG:SetPoint("BOTTOMRIGHT", ClassTrainerSkill7, "BOTTOMRIGHT", 0, 0);
		else
			ClassTrainerFrame.BG:SetPoint("BOTTOMRIGHT", ClassTrainerFrame.Inset, "BOTTOMRIGHT", 0, 0);
		end
		
		ClassTrainerFrame.bottomInset:Hide();		
		ClassTrainerFrame.Inset:SetPoint("BOTTOMRIGHT", ClassTrainerFrame, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_BUTTON_OFFSET);
	end
	
	-- Fill in the skill buttons
	for i=1, CLASS_TRAINER_SKILLS_DISPLAYED, 1 do

		local skillIndex = i + skillOffset;
		if tradeSkillDisplay then
			skillIndex = 1;
		end
		
		local skillButton = _G["ClassTrainerSkill"..i]; 
		local unavailable = false;
		local serviceName, serviceSubText, serviceType, isExpanded;
		if ( skillIndex <= numTrainerServices or tradeSkillDisplay ) then	
			serviceName, serviceSubText, serviceType, texture, reqLevel = GetTrainerServiceInfo(skillIndex);
			if ( not serviceName ) then
				serviceName = UNKNOWN;
			end	

			skillButton.name:SetText(serviceName);
			skillButton.icon:SetTexture(texture);
			
			
			local requirements = "";		
			local separator = "";
			if reqLevel > 1 then
				if ( UnitLevel("player") >= reqLevel ) then
					requirements = requirements..format(TRAINER_REQ_LEVEL, reqLevel);
				else
					requirements = requirements..format(TRAINER_REQ_LEVEL_RED, reqLevel);
				end
				separator = PLAYER_LIST_DELIMITER;
			end
			if ( isTradeSkill ) then
				local skill, rank, hasReq = GetTrainerServiceSkillReq(skillIndex);
				if ( skill ) then
					if ( hasReq ) then
						requirements = requirements..separator..format(TRAINER_REQ_SKILL_RANK, skill, rank );
					else
						requirements = requirements..separator..format(TRAINER_REQ_SKILL_RANK_RED, skill, rank );
					end
					separator = PLAYER_LIST_DELIMITER;
				end			
			end	
			
			-- Ability Requirements
			local numRequirements = GetTrainerServiceNumAbilityReq(skillIndex);
			local ability;
			if ( numRequirements > 0 ) then
				for i=1, numRequirements, 1 do
					ability, hasReq = GetTrainerServiceAbilityReq(skillIndex, i);					
					if ( hasReq ) then
						requirements = requirements..separator..format(TRAINER_REQ_ABILITY, ability );
					else
						requirements = requirements..separator..format(TRAINER_REQ_ABILITY_RED, ability );
					end
				end
			end
			
			if ( requirements ~= "" and serviceType ~= "used" ) then
				skillButton.subText:Show();
				skillButton.subText:SetText(REQUIRES_LABEL.." "..requirements);
				skillButton.money:Show();
			elseif ( serviceType == "used" ) then
				skillButton.subText:Show();
				skillButton.subText:SetText(ITEM_SPELL_KNOWN);
				skillButton.money:Hide();
			else
				skillButton.subText:Hide();
			end
			
			local moneyCost = GetTrainerServiceCost(skillIndex);
			if ( moneyCost and moneyCost > 0 ) then
				MoneyFrame_Update(skillButton.money:GetName(), moneyCost);
				if ( playerMoney >= moneyCost ) then
					SetMoneyFrameColor(skillButton.money:GetName(), "white");
				else
					SetMoneyFrameColor(skillButton.money:GetName(), "red");
					unavailable = true;
				end
			end
			
			-- Place the highlight and lock the highlight state
			if ( ClassTrainerFrame.selectedService and selected == skillIndex ) then
				local prof1, prof2 = GetProfessions();
				ClassTrainerFrame.showDialog = nil;
				
				skillButton.selectedTex:Show();
				if ( serviceType == "available" and not unavailable and not prof2) then
					ClassTrainerTrainButton:Enable();
				else
					ClassTrainerTrainButton:Disable();
				end
			else
				skillButton.selectedTex:Hide();
			end			
			
			
			if ( serviceType == "unavailable" ) then
				skillButton.icon:SetDesaturated(1);
				skillButton.name:SetFontObject(GameFontNormalLeftGrey);
				skillButton.disabledBG:Show();
			else			
				skillButton.icon:SetDesaturated(0);
				skillButton.name:SetFontObject(GameFontNormal);
				skillButton.disabledBG:Hide();
			end	
			skillButton:SetID(skillIndex);
			skillButton:Show();
			
			if skillButton.showingTooltip then
				GameTooltip:SetTrainerService(skillButton:GetID());
			end			
		else
			skillButton:Hide();
		end
		
		-- Set button widths if scrollbar is shown or hidden
		if ( ClassTrainerListScrollFrame:IsShown() and not tradeSkillDisplay ) then
			skillButton:SetWidth(CLASS_TRAINER_SKILL_BARBUTTON_WIDTH);
		else
			skillButton:SetWidth(CLASS_TRAINER_SKILL_BUTTON_WIDTH);
		end	
		tradeSkillDisplay = false; -- only evaluate this the first time through the loop
	end
end

function ClassTrainer_SelectNearestLearnableSkill()
	local numServices = GetNumTrainerServices();
	if ( numServices > 0 ) then
		if ( ClassTrainerFrame.selectedService and ClassTrainerFrame.selectedService <=  numServices ) then
			ClassTrainer_SetSelection( ClassTrainerFrame.selectedService);		
		else	
			local selectionIndex = GetTrainerSelectionIndex();
			ClassTrainer_SetSelection(selectionIndex);
			if ( selectionIndex and (selectionIndex <= numServices and selectionIndex >= 2)) then
				ClassTrainerFrame_Update();
				ClassTrainerListScrollFrameScrollBar:SetValue((selectionIndex-1)*CLASS_TRAINER_SKILL_HEIGHT);
			end
		end
	else
		ClassTrainer_SetSelection(GetTrainerSelectionIndex());
		ClassTrainerListScrollFrameScrollBar:SetValue(0);
	end
end

function ClassTrainer_SetSelection(id)
	-- General Info
	if ( not id ) then
		return;
	end
	
	ClassTrainerFrame.selectedService = id;
	SelectTrainerService(id);
	
	-- Close the confirmation dialog if you choose a different skill
	if ( StaticPopup_Visible("CONFIRM_PROFESSION") ) then
		StaticPopup_Hide("CONFIRM_PROFESSION");
	end
end


function ClassTrainerSkillButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		ClassTrainerFrame.selectedService = self:GetID();
		ClassTrainer_SetSelection(self:GetID());
		ClassTrainerFrame_Update();
	end
end

function ClassTrainerTrainButton_OnClick(self, button)
	if ( IsTradeskillTrainer() and ClassTrainerFrame.showDialog) then
		StaticPopup_Show("CONFIRM_PROFESSION");
	else
		BuyTrainerService(ClassTrainerFrame.selectedService);
		ClassTrainer_SetSelection(ClassTrainerFrame.selectedService);
		ClassTrainerFrame_Update();
	end
end

-- Dropdown functions
function ClassTrainerFrameFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, ClassTrainerFrameFilterDropDown_Initialize);
	UIDropDownMenu_SetText(self, FILTER);
	UIDropDownMenu_SetWidth(self, 60);
end

function ClassTrainerFrameFilterDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	-- Available button
	info.text = GREEN_FONT_COLOR_CODE..AVAILABLE..FONT_COLOR_CODE_CLOSE;
	info.value = "available";
	info.func = ClassTrainerFrameFilterDropDown_OnClick;
	info.checked = GetTrainerServiceTypeFilter("available");
	info.isNotRadial = true;
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);

	-- Unavailable button
	info.text = RED_FONT_COLOR_CODE..UNAVAILABLE..FONT_COLOR_CODE_CLOSE;
	info.value = "unavailable";
	info.func = ClassTrainerFrameFilterDropDown_OnClick;
	info.checked = GetTrainerServiceTypeFilter("unavailable");
	info.isNotRadial = true;
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);

	-- Unavailable button
	info.text = GRAY_FONT_COLOR_CODE..USED..FONT_COLOR_CODE_CLOSE;
	info.value = "used";
	info.func = ClassTrainerFrameFilterDropDown_OnClick;
	info.checked = GetTrainerServiceTypeFilter("used");
	info.isNotRadial = true;
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);
end

function ClassTrainerFrameFilterDropDown_OnClick(self)	
	ClassTrainerListScrollFrameScrollBar:SetValue(0);
	if ( UIDropDownMenuButton_GetChecked(self) ) then
		SetTrainerServiceTypeFilter(self.value, 1);
	else
		SetTrainerServiceTypeFilter(self.value, 0);
	end
end
