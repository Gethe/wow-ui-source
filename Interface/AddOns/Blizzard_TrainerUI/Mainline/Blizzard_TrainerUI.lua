
CLASS_TRAINER_SKILLS_DISPLAYED = 7;
CLASS_TRAINER_SCROLL_HEIGHT = 330
CLASS_TRAINER_SKILL_BUTTON_WIDTH = 318
CLASS_TRAINER_SKILL_BARBUTTON_WIDTH = 298
CLASS_TRAINER_SKILL_HEIGHT = 47;
MAX_LEARNABLE_PROFESSIONS = 2;

function TrainerUI_UseCategories()
	return false;
end

UIPanelWindows["ClassTrainerFrame"] = { area = "left", pushable = 0, allowOtherPanels = 1,};

local TrainDisableReason = EnumUtil.MakeEnum("NoProfessionSlot", "CannotAfford");

StaticPopupDialogs["CONFIRM_PROFESSION"] = {
	text = format(PROFESSION_CONFIRMATION1, "XXX"),
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		BuyTrainerService(ClassTrainerFrame.selectedService);
		ClassTrainerFrame.showSkillDetails = 1;
		ClassTrainerFrame.showDialog = nil;
		ClassTrainer_SetSelection(GetTrainerSelectionIndex());
		local retainScrollPosition = true;
		ClassTrainerFrame_Update(retainScrollPosition);
	end,
	OnShow = function(dialog, data)
		local prof1, prof2 = GetProfessions();
		if ( prof1 and not prof2 ) then
			dialog:SetFormattedText(PROFESSION_CONFIRMATION2, GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService));
		elseif ( not prof1 ) then
			dialog:SetFormattedText(PROFESSION_CONFIRMATION1, GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService));
		end
	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
};

ClassTrainerFrameMixin = {};

--[[
	Boolean flag that identifies this frame as having updated jump hints, no longer
	using legacy FrameControlsManager jump hints only displayed on targets.
	See FrameControlsManager:RefreshJumpHints
]]
ClassTrainerFrameMixin.useFooterJumpHints = true;

local function IsSkillButton(button)
	return button and button.buttonContext == "ButtonContext_TrainerUISkill";
end

local function IsCategoryButton(button)
	return button and button.buttonContext == "ButtonContext_TrainerUICategory";
end

-- Text to display next to jump hints on other frames, if the jump takes them here
function ClassTrainerFrameMixin:GetJumpHintLabel()
	return SKILLS;
end

function ClassTrainerFrameMixin:SetUpGamepad()
	local function IsSelectAvailable()
		local button = SmartNavigation:GetCurrentButton();
		return IsCategoryButton(button) or self.TrainButton:IsEnabled();
	end

	local function SelectAction()
		local button = SmartNavigation:GetCurrentButton();
		if IsCategoryButton(button) then
			button:Click();
		else
			ClassTrainerTrainButton_OnClick(self.TrainButton);
		end
	end

	local function GetSelectLabel()
		local button = SmartNavigation:GetCurrentButton();
		return IsCategoryButton(button) and PROMPT_TOGGLE_CATEGORY or TRAIN;
	end

	local function OpenFilter()
		self.FilterDropdown:MouseDown();
		self.FilterDropdown:MouseUp();
	end

	local function OpenSpellBook()
		PlayerSpellsUtil.TogglePlayerSpellsFrame(PlayerSpellsUtil.FrameTabs.SpellBook);
	end

	local selectBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, SelectAction, TRAIN);
	selectBinding:AddButtonContext("ButtonContext_TrainerUICategory");
	selectBinding:AddButtonContext("ButtonContext_TrainerUISkill");
	selectBinding:AddCondition(IsSelectAvailable);
	selectBinding:SetLabelFunction(GetSelectLabel);

	local filterBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_RIGHT, OpenFilter, FRAME_ACTION_FILTER);
	filterBinding:SetCustomPromptFrame(self.FilterInputHint);

	local openSpellBook = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, OpenSpellBook, RADIAL_LABEL_SPELLBOOK);

	self.footer = GamepadSharedUtility.CreatePromptedBindingFooter(self, "TrainerUIFooter");
	self.footer:AddPromptedBinding(selectBinding);
	self.footer:AddPromptedBinding(filterBinding);
	self.footer:AddPromptedBinding(openSpellBook);
	self.footer:AddStandardFrameControlManagerBindings(self);
	self.footer:AddStandardBackPrompt(FRAME_ACTION_CLOSE);
	self.footer:Finalize();

	SmartNavigation_MarkFrameIgnored(self.FilterDropdown);
