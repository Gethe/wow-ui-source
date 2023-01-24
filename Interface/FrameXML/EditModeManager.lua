EditModeManagerFrameMixin = {};

function EditModeManagerFrameMixin:OnLoad()
	self.registeredSystemFrames = {};
	self.modernSystemMap = EditModePresetLayoutManager:GetModernSystemMap();
	self.modernSystems = EditModePresetLayoutManager:GetModernSystems();

	self.LayoutDropdown:AddTopLabel(HUD_EDIT_MODE_LAYOUT);
	self.LayoutDropdown:SetTextJustifyH("LEFT");

	self.buttonEntryPool = CreateFramePool("FRAME", self, "EditModeDropdownEntryTemplate");
	self.layoutEntryPool = CreateFramePool("FRAME", self, "EditModeDropdownLayoutEntryTemplate");

	local function clearLockedLayoutButton()
		self:ClearLockedLayoutButton();
	end

	self.LayoutDropdown.DropDownMenu.onHide = clearLockedLayoutButton;

	local function createNewLayout()
		self:ShowNewLayoutDialog();
	end

	local function importLayout()
		self:ShowImportLayoutDialog();
	end

	local function shareLayout(layoutButton)
		self:ToggleShareDropdown(layoutButton);
	end

	local function copyToClipboard()
		self:CopyActiveLayoutToClipboard();
	end

	--[[
	local function postInChat()
		self:LinkActiveLayoutToChat();
	end
	]]--

	local function copyLayout()
		self:ShowNewLayoutDialog(self.lockedLayoutButton.layoutData);
	end

	local function renameLayout()
		self:ShowRenameLayoutDialog(self.lockedLayoutButton);
	end

	local function selectLayout(layoutButton)
		UIDropDownMenuButton_OnClick(layoutButton.owningButton);
	end

	local newLayoutButtonText = HUD_EDIT_MODE_NEW_LAYOUT:format(CreateAtlasMarkup("editmode-new-layout-plus"));
	local newLayoutButtonTextDisabled = HUD_EDIT_MODE_NEW_LAYOUT_DISABLED:format(CreateAtlasMarkup("editmode-new-layout-plus-disabled"));
	local dropdownButtonWidth = 210;
	local shareDropdownButtonMaxTextWidth = 190;
	local copyRenameSubDropdownButtonWidth = 150;
	local subMenuButton = true;
	local disableOnMaxLayouts = true;
	local disableOnMaxLayoutsNo = false;
	local disableOnActiveChanges = true;
	local disableOnActiveChangesNo = false;

	local function layoutEntryCustomSetup(dropDownButtonInfo, standardFunc)
		if dropDownButtonInfo.value == "newLayout" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(newLayoutButtonText, createNewLayout, disableOnMaxLayouts, disableOnActiveChangesNo, dropdownButtonWidth, nil, nil, nil, newLayoutButtonTextDisabled);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "import" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_IMPORT_LAYOUT, importLayout, disableOnMaxLayouts, disableOnActiveChanges, dropdownButtonWidth);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "share" then
			local newButton = self.buttonEntryPool:Acquire();
			local showArrow = true;
			newButton:Init(HUD_EDIT_MODE_SHARE_LAYOUT, shareLayout, disableOnMaxLayoutsNo, disableOnActiveChangesNo, dropdownButtonWidth, shareDropdownButtonMaxTextWidth, showArrow);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "copyToClipboard" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_COPY_TO_CLIPBOARD, copyToClipboard, disableOnMaxLayoutsNo, disableOnActiveChangesNo, nil, nil, nil, subMenuButton);
			dropDownButtonInfo.customFrame = newButton;
		--[[elseif dropDownButtonInfo.value == "postInChat" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_POST_IN_CHAT, postInChat, disableOnMaxLayoutsNo, disableOnActiveChangesNo, nil, nil, nil, subMenuButton);
			dropDownButtonInfo.customFrame = newButton;]]--
		elseif dropDownButtonInfo.value == "copyLayout" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_COPY_LAYOUT, copyLayout, disableOnMaxLayouts, disableOnActiveChangesNo, copyRenameSubDropdownButtonWidth, nil, nil, subMenuButton);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "renameLayout" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_RENAME_LAYOUT, renameLayout, disableOnMaxLayoutsNo, disableOnActiveChangesNo, copyRenameSubDropdownButtonWidth, nil, nil, subMenuButton);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "header" then
			dropDownButtonInfo.isTitle = true;
			dropDownButtonInfo.notCheckable = true;
		else
			local newButton = self.layoutEntryPool:Acquire();
			newButton:Init(dropDownButtonInfo.value, dropDownButtonInfo.data, self.layoutInfo.activeLayout == dropDownButtonInfo.value, selectLayout);
			dropDownButtonInfo.customFrame = newButton;
		end
	end

	self.LayoutDropdown:SetCustomSetup(layoutEntryCustomSetup);

	local function layoutSelectedCallback(value, isUserInput)
		if isUserInput and not self:IsLayoutSelected(value) then
			if self:HasActiveChanges() then
				self:ShowRevertWarningDialog(value);
			else
				self:SelectLayout(value);
			end
		end
	end

	local function onCloseCallback()
		if self:HasActiveChanges() then
			self:ShowRevertWarningDialog();
		else
			HideUIPanel(self);
		end
	end

	local function onShowGridCheckboxChecked(isChecked, isUserInput)
		self:SetGridShown(isChecked, isUserInput);
	end

	self.ShowGridCheckButton:SetCallback(onShowGridCheckboxChecked);

	local function onEnableSnapCheckboxChecked(isChecked, isUserInput)
		self:SetEnableSnap(isChecked, isUserInput);
	end

	self.EnableSnapCheckButton:SetCallback(onEnableSnapCheckboxChecked);

	self.onCloseCallback = onCloseCallback;

	self.LayoutDropdown:SetOptionSelectedCallback(layoutSelectedCallback);
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
		maxPerLine = 1;
	elseif raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal then
		orientation = "horizontal";
		CompactRaidFrameContainer:ApplyToFrames("group", CompactRaidGroup_UpdateBorder);
		maxPerLine = 1;
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

