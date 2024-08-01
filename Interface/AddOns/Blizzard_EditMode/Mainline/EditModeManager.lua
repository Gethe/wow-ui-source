EditModeManagerOptionsCategory = {
	Frames = 1,
	Combat = 2,
	Misc = 3
};

local disableOnMaxLayouts = true;
local disableOnActiveChanges = false;
local maxLayoutsErrorText = HUD_EDIT_MODE_ERROR_MAX_LAYOUTS:format(Constants.EditModeConsts.EditModeMaxLayoutsPerType, Constants.EditModeConsts.EditModeMaxLayoutsPerType);
local maxLayoutsCopyErrorText = HUD_EDIT_MODE_ERROR_COPY_MAX_LAYOUTS:format(Constants.EditModeConsts.EditModeMaxLayoutsPerType, Constants.EditModeConsts.EditModeMaxLayoutsPerType);
local characterLayoutHeaderText = GetClassColoredTextForUnit("player", HUD_EDIT_MODE_CHARACTER_LAYOUTS_HEADER:format(UnitNameUnmodified("player")));

EditModeManagerFrameMixin = {};

function EditModeManagerFrameMixin:OnLoad()
	self.registeredSystemFrames = {};
	self.modernSystemMap = EditModePresetLayoutManager:GetModernSystemMap();
	self.modernSystems = EditModePresetLayoutManager:GetModernSystems();

	self.LayoutDropdown:SetWidth(220);

	self.LayoutLabel:ClearAllPoints();
	self.LayoutLabel:SetPoint("BOTTOMLEFT", self.LayoutDropdown, "TOPLEFT", 0, 0);
	self.LayoutLabel:SetText(HUD_EDIT_MODE_LAYOUT);

	local function onShowGridCheckboxChecked(isChecked, isUserInput)
		self:SetGridShown(isChecked, isUserInput);
	end
	self.ShowGridCheckButton:SetCallback(onShowGridCheckboxChecked);

	local function onEnableSnapCheckboxChecked(isChecked, isUserInput)
		self:SetEnableSnap(isChecked, isUserInput);
	end
	self.EnableSnapCheckButton:SetCallback(onEnableSnapCheckboxChecked);

	local function onEnableAdvancedOptionsCheckboxChecked(isChecked, isUserInput)
		self:SetEnableAdvancedOptions(isChecked, isUserInput);
	end
	self.EnableAdvancedOptionsCheckButton:SetCallback(onEnableAdvancedOptionsCheckboxChecked);
	
	local function OnCloseCallback()
		if self:HasActiveChanges() then
			self:ShowRevertWarningDialog();
		else
			HideUIPanel(self);
		end
	end

	self.onCloseCallback = OnCloseCallback;

	self.SaveChangesButton:SetOnClickHandler(GenerateClosure(self.SaveLayoutChanges, self));
	self.RevertAllChangesButton:SetOnClickHandler(GenerateClosure(self.RevertAllChanges, self));

	self:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player");

	self.FramesBlockingEditMode = {};
end

function EditModeManagerFrameMixin:OnDragStart()
	self:StartMoving();
end

function EditModeManagerFrameMixin:OnDragStop()
	self:StopMovingOrSizing();
end

function EditModeManagerFrameMixin:OnUpdate()
	self:InvokeOnAnyEditModeSystemAnchorChanged();
	self:RefreshSnapPreviewLines();
end

local function callOnEditModeEnter(index, systemFrame)
	systemFrame:OnEditModeEnter();
end

function EditModeManagerFrameMixin:ShowSystemSelections()
	secureexecuterange(self.registeredSystemFrames, callOnEditModeEnter);
end

function EditModeManagerFrameMixin:EnterEditMode()
	self.editModeActive = true;
	self:ClearActiveChangesFlags();
	self:UpdateDropdownOptions();
	self:ShowSystemSelections();
	self.AccountSettings:OnEditModeEnter();
    EventRegistry:TriggerEvent("EditMode.Enter");
end

local function callOnEditModeExit(index, systemFrame)
	systemFrame:OnEditModeExit();
end

function EditModeManagerFrameMixin:HideSystemSelections()
	secureexecuterange(self.registeredSystemFrames, callOnEditModeExit);
end

function EditModeManagerFrameMixin:ExitEditMode()
	self.editModeActive = false;
	self:RevertAllChanges();
	self:HideSystemSelections();
	self.AccountSettings:OnEditModeExit();
	self:InvokeOnAnyEditModeSystemAnchorChanged(true);
	C_EditMode.OnEditModeExit();
    EventRegistry:TriggerEvent("EditMode.Exit");
	PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
end

function EditModeManagerFrameMixin:OnShow()
	if not self:IsEditModeLocked() then
		self:EnterEditMode();
	elseif self:IsEditModeInLockState("hideSelections")  then
		self:ShowSystemSelections();
		self.AccountSettings:OnEditModeEnter();
	end

	self:ClearEditModeLockState();
	self:Layout();
end

function EditModeManagerFrameMixin:OnHide()
	if not self:IsEditModeLocked() then
		self:ExitEditMode();
	elseif self:IsEditModeInLockState("hideSelections") then
		self:HideSystemSelections();
		self.AccountSettings:OnEditModeExit();
	end
end

function EditModeManagerFrameMixin:IsEditModeActive()
	return self.editModeActive;
end

function EditModeManagerFrameMixin:SetEditModeLockState(lockState)
	self.editModeLockState = lockState;
end

function EditModeManagerFrameMixin:IsEditModeInLockState(lockState)
	return self.editModeLockState == lockState;
end

function EditModeManagerFrameMixin:ClearEditModeLockState()
	self.editModeLockState = nil;
end

function EditModeManagerFrameMixin:IsEditModeLocked()
	return self.editModeLockState ~= nil;
end

function EditModeManagerFrameMixin:OnEvent(event, ...)
	if event == "EDIT_MODE_LAYOUTS_UPDATED" then
		local layoutInfo, reconcileLayouts = ...;
		self:UpdateLayoutInfo(layoutInfo, reconcileLayouts);
		self:InitializeAccountSettings();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		local layoutInfo = C_EditMode.GetLayouts();
		local activeLayoutChanged = (layoutInfo.activeLayout ~= self.layoutInfo.activeLayout);
		self:UpdateLayoutInfo(layoutInfo);
		if activeLayoutChanged then
			self:NotifyChatOfLayoutChange();
		end
	elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		self:UpdateRightActionBarPositions();
		EditModeMagnetismManager:UpdateUIParentPoints();
	end
end

function EditModeManagerFrameMixin:IsInitialized()
	return self.layoutInfo ~= nil;
end

function EditModeManagerFrameMixin:RegisterSystemFrame(systemFrame)
	table.insert(self.registeredSystemFrames, systemFrame);
end

function EditModeManagerFrameMixin:GetRegisteredSystemFrame(system, systemIndex)
	local foundSystem = nil;
	local function findSystem(index, systemFrame)
		if not foundSystem and systemFrame.system == system and systemFrame.systemIndex == systemIndex then
			foundSystem = systemFrame;
		end
	end
	secureexecuterange(self.registeredSystemFrames, findSystem);
	return foundSystem;
end

local function AreAnchorsEqual(anchorInfo, otherAnchorInfo)
	if anchorInfo and otherAnchorInfo then
		return anchorInfo.point == otherAnchorInfo.point
		and anchorInfo.relativeTo == otherAnchorInfo.relativeTo
		and anchorInfo.relativePoint == otherAnchorInfo.relativePoint
		and anchorInfo.offsetX == otherAnchorInfo.offsetX
		and anchorInfo.offsetY == otherAnchorInfo.offsetY
	end

	return anchorInfo == otherAnchorInfo;
end

local function CopyAnchorInfo(anchorInfo, otherAnchorInfo)
	if anchorInfo and otherAnchorInfo then
		anchorInfo.point = otherAnchorInfo.point;
		anchorInfo.relativeTo = otherAnchorInfo.relativeTo;
		anchorInfo.relativePoint = otherAnchorInfo.relativePoint;
		anchorInfo.offsetX = otherAnchorInfo.offsetX;
		anchorInfo.offsetY = otherAnchorInfo.offsetY;
	end
end

local function ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY)
	if point then
		local anchorInfo = {};
		anchorInfo.point = point;
		anchorInfo.relativeTo = relativeTo and relativeTo:GetName() or "UIParent";
		anchorInfo.relativePoint = relativePoint;
		anchorInfo.offsetX = offsetX;
		anchorInfo.offsetY = offsetY;
		return anchorInfo;
	end

	return nil;
end

function EditModeManagerFrameMixin:SetHasActiveChanges(hasActiveChanges)
	-- Clear taint off of the value passed in
	if hasActiveChanges then
		self.hasActiveChanges = true;
	else
		self.hasActiveChanges = false;
	end	
	self.SaveChangesButton:SetEnabled(hasActiveChanges);
	self.RevertAllChangesButton:SetEnabled(hasActiveChanges);
end

function EditModeManagerFrameMixin:CheckForSystemActiveChanges()
	local hasActiveChanges = false;
	local function checkIfSystemHasActiveChanges(index, systemFrame)
		if not hasActiveChanges and systemFrame:HasActiveChanges() then
			hasActiveChanges = true;
		end
	end
	secureexecuterange(self.registeredSystemFrames, checkIfSystemHasActiveChanges);

	self:SetHasActiveChanges(hasActiveChanges);
end

function EditModeManagerFrameMixin:HasActiveChanges()
	return self.hasActiveChanges;
end

function EditModeManagerFrameMixin:UpdateSystemAnchorInfo(systemFrame)
	local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		local anchorInfoChanged = false;

		local point, relativeTo, relativePoint, offsetX, offsetY = systemFrame:GetPoint(1);

		-- If we don't have a relativeTo then we are gonna set our relativeTo to be UIParent
		if not relativeTo then
			relativeTo = UIParent;

			-- When setting our relativeTo to UIParent it's possible for our y position to change slightly depending on UIParent's size from stuff like debug menus
			-- To account for this set out position and then track the change in our top and adjust for that
			local originalSystemFrameTop = systemFrame:GetTop();
			systemFrame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);

			offsetY = offsetY + originalSystemFrameTop - systemFrame:GetTop();
			systemFrame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
		end

		-- Undo offset changes due to scale so we're always working as if we're at 1.0 scale
		local frameScale = systemFrame:GetScale();
		offsetX = offsetX * frameScale;
		offsetY = offsetY * frameScale;

		local newAnchorInfo = ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY);
		if not AreAnchorsEqual(systemInfo.anchorInfo, newAnchorInfo) then
			CopyAnchorInfo(systemInfo.anchorInfo, newAnchorInfo);
			anchorInfoChanged = true;
		end

		point, relativeTo, relativePoint, offsetX, offsetY = systemFrame:GetPoint(2);

		-- Undo offset changes due to scale so we're always working as if we're at 1.0 scale
		-- May not always have a second point so nil check first
		if point ~= nil then
			offsetX = offsetX * frameScale;
			offsetY = offsetY * frameScale;
		end

		newAnchorInfo = ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY);
		if not AreAnchorsEqual(systemInfo.anchorInfo2, newAnchorInfo) then
			CopyAnchorInfo(systemInfo.anchorInfo2, newAnchorInfo);
			anchorInfoChanged = true;
		end

		if anchorInfoChanged then
			systemInfo.isInDefaultPosition = false;
		end

		return anchorInfoChanged;
	end

	return false;
end

