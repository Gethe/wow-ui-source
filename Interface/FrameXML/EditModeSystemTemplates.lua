EditModeSystemMixin = {};

function EditModeSystemMixin:OnSystemLoad()
	if not self.system then
		-- All systems must have self.system set on them
		return;
	end

	EditModeManagerFrame:RegisterSystemFrame(self);

	self.systemName = (self.addSystemIndexToName and self.systemIndex) and self.systemNameString:format(self.systemIndex) or self.systemNameString;
	self.Selection:SetLabelText(self.systemName);
	self:SetupSettingsDialogAnchor();

	self.settingDisplayInfoMap = EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfoMap(self.system);
end

function EditModeSystemMixin:OnSystemHide()
	if self.isSelected then
		EditModeManagerFrame:ClearSelectedSystem();
	end
end

-- Override in inheriting mixins as needed
function EditModeSystemMixin:AnchorSelectionFrame()
end

-- Override in inheriting mixins as needed
function EditModeSystemMixin:ShouldResetSettingsDialogAnchors(oldSelectedSystemFrame)
	return not oldSelectedSystemFrame or oldSelectedSystemFrame.system ~= self.system;
end

function EditModeSystemMixin:ConvertSettingDisplayValueToRawValue(setting, value)
	if self.settingDisplayInfoMap[setting] then
		return self.settingDisplayInfoMap[setting]:ConvertValue(value);
	else
		return value;
	end
end

function EditModeSystemMixin:UpdateSettingMap(updateDirtySettings)
	local oldSettingsMap = self.settingMap;
	self.settingMap = EditModeUtil:GetSettingMapFromSettings(self.systemInfo.settings, self.settingDisplayInfoMap);

	if updateDirtySettings then
		self:UpdateDirtySettings(oldSettingsMap)
	end
end

function EditModeSystemMixin:UpdateDirtySettings(oldSettingsMap)
	-- Mark changed settings as dirty
	self.dirtySettings = {};
	for setting, settingInfo in pairs(self.settingMap) do
		if not oldSettingsMap or oldSettingsMap[setting].value ~= settingInfo.value then
			self.dirtySettings[setting] = true;
		end
	end
end

function EditModeSystemMixin:IsSettingDirty(setting)
	return self.dirtySettings[setting];
end

function EditModeSystemMixin:ClearDirtySetting(setting)
	self.dirtySettings[setting] = nil;
end

function EditModeSystemMixin:UpdateSystemSettingValue(setting, newValue)
	if not self:IsInitialized() then
		return;
	end

	for _, settingInfo in pairs(self.systemInfo.settings) do
		if settingInfo.setting == setting then
			local rawNewValue = self:ConvertSettingDisplayValueToRawValue(setting, newValue);
			if settingInfo.value ~= rawNewValue then
				settingInfo.value = rawNewValue;
				self:UpdateSystemSetting(setting);
			end
			return;
		end
	end
end

function EditModeSystemMixin:ResetToDefaultPosition()
	self.systemInfo.anchorInfo.isDefaultPosition = true;
	self:ApplySystemAnchor();
	EditModeSystemSettingsDialog:UpdateDialog(self);
	self:SetHasActiveChanges(true);
end

function EditModeSystemMixin:ApplySystemAnchor()
	if self.isBottomManagedFrame then
		if self:IsInDefaultPosition() then
			self.ignoreFramePositionManager = nil;
			UIParentBottomManagedFrameContainer:AddManagedFrame(self);
			return;
		else
			self.ignoreFramePositionManager = true;
			UIParentBottomManagedFrameContainer:RemoveManagedFrame(self);
			self:SetParent(UIParent);
		end
	elseif EditModeUtil:IsRightAnchoredActionBar(self) then
		if self:IsInDefaultPosition() then
			EditModeManagerFrame:AddRightActionBarToLayout(self);
			return;
		end
	end

	self:ClearAllPoints();
	self:SetPoint(self.systemInfo.anchorInfo.point, self.systemInfo.anchorInfo.relativeTo, self.systemInfo.anchorInfo.relativePoint, self.systemInfo.anchorInfo.offsetX, self.systemInfo.anchorInfo.offsetY);
