EditModeManagerFrameMixin = {};

function EditModeManagerFrameMixin:OnLoad()
	self.registeredSystemFrames = {};
	self.RightActionBarsInLayout = {};
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

	local function postInChat()
		self:LinkActiveLayoutToChat();
	end

	local function copyLayout()
		self:ShowNewLayoutDialog(self.lockedLayoutButton.layoutData);
	end

	local function renameLayout()
		self:ShowRenameLayoutDialog(self.lockedLayoutButton);
	end

	local function selectLayout(layoutButton)
		UIDropDownMenuButton_OnClick(layoutButton.owningButton);
	end

	local newLayoutButtonText = HUD_EDIT_MODE_NEW_LAYOUT:format(CreateSimpleTextureMarkup("Interface\\PaperDollInfoFrame\\Character-Plus", 16));
	local dropdownButtonWidth = 210;
	local shareDropdownButtonMaxTextWidth = 190;
	local shareSubDropdownButtonWidth = 220;
	local copyRenameSubDropdownButtonWidth = 150;
	local subMenuButton = true;

	local function layoutEntryCustomSetup(dropDownButtonInfo, standardFunc)
		if dropDownButtonInfo.value == "newLayout" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(newLayoutButtonText, createNewLayout, dropdownButtonWidth);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "import" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_IMPORT_LAYOUT, importLayout, dropdownButtonWidth);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "share" then
			local newButton = self.buttonEntryPool:Acquire();
			local showArrow = true;
			newButton:Init(HUD_EDIT_MODE_SHARE_LAYOUT, shareLayout, dropdownButtonWidth, shareDropdownButtonMaxTextWidth, showArrow);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "copyToClipboard" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_COPY_TO_CLIPBOARD, copyToClipboard, shareSubDropdownButtonWidth, nil, nil, subMenuButton);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "postInChat" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_POST_IN_CHAT, postInChat, shareSubDropdownButtonWidth, nil, nil, subMenuButton);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "copyLayout" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_COPY_LAYOUT, copyLayout, copyRenameSubDropdownButtonWidth, nil, nil, subMenuButton);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "renameLayout" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_RENAME_LAYOUT, renameLayout, copyRenameSubDropdownButtonWidth, nil, nil, subMenuButton);
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
		if isUserInput then
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

	self.onCloseCallback = onCloseCallback;

	self.LayoutDropdown:SetOptionSelectedCallback(layoutSelectedCallback);
	self.SaveChangesButton:SetOnClickHandler(GenerateClosure(self.SaveLayoutChanges, self));
	self.RevertAllChangesButton:SetOnClickHandler(GenerateClosure(self.RevertAllChanges, self));

	self:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player");
end

function EditModeManagerFrameMixin:OnDragStart()
	self:StartMoving();
end

function EditModeManagerFrameMixin:OnDragStop()
	self:StopMovingOrSizing();
end

function EditModeManagerFrameMixin:ShowSystemSelections()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		systemFrame:OnEditModeEnter();
	end
end

function EditModeManagerFrameMixin:EnterEditMode()
	self.editModeActive = true;
	self:ClearActiveChangesFlags();
	self:UpdateDropdownOptions();
	self:ShowSystemSelections();
	self.AccountSettings:OnEditModeEnter();
end

function EditModeManagerFrameMixin:HideSystemSelections()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		systemFrame:OnEditModeExit();
	end
end

function EditModeManagerFrameMixin:ExitEditMode()
	self.editModeActive = false;
	self:RevertAllChanges();
	self:HideSystemSelections();
	self.AccountSettings:OnEditModeExit();
end

function EditModeManagerFrameMixin:OnShow()
	if not self:IsEditModeLocked() then
		self:EnterEditMode();
	elseif self:IsEditModeInLockState("hideSelections")  then
		self:ShowSystemSelections();
	end

	self:ClearEditModeLockState();
	self:Layout();
end

function EditModeManagerFrameMixin:OnHide()
	if not self:IsEditModeLocked() then
		self:ExitEditMode();
	elseif self:IsEditModeInLockState("hideSelections") then
		self:HideSystemSelections();
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
		self:UpdateRightAnchoredActionBarScales();
	end
