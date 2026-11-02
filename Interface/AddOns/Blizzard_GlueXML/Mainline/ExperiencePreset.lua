ExperiencePresetMixin = CreateFromMixins(NarrationStaticNameMixin, NarrationStaticDescriptionMixin);

function ExperiencePresetMixin:OnLoad()
	SetLoginScreenModel(self);
	self:SetNarrationName(self.Title:GetText());
	self:SetNarrationDescription(self.Description:GetText());

	self:RegisterForTransitions();
end

function ExperiencePresetMixin:OnShow()
	local narrationInfo = NarrationUtil.RegionToNarrationInfo(self, NarrationUtil.TriggerType.Notification);
	if narrationInfo then
		EventRegistry:TriggerEvent("Narration.Speak", narrationInfo);
	end
end

function ExperiencePresetMixin:NarrationShouldIgnoreFocus()
	return true;
end

function ExperiencePresetMixin:FocusGamepad()
	self.frameFooter:ShowAndActivateBindings();
	SmartNavigation:SetTargetButtonForFrame(self, ClassicExperienceButton);
end

function ExperiencePresetMixin:UnfocusGamepad()
	self.frameFooter:HideAndDeactivateBindings();
end

function ExperiencePresetMixin:SetupGamepad()
	local select = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, function()
		SelectButton:OnClick();
	end, ACTION_LABEL_SELECT);

	local back = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, function()
		CancelButton:OnClick();
	end, FRAME_ACTION_BACK);

	self.frameFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "ExperiencePresetFooter");
	self.frameFooter:AddPromptedBinding(select);
	self.frameFooter:AddPromptedBinding(back);
	self.frameFooter:Finalize();
	self.frameFooter.inputLegend:ClearAllPoints();
	self.frameFooter.inputLegend:SetPoint("BOTTOM", self, "BOTTOM", 0, 10);
end

function ExperiencePresetMixin:InitializeGamepad()
	SelectButton:Hide();
	CancelButton:Hide();
end

function ExperiencePresetMixin:UninitializeGamepad()
	SelectButton:Show();
	CancelButton:Show();
end

function ExperiencePresetMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

ExperiencePresetButtonMixin = CreateFromMixins(NarrationStaticNameMixin, NarrationStaticDescriptionMixin);

function ExperiencePresetButtonMixin:OnClick()
	self:SetChecked(true);
	SelectButton:Enable();
	SelectButton:SetDisabledTooltip(nil);
	PlaySound(SOUNDKIT.UI_EXPERIENCE_PRESET_OPTION_CLICK);
	if(self.isClassicButton) then
		ModernExperienceButton:SetChecked(false);
	else
		ClassicExperienceButton:SetChecked(false);
	end
end

function ExperiencePresetButtonMixin:OnLoad()
	if(self.isClassicButton) then
		self.Title:SetText(EXPERIENCE_PRESET_CLASSIC);
		self.Description:SetText(EXPERIENCE_PRESET_CLASSIC_DESCRIPTION);
		self.BulletPoint1.BulletText:SetText(EXPERIENCE_PRESET_CLASSIC_CHARACTER_MODELS);
		self.BulletPoint2.BulletText:SetText(EXPERIENCE_PRESET_CLASSIC_QUEST_POI);
		self.BulletPoint3.BulletText:SetText(EXPERIENCE_PRESET_CLASSIC_ONE_BAG);
		self.BulletPoint4.BulletText:SetText(EXPERIENCE_PRESET_CLASSIC_TRANSMOG);
		self.BulletPoint5.BulletText:SetText(EXPERIENCE_PRESET_CLASSIC_KEYBOARD_BINDS);
		self.BulletPoint6.BulletText:SetText(EXPERIENCE_PRESET_CLASSIC_UI_LAYOUT);
		self.Icon:SetAtlas('Achievement_Character_Human_Male');
	else
		self.Title:SetText(EXPERIENCE_PRESET_ENHANCED);
		self.Description:SetText(EXPERIENCE_PRESET_ENHANCED_DESCRIPTION);
		self.BulletPoint1.BulletText:SetText(EXPERIENCE_PRESET_ENHANCED_CHARACTER_MODELS);
		self.BulletPoint2.BulletText:SetText(EXPERIENCE_PRESET_ENHANCED_QUEST_POI);
		self.BulletPoint3.BulletText:SetText(EXPERIENCE_PRESET_ENHANCED_ONE_BAG);
		self.BulletPoint4.BulletText:SetText(EXPERIENCE_PRESET_ENHANCED_TRANSMOG);
		self.BulletPoint5.BulletText:SetText(EXPERIENCE_PRESET_ENHANCED_KEYBOARD_BINDS);
		self.BulletPoint6.BulletText:SetText(EXPERIENCE_PRESET_ENHANCED_UI_LAYOUT);
		self.Icon:SetAtlas('raceicon-human-male');
	end

	self:SetNarrationName(self.Title:GetText());

	local bulletNarration = NarrationUtil.MakeNarrationString(
		self.BulletPoint1.BulletText:GetText(),
		self.BulletPoint2.BulletText:GetText(),
		self.BulletPoint3.BulletText:GetText(),
		self.BulletPoint4.BulletText:GetText(),
		self.BulletPoint5.BulletText:GetText(),
		self.BulletPoint6.BulletText:GetText()
	);
	self:SetNarrationDescription(NarrationUtil.MakeNarrationString(self.Description:GetText(), self.StartingSettings:GetText(), bulletNarration));
end

function ExperiencePresetButtonMixin:OnSmartNavSelect()
	self:OnClick();
end

function ExperiencePresetButtonMixin:OnShow()
	self:SetChecked(false);
end

function ExperiencePresetButtonMixin:NarrationGetContext()
	if self:GetChecked() then
		return NARRATION_STATUS_SELECTED_FORMAT:format(NARRATION_OBJECT_BUTTON);
	end

	return NARRATION_OBJECT_BUTTON;
end

ExperiencePresetSelectButtonMixin = {};

function ExperiencePresetSelectButtonMixin:OnShow()
	self:Disable();
	self:SetDisabledTooltip(EXPERIENCE_PRESET_SELECT_DISABLED_REASON);
end

function ExperiencePresetSelectButtonMixin:OnClick()
	PlaySound(SOUNDKIT.UI_EXPERIENCE_PRESET_SELECT_CLICK);
	if (ClassicExperienceButton:GetChecked() or ModernExperienceButton:GetChecked()) then
		local selectedPreset = ClassicExperienceButton:GetChecked() and Enum.ForeverExperiencePreset.Classic or Enum.ForeverExperiencePreset.Enhanced;
		C_GameRules.SetForeverExperiencePresetPreLogin(selectedPreset);
	end
end

ExperiencePresetCancelButtonMixin = {};

function ExperiencePresetCancelButtonMixin:OnClick()
	PlaySound(SOUNDKIT.UI_EXPERIENCE_PRESET_OPTION_CLICK);
	C_Login.DisconnectFromServer();
	CharacterSelectUtil.ExitAccountLoginSelection();
end