end

function EditModeSystemMixin:UpdateSystem(systemInfo)
	self.savedSystemInfo = CopyTable(systemInfo);
	self:SetHasActiveChanges(false);

	self.systemInfo = systemInfo;

	local updateDirtySettings = true;
	self:UpdateSettingMap(updateDirtySettings);

	self:ApplySystemAnchor();

	self:AnchorSelectionFrame();
	EditModeSystemSettingsDialog:UpdateDialog(self);

	local entireSystemUpdate = true;
	for _, settingInfo in ipairs(systemInfo.settings) do
		self:UpdateSystemSetting(settingInfo.setting, entireSystemUpdate);
	end
end

function EditModeSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	if not entireSystemUpdate then
		self.dirtySettings[setting] = true;
		self:SetHasActiveChanges(true);
		self:UpdateSettingMap();
		self:AnchorSelectionFrame();
		EditModeSystemSettingsDialog:UpdateDialog(self);
	end

	if self:IsSettingDirty(setting) then
		EditModeManagerFrame:MirrorSetting(self.system, self.systemIndex, setting, self:GetSettingValue(setting));
	end
end

function EditModeSystemMixin:IsInitialized()
	return self.systemInfo ~= nil;
end

-- Override in inheriting mixins as needed
function EditModeSystemMixin:SetupSettingsDialogAnchor()
	self.settingsDialogAnchor = AnchorUtil.CreateAnchor("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -250, 200);
end

function EditModeSystemMixin:SetHasActiveChanges(hasActiveChanges)
	self.hasActiveChanges = hasActiveChanges;
	if hasActiveChanges then
		EditModeManagerFrame:SetHasActiveChanges(true);
	end
	EditModeSystemSettingsDialog:UpdateButtons(self);
end

function EditModeSystemMixin:HasActiveChanges()
	return self.hasActiveChanges;
end

function EditModeSystemMixin:HasSetting(setting)
	return self.settingMap[setting] ~= nil;
end

function EditModeSystemMixin:GetSettingValue(setting, useRawValue)
	return useRawValue and self.settingMap[setting].value or self.settingMap[setting].displayValue;
end

function EditModeSystemMixin:GetSettingValueBool(setting, useRawValue)
	return self:GetSettingValue(setting, useRawValue) == 1;
end

function EditModeSystemMixin:DoesSettingValueEqual(setting, value)
	local useRawValue = true;
	return self:GetSettingValue(setting, useRawValue) == value;
end

function EditModeSystemMixin:DoesSettingDisplayValueEqual(setting, value)
	local useRawValueNo = false;
	return self:GetSettingValue(setting, useRawValueNo) == value;
end

-- Override in inheriting mixins as needed
function EditModeSystemMixin:UseSettingAltName(setting)
	return false;
end

-- Override in inheriting mixins as needed
function EditModeSystemMixin:ShouldShowSetting(setting)
	return self:HasSetting(setting);
end

function EditModeSystemMixin:GetSettingsDialogAnchor()
	return self.settingsDialogAnchor;
end

-- Override in inheriting mixins as needed
function EditModeSystemMixin:AddExtraButtons(extraButtonPool)
	return false;
end

function EditModeSystemMixin:ClearHighlight()
	self.Selection:Hide();
	self.isSelected = false;
	self.isHighlighted = false;
end

function EditModeSystemMixin:HighlightSystem()
	self:SetMovable(false);
	self.Selection:ShowHighlighted();
	self.isHighlighted = true;
	self.isSelected = false;
end

function EditModeSystemMixin:SelectSystem()
	if not self.isSelected then
		self:SetMovable(true);
		self.Selection:ShowSelected();
		EditModeSystemSettingsDialog:AttachToSystemFrame(self);
		self.isSelected = true;
	end
end

function EditModeSystemMixin:OnEditModeEnter()
	if not self.defaultHideSelection then
		self:HighlightSystem();
	end
end

function EditModeSystemMixin:OnEditModeExit()
	self:ClearHighlight();
	EditModeSystemSettingsDialog:Hide();
end

function EditModeSystemMixin:CanBeMoved()
	return self.isSelected and not self.isLocked;
end

function EditModeSystemMixin:IsInDefaultPosition()
	return self:IsInitialized() and self.systemInfo.anchorInfo.isDefaultPosition;
end

function EditModeSystemMixin:OnDragStart()
	if self:CanBeMoved() then
		self:StartMoving();
	end
end

function EditModeSystemMixin:OnDragStop()
	if self:CanBeMoved() then
		self:StopMovingOrSizing();
		EditModeManagerFrame:OnSystemPositionChange(self);
	end
end

EditModeActionBarSystemMixin = {};

function EditModeActionBarSystemMixin:UpdateSystem(systemInfo)
	EditModeSystemMixin.UpdateSystem(self, systemInfo);
	self:RefreshGridLayout();
	self:RefreshButtonArt();

	if EditModeUtil:IsBottomAnchoredActionBar(self) then
		EditModeManagerFrame:UpdateBottomAnchoredActionBarHeight();
	elseif EditModeUtil:IsRightAnchoredActionBar(self) then
		EditModeManagerFrame:UpdateRightActionBarsLayout();
	end
end

function EditModeActionBarSystemMixin:OnDragStart()
	EditModeSystemMixin.OnDragStart(self);

	if self:HasSetting(Enum.EditModeActionBarSetting.SnapToSide) then
		EditModeSystemSettingsDialog:OnSettingValueChanged(Enum.EditModeActionBarSetting.SnapToSide, 0);
	end
end

function EditModeActionBarSystemMixin:OnEditModeEnter()
	EditModeSystemMixin.OnEditModeEnter(self);

	-- Some action bars have special visibility rules so use their method for whether to turn them on/off on enter
	self:UpdateVisibility();
end

function EditModeActionBarSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	-- Some action bars have special visibility rules so use their method for whether to turn them on/off on exit
	self:UpdateVisibility();
end

function EditModeActionBarSystemMixin:IsInDefaultPosition()
	if not self:IsInitialized() then
		return false;
	end

	local _, relativeTo = self:GetPoint(1);
	if relativeTo and relativeTo.IsInDefaultPosition and not relativeTo:IsInDefaultPosition() then
		return false;
	end

	return EditModeSystemMixin.IsInDefaultPosition(self);
end

function EditModeActionBarSystemMixin:SetScaleIfRightAnchored(scale)
	if self:IsInDefaultPosition() then
		self:SetScale(scale);
	else
		self:SetScale(1);
	end
end

function EditModeActionBarSystemMixin:GetRightAnchoredWidth()
	if not self:IsInitialized() then
		return 0;
	end

	if self:IsShown() and self:IsInDefaultPosition() then
		return self:GetWidth() + -self.systemInfo.anchorInfo.offsetX;
	end

	return 0;
end

function EditModeActionBarSystemMixin:GetBottomAnchoredHeight()
	if not self:IsInitialized() then
		return 0;
	end

	if self:IsShown() and self:IsInDefaultPosition() then
		return self:GetHeight() + self.systemInfo.anchorInfo.offsetY;
	end

	return 0;
end

function EditModeActionBarSystemMixin:MarkGridLayoutDirty()
	self.gridLayoutDirty = true;
end

function EditModeActionBarSystemMixin:RefreshGridLayout()
	if self.gridLayoutDirty then
		self:UpdateGridLayout()
		self.gridLayoutDirty = false;
	end
end

function EditModeActionBarSystemMixin:UpdateGridLayout()
	ActionBarMixin.UpdateGridLayout(self);

	if not self:IsInitialized() then
		return;
	end

	-- If you can be in a right action bar layout then update the layout
	if self:HasSetting(Enum.EditModeActionBarSetting.SnapToSide) then
		EditModeManagerFrame:UpdateRightActionBarsLayout();
	end

	if EditModeUtil:IsBottomAnchoredActionBar(self) then
		EditModeManagerFrame:UpdateBottomAnchoredActionBarHeight();
	elseif EditModeUtil:IsRightAnchoredActionBar(self) then
		EditModeManagerFrame:UpdateRightActionBarsLayout();
	end

	-- Update frame positions since if we update the size of the action bars then we'll wanna update the position of things relative to those action bars
	UIParent_ManageFramePositions();
end

function EditModeActionBarSystemMixin:MarkButtonArtDirty()
	self.buttonArtDirty = true;
end

function EditModeActionBarSystemMixin:RefreshButtonArt()
	if self.buttonArtDirty then
		self:UpdateButtonArt()
		self.buttonArtDirty = false;
	end
end

function EditModeActionBarSystemMixin:UpdateButtonArt()
	for i, actionButton in pairs(self.actionButtons) do
		actionButton:UpdateButtonArt(i >= self.numShowingButtons);
	end
end

function EditModeActionBarSystemMixin:UpdateSystemSettingOrientation()
	self.isHorizontal = self:DoesSettingValueEqual(Enum.EditModeActionBarSetting.Orientation, Enum.ActionBarOrientation.Horizontal);
	self.Selection:SetVerticalState(not self.isHorizontal);

	self.addButtonsToRight = true;
	if self.isHorizontal then
		self.addButtonsToTop = true;
	else
		self.addButtonsToTop = false;
	end

	if (self.isHorizontal
		and self:HasSetting(Enum.EditModeActionBarSetting.SnapToSide)
		and self:GetSettingValueBool(Enum.EditModeActionBarSetting.SnapToSide)) then
		EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeActionBarSetting.SnapToSide, 0);
	end

	-- Since the orientation changed we'll want to update the grid layout
	self:MarkGridLayoutDirty();

	-- Update the art since we'll possibly be switching from horizontal to vertical dividers
	self:MarkButtonArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingNumRows()
	self.numRows = self:GetSettingValue(Enum.EditModeActionBarSetting.NumRows);

	-- If num rows > 1 and we can snap to the side then make sure snap to side is disabled
	if self.numRows > 1
		and self:HasSetting(Enum.EditModeActionBarSetting.SnapToSide)
		and self:GetSettingValueBool(Enum.EditModeActionBarSetting.SnapToSide) then
		EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeActionBarSetting.SnapToSide, 0);
	end

	-- Since the num rows changed we'll want to update the grid layout
	self:MarkGridLayoutDirty();

	-- Update the art since we hide dividers when num rows > 1
	self:MarkButtonArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingNumIcons()
	self.numShowingButtons = self:GetSettingValue(Enum.EditModeActionBarSetting.NumIcons);
	self:UpdateShownButtons();

	-- Since the num icons changed we'll want to update the grid layout
	self:MarkGridLayoutDirty();

	-- Update the art since we'll need to change what dividers are shown specifically for the new last button
	self:MarkButtonArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingIconSize()
	local iconSizeSetting = self:GetSettingValue(Enum.EditModeActionBarSetting.IconSize);

	local iconScale = iconSizeSetting / 100;

	if self.EditModeSetScale then
		self:EditModeSetScale(iconScale);
	end

	for i, buttonOrSpacer in pairs(self.buttonsAndSpacers) do
		buttonOrSpacer:SetScale(iconScale);
	end

	-- Since size of buttons changed we'll want to update the grid layout so we can resize the bar's frame
	self:MarkGridLayoutDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingIconPadding()
	self.buttonPadding = self:GetSettingValue(Enum.EditModeActionBarSetting.IconPadding);

	-- Since the icon padding changed we'll want to update the grid layout
	self:MarkGridLayoutDirty();

	-- Update art since we will hide dividers if padding is changed
	self:MarkButtonArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingHideBarArt()
	local hideBarArt = self:GetSettingValueBool(Enum.EditModeActionBarSetting.HideBarArt);

	self:UpdateEndCaps(hideBarArt);
	self.BorderArt:SetShown(not hideBarArt);
	self.Background:SetShown(not hideBarArt);

	for i, actionButton in pairs(self.actionButtons) do
		actionButton.showButtonArt = not hideBarArt;
	end

	self:MarkButtonArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingHideBarScrolling()
	self.ActionBarPageNumber:SetShown(not self:GetSettingValueBool(Enum.EditModeActionBarSetting.HideBarScrolling));
