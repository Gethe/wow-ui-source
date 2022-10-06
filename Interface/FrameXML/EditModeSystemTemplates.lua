EditModeSystemMixin = {};

function EditModeSystemMixin:OnSystemLoad()
	if not self.system then
		-- All systems must have self.system set on them
		return;
	end

	-- Override set scale so we can keep systems in place as their scale changes
	self.SetScaleBase = self.SetScale;
	self.SetScale = self.SetScaleOverride;

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

function EditModeSystemMixin:SetScaleOverride(newScale)
	local oldScale = self:GetScale();

	self:SetScaleBase(newScale);

	if oldScale == newScale then
		return;
	end

	-- Update position to try and keep the system frame in the same position since scale changes how offsets work
	local numPoints = self:GetNumPoints();
	for i = 1, numPoints do
		local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint(i);

		-- Undo old scale adjustment so we're working with 1.0 scale offsets
		-- Then apply the newScale adjustment
		offsetX = offsetX * oldScale / newScale;
		offsetY = offsetY * oldScale / newScale;
		self:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
	end

	if (self.isBottomManagedFrame or self.isRightManagedFrame) and self:IsInDefaultPosition() then
		UIParent_ManageFramePositions();
	end
end

function EditModeSystemMixin:UpdateClampOffsets()
	if not self:GetLeft() then
		self:SetClampRectInsets(0, 0, 0, 0);
		return;
	end

	local leftOffset = self.Selection:GetLeft() - self:GetLeft();
	local rightOffset = self.Selection:GetRight() - self:GetRight();
	local topOffset = self.Selection:GetTop() - self:GetTop();
	local bottomOffset = self.Selection:GetBottom() - self:GetBottom();

	self:SetClampRectInsets(leftOffset, rightOffset, topOffset, bottomOffset);
end

-- Override in inheriting mixins as needed
function EditModeSystemMixin:AnchorSelectionFrame()
	self:UpdateClampOffsets();
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
		if not oldSettingsMap or not oldSettingsMap[setting] or oldSettingsMap[setting].value ~= settingInfo.value then
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
	self.systemInfo.anchorInfo = EditModePresetLayoutManager:GetModernSystemAnchorInfo(self.system, self.systemIndex);
	self.systemInfo.anchorInfo2 = nil;
	self.systemInfo.isInDefaultPosition = true;
	self:ApplySystemAnchor();
	EditModeSystemSettingsDialog:UpdateDialog(self);
	self:SetHasActiveChanges(true);
end

function EditModeSystemMixin:ApplySystemAnchor()
	if self.isBottomManagedFrame or self.isRightManagedFrame then
		local frameContainer = self.isBottomManagedFrame and UIParentBottomManagedFrameContainer or UIParentRightManagedFrameContainer;

		if self:IsInDefaultPosition() then
			self.ignoreFramePositionManager = nil;
			frameContainer:AddManagedFrame(self);
			return;
		else
			self.ignoreFramePositionManager = true;
			frameContainer:RemoveManagedFrame(self);
			self:SetParent(UIParent);
		end
	end

	self:ClearAllPoints();

	-- Make sure offsets are relative to our current scale
	local scale = self:GetScale();
	self:SetPoint(self.systemInfo.anchorInfo.point, self.systemInfo.anchorInfo.relativeTo, self.systemInfo.anchorInfo.relativePoint, self.systemInfo.anchorInfo.offsetX / scale, self.systemInfo.anchorInfo.offsetY / scale);

	if self.systemInfo.anchorInfo2 then
		self:SetPoint(self.systemInfo.anchorInfo2.point, self.systemInfo.anchorInfo2.relativeTo, self.systemInfo.anchorInfo2.relativePoint, self.systemInfo.anchorInfo2.offsetX / scale, self.systemInfo.anchorInfo2.offsetY / scale);
	end

	EditModeManagerFrame:UpdateActionBarLayout(self);
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
	return self.settingMap and (self.settingMap[setting] ~= nil);
end

function EditModeSystemMixin:GetSettingValue(setting, useRawValue)
	if not self:IsInitialized() then
		return 0;
	end
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
function EditModeSystemMixin:UpdateDisplayInfoOptions(displayInfo)
	return displayInfo;
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
	-- Create reset to default position button
	self.resetToDefaultPositionButton = extraButtonPool:Acquire();
	self.resetToDefaultPositionButton.layoutIndex = 3;
	self.resetToDefaultPositionButton:SetText(HUD_EDIT_MODE_RESET_POSITION);
	self.resetToDefaultPositionButton:SetOnClickHandler(GenerateClosure(self.ResetToDefaultPosition, self));
	self.resetToDefaultPositionButton:SetEnabled(not self:IsInDefaultPosition());
	self.resetToDefaultPositionButton:Show();
	return true;
end

function EditModeSystemMixin:IsToTheLeftOfFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return myRight < systemFrameLeft;
end

function EditModeSystemMixin:IsToTheRightOfFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return myLeft > systemFrameRight;
end

function EditModeSystemMixin:IsAboveFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return myBottom > systemFrameTop;
end

function EditModeSystemMixin:IsBelowFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return myTop < systemFrameBottom;
end

function EditModeSystemMixin:IsVerticallyAlignedWithFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return (myTop >= systemFrameBottom) and (myBottom <= systemFrameTop);
end

function EditModeSystemMixin:IsHorizontallyAlignedWithFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return (myRight >= systemFrameLeft) and (myLeft <= systemFrameRight);
end

-- Returns selection frame center, adjusted for scale: centerX, centerY
function EditModeSystemMixin:GetScaledSelectionCenter()
	local centerX, centerY = self.Selection:GetCenter();
	local scale = self:GetScale();
	return centerX * scale, centerY * scale;
end

-- Returns center, adjusted for scale: centerX, centerY
function EditModeSystemMixin:GetScaledCenter()
	local centerX, centerY = self:GetCenter();
	local scale = self:GetScale();
	return centerX * scale, centerY * scale;
end

-- Returns selection frame sides, adjusted for scale: left, right, bottom, top
function EditModeSystemMixin:GetScaledSelectionSides()
	local left, bottom, width, height = self.Selection:GetRect();
	local scale = self:GetScale();
	return left * scale, (left + width) * scale, bottom * scale, (bottom + height) * scale;