function EditModeManagerFrameMixin:OnSystemPositionChange(systemFrame)
	if self:UpdateSystemAnchorInfo(systemFrame) then
		systemFrame:SetHasActiveChanges(true);

		self:UpdateActionBarLayout(systemFrame);

		if systemFrame.isBottomManagedFrame or systemFrame.isRightManagedFrame then
			UIParent_ManageFramePositions();
		end

		EditModeSystemSettingsDialog:UpdateDialog(systemFrame);
	end

	self:OnEditModeSystemAnchorChanged();
end

function EditModeManagerFrameMixin:MirrorSetting(system, systemIndex, setting, value)
	local mirroredSettings = EditModeSettingDisplayInfoManager:GetMirroredSettings(system, systemIndex, setting);
	if mirroredSettings then
		for _, mirroredSettingInfo in ipairs(mirroredSettings) do
			local systemFrame = self:GetRegisteredSystemFrame(mirroredSettingInfo.system, mirroredSettingInfo.systemIndex);
			if systemFrame then
				systemFrame:UpdateSystemSettingValue(setting, value);
			end
		end
	end
end

function EditModeManagerFrameMixin:OnSystemSettingChange(systemFrame, changedSetting, newValue)
	local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		systemFrame:UpdateSystemSettingValue(changedSetting, newValue);
	end
end

function EditModeManagerFrameMixin:RevertSystemChanges(systemFrame)
	local activeLayoutInfo = self:GetActiveLayoutInfo();
	if activeLayoutInfo then
		for index, systemInfo in ipairs(activeLayoutInfo.systems) do
			if systemInfo.system == systemFrame.system and systemInfo.systemIndex == systemFrame.systemIndex then
				activeLayoutInfo.systems[index] = systemFrame.savedSystemInfo;

				systemFrame:BreakSnappedFrames();
				systemFrame:UpdateSystem(systemFrame.savedSystemInfo);
				self:CheckForSystemActiveChanges();
				return;
			end
		end
	end
end

function EditModeManagerFrameMixin:GetSettingValue(system, systemIndex, setting, useRawValue)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:GetSettingValue(setting, useRawValue)
	end
end

function EditModeManagerFrameMixin:GetSettingValueBool(system, systemIndex, setting, useRawValue)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:GetSettingValueBool(setting, useRawValue)
	end
end

function EditModeManagerFrameMixin:DoesSettingValueEqual(system, systemIndex, setting, value)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:DoesSettingValueEqual(setting, value);
	end
end

function EditModeManagerFrameMixin:DoesSettingDisplayValueEqual(system, systemIndex, setting, value)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:DoesSettingDisplayValueEqual(setting, value);
	end
end

function EditModeManagerFrameMixin:ArePartyFramesForcedShown()
	return self:IsEditModeActive() and self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPartyFrames);
end

function EditModeManagerFrameMixin:GetNumArenaFramesForcedShown()
	if self:IsEditModeActive() and self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowArenaFrames) then
		local viewArenaSize = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Arena, Enum.EditModeUnitFrameSetting.ViewArenaSize);
		if viewArenaSize == Enum.ViewArenaSize.Two then
			return 2;
		else
			return 3;
		end
	end

	return 0;
end

function EditModeManagerFrameMixin:UseRaidStylePartyFrames()
	return self:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Party, Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames);
end

function EditModeManagerFrameMixin:ShouldShowPartyFrameBackground()
	return self:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Party, Enum.EditModeUnitFrameSetting.ShowPartyFrameBackground);
end

function EditModeManagerFrameMixin:UpdateRaidContainerFlow()
	local maxPerLine, orientation;

	local raidGroupDisplayType = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType);
	if raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsVertical then
		orientation = "vertical";
		CompactRaidFrameContainer:ApplyToFrames("group", CompactRaidGroup_UpdateBorder);
		maxPerLine = 5;
	elseif raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal then
		orientation = "horizontal";
		CompactRaidFrameContainer:ApplyToFrames("group", CompactRaidGroup_UpdateBorder);
		maxPerLine = 5;
	elseif raidGroupDisplayType == Enum.RaidGroupDisplayType.CombineGroupsVertical then
		orientation = "vertical";
		maxPerLine = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RowSize);
	else
		orientation = "horizontal";
		maxPerLine = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RowSize);
	end

	-- Setting CompactRaidFrameContainer to a really big size because the flow container bases its calculations off the size of the container itself
	-- The layout call below shrinks the container back down to fit the actual contents after they have been anchored
	FlowContainer_SetOrientation(CompactRaidFrameContainer, orientation);
	FlowContainer_SetMaxPerLine(CompactRaidFrameContainer, maxPerLine);
	CompactRaidFrameContainer:TryUpdate();
end

function EditModeManagerFrameMixin:AreRaidFramesForcedShown()
	return self:IsEditModeActive() and self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowRaidFrames);
end

function EditModeManagerFrameMixin:GetNumRaidGroupsForcedShown()
	if self:AreRaidFramesForcedShown() then
		local viewRaidSize = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.ViewRaidSize);
		if viewRaidSize == Enum.ViewRaidSize.Ten then
			return 2;
		elseif viewRaidSize == Enum.ViewRaidSize.TwentyFive then
			return 5;
		elseif viewRaidSize == Enum.ViewRaidSize.Forty then
			return 8;
		else
			return 0;
		end
	else
		return 0;
	end
end

function EditModeManagerFrameMixin:GetNumRaidMembersForcedShown()
	if self:AreRaidFramesForcedShown() then
		local viewRaidSize = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.ViewRaidSize);
		if viewRaidSize == Enum.ViewRaidSize.Ten then
			return 10;
		elseif viewRaidSize == Enum.ViewRaidSize.TwentyFive then
			return 25;
		elseif viewRaidSize == Enum.ViewRaidSize.Forty then
			return 40;
		else
			return 0;
		end
	else
		return 0;
	end
end

function EditModeManagerFrameMixin:GetRaidFrameWidth(systemIndex)
	local raidFrameWidth = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.FrameWidth);
	return (raidFrameWidth and raidFrameWidth > 0) and raidFrameWidth or NATIVE_UNIT_FRAME_WIDTH;
end

function EditModeManagerFrameMixin:GetRaidFrameHeight(systemIndex)
	local raidFrameHeight = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.FrameHeight);
	return (raidFrameHeight and raidFrameHeight > 0) and raidFrameHeight or NATIVE_UNIT_FRAME_HEIGHT;
end

function EditModeManagerFrameMixin:ShouldRaidFrameUseHorizontalRaidGroups(systemIndex)
	if systemIndex == Enum.EditModeUnitFrameSystemIndices.Party then
		return self:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.UseHorizontalGroups);
	elseif systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid then
		return self:DoesSettingValueEqual(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType, Enum.RaidGroupDisplayType.SeparateGroupsHorizontal);
	end

	return false;
end

function EditModeManagerFrameMixin:ShouldRaidFrameDisplayBorder(systemIndex)
	return self:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.DisplayBorder);
end

function EditModeManagerFrameMixin:ShouldRaidFrameShowSeparateGroups()
	local raidGroupDisplayType = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType);
	return (raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsVertical) or (raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal);
end

function EditModeManagerFrameMixin:UpdateActionBarLayout(systemFrame)
	if EditModeUtil:IsBottomAnchoredActionBar(systemFrame) then
		self:UpdateBottomActionBarPositions();
	elseif EditModeUtil:IsRightAnchoredActionBar(systemFrame) or systemFrame == MinimapCluster then
		self:UpdateRightActionBarPositions();
	end
end

function EditModeManagerFrameMixin:UpdateActionBarPositions()
	self:UpdateBottomActionBarPositions();
	self:UpdateRightActionBarPositions();
end

function EditModeManagerFrameMixin:UpdateRightActionBarPositions()
	if not self:IsInitialized() or self.layoutApplyInProgress then
		return;
	end

	local barsToUpdate = { MultiBarRight, MultiBarLeft };

	-- Determine new scale
	local topLimit = MinimapCluster:IsInDefaultPosition() and (MinimapCluster:GetBottom() - 10) or UIParent:GetTop();
	local bottomLimit = MicroButtonAndBagsBar:GetTop() + 24;
	local availableSpace = topLimit - bottomLimit;
	local multiBarHeight = MultiBarRight:GetHeight();
	local newScale = multiBarHeight > availableSpace and availableSpace / multiBarHeight or 1;

	-- Update bars
	local offsetX = RIGHT_ACTION_BAR_DEFAULT_OFFSET_X;
	local offsetY = RIGHT_ACTION_BAR_DEFAULT_OFFSET_Y;
	local leftMostBar = nil;
	for index, bar in ipairs(barsToUpdate) do
		if bar and bar:IsShown() then
			local isInDefaultPosition = bar:IsInDefaultPosition();
			bar:SetScale(isInDefaultPosition and newScale or 1);

			if isInDefaultPosition then
				local leftMostBarWidth = leftMostBar and -leftMostBar:GetWidth() - 5 or 0;
				offsetX = offsetX + leftMostBarWidth;

				bar:ClearAllPoints();
				bar:SetPoint("RIGHT", UIParent, "RIGHT", offsetX, offsetY);

				-- Bar position changed so we should update our flyout direction
				if bar.UpdateSpellFlyoutDirection then
					bar:UpdateSpellFlyoutDirection();
				end

				leftMostBar = bar;
			end
		end
	end

	UIParent_ManageFramePositions();
end

function EditModeManagerFrameMixin:UpdateBottomActionBarPositions()
	if not self:IsInitialized() or self.layoutApplyInProgress then
		return;
	end

	local barsToUpdate = { MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, StanceBar, PetActionBar, PossessActionBar, MainMenuBarVehicleLeaveButton };

	local offsetX = 0;
	local offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y;

	if OverrideActionBar and OverrideActionBar:IsShown() then
		local xpBarHeight = OverrideActionBar.xpBar:IsShown() and OverrideActionBar.xpBar:GetHeight() or 0;
		offsetY = OverrideActionBar:GetHeight() + xpBarHeight + 10;
	end

	local topMostBar = nil;

	local layoutInfo = self:GetActiveLayoutInfo();
	local isPresetLayout = layoutInfo.layoutType == Enum.EditModeLayoutType.Preset;
	local isOverrideLayout = layoutInfo.layoutType == Enum.EditModeLayoutType.Override; 

	for index, bar in ipairs(barsToUpdate) do
		if bar and bar:IsShown() and bar:IsInDefaultPosition() then
			bar:ClearAllPoints();

			if bar.useDefaultAnchors and isPresetLayout then
				local anchorInfo = EditModePresetLayoutManager:GetPresetLayoutSystemAnchorInfo(layoutInfo.layoutIndex, bar.system, bar.systemIndex);
				bar:SetPoint(anchorInfo.point, anchorInfo.relativeTo, anchorInfo.relativePoint, anchorInfo.offsetX, anchorInfo.offsetY);
			elseif bar.useDefaultAnchors and isOverrideLayout then
				local anchorInfo = EditModePresetLayoutManager:GetOverrideLayoutSystemAnchorInfo(layoutInfo.layoutIndex, bar.system, bar.systemIndex);
				bar:SetPoint(anchorInfo.point, anchorInfo.relativeTo, anchorInfo.relativePoint, anchorInfo.offsetX, anchorInfo.offsetY);
			else
				if not topMostBar then
					offsetX = -bar:GetWidth() / 2;
				end

				local topBarHeight = topMostBar and topMostBar:GetHeight() + 5 or 0;
				offsetY = offsetY + topBarHeight;

				bar:ClearAllPoints();
				bar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", offsetX, offsetY);

				topMostBar = bar;
			end

			-- Bar position changed so we should update our flyout direction
			if bar.UpdateSpellFlyoutDirection then
				bar:UpdateSpellFlyoutDirection();
			end
		end
	end

	UIParent_ManageFramePositions();
