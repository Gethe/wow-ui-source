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
			newButton:Init(dropDownButtonInfo.value, dropDownButtonInfo.data, self.editModeInfo.activeLayout == dropDownButtonInfo.value, selectLayout);
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

	self.onCloseCallback = onCloseCallback;

	self.LayoutDropdown:SetOptionSelectedCallback(layoutSelectedCallback);
	self.SaveChangesButton:SetOnClickHandler(GenerateClosure(self.SaveLayoutChanges, self));
	self.RevertAllChangesButton:SetOnClickHandler(GenerateClosure(self.RevertAllChanges, self));

	self:RegisterEvent("EDIT_MODE_DATA_UPDATED");
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
end

function EditModeManagerFrameMixin:OnShow()
	if not self:IsEditModeLocked() then
		self:EnterEditMode();
	elseif self:IsEditModeInLockState("hideSelections")  then
		self:ShowSystemSelections();
	end

	self:ClearEditModeLockState();
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
	if event == "EDIT_MODE_DATA_UPDATED" then
		local editModeInfo, reconcileLayouts = ...;
		self:UpdateEditModeInfo(editModeInfo, reconcileLayouts);
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		local editModeInfo = C_EditMode.GetEditModeInfo();
		local activeLayoutChanged = (editModeInfo.activeLayout ~= self.editModeInfo.activeLayout);
		self:UpdateEditModeInfo(editModeInfo);
		if activeLayoutChanged then
			self:NotifyChatOfLayoutChange();
		end
	elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		self:UpdateRightAnchoredActionBarScales();
	end
end

function EditModeManagerFrameMixin:IsInitialized()
	return self.editModeInfo ~= nil;
end

function EditModeManagerFrameMixin:RegisterSystemFrame(systemFrame)
	table.insert(self.registeredSystemFrames, systemFrame);
end

local function AreAnchorsEqual(anchorInfo, otherAnchorInfo)
	if anchorInfo and otherAnchorInfo then
		return anchorInfo.point == otherAnchorInfo.point
		and anchorInfo.relativeTo == otherAnchorInfo.relativeTo
		and anchorInfo.relativePoint == otherAnchorInfo.relativePoint
		and anchorInfo.offsetX == otherAnchorInfo.offsetX
		and anchorInfo.offsetY == otherAnchorInfo.offsetY;
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
		anchorInfo.relativeTo = relativeTo or "UIParent";
		anchorInfo.relativePoint = relativePoint;
		anchorInfo.offsetX = offsetX;
		anchorInfo.offsetY = offsetY;
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

local function UpdateSystemAnchorInfo(systemInfo, systemFrame)
	local newAnchorInfo = ConvertToAnchorInfo(systemFrame:GetPoint(1));
	if not AreAnchorsEqual(systemInfo.anchorInfo, newAnchorInfo) then
		CopyAnchorInfo(systemInfo.anchorInfo, newAnchorInfo);
		return true;
	end

	return false;
end

local function IsRightAnchoredActionBar(systemFrame)
	return (systemFrame == MultiBarRight) or (systemFrame == MultiBarLeft);
end

local function IsBottomAnchoredActionBar(systemFrame)
	return (systemFrame == MultiBarBottomRight) or (systemFrame == MultiBarBottomLeft) or (systemFrame == MainMenuBar);
end

function EditModeManagerFrameMixin:OnSystemPositionChange(systemFrame)
	local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		if UpdateSystemAnchorInfo(systemInfo, systemFrame) then
			systemFrame:SetHasActiveChanges(true);

			if IsRightAnchoredActionBar(systemFrame) then
				self:UpdateRightAnchoredActionBarWidth();
				self:UpdateRightAnchoredActionBarScales();
			end

			if IsBottomAnchoredActionBar(systemFrame) then
				self:UpdateBottomAnchoredActionBarHeight();
			end

			EditModeSystemSettingsDialog:UpdateDialog(systemFrame);
		end
	end
end

function EditModeManagerFrameMixin:OnSystemSettingChange(systemFrame, changedSetting, newValue)
	local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		local rawNewValue = systemFrame:ConvertSettingDisplayValueToRawValue(changedSetting, newValue);
		for _, settingInfo in pairs(systemInfo.settings) do
			if settingInfo.setting == changedSetting then
				if settingInfo.value ~= rawNewValue then
					settingInfo.value = rawNewValue;
					systemFrame:UpdateSystem(systemInfo);
				end
				return;
			end
		end
	end