function EditModeManagerFrameMixin:GetRaidFrameWidth(forParty)
	local systemIndex = forParty and Enum.EditModeUnitFrameSystemIndices.Party or Enum.EditModeUnitFrameSystemIndices.Raid;
	local raidFrameWidth = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.FrameWidth);
	return (raidFrameWidth and raidFrameWidth > 0) and raidFrameWidth or NATIVE_UNIT_FRAME_WIDTH;
end

function EditModeManagerFrameMixin:GetRaidFrameHeight(forParty)
	local systemIndex = forParty and Enum.EditModeUnitFrameSystemIndices.Party or Enum.EditModeUnitFrameSystemIndices.Raid;
	local raidFrameHeight = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.FrameHeight);
	return (raidFrameHeight and raidFrameHeight > 0) and raidFrameHeight or NATIVE_UNIT_FRAME_HEIGHT;
end

function EditModeManagerFrameMixin:ShouldRaidFrameUseHorizontalRaidGroups(forParty)
	if forParty then
		return self:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Party, Enum.EditModeUnitFrameSetting.UseHorizontalGroups);
	else
		return self:DoesSettingValueEqual(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType, Enum.RaidGroupDisplayType.SeparateGroupsHorizontal);
	end
end

function EditModeManagerFrameMixin:ShouldRaidFrameDisplayBorder(forParty)
	local systemIndex = forParty and Enum.EditModeUnitFrameSystemIndices.Party or Enum.EditModeUnitFrameSystemIndices.Raid;
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
	local leftMostBar = UIParent;

	for index, bar in ipairs(barsToUpdate) do
		local isInDefaultPosition = bar:IsInDefaultPosition();
		bar:SetScale(isInDefaultPosition and newScale or 1);

		if bar and bar:IsShown() and isInDefaultPosition then
			bar:ClearAllPoints();

			if leftMostBar == UIParent then
				bar:SetPoint("RIGHT", leftMostBar, "RIGHT", RIGHT_ACTION_BAR_DEFAULT_OFFSET_X, RIGHT_ACTION_BAR_DEFAULT_OFFSET_Y);
			else
				bar:SetPoint("TOPRIGHT", leftMostBar, "TOPLEFT", -5, 0);
			end

			-- Bar position changed so we should update our flyout direction
			if bar.UpdateSpellFlyoutDirection then
				bar:UpdateSpellFlyoutDirection();
			end

			leftMostBar = bar;
		end
	end

	UIParent_ManageFramePositions();
end

