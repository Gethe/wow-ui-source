EditModeSystemMixin = {};

function EditModeSystemMixin:OnSystemLoad()
	if not self.system then
		-- All systems must have self.system set on them
		return;
	end

	-- Override set scale so we can keep systems in place as their scale changes
	self.SetScaleBase = self.SetScale;
	self.SetScale = self.SetScaleOverride;

	self.SetPointBase = self.SetPoint;
	self.SetPoint = self.SetPointOverride;

	self.ClearAllPointsBase = self.ClearAllPoints;
	self.ClearAllPoints = self.ClearAllPointsOverride;

	self:SetupVisibilityFunctionOverrides();

	EditModeManagerFrame:RegisterSystemFrame(self);

	self:SetupSettingsDialogAnchor();
	self.snappedFrames = {};
	self.downKeys = {};

	self.settingDisplayInfoMap = EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfoMap(self.system);

	self.Selection:SetSystem(self);
end

function EditModeSystemMixin:SetupVisibilityFunctionOverrides()
	self.SetShownBase = self.SetShown;
	self.SetShown = self.SetShownOverride;
	self.HideBase = self.Hide;
	self.Hide = self.HideOverride;
end

function EditModeSystemMixin:OnSystemHide()
	if self.isSelected then
		EditModeManagerFrame:ClearSelectedSystem();
	end

	if self.isManagedFrame then
		UIParentManagedFrameMixin.OnHide(self);
	end
end

function EditModeSystemMixin:ProcessMovementKey(key)
	if not self:CanBeMoved() then
		return;
	end

	local deltaAmount = self:IsShiftKeyDown() and 10 or 1;
	local xDelta, yDelta = 0, 0;
	if key == "UP" then
		yDelta = deltaAmount;
	elseif key == "DOWN" then
		yDelta = -deltaAmount;
	elseif key == "LEFT" then
		xDelta = -deltaAmount;
	elseif key == "RIGHT" then
		xDelta = deltaAmount;
	end

	if self.isManagedFrame and self:IsInDefaultPosition() then
		self:BreakFromFrameManager();
	end

	if self == PlayerCastingBarFrame then
		EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeCastBarSetting.LockToPlayerFrame, 0);
	end

	self:ClearFrameSnap();

	self:StopMovingOrSizing();
	self:BreakFrameSnap(xDelta, yDelta);
end

local movementKeys = {
	UP = true,
	DOWN = true,
	LEFT = true,
	RIGHT = true,
};

function EditModeSystemMixin:OnKeyDown(key)
	self.downKeys[key] = true;
	if movementKeys[key] then
		self:ProcessMovementKey(key);
	end

end

function EditModeSystemMixin:OnKeyUp(key)
	self.downKeys[key] = false;
end

function EditModeSystemMixin:ClearDownKeys()
	self.downKeys = {};
end

function EditModeSystemMixin:IsShiftKeyDown()
	return self.downKeys["LSHIFT"] or self.downKeys["RSHIFT"];
end

function EditModeSystemMixin:PrepareForSave()
	if self.breakSnappedFramesOnSave then
		self:BreakSnappedFrames();
	end

	if not self:IsInDefaultPosition() and (self.alwaysUseTopLeftAnchor or self.alwaysUseTopRightAnchor) then
		self:BreakFrameSnap();
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

	if self.isManagedFrame and self:IsInDefaultPosition() then
		UIParent_ManageFramePositions();

		if self.isRightManagedFrame and ObjectiveTrackerFrame and ObjectiveTrackerFrame:IsInDefaultPosition() then
			ObjectiveTrackerFrame:Update();
		end
	end
end

function EditModeSystemMixin:SetPointOverride(point, relativeTo, relativePoint, offsetX, offsetY)
	self:SetPointBase(point, relativeTo, relativePoint, offsetX, offsetY);
	self:SetSnappedToFrame(relativeTo);
	EditModeManagerFrame:OnEditModeSystemAnchorChanged();
end

function EditModeSystemMixin:ClearAllPointsOverride()
	self:ClearAllPointsBase();
	self:ClearFrameSnap();
end

function EditModeSystemMixin:HideOverride()
	if self:ShouldBreakSnappedFramesOnHide() then
		self:BreakSnappedFrames();
	end

	return self:HideBase();
end

function EditModeSystemMixin:SetShownOverride(shown)
	if shown then
		return self:Show();
	else
		return self:Hide();
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

function EditModeSystemMixin:MarkAllSettingsDirty()
	self.settingMap = nil;
end

function EditModeSystemMixin:IsSettingDirty(setting)
	return self.dirtySettings[setting];
end

function EditModeSystemMixin:ClearDirtySetting(setting)
	self.dirtySettings[setting] = nil;
end

function EditModeSystemMixin:AnySettingsDirty()
	for _, setting in pairs(self.dirtySettings) do
		if setting ~= nil then
			return true;
		end
	end
	return false;
end

function EditModeSystemMixin:TrySetCompositeNumberSettingValue(setting, newValue)
	local settingDisplayInfo = self.settingDisplayInfoMap[setting];
	if not settingDisplayInfo or not settingDisplayInfo.isCompositeNumberSetting then
		return false;
	end

	-- Composite number settings are settings which represent multiple other hidden settings which combine to form the one main setting's number
	-- So when we change the main setting we actually want to be changing each of the sub settings which make up that number
	local useRawValueYes = true;
	local rawOldValue = self:GetSettingValue(setting, useRawValueYes);
	local rawNewValue = self:ConvertSettingDisplayValueToRawValue(setting, newValue);
	if rawOldValue ~= rawNewValue then
		local hundredsValue = math.floor(newValue / 100);
		EditModeManagerFrame:OnSystemSettingChange(self, settingDisplayInfo.compositeNumberHundredsSetting, hundredsValue);

		local tensAndOnesValue = math.floor(newValue % 100);
		EditModeManagerFrame:OnSystemSettingChange(self, settingDisplayInfo.compositeNumberTensAndOnesSetting, tensAndOnesValue);
	end
	return true;
end

function EditModeSystemMixin:UpdateSystemSettingValue(setting, newValue)
	if not self:IsInitialized() then
		return;
	end

	if self:TrySetCompositeNumberSettingValue(setting, newValue) then
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

function EditModeSystemMixin:AreAllSystemSettingsDefault()
	local defaultSystemInfo = EditModePresetLayoutManager:GetAllDefaultSettingsForSystem(self.system, self.systemIndex);

	for setting, defaultValue in pairs(defaultSystemInfo) do
		local myValue = self:GetSettingValue(setting, true);
		if (defaultValue ~= myValue) then
			return false;
		end
	end

	return true;
end

function EditModeSystemMixin:IsSystemSettingDefault(systemSetting)
	local defaultSystemValue = EditModePresetLayoutManager:GetDefaultSettingForSystem(self.system, self.systemIndex, systemSetting);
	if (defaultSystemValue ~= nil) then
		return defaultSystemValue == self:GetSettingValue(systemSetting, true);
	end

	return false;
end

function EditModeSystemMixin:ResetToDefaultPosition()
	self.systemInfo.anchorInfo = EditModePresetLayoutManager:GetDefaultSystemAnchorInfo(self.system, self.systemIndex);
	self.systemInfo.anchorInfo2 = nil;
	self.systemInfo.isInDefaultPosition = true;
	self:BreakSnappedFrames();
	self:ApplySystemAnchor();
	EditModeSystemSettingsDialog:UpdateDialog(self);
	self:SetHasActiveChanges(true);
end

function EditModeSystemMixin:GetManagedFrameContainer()
	if not self.isManagedFrame then
		return nil;
	end

	if self.isBottomManagedFrame then
		return UIParentBottomManagedFrameContainer;
	elseif self.isRightManagedFrame then
		return UIParentRightManagedFrameContainer;
	else
		return PlayerFrameBottomManagedFramesContainer;
	end
end

function EditModeSystemMixin:BreakFromFrameManager()
	local frameContainer = self:GetManagedFrameContainer();
	if not frameContainer then
		return;
	end

	self.ignoreFramePositionManager = true;
	frameContainer:RemoveManagedFrame(self);
	self:SetParent(UIParent);

	if self.isPlayerFrameBottomManagedFrame then
		self:UpdateSystemSettingFrameSize();
	end
end

function EditModeSystemMixin:ApplySystemAnchor()
	local frameContainer = self:GetManagedFrameContainer();

	if frameContainer then
		if self:IsInDefaultPosition() then
			self.ignoreFramePositionManager = nil;
			frameContainer:AddManagedFrame(self);

			if self.isPlayerFrameBottomManagedFrame then
				self:UpdateSystemSettingFrameSize();
			end
			return;
		end

		self:BreakFromFrameManager();
	end

	self:ClearAllPoints();

	if self:IsInDefaultPosition() and (EditModeUtil:IsRightAnchoredActionBar(self) or EditModeUtil:IsBottomAnchoredActionBar(self)) then
		-- If this is a right or bottom anchored action bar in default position let UpdateActionBarLayout handle all anchoring
		self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
	else
		-- Make sure offsets are relative to our current scale
		local scale = self:GetScale();
		self:SetPoint(self.systemInfo.anchorInfo.point, self.systemInfo.anchorInfo.relativeTo, self.systemInfo.anchorInfo.relativePoint, self.systemInfo.anchorInfo.offsetX / scale, self.systemInfo.anchorInfo.offsetY / scale);

		if self.systemInfo.anchorInfo2 then
			self:SetPoint(self.systemInfo.anchorInfo2.point, self.systemInfo.anchorInfo2.relativeTo, self.systemInfo.anchorInfo2.relativePoint, self.systemInfo.anchorInfo2.offsetX / scale, self.systemInfo.anchorInfo2.offsetY / scale);
		end
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

	local anySettingsDirty = self:AnySettingsDirty();

	local entireSystemUpdate = true;
	for _, settingInfo in ipairs(systemInfo.settings) do
		self:UpdateSystemSetting(settingInfo.setting, entireSystemUpdate);
	end

	self:OnUpdateSystem(anySettingsDirty);
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

-- Override in derived mixins that need to know when a system update occurs.
function EditModeSystemMixin:OnUpdateSystem(anySettingsDirty)

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

function EditModeSystemMixin:HasCompositeNumberSetting(setting)
	local settingDisplayInfo = self.settingDisplayInfoMap[setting];
	if not settingDisplayInfo or not settingDisplayInfo.isCompositeNumberSetting then
		return nil;
	end

	-- Composite number settings are settings which represent multiple other hidden settings which combine to form the one main setting's number
	-- So if we want to know if a composite number setting exists we actually want to be checking if all the sub settings which make up the number exist
	return self:HasSetting(settingDisplayInfo.compositeNumberHundredsSetting)
		and self:HasSetting(settingDisplayInfo.compositeNumberTensAndOnesSetting);
end

function EditModeSystemMixin:HasSetting(setting)
	local hasCompositeNumberSetting = self:HasCompositeNumberSetting(setting);
	if hasCompositeNumberSetting ~= nil then
		return hasCompositeNumberSetting;
	end

	return self.settingMap and (self.settingMap[setting] ~= nil);
end