end

function EditModeManagerFrameMixin:RevertSystemChanges(systemFrame)
	local activeLayoutInfo = self:GetActiveLayoutInfo();
	if activeLayoutInfo then
		for index, systemInfo in ipairs(activeLayoutInfo.systems) do
			if systemInfo.system == systemFrame.system and systemInfo.systemIndex == systemFrame.systemIndex then
				activeLayoutInfo.systems[index] = systemFrame.savedSystemInfo;

				local savedData = true;
				systemFrame:UpdateSystem(systemFrame.savedSystemInfo, savedData);
				self:CheckForSystemActiveChanges();
				return;
			end
		end
	end
end

function EditModeManagerFrameMixin:GetRightAnchoredActionBarWidth()
	return self.rightAnchoredActionBarWidth;
end

function EditModeManagerFrameMixin:GetBottomAnchoredActionBarHeight()
	return self.bottomAnchoredActionBarHeight;
end

function EditModeManagerFrameMixin:UpdateRightAnchoredActionBarWidth()
	self.rightAnchoredActionBarWidth = EditModeUtil.GetRightActionBarWidth(); 
	UIParent_ManageFramePositions();
end

function EditModeManagerFrameMixin:UpdateRightAnchoredActionBarScales()
	if not self:IsInitialized() then
		return;
	end

	local topLimit = MinimapCluster:GetBottom() - 10;
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
	self.bottomAnchoredActionBarHeight =  EditModeUtil.GetBottomActionBarHeight(includeMainMenuBar); 
	UIParent_ManageFramePositions();
end

function EditModeManagerFrameMixin:SelectSystem(selectFrame)
	if not self:IsEditModeLocked() then
		for _, systemFrame in ipairs(self.registeredSystemFrames) do
			if systemFrame == selectFrame then
				systemFrame:SelectSystem();
			else
				systemFrame:HighlightSystem();
			end
		end
	end
end

function EditModeManagerFrameMixin:ClearSelectedSystem()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		systemFrame:HighlightSystem();
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
	for _, layoutInfo in ipairs(self.editModeInfo.layouts) do
		if self:ReconcileWithModern(layoutInfo) then
			somethingChanged = true;
		end
	end

	if somethingChanged then
		-- Something changed, so we need to send the updated edit mode info up to be saved on logout
		C_EditMode.SaveEditModeInfo(self.editModeInfo);
	end
end

function EditModeManagerFrameMixin:UpdateEditModeInfo(editModeInfo, reconcileLayouts)
	self.editModeInfo = editModeInfo;

	if reconcileLayouts then
		self:ReconcileLayoutsWithModern();
	end

	local savedLayouts = self.editModeInfo.layouts;
	self.editModeInfo.layouts = EditModePresetLayoutManager:GetCopyOfPresetLayouts();
	tAppendAll(self.editModeInfo.layouts, savedLayouts);

	self:UpdateSystems();
	self:ClearActiveChangesFlags();

	if self:IsShown() then
		self:UpdateDropdownOptions();
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
	for index, layoutInfo in ipairs(self.editModeInfo.layouts) do
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

	self.LayoutDropdown:SetOptions(options, self.editModeInfo.activeLayout);
end

function EditModeManagerFrameMixin:UpdateSystems()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
		if systemInfo then
			local savedData = true;
			systemFrame:UpdateSystem(systemInfo, savedData);
		end
	end

	self:UpdateRightAnchoredActionBarWidth();
	self:UpdateBottomAnchoredActionBarHeight();
	self:UpdateRightAnchoredActionBarScales();
end

function EditModeManagerFrameMixin:GetActiveLayoutInfo()
	return self.editModeInfo and self.editModeInfo.layouts[self.editModeInfo.activeLayout];
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
	if layoutIndex ~= self.editModeInfo.activeLayout then
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

		table.insert(self.editModeInfo.layouts, newLayoutIndex, newLayoutInfo);
		self:SaveLayouts();
		C_EditMode.OnLayoutAdded(newLayoutIndex);
	end
end

function EditModeManagerFrameMixin:DeleteLayout(layoutIndex)
	local deleteLayoutInfo = self.editModeInfo.layouts[layoutIndex];
	if deleteLayoutInfo and deleteLayoutInfo.layoutType ~= Enum.EditModeLayoutType.Preset then
		table.remove(self.editModeInfo.layouts, layoutIndex);
		self:SaveLayouts();
		C_EditMode.OnLayoutDeleted(layoutIndex);
	end