function EditModeManagerFrameMixin:UpdateBottomActionBarPositions()
	if not self:IsInitialized() or self.layoutApplyInProgress then
		return;
	end

	local barsToUpdate = { MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, StanceBar, PetActionBar, PossessActionBar, MainMenuBarVehicleLeaveButton };

	local topMostBar = UIParent;
	if OverrideActionBar and OverrideActionBar:IsShown() then
		topMostBar = OverrideActionBar;
	end

	for index, bar in ipairs(barsToUpdate) do
		if bar and bar:IsInDefaultPosition() then
			bar:ClearAllPoints();
			if topMostBar == UIParent then
				bar:SetPoint("BOTTOM", topMostBar, "BOTTOM", 0, MAIN_ACTION_BAR_DEFAULT_OFFSET_Y);
			elseif topMostBar == OverrideActionBar then
				local xpBarHeight = OverrideActionBar.xpBar:IsShown() and OverrideActionBar.xpBar:GetHeight() or 0;
				bar:SetPoint("BOTTOM", topMostBar, "TOP", 0, 10 + xpBarHeight);
			else
				bar:SetPoint("BOTTOMLEFT", topMostBar, "TOPLEFT", 0, 5);
			end

			-- Bar position changed so we should update our flyout direction
			if bar.UpdateSpellFlyoutDirection then
				bar:UpdateSpellFlyoutDirection();
			end

			if bar:IsShown() then
				topMostBar = bar;
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
	self.AccountSettings:SetExpandedState(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.SettingsExpanded));
	self.AccountSettings:SetTargetAndFocusShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowTargetAndFocus));
	self.AccountSettings:SetPartyFramesShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPartyFrames));
	self.AccountSettings:SetRaidFramesShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowRaidFrames));
	self.AccountSettings:SetActionBarShown(StanceBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowStanceBar));
	self.AccountSettings:SetActionBarShown(PetActionBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPetActionBar));
	self.AccountSettings:SetActionBarShown(PossessActionBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPossessActionBar));
	self.AccountSettings:SetCastBarShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowCastBar));
	self.AccountSettings:SetEncounterBarShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowEncounterBar));
	self.AccountSettings:SetExtraAbilitiesShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowExtraAbilities));
	self.AccountSettings:SetAuraFrameShown(BuffFrame, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowBuffFrame));
	self.AccountSettings:SetAuraFrameShown(DebuffFrame, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowDebuffFrame));
	self.AccountSettings:SetTalkingHeadFrameShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowTalkingHeadFrame));
	self.AccountSettings:SetVehicleLeaveButtonShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowVehicleLeaveButton));
	self.AccountSettings:SetBossFramesShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowBossFrames));
	self.AccountSettings:SetArenaFramesShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowArenaFrames));
	self.AccountSettings:SetLootFrameShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowLootFrame));
	self.AccountSettings:SetHudTooltipShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowHudTooltip));
	self.AccountSettings:SetReputationBarShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowReputationBar));
	self.AccountSettings:SetDurabilityFrameShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowDurabilityFrame));
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

	if isUserInput then
		self:OnAccountSettingChanged(Enum.EditModeAccountSetting.EnableSnap, enableSnap);
	else
		self.EnableSnapCheckButton:SetControlChecked(enableSnap);
	end
end

function EditModeManagerFrameMixin:IsSnapEnabled()
	return self.snapEnabled;
end

local characterLayoutHeaderText = GetClassColoredTextForUnit("player", HUD_EDIT_MODE_CHARACTER_LAYOUTS_HEADER:format(UnitNameUnmodified("player")));

local function SortLayouts(a, b)
	if a.data.layoutType ~= b.data.layoutType then
		return a.data.layoutType > b.data.layoutType;
	end

	return a.value < b.value;
end

function EditModeManagerFrameMixin:UpdateDropdownOptions()
	self:ClearLockedLayoutButton();
	self.buttonEntryPool:ReleaseAll();
	self.layoutEntryPool:ReleaseAll();
	self.highestLayoutIndexByType = {};

	local options = {};

	local hasCharacterLayouts = false;
	for index, layoutInfo in ipairs(self.layoutInfo.layouts) do
		local dropdownText = (layoutInfo.layoutType == Enum.EditModeLayoutType.Preset) and HUD_EDIT_MODE_PRESET_LAYOUT:format(layoutInfo.layoutName) or layoutInfo.layoutName;

		table.insert(options, { value = index, selectedText = layoutInfo.layoutName, data = layoutInfo });

		if layoutInfo.layoutType == Enum.EditModeLayoutType.Character then
			hasCharacterLayouts = true;
		end

		if not self.highestLayoutIndexByType[layoutInfo.layoutType] or self.highestLayoutIndexByType[layoutInfo.layoutType] < index then
			self.highestLayoutIndexByType[layoutInfo.layoutType] = index;
		end
	end

	-- Sort the layouts: character-specific -> account -> preset
	table.sort(options, SortLayouts);

	-- Insert a divider between each section
	local lastLayoutType = nil;
	for index, optionInfo in ipairs(options) do
		if lastLayoutType and lastLayoutType ~= optionInfo.data.layoutType then
			table.insert(options, index, { isSeparator = true });
		end

		lastLayoutType = optionInfo.data.layoutType;
	end

	-- Insert a header before the character-specific layouts if there are any
	if hasCharacterLayouts then
		table.insert(options, 1, { value = "header", text = characterLayoutHeaderText });
	end

	-- Insert a divider and the New Layout, Import and Share buttons
	table.insert(options, { isSeparator = true });
	table.insert(options, { value = "newLayout" });
	table.insert(options, { value = "import" });
	table.insert(options, { value = "share" });

	-- Add the 2nd-level options (rename and copy)
	table.insert(options, { value = "copyLayout", text = HUD_EDIT_MODE_COPY_LAYOUT, level = 2 });
	table.insert(options, { value = "renameLayout", text = HUD_EDIT_MODE_RENAME_LAYOUT, level = 2 });

	-- And the 3rd-level options (copy to clipboard and post in chat)
	table.insert(options, { value = "copyToClipboard", text = HUD_EDIT_MODE_COPY_TO_CLIPBOARD, level = 3 });
	--table.insert(options, { value = "postInChat", text = HUD_EDIT_MODE_POST_IN_CHAT, level = 3 });

	self.LayoutDropdown:SetOptions(options, self.layoutInfo.activeLayout);
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

