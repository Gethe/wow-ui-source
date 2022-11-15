EditModeDialogMixin = {};

function EditModeDialogMixin:EditModeDialog_OnLoad()
	EventRegistry:RegisterCallback("EditMode.Exit", function() self:OnEditModeExit() end);
end

function EditModeDialogMixin:OnEditModeExit()
	-- Override this as necessary
	if self.OnCancel then
		self:OnCancel();
	end
end

EditModeNewLayoutDialogMixin = {};

function EditModeNewLayoutDialogMixin:OnLoad()
	self.exclusive = true;
	self.AcceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self))
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self))
	self.CharacterSpecificLayoutCheckButton:SetCallback(GenerateClosure(self.UpdateAcceptButtonEnabledState, self))
end

function EditModeNewLayoutDialogMixin:OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function EditModeNewLayoutDialogMixin:ShowDialog(copyLayoutInfo)
	self.copyLayoutInfo = copyLayoutInfo;
	self.LayoutNameEditBox:SetText("");

	local isCharacterSpecific = (copyLayoutInfo.layoutType == Enum.EditModeLayoutType.Character);
	self.CharacterSpecificLayoutCheckButton:SetControlChecked(isCharacterSpecific);

	StaticPopupSpecial_Show(self);
end

function EditModeNewLayoutDialogMixin:OnAccept()
	if self.AcceptButton:IsEnabled() then
		local layoutType = self.CharacterSpecificLayoutCheckButton:IsControlChecked() and Enum.EditModeLayoutType.Character or Enum.EditModeLayoutType.Account;
		local newLayoutInfo = CopyTable(self.copyLayoutInfo);
		EditModeManagerFrame:RevertAllChanges();
		EditModeManagerFrame:MakeNewLayout(newLayoutInfo, layoutType, self.LayoutNameEditBox:GetText());
		StaticPopupSpecial_Hide(self);
	end
end

local maxCharLayoutsErrorText = HUD_EDIT_MODE_ERROR_MAX_CHAR_LAYOUTS:format(Constants.EditModeConsts.EditModeMaxLayoutsPerType);
local maxAccountLayoutsErrorText = HUD_EDIT_MODE_ERROR_MAX_ACCOUNT_LAYOUTS:format(Constants.EditModeConsts.EditModeMaxLayoutsPerType);
local maxLayoutsErrorText = HUD_EDIT_MODE_ERROR_MAX_LAYOUTS:format(Constants.EditModeConsts.EditModeMaxLayoutsPerType, Constants.EditModeConsts.EditModeMaxLayoutsPerType);

local function CheckForMaxLayouts(acceptButton, charSpecificButton)
	if EditModeManagerFrame:AreLayoutsFullyMaxed() then
		acceptButton.disabledTooltip = maxLayoutsErrorText;
		acceptButton:Disable();
		return true;
	end

	local layoutType = charSpecificButton:IsControlChecked() and Enum.EditModeLayoutType.Character or Enum.EditModeLayoutType.Account;
	local areLayoutsMaxed = EditModeManagerFrame:AreLayoutsOfTypeMaxed(layoutType);
	if areLayoutsMaxed then
		acceptButton.disabledTooltip = (layoutType == Enum.EditModeLayoutType.Character) and maxCharLayoutsErrorText or maxAccountLayoutsErrorText;
		acceptButton:Disable();
		return true;
	end
end

local function CheckForDuplicateLayoutName(acceptButton, editBox)
	local editBoxText = editBox:GetText();
	local editModeLayouts = EditModeManagerFrame:GetLayouts();
	for index, layout in ipairs(editModeLayouts) do
		if layout.layoutName == editBoxText then
			acceptButton.disabledTooltip = HUD_EDIT_MODE_ERROR_DUPLICATE_NAME;
			acceptButton:Disable();
			return true;
		end
	end
end

function EditModeNewLayoutDialogMixin:UpdateAcceptButtonEnabledState()
	if not CheckForMaxLayouts(self.AcceptButton, self.CharacterSpecificLayoutCheckButton)
		and not CheckForDuplicateLayoutName(self.AcceptButton, self.LayoutNameEditBox)  then
		self.AcceptButton.disabledTooltip = HUD_EDIT_MODE_ERROR_ENTER_NAME;
		self.AcceptButton:SetEnabled(UserEditBoxNonEmpty(self.LayoutNameEditBox));
	end
end

function EditModeNewLayoutDialogMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end

EditModeDialogNameEditBoxMixin = {};

function EditModeDialogNameEditBoxMixin:OnEnterPressed()
	self:GetParent():OnAccept();
end

function EditModeDialogNameEditBoxMixin:OnEscapePressed()
	self:GetParent():OnCancel();