function EditModeSystemMixin:GetCompositeNumberSettingValue(setting, useRawValue)
	local settingDisplayInfo = self.settingDisplayInfoMap[setting];
	if not settingDisplayInfo or not settingDisplayInfo.isCompositeNumberSetting then
		return nil;
	end

	-- Composite number settings are settings which represent multiple other hidden settings which combine to form the one main setting's number
	-- So if we want to get the setting's value we need to get the sub settings values and combine them to form the main setting's number
	local hundreds = self:GetSettingValue(settingDisplayInfo.compositeNumberHundredsSetting, useRawValue) or 0;
	local tensAndOnes = self:GetSettingValue(settingDisplayInfo.compositeNumberTensAndOnesSetting, useRawValue) or 0;
	return math.floor((hundreds * 100) + tensAndOnes);
end

function EditModeSystemMixin:GetSettingValue(setting, useRawValue)
	if not self:IsInitialized() then
		return 0;
	end

	if not self:HasSetting(setting) then
		return 0;
	end

	local compositeNumberValue = self:GetCompositeNumberSettingValue(setting, useRawValue);
	if compositeNumberValue ~= nil then
		return compositeNumberValue;
	end

	if useRawValue then
		return self.settingMap[setting].value;
	else
		return self.settingMap[setting].displayValue or self.settingMap[setting].value;
	end
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

function EditModeSystemMixin:GetLeftOffset()
	return select(4, self.Selection:GetPoint(1)) - SELECTION_PADDING;
end
function EditModeSystemMixin:GetRightOffset()
	return select(4, self.Selection:GetPoint(2)) + SELECTION_PADDING;
end
function EditModeSystemMixin:GetTopOffset()
	return select(5, self.Selection:GetPoint(1)) + SELECTION_PADDING;
end
function EditModeSystemMixin:GetBottomOffset()
	return select(5, self.Selection:GetPoint(2)) - SELECTION_PADDING;
end

function EditModeSystemMixin:GetSelectionOffset(point, forYOffset)
	local offset;
	if point == "LEFT" then
		offset = self:GetLeftOffset();
	elseif point == "RIGHT" then
		offset = self:GetRightOffset();
	elseif point == "TOP" then
		offset = self:GetTopOffset();
	elseif point == "BOTTOM" then
		offset = self:GetBottomOffset();
	elseif point == "TOPLEFT" then
		offset = forYOffset and self:GetTopOffset() or self:GetLeftOffset();
	elseif point == "TOPRIGHT" then
		offset = forYOffset and self:GetTopOffset() or self:GetRightOffset();
	elseif point == "BOTTOMLEFT" then
		offset = forYOffset and self:GetBottomOffset() or self:GetLeftOffset();
	elseif point == "BOTTOMRIGHT" then
		offset = forYOffset and self:GetBottomOffset() or self:GetRightOffset();
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
	local forYOffsetNo = false;
	local forYOffsetYes = true;
	local offsetX, offsetY;
	if frameInfo.isCornerSnap then
		offsetX = self:GetCombinedSelectionOffset(frameInfo, forYOffsetNo);
		offsetY = self:GetCombinedSelectionOffset(frameInfo, forYOffsetYes);
	else
		offsetX, offsetY = self:GetCombinedCenterOffset(frameInfo.frame);
		if frameInfo.isHorizontal then
			offsetX = self:GetCombinedSelectionOffset(frameInfo, forYOffsetNo);
		else
			offsetY = self:GetCombinedSelectionOffset(frameInfo, forYOffsetYes);
		end
	end

	return offsetX, offsetY;
end

function EditModeSystemMixin:AddSnappedFrame(frame)
	self.snappedFrames[frame] = true;
end

function EditModeSystemMixin:RemoveSnappedFrame(frame)
	self.snappedFrames[frame] = nil;
end

function EditModeSystemMixin:BreakSnappedFrames()
	for snappedFrame in pairs(self.snappedFrames) do
		snappedFrame:BreakFrameSnap();
	end
end

function EditModeSystemMixin:ShouldBreakSnappedFramesOnHide()
	-- Override as necessary, LayoutFrames (automatically sized frames) will typically need to do this
	return self.IsLayoutFrame and self:IsLayoutFrame();
end

function EditModeSystemMixin:SetSnappedToFrame(frame)
	if type(frame) == "string" then
		frame = _G[frame];
	end

	if frame and type(frame) == "table" and frame.AddSnappedFrame then
		frame:AddSnappedFrame(self);
		self.snappedToFrame = frame;
	end
end

function EditModeSystemMixin:ClearFrameSnap()
	if self.snappedToFrame then
		self.snappedToFrame:RemoveSnappedFrame(self);
		self.snappedToFrame = nil;
	end
end

function EditModeSystemMixin:BreakFrameSnap(deltaX, deltaY)
	local top = self:GetTop();
	if top then
		local scale = self:GetScale();
		local offsetY = -((UIParent:GetHeight() - top * scale) / scale);

		local offsetX, anchorPoint;
		if self.alwaysUseTopRightAnchor then
			offsetX = -((UIParent:GetWidth() - self:GetRight() * scale) / scale);
			anchorPoint = "TOPRIGHT";
		else
			offsetX = self:GetLeft();
			anchorPoint = "TOPLEFT";
		end

		if deltaX then
			offsetX = offsetX + deltaX;
		end

		if deltaY then
			offsetY = offsetY + deltaY;
		end

		self:ClearAllPoints();
		self:SetPoint(anchorPoint, UIParent, anchorPoint, offsetX, offsetY);
		self:OnSystemPositionChange();
	end
end

function EditModeSystemMixin:SnapToFrame(frameInfo)
	local offsetX, offsetY = self:GetSnapOffsets(frameInfo);

	-- ClearAllPoints after GetSnapOffsets since it uses the existing rect to calculate the offset
	self:ClearAllPoints();
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
	if self.isDragging then
		self:OnDragStop();
	end

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

function EditModeSystemMixin:SetSelectionShown(shown)
	self.Selection:SetShown(shown);
end

function EditModeSystemMixin:ShowEditInstructions(shown)
	self.Selection:ShowEditInstructions(shown);
end

function EditModeSystemMixin:OnEditModeEnter()
	if not self.defaultHideSelection then
		self:HighlightSystem();
	end
end

function EditModeSystemMixin:OnEditModeExit()
	self:ClearHighlight();
	self:StopMovingOrSizing();
	EditModeSystemSettingsDialog:Hide();
end

function EditModeSystemMixin:CanBeMoved()
	return self.isSelected and not self.isLocked;
end

function EditModeSystemMixin:IsInDefaultPosition()
	return self:IsInitialized() and self.systemInfo.isInDefaultPosition;
end

function EditModeSystemMixin:IsEditModeDragging()
	return self.Selection:IsDragging();
end

function EditModeSystemMixin:OnDragStart()
	if self:CanBeMoved() then
		if self.isManagedFrame and self:IsInDefaultPosition() then
			self:BreakFromFrameManager();
		end
		self:ClearFrameSnap();
		self:StartMoving();
		EditModeManagerFrame:SetSnapPreviewFrame(self);
		self.isDragging = true;
	end
end

function EditModeSystemMixin:OnDragStop()
	if self:CanBeMoved() then
		EditModeManagerFrame:ClearSnapPreviewFrame();
		self:StopMovingOrSizing();
		self.isDragging = false;

		if EditModeManagerFrame:IsSnapEnabled() then
			EditModeMagnetismManager:ApplyMagnetism(self);
		end
		self:OnSystemPositionChange();
	end
end

function EditModeSystemMixin:GetSystemName()
	return (self.addSystemIndexToName and self.systemIndex) and self.systemNameString:format(self.systemIndex) or self.systemNameString;
end

function EditModeSystemMixin:OnSystemPositionChange()
	EditModeManagerFrame:OnSystemPositionChange(self);
end

-- Override this as needed to do things after any edit mode system had their anchor changed.
-- Only use this if your logic depends on knowing your system's screen position or cares about the position of whatever your system is anchored to.
function EditModeSystemMixin:OnAnyEditModeSystemAnchorChanged()
end

EditModeActionBarSystemMixin = {};

function EditModeActionBarSystemMixin:UpdateSystem(systemInfo)
	EditModeSystemMixin.UpdateSystem(self, systemInfo);
	self:RefreshGridLayout();
	self:RefreshDividers();
	self:RefreshBarArt();
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

function EditModeActionBarSystemMixin:OnSystemPositionChange()
	EditModeSystemMixin.OnSystemPositionChange(self);

	-- For Classic, bar art can be dependent on the bar's position, so make sure to refresh this.
	self:RefreshBarArt(true);
end

function EditModeActionBarSystemMixin:ApplySystemAnchor()
	EditModeSystemMixin.ApplySystemAnchor(self);

	-- For Classic, bar art can be dependent on the bar's position, so make sure to refresh this.
	self:RefreshBarArt(true);
end


function EditModeActionBarSystemMixin:OnAnyEditModeSystemAnchorChanged()
	EditModeSystemMixin.OnAnyEditModeSystemAnchorChanged(self);

	self:UpdateSpellFlyoutDirection();
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

function EditModeActionBarSystemMixin:MarkDividersDirty()
	self.dividersDirty = true;
end

function EditModeActionBarSystemMixin:RefreshDividers()
	if self.dividersDirty then
		if self.UpdateDividers then
			self:UpdateDividers();
		end

		self.dividersDirty = false;
	end
end

function EditModeActionBarSystemMixin:MarkBarArtDirty()
	self.barArtDirty = true;
end

function EditModeActionBarSystemMixin:RefreshBarArt(force)
	if (self.barArtDirty or force) then
		if self.UpdateEndCaps then
			self:UpdateEndCaps(self.hideBarArt);
		end

		self.barArtDirty = false;
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

	-- Update the dividers since we'll possibly be switching from horizontal to vertical dividers
	self:MarkDividersDirty();

	-- Update our bar art. For Classic in particular, Bar Art can change based on bar settings.
	self:MarkBarArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingNumRows()
	self.numRows = self:GetSettingValue(Enum.EditModeActionBarSetting.NumRows);

	-- Since the num rows changed we'll want to update the grid layout
	self:MarkGridLayoutDirty();

	-- Update the dividers since we hide dividers when num rows > 1
	self:MarkDividersDirty();

	-- Update our bar art. For Classic in particular, Bar Art can change based on bar settings.
	self:MarkBarArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingNumIcons()
	-- We want to allow below-minimum values in Plunderstorm so allow a raw value that's less than minimum.
	local useRawValue = GameRulesUtil.AllowBelowMinimumActionBarIcons();
	self.numButtonsShowable = self:GetSettingValue(Enum.EditModeActionBarSetting.NumIcons, useRawValue);
	self:UpdateShownButtons();

	-- Since the num icons changed we'll want to update the grid layout
	self:MarkGridLayoutDirty();

	-- Update the dividers since we'll need to change what dividers are shown specifically for the new last button
	self:MarkDividersDirty();

	-- Update our bar art. For Classic in particular, Bar Art can change based on bar settings.
	self:MarkBarArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingIconSize()
	local iconSizeSetting = self:GetSettingValue(Enum.EditModeActionBarSetting.IconSize);

	local iconScale = iconSizeSetting / 100;

	if self.EditModeSetScale then
		self:EditModeSetScale(iconScale);
	end

	for i, actionButton in pairs(self.actionButtons) do
		actionButton.container:SetScale(iconScale);
	end

	-- Changing icon size will effect the size of the ResizeLayoutFrame
	self:Layout();

	EditModeManagerFrame:UpdateActionBarLayout(self);

	-- Update our bar art. For Classic in particular, Bar Art can change based on bar settings.
	self:MarkBarArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingIconPadding()
	self.buttonPadding = self:GetSettingValue(Enum.EditModeActionBarSetting.IconPadding);

	-- Since the icon padding changed we'll want to update the grid layout
	self:MarkGridLayoutDirty();

	-- Update dividers since we will hide dividers if padding is changed
	self:MarkDividersDirty();

	-- Update our bar art. For Classic in particular, Bar Art can change based on bar settings.
	self:MarkBarArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingHideBarArt()
	self.hideBarArt = self:GetSettingValueBool(Enum.EditModeActionBarSetting.HideBarArt);

	if (self.BorderArt) then
		self.BorderArt:SetShown(not self.hideBarArt);
	end

	for i, actionButton in pairs(self.actionButtons) do
		actionButton:UpdateButtonArt();
	end

	self:MarkDividersDirty();

	self:MarkBarArtDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSettingHideBarScrolling()
	if(self.ActionBarPageNumber) then
		self.ActionBarPageNumber:SetShown(not self:GetSettingValueBool(Enum.EditModeActionBarSetting.HideBarScrolling));
	end

	-- Update our bar art. For Classic in particular, Bar Art can change based on bar settings.
	self:MarkBarArtDirty();
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

	-- Update dividers since some buttons may have hidden and we show dividers based on buttons shown
	self:MarkDividersDirty();