end

function ClassTrainerFrameMixin:InitializeGamepad()
	self.CloseButton:Hide();
	ClassTrainerTrainButton:Hide();
end

function ClassTrainerFrameMixin:UninitializeGamepad()
	self.CloseButton:Show();
	ClassTrainerTrainButton:Show();
end

function ClassTrainerFrameMixin:FocusGamepad()
	self.footer:ShowAndActivateBindings();
	SmartNavigation:SetScrollFrameForFrame(self, self.ScrollBox);
	GamepadScrollBarHint:SetOwner(self.ScrollBar.Track.Thumb, "CENTER");
	GamepadScrollBarHint:Show();
end

function ClassTrainerFrameMixin:UnfocusGamepad()
	self.footer:HideAndDeactivateBindings();
end

function ClassTrainerFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetUpGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function ClassTrainerFrame_OnLoad(self)
	self:RegisterEvent("TRAINER_UPDATE");
	self:RegisterEvent("TRAINER_DESCRIPTION_UPDATE");
	self:RegisterEvent("TRAINER_SERVICE_INFO_NAME_UPDATE");
	self:RegisterEvent("UNIT_PET_TRAINING_POINTS");
	MoneyFrame_SetMaxDisplayWidth(self.money, 152);

	self.BG:SetPoint("TOPLEFT", self.ScrollBox, "TOPLEFT", -3, 4);
	self.BG:SetPoint("BOTTOMRIGHT", self.ScrollBox, "BOTTOMRIGHT", 3, -4);

	local indent = 10;
	local padLeft = 0;
	local pad = 1;
	local spacing = 0;
	local view = CreateScrollBoxListTreeListView(indent, pad, pad, padLeft, pad, spacing);
	view:SetElementFactory(function(factory, node)
		local elementData = node:GetData();
		if elementData.categoryInfo then
			local function Initializer(button)
				ClassTrainerFrame_InitCategoryButton(button, node);
			end
			factory("TrainerUICategoryTemplate", Initializer);
		else
			local function Initializer(button)
		ClassTrainerFrame_InitServiceButton(button, elementData);
			end
			factory("ClassTrainerSkillButtonTemplate", Initializer);
		end
	end);

	view:SetElementExtentCalculator(function(dataIndex, node)
		local elementData = node:GetData();
		if elementData.categoryInfo then
			return 25;
		end

		return CLASS_TRAINER_SKILL_HEIGHT;
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.FilterDropdown:SetWidth(100);
	self.collapsedCategories = {};

	self:RegisterForTransitions();
end

function ClassTrainerFrame_InitCategoryButton(categoryButton, node)
	local elementData = node:GetData();
	categoryButton.Label:SetText(elementData.categoryInfo.name);

	local function SetCollapseState(collapsed)
		local atlas = collapsed and "Professions-recipe-header-expand" or "Professions-recipe-header-collapse";
		categoryButton.CollapseIcon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
		categoryButton.CollapseIconAlphaAdd:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	end

	SetCollapseState(node:IsCollapsed());
	categoryButton:SetScript("OnClick", function()
		node:ToggleCollapsed();
		local collapsed = node:IsCollapsed();
		SetCollapseState(collapsed);
		ClassTrainerFrame.collapsedCategories[elementData.categoryInfo.name] = collapsed or nil;
	end);

	categoryButton:SetScript("OnEnter", function()
		categoryButton.Label:SetFontObject(GameFontHighlight_NoShadow);
	end);

	categoryButton:SetScript("OnLeave", function()
		categoryButton.Label:SetFontObject(GameFontNormal_NoShadow);
	end);
end

local function IsSelected(filter)
	return GetTrainerServiceTypeFilter(filter);
end

local function SetSelected(filter)
	ClassTrainerFrame.filterPending = true;
	SetTrainerServiceTypeFilter(filter, not IsSelected(filter));
end

function ClassTrainerFrame_OnShow(self)

	local unit = "npc";

	if C_Trainer.GetTrainerType() == Enum.TrainerType.Pet then
		unit = "pet";
	end

	SetPortraitTexture(ClassTrainerFramePortrait, unit);
	self:SetTitle(UnitName(unit));
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	ClassTrainerTrainButton.disableReason = nil;
	ClassTrainerFrame_SetTrainButtonEnabled(false);

	ClassTrainerFrame.selectedService = nil;

	local retainScrollPosition = false;
	ClassTrainerFrame_Update(retainScrollPosition);

	ClassTrainer_SelectNearestLearnableSkill();
	UpdateMicroButtons();

	self.FilterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_TRAINER_FILTER");

		rootDescription:CreateCheckbox(GREEN_FONT_COLOR:WrapTextInColorCode(AVAILABLE), IsSelected, SetSelected, "available");
		rootDescription:CreateCheckbox(RED_FONT_COLOR:WrapTextInColorCode(UNAVAILABLE), IsSelected, SetSelected, "unavailable");
		rootDescription:CreateCheckbox(GRAY_FONT_COLOR:WrapTextInColorCode(USED), IsSelected, SetSelected, "used");
	end);