end

function EditModeManagerFrameMixin:SelectSystem(selectFrame)
	if not self:IsEditModeLocked() then
		local function selectMatchingSystem(index, systemFrame)
			if systemFrame == selectFrame then
				systemFrame:SelectSystem();
			else
				-- Only highlight a system if it was already highlighted
				if systemFrame.isHighlighted then
					systemFrame:HighlightSystem();
				end
			end
		end
		secureexecuterange(self.registeredSystemFrames, selectMatchingSystem);
	end
end

local function clearSelectedSystem(index, systemFrame)
	-- Only highlight a system if it was already highlighted
	if systemFrame.isHighlighted then
		systemFrame:HighlightSystem();
	end
end

function EditModeManagerFrameMixin:ClearSelectedSystem()
	secureexecuterange(self.registeredSystemFrames, clearSelectedSystem);
	EditModeSystemSettingsDialog:Hide();
end

function EditModeManagerFrameMixin:NotifyChatOfLayoutChange()
	local newActiveLayoutName = self:GetActiveLayoutInfo().layoutName;
	local systemChatInfo = ChatTypeInfo["SYSTEM"];
	DEFAULT_CHAT_FRAME:AddMessage(HUD_EDIT_MODE_LAYOUT_APPLIED:format(newActiveLayoutName), systemChatInfo.r, systemChatInfo.g, systemChatInfo.b, systemChatInfo.id);
end

-- This method handles removing any out-dated systems/settings from a saved layout data table
function EditModeManagerFrameMixin:RemoveOldSystemsAndSettings(layoutInfo)
	local removedSomething = false;
	local keepSystems = {};

	for _, layoutSystemInfo in ipairs(layoutInfo.systems) do
		local keepSystem;
		if layoutSystemInfo.systemIndex then
			keepSystem = self.modernSystemMap[layoutSystemInfo.system] and self.modernSystemMap[layoutSystemInfo.system][layoutSystemInfo.systemIndex];
		else
			keepSystem = self.modernSystemMap[layoutSystemInfo.system];
		end

		if keepSystem then
			-- This system still exists, so we want to add it to keepSystems, but first we want to check if any settings within it were removed
			local keepSettings = {};
			local removedSetting = false;
			for _, settingInfo in ipairs(layoutSystemInfo.settings) do
				if keepSystem.settings[settingInfo.setting] then
					-- This setting still exists, so we want to add it to keepSettings
					table.insert(keepSettings, settingInfo);
				else
					-- This setting no longer exists, so don't add it to keepSystems
					removedSomething = true;
					removedSetting = true;
				end
			end

			if removedSetting then
				-- A setting was removed, so replace the settings table with keepSettings
				layoutSystemInfo.settings = keepSettings;
			end

			-- Add layoutSystemInfo to keepSystems;
			table.insert(keepSystems, layoutSystemInfo);
		else
			-- This system no longer exists, so don't add it to keepSystems
			removedSomething = true;
		end
	end

	if removedSomething then
		-- Something was removed, so replace the systems table with keepSystems
		layoutInfo.systems = keepSystems;
	end

	return removedSomething;
end

-- This method handles adding any missing systems/settings to a saved layout data table
function EditModeManagerFrameMixin:AddNewSystemsAndSettings(layoutInfo)
	local addedSomething = false;

	-- Create a system/setting map to allow for efficient checking of each system & setting below
	local layoutSystemMap = {};
	for _, layoutSystemInfo in ipairs(layoutInfo.systems) do
		local settingMap = EditModeUtil:GetSettingMapFromSettings(layoutSystemInfo.settings);

		if layoutSystemInfo.systemIndex then
			if not layoutSystemMap[layoutSystemInfo.system] then
				layoutSystemMap[layoutSystemInfo.system] = {};
			end
			layoutSystemMap[layoutSystemInfo.system][layoutSystemInfo.systemIndex] = { settingMap = settingMap, settings = layoutSystemInfo.settings };
		else
			layoutSystemMap[layoutSystemInfo.system] = { settingMap = settingMap, settings = layoutSystemInfo.settings };
		end
	end

	-- Loop through all of the modern systems/setting and add any that don't exist in the saved layout data table
	for _, systemInfo in ipairs(self.modernSystems) do
		local existingSystem;
		if systemInfo.systemIndex then
			existingSystem = layoutSystemMap[systemInfo.system] and layoutSystemMap[systemInfo.system][systemInfo.systemIndex];
		else
			existingSystem = layoutSystemMap[systemInfo.system];
		end

		if not existingSystem then
			-- This system was newly added since this layout was saved so add it
			table.insert(layoutInfo.systems, CopyTable(systemInfo));
			addedSomething = true;
		else
			-- This system already existed, but we still need to check if any settings were added to it
			for _, settingInfo in ipairs(systemInfo.settings) do
				if not existingSystem.settingMap[settingInfo.setting] then
					-- This setting was newly added since this layout was saved so add it
					table.insert(existingSystem.settings, CopyTable(settingInfo));
					addedSomething = true;
				end
			end
		end
	end

	return addedSomething;
end

function EditModeManagerFrameMixin:ReconcileWithModern(layoutInfo)
	local removedSomething = self:RemoveOldSystemsAndSettings(layoutInfo);
	local addedSomething = self:AddNewSystemsAndSettings(layoutInfo);
	return removedSomething or addedSomething;
end

-- Sometimes new systems/settings may be added to (or removed from) EditMode. When that happens the saved layout data be will out of date
-- This method handles adding any missing systems/settings and removing any existing systems/settings from the saved layout data
function EditModeManagerFrameMixin:ReconcileLayoutsWithModern()
	local somethingChanged = false;
	for _, layoutInfo in ipairs(self.layoutInfo.layouts) do
		if self:ReconcileWithModern(layoutInfo) then
			somethingChanged = true;
		end
	end

	if somethingChanged then
		-- Something changed, so we need to send the updated edit mode info up to be saved on logout
		C_EditMode.SaveLayouts(self.layoutInfo);
	end
end

function EditModeManagerFrameMixin:UpdateAccountSettingMap()
	self.accountSettingMap = EditModeUtil:GetSettingMapFromSettings(self.accountSettings);
end

function EditModeManagerFrameMixin:GetAccountSettingValue(setting)
	return self.accountSettingMap[setting].value;
end

function EditModeManagerFrameMixin:GetAccountSettingValueBool(setting)
	return self:GetAccountSettingValue(setting) == 1;
end

function EditModeManagerFrameMixin:InitializeAccountSettings()
	self.accountSettings = C_EditMode.GetAccountSettings();
	self:UpdateAccountSettingMap();

	self:SetGridShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowGrid));
	self:SetGridSpacing(self:GetAccountSettingValue(Enum.EditModeAccountSetting.GridSpacing));
	self:SetEnableSnap(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.EnableSnap));
	self:SetEnableAdvancedOptions(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.EnableAdvancedOptions));
	self.AccountSettings:SetExpandedState(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.SettingsExpanded));
	self.AccountSettings:SetTargetAndFocusShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowTargetAndFocus));
	self.AccountSettings:SetPartyFramesShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPartyFrames));
	self.AccountSettings:SetRaidFramesShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowRaidFrames));
	self.AccountSettings:SetActionBarShown(StanceBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowStanceBar));
	if(PetActionBar) then 
	self.AccountSettings:SetActionBarShown(PetActionBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPetActionBar));
	end 
	self.AccountSettings:SetActionBarShown(PossessActionBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPossessActionBar));
	self.AccountSettings:SetCastBarShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowCastBar));
	self.AccountSettings:SetEncounterBarShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowEncounterBar));
	self.AccountSettings:SetExtraAbilitiesShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowExtraAbilities));
	self.AccountSettings:SetBuffsAndDebuffsShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowBuffsAndDebuffs));
	self.AccountSettings:SetTalkingHeadFrameShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowTalkingHeadFrame));
	self.AccountSettings:SetVehicleLeaveButtonShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowVehicleLeaveButton));
	self.AccountSettings:SetBossFramesShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowBossFrames));
	self.AccountSettings:SetArenaFramesShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowArenaFrames));
	self.AccountSettings:SetLootFrameShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowLootFrame));
	self.AccountSettings:SetHudTooltipShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowHudTooltip));
	self.AccountSettings:SetStatusTrackingBar2Shown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowStatusTrackingBar2));
	self.AccountSettings:SetDurabilityFrameShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowDurabilityFrame));
	self.AccountSettings:SetPetFrameShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPetFrame));
end

function EditModeManagerFrameMixin:OnAccountSettingChanged(changedSetting, newValue)
	if type(newValue) == "boolean" then
		newValue = newValue and 1 or 0;
	end

	for _, settingInfo in pairs(self.accountSettings) do
		if settingInfo.setting == changedSetting then
			if settingInfo.value ~= newValue then
				settingInfo.value = newValue;
				self:UpdateAccountSettingMap();
				C_EditMode.SetAccountSetting(changedSetting, newValue);
			end
			return;
		end
	end
end

function EditModeManagerFrameMixin:UpdateLayoutCounts(savedLayouts)
	self.numLayouts = {
		[Enum.EditModeLayoutType.Account] = 0,
		[Enum.EditModeLayoutType.Character] = 0,
	};

	for _, layoutInfo in ipairs(savedLayouts) do
		self.numLayouts[layoutInfo.layoutType] = self.numLayouts[layoutInfo.layoutType] + 1;
	end
end

function EditModeManagerFrameMixin:AreLayoutsOfTypeMaxed(layoutType)
	return self.numLayouts[layoutType] >= Constants.EditModeConsts.EditModeMaxLayoutsPerType;
end

function EditModeManagerFrameMixin:AreLayoutsFullyMaxed()
	return self:AreLayoutsOfTypeMaxed(Enum.EditModeLayoutType.Account) and self:AreLayoutsOfTypeMaxed(Enum.EditModeLayoutType.Character);
end

function EditModeManagerFrameMixin:UpdateLayoutInfo(layoutInfo, reconcileLayouts)
	self.layoutApplyInProgress = true;
	self.layoutInfo = layoutInfo;

	if reconcileLayouts then
		self:ReconcileLayoutsWithModern();
	end

	local savedLayouts = self.layoutInfo.layouts;
	self.layoutInfo.layouts = EditModePresetLayoutManager:GetCopyOfPresetLayouts();
	tAppendAll(self.layoutInfo.layouts, savedLayouts);

	self:UpdateLayoutCounts(savedLayouts);

	self:InitSystemAnchors();
	self:UpdateSystems();
	self:ClearActiveChangesFlags();

	if self:IsShown() then
		self:UpdateDropdownOptions();
	end

	self.layoutApplyInProgress = false;
	self:UpdateActionBarPositions();

	local forceInvokeYes = true;
	self:InvokeOnAnyEditModeSystemAnchorChanged(forceInvokeYes);
end

function EditModeManagerFrameMixin:OnEditModeSystemAnchorChanged()
	self.editModeSystemAnchorDirty = true;
end

function EditModeManagerFrameMixin:InvokeOnAnyEditModeSystemAnchorChanged(force)
	if not force and not self.editModeSystemAnchorDirty then
		return;
	end

	local function callOnAnyEditModeSystemAnchorChanged(index, systemFrame)
		systemFrame:OnAnyEditModeSystemAnchorChanged();
	end
	secureexecuterange(self.registeredSystemFrames, callOnAnyEditModeSystemAnchorChanged);

	self.editModeSystemAnchorDirty = nil;
