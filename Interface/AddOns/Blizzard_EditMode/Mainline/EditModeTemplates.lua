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

EditModeSettingDropdownMixin = {};

function EditModeSettingDropdownMixin:OnLoad()
	self.Dropdown:SetWidth(225);
end

function EditModeSettingDropdownMixin:SetupSetting(settingData)
	self.setting = settingData.displayInfo.setting;
	self.Label:SetText(settingData.settingName);
	
	local function IsSelected(value)
		return settingData.currentValue == value;
	end

	local function SetSelected(value)
		EditModeSystemSettingsDialog:OnSettingValueChanged(self.setting, value);
	end

	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		for index, option in ipairs(settingData.displayInfo.options) do
			rootDescription:CreateRadio(option.text, IsSelected, SetSelected, option.value);
		end
	end);
end

EditModeSettingSliderMixin = CreateFromMixins(CallbackRegistryMixin);

function EditModeSettingSliderMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.cbrHandles = EventUtil.CreateCallbackHandleContainer();
	self.cbrHandles:RegisterCallback(self.Slider, MinimalSliderWithSteppersMixin.Event.OnValueChanged, self.OnSliderValueChanged, self);
	self.cbrHandles:RegisterCallback(self.Slider, MinimalSliderWithSteppersMixin.Event.OnInteractStart, self.OnSliderInteractStart, self);
	self.cbrHandles:RegisterCallback(self.Slider, MinimalSliderWithSteppersMixin.Event.OnInteractEnd, self.OnSliderInteractEnd, self);	
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

function EditModeSettingSliderMixin:OnSliderInteractStart()
	EditModeSystemSettingsDialog:OnSettingInteractStart(self.setting);
end

function EditModeSettingSliderMixin:OnSliderInteractEnd()
	EditModeSystemSettingsDialog:OnSettingInteractEnd(self.setting);
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

local editModeGridLinePixelWidth = 1.2;

local function SetupLineThickness(line, linePixelWidth)
	local lineThickness = PixelUtil.GetNearestPixelSize(linePixelWidth, line:GetEffectiveScale(), linePixelWidth);
	line:SetThickness(lineThickness);
end

function EditModeGridLineMixin:SetupLine(centerLine, verticalLine, xOffset, yOffset)
	local color = centerLine and EDIT_MODE_GRID_CENTER_LINE_COLOR or EDIT_MODE_GRID_LINE_COLOR;
	self:SetColorTexture(color:GetRGBA());

	self:SetStartPoint(verticalLine and "TOP" or "LEFT", EditModeManagerFrame.Grid, xOffset, yOffset);
	self:SetEndPoint(verticalLine and "BOTTOM" or "RIGHT", EditModeManagerFrame.Grid, xOffset, yOffset);

	SetupLineThickness(self, editModeGridLinePixelWidth);

	EditModeMagnetismManager:RegisterGridLine(self, verticalLine, verticalLine and xOffset or yOffset);
end

MagnetismPreviewLineMixin = {};

local magnetismPreviewLinePixelWidth = 1.5;