end

function EditModeManagerFrameMixin:IsInitialized()
	return self.layoutInfo ~= nil;
end

function EditModeManagerFrameMixin:RegisterSystemFrame(systemFrame)
	table.insert(self.registeredSystemFrames, systemFrame);
end

function EditModeManagerFrameMixin:GetRegisteredSystemFrame(system, systemIndex)
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		if systemFrame.system == system and systemFrame.systemIndex == systemIndex then
			return systemFrame;
		end
	end

	return nil;
end

local function AreAnchorsEqual(anchorInfo, otherAnchorInfo)
	if anchorInfo and otherAnchorInfo then
		return anchorInfo.point == otherAnchorInfo.point
		and anchorInfo.relativeTo == otherAnchorInfo.relativeTo
		and anchorInfo.relativePoint == otherAnchorInfo.relativePoint
		and anchorInfo.offsetX == otherAnchorInfo.offsetX
		and anchorInfo.offsetY == otherAnchorInfo.offsetY
		and anchorInfo.isDefaultPosition == otherAnchorInfo.isDefaultPosition;
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
		anchorInfo.isDefaultPosition = otherAnchorInfo.isDefaultPosition;
	end
end

local function ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY, isDefaultPosition)
	if point then
		local anchorInfo = {};
		anchorInfo.point = point;
		anchorInfo.relativeTo = relativeTo and relativeTo:GetName() or "UIParent";
		anchorInfo.relativePoint = relativePoint;
		anchorInfo.offsetX = offsetX;
		anchorInfo.offsetY = offsetY;
		anchorInfo.isDefaultPosition = isDefaultPosition or false;
		return anchorInfo;
	end

	return nil;
end

function EditModeManagerFrameMixin:SetHasActiveChanges(hasActiveChanges)
	self.hasActiveChanges = hasActiveChanges;
	self.SaveChangesButton:SetEnabled(hasActiveChanges);
	self.RevertAllChangesButton:SetEnabled(hasActiveChanges);
end

function EditModeManagerFrameMixin:CheckForSystemActiveChanges()
	local hasActiveChanges = false;
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		if systemFrame:HasActiveChanges() then
			hasActiveChanges = true;
			break;
		end
	end

	self:SetHasActiveChanges(hasActiveChanges);
end

function EditModeManagerFrameMixin:HasActiveChanges()
	return self.hasActiveChanges;
end

local function UpdateSystemAnchorInfo(systemInfo, systemFrame, isDefaultPosition)
	local point, relativeTo, relativePoint, offsetX, offsetY = systemFrame:GetPoint(1);
	local newAnchorInfo = ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY, isDefaultPosition);
	if not AreAnchorsEqual(systemInfo.anchorInfo, newAnchorInfo) then
		CopyAnchorInfo(systemInfo.anchorInfo, newAnchorInfo);
		return true;
	end

	return false;
end

function EditModeManagerFrameMixin:OnSystemPositionChange(systemFrame, isDefaultPosition)
	local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		if UpdateSystemAnchorInfo(systemInfo, systemFrame, isDefaultPosition) then
			systemFrame:SetHasActiveChanges(true);

			local isRightActionBar = EditModeUtil:IsRightAnchoredActionBar(systemFrame);
			if isRightActionBar then
				self:UpdateRightAnchoredActionBarWidth();
			end

			if isRightActionBar or systemFrame == MinimapCluster then
				self:UpdateRightAnchoredActionBarScales();
			end

			if EditModeUtil:IsBottomAnchoredActionBar(systemFrame) then
				self:UpdateBottomAnchoredActionBarHeight();
			end

			if systemFrame.isBottomManagedFrame then
				UIParent_ManageFramePositions();
			end

			EditModeSystemSettingsDialog:UpdateDialog(systemFrame);
		end
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

function EditModeManagerFrameMixin:GetRightAnchoredActionBarWidth()
	return self.rightAnchoredActionBarWidth;
end

function EditModeManagerFrameMixin:GetBottomAnchoredActionBarHeight()
	return self.bottomAnchoredActionBarHeight;
