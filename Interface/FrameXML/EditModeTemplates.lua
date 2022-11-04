EditModeUnsavedChangesCheckerMixin = {};

function EditModeUnsavedChangesCheckerMixin:OnEnter()
	if EditModeManagerFrame:TryShowUnsavedChangesGlow() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddNormalLine(GameTooltip, HUD_EDIT_MODE_UNSAVED_CHANGES);
		GameTooltip:Show();
	end
end

function EditModeUnsavedChangesCheckerMixin:OnLeave()
	EditModeManagerFrame:ClearUnsavedChangesGlow();
	GameTooltip_Hide();
end

EditModeDropdownEntryMixin = {};

local maxLayoutsErrorText = HUD_EDIT_MODE_ERROR_MAX_LAYOUTS:format(Constants.EditModeConsts.EditModeMaxLayoutsPerType, Constants.EditModeConsts.EditModeMaxLayoutsPerType);

function EditModeDropdownEntryMixin:Init(text, onClick, disableOnMaxLayouts, disableOnActiveChanges, width, maxTextWidth, showArrow, isSubmenuButton, disabledText)
	if width then
		self:SetWidth(width);
		maxTextWidth = maxTextWidth or width;
	end

	if disableOnMaxLayouts and EditModeManagerFrame:AreLayoutsFullyMaxed() then
		self.disabledTooltip = maxLayoutsErrorText;
	elseif disableOnActiveChanges and EditModeManagerFrame:HasActiveChanges()then
		self.disabledTooltip = HUD_EDIT_MODE_UNSAVED_CHANGES;
	else
		self.disabledTooltip = nil;
	end

	self.isEnabled = (self.disabledTooltip == nil);

	if disabledText and not self.isEnabled then
		text = disabledText;
	end

	self.Text:SetWidth(0);
	self.Text:SetText(text);
	self.Text:SetFontObject(self.isEnabled and GameFontHighlightSmallLeft or GameFontDisableSmallLeft);

	if maxTextWidth and self.Text:GetStringWidth() > maxTextWidth then
		self.Text:SetWidth(maxTextWidth);
	end

	if not width then
		self:SetWidth(self.Text:GetWidth() + 5);
	end

	self.Arrow:SetShown(showArrow or false);
	self.isSubmenuButton = isSubmenuButton;

	self.onClick = onClick;
end

function EditModeDropdownEntryMixin:OnEnter()
	if not self.isSubmenuButton then
		EditModeManagerFrame:ClearLockedLayoutButton(self);
	end

	self.Highlight:Show();

	if not self.isEnabled then
		GameTooltip_ShowDisabledTooltip(GameTooltip, self, self.disabledTooltip);
	end
end

function EditModeDropdownEntryMixin:OnLeave()
	self.Highlight:Hide();
	if not self.isEnabled then
		GameTooltip_Hide();
	end
end

function EditModeDropdownEntryMixin:OnMouseDown()
	self.Text:SetPoint("LEFT", self, "LEFT", 2, -1);
end

function EditModeDropdownEntryMixin:OnMouseUp()
	self.Text:SetPoint("LEFT", self, "LEFT", 0, 0);
	if self.isEnabled then
		self:onClick();
	end
end

EditModeDropdownLayoutEntryMixin = CreateFromMixins(EditModeDropdownEntryMixin);

function EditModeDropdownLayoutEntryMixin:OnLoad()
	self.CopyLayoutButton:SetOnClickHandler(GenerateClosure(EditModeManagerFrame.ShowNewLayoutDialog, EditModeManagerFrame, self.layoutData));
	self.RenameOrCopyLayoutButton:SetOnClickHandler(GenerateClosure(EditModeManagerFrame.ToggleRenameOrCopyLayoutDropdown, EditModeManagerFrame, self));
	self.DeleteLayoutButton:SetOnClickHandler(GenerateClosure(EditModeManagerFrame.ShowDeleteLayoutDialog, EditModeManagerFrame, self));