end

function EditModeActionBarSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if self:HasSetting(setting) then
		if setting == Enum.EditModeActionBarSetting.Orientation then
			self:UpdateSystemSettingOrientation();
		elseif setting == Enum.EditModeActionBarSetting.NumRows then
			self:UpdateSystemSettingNumRows();
		elseif setting == Enum.EditModeActionBarSetting.NumIcons then
			self:UpdateSystemSettingNumIcons();
		elseif setting == Enum.EditModeActionBarSetting.IconSize then
			self:UpdateSystemSettingIconSize();
		elseif setting == Enum.EditModeActionBarSetting.IconPadding then
			self:UpdateSystemSettingIconPadding();
		elseif setting == Enum.EditModeActionBarSetting.HideBarArt then
			self:UpdateSystemSettingHideBarArt();
		elseif setting == Enum.EditModeActionBarSetting.HideBarScrolling then
			self:UpdateSystemSettingHideBarScrolling();
		elseif setting == Enum.EditModeActionBarSetting.VisibleSetting then
			self:UpdateSystemSettingVisibleSetting();
		elseif setting == Enum.EditModeActionBarSetting.AlwaysShowButtons then
			self:UpdateSystemSettingAlwaysShowButtons();
		end
	end

	if not entireSystemUpdate then
		self:RefreshGridLayout();
		self:RefreshDividers();
		self:RefreshBarArt();
	end

	self:ClearDirtySetting(setting);
end

function EditModeActionBarSystemMixin:UseSettingAltName(setting)
	if setting == Enum.EditModeActionBarSetting.NumRows then
		return self:DoesSettingValueEqual(Enum.EditModeActionBarSetting.Orientation, Enum.ActionBarOrientation.Vertical);
	end
	return false;
end

local function EnterQuickKeybindMode()
	EditModeManagerFrame:CheckHideAndLockEditMode();
	QuickKeybindFrame:Show();
end

local function OpenActionBarSettings()
	EditModeManagerFrame:CheckHideAndLockEditMode();
	Settings.OpenToCategory(Settings.ACTION_BAR_CATEGORY_ID);
end

function EditModeActionBarSystemMixin:AddExtraButtons(extraButtonPool)
	EditModeSystemMixin.AddExtraButtons(self, extraButtonPool);

	local quickKeybindModeButton = extraButtonPool:Acquire();
	quickKeybindModeButton.layoutIndex = 4;
	quickKeybindModeButton:SetText(QUICK_KEYBIND_MODE);
	quickKeybindModeButton:SetOnClickHandler(EnterQuickKeybindMode);
	quickKeybindModeButton:Show();

	if self.systemIndex ~= Enum.EditModeActionBarSystemIndices.StanceBar
		and self.systemIndex ~= Enum.EditModeActionBarSystemIndices.PetActionBar
		and self.systemIndex ~= Enum.EditModeActionBarSystemIndices.PossessActionBar then
		local actionBarSettingsButton = extraButtonPool:Acquire();
		actionBarSettingsButton.layoutIndex = 5;
		actionBarSettingsButton:SetText(HUD_EDIT_MODE_ACTION_BAR_SETTINGS);
		actionBarSettingsButton:SetOnClickHandler(OpenActionBarSettings);
		actionBarSettingsButton:Show();
	end

	return true;
end

EditModeUnitFrameSystemMixin = {};

local function OpenRaidFrameSettings()
	EditModeManagerFrame:CheckHideAndLockEditMode();
	Settings.OpenToCategory(Settings.INTERFACE_CATEGORY_ID, RAID_FRAMES_LABEL);
end

function EditModeUnitFrameSystemMixin:AddExtraButtons(extraButtonPool)
	EditModeSystemMixin.AddExtraButtons(self, extraButtonPool);

	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid
		or (self:HasSetting(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames) and self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames)) then
		local raidFrameSettingsButton = extraButtonPool:Acquire();
		raidFrameSettingsButton.layoutIndex = 4;
		raidFrameSettingsButton:SetText(HUD_EDIT_MODE_RAID_FRAME_SETTINGS);
		raidFrameSettingsButton:SetOnClickHandler(OpenRaidFrameSettings);
		raidFrameSettingsButton:Show();
	end

	return true;
end

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
	elseif setting == Enum.EditModeUnitFrameSetting.AuraOrganizationType then
		if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Party then
			return self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames);
		end
	elseif setting == Enum.EditModeUnitFrameSetting.IconSize then
		if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Party then
			return self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames);
		end
	elseif setting == Enum.EditModeUnitFrameSetting.Opacity then
		-- Arena frames not supported for now
		if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Arena then
			return false;
		end

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
		if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Party then
			return self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames);
		else
			return self:UseCombinedGroups();
		end
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
	if self.systemIndex ~= self.lastSystemIndex then
		self.lastSystemIndex = self.systemIndex;

		self.Selection:ClearAllPoints();
		if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Player then
			self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 20, -16);
			self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -20, 18);
		elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Target then
			self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 20, -16);
			self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -20, 18);
		elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Focus then
			self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 20, -16);
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
		elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Pet then
			self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -3);
			self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 6);
		end
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
	elseif self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Pet then
		self.settingsDialogAnchor = AnchorUtil.CreateAnchor("LEFT", UIParent, "LEFT", 250);
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
	CompactPartyFrame:RefreshMembers();
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
	if self.SetCastBarPosition then
		self:SetCastBarPosition(self:GetSettingValueBool(Enum.EditModeUnitFrameSetting.CastBarOnSide));
	end
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingShowCastTime()
	-- TODO
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingViewRaidSize()
	CompactRaidFrameContainer:TryUpdate();
	CompactRaidFrameContainer:Layout();
end

function EditModeUnitFrameSystemMixin:UpdateCompactRaidFrameContainerSetting(...)
	CompactRaidFrameContainer:ApplyMultipleToFrames(...);

	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid then
		EditModeManagerFrame:UpdateRaidContainerFlow();
	else
		PartyFrame:UpdatePaddingAndLayout();
	end
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingFrameWidth()
	self:UpdateCompactRaidFrameContainerSetting(
		"mini", DefaultCompactMiniFrameSetup,
		"normal", CompactUnitFrame_UpdateAll,
		"group", CompactRaidGroup_UpdateBorder
	);
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingFrameHeight()
	self:UpdateCompactRaidFrameContainerSetting(
		"mini", DefaultCompactMiniFrameSetup,
		"normal", CompactUnitFrame_UpdateAll,
		"group", CompactRaidGroup_UpdateBorder
	);
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingDisplayBorder()
	self:UpdateCompactRaidFrameContainerSetting("group", CompactRaidGroup_UpdateBorder);
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingAuraOrganizationType()
	-- New setting, not sure this one is right...
	self:UpdateCompactRaidFrameContainerSetting("normal", CompactUnitFrame_UpdateAll);
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingIconSize()
	-- New setting, not sure this one is right...
	self:UpdateCompactRaidFrameContainerSetting("normal", CompactUnitFrame_UpdateAll);
end

function EditModeUnitFrameSystemMixin:UpdateSystemSettingOpacity()
	if self:ShouldShowSetting(Enum.EditModeUnitFrameSetting.Opacity) then
		local alpha = self:GetSettingValue(Enum.EditModeUnitFrameSetting.Opacity) / 100;
		self:SetAlpha(alpha);
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

	local sortFunc;
	if sortBySettingValue == Enum.SortPlayersBy.Group then
		sortFunc = CRFSort_Group;
	elseif sortBySettingValue == Enum.SortPlayersBy.Alphabetical then
		sortFunc = CRFSort_Alphabetical;
	else
		sortFunc = CRFSort_Role;
	end

	if self.systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid then
		CompactRaidFrameContainer:SetFlowSortFunction(sortFunc);
		EditModeManagerFrame:UpdateRaidContainerFlow();
	else
		CompactPartyFrame:SetFlowSortFunction(sortFunc);
	end
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

function EditModeUnitFrameSystemMixin:UpdateSystemSettingViewArenaSize()
	self:RefreshMembers();
end

function EditModeUnitFrameSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if self:HasSetting(setting) then
		if setting == Enum.EditModeUnitFrameSetting.CastBarUnderneath then
			-- Nothing to do, this setting is mirrored by Enum.EditModeCastBarSetting.LockToPlayerFrame
		elseif setting == Enum.EditModeUnitFrameSetting.BuffsOnTop then
			self:UpdateSystemSettingBuffsOnTop();
		elseif setting == Enum.EditModeUnitFrameSetting.UseLargerFrame then
			self:UpdateSystemSettingUseLargerFrame();
		elseif setting == Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames then
			self:UpdateSystemSettingUseRaidStylePartyFrames();
		elseif setting == Enum.EditModeUnitFrameSetting.ShowPartyFrameBackground then
			self:UpdateSystemSettingShowPartyFrameBackground();
		elseif setting == Enum.EditModeUnitFrameSetting.UseHorizontalGroups then
			self:UpdateSystemSettingUseHorizontalGroups();
		elseif setting == Enum.EditModeUnitFrameSetting.CastBarOnSide then
			self:UpdateSystemSettingCastBarOnSide();
		elseif setting == Enum.EditModeUnitFrameSetting.ShowCastTime then
			self:UpdateSystemSettingShowCastTime();
		elseif setting == Enum.EditModeUnitFrameSetting.ViewRaidSize then
			self:UpdateSystemSettingViewRaidSize();
		elseif setting == Enum.EditModeUnitFrameSetting.FrameWidth then
			self:UpdateSystemSettingFrameWidth();
		elseif setting == Enum.EditModeUnitFrameSetting.FrameHeight then
			self:UpdateSystemSettingFrameHeight();
		elseif setting == Enum.EditModeUnitFrameSetting.DisplayBorder then
			self:UpdateSystemSettingDisplayBorder();
		elseif setting == Enum.EditModeUnitFrameSetting.RaidGroupDisplayType then
			self:UpdateSystemSettingRaidGroupDisplayType();
		elseif setting == Enum.EditModeUnitFrameSetting.SortPlayersBy then
			self:UpdateSystemSettingSortPlayersBy();
		elseif setting == Enum.EditModeUnitFrameSetting.RowSize then
			self:UpdateSystemSettingRowSize();
		elseif setting == Enum.EditModeUnitFrameSetting.FrameSize then
			self:UpdateSystemSettingFrameSize();
		elseif setting == Enum.EditModeUnitFrameSetting.ViewArenaSize then
			self:UpdateSystemSettingViewArenaSize();
		elseif setting == Enum.EditModeUnitFrameSetting.AuraOrganizationType then
			self:UpdateSystemSettingAuraOrganizationType();
		elseif setting == Enum.EditModeUnitFrameSetting.Opacity then
			self:UpdateSystemSettingOpacity();
		elseif setting == Enum.EditModeUnitFrameSetting.IconSize then
			self:UpdateSystemSettingIconSize();
		end
	end

	self:ClearDirtySetting(setting);