end

function EditModeManagerFrameMixin:GetLayouts()
	return self.layoutInfo.layouts;
end

function EditModeManagerFrameMixin:SetGridShown(gridShown, isUserInput)
	self.Grid:SetShown(gridShown);
	self.GridSpacingSlider:SetEnabled(gridShown);

	if isUserInput then
		self:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowGrid, gridShown);
	else
		self.ShowGridCheckButton:SetControlChecked(gridShown);
	end
end

function EditModeManagerFrameMixin:SetGridSpacing(gridSpacing, isUserInput)
	self.Grid:SetGridSpacing(gridSpacing);
	self.GridSpacingSlider:SetupSlider(gridSpacing);

	if isUserInput then
		self:OnAccountSettingChanged(Enum.EditModeAccountSetting.GridSpacing, gridSpacing);
	end
end

function EditModeManagerFrameMixin:SetEnableSnap(enableSnap, isUserInput)
	self.snapEnabled = enableSnap;

	if not self.snapEnabled then
		self:HideSnapPreviewLines();
	end

	if isUserInput then
		self:OnAccountSettingChanged(Enum.EditModeAccountSetting.EnableSnap, enableSnap);
	else
		self.EnableSnapCheckButton:SetControlChecked(enableSnap);
	end
end

function EditModeManagerFrameMixin:IsSnapEnabled()
	return self.snapEnabled;
end

function EditModeManagerFrameMixin:SetSnapPreviewFrame(snapPreviewFrame)
	self.snapPreviewFrame = snapPreviewFrame;
end

function EditModeManagerFrameMixin:ClearSnapPreviewFrame()
	self.snapPreviewFrame = nil;
	self:HideSnapPreviewLines();
end

function EditModeManagerFrameMixin:ShouldShowSnapPreviewLines()
	return self:IsSnapEnabled() and self.snapPreviewFrame;
end

function EditModeManagerFrameMixin:RefreshSnapPreviewLines()
	self:HideSnapPreviewLines();

	if not self:ShouldShowSnapPreviewLines() then
		return;
	end

	if not self.magnetismPreviewLinesPool then
		self.magnetismPreviewLinePool = EditModeUtil.CreateLinePool(self.MagnetismPreviewLinesContainer, "MagnetismPreviewLineTemplate");
	end

	local magneticFrameInfos = EditModeMagnetismManager:GetMagneticFrameInfos(self.snapPreviewFrame);
	if magneticFrameInfos then
		for _, magneticFrameInfo in ipairs(magneticFrameInfos) do
			local lineAnchors = EditModeMagnetismManager:GetPreviewLineAnchors(magneticFrameInfo);
			for _, lineAnchor in ipairs(lineAnchors) do
				local line = self.magnetismPreviewLinePool:Acquire();
				line:Setup(magneticFrameInfo, lineAnchor);
			end
		end
	end
end

function EditModeManagerFrameMixin:HideSnapPreviewLines()
	if self.magnetismPreviewLinePool then
		self.magnetismPreviewLinePool:ReleaseAll();
	end
end

function EditModeManagerFrameMixin:SetEnableAdvancedOptions(enableAdvancedOptions, isUserInput)
	self.advancedOptionsEnabled = enableAdvancedOptions;
	self.AccountSettings:LayoutSettings();

	if isUserInput then
		self:OnAccountSettingChanged(Enum.EditModeAccountSetting.EnableAdvancedOptions, enableAdvancedOptions);
	else
		self.EnableAdvancedOptionsCheckButton:SetControlChecked(enableAdvancedOptions);
	end
end

function EditModeManagerFrameMixin:AreAdvancedOptionsEnabled()
	return self.advancedOptionsEnabled;
end

local function SortLayouts(a, b)
	-- Sorts the layouts: character-specific -> account -> preset
	local layoutTypeA = a.layoutInfo.layoutType;
	local layoutTypeB = b.layoutInfo.layoutType;
	if layoutTypeA ~= layoutTypeB then
		return layoutTypeA > layoutTypeB;
	end

	return a.index < b.index;
end

function EditModeManagerFrameMixin:CreateLayoutTbls()
	self.highestLayoutIndexByType = {};

	local layoutTbls = {};
	local hasCharacterLayouts = false;
	for index, layoutInfo in ipairs(self.layoutInfo.layouts) do
		table.insert(layoutTbls, { index = index, layoutInfo = layoutInfo });

		local layoutType = layoutInfo.layoutType;
		if layoutType == Enum.EditModeLayoutType.Character then
			hasCharacterLayouts = true;
		end

		if not self.highestLayoutIndexByType[layoutType] or self.highestLayoutIndexByType[layoutType] < index then
			self.highestLayoutIndexByType[layoutType] = index;
		end
	end

	table.sort(layoutTbls, SortLayouts);

	return layoutTbls, hasCharacterLayouts;
end

local function GetNewLayoutText(disabled)
	if disabled then
		return HUD_EDIT_MODE_NEW_LAYOUT_DISABLED:format(CreateAtlasMarkup("editmode-new-layout-plus-disabled"));
	end
	return HUD_EDIT_MODE_NEW_LAYOUT:format(CreateAtlasMarkup("editmode-new-layout-plus"));
end

local function GetDisableReason(disableOnMaxLayouts, disableOnActiveChanges)
	if disableOnMaxLayouts and EditModeManagerFrame:AreLayoutsFullyMaxed() then
		return maxLayoutsErrorText;
	elseif disableOnActiveChanges and EditModeManagerFrame:HasActiveChanges() then
		return HUD_EDIT_MODE_UNSAVED_CHANGES;
	end
	return nil;
end

local function SetPresetEnabledState(elementDescription, disableOnMaxLayouts, disableOnActiveChanges)
	local reason = GetDisableReason(disableOnMaxLayouts, disableOnActiveChanges);
	local enabled = reason == nil;
	elementDescription:SetEnabled(enabled);
	
	if not enabled then
		elementDescription:SetTooltip(function(tooltip, elementDescription)
			GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
			GameTooltip_AddErrorLine(tooltip, reason);
		end);
	end
end

function EditModeManagerFrameMixin:UpdateDropdownOptions()
	local function IsSelected(index)
		return self.layoutInfo.activeLayout == index;
	end

	local function SetSelected(index)
		if not self:IsLayoutSelected(index) then
			if self:HasActiveChanges() then
				self:ShowRevertWarningDialog(index);
			else
				self:SelectLayout(index);
			end
		end
	end

	local layoutTbls, hasCharacterLayouts = self:CreateLayoutTbls();

	self.LayoutDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_EDIT_MODE_MANAGER");

		local lastLayoutType = nil;
		for _, layoutTbl in ipairs(layoutTbls) do
			local layoutInfo = layoutTbl.layoutInfo;
			local index = layoutTbl.index;
			local layoutType = layoutInfo.layoutType;

			if lastLayoutType and lastLayoutType ~= layoutType then
				rootDescription:CreateDivider();
			end
			lastLayoutType = layoutType;

			local isUserLayout = layoutType == Enum.EditModeLayoutType.Account or layoutType == Enum.EditModeLayoutType.Server;
			local isPreset = layoutType == Enum.EditModeLayoutType.Preset;
			local text = isPreset and HUD_EDIT_MODE_PRESET_LAYOUT:format(layoutInfo.layoutName) or layoutInfo.layoutName;

			local radio = rootDescription:CreateRadio(text, IsSelected, SetSelected, index);
			if isUserLayout then
				local copyButton = radio:CreateButton(HUD_EDIT_MODE_COPY_LAYOUT, function()
					self:ShowNewLayoutDialog(layoutInfo);
				end);

				local layoutsMaxed = EditModeManagerFrame:AreLayoutsFullyMaxed();
				if layoutsMaxed or self:HasActiveChanges() then
					copyButton:SetEnabled(false);

					local tooltipText = layoutsMaxed and maxLayoutsCopyErrorText or HUD_EDIT_MODE_ERROR_COPY;
					copyButton:SetTooltip(function(tooltip, elementDescription)
						GameTooltip_SetTitle(tooltip, HUD_EDIT_MODE_COPY_LAYOUT);
						GameTooltip_AddErrorLine(tooltip, tooltipText);
					end);
				end

				radio:CreateButton(HUD_EDIT_MODE_RENAME_LAYOUT, function()
					self:ShowRenameLayoutDialog(index, layoutInfo);
				end);
				
				radio:DeactivateSubmenu();

				radio:AddInitializer(function(button, description, menu)
					local gearButton = MenuTemplates.AttachAutoHideGearButton(button);
					gearButton:SetPoint("RIGHT");
					gearButton:SetScript("OnClick", function()
						description:ForceOpenSubmenu();
					end);
				
					MenuUtil.HookTooltipScripts(gearButton, function(tooltip)
						GameTooltip_SetTitle(tooltip, HUD_EDIT_MODE_RENAME_OR_COPY_LAYOUT);
					end);

					local cancelButton = MenuTemplates.AttachAutoHideCancelButton(button);
					cancelButton:SetPoint("RIGHT", gearButton, "LEFT", -3, 0);
					cancelButton:SetScript("OnClick", function()
						self:ShowDeleteLayoutDialog(index, layoutInfo);
						menu:Close();
					end);

					MenuUtil.HookTooltipScripts(cancelButton, function(tooltip)
						GameTooltip_SetTitle(tooltip, HUD_EDIT_MODE_DELETE_LAYOUT);
					end);
				end);
			else
				radio:AddInitializer(function(button, description, menu)
					local gearButton = MenuTemplates.AttachAutoHideGearButton(button);
					gearButton:SetPoint("RIGHT");
					gearButton:SetScript("OnClick", function()
						self:ShowNewLayoutDialog(layoutInfo);
						menu:Close();
					end);

					MenuUtil.HookTooltipScripts(gearButton, function(tooltip)
						GameTooltip_SetTitle(tooltip, HUD_EDIT_MODE_COPY_LAYOUT);
					end);
				end);
			end
		end

		if hasCharacterLayouts then
			rootDescription:CreateTitle(characterLayoutHeaderText);
		end

		rootDescription:CreateDivider();

		-- new layout
		local disabled = GetDisableReason(disableOnMaxLayouts, not disableOnActiveChanges) ~= nil;
		local text = GetNewLayoutText(disabled);
		local newLayoutButton = rootDescription:CreateButton(text, function()
			self:ShowNewLayoutDialog();
		end);
		SetPresetEnabledState(newLayoutButton, disableOnMaxLayouts, not disableOnActiveChanges);
		
		-- import layout
		local importLayoutButton = rootDescription:CreateButton(HUD_EDIT_MODE_IMPORT_LAYOUT, function()
			self:ShowImportLayoutDialog();
		end);
		SetPresetEnabledState(importLayoutButton, disableOnMaxLayouts, disableOnActiveChanges);

		-- share
		local shareSubmenu = rootDescription:CreateButton(HUD_EDIT_MODE_SHARE_LAYOUT);
		shareSubmenu:CreateButton(HUD_EDIT_MODE_COPY_TO_CLIPBOARD, function()
			self:CopyActiveLayoutToClipboard();
		end);
	end);
end

local function initSystemAnchor(index, systemFrame)
	systemFrame:ClearAllPoints();
	systemFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
end

function EditModeManagerFrameMixin:InitSystemAnchors()
	secureexecuterange(self.registeredSystemFrames, initSystemAnchor);
end

function EditModeManagerFrameMixin:UpdateSystems()
	local function callUpdateSystem(index, systemFrame)
		self:UpdateSystem(systemFrame);
	end
	secureexecuterange(self.registeredSystemFrames, callUpdateSystem);
