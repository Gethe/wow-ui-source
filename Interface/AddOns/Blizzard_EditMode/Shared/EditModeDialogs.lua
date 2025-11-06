EditModeBaseDialogMixin = {};

function EditModeBaseDialogMixin:EditModeDialog_OnLoad()
	self.exclusive = true;
	self:SetupEditBoxHandlers(self:GetEditBox(), self.UpdateAcceptButtonEnabledState, self.OnAccept, self.OnCancel);
	self:SetupButtonClickHandlers();

	self.managerExitCallbackEventName = self:GetManagerExitCallbackEventName();
end

function EditModeBaseDialogMixin:EditModeDialog_OnShow()
	if self.managerExitCallbackEventName then
		EventRegistry:RegisterCallback(self.managerExitCallbackEventName, self.OnManagerExit, self);
	end
end

function EditModeBaseDialogMixin:EditModeDialog_OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);

	if self.managerExitCallbackEventName then
		EventRegistry:UnregisterCallback(self.managerExitCallbackEventName, self);
	end
end

function EditModeBaseDialogMixin:SetLayoutManager(manager)
	self.layoutManager = manager;
end

function EditModeBaseDialogMixin:GetLayoutManager()
	return self.layoutManager;
end

function EditModeBaseDialogMixin:SetLayoutInfo(layoutInfo)
	self.layoutInfo = layoutInfo;
end

function EditModeBaseDialogMixin:GetLayoutInfo()
	return self.layoutInfo;
end

function EditModeBaseDialogMixin:SetLayoutIndex(layoutIndex)
	self.layoutIndex = layoutIndex;
end

function EditModeBaseDialogMixin:GetLayoutIndex()
	return self.layoutIndex;
end

--[[
	Pass in a table of mode data for each mode, the names are "well-known" keys in the table which include but aren't limited to:
	newLayout, renameLayout, deleteLayout (custom mode keys are also possible, just build an API that sets the desired mode, or set it directly from your caller)

	Each sub-table contains the following data:

	{
		title = string,						-- Set with varargs, whatever args you pass when you show the dialog (NOTE: Layout name: Except for Import, could add that if needed, but it's not supported)
		acceptText = string,				-- String for accept/confirm
		cancelText = string,				-- String for close/cancel
		disabledAcceptTooltip = opt string,	-- String for tooltip when accept button is disabled
		needsEditbox = bool,				-- Whether the layout name edit box is needed
		useLayoutNameForEditBox = bool,		-- Use the layout name as the initial edit box text and select it
		needsCharacterSpecific = bool,		-- Whether the layout is character-specific
											-- TODO: If other systems use this setting then HUD_EDIT_MODE_CHARACTER_SPECIFIC_LAYOUT used for the label needs to be configurable
		onCancelEvent = string,				-- Event name to fire when the dialog is canceled

		-- NOTE: All callbacks are passed the layoutManager and the dialog
		onCancelCallback = function,		-- Called when the Cancel is clicked
		onAcceptCallback = function,		-- Called when Accept is clicked
		updateAcceptCallback = function,	-- Called when various attributes about the dialog change and things need to be verified

		-- The following apply to the import dialog
		importEditBoxLabel = string,		-- Label shown above the large edit box that contains the import data
		nameEditBoxLabel = string,			-- Label shown above the layout name edit box
		instructionsLabel = string,			-- Label shown in the import edit box that say what to enter
	},
--]]
function EditModeBaseDialogMixin:SetModeData(modes)
	self.modes = modes;
end

function EditModeBaseDialogMixin:GetModeData()
	return self.dialogModeData;
end

function EditModeBaseDialogMixin:SetMode(mode, layoutName, ...)
	local modeData = self.modes[mode];
	assertsafe(modeData ~= nil, "Mode %s was unsupported.", tostring(mode));
	self.dialogModeData = modeData;
	self:SetupControlsForMode(modeData, layoutName, ...);
	self:UpdateAcceptButtonEnabledState();
end

function EditModeBaseDialogMixin:SetupControlsForMode(_modeData, _layoutName, ...)
	-- Override as needed, call base class
	StaticPopupSpecial_Show(self);
end

function EditModeBaseDialogMixin:SetupEditBoxHandlers(editBox, onTextChanged, onEnter, onEscape)
	if editBox then
		editBox:SetScript("OnTextChanged", GenerateClosure(onTextChanged, self));
		editBox:SetScript("OnEnterPressed", GenerateClosure(onEnter, self));
		editBox:SetScript("OnEscapePressed", GenerateClosure(onEscape, self));
	end
end

function EditModeBaseDialogMixin:SetupButtonClickHandlers()
	local acceptButton = self:GetAcceptButton();
	if acceptButton then
		acceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self));
	end

	local cancelButton = self:GetCancelButton();
	if cancelButton then
		cancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self));
	end

	local characterSpecificButton = self:GetCharacterSpecificButton();
	if characterSpecificButton then
		characterSpecificButton:SetCallback(GenerateClosure(self.UpdateAcceptButtonEnabledState, self));
	end