end

EditModeBossUnitFrameSystemMixin = {};

function EditModeBossUnitFrameSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateShownState();
end

function EditModeBossUnitFrameSystemMixin:ShouldAnyBossFrameShow()
	for index, bossFrame in ipairs(self.BossTargetFrames) do
		if bossFrame:ShouldShow() then
			return true;
		end
	end

	return false;
end

function EditModeBossUnitFrameSystemMixin:UpdateShownState()
	-- Change the visibility state of the container before the children to allow the container to continue to have a valid rect
	-- during edit mode changes so that snapped frames can be properly repositioned.
	self:SetShown(self.isInEditMode or self:ShouldAnyBossFrameShow());

	for index, bossFrame in ipairs(self.BossTargetFrames) do
		bossFrame:UpdateShownState();
	end

	UIParent_ManageFramePositions();
end

EditModeArenaUnitFrameSystemMixin = {};

local function OpenPvpFrameSettings()
	EditModeManagerFrame:CheckHideAndLockEditMode();
	Settings.OpenToCategory(Settings.INTERFACE_CATEGORY_ID, PVP_FRAMES_LABEL);
end

function EditModeArenaUnitFrameSystemMixin:SetIsInEditMode(isInEditMode)
	self.isInEditMode = isInEditMode;

	for _, memberUnitFrame in ipairs(self.memberUnitFrames) do
		local castingBarFrame = memberUnitFrame.CastingBarFrame;
		if castingBarFrame then
			castingBarFrame.isInEditMode = isInEditMode;
			castingBarFrame:UpdateShownState();
		end

		local ccRemoverFrame = memberUnitFrame.CcRemoverFrame;
		if ccRemoverFrame then
			ccRemoverFrame:SetIsInEditMode(isInEditMode);
		end

		local spellDiminishStatusTray = memberUnitFrame.SpellDiminishStatusTray;
		if spellDiminishStatusTray then
			spellDiminishStatusTray:SetIsInEditMode(isInEditMode);
		end

		local debuffFrame = memberUnitFrame.DebuffFrame;
		if debuffFrame then
			debuffFrame:SetIsInEditMode(isInEditMode);
		end
	end

	self.PreMatchFramesContainer:SetIsInEditMode(isInEditMode);

	self:RefreshMembers();

	if isInEditMode then
		self:HighlightSystem();
	else
		self:ClearHighlight();
	end
end

function EditModeArenaUnitFrameSystemMixin:AddExtraButtons(extraButtonPool)
	EditModeSystemMixin.AddExtraButtons(self, extraButtonPool);

	local raidFrameSettingsButton = extraButtonPool:Acquire();
	raidFrameSettingsButton.layoutIndex = 4;
	raidFrameSettingsButton:SetText(HUD_EDIT_MODE_PVP_FRAME_SETTINGS);
	raidFrameSettingsButton:SetOnClickHandler(OpenPvpFrameSettings);
	raidFrameSettingsButton:Show();

	return true;
end

EditModeMinimapSystemMixin = {};

function EditModeMinimapSystemMixin:UpdateSystemSettingHeaderUnderneath()
	self:SetHeaderUnderneath(self:GetSettingValueBool(Enum.EditModeMinimapSetting.HeaderUnderneath));
	self:Layout();
end

function EditModeMinimapSystemMixin:UpdateSystemSettingRotateMinimap()
	self:SetRotateMinimap(self:GetSettingValueBool(Enum.EditModeMinimapSetting.RotateMinimap));
end

function EditModeMinimapSystemMixin:UpdateSystemSettingSize()
	local scale = self:GetSettingValue(Enum.EditModeMicroMenuSetting.Size) / 100;
	self:SetEditModeScale(scale);

	-- Updating the header will adjust the map's offsets to account for the scale change
	self:UpdateSystemSettingHeaderUnderneath();
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
	elseif setting == Enum.EditModeMinimapSetting.Size and self:HasSetting(Enum.EditModeMinimapSetting.Size) then
		self:UpdateSystemSettingSize();
	end

	self:ClearDirtySetting(setting);
end

EditModeCastBarSystemMixin = {};

function EditModeCastBarSystemMixin:OnDragStart()
	-- If we start dragging then unlock the cast bar from the player frame so it can move
	EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeCastBarSetting.LockToPlayerFrame, 0);

	EditModeSystemMixin.OnDragStart(self);
end

function EditModeCastBarSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateShownState();
end

function EditModeCastBarSystemMixin:ApplySystemAnchor()
	local lockToPlayerFrame = self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame);
	if lockToPlayerFrame then
		PlayerFrame_AttachCastBar();
	else
		PlayerFrame_DetachCastBar();
		EditModeSystemMixin.ApplySystemAnchor(self);
	end
	self:UpdateSystemSettingBarSize();
end

function EditModeCastBarSystemMixin:ResetToDefaultPosition()
	EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeCastBarSetting.LockToPlayerFrame, 0);
	EditModeSystemMixin.ResetToDefaultPosition(self);
end

function EditModeCastBarSystemMixin:ShouldResetSettingsDialogAnchors(oldSelectedSystemFrame)
	return true;
end

function EditModeCastBarSystemMixin:ShouldShowSetting(setting)
	if not EditModeSystemMixin.ShouldShowSetting(self, setting) then
		return false;
	end

	return true;
end

function EditModeCastBarSystemMixin:SetupSettingsDialogAnchor()
	self.settingsDialogAnchor = AnchorUtil.CreateAnchor("LEFT", UIParent, "CENTER", 100);
end

function EditModeCastBarSystemMixin:AnchorSelectionFrame()
	local lockToPlayerFrame = self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame);
	if self.lockedToPlayerFrame ~= lockToPlayerFrame then
		self.lockedToPlayerFrame = lockToPlayerFrame;

		self.Selection:ClearAllPoints();
		local topOffset = self.editModeSelectionTopOffset or 0;
		local bottomOffset = self.editModeSelectionBottomOffset or 0;
		if lockToPlayerFrame then
			self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", -20, topOffset);
			self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, bottomOffset);
		else
			self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 0, topOffset);
			self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, bottomOffset);
		end
	end

	self:UpdateClampOffsets();
end

function EditModeCastBarSystemMixin:UpdateSystemSettingLockToPlayerFrame()
	local lockToPlayerFrame = self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame);
	if lockToPlayerFrame then
		PlayerFrame_AttachCastBar();
		self:UpdateSystemSettingBarSize();
		self:OnSystemPositionChange();
	elseif not self:IsInDefaultPosition() and self.attachedToPlayerFrame then
		-- If we aren't locked to the player frame and we aren't in our default position then
		-- try to detach from the player frame and break any connections.
		-- Only do this when not in our default position since our default position is in the UIParent bottom layout frame
		-- which we would not want to unparent from
		self:SetParent(UIParent);
		self:UpdateSystemSettingBarSize();
		PlayerFrame_DetachCastBar();
		self:BreakFrameSnap();
	end
end

function EditModeCastBarSystemMixin:UpdateSystemSettingShowCastTime()
	local showCastTime = self:GetSettingValueBool(Enum.EditModeCastBarSetting.ShowCastTime);
	self:SetCastTimeTextShown(showCastTime);
end

function EditModeCastBarSystemMixin:UpdateSystemSettingBarSize()
	local barScale = self:GetSettingValue(Enum.EditModeCastBarSetting.BarSize) / 100;

	if self:GetSettingValueBool(Enum.EditModeCastBarSetting.LockToPlayerFrame) then
		-- Counteract player frame scale so only the cast bar's size is taken into account
		self:SetScale(barScale / PlayerFrame:GetScale());
		PlayerFrame_AttachCastBar();
		return;
	end

	self:SetScale(barScale);
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
	elseif setting == Enum.EditModeCastBarSetting.ShowCastTime then
		self:UpdateSystemSettingShowCastTime();
	end

	self:ClearDirtySetting(setting);
end

EditModeEncounterBarSystemMixin = {};

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

function EditModeAuraFrameSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self:SetIsEditing(false);
	self:Update();
end

function EditModeAuraFrameSystemMixin:AnchorSelectionFrame()
	if self.systemIndex == Enum.EditModeAuraFrameSystemIndices.BuffFrame then
		self.Selection:ClearAllPoints();
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -15, 0); -- Cut off Collapse and Expand button to align with Debuff Frame.
	end

	self:UpdateClampOffsets();
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

function EditModeAuraFrameSystemMixin:UpdateSystemSettingOrientation(entireSystemUpdate)
	local isHorizontal = self:DoesSettingValueEqual(Enum.EditModeAuraFrameSetting.Orientation, Enum.AuraFrameOrientation.Horizontal);
	self.AuraContainer.isHorizontal = isHorizontal;

	-- If this is for an entire system update then no need to update icon wrap or direction
	if entireSystemUpdate then
		return;
	end

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
	self.AuraContainer.iconStride = self:GetSettingValue(self:GetIconLimitSettingEnum());
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingIconSize()
	local iconSize = self:GetSettingValue(Enum.EditModeAuraFrameSetting.IconSize);
	self.AuraContainer.iconScale = iconSize / 100;
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingIconPadding()
	self.AuraContainer.iconPadding = self:GetSettingValue(Enum.EditModeAuraFrameSetting.IconPadding);
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingVisibleSetting()
	self.visibleSetting = self:GetSettingValue(Enum.EditModeAuraFrameSetting.VisibleSetting);
	self:UpdateShownState();
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingOpacity()
	local opacitySetting = self:GetSettingValue(Enum.EditModeAuraFrameSetting.Opacity);
	self:SetAlpha(opacitySetting / 100);
end

function EditModeAuraFrameSystemMixin:UpdateSystemSettingShowDispelType()
	self.AuraContainer.showDispelType = self:GetSettingValueBool(Enum.EditModeAuraFrameSetting.ShowDispelType);
	C_UnitAuras.TriggerPrivateAuraShowDispelType(self.AuraContainer.showDispelType);
end

function EditModeAuraFrameSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if self:HasSetting(setting) then
		if setting == Enum.EditModeAuraFrameSetting.Orientation then
			self:UpdateSystemSettingOrientation(entireSystemUpdate);
		elseif setting == Enum.EditModeAuraFrameSetting.IconWrap then
			self:UpdateSystemSettingIconWrap();
		elseif setting == Enum.EditModeAuraFrameSetting.IconDirection then
			self:UpdateSystemSettingIconDirection();
		elseif (setting == Enum.EditModeAuraFrameSetting.IconLimitBuffFrame) or (setting == Enum.EditModeAuraFrameSetting.IconLimitDebuffFrame) then
			self:UpdateSystemSettingIconLimit();
		elseif setting == Enum.EditModeAuraFrameSetting.IconSize then
			self:UpdateSystemSettingIconSize();
		elseif setting == Enum.EditModeAuraFrameSetting.IconPadding then
			self:UpdateSystemSettingIconPadding();
		elseif setting == Enum.EditModeAuraFrameSetting.VisibleSetting then
			self:UpdateSystemSettingVisibleSetting();
		elseif setting == Enum.EditModeAuraFrameSetting.Opacity then
			self:UpdateSystemSettingOpacity();
		elseif setting == Enum.EditModeAuraFrameSetting.ShowDispelType then
			self:UpdateSystemSettingShowDispelType();
			self:UpdateAuraButtons();
		end
	end

	if not entireSystemUpdate then
		self:UpdateGridLayout();
	end

	self:ClearDirtySetting(setting);