end

function EditModeManagerFrameMixin:UpdateSystem(systemFrame, forceFullUpdate)
	local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		if forceFullUpdate then
			systemFrame:MarkAllSettingsDirty();
		end

		systemFrame:UpdateSystem(systemInfo);
	end
end

function EditModeManagerFrameMixin:SetOverrideLayout(overrideLayoutIndex)
	local overrideLayouts = EditModePresetLayoutManager:GetCopyOfOverrideLayouts();
	if(not overrideLayouts) then 
		self.overrideLayoutInfo = nil; 
		return;
	end

	local overrideLayout = overrideLayouts[overrideLayoutIndex];
	self.overrideLayoutInfo = overrideLayout or nil; 
	if(overrideLayout) then 
	self:UpdateLayoutInfo(C_EditMode.GetLayouts());
	end		
end

function EditModeManagerFrameMixin:ClearOverrideLayout()
	self.overrideLayoutInfo = nil;
	self:UpdateLayoutInfo(C_EditMode.GetLayouts());
end

function EditModeManagerFrameMixin:GetActiveLayoutInfo()
	if(self.overrideLayoutInfo) then 
		return self.overrideLayoutInfo; 
	else 
	return self.layoutInfo and self.layoutInfo.layouts[self.layoutInfo.activeLayout];
end
end

function EditModeManagerFrameMixin:GetActiveLayoutSystemInfo(system, systemIndex)
	local activeLayoutInfo = self:GetActiveLayoutInfo();
	if activeLayoutInfo then
		for _, systemInfo in ipairs(activeLayoutInfo.systems) do
			if systemInfo.system == system and systemInfo.systemIndex == systemIndex then
				return systemInfo;
			end
		end
	end
end

function EditModeManagerFrameMixin:IsActiveLayoutPreset()
	local activeLayoutInfo = self:GetActiveLayoutInfo();
	return activeLayoutInfo and activeLayoutInfo.layoutType == Enum.EditModeLayoutType.Preset;
end

function EditModeManagerFrameMixin:SelectLayout(layoutIndex)
	if layoutIndex ~= self.layoutInfo.activeLayout then
		self:ClearSelectedSystem();
		C_EditMode.SetActiveLayout(layoutIndex);
		self:NotifyChatOfLayoutChange();
	end
end

function EditModeManagerFrameMixin:IsLayoutSelected(layoutIndex)
	return layoutIndex == self.layoutInfo.activeLayout;
end

function EditModeManagerFrameMixin:ResetDropdownToActiveLayout()
	self:UpdateDropdownOptions();
end

function EditModeManagerFrameMixin:MakeNewLayout(newLayoutInfo, layoutType, layoutName, isLayoutImported)
	if newLayoutInfo and layoutName and layoutName ~= "" and C_EditMode.IsValidLayoutName(layoutName) then
		newLayoutInfo.layoutType = layoutType;
		newLayoutInfo.layoutName = layoutName;

		local newLayoutIndex;
		if self.highestLayoutIndexByType[layoutType] then
			newLayoutIndex = self.highestLayoutIndexByType[layoutType] + 1;
		elseif (layoutType == Enum.EditModeLayoutType.Character) and self.highestLayoutIndexByType[Enum.EditModeLayoutType.Account] then
			newLayoutIndex = self.highestLayoutIndexByType[Enum.EditModeLayoutType.Account] + 1;
		else
			newLayoutIndex = Enum.EditModePresetLayoutsMeta.NumValues + 1;
		end

		local activateNewLayout = not EditModeUnsavedChangesDialog:HasPendingSelectedLayout();

		table.insert(self.layoutInfo.layouts, newLayoutIndex, newLayoutInfo);
		self:SaveLayouts();
		C_EditMode.OnLayoutAdded(newLayoutIndex, activateNewLayout, isLayoutImported);
	end
end

function EditModeManagerFrameMixin:DeleteLayout(layoutIndex)
	local deleteLayoutInfo = self.layoutInfo.layouts[layoutIndex];
	if deleteLayoutInfo and deleteLayoutInfo.layoutType ~= Enum.EditModeLayoutType.Preset then
		table.remove(self.layoutInfo.layouts, layoutIndex);
		self:SaveLayouts();
		C_EditMode.OnLayoutDeleted(layoutIndex);
	end
end

function EditModeManagerFrameMixin:RenameLayout(layoutIndex, layoutName)
	if layoutName ~= "" and C_EditMode.IsValidLayoutName(layoutName) then
		local renameLayoutInfo = self.layoutInfo.layouts[layoutIndex];
		if renameLayoutInfo and renameLayoutInfo.layoutType ~= Enum.EditModeLayoutType.Preset then
			renameLayoutInfo.layoutName = layoutName;
			self:SaveLayouts();
			self:UpdateDropdownOptions();
		end
	end
end

function EditModeManagerFrameMixin:CopyActiveLayoutToClipboard()
	local activeLayoutInfo = self:GetActiveLayoutInfo();
	CopyToClipboard(C_EditMode.ConvertLayoutInfoToString(activeLayoutInfo));
	DEFAULT_CHAT_FRAME:AddMessage(HUD_EDIT_MODE_COPY_TO_CLIPBOARD_NOTICE:format(activeLayoutInfo.layoutName), YELLOW_FONT_COLOR:GetRGB());
end

--[[
function EditModeManagerFrameMixin:LinkActiveLayoutToChat()
	local hyperlink = C_EditMode.ConvertLayoutInfoToHyperlink(self:GetActiveLayoutInfo());
	if not ChatEdit_InsertLink(hyperlink) then
		ChatFrame_OpenChat(hyperlink);
	end
end
]]--

local function clearActiveChangesFlag(index, systemFrame)
	systemFrame:SetHasActiveChanges(false);
end

function EditModeManagerFrameMixin:ClearActiveChangesFlags()
	secureexecuterange(self.registeredSystemFrames, clearActiveChangesFlag);
	self:SetHasActiveChanges(false);
end

function EditModeManagerFrameMixin:ImportLayout(newLayoutInfo, layoutType, layoutName)
	self:RevertAllChanges();

	local isLayoutImportedYes = true;
	self:MakeNewLayout(newLayoutInfo, layoutType, layoutName, isLayoutImportedYes);
end

local function callPrepareForSave(index, systemFrame)
	systemFrame:PrepareForSave();
end

function EditModeManagerFrameMixin:PrepareSystemsForSave()
	secureexecuterange(self.registeredSystemFrames, callPrepareForSave);
end

function EditModeManagerFrameMixin:SaveLayouts()
	self:PrepareSystemsForSave();
	C_EditMode.SaveLayouts(self.layoutInfo);
	self:ClearActiveChangesFlags();
	EventRegistry:TriggerEvent("EditMode.SavedLayouts");
end

function EditModeManagerFrameMixin:SaveLayoutChanges()
	if self:IsActiveLayoutPreset() then
		self:ShowNewLayoutDialog();
	else
		self:SaveLayouts();
	end
end

function EditModeManagerFrameMixin:RevertAllChanges()
	self:ClearSelectedSystem();
	self:UpdateLayoutInfo(C_EditMode.GetLayouts());
	UIParent_ManageFramePositions();
end

function EditModeManagerFrameMixin:ShowNewLayoutDialog(layoutInfo)
	self:ClearSelectedSystem();
	EditModeNewLayoutDialog:ShowDialog(layoutInfo or self:GetActiveLayoutInfo());
end

function EditModeManagerFrameMixin:ShowImportLayoutDialog()
	self:ClearSelectedSystem();
	EditModeImportLayoutDialog:ShowDialog();
end

function EditModeManagerFrameMixin:OpenAndShowImportLayoutLinkDialog(link)
	if not self:IsShown() then
		self:Show();
	end

	EditModeImportLayoutLinkDialog:ShowDialog(link);
end

function EditModeManagerFrameMixin:ShowRenameLayoutDialog(layoutIndex, layoutInfo)
	self:ClearSelectedSystem();

	local function onAcceptCallback(layoutName)
		self:RenameLayout(layoutIndex, layoutName);
	end

	local data = {text = HUD_EDIT_MODE_RENAME_LAYOUT_DIALOG_TITLE, text_arg1 = layoutInfo.layoutName, callback = onAcceptCallback, acceptText = SAVE }
	StaticPopup_ShowCustomGenericInputBox(data);
end

function EditModeManagerFrameMixin:ShowDeleteLayoutDialog(layoutIndex, layoutInfo)
	self:ClearSelectedSystem();

	local function onAcceptCallback()
		self:DeleteLayout(layoutIndex);
	end

	local data = {text = HUD_EDIT_MODE_DELETE_LAYOUT_DIALOG_TITLE, text_arg1 = layoutInfo.layoutName, callback = onAcceptCallback }
	StaticPopup_ShowCustomGenericConfirmation(data);
end

function EditModeManagerFrameMixin:ShowRevertWarningDialog(selectedLayoutIndex)
	self:ClearSelectedSystem();
	EditModeUnsavedChangesDialog:ShowDialog(selectedLayoutIndex);
end

function EditModeManagerFrameMixin:TryShowUnsavedChangesGlow()
	if self:HasActiveChanges() then
		GlowEmitterFactory:Show(self.SaveChangesButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
		return true;
	end
end

function EditModeManagerFrameMixin:ClearUnsavedChangesGlow()
	GlowEmitterFactory:Hide(self.SaveChangesButton);
end

function EditModeManagerFrameMixin:BlockEnteringEditMode(blockingFrame)
	self.FramesBlockingEditMode[blockingFrame] = true;
end

function EditModeManagerFrameMixin:UnblockEnteringEditMode(blockingFrame)
	self.FramesBlockingEditMode[blockingFrame] = nil;
end

function EditModeManagerFrameMixin:CanEnterEditMode()
	local editModeDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.EditModeDisabled);
	return (not editModeDisabled) and (not C_PlayerInfo.IsPlayerNPERestricted()) and TableIsEmpty(self.FramesBlockingEditMode);
end

EditModeGridMixin = {}

function EditModeGridMixin:OnLoad()
	self.linePool = EditModeUtil.CreateLinePool(self, "EditModeGridLineTemplate");

	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	hooksecurefunc("UpdateUIParentPosition", function() if self:IsShown() then self:UpdateGrid() end end);
end

function EditModeGridMixin:OnHide()
	EditModeMagnetismManager:UnregisterGrid();
	self.linePool:ReleaseAll();
end

function EditModeGridMixin:SetGridSpacing(spacing)
	self.gridSpacing = spacing;
	self:UpdateGrid();
end

function EditModeGridMixin:UpdateGrid()
	if not self:IsVisible() then
		return;
	end

	self.linePool:ReleaseAll();
	EditModeMagnetismManager:RegisterGrid(self:GetCenter());

	local centerLine = true;
	local centerLineNo = false;
	local verticalLine = true;
	local verticalLineNo = false;

	local centerVerticalLine = self.linePool:Acquire();
	centerVerticalLine:SetupLine(centerLine, verticalLine, 0, 0);
	centerVerticalLine:Show();

	local centerHorizontalLine = self.linePool:Acquire();
	centerHorizontalLine:SetupLine(centerLine, verticalLineNo, 0, 0);
	centerHorizontalLine:Show();

	local halfNumVerticalLines = floor((self:GetWidth() / self.gridSpacing) / 2);
	local halfNumHorizontalLines = floor((self:GetHeight() / self.gridSpacing) / 2);

	for i = 1, halfNumVerticalLines do
		local xOffset = i * self.gridSpacing;

		local line = self.linePool:Acquire();
		line:SetupLine(centerLineNo, verticalLine, xOffset, 0);
		line:Show();

		line = self.linePool:Acquire();
		line:SetupLine(centerLineNo, verticalLine, -xOffset, 0);
		line:Show();
	end

	for i = 1, halfNumHorizontalLines do
		local yOffset = i * self.gridSpacing;

		local line = self.linePool:Acquire();
		line:SetupLine(centerLineNo, verticalLineNo, 0, yOffset);
		line:Show();

		line = self.linePool:Acquire();
		line:SetupLine(centerLineNo, verticalLineNo, 0, -yOffset);
		line:Show();
	end