function EditModeManagerFrameMixin:GetActiveLayoutInfo()
	return self.layoutInfo and self.layoutInfo.layouts[self.layoutInfo.activeLayout];
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
	self.LayoutDropdown:SetSelectedValue(self.layoutInfo.activeLayout);
end

function EditModeManagerFrameMixin:MakeNewLayout(newLayoutInfo, layoutType, layoutName, isLayoutImported)
	if newLayoutInfo and layoutName and layoutName ~= "" then
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
	if layoutName ~= "" then
		local renameLayoutInfo = self.layoutInfo.layouts[layoutIndex];
		if renameLayoutInfo and renameLayoutInfo.layoutType ~= Enum.EditModeLayoutType.Preset then
			renameLayoutInfo.layoutName = layoutName;
			self:SaveLayouts();
			self:UpdateDropdownOptions();
		end
	end
end

function EditModeManagerFrameMixin:CopyActiveLayoutToClipboard()
	CloseDropDownMenus();
	local activeLayoutInfo = self:GetActiveLayoutInfo();
	CopyToClipboard(C_EditMode.ConvertLayoutInfoToString(activeLayoutInfo));
	DEFAULT_CHAT_FRAME:AddMessage(HUD_EDIT_MODE_COPY_TO_CLIPBOARD_NOTICE:format(activeLayoutInfo.layoutName), YELLOW_FONT_COLOR:GetRGB());
end

