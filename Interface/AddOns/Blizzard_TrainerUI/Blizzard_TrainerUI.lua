
CLASS_TRAINER_SKILLS_DISPLAYED = 7;
CLASS_TRAINER_SCROLL_HEIGHT = 330
CLASS_TRAINER_SKILL_BUTTON_WIDTH = 318
CLASS_TRAINER_SKILL_BARBUTTON_WIDTH = 298
CLASS_TRAINER_SKILL_HEIGHT = 47;
MAX_LEARNABLE_PROFESSIONS = 2;

-- Trainer Filter Default Values
TRAINER_FILTER_AVAILABLE = 1;
TRAINER_FILTER_UNAVAILABLE = 1;
TRAINER_FILTER_USED = 0;


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
end

function ClassTrainerFrame_Hide()
	HideUIPanel(ClassTrainerFrame);
end

function ClassTrainerFrame_OnLoad(self)
	self:RegisterEvent("TRAINER_UPDATE");
	self:RegisterEvent("TRAINER_DESCRIPTION_UPDATE");
	self:RegisterEvent("TRAINER_SERVICE_INFO_NAME_UPDATE");
	MoneyFrame_SetMaxDisplayWidth(ClassTrainerFrameMoneyFrame, 152);


	self.BG:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT", -3, 4);
	self.BG:SetPoint("BOTTOMRIGHT", self.scrollFrame, "BOTTOMRIGHT", 3, -4);
	self.scrollFrame.update = ClassTrainerFrame_Update;
	HybridScrollFrame_CreateButtons(self.scrollFrame, "ClassTrainerSkillButtonTemplate", 1, -1, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM");

	ClassTrainerScrollFrameScrollBar.Show = 
		function (self)
			ClassTrainerScrollFrame:SetWidth(CLASS_TRAINER_SKILL_BARBUTTON_WIDTH + 2);
			for _, button in next, ClassTrainerScrollFrame.buttons do
				button:SetWidth(CLASS_TRAINER_SKILL_BARBUTTON_WIDTH);
			end
			getmetatable(self).__index.Show(self);
		end
		
	ClassTrainerScrollFrameScrollBar.Hide = 
		function (self)
			ClassTrainerScrollFrame:SetWidth(CLASS_TRAINER_SKILL_BUTTON_WIDTH + 2);
			for _, button in next, ClassTrainerScrollFrame.buttons do
				button:SetWidth(CLASS_TRAINER_SKILL_BUTTON_WIDTH);
			end
			getmetatable(self).__index.Hide(self);
		end	
end


function ClassTrainerFrame_OnShow(self)
	SetPortraitTexture(ClassTrainerFramePortrait, "npc");
	ClassTrainerFrameTitleText:SetText(UnitName("npc"));
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	ClassTrainerTrainButton:Disable();

	ClassTrainerFrame.selectedService = nil;
	--Reset scrollbar
	ClassTrainerFrame_Update();
	ClassTrainerFrame.scrollFrame.scrollBar:SetValue(0);
	ClassTrainer_SelectNearestLearnableSkill();
	UpdateMicroButtons();
end


function ClassTrainerFrame_OnEvent(self, event, ...)
	if ( event == "TRAINER_UPDATE" ) then
		ClassTrainer_SelectNearestLearnableSkill();
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
	local numTrainerServices = GetNumTrainerServices();
	local selected = GetTrainerSelectionIndex();
	local playerMoney = GetMoney();
	local isTradeSkill = IsTradeskillTrainer()
	local scrollFrame = ClassTrainerFrame.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local displayHeight = CLASS_TRAINER_SCROLL_HEIGHT;
	
	local tradeSkillStepIndex = GetTrainerServiceStepIndex();
	if tradeSkillStepIndex then
		scrollFrame:ClearAllPoints();
		scrollFrame:SetPoint("TOPLEFT", ClassTrainerFrame.bottomInset, "TOPLEFT", 5, -5);
		displayHeight = CLASS_TRAINER_SCROLL_HEIGHT - CLASS_TRAINER_SKILL_HEIGHT - 5;
		scrollFrame:SetHeight(CLASS_TRAINER_SCROLL_HEIGHT - CLASS_TRAINER_SKILL_HEIGHT - 5);
		ClassTrainerFrame.bottomInset:Show();
		ClassTrainerFrame.Inset:SetPoint("BOTTOMRIGHT", ClassTrainerFrame, "TOPRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_ATTIC_OFFSET-47);
		ClassTrainerFrame_SetServiceButton( ClassTrainerFrame.skillStepButton, tradeSkillStepIndex, playerMoney, selected, isTradeSkill );
	else
		scrollFrame:ClearAllPoints();
		scrollFrame:SetPoint("TOPLEFT", ClassTrainerFrame.Inset, "TOPLEFT", 5, -5);
		scrollFrame:SetHeight(CLASS_TRAINER_SCROLL_HEIGHT);
		ClassTrainerFrame.bottomInset:Hide();
		ClassTrainerFrame.Inset:SetPoint("BOTTOMRIGHT", ClassTrainerFrame, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_BUTTON_OFFSET);
		ClassTrainerFrame.skillStepButton:Hide();
	end

	-- rank status bar
	local rank, maxRank, rankModifier = GetTrainerTradeskillRankValues();
	if ( rank and rank > 0 ) then
		local statusBar = ClassTrainerStatusBar;
		statusBar:SetMinMaxValues(1, maxRank);
		statusBar:SetValue(rank);
		statusBar:Show();
		if ( rankModifier > 0 ) then
			statusBar.rankText:SetFormattedText(TRADESKILL_RANK_WITH_MODIFIER, rank, rankModifier, maxRank);
		else
			statusBar.rankText:SetFormattedText(TRADESKILL_RANK, rank, maxRank);
		end
	else
		ClassTrainerStatusBar:Hide();
	end

	-- Fill in the skill buttons
	for i=1, numButtons do
		local skillIndex = i + offset;
		local skillButton = buttons[i];
		if ( skillIndex <= numTrainerServices) then	
			ClassTrainerFrame_SetServiceButton( skillButton, skillIndex, playerMoney, selected, isTradeSkill );
		else
			skillButton:Hide();
		end
	end
	

	local totalHeight = CLASS_TRAINER_SKILL_HEIGHT * numTrainerServices ;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayHeight);
end


function ClassTrainerFrame_SetServiceButton( skillButton, skillIndex, playerMoney, selected, isTradeSkill )

	local unavailable = false;
	local serviceName, serviceType, texture, reqLevel = GetTrainerServiceInfo(skillIndex);
	if ( not serviceName ) then
		serviceName = UNKNOWN;
	end

	skillButton.icon:SetTexture(texture);
	
	
	local requirements = "";
	local separator = "";
	if reqLevel and reqLevel > 1 then
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
	local ability, hasReq;
	if ( numRequirements > 0 ) then
		for i=1, numRequirements, 1 do
			ability, hasReq = GetTrainerServiceAbilityReq(skillIndex, i);
			if ( ability ) then
				if ( hasReq ) then
					requirements = requirements..separator..format(TRAINER_REQ_ABILITY, ability );
				else
					requirements = requirements..separator..format(TRAINER_REQ_ABILITY_RED, ability );
				end
			end
		end
	end
	
	if ( serviceType == "unavailable" ) then
		skillButton.icon:SetDesaturated(true);
		skillButton.name:SetText(GRAY_FONT_COLOR_CODE..serviceName..FONT_COLOR_CODE_CLOSE);
		skillButton.disabledBG:Show();
	else
		skillButton.icon:SetDesaturated(false);
		skillButton.disabledBG:Hide();
	end
	
	local showMoney = true;
	if ( requirements ~= "" and serviceType ~= "used" ) then
		requirements = REQUIRES_LABEL.." "..requirements;
	elseif ( serviceType == "used" ) then
		requirements = ITEM_SPELL_KNOWN;
		showMoney = false;
	else
		requirements = "";
	end
	skillButton.name:SetText(serviceName);
	skillButton.subText:SetText(requirements);
	
	
	local moneyCost, isProfession = GetTrainerServiceCost(skillIndex);
	if ( showMoney and moneyCost and moneyCost > 0 ) then
		MoneyFrame_Update(skillButton.money:GetName(), moneyCost);
		if ( playerMoney >= moneyCost ) then
			SetMoneyFrameColor(skillButton.money:GetName(), "white");
		else
			SetMoneyFrameColor(skillButton.money:GetName(), "red");
			unavailable = true;
		end
		skillButton.money:Show();
	else
		skillButton.money:SetWidth(1);
		skillButton.money:Hide();
	end
	-- Place the highlight and lock the highlight state
	if ( ClassTrainerFrame.selectedService and selected == skillIndex ) then
		ClassTrainerFrame.showDialog = nil;
		
		if isProfession then
			ClassTrainerFrame.showDialog = true;
			local _, prof2 = GetProfessions();
			if prof2 then
				unavailable = true;
			end
		end 
	
		skillButton.selectedTex:Show();
		if ( serviceType == "available" and not unavailable) then
			ClassTrainerTrainButton:Enable();
		else
			ClassTrainerTrainButton:Disable();
		end
	else
		skillButton.selectedTex:Hide();
	end

	if skillButton.showingTooltip then
		GameTooltip:SetTrainerService(skillButton:GetID());
	end
	
	skillButton:SetID(skillIndex);
	skillButton:Hide(); -- Forces the anchors in the button to update (Hack)
	skillButton:Show();
end


function ClassTrainer_SelectNearestLearnableSkill()
	ClassTrainerTrainButton:Disable();
	local numServices = GetNumTrainerServices();
	local startIndex = ClassTrainerFrame.selectedService;
	ClassTrainerFrame.selectedService = nil;
	if not startIndex or  startIndex> numServices then
		 startIndex = 1;
	else 
		local _, serviceType = GetTrainerServiceInfo(startIndex);
		if ( serviceType == "unavailable" ) then
			startIndex = 1;
		end
	end
	local tradeSkillStepIndex = GetTrainerServiceStepIndex();
	if ( numServices > 0 ) then
		for i=startIndex, numServices do 
			local _, serviceType = GetTrainerServiceInfo(i);
			if ( serviceType == "available" and i ~= tradeSkillStepIndex ) then
				ClassTrainerFrame.selectedService = i;
				break;
			end
		end
	end
	
	if ClassTrainerFrame.selectedService then
		ClassTrainer_SetSelection( ClassTrainerFrame.selectedService);
		local offset = HybridScrollFrame_GetOffset(ClassTrainerFrame.scrollFrame);
		if ClassTrainerFrame.selectedService > offset + CLASS_TRAINER_SKILLS_DISPLAYED then
			ClassTrainerFrame.scrollFrame.scrollBar:SetValue( (ClassTrainerFrame.selectedService-1)*CLASS_TRAINER_SKILL_HEIGHT);
		end
		ClassTrainerFrame_Update();
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
	UIDropDownMenu_SetWidth(self, 100);
end

function ClassTrainerFrameFilterDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	-- Available button
	info.text = GREEN_FONT_COLOR_CODE..AVAILABLE..FONT_COLOR_CODE_CLOSE;
	info.value = "available";
	info.func = ClassTrainerFrameFilterDropDown_OnClick;
	info.checked = GetTrainerServiceTypeFilter("available");
	info.isNotRadio = true;
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);

	-- Unavailable button
	info.text = RED_FONT_COLOR_CODE..UNAVAILABLE..FONT_COLOR_CODE_CLOSE;
	info.value = "unavailable";
	info.func = ClassTrainerFrameFilterDropDown_OnClick;
	info.checked = GetTrainerServiceTypeFilter("unavailable");
	info.isNotRadio = true;
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);

	-- Unavailable button
	info.text = GRAY_FONT_COLOR_CODE..USED..FONT_COLOR_CODE_CLOSE;
	info.value = "used";
	info.func = ClassTrainerFrameFilterDropDown_OnClick;
	info.checked = GetTrainerServiceTypeFilter("used");
	info.isNotRadio = true;
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);
end

function ClassTrainerFrameFilterDropDown_OnClick(self)
	if ( UIDropDownMenuButton_GetChecked(self) ) then
		SetTrainerServiceTypeFilter(self.value, 1);
	else
		SetTrainerServiceTypeFilter(self.value, 0);
	end
end