end

function EditModeActionBarSystemMixin:UpdateSystemSettingVisibleSetting()
	if self:DoesSettingValueEqual(Enum.EditModeActionBarSetting.VisibleSetting, Enum.ActionBarVisibleSetting.InCombat) then
		self.visibility = "InCombat";
	elseif self:DoesSettingValueEqual(Enum.EditModeActionBarSetting.VisibleSetting, Enum.ActionBarVisibleSetting.OutOfCombat) then
		self.visibility = "OutOfCombat"
	else
		self.visibility = "Always";
	end
	self:UpdateVisibility();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingAlwaysShowButtons()
	local alwaysShowButtons = self:GetSettingValueBool(Enum.EditModeActionBarSetting.AlwaysShowButtons);
	self:SetShowGrid(alwaysShowButtons, ACTION_BUTTON_SHOW_GRID_REASON_CVAR);
end

function EditModeActionBarSystemMixin:UpdateSystemSettingSnapToSide()
	if self:GetSettingValueBool(Enum.EditModeActionBarSetting.SnapToSide) then
		self:ResetToDefaultPosition();

		-- Force vertical with 1 column when snapped to side
		EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeActionBarSetting.Orientation, Enum.ActionBarOrientation.Vertical);
		EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeActionBarSetting.NumRows, 1);
	else
		self.systemInfo.anchorInfo.isDefaultPosition = false;
		EditModeManagerFrame:RemoveRightActionBarFromLayout(self);
	end

	EditModeManagerFrame:UpdateRightAnchoredActionBarScales();