end

local function RunLayoutDialogCallback(dialog, callbackKey)
	local modeData = dialog:GetModeData();
	if modeData and modeData[callbackKey] then
		return modeData[callbackKey](dialog:GetLayoutManager(), dialog);
	end
end

function EditModeBaseDialogMixin:OnAccept()
	if self:CanAccept() then
		RunLayoutDialogCallback(self, "onAcceptCallback");
		StaticPopupSpecial_Hide(self);
	end
end

function EditModeBaseDialogMixin:UpdateAcceptButtonEnabledState()
	local enableAcceptButton, disabledTooltipOverride = RunLayoutDialogCallback(self, "updateAcceptCallback");
	self:GetAcceptButton():SetEnabled(enableAcceptButton);
	self:GetAcceptButton().disabledTooltip = disabledTooltipOverride;
end

function EditModeBaseDialogMixin:GetOnCancelEvent()
	local modeData = self:GetModeData();
	return modeData and modeData.onCancelEvent;
end

function EditModeBaseDialogMixin:OnCancel()
	RunLayoutDialogCallback(self, "onCancelCallback");
	StaticPopupSpecial_Hide(self);

	local onCancelEvent = self:GetOnCancelEvent();
	if onCancelEvent then
		EventRegistry:TriggerEvent(onCancelEvent);
	end
end

function EditModeBaseDialogMixin:GetEditBox()
	-- override as necessary
	return self.LayoutNameEditBox;
end

function EditModeBaseDialogMixin:GetEditBoxText()
	local editBox = self:GetEditBox();
	if editBox then
		return editBox:GetText();
	end

	return nil;
end

function EditModeBaseDialogMixin:GetAcceptButton()
	-- override as necessary
	return self.AcceptButton;
end

function EditModeBaseDialogMixin:CanAccept()
	local acceptButton = self:GetAcceptButton();
	return acceptButton and acceptButton:IsEnabled();
end

function EditModeBaseDialogMixin:GetCancelButton()
	-- override as necessary
	return self.CancelButton;
end

function EditModeBaseDialogMixin:GetCharacterSpecificButton()
	-- override as necessary
	return self.CharacterSpecificLayoutCheckButton;
end

function EditModeBaseDialogMixin:IsCharacterSpecificLayoutChecked()
	local characterSpecificButton = self:GetCharacterSpecificButton();
	if characterSpecificButton then
		return characterSpecificButton:IsControlChecked();
	end

	return false;
end

function EditModeBaseDialogMixin:GetDesiredLayoutType()
	-- override as necessary
	return self:IsCharacterSpecificLayoutChecked() and Enum.EditModeLayoutType.Character or Enum.EditModeLayoutType.Account;
end

function EditModeBaseDialogMixin:GetManagerExitCallbackEventName()
	-- Override this as necessary
	return "EditMode.Exit";
end

function EditModeBaseDialogMixin:ShouldCloseWhenManagerCloses()
	-- Override this as necessary
	return true;
end

function EditModeBaseDialogMixin:OnManagerExit()
	-- Override this as necessary
	if self:IsShown() and self:ShouldCloseWhenManagerCloses() then
		self:OnCancel();
	end
end

function EditModeBaseDialogMixin:OnEditModeExit()
	-- TODO: Complete rename to OnManagerExit, but I need to track down all the dialog instances that use this
	-- This is about to be dead code
	self:OnManagerExit();
end

EditModeLayoutDialogMixin = {};

function EditModeLayoutDialogMixin:SetupControlsForMode(modeData, layoutName, ...)
	self.Title:SetText(modeData.title:format(layoutName, ...));
	self:GetAcceptButton():SetText(modeData.acceptText);
	self:GetAcceptButton():SetDisabledTooltip(modeData.disabledAcceptTooltip);
	self:GetCancelButton():SetText(modeData.cancelText);
	self:GetEditBox():SetShown(modeData.needsEditbox);

	if modeData.needsEditbox then
		self:GetEditBox():SetText(modeData.useLayoutNameForEditBox and layoutName or "");
		self:GetEditBox():HighlightText();
	else
		self:GetEditBox():SetText("");
	end

	self:GetCharacterSpecificButton():SetShown(modeData.needsCharacterSpecific);

	if modeData.needsEditbox and modeData.needsCharacterSpecific then
		self:SetHeight(150);
	elseif modeData.needsEditbox and not modeData.needsCharacterSpecific then
		self:SetHeight(130);
	elseif not modeData.needsEditbox and modeData.needsCharacterSpecific then
		assertsafe(false, "This case is unsupported");
	else
		self:SetHeight(120);
	end

	EditModeBaseDialogMixin.SetupControlsForMode(self, modeData, ...);
