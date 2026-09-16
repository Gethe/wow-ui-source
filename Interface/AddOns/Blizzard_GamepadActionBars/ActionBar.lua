local HIGHLIGHT_ACTIVE_FRAME_LEVEL = 5;
local HIGHLIGHT_INACTIVE_FRAME_LEVEL = 4;
local LEFTSQUARE_RIGHTCIRCLE_STYLE = 0;

GamepadActionBarMixin = {}

function GamepadActionBarMixin:InitActionButtons()
	self.actionButtons = {};
	-- Make sure button backgrounds stay on and sub to soft enemy changing.
	local NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP = Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP;
	for i = 1, NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP do
		local actionButton = "ActionButton" .. i;
		local leftGroupButton = self.Left[actionButton];
		local rightGroupButton = self.Right[actionButton];

		self.actionButtons[i] = leftGroupButton;
		self.actionButtons[NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP + i] = rightGroupButton;

		leftGroupButton:SetButtonIndexOnActionBar(i);
		rightGroupButton:SetButtonIndexOnActionBar(NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP + i);

		leftGroupButton:SetAttribute("showgrid", 1);
		rightGroupButton:SetAttribute("showgrid", 1);

		leftGroupButton:Show();
		rightGroupButton:Show();

		rightGroupButton.HotKey:Hide();
		rightGroupButton.HotKey.Show = function() end;

		leftGroupButton.HotKey:Hide();
		leftGroupButton.HotKey.Show = function() end;

		leftGroupButton:SetActionBarParent(self);
		rightGroupButton:SetActionBarParent(self);

		leftGroupButton.ButtonIcon:SetSize(20, 20);
		rightGroupButton.ButtonIcon:SetSize(20, 20);
	end
end

function GamepadActionBarMixin:OnLoad()
	self.supportsActionButtonPaging = false; -- Default to no paging support.
	self.IsActionBarUsable = function() return false; end;

	-- Initialize the action bar style
	GamepadActionBarStyleUtil.ApplyCollapsedActionBarStyle(self, LEFTSQUARE_RIGHTCIRCLE_STYLE);

	self:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED");

	self:ApplyKeyValueCustomizations();
	self:InitActionButtons();
end

function GamepadActionBarMixin:OnEvent(event, ...)
	if (event == "PLAYER_SOFT_ENEMY_CHANGED" and not self.isGamepadPossessBar) then
		for _, actionButton in ipairs(self.actionButtons) do
			actionButton:UpdateUsable();
		end
	end
end

function GamepadActionBarMixin:HideButtonIcons()
	for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP do
		local actionButton = "ActionButton" .. i;
		self.Left[actionButton].ButtonIcon:Hide();
		self.Right[actionButton].ButtonIcon:Hide();
	end
end

function GamepadActionBarMixin:ShowButtonIcons()
	for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP do
		local actionButton = "ActionButton" .. i;
		self.Left[actionButton].ButtonIcon:Show();
		self.Right[actionButton].ButtonIcon:Show();
	end
end

function GamepadActionBarMixin:ShowHighlight()
	-- Do not refresh the action bar to an active state when HUD input is blocked.
	if not self:IsActionBarUsable() then
		return;
	end

	local shouldShowButtonIcons = CVarCallbackRegistry:GetCVarValueBool("GamepadShowActionBarButtonPrompts");
	local shouldShowHighlight = CVarCallbackRegistry:GetCVarValueBool("GamepadShowActionBarHighlight");
	local shouldShowScaling = CVarCallbackRegistry:GetCVarValueBool("GamepadShowActionBarScaling");

	-- If we disable scaling, button icons overlap the spell icons so disabling scaling will also disable buttons for now.
	if shouldShowButtonIcons and shouldShowScaling then
		self:ShowButtonIcons();
	else
		self:HideButtonIcons();
	end

	self:SetFrameLevel(HIGHLIGHT_ACTIVE_FRAME_LEVEL);

	if shouldShowHighlight then
		self.BackgroundFocus:Show();
	end

	if shouldShowScaling then
		self:ExpandActionButtons();
		self.actionBarScaledUp = true;
	end