end

function EditModeManagerFrameMixin:UpdateRightAnchoredActionBarWidth()
	self.rightAnchoredActionBarWidth = EditModeUtil:GetRightActionBarWidth();
	UIParent_ManageFramePositions();
end

function EditModeManagerFrameMixin:UpdateRightAnchoredActionBarScales()
	if not self:IsInitialized() then
		return;
	end

	local topLimit = MinimapCluster:IsInDefaultPosition() and (MinimapCluster:GetBottom() - 10) or UIParent:GetTop();
	local bottomLimit = MicroButtonAndBagsBar:GetTop() + 24;
	local availableSpace = topLimit - bottomLimit;
	local multiBarHeight = MultiBarRight:GetHeight();

	if multiBarHeight <= availableSpace then
		MultiBarRight:SetScale(1);
		MultiBarLeft:SetScale(1);
		return;
	end

	local scale = availableSpace / multiBarHeight;
	MultiBarRight:SetScaleIfRightAnchored(scale);
	MultiBarLeft:SetScaleIfRightAnchored(scale);
end

function EditModeManagerFrameMixin:UpdateBottomAnchoredActionBarHeight(includeMainMenuBar)
	self.bottomAnchoredActionBarHeight =  EditModeUtil:GetBottomActionBarHeight(includeMainMenuBar);

	-- Update bottom anchoring bars which show on top of other bars since if other bottom bars changed we may wanna change those bars too
	local bottomAnchoredActionBarsToUpdate = { StanceBar, PetActionBar, PossessActionBar};

	local topMostBottomAnchoredBar = nil;
	if MultiBar2_IsVisible() and MultiBarBottomRight:IsInDefaultPosition() then
		topMostBottomAnchoredBar = MultiBarBottomRight;
	elseif MultiBar1_IsVisible() and MultiBarBottomLeft:IsInDefaultPosition() then
		topMostBottomAnchoredBar = MultiBarBottomLeft;
	elseif MainMenuBar:IsInDefaultPosition() then
		topMostBottomAnchoredBar = MainMenuBar;
	end

	for index, bar in ipairs(bottomAnchoredActionBarsToUpdate) do
		if (bar and bar:IsShown()) then
			-- Only update bar's anchor if it was already bottom anchored
			local point, relativeTo, relativePoint, offsetX, offsetY = bar:GetPoint(1);
			if EditModeUtil:IsBottomAnchoredActionBar(relativeTo) then
				if topMostBottomAnchoredBar and relativeTo ~= topMostBottomAnchoredBar then
					bar:SetPoint("BOTTOMLEFT", topMostBottomAnchoredBar, "TOPLEFT", 0, 5);
					
					local isDefaultPosition = true;
					EditModeManagerFrame:OnSystemPositionChange(bar, isDefaultPosition);
				end

				if bar:IsInDefaultPosition() then
					-- This bar is now the new topmost bar
					topMostBottomAnchoredBar = bar;
				end
			end
		end
	end

	UIParent_ManageFramePositions();
end

function EditModeManagerFrameMixin:SelectSystem(selectFrame)
	if not self:IsEditModeLocked() then
		for _, systemFrame in ipairs(self.registeredSystemFrames) do
			if systemFrame == selectFrame then
				systemFrame:SelectSystem();
			else
				-- Only highlight a system if it was already highlighted
				if systemFrame.isHighlighted then
					systemFrame:HighlightSystem();
				end
			end
		end
	end
end

function EditModeManagerFrameMixin:ClearSelectedSystem()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		-- Only highlight a system if it was already highlighted
		if systemFrame.isHighlighted then
			systemFrame:HighlightSystem();
		end
	end
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

local function GetSettingMapFromSettings(settings, displayInfoMap)
	local settingMap = {};
	for _, settingInfo in ipairs(settings) do
		settingMap[settingInfo.setting] = { value = settingInfo.value };

		if displayInfoMap and displayInfoMap[settingInfo.setting] then
			settingMap[settingInfo.setting].displayValue = displayInfoMap[settingInfo.setting]:ConvertValueForDisplay(settingInfo.value);
		end
	end
	return settingMap;