end

function EditModeManagerFrameMixin:RenameLayout(layoutIndex, layoutName)
	if layoutName ~= "" then
		local renameLayoutInfo = self.editModeInfo.layouts[layoutIndex];
		if renameLayoutInfo and renameLayoutInfo.layoutType ~= Enum.EditModeLayoutType.Preset then
			renameLayoutInfo.layoutName = layoutName;
			self:SaveLayouts();
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
	C_EditMode.SaveEditModeInfo(self.editModeInfo);
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
	self:UpdateEditModeInfo(C_EditMode.GetEditModeInfo());
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
	self.systemChanged = not self.attachedToSystem or self.attachedToSystem.system ~= systemFrame.system;
	self.attachedToSystem = systemFrame;
	self.Title:SetText(systemFrame.systemName);
	self:UpdateDialog(systemFrame);
	self:Show();
end

local edgePercentage = 2 / 5;
local edgePercentageInverse =  1 - edgePercentage;

function EditModeSystemSettingsDialogMixin:UpdateSizeAndAnchors(systemFrame)
	if systemFrame == self.attachedToSystem then
		if self.systemChanged then
			local clearAllPoints = true;
			systemFrame:GetSettingsDialogAnchor():SetPoint(self, clearAllPoints);
			self.systemChanged = false;
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
			if self.attachedToSystem:HasSetting(displayInfo.setting) then 
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

		self.Settings:Layout();

		for settingFrame, settingData in pairs(settingsToSetup) do
			settingFrame:SetupSetting(settingData);
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

	self.systemName = self.systemIndex and self.systemNameString:format(self.systemIndex) or self.systemNameString;
	self.Selection:SetLabelText(self.systemName);
	self:SetupSettingsDialogAnchor();

	self.settingDisplayInfoMap = EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfoMap(self.system);
	self.settingMap = {};
end

function EditModeSystemMixin:ConvertSettingDisplayValueToRawValue(setting, value)
	if self.settingDisplayInfoMap[setting] then
		return self.settingDisplayInfoMap[setting]:ConvertValue(value);
	else
		return value;
	end
end

function EditModeSystemMixin:UpdateSystem(systemInfo, savedData)
	if savedData then
		self.savedSystemInfo = CopyTable(systemInfo);
		self:SetHasActiveChanges(false);
	else
		self:SetHasActiveChanges(true);
	end

	self.settingMap = GetSettingMapFromSettings(systemInfo.settings, self.settingDisplayInfoMap);

	self:ClearAllPoints();

	self.systemInfo = systemInfo;
	self:SetPoint(self.systemInfo.anchorInfo.point, self.systemInfo.anchorInfo.relativeTo, self.systemInfo.anchorInfo.relativePoint, self.systemInfo.anchorInfo.offsetX, self.systemInfo.anchorInfo.offsetY);

	EditModeSystemSettingsDialog:UpdateDialog(self);
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
end

function EditModeSystemMixin:HighlightSystem()
	self:SetMovable(false);
	self.Selection:ShowHighlighted();
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
	self:HighlightSystem();
end

function EditModeSystemMixin:OnEditModeExit()
	self:ClearHighlight();
	EditModeSystemSettingsDialog:Hide();
end

function EditModeSystemMixin:OnDragStart()
	if self.isSelected then
		self:StartMoving();
	end
end

function EditModeSystemMixin:OnDragStop()
	if self.isSelected then
		self:StopMovingOrSizing();
		EditModeManagerFrame:OnSystemPositionChange(self);
	end
end

EditModeActionBarSystemMixin = {};

function EditModeActionBarSystemMixin:EditModeActionBarSystem_OnLoad()
	self.OnEditModeEnterBase = self.OnEditModeEnter;
	self.OnEditModeEnter = self.OnEditModeEnterOverride;

	self.OnEditModeExitBase = self.OnEditModeExit;
	self.OnEditModeExit = self.OnEditModeExitOverride;
end

function EditModeActionBarSystemMixin:OnEditModeEnterOverride()
	self:OnEditModeEnterBase();

	-- Some action bars have special visibility rules so use their method for whether to turn them on/off on enter
	self:UpdateVisibility();
end

function EditModeActionBarSystemMixin:OnEditModeExitOverride()
	self:OnEditModeExitBase();

	-- Some action bars have special visibility rules so use their method for whether to turn them on/off on exit
	self:UpdateVisibility();