end

local SELECTION_PADDING = 2;

function EditModeSystemMixin:GetSelectionOffset(point, forYOffset)
	local offset;
	if point == "LEFT" then
		offset = select(4, self.Selection:GetPoint(1)) - SELECTION_PADDING;
	elseif point == "RIGHT" then
		offset = select(4, self.Selection:GetPoint(2)) + SELECTION_PADDING;
	elseif point == "TOP" then
		offset = select(5, self.Selection:GetPoint(1)) + SELECTION_PADDING;
	elseif point == "BOTTOM" then
		offset = select(5, self.Selection:GetPoint(2)) - SELECTION_PADDING;
	else
		-- Center
		local selectionCenterX, selectionCenterY = self.Selection:GetCenter();
		local centerX, centerY = self:GetCenter();
		if forYOffset then
			offset = selectionCenterY - centerY;
		else
			offset = selectionCenterX - centerX;
		end
	end

	return offset * self:GetScale();
end

function EditModeSystemMixin:GetCombinedSelectionOffset(frameInfo, forYOffset)
	local offset;
	if frameInfo.frame.Selection then
		offset = -self:GetSelectionOffset(frameInfo.point, forYOffset) + frameInfo.frame:GetSelectionOffset(frameInfo.relativePoint, forYOffset) + frameInfo.offset;
	else
		offset = -self:GetSelectionOffset(frameInfo.point, forYOffset) + frameInfo.offset;
	end

	return offset / self:GetScale();
end

function EditModeSystemMixin:GetCombinedCenterOffset(frame)
	local centerX, centerY = self:GetScaledCenter();
	local frameCenterX, frameCenterY;
	if frame.GetScaledCenter then
		frameCenterX, frameCenterY = frame:GetScaledCenter();
	else
		frameCenterX, frameCenterY = frame:GetCenter();
	end

	local scale = self:GetScale();
	return (centerX - frameCenterX) / scale, (centerY - frameCenterY) / scale;
end

function EditModeSystemMixin:GetSnapOffsets(frameInfo)
	local offsetX, offsetY = self:GetCombinedCenterOffset(frameInfo.frame);
	if frameInfo.isHorizontal then
		local forYOffsetNo = false;
		offsetX = self:GetCombinedSelectionOffset(frameInfo, forYOffsetNo);
	else
		local forYOffsetYes = true;
		offsetY = self:GetCombinedSelectionOffset(frameInfo, forYOffsetYes);
	end
	return offsetX, offsetY;
end

function EditModeSystemMixin:SnapToFrame(frameInfo)
	local offsetX, offsetY = self:GetSnapOffsets(frameInfo);
	self:SetPoint(frameInfo.point, frameInfo.frame, frameInfo.relativePoint, offsetX, offsetY);
end

function EditModeSystemMixin:IsFrameAnchoredToMe(frame)
	for i = 1, frame:GetNumPoints() do
		local _, relativeTo = frame:GetPoint(i);

		if not relativeTo then
			return false;
		end

		if relativeTo == self then
			return true;
		end

		if self:IsFrameAnchoredToMe(relativeTo) then
			return true;
		end
	end

	return false;
end

function EditModeSystemMixin:GetFrameMagneticEligibility(systemFrame)
	-- Can't magnetize to myself
	if systemFrame ==  self then
		return nil;
	end

	-- Can't magnetize to anything already anchored to me
	if self:IsFrameAnchoredToMe(systemFrame) then
		return nil;
	end

	local horizontalEligible = self:IsVerticallyAlignedWithFrame(systemFrame) and (self:IsToTheLeftOfFrame(systemFrame) or self:IsToTheRightOfFrame(systemFrame));
	local verticalEligible = self:IsHorizontallyAlignedWithFrame(systemFrame) and (self:IsAboveFrame(systemFrame) or self:IsBelowFrame(systemFrame));

	return horizontalEligible, verticalEligible;
end

function EditModeSystemMixin:UpdateMagnetismRegistration()
	if self:IsVisible() and self.isHighlighted and not self.isSelected then
		EditModeMagnetismManager:RegisterFrame(self);
	else
		EditModeMagnetismManager:UnregisterFrame(self);
	end
end

function EditModeSystemMixin:ClearHighlight()
	if self.isSelected then
		EditModeManagerFrame:ClearSelectedSystem();
		self.isSelected = false;
	end

	self.Selection:Hide();
	self.isHighlighted = false;
	self:UpdateMagnetismRegistration();
end

function EditModeSystemMixin:HighlightSystem()
	self:SetMovable(false);
	self:AnchorSelectionFrame();
	self.Selection:ShowHighlighted();
	self.isHighlighted = true;
	self.isSelected = false;
	self:UpdateMagnetismRegistration();
end

function EditModeSystemMixin:SelectSystem()
	if not self.isSelected then
		self:SetMovable(true);
		self.Selection:ShowSelected();
		EditModeSystemSettingsDialog:AttachToSystemFrame(self);
		self.isSelected = true;
		self:UpdateMagnetismRegistration();
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
	return self:IsInitialized() and self.systemInfo.isInDefaultPosition;
end

function EditModeSystemMixin:OnDragStart()
	if self:CanBeMoved() then
		if (self.isBottomManagedFrame or self.isRightManagedFrame) and self:IsInDefaultPosition() then
			self:SetParent(UIParent);
		end

		self:StartMoving();
	end
end

function EditModeSystemMixin:OnDragStop()
	if self:CanBeMoved() then
		self:StopMovingOrSizing();
		if EditModeManagerFrame:IsSnapEnabled() then
			EditModeMagnetismManager:ApplyMagnetism(self);
		end
		local isInDefaultPositionNo = false;
		EditModeManagerFrame:OnSystemPositionChange(self, isInDefaultPositionNo);
	end
end

EditModeActionBarSystemMixin = {};

function EditModeActionBarSystemMixin:UpdateSystem(systemInfo)
	EditModeSystemMixin.UpdateSystem(self, systemInfo);
	self:RefreshGridLayout();
	self:RefreshButtonArt();
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