--[[
function EditModeManagerFrameMixin:LinkActiveLayoutToChat()
	CloseDropDownMenus();
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

function EditModeManagerFrameMixin:ShowNewLayoutDialog(layoutData)
	CloseDropDownMenus();
	EditModeNewLayoutDialog:ShowDialog(layoutData or self:GetActiveLayoutInfo());
end

function EditModeManagerFrameMixin:ShowImportLayoutDialog()
	CloseDropDownMenus();
	EditModeImportLayoutDialog:ShowDialog();
end

function EditModeManagerFrameMixin:OpenAndShowImportLayoutLinkDialog(link)
	if not self:IsShown() then
		self:Show();
	end

	EditModeImportLayoutLinkDialog:ShowDialog(link);
end

function EditModeManagerFrameMixin:ShowRenameLayoutDialog(layoutButton)
	CloseDropDownMenus();

	local function onAcceptCallback(layoutName)
		self:RenameLayout(layoutButton.layoutIndex, layoutName);
	end

	local data = {text = HUD_EDIT_MODE_RENAME_LAYOUT_DIALOG_TITLE, text_arg1 = layoutButton.layoutData.layoutName, callback = onAcceptCallback, acceptText = SAVE }
	StaticPopup_ShowCustomGenericInputBox(data);
end

function EditModeManagerFrameMixin:ShowDeleteLayoutDialog(layoutButton)
	CloseDropDownMenus();

	local function onAcceptCallback()
		self:DeleteLayout(layoutButton.layoutIndex);
	end

	local data = {text = HUD_EDIT_MODE_DELETE_LAYOUT_DIALOG_TITLE, text_arg1 = layoutButton.layoutData.layoutName, callback = onAcceptCallback }
	StaticPopup_ShowCustomGenericConfirmation(data);
end

function EditModeManagerFrameMixin:ShowRevertWarningDialog(selectedLayoutIndex)
	EditModeUnsavedChangesDialog:ShowDialog(selectedLayoutIndex);
end

function EditModeManagerFrameMixin:ToggleSubDropdown(level, layoutButton)
	ToggleDropDownMenu(level, layoutButton.layoutIndex, self.LayoutDropdown.DropDownMenu, nil, nil, nil, nil, layoutButton.owningButton);

	if self.lockedLayoutButton then
		self.lockedLayoutButton = nil;
	else
		self.lockedLayoutButton = layoutButton;
	end
end

function EditModeManagerFrameMixin:ToggleRenameOrCopyLayoutDropdown(layoutButton)
	self:ToggleSubDropdown(2, layoutButton)
end

function EditModeManagerFrameMixin:ToggleShareDropdown(layoutButton)
	self:ToggleSubDropdown(3, layoutButton)
end

function EditModeManagerFrameMixin:ClearLockedLayoutButton(exemptLayoutButton)
	if self.lockedLayoutButton ~= exemptLayoutButton then
		self.lockedLayoutButton = nil;
		CloseDropDownMenus(2);
		CloseDropDownMenus(3);
	end
end

function EditModeManagerFrameMixin:IsLayoutButtonLocked(layoutButton)
	return self.lockedLayoutButton == layoutButton;
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
	return not C_PlayerInfo.IsPlayerNPERestricted() and TableIsEmpty(self.FramesBlockingEditMode);
end

EditModeGridMixin = {}

function EditModeGridMixin:OnLoad()
	local function resetLine(pool, line)
		line:Hide();
		line:ClearAllPoints();
	end

	self.linePool = CreateObjectPool(
		function(pool)
			return self:CreateLine(nil, nil, "EditModeGridLineTemplate");
		end,

		resetLine
	);

	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
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
	self.Slider:SetEnabled_(enabled);
	self.Label:SetFontObject(enabled and GameFontHighlightMedium or GameFontDisableMed3);
end

function EditModeGridSpacingSliderMixin:OnSliderValueChanged(value)
	local isUserInput = true;
	EditModeManagerFrame:SetGridSpacing(value, isUserInput);
end

EditModeAccountSettingsMixin = {};

function EditModeAccountSettingsMixin:OnLoad()
	local function onTargetAndFocusCheckboxChecked(isChecked, isUserInput)
		self:SetTargetAndFocusShown(isChecked, isUserInput);
	end
	self.Settings.TargetAndFocus:SetCallback(onTargetAndFocusCheckboxChecked);

	local function onPartyFramesCheckboxChecked(isChecked, isUserInput)
		self:SetPartyFramesShown(isChecked, isUserInput);
	end
	self.Settings.PartyFrames:SetCallback(onPartyFramesCheckboxChecked);

	local function onRaidFramesCheckboxChecked(isChecked, isUserInput)
		self:SetRaidFramesShown(isChecked, isUserInput);
	end
	self.Settings.RaidFrames:SetCallback(onRaidFramesCheckboxChecked);

	local function onStanceBarCheckboxChecked(isChecked, isUserInput)
		self:SetActionBarShown(StanceBar, isChecked, isUserInput);
	end
	self.Settings.StanceBar:SetCallback(onStanceBarCheckboxChecked);

	local function onPetActionBarCheckboxChecked(isChecked, isUserInput)
		self:SetActionBarShown(PetActionBar, isChecked, isUserInput);
	end
	self.Settings.PetActionBar:SetCallback(onPetActionBarCheckboxChecked);

	local function onPossessActionBarCheckboxChecked(isChecked, isUserInput)
		self:SetActionBarShown(PossessActionBar, isChecked, isUserInput);
	end
	self.Settings.PossessActionBar:SetCallback(onPossessActionBarCheckboxChecked);

	local function onCastBarCheckboxChecked(isChecked, isUserInput)
		self:SetCastBarShown(isChecked, isUserInput);
	end
	self.Settings.CastBar:SetCallback(onCastBarCheckboxChecked);

	local function onEncounterBarCheckboxChecked(isChecked, isUserInput)
		self:SetEncounterBarShown(isChecked, isUserInput);
	end
	self.Settings.EncounterBar:SetCallback(onEncounterBarCheckboxChecked);

	local function onExtraAbilitiesCheckboxChecked(isChecked, isUserInput)
		self:SetExtraAbilitiesShown(isChecked, isUserInput);
	end
	self.Settings.ExtraAbilities:SetCallback(onExtraAbilitiesCheckboxChecked);

	local function onBuffFrameCheckboxChecked(isChecked, isUserInput)
		self:SetAuraFrameShown(BuffFrame, isChecked, isUserInput);
	end
	self.Settings.BuffFrame:SetCallback(onBuffFrameCheckboxChecked);

	local function onDebuffFrameCheckboxChecked(isChecked, isUserInput)
		self:SetAuraFrameShown(DebuffFrame, isChecked, isUserInput);
	end
	self.Settings.DebuffFrame:SetCallback(onDebuffFrameCheckboxChecked);

	local function onTalkingHeadFrameCheckboxChecked(isChecked, isUserInput)
		self:SetTalkingHeadFrameShown(isChecked, isUserInput);
	end
	self.Settings.TalkingHeadFrame:SetCallback(onTalkingHeadFrameCheckboxChecked);

	local function onVehicleLeaveButtonCheckboxChecked(isChecked, isUserInput)
		self:SetVehicleLeaveButtonShown(isChecked, isUserInput);
	end
	self.Settings.VehicleLeaveButton:SetCallback(onVehicleLeaveButtonCheckboxChecked);

	local function onBossFramesCheckboxChecked(isChecked, isUserInput)
		self:SetBossFramesShown(isChecked, isUserInput);
	end
	self.Settings.BossFrames:SetCallback(onBossFramesCheckboxChecked);

	local function onArenaFramesCheckboxChecked(isChecked, isUserInput)
		self:SetArenaFramesShown(isChecked, isUserInput);
	end
	self.Settings.ArenaFrames:SetCallback(onArenaFramesCheckboxChecked);

	local function onLootFrameCheckboxChecked(isChecked, isUserInput)
		self:SetLootFrameShown(isChecked, isUserInput);
	end
	self.Settings.LootFrame:SetCallback(onLootFrameCheckboxChecked);

	local function onHudTooltipCheckboxChecked(isChecked, isUserInput)
		self:SetHudTooltipShown(isChecked, isUserInput);
	end
	self.Settings.HudTooltip:SetCallback(onHudTooltipCheckboxChecked);

	local function onReputationBarCheckboxChecked(isChecked, isUserInput)
		self:SetReputationBarShown(isChecked, isUserInput);
	end
	self.Settings.ReputationBar:SetCallback(onReputationBarCheckboxChecked);

	local function onDurabilityFrameCheckboxChecked(isChecked, isUserInput)
		self:SetDurabilityFrameShown(isChecked, isUserInput);
	end
	self.Settings.DurabilityFrame:SetCallback(onDurabilityFrameCheckboxChecked);
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

	self:SetupReputationBar();
	self:SetupDurabilityFrame();

	self:RefreshTargetAndFocus();
	self:RefreshPartyFrames();
	self:RefreshRaidFrames()
	self:RefreshCastBar();
	self:RefreshEncounterBar();
	self:RefreshExtraAbilities();
	self:RefreshAuraFrame(BuffFrame);
	self:RefreshAuraFrame(DebuffFrame);
	self:RefreshTalkingHeadFrame();
	self:RefreshVehicleLeaveButton();
	self:RefreshBossFrames();
	self:RefreshArenaFrames();
	self:RefreshLootFrame();
	self:RefreshHudTooltip();
	self:RefreshReputationBar();
	self:RefreshDurabilityFrame();
end

function EditModeAccountSettingsMixin:OnEditModeExit()
	self:ResetTargetAndFocus();
	self:ResetPartyFrames();
	self:ResetRaidFrames();
	self:ResetHudTooltip();

	self:ResetActionBarShown(StanceBar);
	self:ResetActionBarShown(PetActionBar);
	self:ResetActionBarShown(PossessActionBar);
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
	local showTargetAndFocus = self.Settings.TargetAndFocus:IsControlChecked();
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
		self.Settings.TargetAndFocus:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshPartyFrames()
	local showPartyFrames = self.Settings.PartyFrames:IsControlChecked();
	if showPartyFrames then
		PartyFrame:HighlightSystem();
		PartyFrame:Raise();
	else
		PartyFrame:ClearHighlight();
	end

	CompactPartyFrame_RefreshMembers();
	UpdateRaidAndPartyFrames();
end

function EditModeAccountSettingsMixin:ResetPartyFrames()
	CompactPartyFrame_RefreshMembers();
	UpdateRaidAndPartyFrames();
end

function EditModeAccountSettingsMixin:SetPartyFramesShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowPartyFrames, shown);
		self:RefreshPartyFrames();
	else
		self.Settings.PartyFrames:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshRaidFrames()
	local showRaidFrames = self.Settings.RaidFrames:IsControlChecked();
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
		self.Settings.RaidFrames:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:SetupActionBar(bar)
	local isShown = bar:IsShown();
	self.oldActionBarSettings[bar] = {
		isShown = isShown;
	}

	-- If the bar is already showing then set control checked
	if isShown then
		self.Settings[bar:GetName()]:SetControlChecked(true);
	end

	self:RefreshActionBarShown(bar);
end

function EditModeAccountSettingsMixin:ResetActionBarShown(bar)
	if not bar:HasSetting(Enum.EditModeActionBarSetting.AlwaysShowButtons) then
		bar:SetShowGrid(false, ACTION_BUTTON_SHOW_GRID_REASON_CVAR);
	end

	bar.editModeForceShow = false;
	bar:SetShown(self.oldActionBarSettings[bar].isShown);
end

function EditModeAccountSettingsMixin:RefreshActionBarShown(bar)
	local barName = bar:GetName();
	local show = self.Settings[barName]:IsControlChecked();

	if show then
		bar.editModeForceShow = true;

		if not bar:HasSetting(Enum.EditModeActionBarSetting.AlwaysShowButtons) and (bar.numShowingButtonsOrSpacers == 0 or not bar.dontShowAllButtonsInEditMode) then
			bar:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_CVAR);
		end

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
		self.Settings[barName]:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:SetCastBarShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowCastBar, shown);
		self:RefreshCastBar();
	else
		self.Settings.CastBar:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshCastBar()
	local showCastBar = self.Settings.CastBar:IsControlChecked();
	if showCastBar then
		PlayerCastingBarFrame.isInEditMode = true;
		PlayerCastingBarFrame:HighlightSystem();
	else
		PlayerCastingBarFrame.isInEditMode = false;
		PlayerCastingBarFrame:ClearHighlight();
	end
	PlayerCastingBarFrame:UpdateShownState();