end

function EditModeLayoutDialogMixin:ShowNewLayoutDialog(layoutInfo)
	self:SetLayoutInfo(layoutInfo);

	local isCharacterSpecific = self:GetLayoutManager():IsCharacterSpecificLayout(layoutInfo);
	self:GetCharacterSpecificButton():SetControlChecked(isCharacterSpecific);

	self:SetMode("newLayout");
end

function EditModeLayoutDialogMixin:ShowRenameLayoutDialog(layoutIndex, layoutInfo)
	self:SetLayoutInfo(layoutInfo);
	self:SetLayoutIndex(layoutIndex);
	self:SetMode("renameLayout", self:GetLayoutManager():GetLayoutName(layoutInfo));
end

function EditModeLayoutDialogMixin:ShowDeleteLayoutDialog(layoutIndex, layoutInfo)
	self:SetLayoutInfo(layoutInfo);
	self:SetLayoutIndex(layoutIndex);
	self:SetMode("deleteLayout", self:GetLayoutManager():GetLayoutName(layoutInfo));
end

EditModeImportLayoutDialogMixin = {};

function EditModeImportLayoutDialogMixin:GetImportEditBox()
	return self.ImportBox.EditBox;
end

function EditModeImportLayoutDialogMixin:GetImportBox()
	return self.ImportBox;
end

function EditModeImportLayoutDialogMixin:GetImportBoxLabel()
	return self.EditBoxLabel;
end

function EditModeImportLayoutDialogMixin:GetEditBoxLabel()
	return self.NameEditBoxLabel;
end

function EditModeImportLayoutDialogMixin:OnLoad()
	self:SetupEditBoxHandlers(self:GetImportEditBox(), self.OnImportTextChanged, self.OnAccept, self.OnCancel);

	-- TODO: Setup the callbacks for the name edit box to update the layoutInfo as needed? This is optional and can be handled in OnAccept as well.
	-- One reason to do setup these callbacks here would be to verify that the name is valid as the user changes it.
end

function EditModeImportLayoutDialogMixin:ShowImportLayoutDialog()
	self:SetMode("importLayout");
end

function EditModeImportLayoutDialogMixin:SetupControlsForMode(modeData, ...)
	-- NOTE: Do not call anything except the base SetupControlsForMode, in this case all the setup needs to be custom

	self:SetLayoutInfo();
	self.Title:SetText(modeData.title); -- See Above: layout name is not formatted in here.
	self:GetAcceptButton():SetText(modeData.acceptText);
	self:GetAcceptButton():SetDisabledTooltip(modeData.disabledAcceptTooltip);
	self:GetCancelButton():SetText(modeData.cancelText);
	self:GetEditBox():SetShown(true); -- The layout always needs a way to name it
	self:GetEditBox():SetText(""); -- Force the user to name the imported layout, we don't trust external text.
	self:GetEditBoxLabel():SetText(modeData.nameEditBoxLabel);
	self:GetImportEditBox():SetText("");
	InputScrollFrame_SetInstructions(self:GetImportBox(), modeData.instructionsLabel);
	self:GetImportBoxLabel():SetText(modeData.importEditBoxLabel);
	self:GetImportEditBox():SetFocus();
	self:GetCharacterSpecificButton():SetControlChecked(false);
	self:GetCharacterSpecificButton():SetShown(modeData.needsCharacterSpecific);

	if modeData.needsCharacterSpecific then
		self:SetHeight(370);
	else
		self:SetHeight(345);
	end

	EditModeBaseDialogMixin.SetupControlsForMode(self, modeData, ...);
end

function EditModeImportLayoutDialogMixin:OnImportTextChanged(editBox, isUserChange)
	-- HACK: Cache text to avoid duplicate ProcessText calls
	-- Required because this is getting called twice for certain editbox types (usually after initial show or pasting of text).
	local importText = editBox:GetText();
	if self.importText == importText then
		return;
	end

	self.importText = importText;
	-- END HACK

	InputScrollFrame_OnTextChanged(editBox, isUserChange);

	self:ProcessImportText(editBox:GetText());
	self:GetEditBox():SetText(""); -- Force the user to name the layout, do not use imported name
	self:GetEditBox():SetEnabled(self:GetLayoutInfo() ~= nil);

	self:UpdateAcceptButtonEnabledState();
end

function EditModeImportLayoutDialogMixin:ProcessImportText(text)
	-- Override as needed
	self:SetLayoutInfo(C_EditMode.ConvertStringToLayoutInfo(text));