end

-- This method handles adding any missing systems/settings to a saved layout data table
function EditModeManagerFrameMixin:AddNewSystemsAndSettings(layoutInfo)
	local addedSomething = false;

	-- Create a system/setting map to allow for efficient checking of each system & setting below
	local layoutSystemMap = {};
	for _, layoutSystemInfo in ipairs(layoutInfo.systems) do
		local settingMap = GetSettingMapFromSettings(layoutSystemInfo.settings);

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
	self.accountSettingMap = GetSettingMapFromSettings(self.accountSettings);
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
	self.AccountSettings:SetExpandedState(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.SettingsExpanded));
	self.AccountSettings:SetTargetAndFocusShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowTargetAndFocus));
	self.AccountSettings:SetActionBarShown(StanceBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowStanceBar));
	self.AccountSettings:SetActionBarShown(PetActionBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPetActionBar));
	self.AccountSettings:SetActionBarShown(PossessActionBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPossessActionBar));
	self.AccountSettings:SetCastBarShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowCastBar));
	self.AccountSettings:SetEncounterBarShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowEncounterBar));
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


function EditModeManagerFrameMixin:UpdateLayoutInfo(layoutInfo, reconcileLayouts)
	self.layoutInfo = layoutInfo;

	if reconcileLayouts then
		self:ReconcileLayoutsWithModern();
	end

	local savedLayouts = self.layoutInfo.layouts;
	self.layoutInfo.layouts = EditModePresetLayoutManager:GetCopyOfPresetLayouts();
	tAppendAll(self.layoutInfo.layouts, savedLayouts);

	self:UpdateSystems();
	self:ClearActiveChangesFlags();

	if self:IsShown() then
		self:UpdateDropdownOptions();
	end
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
	table.insert(options, { value = "postInChat", text = HUD_EDIT_MODE_POST_IN_CHAT, level = 3 });

	self.LayoutDropdown:SetOptions(options, self.layoutInfo.activeLayout);
end

function EditModeManagerFrameMixin:UpdateSystems()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
		if systemInfo then
			systemFrame:UpdateSystem(systemInfo);
		end
	end

	self:UpdateRightAnchoredActionBarWidth();
	self:UpdateBottomAnchoredActionBarHeight();
	self:UpdateRightAnchoredActionBarScales();
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

function EditModeManagerFrameMixin:MakeNewLayout(newLayoutInfo, layoutType, layoutName)
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

		table.insert(self.layoutInfo.layouts, newLayoutIndex, newLayoutInfo);
		self:SaveLayouts();
		C_EditMode.OnLayoutAdded(newLayoutIndex);
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

function EditModeManagerFrameMixin:LinkActiveLayoutToChat()
	CloseDropDownMenus();
	local hyperlink = C_EditMode.ConvertLayoutInfoToHyperlink(self:GetActiveLayoutInfo());
	if not ChatEdit_InsertLink(hyperlink) then
		ChatFrame_OpenChat(hyperlink);
	end
end

function EditModeManagerFrameMixin:ClearActiveChangesFlags()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		systemFrame:SetHasActiveChanges(false);
	end
	self:SetHasActiveChanges(false);
end

function EditModeManagerFrameMixin:ImportLayout(newLayoutInfo, layoutType, layoutName)
	self:RevertAllChanges();
	self:MakeNewLayout(newLayoutInfo, layoutType, layoutName);
end

function EditModeManagerFrameMixin:SaveLayouts()
	C_EditMode.SaveLayouts(self.layoutInfo);
	self:ClearActiveChangesFlags();
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
	local function onAcceptCallback()
		if selectedLayoutIndex then
			self:SelectLayout(selectedLayoutIndex);
		else
			StaticPopup_Hide("GENERIC_CONFIRMATION");
			HideUIPanel(self);
		end
	end

	local data = {text = HUD_EDIT_MODE_UNSAVED_CHANGES_DIALOG_TITLE, callback = onAcceptCallback }
	StaticPopup_ShowCustomGenericConfirmation(data);
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