end

function GamepadActionBarMixin:HideHighlight()
	self:HideButtonIcons();
	self:SetFrameLevel(HIGHLIGHT_INACTIVE_FRAME_LEVEL);

	if self.BackgroundFocus:IsShown() then
		self.BackgroundFocus:Hide();
	end

	if self.actionBarScaledUp then
		self:CollapseActionButtons();
		self.actionBarScaledUp = false;
	end

	self.LeftButtonFrame:Hide();
	self.RightButtonFrame:Hide();
end

function GamepadActionBarMixin:ExpandActionButtons()
	GamepadActionBarStyleUtil.ApplyExpandedActionBarStyle(self, self.appliedStyle);
end

function GamepadActionBarMixin:CollapseActionButtons()
	GamepadActionBarStyleUtil.ApplyCollapsedActionBarStyle(self, self.appliedStyle);

	for _, actionButton in ipairs(self.actionButtons) do
		-- Fixes an issue where the button can remain in the pushed state when the active action bar is changed.
		if actionButton:IsEnabled() then
			actionButton:SetButtonState("NORMAL");
		end
	end
end

function GamepadActionBarMixin:SetIsActionBarUsableFunc(func)
	self.IsActionBarUsable = func;
end

function GamepadActionBarMixin:SetActionBarShowSetting(cvarName)
	self.actionBarShowSetting = cvarName;
end

local function GetGamepadActionBarShowSettingValue(gamepadActionBar)
	if (gamepadActionBar.actionBarShowSetting) then
		return CVarCallbackRegistry:GetCVarValueBool(gamepadActionBar.actionBarShowSetting);
	else
		return true;
	end
end

function GamepadActionBarMixin:RefreshActionBarVisibility()
	local function shouldShow()
		if not InputUtil.IsGamepadUIEnabled() then
			return false;
		end

		local pageUnit = self.pagingUnitOwner;
		if pageUnit:IsAnyOverrideBarOverridingActionBar(self) then
			return false;
		end

		local currentPage = pageUnit:GetCurrentPage();
		if currentPage == Constants.GamepadActionBarConstants.GAMEPAD_ACTION_BAR_PAGE_UNIT_SPECIAL_PAGE_INDEX then
			return false;
		end

		if pageUnit:ShouldUseCompactLayout() and pageUnit:GetActiveBar() ~= self then
			return false;
		end

		if not GetGamepadActionBarShowSettingValue(self) and self:IsBarEmpty() then
			return false;
		end

		return true;
	end

	self:SetShown(shouldShow());
end

--[[
	Returns a true or false value depending on if all the action buttons that the
	action bar is made up of are empty with their currently assigned ids.
]]
function GamepadActionBarMixin:IsBarEmpty()
	for _, actionButton in ipairs(self.actionButtons) do
		local pageUnitSlotID = actionButton:GetGamepadPageUnitSlotID();
		if not GamepadActionBarBindingUtil.IsBindablePageUnitSlotID(pageUnitSlotID) then
			return false;	-- Handle hardcoded bindings.
		end

		if (actionButton:HasAction()) then
			return false;
		end
	end

	return true;
end