end

function ClassTrainerFrame_OnHide(self)
	CloseTrainer();
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	if ( StaticPopup_Visible("CONFIRM_PROFESSION") ) then
		StaticPopup_Hide("CONFIRM_PROFESSION");
	end
end

function ClassTrainerFrame_OnEvent(self, event, ...)
	if ( event == "TRAINER_UPDATE" ) then
		local retainScrollPosition = true;
		if ClassTrainerFrame.filterPending then
			ClassTrainerFrame.filterPending = nil;
			retainScrollPosition = false;
		end

		ClassTrainerFrame_Update(retainScrollPosition);
	elseif ( event == "TRAINER_DESCRIPTION_UPDATE" ) then
		ClassTrainer_SetSelection(GetTrainerSelectionIndex());
	elseif ( event == "TRAINER_SERVICE_INFO_NAME_UPDATE" ) then
		-- It would be really cool if I could uniquely identify the button associated
		-- with a particular spell here, and only update the name on that button.
		local retainScrollPosition = true;
		ClassTrainerFrame_Update(retainScrollPosition);
	elseif ( event == "UNIT_PET_TRAINING_POINTS" ) then
		ClassTrainerFrame_UpdateTrainingPoints();
	end
end

function ClassTrainerFrame_SetTrainButtonEnabled(enabled, disableReason)
	ClassTrainerTrainButton:SetEnabled(enabled);

	if enabled then
		ClassTrainerTrainButton:SetScript("OnEnter", nil);
		ClassTrainerTrainButton:SetScript("OnLeave", nil);
	else
		ClassTrainerTrainButton:SetScript("OnEnter", function()
			-- Tooltips have not been asked for other disabled cases
			if ClassTrainerTrainButton.disableReason == TrainDisableReason.NoProfessionSlot then
				GameTooltip:SetOwner(ClassTrainerTrainButton, "ANCHOR_RIGHT");
				GameTooltip_AddNormalLine(GameTooltip, TRAINER_CANNOT_EXCEED_MAX_PROFESSIONS, true);
				GameTooltip:Show();
			end
		end);
		ClassTrainerTrainButton:SetScript("OnLeave", function()
			GameTooltip_Hide();
		end);
	end

	if InputUtil.IsGamepadUIEnabled() then
		-- Re-evaluate conditional bindings
		ClassTrainerFrame.footer:Refresh();
	end
end

local function GetGamepadSelection()
	if InputUtil.IsMKBUIEnabled() then
		return;
	end

	local self = ClassTrainerFrame;

	-- If we are focused, try to use the smart nav focus
	if self.isFocused then
		local currentButton = SmartNavigation:GetCurrentButton();

		if currentButton then
			local dataIndex = self.ScrollBox:FindByPredicate(function(elementData)
				local frame = self.ScrollBox:FindFrame(elementData);
				return frame == currentButton;
			end);

			if dataIndex then
				return { dataIndex=dataIndex, isSkillButton=IsSkillButton(currentButton) };
			end
		end
	end

	-- If not focused, use the selected service
	if self.selectedService then
		local dataIndex = self.ScrollBox:FindByPredicate(function(elementData)
			return elementData.data.skillIndex == self.selectedService;
		end);

		if dataIndex then
			-- All service buttons are skill buttons
			return { dataIndex = dataIndex, isSkillButton=true };
		end
	end