end

function EditModeActionBarSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeActionBarSetting.Orientation and self:HasSetting(Enum.EditModeActionBarSetting.Orientation) then
		self:UpdateSystemSettingOrientation();
	elseif setting == Enum.EditModeActionBarSetting.NumRows and self:HasSetting(Enum.EditModeActionBarSetting.NumRows) then
		self:UpdateSystemSettingNumRows();
	elseif setting == Enum.EditModeActionBarSetting.NumIcons and self:HasSetting(Enum.EditModeActionBarSetting.NumIcons) then
		self:UpdateSystemSettingNumIcons();
	elseif setting == Enum.EditModeActionBarSetting.IconSize and self:HasSetting(Enum.EditModeActionBarSetting.IconSize) then
		self:UpdateSystemSettingIconSize();
	elseif setting == Enum.EditModeActionBarSetting.IconPadding and self:HasSetting(Enum.EditModeActionBarSetting.IconPadding) then
		self:UpdateSystemSettingIconPadding();
	elseif setting == Enum.EditModeActionBarSetting.HideBarArt and self:HasSetting(Enum.EditModeActionBarSetting.HideBarArt) then
		self:UpdateSystemSettingHideBarArt();
	elseif setting == Enum.EditModeActionBarSetting.HideBarScrolling and self:HasSetting(Enum.EditModeActionBarSetting.HideBarScrolling) then
		self:UpdateSystemSettingHideBarScrolling();
	elseif setting == Enum.EditModeActionBarSetting.VisibleSetting and self:HasSetting(Enum.EditModeActionBarSetting.VisibleSetting) then
		self:UpdateSystemSettingVisibleSetting();
	elseif setting == Enum.EditModeActionBarSetting.AlwaysShowButtons and self:HasSetting(Enum.EditModeActionBarSetting.AlwaysShowButtons) then
		self:UpdateSystemSettingAlwaysShowButtons();
	elseif setting == Enum.EditModeActionBarSetting.SnapToSide and self:HasSetting(Enum.EditModeActionBarSetting.SnapToSide) then
		self:UpdateSystemSettingSnapToSide();
	end

	if not entireSystemUpdate then
		self:RefreshGridLayout();
		self:RefreshButtonArt();
	end

	self:ClearDirtySetting(setting);