--[[
	Returns a true or false value depending on if all the action buttons that are contained
	in a pageable action bar are empty on the specified page.
]]
function GamepadActionBarMixin:IsBarEmptyOnPage(page)
	assert(self.supportsActionButtonPaging, "This function should not be used on gamepad action bars that don't support action button paging.");

	--[[
		At the time of writing pageable action bars only exist on standard pages
		so early out here in order to avoid a nil storage index below.
	]]
	if (not GamepadActionBarBindingUtil.IsStandardGamepadPageNum(page)) then
		return true;
	end

	for _, actionButton in ipairs(self.actionButtons) do
		local pageUnitSlotID = actionButton:GetGamepadPageUnitSlotID();
		assert(pageUnitSlotID);

		if not GamepadActionBarBindingUtil.IsBindablePageUnitSlotID(pageUnitSlotID) then
			return false; -- Hardcoded actions make the bar non-empty, even if in storage they are empty.
		end

		-- Get the storage index for this button on the specified page
		local actionButtonOnPageStorageIndex = GamepadActionBarBindingUtil.GetGamepadStorageSlotIndexFromPageAndPageUnitSlotID(page, pageUnitSlotID);
		local actionType = GetActionInfo(actionButtonOnPageStorageIndex);
		if (actionType) then
			return false;
		end
	end

	return true;
end

function GamepadActionBarMixin:UpdateDisplayedActionsToPageUnitCurrentPage()
	if (self.supportsActionButtonPaging) then
		local currentPage = self.pagingUnitOwner:GetCurrentPage();
		for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR do
			local actionButton = self.actionButtons[i];
			actionButton:UpdatePageableGamepadButtonAction(currentPage);
		end
	end
end

function GamepadActionBarMixin:UpdateActionButtonsStateAndFlash()
	for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP do
		local actionButton = "ActionButton" .. i;
		self.Left[actionButton]:UpdateFlash();
		self.Left[actionButton]:UpdateState();
		self.Right[actionButton]:UpdateFlash();
		self.Right[actionButton]:UpdateState();
	end
end

function GamepadActionBarMixin:RefreshSpellHighlights()
	for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP do
		local actionButton = "ActionButton" .. i;
		SharedActionButton_RefreshSpellHighlight(self.Left[actionButton], false);
		SharedActionButton_RefreshSpellHighlight(self.Right[actionButton], false);
	end
end

function GamepadActionBarMixin:SetPagingUnitOwner(pageUnit)
	self.pagingUnitOwner = pageUnit;
	self:ReinitializeSequences();
end

function GamepadActionBarMixin:SetActionButtonsSaturation(saturateValue)
	for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP do
		local actionButton = "ActionButton" .. i;
		self.Left[actionButton]:DesaturateHierarchy(saturateValue);
		self.Right[actionButton]:DesaturateHierarchy(saturateValue);
	end
end

-- actionButtonName: ex: ActionButton1", "ActionButton2", ..., "ActionButton8"
function GamepadActionBarMixin:GetActionButtonUsingButtonName(actionButtonName)
	local actionButtonIndex = tonumber(string.sub(actionButtonName, -1));
	if (actionButtonIndex) then
		if (actionButtonIndex <= Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP) then
			return self.Left["ActionButton" .. actionButtonIndex];
		else
			actionButtonIndex = actionButtonIndex - Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP;
			return self.Right["ActionButton" .. actionButtonIndex];
		end
	end
end

function GamepadActionBarMixin:GetActionButtonByIndex(inIndex)
	return self.actionButtons[inIndex];
end

--[[
	Applys non-templated key value overrides for the action bar.

	KeyValues
	---------
	crossbarBackgroundAtlas = The atlas that should be used for the bar's crossbar frames.
	identifierIconAtlas = The atlas that should be used for the bar's identifier icon.
]]
function GamepadActionBarMixin:ApplyKeyValueCustomizations()
	if (self.crossbarBackgroundAtlas) then
		self.LeftButtonFrame:SetAtlas(self.crossbarBackgroundAtlas);
		self.RightButtonFrame:SetAtlas(self.crossbarBackgroundAtlas);
	end

	if (self.identifierIconAtlas) then
		self.IdentifierIcon:SetAtlas(self.identifierIconAtlas);
	end
end

--[[
	Marks the action bar as pageable which means that its action buttons
	can have their actions changed based on the current page the action bar's
	page unit parent is on.

	Action bars whose bound actions should remain the same regardless of
	which page the page unit parent is on should NOT use this function.
]]
function GamepadActionBarMixin:MarkBarAsPageable()
	self.supportsActionButtonPaging = true;