function EditModeActionBarSystemMixin:GetRightAnchoredWidth()
	if not self:IsInitialized() then
		return 0;
	end

	if self:IsShown() and self:IsInDefaultPosition() then
		return self:GetWidth() - self.systemInfo.anchorInfo.offsetX;
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

	EditModeManagerFrame:UpdateActionBarLayout(self);
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

	-- Since the orientation changed we'll want to update the grid layout
	self:MarkGridLayoutDirty();

	-- Update the art since we'll possibly be switching from horizontal to vertical dividers
	self:MarkButtonArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingNumRows()
	self.numRows = self:GetSettingValue(Enum.EditModeActionBarSetting.NumRows);

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
	elseif self:DoesSettingValueEqual(Enum.EditModeActionBarSetting.VisibleSetting, Enum.ActionBarVisibleSetting.Hidden) then
		self.visibility = "Hidden";
	else
		self.visibility = "Always";
	end
	self:UpdateVisibility();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingAlwaysShowButtons()
	local alwaysShowButtons = self:GetSettingValueBool(Enum.EditModeActionBarSetting.AlwaysShowButtons);
	self:SetShowGrid(alwaysShowButtons, ACTION_BUTTON_SHOW_GRID_REASON_CVAR);
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
	Settings.OpenToCategory(Settings.ACTION_BAR_CATEGORY_ID);
end

function EditModeActionBarSystemMixin:AddExtraButtons(extraButtonPool)
	EditModeSystemMixin.AddExtraButtons(self, extraButtonPool);

	local quickKeybindModeButton = extraButtonPool:Acquire();
	quickKeybindModeButton.layoutIndex = 4;
	quickKeybindModeButton:SetText(QUICK_KEYBIND_MODE);
	quickKeybindModeButton:SetOnClickHandler(enterQuickKeybindMode);
	quickKeybindModeButton:Show();

	if self.systemIndex ~= Enum.EditModeActionBarSystemIndices.StanceBar
		and self.systemIndex ~= Enum.EditModeActionBarSystemIndices.PetActionBar
		and self.systemIndex ~= Enum.EditModeActionBarSystemIndices.PossessActionBar then
		local actionBarSettingsButton = extraButtonPool:Acquire();
		actionBarSettingsButton.layoutIndex = 5;
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

function EditModeUnitFrameSystemMixin:UseCombinedGroups()
	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid then
		local raidGroupDisplayType = self:GetSettingValue(Enum.EditModeUnitFrameSetting.RaidGroupDisplayType);
		return (raidGroupDisplayType == Enum.RaidGroupDisplayType.CombineGroupsVertical) or (raidGroupDisplayType == Enum.RaidGroupDisplayType.CombineGroupsHorizontal);
	else
		return false;
	end
end

function EditModeUnitFrameSystemMixin:UseSettingAltName(setting)
	if setting == Enum.EditModeUnitFrameSetting.RowSize then
		return self:DoesSettingValueEqual(Enum.EditModeUnitFrameSetting.RaidGroupDisplayType, Enum.RaidGroupDisplayType.CombineGroupsVertical);
	end
	return false;
end

function EditModeUnitFrameSystemMixin:ShouldShowSetting(setting)
	if not EditModeSystemMixin.ShouldShowSetting(self, setting) then
		return false;
	end

	if setting == Enum.EditModeUnitFrameSetting.ShowPartyFrameBackground then
		return not self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames);
	elseif setting == Enum.EditModeUnitFrameSetting.UseHorizontalGroups then
		return self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames);
	elseif setting == Enum.EditModeUnitFrameSetting.FrameHeight then
		if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Party then
			return self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames);
		end
	elseif setting == Enum.EditModeUnitFrameSetting.FrameWidth then
		if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Party then
			return self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames);
		end
	elseif setting == Enum.EditModeUnitFrameSetting.DisplayBorder then
		if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Party then
			return self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames);
		else
			return not self:UseCombinedGroups();
		end
	elseif setting == Enum.EditModeUnitFrameSetting.SortPlayersBy then
		return self:UseCombinedGroups();
	elseif setting == Enum.EditModeUnitFrameSetting.RowSize then
		return self:UseCombinedGroups();
	elseif setting == Enum.EditModeUnitFrameSetting.BuffsOnTop and self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Focus then
		return self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseLargerFrame);
	elseif setting == Enum.EditModeUnitFrameSetting.FrameSize then
		local shouldHideSetting = self:HasSetting(Enum.EditModeUnitFrameSetting.UseLargerFrame) and not self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseLargerFrame);
		shouldHideSetting = shouldHideSetting or (self:HasSetting(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames) and self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames));
		return not shouldHideSetting;
	end

	return true;
end

function EditModeUnitFrameSystemMixin:AnchorSelectionFrame()
	self.Selection:ClearAllPoints();
	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Player then
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 20, -16);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -18, 17);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Target then
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 20, -18);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -20, 18);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Focus then
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 20, -18);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -20, 18);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Party then
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid then
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Boss then
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Arena then
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
	end

	self:UpdateClampOffsets();
end