function EditModeManagerFrameMixin:AddRightActionBarToLayout(barToAdd)
	for i, bar in pairs(self.RightActionBarsInLayout) do
		if bar == barToAdd then
			return;
		end
	end

	table.insert(self.RightActionBarsInLayout, barToAdd);
	table.sort(self.RightActionBarsInLayout, LayoutIndexComparator);
	self:UpdateRightActionBarsLayout();
end

function EditModeManagerFrameMixin:RemoveRightActionBarFromLayout(barToRemove)
	for i, bar in pairs(self.RightActionBarsInLayout) do
		if bar == barToRemove then
			table.remove(self.RightActionBarsInLayout, i);
			table.sort(self.RightActionBarsInLayout, LayoutIndexComparator);
			self:UpdateRightActionBarsLayout();
			break;
		end
	end
end

function EditModeManagerFrameMixin:UpdateRightActionBarsLayout()
	local rightActionBarPadding = -5;
	local leftMostBar;

	for i, bar in pairs(self.RightActionBarsInLayout) do
		local offsetX = rightActionBarPadding;
		if leftMostBar then
			offsetX = offsetX + leftMostBar.systemInfo.anchorInfo.offsetX - leftMostBar:GetWidth();
		end

		bar:ClearAllPoints();
		bar:SetPoint("RIGHT", UIParent, "RIGHT", offsetX, -77);

		local isDefaultPosition = true;
		self:OnSystemPositionChange(bar, isDefaultPosition);

		leftMostBar = bar;
	end

	self:UpdateRightAnchoredActionBarWidth();
end

EditModeDropdownEntryMixin = {};

function EditModeDropdownEntryMixin:Init(text, onClick, width, maxTextWidth, showArrow, isSubmenuButton)
	if width then	
		self:SetWidth(width);
		maxTextWidth = maxTextWidth or width;
	end

	self.Text:SetWidth(0);
	self.Text:SetText(text);

	if maxTextWidth and self.Text:GetStringWidth() > maxTextWidth then
		self.Text:SetWidth(maxTextWidth);
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
end

function EditModeDropdownEntryMixin:OnLeave()
	self.Highlight:Hide();
end

function EditModeDropdownEntryMixin:OnMouseDown()
	self.Text:SetPoint("LEFT", self, "LEFT", 2, -1);
end

function EditModeDropdownEntryMixin:OnMouseUp()
	self.Text:SetPoint("LEFT", self, "LEFT", 0, 0);
	self:onClick();
end

EditModeDropdownLayoutEntryMixin = CreateFromMixins(EditModeDropdownEntryMixin);

function EditModeDropdownLayoutEntryMixin:OnLoad()
	self.CopyLayoutButton:SetOnClickHandler(GenerateClosure(EditModeManagerFrame.ShowNewLayoutDialog, EditModeManagerFrame, self.layoutData));
	self.RenameOrCopyLayoutButton:SetOnClickHandler(GenerateClosure(EditModeManagerFrame.ToggleRenameOrCopyLayoutDropdown, EditModeManagerFrame, self));
	self.DeleteLayoutButton:SetOnClickHandler(GenerateClosure(EditModeManagerFrame.ShowDeleteLayoutDialog, EditModeManagerFrame, self));
end

local layoutEntryMaxTextWidth = 150;

function EditModeDropdownLayoutEntryMixin:Init(layoutIndex, layoutData, isSelected, onClick)
	local text = (layoutData.layoutType == Enum.EditModeLayoutType.Preset) and HUD_EDIT_MODE_PRESET_LAYOUT:format(layoutData.layoutName) or layoutData.layoutName;
	EditModeDropdownEntryMixin.Init(self, text, onClick, nil, layoutEntryMaxTextWidth);

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

	local hasActiveChanges = EditModeManagerFrame:HasActiveChanges();
	self.CopyLayoutButton:SetEnabled(not hasActiveChanges);
	self.RenameOrCopyLayoutButton:SetEnabled(not hasActiveChanges);

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

EditModeNewLayoutDialogMixin = {};

function EditModeNewLayoutDialogMixin:OnLoad()
	self.exclusive = true;
	self.AcceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self))
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self))
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