end

EditModeTalkingHeadFrameSystemMixin = {};

function EditModeTalkingHeadFrameSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateShownState();
end

EditModeChatFrameSystemMixin = {};

function EditModeChatFrameSystemMixin:UpdateSystem(systemInfo)
	EditModeSystemMixin.UpdateSystem(self, systemInfo);
	self:RefreshSystemPosition();
end

function EditModeChatFrameSystemMixin:MarkSystemPositionDirty()
	self.systemPositionDirty = true;
end

function EditModeChatFrameSystemMixin:RefreshSystemPosition()
	if self.systemPositionDirty then
		self:OnSystemPositionChange();
		self.systemPositionDirty = false;
	end
end

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
	local width = math.floor(self:GetWidth());
	local height =  math.floor(self:GetHeight());

	-- Changing the display only width/height settings will in turn cause the hidden width and height settings to be changed (ex. WidthHundreds and WidthTensAndOnes)
	EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeChatFrameDisplayOnlySetting.Width, width);
	EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeChatFrameDisplayOnlySetting.Height, height);
end

function EditModeChatFrameSystemMixin:UpdateSystemSettingWidth()
	local useRawValueYes = true;

	local width;
	if self:HasSetting(Enum.EditModeChatFrameSetting.WidthHundreds) and self:HasSetting(Enum.EditModeChatFrameSetting.WidthTensAndOnes) then
		local widthHundreds = self:GetSettingValue(Enum.EditModeChatFrameSetting.WidthHundreds, useRawValueYes);
		local widthTensAndOnes = self:GetSettingValue(Enum.EditModeChatFrameSetting.WidthTensAndOnes, useRawValueYes);
		width = (widthHundreds * 100) + widthTensAndOnes;
	else
		width = self:GetWidth();
	end
	width = math.floor(width);

	self:SetSize(width, self:GetHeight());
	self:MarkSystemPositionDirty();
end

function EditModeChatFrameSystemMixin:UpdateSystemSettingHeight()
	local useRawValueYes = true;

	local height;
	if self:HasSetting(Enum.EditModeChatFrameSetting.HeightHundreds) and self:HasSetting(Enum.EditModeChatFrameSetting.HeightTensAndOnes) then
		local heightHundreds = self:GetSettingValue(Enum.EditModeChatFrameSetting.HeightHundreds, useRawValueYes);
		local heightTensAndOnes = self:GetSettingValue(Enum.EditModeChatFrameSetting.HeightTensAndOnes, useRawValueYes);
		height = (heightHundreds * 100) + heightTensAndOnes;
	else
		height = self:GetHeight();
	end
	height = math.floor(height);

	self:SetSize(self:GetWidth(), height);
	self:MarkSystemPositionDirty();
end

function EditModeChatFrameSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeChatFrameSetting.WidthHundreds and self:HasSetting(Enum.EditModeChatFrameSetting.WidthHundreds) then
		self:UpdateSystemSettingWidth();
	elseif setting == Enum.EditModeChatFrameSetting.WidthTensAndOnes and self:HasSetting(Enum.EditModeChatFrameSetting.WidthTensAndOnes) then
		self:UpdateSystemSettingWidth();
	elseif setting == Enum.EditModeChatFrameSetting.HeightHundreds and self:HasSetting(Enum.EditModeChatFrameSetting.HeightHundreds) then
		self:UpdateSystemSettingHeight();
	elseif setting == Enum.EditModeChatFrameSetting.HeightTensAndOnes and self:HasSetting(Enum.EditModeChatFrameSetting.HeightTensAndOnes) then
		self:UpdateSystemSettingHeight();
	end

	if not entireSystemUpdate then
		self:RefreshSystemPosition();
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
		ObjectiveTrackerFrame:Expand();
	end
end

function EditModeObjectiveTrackerSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	if self.wascollapsedOnEditModeEnter and not self.collapsed then
		ObjectiveTrackerFrame:Collapse();
	end
end

function EditModeObjectiveTrackerSystemMixin:OnDragStop()
	EditModeSystemMixin.OnDragStop(self);

	ObjectiveTrackerFrame:UpdateHeight();
end

function EditModeObjectiveTrackerSystemMixin:AnchorSelectionFrame()
	if not self.selectedAnchored then
		self.selectedAnchored = true;
		self.Selection:ClearAllPoints();
		self.Selection:SetPoint("TOPLEFT", self, "TOPLEFT", -30, 0);
		self.Selection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
	end
end

function EditModeObjectiveTrackerSystemMixin:ResetToDefaultPosition()
	EditModeSystemMixin.ResetToDefaultPosition(self);
	ObjectiveTrackerFrame:UpdateHeight();
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
	ObjectiveTrackerFrame:UpdateHeight();
end

function EditModeObjectiveTrackerSystemMixin:UpdateSystemSettingOpacity()
	ObjectiveTrackerManager:SetOpacity(self:GetSettingValue(Enum.EditModeObjectiveTrackerSetting.Opacity));
end

function EditModeObjectiveTrackerSystemMixin:UpdateSystemSettingTextSize()
	ObjectiveTrackerManager:SetTextSize(self:GetSettingValue(Enum.EditModeObjectiveTrackerSetting.TextSize));
end

function EditModeObjectiveTrackerSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeObjectiveTrackerSetting.Height and self:HasSetting(Enum.EditModeObjectiveTrackerSetting.Height) then
		self:UpdateSystemSettingHeight();
	elseif setting == Enum.EditModeObjectiveTrackerSetting.Opacity and self:HasSetting(Enum.EditModeObjectiveTrackerSetting.Opacity) then
		self:UpdateSystemSettingOpacity();
	elseif setting == Enum.EditModeObjectiveTrackerSetting.TextSize and self:HasSetting(Enum.EditModeObjectiveTrackerSetting.TextSize) then
		self:UpdateSystemSettingTextSize();
	end

	self:ClearDirtySetting(setting);
end

function EditModeObjectiveTrackerSystemMixin:OnAnyEditModeSystemAnchorChanged()
	EditModeSystemMixin.OnAnyEditModeSystemAnchorChanged(self);

	ObjectiveTrackerFrame:Update(OBJECTIVE_TRACKER_UPDATE_MOVED);
end

EditModeMicroMenuSystemMixin = {};

function EditModeMicroMenuSystemMixin:OnEditModeEnter()
	EditModeSystemMixin.OnEditModeEnter(self);

	-- Update queue status frame so it can show the lfg eye while in edit mode since it is editable via the micro menu in edit mode
	QueueStatusFrame:Update();
end

function EditModeMicroMenuSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	QueueStatusFrame:Update();
end

function EditModeMicroMenuSystemMixin:OnAnyEditModeSystemAnchorChanged()
	EditModeSystemMixin.OnAnyEditModeSystemAnchorChanged(self);

	self:Layout();
end

function EditModeMicroMenuSystemMixin:OnDragStop()
	EditModeSystemMixin.OnDragStop(self);

	self:Layout();
end

function EditModeMicroMenuSystemMixin:UpdateSystem(systemInfo)
	EditModeSystemMixin.UpdateSystem(self, systemInfo);
	self:Layout();
end

function EditModeMicroMenuSystemMixin:UpdateSystemSettingOrientation()
	MicroMenu.isHorizontal = self:DoesSettingValueEqual(Enum.EditModeMicroMenuSetting.Orientation, Enum.MicroMenuOrientation.Horizontal);
end

function EditModeMicroMenuSystemMixin:UpdateSystemSettingOrder()
	MicroMenu.layoutFramesGoingRight = self:DoesSettingValueEqual(Enum.EditModeMicroMenuSetting.Order, Enum.MicroMenuOrder.Default);
	MicroMenu.layoutFramesGoingUp = not self:DoesSettingValueEqual(Enum.EditModeMicroMenuSetting.Order, Enum.MicroMenuOrder.Default);
end

function EditModeMicroMenuSystemMixin:UpdateSystemSettingSize()
	MicroMenu:SetNormalScale(self:GetSettingValue(Enum.EditModeMicroMenuSetting.Size) / 100);
end

function EditModeMicroMenuSystemMixin:UpdateSystemSettingEyeSize()
	MicroMenu:SetQueueStatusScale(self:GetSettingValue(Enum.EditModeMicroMenuSetting.EyeSize) / 100);
end

function EditModeMicroMenuSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeMicroMenuSetting.Orientation and self:HasSetting(Enum.EditModeMicroMenuSetting.Orientation) then
		self:UpdateSystemSettingOrientation();
	elseif setting == Enum.EditModeMicroMenuSetting.Order and self:HasSetting(Enum.EditModeMicroMenuSetting.Order) then
		self:UpdateSystemSettingOrder();
	elseif setting == Enum.EditModeMicroMenuSetting.Size and self:HasSetting(Enum.EditModeMicroMenuSetting.Size) then
		self:UpdateSystemSettingSize();
	elseif setting == Enum.EditModeMicroMenuSetting.EyeSize and self:HasSetting(Enum.EditModeMicroMenuSetting.EyeSize) then
		self:UpdateSystemSettingEyeSize();
	end

	if not entireSystemUpdate then
		self:Layout();
	end

	self:ClearDirtySetting(setting);
end

EditModeBagsSystemMixin = {};

local bagsDirectionTextTable =
{
	[Enum.BagsOrientation.Horizontal] = {
		HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT,
		HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT,
	};
	[Enum.BagsOrientation.Vertical] = {
		HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP,
		HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_DOWN,
	};
}

function EditModeBagsSystemMixin:UpdateSystem(systemInfo)
	EditModeSystemMixin.UpdateSystem(self, systemInfo);
	self:Layout();
end

function EditModeBagsSystemMixin:UpdateDisplayInfoOptions(displayInfo)
	local updatedDisplayInfo = displayInfo;

	if displayInfo.setting == Enum.EditModeBagsSetting.Direction then
		updatedDisplayInfo = CopyTable(displayInfo);

		local orientation = self:GetSettingValue(Enum.EditModeBagsSetting.Orientation);
		updatedDisplayInfo.options[1].text = bagsDirectionTextTable[orientation][1];
		updatedDisplayInfo.options[2].text = bagsDirectionTextTable[orientation][2];
	end

	return updatedDisplayInfo;
end

function EditModeBagsSystemMixin:UpdateSystemSettingOrientation(entireSystemUpdate)
	self.isHorizontal = self:DoesSettingValueEqual(Enum.EditModeBagsSetting.Orientation, Enum.BagsOrientation.Horizontal);

	-- If this is for an entire system update then no need to update direction
	if entireSystemUpdate then
		return;
	end

	-- Update direction based on new orientation
	local newDirection = self.isHorizontal and Enum.BagsDirection.Left or Enum.BagsDirection.Up;
	EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeBagsSetting.Direction, newDirection);
end

function EditModeBagsSystemMixin:UpdateSystemSettingDirection()
	self.direction = self:GetSettingValue(Enum.EditModeBagsSetting.Direction);
end