end

-- previousSelection should be a table returned by GetGamepadSelection
local function UpdateGamepadFocus(previousSelection)
	if InputUtil.IsMKBUIEnabled() then
		return;
	end

	local self = ClassTrainerFrame;
	local newSelection;

	if previousSelection then
		-- If we have a previous selection, prioritize:
		--	1. If the previous button was a skill button:
		--		a. The skill button with the smallest dataIndex >= the previous
		--		b. The skill button with the largest dataIndex
		--	2. The button with the smallest dataIndex >= the previous
		--	3. The button with the largest dataIndex

		local function FindBest(pred)
			local ret;
			for index, elementData in self.ScrollBox:EnumerateDataProviderEntireRange() do
				local frame = self.ScrollBox:FindFrame(elementData);
				if pred(frame) then
					ret = frame;
					if index >= previousSelection.dataIndex then
						break;
					end
				end
			end
			return ret;
		end

		if previousSelection.isSkillButton then
			newSelection = FindBest(IsSkillButton);
		end

		if not newSelection then
			newSelection = FindBest(function(f) return f ~= nil; end);
		end
	end

	-- If there was no previous selection, default to the skill step button if it's available
	if not newSelection and self.skillStepButton:IsShown() and self.skillStepButton.isAvailable then
		newSelection = self.skillStepButton;
	end

	-- If we still don't have a selection, select the first list entry
	if not newSelection then
		newSelection = self.ScrollBox:FindFrameByPredicate(IsSkillButton);
	end

	-- If we _still_ don't have a selection, select the skill step button even if it's not
	-- available
	if not newSelection and self.skillStepButton:IsShown() then
		newSelection = self.skillStepButton;
	end

	SmartNavigation:SetTargetButtonForFrame(self, newSelection);
end