function EditModeNewLayoutDialogMixin:UpdateAcceptButtonEnabledState()
	self.AcceptButton:SetEnabled(UserEditBoxNonEmpty(self.LayoutNameEditBox));
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
	self.ImportBox.EditBox:SetFocus();
	StaticPopupSpecial_Show(self);
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
	self.AcceptButton:SetEnabled((self.importLayoutInfo ~= nil) and UserEditBoxNonEmpty(self.LayoutNameEditBox));
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
	self.AcceptButton:SetEnabled(UserEditBoxNonEmpty(self.LayoutNameEditBox));
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
	self.pools:CreatePool("BUTTON", self.Buttons, "EditModeSystemSettingsDialogExtraButtonTemplate");
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
					settingsToSetup[settingFrame] = { displayInfo = displayInfo, currentValue = self.attachedToSystem:GetSettingValue(displayInfo.setting), settingName = settingName },
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
	EditModeManagerFrame:OnSystemSettingChange(self.attachedToSystem, setting, value);
end

function EditModeSystemSettingsDialogMixin:RevertChanges()
	EditModeManagerFrame:RevertSystemChanges(self.attachedToSystem);
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
	self.formatters[MinimalSliderWithSteppersMixin.Label.Right] = CreateMinimalSliderFormatter(MinimalSliderWithSteppersMixin.Label.Right, settingData.displayInfo.formatter); -- Just show value on the right by default
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
	self.settingMap = GetSettingMapFromSettings(self.systemInfo.settings, self.settingDisplayInfoMap);

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

EditModeGridLineMixin = {};

local linePixelWidth = 1.2;

function EditModeGridLineMixin:SetupLine(centerLine, verticalLine, xOffset, yOffset)
	local color = centerLine and EDIT_MODE_GRID_CENTER_LINE_COLOR or EDIT_MODE_GRID_LINE_COLOR;
	self:SetColorTexture(color:GetRGBA());

	self:SetStartPoint(verticalLine and "TOP" or "LEFT", EditModeManagerFrame.Grid, xOffset, yOffset);
	self:SetEndPoint(verticalLine and "BOTTOM" or "RIGHT", EditModeManagerFrame.Grid, xOffset, yOffset);

	local lineThickness = PixelUtil.GetNearestPixelSize(linePixelWidth, self:GetEffectiveScale(), linePixelWidth);
	self:SetThickness(lineThickness);
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

function EditModeGridMixin:SetGridSpacing(spacing)
	self.gridSpacing = spacing;
	self:UpdateGrid();
end

function EditModeGridMixin:UpdateGrid()
	if not self:IsShown() then
		return;
	end

	self.linePool:ReleaseAll();

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
end

function EditModeAccountSettingsMixin:OnEditModeEnter()
	self.oldTargetName = UnitName("target");
	self.oldFocusName = UnitName("focus");
	self:RefreshTargetAndFocus();

	self.oldActionBarSettings = {};
	local function SetupActionBar(bar)
		self.oldActionBarSettings[bar] = {
			isShown = bar:IsShown();
			numShowingButtons = bar.numShowingButtons;
		}
		self:RefreshActionBarShown(bar);
	end
	SetupActionBar(StanceBar);
	SetupActionBar(PetActionBar);
	SetupActionBar(PossessActionBar);

	self:RefreshCastBar();
	self:RefreshEncounterBar();
end

function EditModeAccountSettingsMixin:OnEditModeExit()
	local clearSavedTargetAndFocus = true;
	self:ResetTargetAndFocus(clearSavedTargetAndFocus);
	self:ResetActionBarShown(StanceBar);
	self:ResetActionBarShown(PetActionBar);
	self:ResetActionBarShown(PossessActionBar);
end

function EditModeAccountSettingsMixin:ResetTargetAndFocus(clearSavedTargetAndFocus)
	if self.oldTargetName then
		TargetUnit(self.oldTargetName);
	else
		ClearTarget();
	end

	if self.oldFocusName then
		FocusUnit(self.oldFocusName);
	else
		ClearFocus();
	end

	if clearSavedTargetAndFocus then
		self.oldTargetName = nil;
		self.oldFocusName = nil;
	end