end

function EditModeActionBarSystemMixin:UseSettingAltName(setting)
	if setting == Enum.EditModeActionBarSetting.NumRows then
		return self:DoesSettingValueEqual(Enum.EditModeActionBarSetting.Orientation, Enum.ActionBarOrientation.Vertical);
	end
	return false;
end

local function enterQuickKeybindMode()
	EditModeManagerFrame:ClearSelectedSystem();
	EditModeManagerFrame:SetEditModeLockState("hideSelections");
	HideUIPanel(EditModeManagerFrame);
	QuickKeybindFrame:Show();
end

local function openActionBarSettings()
	EditModeManagerFrame:ClearSelectedSystem();
	EditModeManagerFrame:SetEditModeLockState("showSelections");
	Settings.OpenToCategory("Interface", ACTIONBARS_LABEL);
end

function EditModeActionBarSystemMixin:AddExtraButtons(extraButtonPool)
	local quickKeybindModeButton = extraButtonPool:Acquire();
	quickKeybindModeButton.layoutIndex = 3;
	quickKeybindModeButton:SetText(QUICK_KEYBIND_MODE);
	quickKeybindModeButton:SetOnClickHandler(enterQuickKeybindMode);
	quickKeybindModeButton:Show();

	if self.systemIndex ~= Enum.EditModeActionBarSystemIndices.StanceBar
		and self.systemIndex ~= Enum.EditModeActionBarSystemIndices.PetActionBar
		and self.systemIndex ~= Enum.EditModeActionBarSystemIndices.PossessActionBar then
		local actionBarSettingsButton = extraButtonPool:Acquire();
		actionBarSettingsButton.layoutIndex = 4;
		actionBarSettingsButton:SetText(HUD_EDIT_MODE_ACTION_BAR_SETTINGS);
		actionBarSettingsButton:SetOnClickHandler(openActionBarSettings);
		actionBarSettingsButton:Show();
	end

	return true;