function EditModeBagsSystemMixin:UpdateSystemSettingSize()
	self:SetScale(self:GetSettingValue(Enum.EditModeBagsSetting.Size) / 100);
end

function EditModeBagsSystemMixin:UpdateSystemSettingBagSlotPadding()
	self.bagPadding = self:GetSettingValue(Enum.EditModeBagsSetting.BagSlotPadding);
end

function EditModeBagsSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeBagsSetting.Orientation and self:HasSetting(Enum.EditModeBagsSetting.Orientation) then
		self:UpdateSystemSettingOrientation(entireSystemUpdate);
	elseif setting == Enum.EditModeBagsSetting.Direction and self:HasSetting(Enum.EditModeBagsSetting.Direction) then
		self:UpdateSystemSettingDirection();
	elseif setting == Enum.EditModeBagsSetting.Size and self:HasSetting(Enum.EditModeBagsSetting.Size) then
		self:UpdateSystemSettingSize();
	elseif setting == Enum.EditModeBagsSetting.BagSlotPadding and self:HasSetting(Enum.EditModeBagsSetting.BagSlotPadding) then
		self:UpdateSystemSettingBagSlotPadding();
	end

	if not entireSystemUpdate then
		self:Layout();
	end

	self:ClearDirtySetting(setting);
end

EditModeStatusTrackingBarSystemMixin = {};

function EditModeStatusTrackingBarSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateShownState();
end

function EditModeStatusTrackingBarSystemMixin:OnSystemPositionChange()
	EditModeSystemMixin.OnSystemPositionChange(self);

	StatusTrackingBarManager:UpdateBarVisuals(true);
end

function EditModeStatusTrackingBarSystemMixin:ApplySystemAnchor()
	EditModeSystemMixin.ApplySystemAnchor(self);

	StatusTrackingBarManager:UpdateBarVisuals(true);
end

EditModeStatusTrackingBar1SystemMixin = {};

function EditModeStatusTrackingBar1SystemMixin:OnEditModeEnter()
	EditModeSystemMixin.OnEditModeEnter(self);

	self.isInEditMode = true;
	self:UpdateShownState();
end

function EditModeStatusTrackingBar1SystemMixin:GetSystemName()
	local shownBar = self:GetShownBar();
	if shownBar and shownBar.isExpBar then
		self.systemNameString = HUD_EDIT_MODE_EXPERIENCE_BAR_LABEL;
		self.addSystemIndexToName = false;
	else
		self.systemNameString = HUD_EDIT_MODE_STATUS_TRACKING_BAR_LABEL;
		self.addSystemIndexToName = true;
	end

	return EditModeSystemMixin.GetSystemName(self);
end

EditModeDurabilityFrameSystemMixin = {};

function EditModeDurabilityFrameSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateShownState();
end

function EditModeDurabilityFrameSystemMixin:UpdateSystemSettingSize()
	self:SetScale(self:GetSettingValue(Enum.EditModeDurabilityFrameSetting.Size) / 100);
end

function EditModeDurabilityFrameSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeDurabilityFrameSetting.Size and self:HasSetting(Enum.EditModeDurabilityFrameSetting.Size) then
		self:UpdateSystemSettingSize();
	end

	self:ClearDirtySetting(setting);
end

local function UpdatePetFrameScale()
	-- If the pet frame is anchored to the player frame's managed container then we need to counteract the player frame scale's effect on the pet frame
	local petFrameScale = PetFrame:GetSettingValue(Enum.EditModeUnitFrameSetting.FrameSize) / 100;
	petFrameScale = petFrameScale > 0 and petFrameScale or 1;
	if PetFrame:GetParent() == PlayerFrameBottomManagedFramesContainer then
		petFrameScale = petFrameScale / PlayerFrame:GetScale();
	end

	PetFrame:SetScale(petFrameScale);
	PlayerFrameBottomManagedFramesContainer:Layout();
end

EditModePlayerFrameSystemMixin = {};

function EditModePlayerFrameSystemMixin:ApplySystemAnchor()
	EditModeSystemMixin.ApplySystemAnchor(self);

	-- If the player frame moves we should re-apply the casting bar frame's anchor in case it is supposed to be locked to the player frame
	PlayerCastingBarFrame:ApplySystemAnchor();
end

function EditModePlayerFrameSystemMixin:UpdateSystemSettingFrameSize()
	EditModeUnitFrameSystemMixin.UpdateSystemSettingFrameSize(self);

	-- When player frame's size updates we should update the pet frame and cast bar in case they are parented to the player frame
	UpdatePetFrameScale();
	PlayerCastingBarFrame:UpdateSystemSettingBarSize();
end

EditModePetFrameSystemMixin = {};

function EditModePetFrameSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.isInEditMode = false;
	self:UpdateShownState();
end

function EditModePetFrameSystemMixin:UpdateSystemSettingFrameSize()
	UpdatePetFrameScale();
end

EditModeTimerBarsSystemMixin = {};

function EditModeTimerBarsSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self:SetIsInEditMode(false);
end

function EditModeTimerBarsSystemMixin:UpdateSystemSettingSize()
	self:SetScale(self:GetSettingValue(Enum.EditModeTimerBarsSetting.Size) / 100);
end

function EditModeTimerBarsSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeTimerBarsSetting.Size and self:HasSetting(Enum.EditModeTimerBarsSetting.Size) then
		self:UpdateSystemSettingSize();
	end

	self:ClearDirtySetting(setting);
end

EditModeVehicleSeatIndicatorSystemMixin = {};

function EditModeVehicleSeatIndicatorSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self:SetIsInEditMode(false);
end

function EditModeVehicleSeatIndicatorSystemMixin:UpdateSystemSettingSize()
	self:SetScale(self:GetSettingValue(Enum.EditModeVehicleSeatIndicatorSetting.Size) / 100);
end

function EditModeVehicleSeatIndicatorSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeVehicleSeatIndicatorSetting.Size and self:HasSetting(Enum.EditModeVehicleSeatIndicatorSetting.Size) then
		self:UpdateSystemSettingSize();
	end

	self:ClearDirtySetting(setting);
end

EditModeArchaeologyBarSystemMixin = {};

function EditModeArchaeologyBarSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self:SetIsInEditMode(false);
end

function EditModeArchaeologyBarSystemMixin:UpdateSystemSettingSize()
	self:SetScale(self:GetSettingValue(Enum.EditModeArchaeologyBarSetting.Size) / 100);
end

function EditModeArchaeologyBarSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeArchaeologyBarSetting.Size and self:HasSetting(Enum.EditModeArchaeologyBarSetting.Size) then
		self:UpdateSystemSettingSize();
	end

	self:ClearDirtySetting(setting);
end

EditModeCooldownViewerSystemMixin = CreateFromMixins(EditModeSystemMixin);

function EditModeCooldownViewerSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self:SetIsEditing(false);
end

function EditModeCooldownViewerSystemMixin:ShouldShowSetting(setting)
	if not EditModeSystemMixin.ShouldShowSetting(self, setting) then
		return false;
	end

	if self.systemIndex == Enum.EditModeCooldownViewerSystemIndices.Essential then
		if setting == Enum.EditModeCooldownViewerSetting.BarContent
		or setting == Enum.EditModeCooldownViewerSetting.HideWhenInactive then
			return false;
		end
	end

	if self.systemIndex == Enum.EditModeCooldownViewerSystemIndices.Utility then
		if setting == Enum.EditModeCooldownViewerSetting.BarContent
		or setting == Enum.EditModeCooldownViewerSetting.HideWhenInactive then
			return false;
		end
	end

	if self.systemIndex == Enum.EditModeCooldownViewerSystemIndices.BuffIcon then
		if setting == Enum.EditModeCooldownViewerSetting.IconLimit
		or setting == Enum.EditModeCooldownViewerSetting.BarContent then
			return false;
		end
	end

	if self.systemIndex == Enum.EditModeCooldownViewerSystemIndices.BuffBar then
		if setting == Enum.EditModeCooldownViewerSetting.Orientation
		or setting == Enum.EditModeCooldownViewerSetting.IconLimit
		or setting == Enum.EditModeCooldownViewerSetting.IconDirection then
			return false;
		end
	end

	return true;
end

function EditModeCooldownViewerSystemMixin:UpdateDisplayInfoOptions(displayInfo)
	local updatedDisplayInfo = displayInfo;

	if displayInfo.setting == Enum.EditModeCooldownViewerSetting.IconDirection then
		updatedDisplayInfo = CopyTable(displayInfo);

		if self:DoesSettingValueEqual(Enum.EditModeCooldownViewerSetting.Orientation, Enum.CooldownViewerOrientation.Horizontal) then
			updatedDisplayInfo.options[1].text = _G["HUD_EDIT_MODE_SETTING_COOLDOWN_VIEWER_ICON_DIRECTION_LEFT"];
			updatedDisplayInfo.options[2].text = _G["HUD_EDIT_MODE_SETTING_COOLDOWN_VIEWER_ICON_DIRECTION_RIGHT"];
		else
			updatedDisplayInfo.options[1].text = _G["HUD_EDIT_MODE_SETTING_COOLDOWN_VIEWER_ICON_DIRECTION_DOWN"];
			updatedDisplayInfo.options[2].text = _G["HUD_EDIT_MODE_SETTING_COOLDOWN_VIEWER_ICON_DIRECTION_UP"];
		end
	end

	return updatedDisplayInfo;
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingOrientation()
	self.orientationSetting = self:GetSettingValue(Enum.EditModeCooldownViewerSetting.Orientation);
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingIconLimit()
	self.iconLimit = self:GetSettingValue(Enum.EditModeCooldownViewerSetting.IconLimit);
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingIconDirection()
	self.iconDirection = self:GetSettingValue(Enum.EditModeCooldownViewerSetting.IconDirection);
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingIconSize()
	local iconSizeSetting = self:GetSettingValue(Enum.EditModeCooldownViewerSetting.IconSize);
	self.iconScale = iconSizeSetting / 100;
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingIconPadding()
	self.iconPadding = self:GetSettingValue(Enum.EditModeCooldownViewerSetting.IconPadding);
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingOpacity()
	local opacitySetting = self:GetSettingValue(Enum.EditModeCooldownViewerSetting.Opacity);
	self:SetAlpha(opacitySetting / 100);
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingVisibleSetting()
	self.visibleSetting = self:GetSettingValue(Enum.EditModeCooldownViewerSetting.VisibleSetting);
	self:UpdateShownState();
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingBarContent()
	self:SetBarContent(self:GetSettingValue(Enum.EditModeCooldownViewerSetting.BarContent));
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingHideWhenInactive()
	self:SetHideWhenInactive(self:GetSettingValue(Enum.EditModeCooldownViewerSetting.HideWhenInactive) == 1);
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingShowTimer()
	self:SetTimerShown(self:GetSettingValue(Enum.EditModeCooldownViewerSetting.ShowTimer) == 1);
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingShowTooltips()
	self:SetTooltipsShown(self:GetSettingValue(Enum.EditModeCooldownViewerSetting.ShowTooltips) == 1);
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSettingBarWidthScale()
	self:SetBarWidthScale(self:GetSettingValue(Enum.EditModeCooldownViewerSetting.BarWidthScale) / 100);
end

function EditModeCooldownViewerSystemMixin:UseSettingAltName(setting)
	if setting == Enum.EditModeCooldownViewerSetting.IconLimit then
		return not self:DoesSettingValueEqual(Enum.EditModeCooldownViewerSetting.Orientation, Enum.CooldownViewerOrientation.Vertical);
	end

	return false;
