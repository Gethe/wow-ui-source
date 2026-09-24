ExperiencePresetMixin = CreateFromMixins(NarrationStaticNameMixin, NarrationStaticDescriptionMixin);

function ExperiencePresetMixin:OnLoad()
	SetLoginScreenModel(self);
	self:SetNarrationName(self.Title:GetText());
	self:SetNarrationDescription(self.Description:GetText());
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
		local selectedPreset = ClassicExperienceButton:GetChecked() and Enum.ForeverExperiencePreset.Classic or Enum.ForeverExperiencePreset.Modern;
		C_GameRules.SetForeverExperiencePreset(selectedPreset);
	end
end

ExperiencePresetCancelButtonMixin = {};

function ExperiencePresetCancelButtonMixin:OnClick()
	PlaySound(SOUNDKIT.UI_EXPERIENCE_PRESET_OPTION_CLICK);
	C_Login.DisconnectFromServer();
	CharacterSelectUtil.ExitAccountLoginSelection();
end