end

EditModeUnitFrameSystemMixin = {};

function EditModeUnitFrameSystemMixin:ShouldResetSettingsDialogAnchors(oldSelectedSystemFrame)
	return true;
end

function EditModeUnitFrameSystemMixin:AnchorSelectionFrame()
	self.Selection:ClearAllPoints();
	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Player then
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 35, -10);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 20);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Target then
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 10);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -35, 0);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Focus then
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 10);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -35, 0);
	end
end

function EditModeUnitFrameSystemMixin:SetupSettingsDialogAnchor()
	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Player then
		self.settingsDialogAnchor = AnchorUtil.CreateAnchor("LEFT", UIParent, "LEFT", 250);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Target then
		self.settingsDialogAnchor = AnchorUtil.CreateAnchor("RIGHT", UIParent, "RIGHT", -250);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Focus then
		self.settingsDialogAnchor = AnchorUtil.CreateAnchor("RIGHT", UIParent, "RIGHT", -250);
	end
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingHidePortrait()
	--TODO
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingBuffsOnTop()
	self.buffsOnTop = self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.BuffsOnTop);
	TargetFrame_UpdateAuras(self);
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingUseLargerFrame()
	FocusFrame_SetSmallSize(not self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseLargerFrame));
end

function EditModeUnitFrameSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeUnitFrameSetting.HidePortrait and self:HasSetting(Enum.EditModeUnitFrameSetting.HidePortrait) then
		self:UpdateSystemSettingHidePortrait();
	elseif setting == Enum.EditModeUnitFrameSetting.CastBarUnderneath and self:HasSetting(Enum.EditModeUnitFrameSetting.CastBarUnderneath) then
		-- Nothing to do, this setting is mirrored by Enum.EditModeCastBarSetting.LockToPlayerFrame 
	elseif setting == Enum.EditModeUnitFrameSetting.BuffsOnTop and self:HasSetting(Enum.EditModeUnitFrameSetting.BuffsOnTop) then
		self:UpdateSystemSettingBuffsOnTop();
	elseif setting == Enum.EditModeUnitFrameSetting.UseLargerFrame and self:HasSetting(Enum.EditModeUnitFrameSetting.UseLargerFrame) then
		self:UpdateSystemSettingUseLargerFrame();
	end

	self:ClearDirtySetting(setting);