end

function GamepadActionBarMixin:DebugPrintActionBarButtonInfoForPage(pageNum)
	assert(self.supportsActionButtonPaging, "This function should not be used on gamepad action bars that don't support action button paging.");

	if (self.DisplayName) then
		print(self.DisplayName .. ":");
	end

	for _, actionButton in ipairs(self.actionButtons) do
		local pageUnitSlotID = actionButton:GetGamepadPageUnitSlotID();
		assert(pageUnitSlotID);

		-- Get the storage index for this button on the specified page
		local debugLine = "PageUnitSlotID = " .. pageUnitSlotID .. ", ";

		if not GamepadActionBarBindingUtil.IsBindablePageUnitSlotID(pageUnitSlotID) then
			debugLine = debugLine .. "Hardcoded Action";
		else
			local actionButtonOnPageStorageIndex = GamepadActionBarBindingUtil.GetGamepadStorageSlotIndexFromPageAndPageUnitSlotID(pageNum, pageUnitSlotID);
			debugLine = debugLine .. "StorageID = " .. actionButtonOnPageStorageIndex .. ", ";
			local actionType, actionID, subactionType = GetActionInfo(actionButtonOnPageStorageIndex);
			if (actionType) then
				local actionIDPrint = actionID and tostring(actionID) or "nil";
				local subactionPrint = subactionType and tostring(subactionType) or "nil";
				debugLine = debugLine .. tostring(actionType) .. ", " .. actionIDPrint .. ", " .. subactionPrint;
			else
				debugLine = debugLine .. "Empty";
			end
		end
		print(debugLine);
	end
	print("\n");
end

function GamepadActionBarMixin:UpdateButtonsEmptySlotBackgroundTexture()
	for _, actionButton in ipairs(self.actionButtons) do
		actionButton:UpdateEmptySlotBackgroundTexture();
	end
end

function GamepadActionBarMixin:DisableActionButtonGameplayFeedback()
	for _, actionButton in ipairs(self.actionButtons) do
		actionButton:DisableGameplayFeedback();
	end
end

function GamepadActionBarMixin:SetShowCheckedStateOnExpand(value)
	self.showCheckedStateOnOnExpand = value;
end

function GamepadActionBarMixin:SetExpandSequence(sequence)
	local wasPlaying = self.expandSequence and self.expandSequence:IsPlaying();
	if wasPlaying then
		self.expandSequence:Stop();
	end
	self.expandSequence = sequence;
	if wasPlaying then
		self.expandSequence:Start();
	end
end

function GamepadActionBarMixin:SetCollapseSequence(sequence)
	local wasPlaying = self.collapseSequence and self.collapseSequence:IsPlaying();
	if wasPlaying then
		self.collapseSequence:Stop();
	end
	self.collapseSequence = sequence;
	if wasPlaying then
		self.collapseSequence:Start();
	end
end

function GamepadActionBarMixin:ReinitializeSequences()
	if self.collapseSequence then
		self.collapseSequence:Reinitialize();
	end

	if self.expandSequence then
		self.expandSequence:Reinitialize();
	end
end

-- Helper: Returns if there are permabound slots, left or right side.
function GamepadActionBarMixin:GetPermaboundState()
	local leftFullyPermabound = true;
	local rightFullyPermabound = true;
	for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP do
		local actionButton = "ActionButton" .. i;

		local leftButton = self.Left[actionButton];
		leftFullyPermabound = leftFullyPermabound
			and leftButton.PermaboundOverlay
			and leftButton.PermaboundOverlay:IsShown();

		local rightButton = self.Right[actionButton];
		rightFullyPermabound = rightFullyPermabound
			and rightButton.PermaboundOverlay
			and rightButton.PermaboundOverlay:IsShown();

		if not leftFullyPermabound and not rightFullyPermabound then
			break;
		end
	end

	return leftFullyPermabound, rightFullyPermabound;
end
