
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


UIPanelWindows["ClassTrainerFrame"] = { area = "left", pushable = 0, allowOtherPanels = 1,};

StaticPopupDialogs["CONFIRM_PROFESSION"] = {
	text = format(PROFESSION_CONFIRMATION1, "XXX"),
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		BuyTrainerService(ClassTrainerFrame.selectedService);
		ClassTrainerFrame.showSkillDetails = 1;
		ClassTrainerFrame.showDialog = nil;
		ClassTrainer_SetSelection(GetTrainerSelectionIndex());
		local retainScrollPosition = true;
		ClassTrainerFrame_Update(retainScrollPosition);
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

	self.BG:SetPoint("TOPLEFT", self.ScrollBox, "TOPLEFT", -3, 4);
	self.BG:SetPoint("BOTTOMRIGHT", self.ScrollBox, "BOTTOMRIGHT", 3, -4);
	
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("ClassTrainerSkillButtonTemplate", function(button, elementData)
		ClassTrainerFrame_InitServiceButton(button, elementData);
	end);
	view:SetPadding(1,0,1,0,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end


function ClassTrainerFrame_OnShow(self)
	SetPortraitTexture(ClassTrainerFramePortrait, "npc");
	ClassTrainerFrameTitleText:SetText(UnitName("npc"));
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	ClassTrainerTrainButton:Disable();

	ClassTrainerFrame.selectedService = nil;

	local retainScrollPosition = false;
	ClassTrainerFrame_Update(retainScrollPosition);

	ClassTrainer_SelectNearestLearnableSkill();
	UpdateMicroButtons();
end


function ClassTrainerFrame_OnEvent(self, event, ...)
	if ( event == "TRAINER_UPDATE" ) then
		local retainScrollPosition = true;
		if ClassTrainerFrame.filterPending then
			ClassTrainerFrame.filterPending = nil;
			retainScrollPosition = false;
		end

		ClassTrainerFrame_Update(retainScrollPosition, ScrollBoxConstants.NoScrollInterpolation);
	elseif ( event == "TRAINER_DESCRIPTION_UPDATE" ) then
		ClassTrainer_SetSelection(GetTrainerSelectionIndex());
	elseif ( event == "TRAINER_SERVICE_INFO_NAME_UPDATE" ) then
		-- It would be really cool if I could uniquely identify the button associated
		-- with a particular spell here, and only update the name on that button.
		local retainScrollPosition = true;
		ClassTrainerFrame_Update(retainScrollPosition);
	end
end


function ClassTrainerFrame_Update(retainScrollPosition)
	local numTrainerServices = GetNumTrainerServices();
	local playerMoney = GetMoney();
	local isTradeSkill = IsTradeskillTrainer();
	
	local dataProvider = CreateDataProvider();
	for index = 1, numTrainerServices do
		dataProvider:Insert({
			skillIndex=index,
			playerMoney=playerMoney,
			isTradeSkill=isTradeSkill,
		});
	end

	local scrollBox = ClassTrainerFrame.ScrollBox;
	scrollBox:ClearAllPoints();
	local tradeSkillStepIndex = GetTrainerServiceStepIndex();
	if tradeSkillStepIndex then
		scrollBox:SetPoint("TOPLEFT", ClassTrainerFrame.bottomInset, "TOPLEFT", 5, -5);
		scrollBox:SetHeight(CLASS_TRAINER_SCROLL_HEIGHT - CLASS_TRAINER_SKILL_HEIGHT - 5);
		ClassTrainerFrame.bottomInset:Show();
		ClassTrainerFrame.Inset:SetPoint("BOTTOMRIGHT", ClassTrainerFrame, "TOPRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_ATTIC_OFFSET-47);
		
		local elementData = {
			skillIndex=tradeSkillStepIndex,
			playerMoney=playerMoney,
			isTradeSkill=isTradeSkill,
		}
		ClassTrainerFrame_InitServiceButton(ClassTrainerFrame.skillStepButton, elementData);
	else
		scrollBox:SetPoint("TOPLEFT", ClassTrainerFrame.Inset, "TOPLEFT", 5, -5);
		scrollBox:SetHeight(CLASS_TRAINER_SCROLL_HEIGHT);
		ClassTrainerFrame.bottomInset:Hide();
		ClassTrainerFrame.Inset:SetPoint("BOTTOMRIGHT", ClassTrainerFrame, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_BUTTON_OFFSET);
		ClassTrainerFrame.skillStepButton:Hide();
	end

	scrollBox:SetDataProvider(dataProvider, retainScrollPosition);

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
end

function ClassTrainerFrame_InitServiceButton(skillButton, elementData)
	local skillIndex = elementData.skillIndex;
	local playerMoney = elementData.playerMoney;
	local isTradeSkill = elementData.isTradeSkill;

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
		MoneyFrame_Update(skillButton.money, moneyCost);
		if ( playerMoney >= moneyCost ) then
			SetMoneyFrameColorByFrame(skillButton.money, "white");
		else
			SetMoneyFrameColorByFrame(skillButton.money, "red");
			unavailable = true;
		end
		skillButton.money:Show();
	else
		skillButton.money:SetWidth(1);
		skillButton.money:Hide();
	end
	-- Place the highlight and lock the highlight state
	if ( ClassTrainerFrame.selectedService == skillIndex ) then
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
	if not startIndex or startIndex > numServices then
		 startIndex = 1;
	else 
		local _, serviceType = GetTrainerServiceInfo(startIndex);
		if ( serviceType == "unavailable" ) then
			startIndex = 1;
		end
	end

	local newSelection = nil;
	local tradeSkillStepIndex = GetTrainerServiceStepIndex();
	if ( numServices > 0 ) then
		for i=startIndex, numServices do 
			local _, serviceType = GetTrainerServiceInfo(i);
			if ( serviceType == "available" and i ~= tradeSkillStepIndex ) then
				newSelection = i;
				break;
			end
		end
	end
	
	if newSelection then
		ClassTrainer_SetSelection( newSelection );
		
		ClassTrainerFrame.ScrollBox:ScrollToElementDataByPredicate(function(elementData)
			return elementData.skillIndex == ClassTrainerFrame.selectedService;
		end, ScrollBoxConstants.AlignNearest, ScrollBoxConstants.NoScrollInterpolation);
	end
end

function ClassTrainer_SetSelection(id)
	-- General Info
	if ( not id ) then
		return;
	end
	
	local oldSelectedService = ClassTrainerFrame.selectedService;
	ClassTrainerFrame.selectedService = id;
	SelectTrainerService(id);
	
	local function ReinitializeButton(skillIndex)
		local button = ClassTrainerFrame.ScrollBox:FindFrameByPredicate(function(frame)
			return frame:GetElementData().skillIndex == skillIndex;
		end);
		if button then
			ClassTrainerFrame_InitServiceButton(button, button:GetElementData());
		end
	end

	ReinitializeButton(oldSelectedService);
	ReinitializeButton(ClassTrainerFrame.selectedService);

	local tradeSkillStepIndex = GetTrainerServiceStepIndex();
	if tradeSkillStepIndex then
		local elementData = {
			skillIndex=tradeSkillStepIndex,
			playerMoney=GetMoney(),
			isTradeSkill=IsTradeskillTrainer(),
		}
		ClassTrainerFrame_InitServiceButton(ClassTrainerFrame.skillStepButton, elementData);
	end

	-- Close the confirmation dialog if you choose a different skill
	if ( StaticPopup_Visible("CONFIRM_PROFESSION") ) then
		StaticPopup_Hide("CONFIRM_PROFESSION");
	end
end


function ClassTrainerSkillButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		ClassTrainer_SetSelection(self:GetID());
	end
end

function ClassTrainerTrainButton_OnClick(self, button)
	if ( IsTradeskillTrainer() and ClassTrainerFrame.showDialog) then
		StaticPopup_Show("CONFIRM_PROFESSION");
	else
		BuyTrainerService(ClassTrainerFrame.selectedService);
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
	ClassTrainerFrame.filterPending = true;
	if ( UIDropDownMenuButton_GetChecked(self) ) then
		SetTrainerServiceTypeFilter(self.value, 1);
	else
		SetTrainerServiceTypeFilter(self.value, 0);
	end
end