end

EditModeMinimapSystemMixin = {};

function EditModeMinimapSystemMixin:UpdateSystemSettingHeaderUnderneath()
	self:SetHeaderUnderneath(self:GetSettingValueBool(Enum.EditModeMinimapSetting.HeaderUnderneath));
end

function EditModeMinimapSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeMinimapSetting.HeaderUnderneath and self:HasSetting(Enum.EditModeMinimapSetting.HeaderUnderneath) then
		self:UpdateSystemSettingHeaderUnderneath();
	end

	self:ClearDirtySetting(setting);
end

EditModeCastBarSystemMixin = {};

local function CreateResetToDefaultPositionButton(systemFrame, extraButtonPool)
	local resetPositionButton = extraButtonPool:Acquire();
	resetPositionButton.layoutIndex = 3;
	resetPositionButton:SetText(HUD_EDIT_MODE_RESET_POSITION);
	resetPositionButton:SetOnClickHandler(GenerateClosure(systemFrame.ResetToDefaultPosition, systemFrame));
	resetPositionButton:SetEnabled(not systemFrame:IsInDefaultPosition());
	resetPositionButton:Show();
end

function EditModeCastBarSystemMixin:ApplySystemAnchor()
	local lockToPlayerFrame = self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame);
	if lockToPlayerFrame then
		-- Nothing to do, it's already anchored to the player frame
	else
		EditModeSystemMixin.ApplySystemAnchor(self);
	end
end

function EditModeCastBarSystemMixin:OnDragStop()
	if self:CanBeMoved() then
		self:StopMovingOrSizing();
		self:SetParent(UIParent);
		EditModeManagerFrame:OnSystemPositionChange(self);
	end
end

function EditModeCastBarSystemMixin:ShouldResetSettingsDialogAnchors(oldSelectedSystemFrame)
	return true;
end

function EditModeCastBarSystemMixin:ShouldShowSetting(setting)
	if setting == Enum.EditModeCastBarSetting.BarSize then
		return not self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame);
	end

	return true;
end

function EditModeCastBarSystemMixin:SetupSettingsDialogAnchor()
	self.settingsDialogAnchor = AnchorUtil.CreateAnchor("LEFT", UIParent, "CENTER", 100);
end

function EditModeCastBarSystemMixin:AddExtraButtons(extraButtonPool)
	if not self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame) then
		CreateResetToDefaultPositionButton(self, extraButtonPool);
		return true;
	end

	return false;
end

function EditModeCastBarSystemMixin:AnchorSelectionFrame()
	self.Selection:ClearAllPoints();
	if self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame) then
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", -20, 0);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, -12);
	else
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, -12);
	end
end

function EditModeCastBarSystemMixin:UpdateSystemSettingLockToPlayerFrame()
	local lockToPlayerFrame = self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame);
	if lockToPlayerFrame then
		PlayerFrame_AttachCastBar();
		self.isLocked = true;
	else
		PlayerFrame_DetachCastBar();
		self:ApplySystemAnchor();
		self.isLocked = false;
	end

	self:UpdateSystemSettingBarSize();
end

function EditModeCastBarSystemMixin:UpdateSystemSettingBarSize()
	if self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame) then
		self:SetScale(1);
	else
		local barSizeSetting = self:GetSettingValue(Enum.EditModeCastBarSetting.BarSize);
		local barScale = barSizeSetting / 100;
		self:SetScale(barScale);
	end