end

function EditModeAccountSettingsMixin:SetEncounterBarShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowEncounterBar, shown);
		self:RefreshEncounterBar();
	else
		self.Settings.EncounterBar:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshEncounterBar()
	local showEncounterbar = self.Settings.EncounterBar:IsControlChecked();
	if showEncounterbar then
		EncounterBar:HighlightSystem();
	else
		EncounterBar:ClearHighlight();
	end

	UIParent_ManageFramePositions();
end

function EditModeAccountSettingsMixin:SetExtraAbilitiesShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowExtraAbilities, shown);
		self:RefreshExtraAbilities();
	else
		self.Settings.ExtraAbilities:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshExtraAbilities()
	local showExtraAbilities = self.Settings.ExtraAbilities:IsControlChecked();
	if showExtraAbilities then
		ExtraAbilityContainer.isInEditMode = true;
		ExtraAbilityContainer:HighlightSystem();
	else
		ExtraAbilityContainer.isInEditMode = false;
		ExtraAbilityContainer:ClearHighlight();
	end

	ExtraAbilityContainer:UpdateShownState();
end

function EditModeAccountSettingsMixin:SetAuraFrameShown(frame, shown, isUserInput)
	local frameName = frame:GetName();

	if isUserInput then
		local showFrameName = "Show"..frameName;
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting[showFrameName], shown);
		self:RefreshAuraFrame(frame);
	else
		self.Settings[frameName]:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshAuraFrame(frame)
	local frameName = frame:GetName();
	local showFrame = self.Settings[frameName]:IsControlChecked();

	if showFrame then
		frame.isInEditMode = true;
		frame:HighlightSystem();
	else
		frame.isInEditMode = false;
		frame:ClearHighlight();
	end

	frame:UpdateAuraButtons();