end

local layoutEntryWidth = 210;
local layoutEntryMaxTextWidth = 150;
local maxLayoutsCopyErrorText = HUD_EDIT_MODE_ERROR_COPY_MAX_LAYOUTS:format(Constants.EditModeConsts.EditModeMaxLayoutsPerType, Constants.EditModeConsts.EditModeMaxLayoutsPerType);

function EditModeDropdownLayoutEntryMixin:Init(layoutIndex, layoutData, isSelected, onClick)
	local text = (layoutData.layoutType == Enum.EditModeLayoutType.Preset) and HUD_EDIT_MODE_PRESET_LAYOUT:format(layoutData.layoutName) or layoutData.layoutName;
	local disableOnMaxLayoutsNo = false;
	local disableOnActiveChangesNo = false;
	EditModeDropdownEntryMixin.Init(self, text, onClick, disableOnMaxLayoutsNo, disableOnActiveChangesNo, layoutEntryWidth, layoutEntryMaxTextWidth);

	local layoutsMaxed = EditModeManagerFrame:AreLayoutsFullyMaxed();
	self.CopyLayoutButton.disabledTooltip = layoutsMaxed and maxLayoutsCopyErrorText or HUD_EDIT_MODE_ERROR_COPY;

	local hasActiveChanges = EditModeManagerFrame:HasActiveChanges();
	self.CopyLayoutButton:SetEnabled(not layoutsMaxed and not hasActiveChanges);
	self.RenameOrCopyLayoutButton:SetEnabled(not hasActiveChanges);

	self.layoutIndex = layoutIndex;
	self.layoutData = layoutData;
	self.SelectedCheck:SetShown(isSelected);
	self.onClick = onClick;
	self.isPresetLayout = (layoutData.layoutType == Enum.EditModeLayoutType.Preset);
end

function EditModeDropdownLayoutEntryMixin:OnUpdate()
	local mouseOver = EditModeManagerFrame:IsLayoutButtonLocked(self) or RegionUtil.IsDescendantOfOrSame(GetMouseFocus(), self);
	self.Highlight:SetShown(mouseOver);
	self.CopyLayoutButton:SetShown(mouseOver and self.isPresetLayout);
	self.RenameOrCopyLayoutButton:SetShown(mouseOver and not self.isPresetLayout);
	self.DeleteLayoutButton:SetShown(mouseOver and not self.isPresetLayout);

	if not mouseOver then
		self:SetScript("OnUpdate", nil);
	end
end

function EditModeDropdownLayoutEntryMixin:OnEnter()
	EditModeManagerFrame:ClearLockedLayoutButton(self);
	self:SetScript("OnUpdate", self.OnUpdate);
end

function EditModeDropdownLayoutEntryMixin:OnLeave()
	-- Intentionally empty, OnUpdate handles this
end

EditModeSettingDropdownMixin = {};

function EditModeSettingDropdownMixin:OnLoad()
	self.Dropdown:SetTextJustifyH("LEFT");
	self.Dropdown:SetOptionSelectedCallback(GenerateClosure(self.OnSettingSelected, self));
end

function EditModeSettingDropdownMixin:SetupSetting(settingData)
	self.setting = settingData.displayInfo.setting;
	self.Label:SetText(settingData.settingName);
	self.Dropdown:SetOptions(settingData.displayInfo.options, settingData.currentValue);
end

function EditModeSettingDropdownMixin:OnSettingSelected(value, isUserInput)
	if isUserInput then
		EditModeSystemSettingsDialog:OnSettingValueChanged(self.setting, value);
	end
end

EditModeSettingSliderMixin = CreateFromMixins(CallbackRegistryMixin);

function EditModeSettingSliderMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.cbrHandles = EventUtil.CreateCallbackHandleContainer();
	self.cbrHandles:RegisterCallback(self.Slider, MinimalSliderWithSteppersMixin.Event.OnValueChanged, self.OnSliderValueChanged, self);