end

EditModeGridSpacingSliderMixin = {};

function EditModeGridSpacingSliderMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.cbrHandles = EventUtil.CreateCallbackHandleContainer();
	self.cbrHandles:RegisterCallback(self.Slider, MinimalSliderWithSteppersMixin.Event.OnValueChanged, self.OnSliderValueChanged, self);

	self.formatters = {};
	self.formatters[MinimalSliderWithSteppersMixin.Label.Right] = CreateMinimalSliderFormatter(MinimalSliderWithSteppersMixin.Label.Right);
end

local minSpacing = Constants.EditModeConsts.EditModeMinGridSpacing;
local maxSpacing = Constants.EditModeConsts.EditModeMaxGridSpacing;
local spacingStepSize = 10;
local numSteps = (maxSpacing - minSpacing) / spacingStepSize;

function EditModeGridSpacingSliderMixin:SetupSlider(gridSpacing)
	self.Slider:Init(gridSpacing, minSpacing, maxSpacing, numSteps, self.formatters);
end

function EditModeGridSpacingSliderMixin:SetEnabled(enabled)
	self.Slider:SetEnabled(enabled);
end

function EditModeGridSpacingSliderMixin:OnSliderValueChanged(value)
	local isUserInput = true;
	EditModeManagerFrame:SetGridSpacing(value, isUserInput);
end

EditModeAccountSettingsMixin = {};

function EditModeAccountSettingsMixin:OnLoad()
	self.settingsCheckButtons = {};

	local function onTargetAndFocusCheckboxChecked(isChecked, isUserInput)
		self:SetTargetAndFocusShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.TargetAndFocus = self.SettingsContainer.TargetAndFocus;
	self.settingsCheckButtons.TargetAndFocus:SetCallback(onTargetAndFocusCheckboxChecked);

	local function onPartyFramesCheckboxChecked(isChecked, isUserInput)
		self:SetPartyFramesShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.PartyFrames = self.SettingsContainer.PartyFrames;
	self.settingsCheckButtons.PartyFrames:SetCallback(onPartyFramesCheckboxChecked);

	local function onRaidFramesCheckboxChecked(isChecked, isUserInput)
		self:SetRaidFramesShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.RaidFrames = self.SettingsContainer.RaidFrames;
	self.settingsCheckButtons.RaidFrames:SetCallback(onRaidFramesCheckboxChecked);

	local function onStanceBarCheckboxChecked(isChecked, isUserInput)
		self:SetActionBarShown(StanceBar, isChecked, isUserInput);
	end
	self.settingsCheckButtons.StanceBar = self.SettingsContainer.StanceBar;
	self.settingsCheckButtons.StanceBar:SetCallback(onStanceBarCheckboxChecked);

	local function onPetActionBarCheckboxChecked(isChecked, isUserInput)
		self:SetActionBarShown(PetActionBar, isChecked, isUserInput);
	end
	self.settingsCheckButtons.PetActionBar = self.SettingsContainer.PetActionBar;
	self.settingsCheckButtons.PetActionBar:SetCallback(onPetActionBarCheckboxChecked);

	local function onPossessActionBarCheckboxChecked(isChecked, isUserInput)
		self:SetActionBarShown(PossessActionBar, isChecked, isUserInput);
	end
	self.settingsCheckButtons.PossessActionBar = self.SettingsContainer.PossessActionBar;
	self.settingsCheckButtons.PossessActionBar:SetCallback(onPossessActionBarCheckboxChecked);

	local function onCastBarCheckboxChecked(isChecked, isUserInput)
		self:SetCastBarShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.CastBar = self.SettingsContainer.CastBar;
	self.settingsCheckButtons.CastBar:SetCallback(onCastBarCheckboxChecked);

	local function onEncounterBarCheckboxChecked(isChecked, isUserInput)
		self:SetEncounterBarShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.EncounterBar = self.SettingsContainer.EncounterBar;
	self.settingsCheckButtons.EncounterBar:SetCallback(onEncounterBarCheckboxChecked);

	local function onExtraAbilitiesCheckboxChecked(isChecked, isUserInput)
		self:SetExtraAbilitiesShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.ExtraAbilities = self.SettingsContainer.ExtraAbilities;
	self.settingsCheckButtons.ExtraAbilities:SetCallback(onExtraAbilitiesCheckboxChecked);

	local function onBuffsAndDebuffsCheckboxChecked(isChecked, isUserInput)
		self:SetBuffsAndDebuffsShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.BuffsAndDebuffs = self.SettingsContainer.BuffsAndDebuffs;
	self.settingsCheckButtons.BuffsAndDebuffs:SetCallback(onBuffsAndDebuffsCheckboxChecked);

	local function onTalkingHeadFrameCheckboxChecked(isChecked, isUserInput)
		self:SetTalkingHeadFrameShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.TalkingHeadFrame = self.SettingsContainer.TalkingHeadFrame;
	self.settingsCheckButtons.TalkingHeadFrame:SetCallback(onTalkingHeadFrameCheckboxChecked);

	local function onVehicleLeaveButtonCheckboxChecked(isChecked, isUserInput)
		self:SetVehicleLeaveButtonShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.VehicleLeaveButton = self.SettingsContainer.VehicleLeaveButton;
	self.settingsCheckButtons.VehicleLeaveButton:SetCallback(onVehicleLeaveButtonCheckboxChecked);

	local function onBossFramesCheckboxChecked(isChecked, isUserInput)
		self:SetBossFramesShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.BossFrames = self.SettingsContainer.BossFrames;
	self.settingsCheckButtons.BossFrames:SetCallback(onBossFramesCheckboxChecked);

	local function onArenaFramesCheckboxChecked(isChecked, isUserInput)
		self:SetArenaFramesShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.ArenaFrames = self.SettingsContainer.ArenaFrames;
	self.settingsCheckButtons.ArenaFrames:SetCallback(onArenaFramesCheckboxChecked);

	local function onLootFrameCheckboxChecked(isChecked, isUserInput)
		self:SetLootFrameShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.LootFrame = self.SettingsContainer.LootFrame;
	self.settingsCheckButtons.LootFrame:SetCallback(onLootFrameCheckboxChecked);

	local function onHudTooltipCheckboxChecked(isChecked, isUserInput)
		self:SetHudTooltipShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.HudTooltip = self.SettingsContainer.HudTooltip;
	self.settingsCheckButtons.HudTooltip:SetCallback(onHudTooltipCheckboxChecked);

	local function onStatusTrackingBar2CheckboxChecked(isChecked, isUserInput)
		self:SetStatusTrackingBar2Shown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.StatusTrackingBar2 = self.SettingsContainer.StatusTrackingBar2;
	self.settingsCheckButtons.StatusTrackingBar2:SetCallback(onStatusTrackingBar2CheckboxChecked);

	local function onDurabilityFrameCheckboxChecked(isChecked, isUserInput)
		self:SetDurabilityFrameShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.DurabilityFrame = self.SettingsContainer.DurabilityFrame;
	self.settingsCheckButtons.DurabilityFrame:SetCallback(onDurabilityFrameCheckboxChecked);

	local function onPetFrameCheckboxChecked(isChecked, isUserInput)
		self:SetPetFrameShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.PetFrame = self.SettingsContainer.PetFrame;
	self.settingsCheckButtons.PetFrame:SetCallback(onPetFrameCheckboxChecked);

	local function onTimerBarsCheckboxChecked(isChecked, isUserInput)
		self:SetTimerBarsShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.TimerBars = self.SettingsContainer.TimerBars;
	self.settingsCheckButtons.TimerBars:SetCallback(onTimerBarsCheckboxChecked);

	local function onVehicleSeatIndicatorCheckboxChecked(isChecked, isUserInput)
		self:SetVehicleSeatIndicatorShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.VehicleSeatIndicator = self.SettingsContainer.VehicleSeatIndicator;
	self.settingsCheckButtons.VehicleSeatIndicator:SetCallback(onVehicleSeatIndicatorCheckboxChecked);

	local function onArchaeologyBarCheckboxChecked(isChecked, isUserInput)
		self:SetArchaeologyBarShown(isChecked, isUserInput);
	end
	self.settingsCheckButtons.ArchaeologyBar = self.SettingsContainer.ArchaeologyBar;
	self.settingsCheckButtons.ArchaeologyBar:SetCallback(onArchaeologyBarCheckboxChecked);

	self:LayoutSettings();
end