end

function EditModeAccountSettingsMixin:SetTalkingHeadFrameShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowTalkingHeadFrame, shown);
		self:RefreshTalkingHeadFrame();
	else
		self.Settings.TalkingHeadFrame:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshTalkingHeadFrame()
	local showTalkingHeadFrame = self.Settings.TalkingHeadFrame:IsControlChecked();
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
		self.Settings.VehicleLeaveButton:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshVehicleLeaveButton()
	local showVehicleLeaveButton = self.Settings.VehicleLeaveButton:IsControlChecked();
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
		self.Settings.BossFrames:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshBossFrames()
	local showBossFrames = self.Settings.BossFrames:IsControlChecked();
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
		self.Settings.ArenaFrames:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshArenaFrames()
	local showArenaFrames = self.Settings.ArenaFrames:IsControlChecked();
	if showArenaFrames then
		ArenaEnemyFramesContainer:SetIsInEditMode(true);
		ArenaEnemyFramesContainer:HighlightSystem();
	else
		ArenaEnemyFramesContainer:SetIsInEditMode(false);
		ArenaEnemyFramesContainer:ClearHighlight();
	end

	ArenaEnemyFramesContainer:Update();
end

function EditModeAccountSettingsMixin:SetLootFrameShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowLootFrame, shown);
		self:RefreshLootFrame();
	else
		self.Settings.LootFrame:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshLootFrame()
	local showLootFrame = self.Settings.LootFrame:IsControlChecked() and GetCVar("lootUnderMouse") ~= "1";
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
		self.Settings.HudTooltip:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshHudTooltip()
	local showHudTooltip = self.Settings.HudTooltip:IsControlChecked();
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