function EditModeUnitFrameSystemMixin:SetupSettingsDialogAnchor()
	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Player then
		self.settingsDialogAnchor = AnchorUtil.CreateAnchor("LEFT", UIParent, "LEFT", 250);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Target then
		self.settingsDialogAnchor = AnchorUtil.CreateAnchor("RIGHT", UIParent, "RIGHT", -250);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Focus then
		self.settingsDialogAnchor = AnchorUtil.CreateAnchor("RIGHT", UIParent, "RIGHT", -250);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Party then
		self.settingsDialogAnchor = AnchorUtil.CreateAnchor("TOPLEFT", UIParent, "TOPLEFT", 200, -200);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid then
		self.settingsDialogAnchor = AnchorUtil.CreateAnchor("TOPLEFT", UIParent, "TOPLEFT", 200, -200);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Boss then
		self.settingsDialogAnchor = AnchorUtil.CreateAnchor("TOPRIGHT", UIParent, "TOPRIGHT", -400, -200);
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Arena then
		self.settingsDialogAnchor = AnchorUtil.CreateAnchor("TOPRIGHT", UIParent, "TOPRIGHT", -400, -200);
	end
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingBuffsOnTop()
	self.buffsOnTop = self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.BuffsOnTop);
	self:UpdateAuras();
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingUseLargerFrame()
	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Focus then
		FocusFrame:SetSmallSize(not self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseLargerFrame));
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Boss then
		BossTargetFrameContainer:SetSmallSize(not self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseLargerFrame));
	end

	self:UpdateSystemSettingFrameSize();
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingUseRaidStylePartyFrames()
	UpdateRaidAndPartyFrames();
	CompactPartyFrame_RefreshMembers();
	self:UpdateSelectionVerticalState();
	self:UpdateSystemSettingFrameSize();
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingShowPartyFrameBackground()
	PartyFrame:UpdatePartyMemberBackground();
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingUseHorizontalGroups()
	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Party then
		if CompactPartyFrame then
			CompactRaidGroup_UpdateBorder(CompactPartyFrame);
		end
		UpdateRaidAndPartyFrames();
		self:UpdateSelectionVerticalState();
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid then
		EditModeManagerFrame:UpdateRaidContainerFlow();
	end
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingCastBarOnSide()
	self:SetCastBarPosition(self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.CastBarOnSide));
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingShowCastTime()
	-- TODO
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingViewRaidSize()
	CompactRaidFrameContainer:TryUpdate();
	CompactRaidFrameContainer:Layout();
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingFrameWidth()
	CompactRaidFrameContainer:ApplyToFrames("normal", DefaultCompactUnitFrameSetup);
	CompactRaidFrameContainer:ApplyToFrames("normal", CompactUnitFrame_UpdateAll);
	CompactRaidFrameContainer:ApplyToFrames("group", CompactRaidGroup_UpdateBorder);

	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid then
		EditModeManagerFrame:UpdateRaidContainerFlow();
	else
		PartyFrame:UpdatePaddingAndLayout();
	end
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingFrameHeight()
	CompactRaidFrameContainer:ApplyToFrames("normal", DefaultCompactUnitFrameSetup);
	CompactRaidFrameContainer:ApplyToFrames("normal", CompactUnitFrame_UpdateAll);
	CompactRaidFrameContainer:ApplyToFrames("group", CompactRaidGroup_UpdateBorder);

	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid then
		EditModeManagerFrame:UpdateRaidContainerFlow();
	else
		PartyFrame:UpdatePaddingAndLayout();
	end
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingDisplayBorder()
	CompactRaidFrameContainer:ApplyToFrames("group", CompactRaidGroup_UpdateBorder);

	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid then
		EditModeManagerFrame:UpdateRaidContainerFlow();
	else
		PartyFrame:UpdatePaddingAndLayout();
	end
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingRaidGroupDisplayType()
	local groupMode = self:UseCombinedGroups() and "flush" or "discrete";
	CompactRaidFrameContainer:SetGroupMode(groupMode);
	CompactRaidFrameManager_UpdateFilterInfo();
	EditModeManagerFrame:UpdateRaidContainerFlow();
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingSortPlayersBy()
	local sortBySettingValue = self:GetSettingValue(Enum.EditModeUnitFrameSetting.SortPlayersBy);
	if sortBySettingValue == Enum.SortPlayersBy.Group then
		CompactRaidFrameContainer:SetFlowSortFunction(CRFSort_Group);
	elseif sortBySettingValue == Enum.SortPlayersBy.Alphabetical then
		CompactRaidFrameContainer:SetFlowSortFunction(CRFSort_Alphabetical);
	else
		CompactRaidFrameContainer:SetFlowSortFunction(CRFSort_Role);
	end
	EditModeManagerFrame:UpdateRaidContainerFlow();
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingRowSize()
	EditModeManagerFrame:UpdateRaidContainerFlow();
end

function EditModeUnitFrameSystemMixin:UpdateSelectionVerticalState()
	local verticalState = self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames) and not self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseHorizontalGroups)
	self.Selection:SetVerticalState(verticalState);
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingFrameSize()
	if self:HasSetting(Enum.EditModeUnitFrameSetting.UseLargerFrame) and not self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseLargerFrame) then
		-- Boss frame needs to reset it's container size when not using larger frames
		-- Don't need this for focus frame since it's method around UseLargerFrame is directly setting it's scale whereas boss frame's doesn't change it's container's scale
		if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Boss then
			self:SetScale(1);
		end
		return;
	end

	if self:HasSetting(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames) and self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames) then
		self:SetScale(1);
		return;
	end

	self:SetScale(self:GetSettingValue(Enum.EditModeUnitFrameSetting.FrameSize) / 100);
end

function EditModeUnitFrameSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeUnitFrameSetting.CastBarUnderneath and self:HasSetting(Enum.EditModeUnitFrameSetting.CastBarUnderneath) then
		-- Nothing to do, this setting is mirrored by Enum.EditModeCastBarSetting.LockToPlayerFrame 
	elseif setting == Enum.EditModeUnitFrameSetting.BuffsOnTop and self:HasSetting(Enum.EditModeUnitFrameSetting.BuffsOnTop) then
		self:UpdateSystemSettingBuffsOnTop();
	elseif setting == Enum.EditModeUnitFrameSetting.UseLargerFrame and self:HasSetting(Enum.EditModeUnitFrameSetting.UseLargerFrame) then
		self:UpdateSystemSettingUseLargerFrame();
	elseif setting == Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames and self:HasSetting(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames) then
		self:UpdateSystemSettingUseRaidStylePartyFrames();
	elseif setting == Enum.EditModeUnitFrameSetting.ShowPartyFrameBackground and self:HasSetting(Enum.EditModeUnitFrameSetting.ShowPartyFrameBackground) then
		self:UpdateSystemSettingShowPartyFrameBackground();
	elseif setting == Enum.EditModeUnitFrameSetting.UseHorizontalGroups and self:HasSetting(Enum.EditModeUnitFrameSetting.UseHorizontalGroups) then
		self:UpdateSystemSettingUseHorizontalGroups();
	elseif setting == Enum.EditModeUnitFrameSetting.CastBarOnSide and self:HasSetting(Enum.EditModeUnitFrameSetting.CastBarOnSide) then
		self:UpdateSystemSettingCastBarOnSide();
	elseif setting == Enum.EditModeUnitFrameSetting.ShowCastTime and self:HasSetting(Enum.EditModeUnitFrameSetting.ShowCastTime) then
		self:UpdateSystemSettingShowCastTime();
	elseif setting == Enum.EditModeUnitFrameSetting.ViewRaidSize and self:HasSetting(Enum.EditModeUnitFrameSetting.ViewRaidSize) then
		self:UpdateSystemSettingViewRaidSize();
	elseif setting == Enum.EditModeUnitFrameSetting.FrameWidth and self:HasSetting(Enum.EditModeUnitFrameSetting.FrameWidth) then
		self:UpdateSystemSettingFrameWidth();
	elseif setting == Enum.EditModeUnitFrameSetting.FrameHeight and self:HasSetting(Enum.EditModeUnitFrameSetting.FrameHeight) then
		self:UpdateSystemSettingFrameHeight();
	elseif setting == Enum.EditModeUnitFrameSetting.DisplayBorder and self:HasSetting(Enum.EditModeUnitFrameSetting.DisplayBorder) then
		self:UpdateSystemSettingDisplayBorder();
	elseif setting == Enum.EditModeUnitFrameSetting.RaidGroupDisplayType and self:HasSetting(Enum.EditModeUnitFrameSetting.RaidGroupDisplayType) then
		self:UpdateSystemSettingRaidGroupDisplayType();
	elseif setting == Enum.EditModeUnitFrameSetting.SortPlayersBy and self:HasSetting(Enum.EditModeUnitFrameSetting.SortPlayersBy) then
		self:UpdateSystemSettingSortPlayersBy();
	elseif setting == Enum.EditModeUnitFrameSetting.RowSize and self:HasSetting(Enum.EditModeUnitFrameSetting.RowSize) then
		self:UpdateSystemSettingRowSize();
	elseif setting == Enum.EditModeUnitFrameSetting.FrameSize and self:HasSetting(Enum.EditModeUnitFrameSetting.FrameSize) then
		self:UpdateSystemSettingFrameSize()
	end

	self:ClearDirtySetting(setting);
end

EditModeBossUnitFrameSystemMixin = {};

function EditModeBossUnitFrameSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateShownState();
end

function EditModeBossUnitFrameSystemMixin:UpdateShownState()
	local isAnyBossFrameShowing = false;
	for index, bossFrame in ipairs(self.BossTargetFrames) do
		bossFrame:UpdateShownState();
		isAnyBossFrameShowing = isAnyBossFrameShowing or bossFrame:IsShown();
	end

	self:SetShown(self.isInEditMode or isAnyBossFrameShowing);
end

EditModeArenaUnitFrameSystemMixin = {};

function EditModeArenaUnitFrameSystemMixin:OnSystemLoad()
	EditModeSystemMixin.OnSystemLoad(self);

	-- Gotta call this ourselves since arena frames are loaded in as needed on the fly so they won't be setup yet
	EditModeManagerFrame:UpdateSystem(self);
end

function EditModeArenaUnitFrameSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self:SetIsInEditMode(false);
	self:Update();
end

function EditModeArenaUnitFrameSystemMixin:SetIsInEditMode(isInEditMode)
	self.isInEditMode = isInEditMode;
	for index, unitFrame in ipairs(ArenaEnemyMatchFramesContainer.UnitFrames) do
		unitFrame.isInEditMode = isInEditMode;
		unitFrame:GetPetFrame().isInEditMode = isInEditMode;
	end
end

EditModeMinimapSystemMixin = {};

function EditModeMinimapSystemMixin:UpdateSystemSettingHeaderUnderneath()
	self:SetHeaderUnderneath(self:GetSettingValueBool(Enum.EditModeMinimapSetting.HeaderUnderneath));
end

function EditModeMinimapSystemMixin:UpdateSystemSettingRotateMinimap()
	self:SetRotateMinimap(self:GetSettingValueBool(Enum.EditModeMinimapSetting.RotateMinimap));
end

function EditModeMinimapSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeMinimapSetting.HeaderUnderneath and self:HasSetting(Enum.EditModeMinimapSetting.HeaderUnderneath) then
		self:UpdateSystemSettingHeaderUnderneath();
	elseif setting == Enum.EditModeMinimapSetting.RotateMinimap and self:HasSetting(Enum.EditModeMinimapSetting.RotateMinimap) then
		self:UpdateSystemSettingRotateMinimap();
	end

	self:ClearDirtySetting(setting);
end

EditModeCastBarSystemMixin = {};

function EditModeCastBarSystemMixin:ApplySystemAnchor()
	local lockToPlayerFrame = self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame);
	if lockToPlayerFrame then
		PlayerFrame_AttachCastBar();
	else
		EditModeSystemMixin.ApplySystemAnchor(self);
	end
end

function EditModeCastBarSystemMixin:ShouldResetSettingsDialogAnchors(oldSelectedSystemFrame)
	return true;
end

function EditModeCastBarSystemMixin:ShouldShowSetting(setting)
	if not EditModeSystemMixin.ShouldShowSetting(self, setting) then
		return false;
	end

	if setting == Enum.EditModeCastBarSetting.BarSize then
		return not self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame);
	end

	return true;
end

function EditModeCastBarSystemMixin:SetupSettingsDialogAnchor()
	self.settingsDialogAnchor = AnchorUtil.CreateAnchor("LEFT", UIParent, "CENTER", 100);
end

function EditModeCastBarSystemMixin:AddExtraButtons(extraButtonPool)
	EditModeSystemMixin.AddExtraButtons(self, extraButtonPool);
	self.resetToDefaultPositionButton:SetEnabled(not self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame));
	return true;
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

	self:UpdateClampOffsets();
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

function EditModeEncounterBarSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	-- Undo encounter bar min size stuff so we don't have extra spacing in bottom managed container
	EncounterBar.minimumWidth = nil;
	EncounterBar.minimumHeight = nil;
	EncounterBar:Layout();
	UIParent_ManageFramePositions();
end

function EditModeEncounterBarSystemMixin:ApplySystemAnchor()
	EditModeSystemMixin.ApplySystemAnchor(self);
	self:Layout();
end