end

function EditModeSettingSliderMixin:SetupSetting(settingData)
	self.initInProgress = true;
	self.formatters = {};
	if settingData.displayInfo.hideValue then
		self.formatters[MinimalSliderWithSteppersMixin.Label.Right] = nil;
		self.Slider:SetWidth(230);
	else
		self.formatters[MinimalSliderWithSteppersMixin.Label.Right] = CreateMinimalSliderFormatter(MinimalSliderWithSteppersMixin.Label.Right, settingData.displayInfo.formatter);
		self.Slider:SetWidth(200);
	end

	if settingData.displayInfo.minText or settingData.displayInfo.maxText then
		self:SetHeight(38);
		self.Label:SetPoint("LEFT", self, "LEFT", 0, 3);
	else
		self:SetHeight(32);
		self.Label:SetPoint("LEFT", self, "LEFT", 0, 0);
	end

	if settingData.displayInfo.minText then
		self.Slider.MinText:SetText(settingData.displayInfo.minText);
		self.Slider.MinText:Show();
	else
		self.Slider.MinText:Hide();
	end

	if settingData.displayInfo.maxText then
		self.Slider.MaxText:SetText(settingData.displayInfo.maxText);
		self.Slider.MaxText:Show();
	else
		self.Slider.MaxText:Hide();
	end

	self.setting = settingData.displayInfo.setting;
	self.Label:SetText(settingData.settingName);
	local stepSize = settingData.displayInfo.stepSize or 1;
	local steps = (settingData.displayInfo.maxValue - settingData.displayInfo.minValue) / stepSize;
	self.Slider:Init(settingData.currentValue, settingData.displayInfo.minValue, settingData.displayInfo.maxValue, steps, self.formatters);
	self.initInProgress = false;
end

function EditModeSettingSliderMixin:OnSliderValueChanged(value)
	if not self.initInProgress then
		EditModeSystemSettingsDialog:OnSettingValueChanged(self.setting, value);
	end
end

EditModeSettingCheckboxMixin = {};

function EditModeSettingCheckboxMixin:SetupSetting(settingData)
	self.setting = settingData.displayInfo.setting;
	self.checked = (settingData.currentValue == 1);
	self.Label:SetText(settingData.settingName);
	self.Button:SetChecked(self.checked);
end

function EditModeSettingCheckboxMixin:OnCheckButtonClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self.checked = not self.checked;
	EditModeSystemSettingsDialog:OnSettingValueChanged(self.setting, self.checked and 1 or 0);
end

EditModeGridLineMixin = {};

local linePixelWidth = 1.2;

function EditModeGridLineMixin:SetupLine(centerLine, verticalLine, xOffset, yOffset)
	local color = centerLine and EDIT_MODE_GRID_CENTER_LINE_COLOR or EDIT_MODE_GRID_LINE_COLOR;
	self:SetColorTexture(color:GetRGBA());

	self:SetStartPoint(verticalLine and "TOP" or "LEFT", EditModeManagerFrame.Grid, xOffset, yOffset);
	self:SetEndPoint(verticalLine and "BOTTOM" or "RIGHT", EditModeManagerFrame.Grid, xOffset, yOffset);

	local lineThickness = PixelUtil.GetNearestPixelSize(linePixelWidth, self:GetEffectiveScale(), linePixelWidth);
	self:SetThickness(lineThickness);

	EditModeMagnetismManager:RegisterGridLine(self, verticalLine, verticalLine and xOffset or yOffset);
end

EditModeCheckButtonMixin = {};

function EditModeCheckButtonMixin:EditModeCheckButton_OnShow()
	local shouldEnable = self:ShouldEnable();
	self.Button:SetEnabled(shouldEnable);
	self.Label:SetFontObject(shouldEnable and "GameFontHighlightMedium" or "GameFontDisableMed2")
end

-- Override this to change whether we are enabled on show
function EditModeCheckButtonMixin:ShouldEnable()
	return true;
end