end

function EditModeDialogNameEditBoxMixin:OnTextChanged()
	self:GetParent():UpdateAcceptButtonEnabledState();
end

EditModeImportLayoutDialogMixin = {};

function EditModeImportLayoutDialogMixin:OnLoad()
	self.exclusive = true;
	self.AcceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self))
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self))
	self.CharacterSpecificLayoutCheckButton:SetCallback(GenerateClosure(self.UpdateAcceptButtonEnabledState, self))
	self.ImportBox.EditBox:SetScript("OnTextChanged", GenerateClosure(self.OnImportTextChanged, self));
	self.ImportBox.EditBox:SetScript("OnEnterPressed", GenerateClosure(self.OnAccept, self));
	self.ImportBox.EditBox:SetScript("OnEscapePressed", GenerateClosure(self.OnCancel, self));
end

function EditModeImportLayoutDialogMixin:OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function EditModeImportLayoutDialogMixin:ShowDialog()
	self.ImportBox.EditBox:SetText("");
	self.CharacterSpecificLayoutCheckButton:SetControlChecked(false);
	StaticPopupSpecial_Show(self);
	self.ImportBox.EditBox:SetFocus();
end

function EditModeImportLayoutDialogMixin:OnAccept()
	if self.AcceptButton:IsEnabled() then
		local layoutType = self.CharacterSpecificLayoutCheckButton:IsControlChecked() and Enum.EditModeLayoutType.Character or Enum.EditModeLayoutType.Account;
		EditModeManagerFrame:ImportLayout(self.importLayoutInfo, layoutType, self.LayoutNameEditBox:GetText());
		StaticPopupSpecial_Hide(self);
	end
end

function EditModeImportLayoutDialogMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end

function EditModeImportLayoutDialogMixin:UpdateAcceptButtonEnabledState()
	if not CheckForMaxLayouts(self.AcceptButton, self.CharacterSpecificLayoutCheckButton)
		and not CheckForDuplicateLayoutName(self.AcceptButton, self.LayoutNameEditBox)  then
		self.AcceptButton.disabledTooltip = HUD_EDIT_MODE_ERROR_ENTER_IMPORT_STRING_AND_NAME;
		self.AcceptButton:SetEnabled((self.importLayoutInfo ~= nil) and UserEditBoxNonEmpty(self.LayoutNameEditBox));
	end
end

function EditModeImportLayoutDialogMixin:OnImportTextChanged(text)
	self.importLayoutInfo = C_EditMode.ConvertStringToLayoutInfo(self.ImportBox.EditBox:GetText());
	if self.importLayoutInfo then
		self.LayoutNameEditBox:Enable();
	else
		self.LayoutNameEditBox:Disable();
	end
	self.LayoutNameEditBox:SetText("");
	self:UpdateAcceptButtonEnabledState();
end

EditModeImportLayoutLinkDialogMixin = {};

function EditModeImportLayoutLinkDialogMixin:OnLoad()
	self.exclusive = true;
	self.AcceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self))
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self))
	self.CharacterSpecificLayoutCheckButton:SetCallback(GenerateClosure(self.UpdateAcceptButtonEnabledState, self))
end

function EditModeImportLayoutLinkDialogMixin:OnHide()
	self.importLayoutInfo = nil;
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function EditModeImportLayoutLinkDialogMixin:ShowDialog(link)
	local _, linkOptions = LinkUtil.ExtractLink(link);
	local importLayoutInfo = C_EditMode.ConvertStringToLayoutInfo(linkOptions);
	if importLayoutInfo then
		self.LayoutNameEditBox:SetText("");
		self.CharacterSpecificLayoutCheckButton:SetControlChecked(false);
		self.importLayoutInfo = importLayoutInfo;
		StaticPopupSpecial_Show(self);
	end
end

function EditModeImportLayoutLinkDialogMixin:OnAccept()
	if self.AcceptButton:IsEnabled() then
		local layoutType = self.CharacterSpecificLayoutCheckButton:IsControlChecked() and Enum.EditModeLayoutType.Character or Enum.EditModeLayoutType.Account;	
		EditModeManagerFrame:ImportLayout(self.importLayoutInfo, layoutType, self.LayoutNameEditBox:GetText());
		StaticPopupSpecial_Hide(self);
	end
end

function EditModeImportLayoutLinkDialogMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end

function EditModeImportLayoutLinkDialogMixin:UpdateAcceptButtonEnabledState()
	if not CheckForMaxLayouts(self.AcceptButton, self.CharacterSpecificLayoutCheckButton)
		and not CheckForDuplicateLayoutName(self.AcceptButton, self.LayoutNameEditBox)  then
		self.AcceptButton.disabledTooltip = HUD_EDIT_MODE_ERROR_ENTER_IMPORT_STRING_AND_NAME;
		self.AcceptButton:SetEnabled(UserEditBoxNonEmpty(self.LayoutNameEditBox));
	end