function ClassTrainerFrame_Update(retainScrollPosition)
	local scrollBox = ClassTrainerFrame.ScrollBox;

	--[[
		Before updating the list itself, note current focus / selection state. This state
		will be required to reconstruct focus / selection state after the list was updated.
	 ]]
	local previousSelection = GetGamepadSelection();
	local numTrainerServices = GetNumTrainerServices();
	local playerMoney = GetMoney();
	local tradeSkillStepIndex = GetTrainerServiceStepIndex();

	local dataProvider = CreateTreeDataProvider();
	local categoryNodes = {};
	for index = 1, numTrainerServices do
		if index ~= tradeSkillStepIndex then
			local _serviceName, _serviceType, _texture, _reqLevel, _serviceSubText, category = GetTrainerServiceInfo(index);
			local elementData = {
				skillIndex=index,
				playerMoney=playerMoney,
				trainerType=C_Trainer.GetTrainerType(),
			};

			if TrainerUI_UseCategories() and category and category ~= "" then
				local categoryNode = categoryNodes[category];
				if not categoryNode then
					categoryNode = dataProvider:Insert({
						categoryInfo = {
							name = category,
						},
					});
					categoryNodes[category] = categoryNode;

					if ClassTrainerFrame.collapsedCategories[category] then
						categoryNode:SetCollapsed(true);
					end
				end

				categoryNode:Insert(elementData);
			else
				dataProvider:Insert(elementData);
			end
		end
	end

	scrollBox:ClearAllPoints();
	if tradeSkillStepIndex then
		scrollBox:SetPoint("TOPLEFT", ClassTrainerFrame.bottomInset, "TOPLEFT", 5, -5);
		scrollBox:SetHeight(CLASS_TRAINER_SCROLL_HEIGHT - CLASS_TRAINER_SKILL_HEIGHT - 5);
		ClassTrainerFrame.bottomInset:Show();
		ClassTrainerFrame.Inset:SetPoint("BOTTOMRIGHT", ClassTrainerFrame, "TOPRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_ATTIC_OFFSET-47);

		local elementData = {
			skillIndex=tradeSkillStepIndex,
			playerMoney=playerMoney,
			trainerType=C_Trainer.GetTrainerType(),
		}
		ClassTrainerFrame_InitServiceButton(ClassTrainerFrame.skillStepButton, elementData);
	else
		scrollBox:SetPoint("TOPLEFT", ClassTrainerFrame.Inset, "TOPLEFT", 5, -5);
		scrollBox:SetHeight(CLASS_TRAINER_SCROLL_HEIGHT);
		ClassTrainerFrame.bottomInset:Hide();
		ClassTrainerFrame.Inset:SetPoint("BOTTOMRIGHT", ClassTrainerFrame, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_BUTTON_OFFSET);
		ClassTrainerFrame.skillStepButton:Hide();
	end

	scrollBox:SetDataProvider(dataProvider, retainScrollPosition, false);

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

	if C_Trainer.GetTrainerType() == Enum.TrainerType.Pet then
		ClassTrainerFrame.money:Hide();
		ClassTrainerFrame.trainingPoints:Show();
		ClassTrainerFrame_UpdateTrainingPoints();
	else
		ClassTrainerFrame.money:Show();
		ClassTrainerFrame.trainingPoints:Hide();
	end

	UpdateGamepadFocus(previousSelection);
end

function ClassTrainerFrame_UpdateTrainingPoints()
	local total, used = C_PetInfo.GetPetTrainingPoints();
	local points = math.max(total - used, 0);

	ClassTrainerFrame.trainingPoints.text:SetFormattedText(TRAINING_POINTS, points);

	local view = ClassTrainerFrame.ScrollBox:GetView();

	for i=1,view:GetFrameCount(),1 do
		if view.frames[i] and view.frames[i].update then
			view.frames[i].update();
		end
	end
end

function ClassTrainerFrame_InitServiceButton(skillButton, elementData)
	elementData = elementData and (elementData.data or elementData);
	if not elementData or not elementData.skillIndex then
		return;
	end

	local skillIndex = elementData.skillIndex;
	local playerMoney = elementData.playerMoney;
	local isPetSkill = elementData.trainerType == Enum.TrainerType.Pet;

	local unit = isPetSkill and "pet" or "player";

	ClassTrainerTrainButton.disableReason = nil;

	local available = true;
	local serviceName, serviceType, texture, reqLevel, serviceSubText = GetTrainerServiceInfo(skillIndex);
	if ( not serviceName ) then
		serviceName = UNKNOWN;
	end

	skillButton.icon:SetTexture(texture);

	local requirements = "";
	local separator = "";
	if reqLevel and reqLevel > 1 then
		if ( UnitLevel(unit) >= reqLevel ) then
			requirements = requirements..format(TRAINER_REQ_LEVEL, reqLevel);
		else
			requirements = requirements..format(TRAINER_REQ_LEVEL_RED, reqLevel);
		end
		separator = PLAYER_LIST_DELIMITER;
	end


	local skill, rank, hasSkillReq = GetTrainerServiceSkillReq(skillIndex);
	if ( skill ) then
		if ( hasSkillReq ) then
			requirements = requirements..separator..format(TRAINER_REQ_SKILL_RANK, skill, rank );
		else
			requirements = requirements..separator..format(TRAINER_REQ_SKILL_RANK_RED, skill, rank );
		end
		separator = PLAYER_LIST_DELIMITER;
	end


	-- Ability Requirements
	local numRequirements = GetTrainerServiceNumAbilityReq(skillIndex);
	local ability, hasAbilReq;
	if ( numRequirements > 0 ) then
		for i=1, numRequirements, 1 do
			ability, hasAbilReq = GetTrainerServiceAbilityReq(skillIndex, i);
			if ( ability ) then
				if ( hasAbilReq ) then
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
	if ( serviceSubText and serviceSubText ~= "") then
		skillButton.nameSubText:SetText(PARENS_TEMPLATE:format(serviceSubText));
	else
		skillButton.nameSubText:SetText("");
	end


	local moneyCost, isProfession = GetTrainerServiceCost(skillIndex);
	if ( not isPetSkill and showMoney and moneyCost and moneyCost > 0 ) then
		MoneyFrame_Update(skillButton.money, moneyCost);
		if ( playerMoney >= moneyCost ) then
			SetMoneyFrameColorByFrame(skillButton.money, "white");
		else
			SetMoneyFrameColorByFrame(skillButton.money, "red");
			available = false;
			ClassTrainerTrainButton.disableReason = TrainDisableReason.CannotAfford;
		end
		skillButton.money:Show();
	else
		skillButton.money:SetWidth(1);
		skillButton.money:Hide();
	end

	-- Alternate Costs
	if isPetSkill and moneyCost > 0 then
		skillButton.money:Hide();
		skillButton.alternateCost:Show();

		skillButton.update = function()
			local total, used = C_PetInfo.GetPetTrainingPoints();
			local points = total - used;

			skillButton.alternateCost:SetFormattedText(TRAINING_POINTS_ABBREV, tostring(moneyCost));
			if points < moneyCost then
				skillButton.alternateCost:SetTextColor(RED_FONT_COLOR:GetRGB());
				available = false;
				ClassTrainerTrainButton.disableReason = TrainDisableReason.CannotAfford;
			else
				skillButton.alternateCost:SetTextColor(DARKYELLOW_FONT_COLOR:GetRGB());
			end
		end

		skillButton.update();
	else
		skillButton.alternateCost:Hide();
	end

	-- Place the highlight and lock the highlight state
	if isProfession then
		local noAvailableSlot = select(2, GetProfessions()) ~= nil;
		local cannotAcquireService = serviceType == "available" and noAvailableSlot;
		if cannotAcquireService then
			available = false;
			ClassTrainerTrainButton.disableReason = TrainDisableReason.NoProfessionSlot;
		end
	end

	if ( ClassTrainerFrame.selectedService == skillIndex ) then
		ClassTrainerFrame.showDialog = isProfession;
		skillButton.selectedTex:Show();

		-- This ClassTrainerFrame_SetTrainButtonEnabled logic should be moved out of the button initializer to
		-- the point where a button/option is selected.
		ClassTrainerFrame_SetTrainButtonEnabled(serviceType == "available" and available);

		if InputUtil.IsGamepadUIEnabled() then
			-- Make sure smart nav stays in sync with selected services
			SmartNavigation:SetTargetButtonForFrame(ClassTrainerFrame, skillButton);
		end
	else
		skillButton.selectedTex:Hide();
	end

	if skillButton.showingTooltip then
		GameTooltip:SetTrainerService(skillButton:GetID());
	end

	skillButton.isAvailable = serviceType == "available" and available;
	skillButton:SetID(skillIndex);
	skillButton:Hide(); -- Forces the anchors in the button to update (Hack)
	skillButton:Show();
end

function ClassTrainer_SelectNearestLearnableSkill()
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
			elementData = elementData and (elementData.data or elementData);
			return elementData and elementData.skillIndex and elementData.skillIndex == ClassTrainerFrame.selectedService;
		end, ScrollBoxConstants.AlignNearest);
	end