end

function EditModeCastBarSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeCastBarSetting.BarSize then
		self:UpdateSystemSettingBarSize();
	elseif setting == Enum.EditModeCastBarSetting.LockToPlayerFrame then
		self:UpdateSystemSettingLockToPlayerFrame();
	end

	self:ClearDirtySetting(setting);
end

EditModeEncounterBarSystemMixin = {};

function EditModeEncounterBarSystemMixin:AddExtraButtons(extraButtonPool)
	CreateResetToDefaultPositionButton(self, extraButtonPool);
	return true;
end

function EditModeEncounterBarSystemMixin:OnDragStart()
	if self:CanBeMoved() then
		self:SetParent(UIParent);
		self:StartMoving();
	end
end

EditModeExtraAbilitiesSystemMixin = {};

function EditModeExtraAbilitiesSystemMixin:AddExtraButtons(extraButtonPool)
	CreateResetToDefaultPositionButton(self, extraButtonPool);
	return true;
end

function EditModeExtraAbilitiesSystemMixin:OnDragStart()
	if self:CanBeMoved() then
		self:SetParent(UIParent);
		self:StartMoving();
	end
end

local EditModeSystemSelectionLayout =
{
	["TopRightCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, x=8, y=8 },
	["TopLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, x=-8, y=8 },
	["BottomLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, x=-8, y=-8 },
	["BottomRightCorner"] = { atlas = "%s-NineSlice-Corner",  mirrorLayout = true, x=8, y=-8 },
	["TopEdge"] = { atlas = "_%s-NineSlice-EdgeTop" },
	["BottomEdge"] = { atlas = "_%s-NineSlice-EdgeBottom" },
	["LeftEdge"] = { atlas = "!%s-NineSlice-EdgeLeft" },
	["RightEdge"] = { atlas = "!%s-NineSlice-EdgeRight" },
	["Center"] = { atlas = "%s-NineSlice-Center", x = -8, y = 8, x1 = 8, y1 = -8, },
};

EditModeSystemSelectionBaseMixin = {};

function EditModeSystemSelectionBaseMixin:OnLoad()
	self.parent = self:GetParent();
end

function EditModeSystemSelectionBaseMixin:ShowHighlighted()
	NineSliceUtil.ApplyLayout(self, EditModeSystemSelectionLayout, self.highlightTextureKit);
	self.isSelected = false;
	self:UpdateLabelVisibility();
	self:Show();
end

function EditModeSystemSelectionBaseMixin:ShowSelected()
	NineSliceUtil.ApplyLayout(self, EditModeSystemSelectionLayout, self.selectedTextureKit);
	self.isSelected = true;
	self:UpdateLabelVisibility();
	self:Show();
end

function EditModeSystemSelectionBaseMixin:OnDragStart()
	self.parent:OnDragStart();
end

function EditModeSystemSelectionBaseMixin:OnDragStop()
	self.parent:OnDragStop();
end

function EditModeSystemSelectionBaseMixin:OnMouseDown()
	EditModeManagerFrame:SelectSystem(self.parent);
end

EditModeSystemSelectionMixin = {};

function EditModeSystemSelectionMixin:SetLabelText(text)
	self.Label:SetText(text);
end

function EditModeSystemSelectionMixin:UpdateLabelVisibility()
	self.Label:SetShown(self.isSelected);
end

EditModeActionBarSystemSelectionMixin = {};

function EditModeActionBarSystemSelectionMixin:SetLabelText(text)
	self.HorizontalLabel:SetText(text);
	self.VerticalLabel:SetText(text);
end

function EditModeActionBarSystemSelectionMixin:SetVerticalState(vertical)
	self.isVertical = vertical;
	self:UpdateLabelVisibility();
end

function EditModeActionBarSystemSelectionMixin:UpdateLabelVisibility()
	self.HorizontalLabel:SetShown(self.isSelected and not self.isVertical);
	self.VerticalLabel:SetShown(self.isSelected and self.isVertical);
end