function EditModeAccountSettingsMixin:SetReputationBarShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowReputationBar, shown);
		self:RefreshReputationBar();
	else
		self.Settings.ReputationBar:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:SetupReputationBar()
	if SecondaryStatusTrackingBarContainer:IsShown() then
		self.Settings.ReputationBar:SetControlChecked(true);
	end
end

function EditModeAccountSettingsMixin:RefreshReputationBar()
	local showReputationBar = self.Settings.ReputationBar:IsControlChecked();
	if showReputationBar then
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
		self.Settings.DurabilityFrame:SetControlChecked(true);
	end
end

function EditModeAccountSettingsMixin:SetDurabilityFrameShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowDurabilityFrame, shown);
		self:RefreshDurabilityFrame();
	else
		self.Settings.DurabilityFrame:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshDurabilityFrame()
	local showDurabilityFrame = self.Settings.DurabilityFrame:IsControlChecked();
	if showDurabilityFrame then
		DurabilityFrame.isInEditMode = true;
		DurabilityFrame:HighlightSystem();
	else
		DurabilityFrame.isInEditMode = false;
		DurabilityFrame:ClearHighlight();
	end

	DurabilityFrame:UpdateShownState();
end

function EditModeAccountSettingsMixin:SetExpandedState(expanded, isUserInput)
	self.expanded = expanded;
	self.Expander.Label:SetText(expanded and HUD_EDIT_MODE_COLLAPSE_OPTIONS or HUD_EDIT_MODE_EXPAND_OPTIONS);
	self.Settings:SetShown(self.expanded);
	EditModeManagerFrame:Layout();

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
	[1] = { text = EDIT_MODE_HELPTIPS_1, buttonStyle = HelpTip.ButtonStyle.Next, offsetX = 0, offsetY = 0, targetPoint = HelpTip.Point.RightEdgeCenter, relativeRegionParentKey="LayoutDropdown",
			cvarBitfield = "closedInfoFrames", bitfieldFlag = LE_FRAME_TUTORIAL_EDIT_MODE_MANAGER, },
	[2] = { text = EDIT_MODE_HELPTIPS_2, buttonStyle = HelpTip.ButtonStyle.Next, offsetX = 0, offsetY = 0, targetPoint = HelpTip.Point.RightEdgeCenter, relativeRegionParentKey="AccountSettings",
			cvarBitfield = "closedInfoFrames", bitfieldFlag = LE_FRAME_TUTORIAL_EDIT_MODE_MANAGER, },
	[3] = { text = EDIT_MODE_HELPTIPS_3, buttonStyle = HelpTip.ButtonStyle.GotIt, offsetX = 0, offsetY = 0, targetPoint = HelpTip.Point.BottomEdgeCenter, hideArrow = true,
			cvarBitfield = "closedInfoFrames", bitfieldFlag = LE_FRAME_TUTORIAL_EDIT_MODE_MANAGER, },
};

function EditModeManagerTutorialMixin:OnLoad()
	local onAcknowledgeCallback = GenerateClosure(self.ProgressHelpTips, self);
	for index, helpTipInfo in ipairs(HelpTipInfos) do
		helpTipInfo.onAcknowledgeCallback = onAcknowledgeCallback;
	end
end

function EditModeManagerTutorialMixin:OnShow()
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_EDIT_MODE_MANAGER) then
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
	local isUserInput = true;
	EditModeManagerFrame.AccountSettings:SetExpandedState(expanded, isUserInput)

	self.currentTipIndex = 1;
	self:ShowHelpTip();
end

function EditModeManagerTutorialMixin:ShowHelpTip()
	local helpTipInfo = HelpTipInfos[self.currentTipIndex];
	local relativeRegion = helpTipInfo.relativeRegionParentKey and EditModeManagerFrame[helpTipInfo.relativeRegionParentKey] or EditModeManagerFrame;

	HelpTip:Show(self, helpTipInfo, relativeRegion);
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

function EditModeLootFrameCheckButtonMixin:OnEnter()
	if not self:ShouldEnable() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddNormalLine(GameTooltip, HUD_EDIT_MODE_LOOT_FRAME_DISABLED_TOOLTIP);
		GameTooltip:Show();
	end
end

function EditModeLootFrameCheckButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function EditModeLootFrameCheckButtonMixin:ShouldEnable()
	return GetCVar("lootUnderMouse") ~= "1";
end