end

function EditModeCooldownViewerSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		return;
	end

	if self:HasSetting(setting) then
		if setting == Enum.EditModeCooldownViewerSetting.Orientation then
			self:UpdateSystemSettingOrientation(entireSystemUpdate);
		elseif setting == Enum.EditModeCooldownViewerSetting.IconLimit then
			self:UpdateSystemSettingIconLimit();
		elseif setting == Enum.EditModeCooldownViewerSetting.IconDirection then
			self:UpdateSystemSettingIconDirection();
		elseif setting == Enum.EditModeCooldownViewerSetting.IconSize then
			self:UpdateSystemSettingIconSize();
		elseif setting == Enum.EditModeCooldownViewerSetting.IconPadding then
			self:UpdateSystemSettingIconPadding();
		elseif setting == Enum.EditModeCooldownViewerSetting.Opacity then
			self:UpdateSystemSettingOpacity();
		elseif setting == Enum.EditModeCooldownViewerSetting.VisibleSetting then
			self:UpdateSystemSettingVisibleSetting();
		elseif setting == Enum.EditModeCooldownViewerSetting.BarContent then
			self:UpdateSystemSettingBarContent();
		elseif setting == Enum.EditModeCooldownViewerSetting.HideWhenInactive then
			self:UpdateSystemSettingHideWhenInactive();
		elseif setting == Enum.EditModeCooldownViewerSetting.ShowTimer then
			self:UpdateSystemSettingShowTimer();
		elseif setting == Enum.EditModeCooldownViewerSetting.ShowTooltips then
			self:UpdateSystemSettingShowTooltips();
		elseif setting == Enum.EditModeCooldownViewerSetting.BarWidthScale then
			self:UpdateSystemSettingBarWidthScale();
		end
	end

	if not entireSystemUpdate then
		self:RefreshLayout();
	end

	self:ClearDirtySetting(setting);
end

function EditModeCooldownViewerSystemMixin:OnUpdateSystem(anySettingsDirty)
	EditModeSystemMixin.OnUpdateSystem(self, anySettingsDirty);

	if anySettingsDirty then
		self:RefreshLayout();
	end
end

function EditModeCooldownViewerSystemMixin:AddExtraButtons(extraButtonPool)
	EditModeSystemMixin.AddExtraButtons(self, extraButtonPool);

	if not Kiosk.IsEnabled() then
		local settingsButton = extraButtonPool:Acquire();
		settingsButton.layoutIndex = 5;
		settingsButton:SetText(HUD_EDIT_MODE_COOLDOWN_VIEWER_SETTINGS);
		local fromEditMode = true;
		settingsButton:SetOnClickHandler(function() CooldownViewerSettings:ShowUIPanel(fromEditMode); end);
		settingsButton:Show();
	end

	local optionsButton = extraButtonPool:Acquire();
	optionsButton.layoutIndex = 6;
	optionsButton:SetText(HUD_EDIT_MODE_COOLDOWN_VIEWER_OPTIONS);
	optionsButton:SetOnClickHandler(function()
		local fromEditMode = true;
		CooldownViewerSettings:ShowOptionsPanel(fromEditMode);
	end);
	optionsButton:Show();

	return true;
end

EditModeEncounterEventsSystemMixin = CreateFromMixins(EditModeSystemMixin);

function EditModeEncounterEventsSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self:SetIsEditing(false);
end

do
	local IconDirectionStringOverrides = {
		[Enum.EncounterEventsOrientation.Horizontal] = {
			HUD_EDIT_MODE_SETTING_ENCOUNTER_EVENTS_ICON_DIRECTION_LEFT,
			HUD_EDIT_MODE_SETTING_ENCOUNTER_EVENTS_ICON_DIRECTION_RIGHT,
		},

		[Enum.EncounterEventsOrientation.Vertical] = {
			HUD_EDIT_MODE_SETTING_ENCOUNTER_EVENTS_ICON_DIRECTION_TOP,
			HUD_EDIT_MODE_SETTING_ENCOUNTER_EVENTS_ICON_DIRECTION_BOTTOM,
		},
	};

	function EditModeEncounterEventsSystemMixin:ShouldShowSetting(setting)
		if not EditModeSystemMixin.ShouldShowSetting(self, setting) then
			return false;
		end

		if self.systemIndex == Enum.EditModeEncounterEventsSystemIndices.Timeline then
			if setting == Enum.EditModeEncounterEventsSetting.ShowSpellName then
				return self:DoesSettingValueEqual(Enum.EditModeEncounterEventsSetting.Orientation, Enum.EncounterEventsOrientation.Vertical);
			end
		end

		return true;
	end

	function EditModeEncounterEventsSystemMixin:UpdateDisplayInfoOptions(displayInfo)
		local updatedDisplayInfo = displayInfo;

		if displayInfo.setting == Enum.EditModeEncounterEventsSetting.IconDirection then
			local orientation = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.Orientation);
			updatedDisplayInfo = CopyTable(displayInfo);

			for optionIndex, optionText in ipairs(IconDirectionStringOverrides[orientation]) do
				updatedDisplayInfo.options[optionIndex].text = optionText;
			end
		end

		return updatedDisplayInfo;
	end
end

function EditModeEncounterEventsSystemMixin:UpdateSystemSettingOrientation()
	-- Implement in a derived system frame mixin to process setting changes.
end

function EditModeEncounterEventsSystemMixin:UpdateSystemSettingIconDirection()
	-- Implement in a derived system frame mixin to process setting changes.
end

function EditModeEncounterEventsSystemMixin:UpdateSystemSettingIconSize()
	-- Implement in a derived system frame mixin to process setting changes.
end

function EditModeEncounterEventsSystemMixin:UpdateSystemSettingOverallSize()
	-- Implement in a derived system frame mixin to process setting changes.
end

function EditModeEncounterEventsSystemMixin:UpdateSystemSettingBackgroundTransparency()
	-- Implement in a derived system frame mixin to process setting changes.
end

function EditModeEncounterEventsSystemMixin:UpdateSystemSettingTransparency()
	-- Implement in a derived system frame mixin to process setting changes.
end

function EditModeEncounterEventsSystemMixin:UpdateSystemSettingVisibility()
	-- Implement in a derived system frame mixin to process setting changes.
end

function EditModeEncounterEventsSystemMixin:UpdateSystemSettingShowSpellName()
	-- Implement in a derived system frame mixin to process setting changes.
end

function EditModeEncounterEventsSystemMixin:UpdateSystemSettingShowTooltips()
	-- Implement in a derived system frame mixin to process setting changes.
end

function EditModeEncounterEventsSystemMixin:UpdateSystemSettingShowTimer()
	-- Implement in a derived system frame mixin to process setting changes.
end

function EditModeEncounterEventsSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		-- If the setting didn't change we have nothing to do
		return;
	end

	if setting == Enum.EditModeEncounterEventsSetting.Orientation and self:HasSetting(Enum.EditModeEncounterEventsSetting.Orientation) then
		self:UpdateSystemSettingOrientation();
	elseif setting == Enum.EditModeEncounterEventsSetting.IconDirection and self:HasSetting(Enum.EditModeEncounterEventsSetting.IconDirection) then
		self:UpdateSystemSettingIconDirection();
	elseif setting == Enum.EditModeEncounterEventsSetting.IconSize and self:HasSetting(Enum.EditModeEncounterEventsSetting.IconSize) then
		self:UpdateSystemSettingIconSize();
	elseif setting == Enum.EditModeEncounterEventsSetting.OverallSize and self:HasSetting(Enum.EditModeEncounterEventsSetting.OverallSize) then
		self:UpdateSystemSettingOverallSize();
	elseif setting == Enum.EditModeEncounterEventsSetting.BackgroundTransparency and self:HasSetting(Enum.EditModeEncounterEventsSetting.BackgroundTransparency) then
		self:UpdateSystemSettingBackgroundTransparency();
	elseif setting == Enum.EditModeEncounterEventsSetting.Transparency and self:HasSetting(Enum.EditModeEncounterEventsSetting.Transparency) then
		self:UpdateSystemSettingTransparency();
	elseif setting == Enum.EditModeEncounterEventsSetting.Visibility and self:HasSetting(Enum.EditModeEncounterEventsSetting.Visibility) then
		self:UpdateSystemSettingVisibility();
	elseif setting == Enum.EditModeEncounterEventsSetting.ShowSpellName and self:HasSetting(Enum.EditModeEncounterEventsSetting.ShowSpellName) then
		self:UpdateSystemSettingShowSpellName();
	elseif setting == Enum.EditModeEncounterEventsSetting.ShowTooltips and self:HasSetting(Enum.EditModeEncounterEventsSetting.ShowTooltips) then
		self:UpdateSystemSettingShowTooltips();
	elseif setting == Enum.EditModeEncounterEventsSetting.ShowTimer and self:HasSetting(Enum.EditModeEncounterEventsSetting.ShowTimer) then
		self:UpdateSystemSettingShowTimer();
	end

	self:ClearDirtySetting(setting);
end

function EditModeEncounterEventsSystemMixin:OpenToBossWarningSettingsCategory()
	EditModeManagerFrame:CheckHideAndLockEditMode();
	Settings.OpenToCategory(Settings.ADVANCED_OPTIONS_CATEGORY_ID, COMBAT_WARNINGS_LABEL);
end

function EditModeEncounterEventsSystemMixin:AddExtraButtons(extraButtonPool)
	EditModeSystemMixin.AddExtraButtons(self, extraButtonPool);

	local optionsButton = extraButtonPool:Acquire();
	optionsButton.layoutIndex = 5;
	optionsButton:SetText(COMBAT_WARNINGS_SETTINGS);
	optionsButton:SetOnClickHandler(function() self:OpenToBossWarningSettingsCategory(); end);
	optionsButton:Show();

	return true;
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
	if self.Label then
		self.Label:SetFontObjectsToTry("GameFontHighlightLarge", "GameFontHighlightMedium", "GameFontHighlightSmall");
	end
	if self.HorizontalLabel then
		self.HorizontalLabel:SetFontObjectsToTry("GameFontHighlightLarge", "GameFontHighlightMedium", "GameFontHighlightSmall");
	end

	NineSliceUtil.ApplyLayout(self.MouseOverHighlight, EditModeSystemSelectionLayout, self.highlightTextureKit);
	self.MouseOverHighlight:SetBlendMode("ADD");
end

function EditModeSystemSelectionBaseMixin:SetSystem(system)
	self.system = system;
end

function EditModeSystemSelectionBaseMixin:ShowHighlighted()
	if self.textureShown ~= "highlight" then
		NineSliceUtil.ApplyLayout(self, EditModeSystemSelectionLayout, self.highlightTextureKit);
		self.textureShown = "highlight";
	end
	self.isSelected = false;
	self:UpdateLabelVisibility();
	self:Show();
end

function EditModeSystemSelectionBaseMixin:ShowSelected()
	if self.textureShown ~= "selected" then
		NineSliceUtil.ApplyLayout(self, EditModeSystemSelectionLayout, self.selectedTextureKit);
		self.textureShown = "selected";
	end
	self.isSelected = true;
	self:UpdateLabelVisibility();
	self:CheckShowInstructionalTooltip();
	self:Show();
end

function EditModeSystemSelectionBaseMixin:IsSelected()
	return self.isSelected;
end

function EditModeSystemSelectionBaseMixin:ShouldShowLabelText()
	return self:IsSelected() or self:IsShowingEditInstructions();
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