function EditModeAccountSettingsMixin:OnEvent(event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		self.oldTargetName = UnitName("target");
		if not self.oldTargetName then
			-- Unregister before setting so we don't fall back into this OnEvent from this change
			self:UnregisterEvent("PLAYER_TARGET_CHANGED");
			TargetUnit("player");
			self:RegisterEvent("PLAYER_TARGET_CHANGED");
		end
	elseif event == "PLAYER_FOCUS_CHANGED" then
		self.oldFocusName = UnitName("focus");
		if not self.oldFocusName then
			-- Unregister before setting so we don't fall back into this OnEvent from this change
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED");
			FocusUnit("player");
			self:RegisterEvent("PLAYER_FOCUS_CHANGED");
		end
	end
end

function EditModeAccountSettingsMixin:OnEditModeEnter()
	self.oldActionBarSettings = {};
	self:SetupActionBar(StanceBar);
	self:SetupActionBar(PetActionBar);
	self:SetupActionBar(PossessActionBar);

	self:SetupStatusTrackingBar2();
	self:SetupDurabilityFrame();
	self:SetupPetFrame();
	self:SetupEncounterBar();
	self:SetupTimerBars();
	self:SetupVehicleSeatIndicator();
	self:SetupArchaeologyBar();

	self:RefreshTargetAndFocus();
	self:RefreshPartyFrames();
	self:RefreshRaidFrames()
	self:RefreshCastBar();
	self:RefreshEncounterBar();
	self:RefreshExtraAbilities();
	self:RefreshBuffsAndDebuffs();
	self:RefreshTalkingHeadFrame();
	self:RefreshVehicleLeaveButton();
	self:RefreshBossFrames();
	self:RefreshArenaFrames();
	self:RefreshLootFrame();
	self:RefreshHudTooltip();
	self:RefreshStatusTrackingBar2();
	self:RefreshDurabilityFrame();
	self:RefreshPetFrame();
	self:RefreshTimerBars();
	self:RefreshVehicleSeatIndicator();
	self:RefreshArchaeologyBar();
end

function EditModeAccountSettingsMixin:OnEditModeExit()
	self:ResetTargetAndFocus();
	self:ResetPartyFrames();
	self:ResetRaidFrames();
	self:ResetArenaFrames();
	self:ResetHudTooltip();

	self:ResetActionBarShown(StanceBar);
	self:ResetActionBarShown(PetActionBar);
	self:ResetActionBarShown(PossessActionBar);
end

function EditModeAccountSettingsMixin:LayoutSettings()
	local showAdvancedOptions = EditModeManagerFrame:AreAdvancedOptionsEnabled();
	for _, checkButton in pairs(self.settingsCheckButtons) do
		if showAdvancedOptions then
			if checkButton.category == EditModeManagerOptionsCategory.Frames then
				checkButton:SetParent(self.SettingsContainer.ScrollChild.AdvancedOptionsContainer.FramesContainer);
			elseif checkButton.category == EditModeManagerOptionsCategory.Combat then
				checkButton:SetParent(self.SettingsContainer.ScrollChild.AdvancedOptionsContainer.CombatContainer);
			else -- Misc
				checkButton:SetParent(self.SettingsContainer.ScrollChild.AdvancedOptionsContainer.MiscContainer);
			end

			checkButton.layoutIndex = checkButton.advancedLayoutIndex;
			checkButton:Show();
		else -- Only show basic options
			checkButton:SetParent(self.SettingsContainer.ScrollChild.BasicOptionsContainer);

			checkButton.layoutIndex = checkButton.basicLayoutIndex;
			checkButton:SetShown(checkButton.isBasicOption);
		end
	end

	self.SettingsContainer.ScrollChild.BasicOptionsContainer:SetShown(not showAdvancedOptions);
	self.SettingsContainer.ScrollChild.AdvancedOptionsContainer:SetShown(showAdvancedOptions);

	EditModeManagerFrame:Layout();
end

function EditModeAccountSettingsMixin:ResetTargetAndFocus()
	self:UnregisterEvent("PLAYER_TARGET_CHANGED");
	self:UnregisterEvent("PLAYER_FOCUS_CHANGED");

	if self.oldTargetName then
		TargetUnit(self.oldTargetName);
	else
		ClearTarget();
	end
	self.oldTargetName = nil;

	if self.oldFocusName then
		FocusUnit(self.oldFocusName);
	else
		ClearFocus();
	end
	self.oldFocusName = nil;

	TargetFrame:ClearHighlight();
	FocusFrame:ClearHighlight();
end

function EditModeAccountSettingsMixin:RefreshTargetAndFocus()
	local showTargetAndFocus = self.settingsCheckButtons.TargetAndFocus:IsControlChecked();
	if showTargetAndFocus then
		self.oldTargetName = UnitName("target");
		self.oldFocusName = UnitName("focus");

		if not TargetFrame:IsShown() then
			TargetUnit("player");
		end

		if not FocusFrame:IsShown() then
			FocusUnit("player");
		end

		TargetFrame:HighlightSystem();
		FocusFrame:HighlightSystem();

		self:RegisterEvent("PLAYER_TARGET_CHANGED");
		self:RegisterEvent("PLAYER_FOCUS_CHANGED");
	else
		self:ResetTargetAndFocus();
	end
end

function EditModeAccountSettingsMixin:SetTargetAndFocusShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowTargetAndFocus, shown);
		self:RefreshTargetAndFocus();
	else
		self.settingsCheckButtons.TargetAndFocus:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshPartyFrames()
	local showPartyFrames = self.settingsCheckButtons.PartyFrames:IsControlChecked();
	if showPartyFrames then
		PartyFrame:HighlightSystem();
		PartyFrame:Raise();
	else
		PartyFrame:ClearHighlight();
	end

	CompactPartyFrame:RefreshMembers();
	UpdateRaidAndPartyFrames();
end

function EditModeAccountSettingsMixin:ResetPartyFrames()
	CompactPartyFrame:RefreshMembers();
	UpdateRaidAndPartyFrames();
end

function EditModeAccountSettingsMixin:SetPartyFramesShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowPartyFrames, shown);
		self:RefreshPartyFrames();
	else
		self.settingsCheckButtons.PartyFrames:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshRaidFrames()
	local showRaidFrames = self.settingsCheckButtons.RaidFrames:IsControlChecked();
	if showRaidFrames then
		CompactRaidFrameManager_SetSetting("IsShown", true);
		CompactRaidFrameContainer:HighlightSystem();
	else
		CompactRaidFrameContainer:ClearHighlight();
	end

	CompactRaidFrameContainer:ApplyToFrames("group", CompactRaidGroup_UpdateUnits);
	CompactRaidFrameContainer:TryUpdate();
	EditModeManagerFrame:UpdateRaidContainerFlow();
	UpdateRaidAndPartyFrames();
end

function EditModeAccountSettingsMixin:ResetRaidFrames()
	CompactRaidFrameContainer:ApplyToFrames("group", CompactRaidGroup_UpdateUnits);
	CompactRaidFrameContainer:TryUpdate();
	EditModeManagerFrame:UpdateRaidContainerFlow();
end

function EditModeAccountSettingsMixin:SetRaidFramesShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowRaidFrames, shown);
		self:RefreshRaidFrames();
	else
		self.settingsCheckButtons.RaidFrames:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:SetupActionBar(bar)
	local isShown = bar:IsShown();
	self.oldActionBarSettings[bar] = {
		isShown = isShown;
	}

	-- If the bar is already showing then set control checked
	if isShown then
		self.settingsCheckButtons[bar:GetName()]:SetControlChecked(true);
	end

	self:RefreshActionBarShown(bar);
end

function EditModeAccountSettingsMixin:ResetActionBarShown(bar)
	bar.editModeForceShow = false;
	bar:SetShown(self.oldActionBarSettings[bar].isShown);
end

function EditModeAccountSettingsMixin:RefreshActionBarShown(bar)
	local barName = bar:GetName();
	local show = self.settingsCheckButtons[barName]:IsControlChecked();

	if show then
		bar.editModeForceShow = true;
		bar:Show();
		bar:HighlightSystem();
	else
		self:ResetActionBarShown(bar);
		bar:ClearHighlight();
	end
end

function EditModeAccountSettingsMixin:SetActionBarShown(bar, shown, isUserInput)
	local barName = bar:GetName();
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting["Show"..barName], shown);
		self:RefreshActionBarShown(bar);
	else
		self.settingsCheckButtons[barName]:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:SetCastBarShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowCastBar, shown);
		self:RefreshCastBar();
	else
		self.settingsCheckButtons.CastBar:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshCastBar()
	local showCastBar = self.settingsCheckButtons.CastBar:IsControlChecked();
	if showCastBar then
		PlayerCastingBarFrame.isInEditMode = true;
		PlayerCastingBarFrame:HighlightSystem();
	else
		PlayerCastingBarFrame.isInEditMode = false;
		PlayerCastingBarFrame:ClearHighlight();
	end
	PlayerCastingBarFrame:UpdateShownState();
end

function EditModeAccountSettingsMixin:SetupEncounterBar()
	-- If encounter bar is showing and has content showing then auto enable the setting
	if EncounterBar:IsShown() and EncounterBar:HasContentShowing() then
		self.settingsCheckButtons.EncounterBar:SetControlChecked(true);
	end
end

function EditModeAccountSettingsMixin:SetEncounterBarShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowEncounterBar, shown);
		self:RefreshEncounterBar();
	else
		self.settingsCheckButtons.EncounterBar:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshEncounterBar()
	local showEncounterbar = self.settingsCheckButtons.EncounterBar:IsControlChecked();
	if showEncounterbar then
		EncounterBar.minimumWidth = 230;
		EncounterBar.minimumHeight = 30;
		EncounterBar:HighlightSystem();
	else
		EncounterBar.minimumWidth = 1;
		EncounterBar.minimumHeight = 1;
		EncounterBar:ClearHighlight();
	end

	EncounterBar:Layout();
	UIParent_ManageFramePositions();
end

function EditModeAccountSettingsMixin:SetExtraAbilitiesShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowExtraAbilities, shown);
		self:RefreshExtraAbilities();
	else
		self.settingsCheckButtons.ExtraAbilities:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshExtraAbilities()
	local showExtraAbilities = self.settingsCheckButtons.ExtraAbilities:IsControlChecked();
	if showExtraAbilities then
		ExtraAbilityContainer.isInEditMode = true;
		ExtraAbilityContainer:HighlightSystem();
	else
		ExtraAbilityContainer.isInEditMode = false;
		ExtraAbilityContainer:ClearHighlight();
	end

	ExtraAbilityContainer:UpdateShownState();
end

function EditModeAccountSettingsMixin:SetBuffsAndDebuffsShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowBuffsAndDebuffs, shown);
		self:RefreshBuffsAndDebuffs();
	else
		self.settingsCheckButtons.BuffsAndDebuffs:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshBuffsAndDebuffs()
	local showBuffsAndDebuffs = self.settingsCheckButtons.BuffsAndDebuffs:IsControlChecked();

	if showBuffsAndDebuffs then
		BuffFrame.isInEditMode = true;
		DebuffFrame.isInEditMode = true;
		BuffFrame:HighlightSystem();
		DebuffFrame:HighlightSystem();
	else
		BuffFrame.isInEditMode = false;
		DebuffFrame.isInEditMode = false;
		BuffFrame:ClearHighlight();
		DebuffFrame:ClearHighlight();
	end

	BuffFrame:UpdateAuraButtons();
	DebuffFrame:UpdateAuraButtons();
end

function EditModeAccountSettingsMixin:SetTalkingHeadFrameShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowTalkingHeadFrame, shown);
		self:RefreshTalkingHeadFrame();
	else
		self.settingsCheckButtons.TalkingHeadFrame:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshTalkingHeadFrame()
	local showTalkingHeadFrame = self.settingsCheckButtons.TalkingHeadFrame:IsControlChecked();
	if showTalkingHeadFrame then
		TalkingHeadFrame.isInEditMode = true;
		TalkingHeadFrame:HighlightSystem();
	else
		TalkingHeadFrame.isInEditMode = false;
		TalkingHeadFrame:ClearHighlight();
	end

	TalkingHeadFrame:UpdateShownState();
	UIParent_ManageFramePositions();
end

function EditModeAccountSettingsMixin:SetVehicleLeaveButtonShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowVehicleLeaveButton, shown);
		self:RefreshVehicleLeaveButton();
	else
		self.settingsCheckButtons.VehicleLeaveButton:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshVehicleLeaveButton()
	local showVehicleLeaveButton = self.settingsCheckButtons.VehicleLeaveButton:IsControlChecked();
	if showVehicleLeaveButton then
		MainMenuBarVehicleLeaveButton.isInEditMode = true;
		MainMenuBarVehicleLeaveButton:HighlightSystem();
	else
		MainMenuBarVehicleLeaveButton.isInEditMode = false;
		MainMenuBarVehicleLeaveButton:ClearHighlight();
	end

	MainMenuBarVehicleLeaveButton:UpdateShownState();
end

function EditModeAccountSettingsMixin:SetBossFramesShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowBossFrames, shown);
		self:RefreshBossFrames();
	else
		self.settingsCheckButtons.BossFrames:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshBossFrames()
	local showBossFrames = self.settingsCheckButtons.BossFrames:IsControlChecked();
	if showBossFrames then
		BossTargetFrameContainer.isInEditMode = true;
		BossTargetFrameContainer:HighlightSystem();
	else
		BossTargetFrameContainer.isInEditMode = false;
		BossTargetFrameContainer:ClearHighlight();
	end

	BossTargetFrameContainer:UpdateShownState();
end

function EditModeAccountSettingsMixin:SetArenaFramesShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowArenaFrames, shown);
		self:RefreshArenaFrames();
	else
		self.settingsCheckButtons.ArenaFrames:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshArenaFrames()
	local showArenaFrames = self.settingsCheckButtons.ArenaFrames:IsControlChecked();
	CompactArenaFrame:SetIsInEditMode(showArenaFrames);