end

function EditModeActionBarSystemMixin:IsCurrentlyRightAnchored()
	if not self:IsInitialized() then
		return false;
	end

	if self.systemInfo.anchorInfo.point == "RIGHT" then
		if self == MultiBarRight and self.systemInfo.anchorInfo.relativeTo == "UIParent" then
			return self.systemInfo.anchorInfo.offsetX == 0;
		elseif self == MultiBarLeft and self.systemInfo.anchorInfo.relativeTo == "MultiBarRight" then
			return MultiBarRight:IsCurrentlyRightAnchored();
		end
	end

	return false;
end

function EditModeActionBarSystemMixin:SetScaleIfRightAnchored(scale)
	if self:IsCurrentlyRightAnchored() then
		self:SetScale(scale);
	else
		self:SetScale(1);
	end
end

function EditModeActionBarSystemMixin:GetRightAnchoredWidth()
	if not self:IsInitialized() then
		return 0;
	end

	if self:IsShown() and self:IsCurrentlyRightAnchored() then
		return self:GetWidth() + -self.systemInfo.anchorInfo.offsetX;
	end

	return 0;
end

function EditModeActionBarSystemMixin:IsCurrentlyBottomAnchored()
	if not self:IsInitialized() then
		return false;
	end

	if self.systemInfo.anchorInfo.point == "BOTTOM" then
		if self == MainMenuBar and self.systemInfo.anchorInfo.relativeTo == "UIParent" then
			return self.systemInfo.anchorInfo.offsetY <= 25;
		elseif self == MultiBarBottomLeft and self.systemInfo.anchorInfo.relativeTo == "MainMenuBar" then
			return MainMenuBar:IsCurrentlyBottomAnchored();
		elseif self == MultiBarBottomRight and self.systemInfo.anchorInfo.relativeTo == "MultiBarBottomLeft" then
			return MultiBarBottomLeft:IsCurrentlyBottomAnchored();
		end
	end

	return false;
end

function EditModeActionBarSystemMixin:GetBottomAnchoredHeight()
	if not self:IsInitialized() then
		return 0;
	end

	if self:IsShown() and self:IsCurrentlyBottomAnchored() then
		return self:GetHeight() + self.systemInfo.anchorInfo.offsetY;
	end

	return 0;
end