end

function ClassTrainer_SetSelection(id)
	local oldSelectedService = ClassTrainerFrame.selectedService;
	ClassTrainerFrame.selectedService = id;

	-- Setting it to > count effectively resets it
	SelectTrainerService(id or (GetNumTrainerServices() + 1));

	local function ReinitializeButton(skillIndex)
		if not skillIndex then
			return;
		end

		local button = ClassTrainerFrame.ScrollBox:FindFrameByPredicate(function(frame, elementData)
			elementData = elementData and (elementData.data or elementData);
			return elementData and elementData.skillIndex and elementData.skillIndex == skillIndex;
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
			trainerType=C_Trainer.GetTrainerType(),
		}
		ClassTrainerFrame_InitServiceButton(ClassTrainerFrame.skillStepButton, elementData);
	end

	-- Close the confirmation dialog if you choose a different skill
	if ( StaticPopup_Visible("CONFIRM_PROFESSION") ) then
		StaticPopup_Hide("CONFIRM_PROFESSION");
	end
end

ClassTrainerCategoryButtonMixin = {};

function ClassTrainerCategoryButtonMixin:OnSmartNavSelect()
	-- Make sure smart nav stays in sync with selected services
	ClassTrainer_SetSelection(nil);
end

ClassTrainerSkillButtonMixin = {};

function ClassTrainerSkillButtonMixin:OnSmartNavSelect()
	-- Make sure smart nav stays in sync with selected services
	ClassTrainer_SetSelection(self:GetID());
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