end

function EditModeAccountSettingsMixin:RefreshTargetAndFocus()
	local showTargetAndFocus = self.Settings.TargetAndFocus:IsControlChecked();
	if showTargetAndFocus then
		if not TargetFrame:IsShown() then
			TargetUnit("player");
		end

		if not FocusFrame:IsShown() then
			FocusUnit("player");
		end
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

function EditModeAccountSettingsMixin:ResetActionBarShown(bar)
	bar.numShowingButtons = self.oldActionBarSettings[bar].numShowingButtons;
	bar:SetShowGrid(false, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	bar:SetShown(self.oldActionBarSettings[bar].isShown);
end

function EditModeAccountSettingsMixin:RefreshActionBarShown(bar)
	local barName = bar:GetName();
	local show = self.Settings[barName]:IsControlChecked();

	if show then
		if not bar:IsShown() then
			bar.numShowingButtons = bar.numButtons;
			bar:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
			bar:Show();
		end
	else
		self:ResetActionBarShown(bar);
	end

	if EditModeUtil:IsBottomAnchoredActionBar(bar) then
		EditModeManagerFrame:UpdateBottomAnchoredActionBarHeight();
	elseif EditModeUtil:IsRightAnchoredActionBar(bar) then
		EditModeManagerFrame:UpdateRightAnchoredActionBarWidth();
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
	PlayerCastingBarFrame:StopAnims();
	PlayerCastingBarFrame:SetAlpha(0);
	PlayerCastingBarFrame:SetShown(showCastBar);
	UIParent_ManageFramePositions();
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

EditModeUtil = { };

function EditModeUtil:IsRightAnchoredActionBar(systemFrame)
	return (systemFrame == MultiBarRight)
		or (systemFrame == MultiBarLeft);
end

function EditModeUtil:IsBottomAnchoredActionBar(systemFrame)
	return (systemFrame == MultiBarBottomRight)
		or (systemFrame == MultiBarBottomLeft)
		or (systemFrame == MainMenuBar)
		or (systemFrame == StanceBar)
		or (systemFrame == PetActionBar)
		or (systemFrame == PossessActionBar);
end

function EditModeUtil:GetRightActionBarWidth()
	local offset = 0;
	if MultiBar3_IsVisible and MultiBar3_IsVisible() and MultiBarRight:IsInDefaultPosition() then
		local point, relativeTo, relativePoint, offsetX, offsetY = MultiBarRight:GetPoint(1);
		offset = MultiBarRight:GetWidth() - offsetX; -- Subtract x offset since it will be a negative value due to us anchoring to the right side and anchoring towards the middle
	end

	if MultiBar4_IsVisible and MultiBar4_IsVisible() and MultiBarLeft:IsInDefaultPosition() then
		local point, relativeTo, relativePoint, offsetX, offsetY = MultiBarLeft:GetPoint(1);
		offset = MultiBarLeft:GetWidth() - offsetX;
	end

	return offset;
end

function EditModeUtil:GetBottomActionBarHeight(includeMainMenuBar)
	local actionBarHeight = 0;
	actionBarHeight = includeMainMenuBar and MainMenuBar:GetBottomAnchoredHeight() or 0;
	actionBarHeight = actionBarHeight + MultiBarBottomLeft:GetBottomAnchoredHeight();
	actionBarHeight = actionBarHeight + MultiBarBottomRight:GetBottomAnchoredHeight();
	actionBarHeight = actionBarHeight + StanceBar:GetBottomAnchoredHeight();
	actionBarHeight = actionBarHeight + (PetActionBar and PetActionBar:GetBottomAnchoredHeight() or 0);
	actionBarHeight = actionBarHeight + PossessActionBar:GetBottomAnchoredHeight();
	return actionBarHeight;
end

function EditModeUtil:GetRightContainerAnchor()
	local rightBarOffset = EditModeUtil:GetRightActionBarWidth();
	local anchor = AnchorUtil.CreateAnchor("TOPRIGHT", UIParent, "TOPRIGHT", -rightBarOffset, -260);
	return anchor;
end