function EditModeActionBarSystemMixin:UpdateSystem(systemInfo, savedData)
	EditModeSystemMixin.UpdateSystem(self, systemInfo, savedData);

	local shouldUpdateGridLayout = false;
	local shouldUpdateButtonArt = false;

	-- Update orientation
	if self:HasSetting(Enum.EditModeActionBarSetting.Orientation) then
		self.isHorizontal = self:DoesSettingValueEqual(Enum.EditModeActionBarSetting.Orientation, Enum.ActionBarOrientation.Horizontal);
		self.Selection:SetVerticalState(not self.isHorizontal);

		self.addButtonsToRight = true;
		if self.isHorizontal then
			self.addButtonsToTop = true;
		else
			self.addButtonsToTop = false;
		end

		-- Since the orientation changed we'll want to update the grid layout and the art
		-- Update the art since we'll possibly be switching from horizontal to vertical dividers
		shouldUpdateGridLayout = true;
		shouldUpdateButtonArt = true;
	end

	-- Update num rows
	if self:HasSetting(Enum.EditModeActionBarSetting.NumRows) then
		self.numRows = self:GetSettingValue(Enum.EditModeActionBarSetting.NumRows);

		-- Since the num rows changed we'll want to update the grid layout and the art
		-- Update the art since we hide dividers when num rows > 1
		shouldUpdateGridLayout = true;
		shouldUpdateButtonArt = true;
	end

	-- Update num icons
	if self:HasSetting(Enum.EditModeActionBarSetting.NumIcons) then
		self.numShowingButtons = self:GetSettingValue(Enum.EditModeActionBarSetting.NumIcons);
		self:UpdateShownButtons();

		-- Since the num rows changed we'll want to update the grid layout and the art
		-- Update the art since we'll need to change what dividers are shown specifically for the new last button
		shouldUpdateGridLayout = true;
		shouldUpdateButtonArt = true;
	end

	-- Update icon size
	if self:HasSetting(Enum.EditModeActionBarSetting.IconSize) then
		local iconSizeSetting = self:GetSettingValue(Enum.EditModeActionBarSetting.IconSize);

		local iconScale = iconSizeSetting / 100;

		if self.EditModeSetScale then
			self:EditModeSetScale(iconScale);
		end

		for i, buttonOrSpacer in pairs(self.buttonsAndSpacers) do
			buttonOrSpacer:SetScale(iconScale);
		end

		-- Since size of buttons changed we'll want to update the grid layout so we can resize the bar's frame
		shouldUpdateGridLayout = true;
	end

	-- Update icon padding
	if self:HasSetting(Enum.EditModeActionBarSetting.IconPadding) then
		self.buttonPadding = self:GetSettingValue(Enum.EditModeActionBarSetting.IconPadding);

		-- Since the icon padding changed we'll want to update the grid layout and the art
		-- Update art since we will hide dividers if padding is changed
		shouldUpdateButtonArt =  true;
		shouldUpdateGridLayout =  true;
	end

	-- Update whether we show bar art
	if self:HasSetting(Enum.EditModeActionBarSetting.HideBarArt) then
		local hideBarArt = self:GetSettingValueBool(Enum.EditModeActionBarSetting.HideBarArt);

		self:UpdateEndCaps(hideBarArt);
		self.BorderArt:SetShown(not hideBarArt);
		self.Background:SetShown(not hideBarArt);

		for i, actionButton in pairs(self.ActionButtons) do
			actionButton.showButtonArt = not hideBarArt;
		end
		shouldUpdateButtonArt =  true;
	end

	-- Update whether we show bar scrolling
	if self:HasSetting(Enum.EditModeActionBarSetting.HideBarScrolling) then
		self.ActionBarPageNumber:SetShown(not self:GetSettingValueBool(Enum.EditModeActionBarSetting.HideBarScrolling));
	end

	-- Update bar visibility
	if self:HasSetting(Enum.EditModeActionBarSetting.VisibleSetting) then
		if self:DoesSettingValueEqual(Enum.EditModeActionBarSetting.VisibleSetting, Enum.ActionBarVisibleSetting.InCombat) then
			self.visibility = "InCombat";
		elseif self:DoesSettingValueEqual(Enum.EditModeActionBarSetting.VisibleSetting, Enum.ActionBarVisibleSetting.OutOfCombat) then
			self.visibility = "OutOfCombat"
		else
			self.visibility = "Always";
		end
		self:UpdateVisibility();
	end

	-- Update always show buttons
	if self:HasSetting(Enum.EditModeActionBarSetting.AlwaysShowButtons) then
		local alwaysShowButtons = self:GetSettingValueBool(Enum.EditModeActionBarSetting.AlwaysShowButtons);
		self:SetShowGrid(alwaysShowButtons, ACTION_BUTTON_SHOW_GRID_REASON_CVAR);
	end

	-- If we changed anything that could mess with the grid layout we should update it
	if shouldUpdateGridLayout then
		self:UpdateGridLayout();

		-- Update frame positions since if we update the size of the action bars then we'll wanna update the position of things relative to those action bars
		UIParent_ManageFramePositions();
	end

	-- If we changed anything that could mess with the button art then we should update it
	if shouldUpdateButtonArt then
		for i, actionButton in pairs(self.ActionButtons) do
			actionButton:UpdateButtonArt(i >= self.numShowingButtons);
		end
	end
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

	local actionBarSettingsButton = extraButtonPool:Acquire();
	actionBarSettingsButton.layoutIndex = 4;
	actionBarSettingsButton:SetText(HUD_EDIT_MODE_ACTION_BAR_SETTINGS);
	actionBarSettingsButton:SetOnClickHandler(openActionBarSettings);
	actionBarSettingsButton:Show();

	return true;
end

EditModeSystemSelectionMixin = {};

function EditModeSystemSelectionMixin:SetLabelText(text)
	self.Label:SetText(text);
end

function EditModeSystemSelectionMixin:ShowHighlighted()
	self.isSelected = false;	
	self:UpdateLabelVisibility();
	self:Show();
end

function EditModeSystemSelectionMixin:ShowSelected()
	self.isSelected = true;	
	self:UpdateLabelVisibility();
	self:Show();
end

function EditModeSystemSelectionMixin:UpdateLabelVisibility()
	self.Label:SetShown(self.isSelected);
end

function EditModeSystemSelectionMixin:OnDragStart()
	self:GetParent():OnDragStart();
end

function EditModeSystemSelectionMixin:OnDragStop()
	self:GetParent():OnDragStop();