end

EditModeUnsavedChangesDialogMixin = {};

function EditModeUnsavedChangesDialogMixin:OnLoad()
	self.exclusive = true;
	self.SaveAndProceedButton:SetOnClickHandler(GenerateClosure(self.OnSaveAndProceed, self))
	self.ProceedButton:SetOnClickHandler(GenerateClosure(self.OnProceed, self))
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self))
end

function EditModeUnsavedChangesDialogMixin:OnHide()
	self.selectedLayoutIndex = nil;
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function EditModeUnsavedChangesDialogMixin:ShowDialog(selectedLayoutIndex)
	if selectedLayoutIndex then
		self.Title:SetText(HUD_EDIT_MODE_UNSAVED_CHANGES_LAYOUT_CHANGE_DIALOG_TITLE);
		self.SaveAndProceedButton:SetText(HUD_EDIT_MODE_SAVE_AND_SWITCH);
		self.ProceedButton:SetText(HUD_EDIT_MODE_SWITCH);
	else
		self.Title:SetText(HUD_EDIT_MODE_UNSAVED_CHANGES_EXIT_DIALOG_TITLE);
		self.SaveAndProceedButton:SetText(HUD_EDIT_MODE_SAVE_AND_EXIT);
		self.ProceedButton:SetText(HUD_EDIT_MODE_EXIT);
	end
	self.selectedLayoutIndex = selectedLayoutIndex;
	StaticPopupSpecial_Show(self);
end

function EditModeUnsavedChangesDialogMixin:OnSaveAndProceed()
	EditModeManagerFrame:SaveLayoutChanges();
	self:OnProceed();
end

function EditModeUnsavedChangesDialogMixin:OnProceed()
	if self.selectedLayoutIndex then
		EditModeManagerFrame:SelectLayout(self.selectedLayoutIndex);
	else
		HideUIPanel(EditModeManagerFrame);
	end

	StaticPopupSpecial_Hide(self);
end

function EditModeUnsavedChangesDialogMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end

EditModeSystemSettingsDialogMixin = {};

function EditModeSystemSettingsDialogMixin:OnLoad()
	local function onCloseCallback()
		EditModeManagerFrame:ClearSelectedSystem();
	end

	self.Buttons.RevertChangesButton:SetOnClickHandler(GenerateClosure(self.RevertChanges, self));

	self.onCloseCallback = onCloseCallback;

	self.pools = CreateFramePoolCollection();
	self.pools:CreatePool("FRAME", self.Settings, "EditModeSettingDropdownTemplate");
	self.pools:CreatePool("FRAME", self.Settings, "EditModeSettingSliderTemplate");
	self.pools:CreatePool("FRAME", self.Settings, "EditModeSettingCheckboxTemplate");

	local function resetExtraButton(pool, button)
		FramePool_HideAndClearAnchors(pool, button);
		button:Enable();
	end
	self.pools:CreatePool("BUTTON", self.Buttons, "EditModeSystemSettingsDialogExtraButtonTemplate", resetExtraButton);
end

function EditModeSystemSettingsDialogMixin:OnHide()
	self.attachedToSystem = nil;
end

function EditModeSystemSettingsDialogMixin:OnDragStart()
	self:StartMoving();
end

function EditModeSystemSettingsDialogMixin:OnDragStop()
	self:StopMovingOrSizing();
end

function EditModeSystemSettingsDialogMixin:AttachToSystemFrame(systemFrame)
	self.resetDialogAnchors = systemFrame:ShouldResetSettingsDialogAnchors(self.attachedToSystem);
	self.attachedToSystem = systemFrame;
	self.Title:SetText(systemFrame.systemName);
	self:UpdateDialog(systemFrame);
	self:Show();
end

local edgePercentage = 2 / 5;
local edgePercentageInverse =  1 - edgePercentage;

function EditModeSystemSettingsDialogMixin:UpdateSizeAndAnchors(systemFrame)
	if systemFrame == self.attachedToSystem then
		if self.resetDialogAnchors then
			local clearAllPoints = true;
			systemFrame:GetSettingsDialogAnchor():SetPoint(self, clearAllPoints);
			self.resetDialogAnchors = false;
		end
		self:Layout();
	end
end

function EditModeSystemSettingsDialogMixin:UpdateDialog(systemFrame)
	self:UpdateSettings(systemFrame);
	self:UpdateButtons(systemFrame);
	self:UpdateExtraButtons(systemFrame);
	self:UpdateSizeAndAnchors(systemFrame);