function MagnetismPreviewLineMixin:Setup(magneticFrameInfo, lineAnchor)
	local uiParentWidth, uiParentHeight, uiParentCenterX, uiParentCenterY = EditModeMagnetismManager.uiParentWidth, EditModeMagnetismManager.uiParentHeight, EditModeMagnetismManager.uiParentCenterX, EditModeMagnetismManager.uiParentCenterY;
	local relativeTo = magneticFrameInfo.frame;
	local isLineAnchoringHorizontally = lineAnchor == "Top" or lineAnchor == "Bottom" or lineAnchor == "CenterHorizontal";

	local startPoint, endPoint;
	if isLineAnchoringHorizontally then
		startPoint, endPoint = "LEFT", "RIGHT";
	else
		startPoint, endPoint = "TOP", "BOTTOM";
	end

	local offsetX, offsetY = 0, 0;
	if relativeTo == UIParent then
		-- RelativeTo is UIParent
		-- We have to adjust offsets to put line on top of the grid line we're anchoring to
		if lineAnchor == "CenterHorizontal" then
			offsetY = magneticFrameInfo.offset;
		elseif lineAnchor == "CenterVertical" then
			offsetX = magneticFrameInfo.offset;
		elseif lineAnchor == "Top" or lineAnchor == "Bottom" then
			if lineAnchor == "Top" then
				offsetY = uiParentHeight + magneticFrameInfo.offset;
			else -- Bottom
				offsetY = magneticFrameInfo.offset;
			end
			offsetY = offsetY - uiParentCenterY;
		elseif lineAnchor == "Right" or lineAnchor == "Left" then
			if lineAnchor == "Right" then
				offsetX = uiParentWidth + magneticFrameInfo.offset;
			else -- Left
				offsetX = magneticFrameInfo.offset;
			end
			offsetX = offsetX - uiParentCenterX;
		end
	else
		-- RelativeTo is an edit mode frame
		local relativeToLeft, relativeToRight, relativeToBottom, relativeToTop;
		local relativeToCenterX, relativeToCenterY;

		relativeToLeft, relativeToRight, relativeToBottom, relativeToTop = relativeTo:GetScaledSelectionSides();
		relativeToCenterX, relativeToCenterY = relativeTo:GetScaledSelectionCenter();

		if isLineAnchoringHorizontally then
			if lineAnchor == "Top" then
				offsetY = relativeToTop - uiParentCenterY;
			elseif lineAnchor == "Bottom" then
				offsetY = relativeToBottom - uiParentCenterY;
			else -- CenterHorizontal
				offsetY = relativeToCenterY - uiParentCenterY;
			end
		else -- isVerticalAnchor
			if lineAnchor == "Left" then
				offsetX = relativeToLeft - uiParentCenterX;
			elseif lineAnchor == "Right" then
				offsetX = relativeToRight - uiParentCenterX;
			else -- CenterVertical
				offsetX = relativeToCenterX - uiParentCenterX;
			end
		end
	end

	self:SetStartPoint(startPoint, UIParent, offsetX, offsetY);
	self:SetEndPoint(endPoint, UIParent, offsetX, offsetY);
	SetupLineThickness(self, magnetismPreviewLinePixelWidth);
	self:Show();
end

EditModeCheckButtonMixin = {};

function EditModeCheckButtonMixin:EditModeCheckButton_OnShow()
	local shouldEnable = self:ShouldEnable();
	self.Button:SetEnabled(shouldEnable);
	self.Label:SetFontObject(shouldEnable and "GameFontHighlightMedium" or "GameFontDisableMed2")
end

function EditModeCheckButtonMixin:OnEnter()
	local isLabelTruncated = self.Label:IsTruncated();
	local showDisabledTooltip = not self:ShouldEnable() and self.disabledTooltipText;
	local showTooltip = isLabelTruncated or showDisabledTooltip;

	if showTooltip then
		GameTooltip:SetOwner(self.Button, "ANCHOR_RIGHT");

		if isLabelTruncated then
			GameTooltip_AddHighlightLine(GameTooltip, self.Label:GetText());
		end

		if showDisabledTooltip then
			GameTooltip_AddNormalLine(GameTooltip, self.disabledTooltipText);
		end

		GameTooltip:Show();
	end
end

function EditModeCheckButtonMixin:OnLeave()
	if GameTooltip:GetOwner() == self.Button then
		GameTooltip:Hide();
	end
end

-- Override this to change whether we are enabled on show
function EditModeCheckButtonMixin:ShouldEnable()
	return true;
end

EditModeCheckButtonButtonMixin = {};

function EditModeCheckButtonButtonMixin:OnClick()
	self:GetParent():OnCheckButtonClick();
end

function EditModeCheckButtonButtonMixin:OnEnter()
	EditModeCheckButtonMixin.OnEnter(self:GetParent());
end

function EditModeCheckButtonButtonMixin:OnLeave()
	EditModeCheckButtonMixin.OnLeave(self:GetParent());
end

EditModeManagerSettingCheckButtonMixin = {};

function EditModeManagerSettingCheckButtonMixin:EditModeManagerSettingCheckButton_OnLoad()
	local width = self:GetWidth() - self.Button:GetWidth() - select(4, self.Label:GetPoint(1));
	self.Label:SetWidth(width);
end