end

function EditModeSystemSelectionMixin:OnMouseDown()
	EditModeManagerFrame:SelectSystem(self:GetParent());
end

local EditModeActionBarSystemLayout =
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

EditModeActionBarSystemSelectionMixin = {};

function EditModeActionBarSystemSelectionMixin:SetLabelText(text)
	self.HorizontalLabel:SetText(text);
	self.VerticalLabel:SetText(text);
end

function EditModeActionBarSystemSelectionMixin:ShowHighlighted()
	NineSliceUtil.ApplyLayout(self, EditModeActionBarSystemLayout, self.highlightTextureKit);
	EditModeSystemSelectionMixin.ShowHighlighted(self);
end

function EditModeActionBarSystemSelectionMixin:ShowSelected()
	NineSliceUtil.ApplyLayout(self, EditModeActionBarSystemLayout, self.selectedTextureKit);
	EditModeSystemSelectionMixin.ShowSelected(self);
end

function EditModeActionBarSystemSelectionMixin:SetVerticalState(vertical)
	self.isVertical = vertical;
	self:UpdateLabelVisibility();
end

function EditModeActionBarSystemSelectionMixin:UpdateLabelVisibility()
	self.HorizontalLabel:SetShown(self.isSelected and not self.isVertical);
	self.VerticalLabel:SetShown(self.isSelected and self.isVertical);
end


EditModeUtil = { }; 

function EditModeUtil:GetBottomActionBarAnchor()
	local anchor; 
	if(OverrideActionBar and OverrideActionBar:IsShown()) then 
		anchor = AnchorUtil.CreateAnchor("BOTTOM", OverrideActionBar, "TOP",0, 40);
	elseif(MultiBarBottomRight:IsShown() and MultiBarBottomRight:IsCurrentlyBottomAnchored()) then
		anchor = AnchorUtil.CreateAnchor("BOTTOM", MultiBarBottomRight, "TOP", 0, 5);
	elseif(MultiBarBottomLeft:IsShown() and MultiBarBottomLeft:IsCurrentlyBottomAnchored()) then 
		anchor = AnchorUtil.CreateAnchor("BOTTOM", MultiBarBottomLeft, "TOP", 0, 5);
	elseif(MainMenuBar:IsShown() and MainMenuBar:IsCurrentlyBottomAnchored()) then
		anchor = AnchorUtil.CreateAnchor("BOTTOM", MainMenuBar, "TOP", 0, 15);
	else
		anchor = AnchorUtil.CreateAnchor("BOTTOM", UIParent, 80);
	end
	return anchor; 
end 

function EditModeUtil:GetRightActionBarWidth()
	local rightActionBarWidth = 0; 

	if MultiBarRight:IsShown() then
		local point, relativeTo, relativePoint, offsetX, offsetY = MultiBarRight:GetPoint(1);
		if point == "RIGHT" and relativeTo == UIParent and relativePoint == "RIGHT" and offsetX == -5 then
			rightActionBarWidth = MultiBarRight:GetWidth();

			if MultiBarLeft:IsShown() then
				point, relativeTo, relativePoint, offsetX, offsetY = MultiBarLeft:GetPoint(1);
				if relativeTo == MultiBarRight then
					rightActionBarWidth = rightActionBarWidth + MultiBarLeft:GetWidth() - offsetX;
				end
			end
		end
	end

	return rightActionBarWidth;
end

function EditModeUtil:GetBottomActionBarHeight(includeMainMenuBar)
	local actionBarHeight = 0; 
	actionBarHeight = includeMainMenuBar and MainMenuBar:GetBottomAnchoredHeight() or 0;
	actionBarHeight = actionBarHeight + MultiBarBottomLeft:GetBottomAnchoredHeight();
	actionBarHeight = actionBarHeight + MultiBarBottomRight:GetBottomAnchoredHeight();
	return actionBarHeight; 
end

function EditModeUtil:GetRightContainerAnchor()
	local anchor; 
	local rightBarOffset = EditModeUtil.GetRightActionBarWidth();
	
	if(not Minimap:IsUserPlaced()) then
		anchor = AnchorUtil.CreateAnchor("TOP", MinimapCluster, "BOTTOM", -rightBarOffset, -5);
	else
		anchor = AnchorUtil.CreateAnchor("TOP", UIParent, "TOP", -rightBarOffset, -60);
	end
	return anchor; 
end 