end

function EditModeAccountSettingsMixin:ResetArenaFrames()
	CompactArenaFrame:SetIsInEditMode(false);
end

function EditModeAccountSettingsMixin:SetLootFrameShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowLootFrame, shown);
		self:RefreshLootFrame();
	else
		self.settingsCheckButtons.LootFrame:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshLootFrame()
	local showLootFrame = self.settingsCheckButtons.LootFrame:IsControlChecked() and GetCVar("lootUnderMouse") ~= "1";
	if showLootFrame then
		LootFrame.isInEditMode = true;
		LootFrame:HighlightSystem();
	else
		LootFrame.isInEditMode = false;
		LootFrame:ClearHighlight();
	end

	LootFrame:UpdateShownState();
end

function EditModeAccountSettingsMixin:SetHudTooltipShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowHudTooltip, shown);
		self:RefreshHudTooltip();
	else
		self.settingsCheckButtons.HudTooltip:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshHudTooltip()
	local showHudTooltip = self.settingsCheckButtons.HudTooltip:IsControlChecked();
	if showHudTooltip then
		GameTooltip_Hide();
		GameTooltipDefaultContainer:Show();
	else
		GameTooltipDefaultContainer:Hide();
	end
end

function EditModeAccountSettingsMixin:ResetHudTooltip()
	GameTooltipDefaultContainer:Hide();
end

function EditModeAccountSettingsMixin:SetStatusTrackingBar2Shown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowStatusTrackingBar2, shown);
		self:RefreshStatusTrackingBar2();
	else
		self.settingsCheckButtons.StatusTrackingBar2:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:SetupStatusTrackingBar2()
	self.settingsCheckButtons.StatusTrackingBar2:SetLabelText(SecondaryStatusTrackingBarContainer:GetSystemName());

	if SecondaryStatusTrackingBarContainer:IsShown() then
		self.settingsCheckButtons.StatusTrackingBar2:SetControlChecked(true);
	end
end

function EditModeAccountSettingsMixin:RefreshStatusTrackingBar2()
	local showStatusTrackingBar2 = self.settingsCheckButtons.StatusTrackingBar2:IsControlChecked();
	if showStatusTrackingBar2 then
		SecondaryStatusTrackingBarContainer.isInEditMode = true;
		SecondaryStatusTrackingBarContainer:HighlightSystem();
	else
		SecondaryStatusTrackingBarContainer.isInEditMode = false;
		SecondaryStatusTrackingBarContainer:ClearHighlight();
	end
	SecondaryStatusTrackingBarContainer:UpdateShownState();
end

function EditModeAccountSettingsMixin:SetupDurabilityFrame()
	-- If the frame is already showing then set control checked
	if DurabilityFrame:IsShown() then
		self.settingsCheckButtons.DurabilityFrame:SetControlChecked(true);
	end
end

function EditModeAccountSettingsMixin:SetDurabilityFrameShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowDurabilityFrame, shown);
		self:RefreshDurabilityFrame();
	else
		self.settingsCheckButtons.DurabilityFrame:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshDurabilityFrame()
	local showDurabilityFrame = self.settingsCheckButtons.DurabilityFrame:IsControlChecked();
	if showDurabilityFrame then
		DurabilityFrame.isInEditMode = true;
		DurabilityFrame:HighlightSystem();
	else
		DurabilityFrame.isInEditMode = false;
		DurabilityFrame:ClearHighlight();
	end

	DurabilityFrame:UpdateShownState();
end

function EditModeAccountSettingsMixin:SetupPetFrame()
	-- If the frame is already showing then set control checked
	if PetFrame:IsShown() then
		self.settingsCheckButtons.PetFrame:SetControlChecked(true);
	end
end

function EditModeAccountSettingsMixin:SetPetFrameShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowPetFrame, shown);
		self:RefreshPetFrame();
	else
		self.settingsCheckButtons.PetFrame:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshPetFrame()
	local showPetFrame = self.settingsCheckButtons.PetFrame:IsControlChecked();
	if showPetFrame then
		PetFrame.isInEditMode = true;
		PetFrame:HighlightSystem();
	else
		PetFrame.isInEditMode = false;
		PetFrame:ClearHighlight();
	end

	PetFrame:UpdateShownState();
end

function EditModeAccountSettingsMixin:SetupTimerBars()
	-- If the frame is already showing then set control checked
	if MirrorTimerContainer:HasAnyTimersShowing() then
		self.settingsCheckButtons.TimerBars:SetControlChecked(true);
	end
end

function EditModeAccountSettingsMixin:SetTimerBarsShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowTimerBars, shown);
		self:RefreshTimerBars();
	else
		self.settingsCheckButtons.TimerBars:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshTimerBars()
	local showTimerBars = self.settingsCheckButtons.TimerBars:IsControlChecked();
	MirrorTimerContainer:SetIsInEditMode(showTimerBars);
	if showTimerBars then
		MirrorTimerContainer:HighlightSystem();
	else
		MirrorTimerContainer:ClearHighlight();
	end
end

function EditModeAccountSettingsMixin:SetupVehicleSeatIndicator()
	-- If the frame is already showing then set control checked
	if VehicleSeatIndicator:IsShown() then
		self.settingsCheckButtons.VehicleSeatIndicator:SetControlChecked(true);
	end
end

function EditModeAccountSettingsMixin:SetVehicleSeatIndicatorShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowVehicleSeatIndicator, shown);
		self:RefreshVehicleSeatIndicator();
	else
		self.settingsCheckButtons.VehicleSeatIndicator:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshVehicleSeatIndicator()
	local showVehicleSeatIndicator = self.settingsCheckButtons.VehicleSeatIndicator:IsControlChecked();
	VehicleSeatIndicator:SetIsInEditMode(showVehicleSeatIndicator);
	if showVehicleSeatIndicator then
		VehicleSeatIndicator:HighlightSystem();
	else
		VehicleSeatIndicator:ClearHighlight();
	end
end

function EditModeAccountSettingsMixin:SetupArchaeologyBar()
	-- If the frame is already showing then set control checked
	if ArcheologyDigsiteProgressBar:IsShown() then
		self.settingsCheckButtons.ArchaeologyBar:SetControlChecked(true);
	end
end

function EditModeAccountSettingsMixin:SetArchaeologyBarShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowArchaeologyBar, shown);
		self:RefreshArchaeologyBar();
	else
		self.settingsCheckButtons.ArchaeologyBar:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshArchaeologyBar()
	local showArchaeologyBar = self.settingsCheckButtons.ArchaeologyBar:IsControlChecked();
	ArcheologyDigsiteProgressBar:SetIsInEditMode(showArchaeologyBar);
	if showArchaeologyBar then
		ArcheologyDigsiteProgressBar:HighlightSystem();
	else
		ArcheologyDigsiteProgressBar:ClearHighlight();
	end
end

function EditModeAccountSettingsMixin:SetExpandedState(expanded, isUserInput)
	self.expanded = expanded;
	self.Expander.Label:SetText(expanded and HUD_EDIT_MODE_COLLAPSE_OPTIONS or HUD_EDIT_MODE_EXPAND_OPTIONS);

	self.SettingsContainer:SetShown(self.expanded);
	if self.expanded then
		self:LayoutSettings();
	else
		EditModeManagerFrame:Layout();
	end

	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.SettingsExpanded, expanded);
	end
end

function EditModeAccountSettingsMixin:ToggleExpandedState()
	local isUserInput = true;
	self:SetExpandedState(not self.expanded, isUserInput);
end

EditModeManagerTutorialMixin = {};

local HelpTipInfos = {
	[1] = { text = EDIT_MODE_HELPTIPS_LAYOUTS, buttonStyle = HelpTip.ButtonStyle.Next, offsetX = 0, offsetY = 0, targetPoint = HelpTip.Point.RightEdgeCenter, relativeRegionParentKey="LayoutDropdown",
			cvarBitfield = "closedInfoFramesAccountWide", bitfieldFlag = LE_FRAME_TUTORIAL_ACCOUNT_EDIT_MODE_MANAGER, useParentStrata = true },
	[2] = { text = EDIT_MODE_HELPTIPS_SHOW_HIDDEN_FRAMES, buttonStyle = HelpTip.ButtonStyle.Next, offsetX = 0, offsetY = 0, targetPoint = HelpTip.Point.RightEdgeCenter, relativeRegionParentKey="AccountSettings",
			cvarBitfield = "closedInfoFramesAccountWide", bitfieldFlag = LE_FRAME_TUTORIAL_ACCOUNT_EDIT_MODE_MANAGER, useParentStrata = true },
	[3] = { text = EDIT_MODE_HELPTIPS_ADVANCED_OPTIONS, buttonStyle = HelpTip.ButtonStyle.Next, offsetX = 0, offsetY = 0, targetPoint = HelpTip.Point.RightEdgeCenter, relativeRegionParentKey="EnableAdvancedOptionsCheckButton",
			cvarBitfield = "closedInfoFramesAccountWide", bitfieldFlag = LE_FRAME_TUTORIAL_ACCOUNT_EDIT_MODE_MANAGER, useParentStrata = true },
	[4] = { text = EDIT_MODE_HELPTIPS_SELECT_FRAMES, buttonStyle = HelpTip.ButtonStyle.GotIt, offsetX = 0, offsetY = 0, targetPoint = HelpTip.Point.BottomEdgeCenter, hideArrow = true,
			cvarBitfield = "closedInfoFramesAccountWide", bitfieldFlag = LE_FRAME_TUTORIAL_ACCOUNT_EDIT_MODE_MANAGER, useParentStrata = true },
};

function EditModeManagerTutorialMixin:OnLoad()
	local onAcknowledgeCallback = GenerateClosure(self.ProgressHelpTips, self);
	for index, helpTipInfo in ipairs(HelpTipInfos) do
		helpTipInfo.onAcknowledgeCallback = onAcknowledgeCallback;
	end
end

function EditModeManagerTutorialMixin:OnShow()
	if not GetCVarBitfield("closedInfoFramesAccountWide", LE_FRAME_TUTORIAL_ACCOUNT_EDIT_MODE_MANAGER) then
		self:BeginHelpTips();
	end
end

function EditModeManagerTutorialMixin:OnClick()
	if HelpTip:IsShowingAny(self) then
		HelpTip:HideAll(self);
	else
		self:BeginHelpTips();
	end
end

function EditModeManagerTutorialMixin:BeginHelpTips()
	-- Expand the account setttings for the help tips
	local expanded = true;
	local isUserInput = false;
	EditModeManagerFrame.AccountSettings:SetExpandedState(expanded, isUserInput)

	self.currentTipIndex = 1;
	self:ShowHelpTip();
end

function EditModeManagerTutorialMixin:ShowHelpTip()
	local helpTipInfo = HelpTipInfos[self.currentTipIndex];
	if helpTipInfo then
		local relativeRegion = helpTipInfo.relativeRegionParentKey and EditModeManagerFrame[helpTipInfo.relativeRegionParentKey] or EditModeManagerFrame;
		HelpTip:Show(self, helpTipInfo, relativeRegion);
	end
end

function EditModeManagerTutorialMixin:ProgressHelpTips()
	self.currentTipIndex = self.currentTipIndex + 1;

	if self.currentTipIndex > #HelpTipInfos then
		HelpTip:HideAll(self);
		return;
	end

	self:ShowHelpTip();
end

EditModeLootFrameCheckButtonMixin = {};

-- Override
function EditModeLootFrameCheckButtonMixin:ShouldEnable()
	return GetCVar("lootUnderMouse") ~= "1";
end