function EditModeSystemSelectionBaseMixin:OnEnter()
	self:ShowEditInstructions(true);
	self:CheckShowInstructionalTooltip();
end

function EditModeSystemSelectionBaseMixin:OnLeave()
	self:ShowEditInstructions(false);
	self:HideInstructionalTooltip();
end

function EditModeSystemSelectionBaseMixin:ShowEditInstructions(shown)
	self.instructionsShown = shown;

	self.MouseOverHighlight:SetShown(shown);
	self:UpdateLabelVisibility();
end

function EditModeSystemSelectionBaseMixin:IsShowingEditInstructions()
	return self.instructionsShown;
end

function EditModeSystemSelectionBaseMixin:CheckShowInstructionalTooltip()
	if not self:IsSelected() then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_CURSOR");
		tooltip:SetText(self.system:GetSystemName());
		tooltip:Show();
	else
		self:HideInstructionalTooltip();
	end
end

function EditModeSystemSelectionBaseMixin:HideInstructionalTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:Hide();
end

function EditModeSystemSelectionBaseMixin:GetLabelText()
	if self:IsSelected() then
		return self.system:GetSystemName();
	end

	return HUD_EDIT_MODE_INSTRUCTIONS_CLICK_TO_EDIT;
end

EditModeSystemSelectionMixin = CreateFromMixins(EditModeSystemSelectionBaseMixin);

function EditModeSystemSelectionMixin:UpdateLabelVisibility()
	self.Label:SetText(self:GetLabelText());
	self.Label:SetShown(self:ShouldShowLabelText());
end

EditModeSystemSelectionDoubleLabelMixin = CreateFromMixins(EditModeSystemSelectionBaseMixin);

function EditModeSystemSelectionDoubleLabelMixin:SetVerticalState(vertical)
	self.isVertical = vertical;
	self:UpdateLabelVisibility();
end

function EditModeSystemSelectionDoubleLabelMixin:UpdateLabelVisibility()
	local labelText = self:GetLabelText();
	self.HorizontalLabel:SetText(labelText);
	self.VerticalLabel:SetText(labelText);

	local showLabel = self:ShouldShowLabelText();
	self.HorizontalLabel:SetShown(showLabel and not self.isVertical);
	self.VerticalLabel:SetShown(showLabel and self.isVertical);
end

EditModePersonalResourceDisplaySystemMixin = {};

function EditModePersonalResourceDisplaySystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);
	self:SetIsInEditMode(false);
end

function EditModePersonalResourceDisplaySystemMixin:UpdateSystemSettingHideHealthAndPower()
	self.hideHealthAndPower = self:GetSettingValueBool(Enum.EditModePersonalResourceDisplaySetting.HideHealthAndPower)
	self:SetupHealthBar();
	self:SetupMaxHealth();
	self:UpdateHealthPrediction();
	self:SetupPowerBar();
	self:UpdatePower();
	self:SetupAlternatePowerBar();
	FunctionUtil.SafeInvokeMethod(self.AlternatePowerBar, "UpdateAuraState");
	FunctionUtil.SafeInvokeMethod(self.AlternatePowerBar, "UpdatePower");
end

function EditModePersonalResourceDisplaySystemMixin:UpdateSystemSettingOnlyShowInCombat()
	self.onlyShowInCombat = self:GetSettingValueBool(Enum.EditModePersonalResourceDisplaySetting.OnlyShowInCombat);
	self:UpdateShownState();
end

function EditModePersonalResourceDisplaySystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		return;
	end

	if setting == Enum.EditModePersonalResourceDisplaySetting.HideHealthAndPower and self:HasSetting(Enum.EditModePersonalResourceDisplaySetting.HideHealthAndPower) then
		self:UpdateSystemSettingHideHealthAndPower();
	elseif setting == Enum.EditModePersonalResourceDisplaySetting.OnlyShowInCombat and self:HasSetting(Enum.EditModePersonalResourceDisplaySetting.OnlyShowInCombat) then
		self:UpdateSystemSettingOnlyShowInCombat();
	end

	self:ClearDirtySetting(setting);
end

EditModeDamageMeterSystemMixin = CreateFromMixins(EditModeSystemMixin);

function EditModeDamageMeterSystemMixin:OnSystemLoad()
	EditModeSystemMixin.OnSystemLoad(self);

	self.EditModeResizeButton:SetScript("OnMouseDown", function(button, mouseButtonName, _down)
		button:SetButtonState("PUSHED", true);
		button:GetHighlightTexture():Hide();

		self:StartSizing("BOTTOMRIGHT");
	end);

	self.EditModeResizeButton:SetScript("OnMouseUp", function(button, mouseButtonName, _down)
		button:SetButtonState("NORMAL", false);
		button:GetHighlightTexture():Show();

		self:StopMovingOrSizing();
		self:SetUserPlaced(false);

		local width = self:GetWidth();
		EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeDamageMeterSetting.FrameWidth, width);

		local height =  self:GetHeight();
		EditModeManagerFrame:OnSystemSettingChange(self, Enum.EditModeDamageMeterSetting.FrameHeight, height);
	end);

	local widthSetting = self.settingDisplayInfoMap[Enum.EditModeDamageMeterSetting.FrameWidth];
	local heightSetting = self.settingDisplayInfoMap[Enum.EditModeDamageMeterSetting.FrameHeight];
	self:SetResizeBounds(widthSetting.minValue, heightSetting.minValue, widthSetting.maxValue, heightSetting.maxValue);
end

function EditModeDamageMeterSystemMixin:OnEditModeEnter()
	EditModeSystemMixin.OnEditModeEnter(self);

	self.EditModeResizeButton:Show();

	self:SetResizable(true);
end

function EditModeDamageMeterSystemMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self);

	self.EditModeResizeButton:Hide();

	self:SetResizable(false);

	self:SetIsEditing(false);
end

function EditModeDamageMeterSystemMixin:ShouldShowSetting(setting)
	if not EditModeSystemMixin.ShouldShowSetting(self, setting) then
		return false;
	end

	--[[
	-- FullBackground style removed, and since the BG always shows the transparency setting is always applicable.
	if setting == Enum.EditModeDamageMeterSetting.BackgroundTransparency then
		-- Art assets for the Bordered style don't support adjusting transparency
		-- of the background at present.
		return not self:DoesSettingValueEqual(Enum.EditModeDamageMeterSetting.Style, Enum.DamageMeterStyle.Bordered);
	end
	--]]

	return true;
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingVisibility()
	self.visibility = self:GetSettingValue(Enum.EditModeDamageMeterSetting.Visibility);
	self:UpdateShownState();
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingStyle()
	local style = self:GetSettingValue(Enum.EditModeDamageMeterSetting.Style);
	self:SetStyle(style);
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingNumbers()
	-- NYI
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingFrameWidth()
	local frameWidth = self:GetSettingValue(Enum.EditModeDamageMeterSetting.FrameWidth);
	self:SetSize(frameWidth, self:GetHeight());
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingFrameHeight()
	local frameHeight = self:GetSettingValue(Enum.EditModeDamageMeterSetting.FrameHeight);
	self:SetSize(self:GetWidth(), frameHeight);
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingBarHeight()
	local barHeight = self:GetSettingValue(Enum.EditModeDamageMeterSetting.BarHeight);
	self:SetBarHeight(barHeight);
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingPadding()
	local barSpacing = self:GetSettingValue(Enum.EditModeDamageMeterSetting.Padding);
	self:SetBarSpacing(barSpacing);
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingTransparency()
	local transparency = self:GetSettingValue(Enum.EditModeDamageMeterSetting.Transparency);
	self:SetWindowTransparency(transparency);
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingShowSpecIcon()
	local showBarIcons = self:GetSettingValueBool(Enum.EditModeDamageMeterSetting.ShowSpecIcon);
	self:SetShowBarIcons(showBarIcons);
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingShowClassColor()
	local useClassColor = self:GetSettingValueBool(Enum.EditModeDamageMeterSetting.ShowClassColor);
	self:SetUseClassColor(useClassColor);
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingTextSize()
	local textSize = self:GetSettingValue(Enum.EditModeDamageMeterSetting.TextSize);
	self:SetTextSize(textSize);
end

function EditModeDamageMeterSystemMixin:UpdateSystemSettingBackgroundTransparency()
	local backgroundTransparency = self:GetSettingValue(Enum.EditModeDamageMeterSetting.BackgroundTransparency);
	self:SetBackgroundTransparency(backgroundTransparency);
end

function EditModeDamageMeterSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	EditModeSystemMixin.UpdateSystemSetting(self, setting, entireSystemUpdate);

	if not self:IsSettingDirty(setting) then
		return;
	end

	if setting == Enum.EditModeDamageMeterSetting.Visibility and self:HasSetting(Enum.EditModeDamageMeterSetting.Visibility) then
		self:UpdateSystemSettingVisibility();
	elseif setting == Enum.EditModeDamageMeterSetting.Style and self:HasSetting(Enum.EditModeDamageMeterSetting.Style) then
		self:UpdateSystemSettingStyle();
	elseif setting == Enum.EditModeDamageMeterSetting.Numbers and self:HasSetting(Enum.EditModeDamageMeterSetting.Numbers) then
		self:UpdateSystemSettingNumbers();
	elseif setting == Enum.EditModeDamageMeterSetting.FrameWidth and self:HasSetting(Enum.EditModeDamageMeterSetting.FrameWidth) then
		self:UpdateSystemSettingFrameWidth();
	elseif setting == Enum.EditModeDamageMeterSetting.FrameHeight and self:HasSetting(Enum.EditModeDamageMeterSetting.FrameHeight) then
		self:UpdateSystemSettingFrameHeight();
	elseif setting == Enum.EditModeDamageMeterSetting.BarHeight and self:HasSetting(Enum.EditModeDamageMeterSetting.BarHeight) then
		self:UpdateSystemSettingBarHeight();
	elseif setting == Enum.EditModeDamageMeterSetting.Padding and self:HasSetting(Enum.EditModeDamageMeterSetting.Padding) then
		self:UpdateSystemSettingPadding();
	elseif setting == Enum.EditModeDamageMeterSetting.Transparency and self:HasSetting(Enum.EditModeDamageMeterSetting.Transparency) then
		self:UpdateSystemSettingTransparency();
	elseif setting == Enum.EditModeDamageMeterSetting.ShowSpecIcon and self:HasSetting(Enum.EditModeDamageMeterSetting.ShowSpecIcon) then
		self:UpdateSystemSettingShowSpecIcon();
	elseif setting == Enum.EditModeDamageMeterSetting.ShowClassColor and self:HasSetting(Enum.EditModeDamageMeterSetting.ShowClassColor) then
		self:UpdateSystemSettingShowClassColor();
	elseif setting == Enum.EditModeDamageMeterSetting.TextSize and self:HasSetting(Enum.EditModeDamageMeterSetting.TextSize) then
		self:UpdateSystemSettingTextSize();
	elseif setting == Enum.EditModeDamageMeterSetting.BackgroundTransparency and self:HasSetting(Enum.EditModeDamageMeterSetting.BackgroundTransparency) then
		self:UpdateSystemSettingBackgroundTransparency();
	end

	if not entireSystemUpdate then
		self:RefreshLayout();
	end

	self:ClearDirtySetting(setting);
end

function EditModeDamageMeterSystemMixin:OnUpdateSystem(anySettingsDirty)
	EditModeSystemMixin.OnUpdateSystem(self, anySettingsDirty);

	if anySettingsDirty then
		self:RefreshLayout();
	end
end