EditModeExtraAbilitiesSystemMixin = {};

function EditModeExtraAbilitiesSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateShownState();
end

EditModeAuraFrameSystemMixin = {};

function EditModeAuraFrameSystemMixin:OnEditModeEnter()
	EditModeSystemMixin.OnEditModeEnter(self);

	if not self.hasInitializedExampleAuras then
		-- Setup example aura frames
		local spellIconsOnly = true;
		self.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Spell, spellIconsOnly);
		local iconDataProviderNumIcons = self.iconDataProvider:GetNumIcons();

		self.exampleAuraFrames = {};
		for i = 1, self.maxAuras, 1 do
			local auraFrame = self.auraPool:Acquire(self.exampleAuraTemplate);
			auraFrame:SetScale(self.AuraContainer.iconScale);

			auraFrame.duration:SetFontObject(DEFAULT_AURA_DURATION_FONT);
			auraFrame.duration:SetFormattedText(SecondsToTimeAbbrev(i * 60));

			auraFrame.Icon:SetTexture(self.iconDataProvider:GetIconByIndex(math.random(1, iconDataProviderNumIcons)));

			if auraFrame.Setup then
				auraFrame:Setup();
			end

			auraFrame:Hide();
			table.insert(self.exampleAuraFrames, auraFrame);
		end

		self.iconDataProvider:Release();
		self.iconDataProvider = nil;

		self.hasInitializedExampleAuras = true;
	end
end

function EditModeAuraFrameSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateAuraButtons();
	self:UpdateGridLayout();
end

function EditModeAuraFrameSystemMixin:UpdateDisplayInfoOptions(displayInfo)
	local updatedDisplayInfo = displayInfo;

	if displayInfo.setting == Enum.EditModeAuraFrameSetting.IconWrap then
		updatedDisplayInfo = CopyTable(displayInfo);

		local valueTextPrefix = "HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_";

		if self:DoesSettingValueEqual(Enum.EditModeAuraFrameSetting.Orientation, Enum.AuraFrameOrientation.Horizontal) then
			updatedDisplayInfo.options[1].text = _G[valueTextPrefix.."DOWN"];
			updatedDisplayInfo.options[2].text = _G[valueTextPrefix.."UP"];
		else -- Vertical orientation
			updatedDisplayInfo.options[1].text = _G[valueTextPrefix.."LEFT"];
			updatedDisplayInfo.options[2].text = _G[valueTextPrefix.."RIGHT"];
		end
	elseif displayInfo.setting == Enum.EditModeAuraFrameSetting.IconDirection then
		updatedDisplayInfo = CopyTable(displayInfo);

		local valueTextPrefix = "HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_";

		if self:DoesSettingValueEqual(Enum.EditModeAuraFrameSetting.Orientation, Enum.AuraFrameOrientation.Horizontal) then
			updatedDisplayInfo.options[1].text = _G[valueTextPrefix.."LEFT"];
			updatedDisplayInfo.options[2].text = _G[valueTextPrefix.."RIGHT"];
		else -- Vertical orientation
			updatedDisplayInfo.options[1].text = _G[valueTextPrefix.."DOWN"];
			updatedDisplayInfo.options[2].text = _G[valueTextPrefix.."UP"];
		end
	end

	return updatedDisplayInfo;
end

function EditModeAuraFrameSystemMixin:UpdateSystem(systemInfo)
	EditModeSystemMixin.UpdateSystem(self, systemInfo);
	self:UpdateGridLayout();
end

function EditModeAuraFrameSystemMixin:MarkAuraButtonsDirty()
	self.auraButtonsDirty = true;
end

function EditModeAuraFrameSystemMixin:RefreshAuraButtons()
	if self.auraButtonsDirty then
		self:UpdateAuraButtons()
		self.auraButtonsDirty = false;
	end
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingOrientation()
	local isHorizontal = self:DoesSettingValueEqual(Enum.EditModeAuraFrameSetting.Orientation, Enum.AuraFrameOrientation.Horizontal);
	self.AuraContainer.isHorizontal = isHorizontal;

	-- Update icon wrap and direction based on new orientation
	-- This is to try and keep the icons in roughly the same location when swapping orientations
	local oldIconWrap = self:GetSettingValue(Enum.EditModeAuraFrameSetting.IconWrap);
	local oldIconDirection = self:GetSettingValue(Enum.EditModeAuraFrameSetting.IconDirection);
	local newIconWrap;
	local newIconDirection;

	if isHorizontal then
		-- Update IconDirection
		if oldIconWrap == Enum.AuraFrameIconWrap.Left then
			newIconDirection = Enum.AuraFrameIconDirection.Left;
		elseif oldIconWrap == Enum.AuraFrameIconWrap.Right then
			newIconDirection = Enum.AuraFrameIconDirection.Right;
		end

		-- Update IconWrap
		if oldIconDirection == Enum.AuraFrameIconDirection.Down then
			newIconWrap = Enum.AuraFrameIconWrap.Down;
		elseif oldIconDirection == Enum.AuraFrameIconDirection.Up then
			newIconWrap = Enum.AuraFrameIconWrap.Up;
		end
	else -- Vertical orientation
		-- Update IconDirection
		if oldIconWrap == Enum.AuraFrameIconWrap.Down then
			newIconDirection = Enum.AuraFrameIconDirection.Down;
		elseif oldIconWrap == Enum.AuraFrameIconWrap.Up then
			newIconDirection = Enum.AuraFrameIconDirection.Up;
		end

		-- Update IconWrap
		if oldIconDirection == Enum.AuraFrameIconDirection.Left then
			newIconWrap = Enum.AuraFrameIconWrap.Left;
		elseif oldIconDirection == Enum.AuraFrameIconDirection.Right then
			newIconWrap = Enum.AuraFrameIconWrap.Right;
		end
	end

	if newIconWrap then
		EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeAuraFrameSetting.IconDirection, newIconDirection);
	end

	if newIconDirection then
		EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeAuraFrameSetting.IconWrap, newIconWrap);
	end
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingIconWrap()
	local iconWrap = self:GetSettingValue(Enum.EditModeAuraFrameSetting.IconWrap);

	if self:DoesSettingValueEqual(Enum.EditModeAuraFrameSetting.Orientation, Enum.AuraFrameOrientation.Horizontal) then
		if iconWrap == Enum.AuraFrameIconWrap.Down then
			self.AuraContainer.addIconsToTop = false;
		else -- Up
			self.AuraContainer.addIconsToTop = true;
		end
	else -- Vertical Orientation
		if iconWrap == Enum.AuraFrameIconWrap.Left then
			self.AuraContainer.addIconsToRight = false;
		else -- Right
			self.AuraContainer.addIconsToRight = true;
		end
	end
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingIconDirection()
	local iconDirection = self:GetSettingValue(Enum.EditModeAuraFrameSetting.IconDirection);

	if self:DoesSettingValueEqual(Enum.EditModeAuraFrameSetting.Orientation, Enum.AuraFrameOrientation.Horizontal) then
		if iconDirection == Enum.AuraFrameIconDirection.Left then
			self.AuraContainer.addIconsToRight = false;
		else -- Right
			self.AuraContainer.addIconsToRight = true;
		end
	else -- Vertical orientation
		if iconDirection == Enum.AuraFrameIconDirection.Down then
			self.AuraContainer.addIconsToTop = false;
		else -- Up
			self.AuraContainer.addIconsToTop = true;
		end
	end
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingIconLimit()
	local setting = self == BuffFrame and Enum.EditModeAuraFrameSetting.IconLimitBuffFrame or Enum.EditModeAuraFrameSetting.IconLimitDebuffFrame;
	self.AuraContainer.iconStride = self:GetSettingValue(setting);

	-- Only need to update aura buttons if we aren't already showing the full number of auras
	-- This is because we base the number of buttons we show on the icon limit if we aren't showing a full number of them
	if not self:GetSettingValueBool(Enum.EditModeAuraFrameSetting.ShowFull) then
		self:MarkAuraButtonsDirty();
	end
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingIconSize()
	local iconSize = self:GetSettingValue(Enum.EditModeAuraFrameSetting.IconSize);
	self.AuraContainer.iconScale = iconSize / 100;
	for i, auraFrame in pairs(self.auraFrames) do
		auraFrame:SetScale(self.AuraContainer.iconScale);
	end
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingIconPadding()
	self.AuraContainer.iconPadding = self:GetSettingValue(Enum.EditModeAuraFrameSetting.IconPadding);
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingShowFull()
	self.ShowFull = self:GetSettingValueBool(Enum.EditModeAuraFrameSetting.ShowFull);
	self:MarkAuraButtonsDirty();