end

function EditModeSystemSettingsDialogMixin:GetSettingPool(settingType)
	if settingType == Enum.EditModeSettingDisplayType.Dropdown then
		return self.pools:GetPool("EditModeSettingDropdownTemplate");
	elseif settingType == Enum.EditModeSettingDisplayType.Slider then
		return self.pools:GetPool("EditModeSettingSliderTemplate");
	elseif settingType == Enum.ChrCustomizationOptionType.Checkbox then
		return self.pools:GetPool("EditModeSettingCheckboxTemplate");
	end
end

function EditModeSystemSettingsDialogMixin:ReleaseAllNonSliders()
	self.pools:ReleaseAllByTemplate("EditModeSettingDropdownTemplate");
	self.pools:ReleaseAllByTemplate("EditModeSettingCheckboxTemplate");
end

function EditModeSystemSettingsDialogMixin:ReleaseNonDraggingSliders()
	local draggingSlider;
	local releaseSliders = {};

	for settingSlider in self.pools:EnumerateActiveByTemplate("EditModeSettingSliderTemplate") do
		if settingSlider.Slider.Slider:IsDraggingThumb() then
			draggingSlider = settingSlider;
		else
			table.insert(releaseSliders, settingSlider);
		end
	end

	for _, releaseSlider in ipairs(releaseSliders) do
		releaseSlider.Slider:Release();
		self.pools:Release(releaseSlider);
	end

	return draggingSlider;
end

function EditModeSystemSettingsDialogMixin:UpdateSettings(systemFrame)
	if systemFrame == self.attachedToSystem then
		self:ReleaseAllNonSliders();
		local draggingSlider = self:ReleaseNonDraggingSliders();

		local settingsToSetup = {};

		local systemSettingDisplayInfo = EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfo(self.attachedToSystem.system);
		for index, displayInfo in ipairs(systemSettingDisplayInfo) do
			if self.attachedToSystem:ShouldShowSetting(displayInfo.setting) then 
				local settingPool = self:GetSettingPool(displayInfo.type);
				if settingPool then
					local settingFrame;

					if draggingSlider and draggingSlider.setting == displayInfo.setting then
						-- This is a slider that is being interacted with and so was not released.
						settingFrame = draggingSlider;
					else
						settingFrame = settingPool:Acquire();
					end

					settingFrame:SetPoint("TOPLEFT");
					settingFrame.layoutIndex = index;
					local settingName = (self.attachedToSystem:UseSettingAltName(displayInfo.setting) and displayInfo.altName) and displayInfo.altName or displayInfo.name;
					local updatedDisplayInfo = self.attachedToSystem:UpdateDisplayInfoOptions(displayInfo);
					settingsToSetup[settingFrame] = { displayInfo = updatedDisplayInfo, currentValue = self.attachedToSystem:GetSettingValue(updatedDisplayInfo.setting), settingName = settingName },
					settingFrame:Show();
				end
			end
		end

		self.Buttons:ClearAllPoints();

		if not next(settingsToSetup) then
			self.Settings:Hide();
			self.Buttons:SetPoint("TOP", self.Title, "BOTTOM", 0, -12);
		else
			self.Settings:Show();
			self.Settings:Layout();
			for settingFrame, settingData in pairs(settingsToSetup) do
				settingFrame:SetupSetting(settingData);
			end
			self.Buttons:SetPoint("TOPLEFT", self.Settings, "BOTTOMLEFT", 0, -12);
		end
	end
end

function EditModeSystemSettingsDialogMixin:UpdateButtons(systemFrame)
	if systemFrame == self.attachedToSystem then
		self.Buttons.RevertChangesButton:SetEnabled(self.attachedToSystem:HasActiveChanges());
	end
end

function EditModeSystemSettingsDialogMixin:UpdateExtraButtons(systemFrame)
	if systemFrame == self.attachedToSystem then
		self.pools:ReleaseAllByTemplate("EditModeSystemSettingsDialogExtraButtonTemplate");
		local addedButtons = systemFrame:AddExtraButtons(self.pools:GetPool("EditModeSystemSettingsDialogExtraButtonTemplate"));
		self.Buttons.Divider:SetShown(addedButtons);
	end
end

function EditModeSystemSettingsDialogMixin:OnSettingValueChanged(setting, value)
	if self.attachedToSystem then
		EditModeManagerFrame:OnSystemSettingChange(self.attachedToSystem, setting, value);
	end
end

function EditModeSystemSettingsDialogMixin:RevertChanges()
	if self.attachedToSystem then
		EditModeManagerFrame:RevertSystemChanges(self.attachedToSystem);
	end
end