end

--[[
EditModeImportLayoutLinkDialogMixin = {};

function EditModeImportLayoutLinkDialogMixin:OnLoad()
	self.exclusive = true;
	self.AcceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self))
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self))
	self.CharacterSpecificLayoutCheckButton:SetCallback(GenerateClosure(self.UpdateAcceptButtonEnabledState, self))
end

function EditModeImportLayoutLinkDialogMixin:OnHide()
	self.importLayoutInfo = nil;
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
--]]

EditModeUnsavedChangesDialogMixin = {};

function EditModeUnsavedChangesDialogMixin:OnLoad()
	self.exclusive = true;
	self.SaveAndProceedButton:SetOnClickHandler(GenerateClosure(self.OnSaveAndProceed, self))
	self.ProceedButton:SetOnClickHandler(GenerateClosure(self.OnProceed, self))
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self))
	EventRegistry:RegisterCallback("EditMode.NewLayoutCancel", self.ResetAndClearCallback, self);
end

function EditModeUnsavedChangesDialogMixin:OnShow()
	EventRegistry:RegisterCallback("EditMode.SavedLayouts", self.OnProceed, self);
end

function EditModeUnsavedChangesDialogMixin:OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function EditModeUnsavedChangesDialogMixin:OnEditModeExit()
	if self:IsShown() then
		self:OnCancel();
	else
		self:ResetAndClearCallback();
	end
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

function EditModeUnsavedChangesDialogMixin:HasPendingSelectedLayout()
	return (self.selectedLayoutIndex ~= nil);
end

function EditModeUnsavedChangesDialogMixin:OnSaveAndProceed()
	EditModeManagerFrame:SaveLayoutChanges();
end

function EditModeUnsavedChangesDialogMixin:OnProceed()
	if self.selectedLayoutIndex then
		EditModeManagerFrame:SelectLayout(self.selectedLayoutIndex);
		self:OnCancel();
	else
		HideUIPanel(EditModeManagerFrame);
	end
end

function EditModeUnsavedChangesDialogMixin:OnCancel()
	self:ResetAndClearCallback();
	StaticPopupSpecial_Hide(self);
end

function EditModeUnsavedChangesDialogMixin:ResetAndClearCallback()
	EditModeManagerFrame:ResetDropdownToActiveLayout();
	self.selectedLayoutIndex = nil;
	self:ClearSavedLayoutsCallback();
end

function EditModeUnsavedChangesDialogMixin:ClearSavedLayoutsCallback()
	EventRegistry:UnregisterCallback("EditMode.SavedLayouts", self);
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
		Pool_HideAndClearAnchors(pool, button);
		button:Enable();
	end
	self.pools:CreatePool("BUTTON", self.Buttons, "EditModeSystemSettingsDialogExtraButtonTemplate", resetExtraButton);
end

function EditModeSystemSettingsDialogMixin:OnHide()
	if self.attachedToSystem then
		self.attachedToSystem:ClearDownKeys();
	end
	self.attachedToSystem = nil;
end

function EditModeSystemSettingsDialogMixin:OnKeyDown(key)
	if self.attachedToSystem then
		if key == "PRINTSCREEN" then
			Screenshot();
		elseif key == "ESCAPE" then
			self.CloseButton:Click();
		else
			self.attachedToSystem:OnKeyDown(key);
		end
	end
end

function EditModeSystemSettingsDialogMixin:OnKeyUp(key)
	if self.attachedToSystem then
		self.attachedToSystem:OnKeyUp(key);
	end
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
	self.Title:SetText(systemFrame:GetSystemName());
	self:UpdateDialog(systemFrame);
	self:Show();
end

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
					settingsToSetup[settingFrame] = { displayInfo = updatedDisplayInfo, currentValue = self.attachedToSystem:GetSettingValue(updatedDisplayInfo.setting), settingName = settingName };
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

function EditModeSystemSettingsDialogMixin:OnSettingInteractStart(setting)
	if self.attachedToSystem then
		local settings = self.attachedToSystem.settingDisplayInfoMap[setting];
		if settings and settings.hideSystemSelectionOnInteract then
			self.attachedToSystem:SetSelectionShown(false);
		end
	end
end

function EditModeSystemSettingsDialogMixin:OnSettingInteractEnd(setting)
	if self.attachedToSystem then
		local settings = self.attachedToSystem.settingDisplayInfoMap[setting];
		if settings and settings.hideSystemSelectionOnInteract then
			self.attachedToSystem:SetSelectionShown(true);
		end
	end
end

function EditModeSystemSettingsDialogMixin:RevertChanges()
	if self.attachedToSystem then
		EditModeManagerFrame:RevertSystemChanges(self.attachedToSystem);
	end
end