end

function EditModeAuraFrameSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeAuraFrameSetting.Orientation and self:HasSetting(Enum.EditModeAuraFrameSetting.Orientation) then
		self:UpdateSystemSettingOrientation();
	elseif setting == Enum.EditModeAuraFrameSetting.IconWrap and self:HasSetting(Enum.EditModeAuraFrameSetting.IconWrap) then
		self:UpdateSystemSettingIconWrap();
	elseif setting == Enum.EditModeAuraFrameSetting.IconDirection and self:HasSetting(Enum.EditModeAuraFrameSetting.IconDirection) then
		self:UpdateSystemSettingIconDirection();
	elseif (setting == Enum.EditModeAuraFrameSetting.IconLimitBuffFrame and self:HasSetting(Enum.EditModeAuraFrameSetting.IconLimitBuffFrame))
		or (setting == Enum.EditModeAuraFrameSetting.IconLimitDebuffFrame and self:HasSetting(Enum.EditModeAuraFrameSetting.IconLimitDebuffFrame)) then
		self:UpdateSystemSettingIconLimit();
	elseif setting == Enum.EditModeAuraFrameSetting.IconSize and self:HasSetting(Enum.EditModeAuraFrameSetting.IconSize) then
		self:UpdateSystemSettingIconSize();
	elseif setting == Enum.EditModeAuraFrameSetting.IconPadding and self:HasSetting(Enum.EditModeAuraFrameSetting.IconPadding) then
		self:UpdateSystemSettingIconPadding();
	elseif setting == Enum.EditModeAuraFrameSetting.ShowFull and self:HasSetting(Enum.EditModeAuraFrameSetting.ShowFull) then
		self:UpdateSystemSettingShowFull();
	end

	if not entireSystemUpdate then
		self:RefreshAuraButtons();
		self:UpdateGridLayout();
	end

	self:ClearDirtySetting(setting);
end

EditModeTalkingHeadFrameSystemMixin = {};

function EditModeTalkingHeadFrameSystemMixin:OnSystemLoad()
	EditModeSystemMixin.OnSystemLoad(self);

	-- Gotta call this ourselves since talking head is loaded in as needed on the fly so it won't be setup yet
	EditModeManagerFrame:UpdateSystem(self);
end

function EditModeTalkingHeadFrameSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateShownState();
end

EditModeChatFrameSystemMixin = {};

function EditModeChatFrameSystemMixin:OnEditModeEnter()
	EditModeSystemMixin.OnEditModeEnter(self);

	FCF_SelectDockFrame(self);
	FCF_SetLocked(self, false);

	self.EditModeResizeButton:Show();
end

function EditModeChatFrameSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	FCF_SetLocked(self, true);

	self.EditModeResizeButton:Hide();
end

function EditModeChatFrameSystemMixin:EditMode_OnResized()
	local width = self:GetWidth();
	local height = self:GetHeight();

	EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeChatFrameSetting.WidthHundreds, math.floor(width / 100));
	EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeChatFrameSetting.WidthTensAndOnes, math.floor(width % 100));
	EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeChatFrameSetting.HeightHundreds, math.floor(height / 100));
	EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeChatFrameSetting.HeightTensAndOnes, math.floor(height % 100));
end

function EditModeChatFrameSystemMixin:UpdateSystemSettingSize()
	local useRawValueYes = true;

	local width;
	if self:HasSetting(Enum.EditModeChatFrameSetting.WidthHundreds) and self:HasSetting(Enum.EditModeChatFrameSetting.WidthTensAndOnes) then
		local widthHundreds = self:GetSettingValue(Enum.EditModeChatFrameSetting.WidthHundreds, useRawValueYes);
		local widthTensAndOnes = self:GetSettingValue(Enum.EditModeChatFrameSetting.WidthTensAndOnes, useRawValueYes);
		width = (widthHundreds * 100) + widthTensAndOnes;
	else
		width = self:GetWidth();
	end

	local height;
	if self:HasSetting(Enum.EditModeChatFrameSetting.HeightHundreds) and self:HasSetting(Enum.EditModeChatFrameSetting.HeightTensAndOnes) then
		local heightHundreds = self:GetSettingValue(Enum.EditModeChatFrameSetting.HeightHundreds, useRawValueYes);
		local heightTensAndOnes = self:GetSettingValue(Enum.EditModeChatFrameSetting.HeightTensAndOnes, useRawValueYes);
		height = (heightHundreds * 100) + heightTensAndOnes;
	else
		height = self:GetHeight();
	end

	self:SetSize(width, height);
end

function EditModeChatFrameSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if (setting == Enum.EditModeChatFrameSetting.WidthHundreds
		or setting == Enum.EditModeChatFrameSetting.WidthTensAndOnes
		or setting == Enum.EditModeChatFrameSetting.HeightHundreds
		or setting == Enum.EditModeChatFrameSetting.HeightTensAndOnes)
		then
		self:UpdateSystemSettingSize();
	end

	self:ClearDirtySetting(setting);
end

EditModeChatFrameResizeButtonMixin = {};

function EditModeChatFrameResizeButtonMixin:OnMouseDown()
	self:SetButtonState("PUSHED", true);
	self:GetHighlightTexture():Hide();

	local chatFrame = self:GetParent();
	chatFrame:StartSizing("BOTTOMRIGHT");
end

function EditModeChatFrameResizeButtonMixin:OnMouseUp()
	self:SetButtonState("NORMAL", false);
	self:GetHighlightTexture():Show();

	local chatFrame = self:GetParent();
	chatFrame:StopMovingOrSizing();
	chatFrame:EditMode_OnResized();
end

EditModeVehicleLeaveButtonSystemMixin = {};

function EditModeVehicleLeaveButtonSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateShownState();
end

function EditModeVehicleLeaveButtonSystemMixin:GetBottomAnchoredHeight()
	if self:IsShown() and self:IsInDefaultPosition() then
		return self:GetHeight() + self.systemInfo.anchorInfo.offsetY;
	end

	return 0;
end

function EditModeVehicleLeaveButtonSystemMixin:EditModeVehicleLeaveButtonSystem_OnShow()
    EditModeManagerFrame:UpdateActionBarLayout(self);
end

function EditModeVehicleLeaveButtonSystemMixin:EditModeVehicleLeaveButtonSystem_OnHide()
    EditModeManagerFrame:UpdateActionBarLayout(self);
end

EditModeLootFrameSystemMixin = {};

function EditModeLootFrameSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateShownState();
end

function EditModeLootFrameSystemMixin:OnDragStart()
	self.editModeManuallyShown = true;
	EditModeSystemMixin.OnDragStart(self);
end

function EditModeLootFrameSystemMixin:ApplySystemAnchor()
	EditModeSystemMixin.ApplySystemAnchor(self);

	-- If we aren't in the default position then we'll want the frame to call it's regular visibility methods rather than UI Panel ones
	-- This is so that if it is in the default position it will be treated as a UI panel and things can push around but if it's got a custom position then it won't be treated like a UI Panel
	self.editModeManuallyShown = not self:IsInDefaultPosition();
end

EditModeObjectiveTrackerSystemMixin = {};

function EditModeObjectiveTrackerSystemMixin:OnEditModeEnter()
	EditModeSystemMixin.OnEditModeEnter(self);

	self.wascollapsedOnEditModeEnter = self.collapsed;
	if self.collapsed then
		ObjectiveTracker_Expand();
	end
end

function EditModeObjectiveTrackerSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	if self.wascollapsedOnEditModeEnter and not self.collapsed then
		ObjectiveTracker_Collapse();
	end
end

function EditModeObjectiveTrackerSystemMixin:OnDragStop()
	EditModeSystemMixin.OnDragStop(self);

	ObjectiveTracker_UpdateHeight();
end

function EditModeObjectiveTrackerSystemMixin:AnchorSelectionFrame()
	self.Selection:ClearAllPoints();
	self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", -30, 0);
	self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
end

function EditModeObjectiveTrackerSystemMixin:ResetToDefaultPosition()
	EditModeSystemMixin.ResetToDefaultPosition(self);
	ObjectiveTracker_UpdateHeight();
end

function EditModeObjectiveTrackerSystemMixin:ShouldShowSetting(setting)
	if not EditModeSystemMixin.ShouldShowSetting(self, setting) then
		return false;
	end

	if setting == Enum.EditModeObjectiveTrackerSetting.Height then
		return not self:IsInDefaultPosition();
	end

	return true;
end

function EditModeObjectiveTrackerSystemMixin:UpdateSystemSettingHeight()
	self.editModeHeight = self:GetSettingValue(Enum.EditModeObjectiveTrackerSetting.Height);
	ObjectiveTracker_UpdateHeight();
end

function EditModeObjectiveTrackerSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeObjectiveTrackerSetting.Height and self:HasSetting(Enum.EditModeObjectiveTrackerSetting.Height) then
		self:UpdateSystemSettingHeight();
	end

	self:ClearDirtySetting(setting);
end

function EditModeObjectiveTrackerSystemMixin:ApplySystemAnchor()
	EditModeSystemMixin.ApplySystemAnchor(self);

	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MOVED);
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

EditModeSystemSelectionDoubleLabelMixin = {};

function EditModeSystemSelectionDoubleLabelMixin:SetLabelText(text)
	self.HorizontalLabel:SetText(text);
	self.VerticalLabel:SetText(text);
end

function EditModeSystemSelectionDoubleLabelMixin:SetVerticalState(vertical)
	self.isVertical = vertical;
	self:UpdateLabelVisibility();
end

function EditModeSystemSelectionDoubleLabelMixin:UpdateLabelVisibility()
	self.HorizontalLabel:SetShown(self.isSelected and not self.isVertical);
	self.VerticalLabel:SetShown(self.isSelected and self.isVertical);
end
