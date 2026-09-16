local TargetActionBars_Shared = require(".TargetActionBars.Shared");

local STARTING_PAGE_ON_LOAD = 1;
local PAGE_TRACKER_BACKGROUND_WIDTH_PADDING = 5;
local PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING = 10;
local FLYOUT_INACTIVE_ALPHA = 0.35;
local ACTION_BAR_CONSTANTS = Constants.GamepadActionBarConstants;
local NUM_STANDARD_PAGE_IMAGES = 3;

local ACTIVE_ACTION_BAR_UPDATED_EVENT = "ACTIVE_ACTION_BAR_UPDATED_EVENT";
local PAGE_UNIT_CALLBACK_EVENTS =
{
	ACTIVE_ACTION_BAR_UPDATED_EVENT,
}

local PageSlotState = {
	Active = 1,
	Empty = 2,
	Disabled = 3,
}

GamepadActionBarPageTrackerSlotMixin = {}

function GamepadActionBarPageTrackerSlotMixin:Initialize(slotIdentifier)
	self.currentState = PageSlotState.Disabled;
end

function GamepadActionBarPageTrackerSlotMixin:SetPageSlotState(pageSlotState)
	local isValue = false;
	for _, state in pairs(PageSlotState) do
		if state == pageSlotState then
			isValue = true;
			break;
		end
	end
	assert(isValue, "Invalid PageSlotState provided: " .. pageSlotState);

	if self.currentState == pageSlotState then
		return;
	end
	self:TransitionPageSlotState(self.currentState, pageSlotState);
	self.currentState = pageSlotState;
end

function GamepadActionBarPageTrackerSlotMixin:TransitionPageSlotState(oldState, newState)
	assert(oldState ~= newState, "Cannot call transition without changing state.");
end

GamepadActionBarPageTrackerSlotImageMixin = CreateFromMixins(GamepadActionBarPageTrackerSlotMixin);

function GamepadActionBarPageTrackerSlotImageMixin:Initialize(slotIdentifier)
	GamepadActionBarPageTrackerSlotMixin.Initialize(self, slotIdentifier);

	self.DisabledTexture:SetAtlas("gamepad-actionbar-numericalpage-" .. slotIdentifier .. "-disabled");
	self.DisabledTexture:SetPoint("TOPLEFT", -PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING, PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING);
	self.DisabledTexture:SetPoint("BOTTOMRIGHT", PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING, -PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING);
	self.NormalTexture:SetAtlas("gamepad-actionbar-numericalpage-" .. slotIdentifier .. "-normal");
	self.NormalTexture:SetPoint("TOPLEFT", -PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING, PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING);
	self.NormalTexture:SetPoint("BOTTOMRIGHT", PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING, -PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING);
	self.SelectedTexture:SetAtlas("gamepad-actionbar-numericalpage-" .. slotIdentifier .. "-selected");
	self.SelectedTexture:SetPoint("TOPLEFT", -PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING, PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING);
	self.SelectedTexture:SetPoint("BOTTOMRIGHT", PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING, -PAGE_TRACKER_PAGEUNIT_IMAGE_PADDING);
	self.stateTextures = {
		[PageSlotState.Disabled] = self.DisabledTexture,
		[PageSlotState.Empty] = self.NormalTexture,
		[PageSlotState.Active] = self.SelectedTexture,
	};
	self:SetPageSlotState(PageSlotState.Disabled);
end

function GamepadActionBarPageTrackerSlotImageMixin:TransitionPageSlotState(oldState, newState)
	GamepadActionBarPageTrackerSlotMixin.TransitionPageSlotState(self, oldState, newState);
	self.stateTextures[oldState]:Hide();
	self.stateTextures[newState]:Show();
end

GamepadActionBarPageTrackerSlotTextMixin = CreateFromMixins(GamepadActionBarPageTrackerSlotMixin);
local TrackerSlotTextStateColors = {
	[PageSlotState.Disabled] = GRAY_FONT_COLOR,
	[PageSlotState.Empty] = WHITE_FONT_COLOR,
	[PageSlotState.Active] = NORMAL_FONT_COLOR,
};

function GamepadActionBarPageTrackerSlotTextMixin:Initialize(slotIdentifier)
	GamepadActionBarPageTrackerSlotMixin.Initialize(self, slotIdentifier);
	self:SetPoint("TOP", 0, -6);
	self.text:SetText(slotIdentifier);
	self:SetPageSlotState(PageSlotState.Disabled);
end

function GamepadActionBarPageTrackerSlotTextMixin:TransitionPageSlotState(oldState, newState)
	GamepadActionBarPageTrackerSlotMixin.TransitionPageSlotState(self, oldState, newState);

	local r, g, b = TrackerSlotTextStateColors[newState]:GetRGB();
	self.text:SetVertexColor(r, g, b, 1);

	if oldState == PageSlotState.Active then
		self.ActiveHighlight:Hide();
	end

	if newState == PageSlotState.Active then
		self.ActiveHighlight:Show();
	end
end

GamepadActionBarPageUnitMixin = CreateFromMixins(CallbackRegistryMixin);

local function SetupActionBarReferences(pageUnit)
	pageUnit.actionBars = {}; -- All available action bars in the page unit (both standard indexed bars and special bars).
	local actionBars = pageUnit.actionBars;
	actionBars.topBar = pageUnit.TopCenteredAnchor.Bar;
	actionBars.leftBar = pageUnit.LeftCenteredAnchor.Bar;
	actionBars.rightBar = pageUnit.RightCenteredAnchor.Bar;
	actionBars.bottomBar = pageUnit.BottomCenteredAnchor.Bar;
	actionBars.possessBar = pageUnit.TopCenteredAnchor.PossessBar;
	actionBars.stanceBar = pageUnit.TopCenteredAnchor.StanceBar;

	-- These bars are not available in the edit mode bar
	actionBars.friendlyTargetingBar = pageUnit.FriendlyTargetingActionBar;
	actionBars.hostileTargetingBar = pageUnit.HostileTargetingActionBar;
	actionBars.shortcutsBar = pageUnit.ShortcutsActionBar;

	pageUnit.LeftIcon:SetParent(actionBars.leftBar);
	pageUnit.RightIcon:SetParent(actionBars.rightBar);
	pageUnit.CenteredIcons:SetParent(actionBars.bottomBar);
	actionBars.leftBar.modifierIcon = pageUnit.LeftIcon;
	actionBars.rightBar.modifierIcon = pageUnit.RightIcon;
	actionBars.bottomBar.modifierIcon = pageUnit.CenteredIcons;

	for _, actionBar in pairs(actionBars) do
		actionBar:SetPagingUnitOwner(pageUnit);
	end

	pageUnit.overrideBars = { actionBars.possessBar, actionBars.stanceBar };

	if actionBars.friendlyTargetingBar then
		actionBars.friendlyTargetingBar:SetParent(pageUnit.TopCenteredAnchor);
		table.insert(pageUnit.overrideBars, actionBars.friendlyTargetingBar);
	end

	if actionBars.hostileTargetingBar then
		actionBars.hostileTargetingBar:SetParent(pageUnit.TopCenteredAnchor);
		table.insert(pageUnit.overrideBars, actionBars.hostileTargetingBar);
	end

	if actionBars.shortcutsBar then
		actionBars.shortcutsBar:SetParent(pageUnit.TopCenteredAnchor);
		table.insert(pageUnit.overrideBars, actionBars.shortcutsBar);
	end

	--[[
		Pageable action bars are action bars in which the action buttons display different actions depending on what page the page unit is currently on.
		Non-pageable action bars are action bars in which the action buttons contain the same action regardless of what page is active (PossessBar, StanceBar).
	]]
	pageUnit.pageableActionBarsIndexOrder = { actionBars.topBar, actionBars.leftBar, actionBars.rightBar, actionBars.bottomBar };
	for _, actionBar in ipairs(pageUnit.pageableActionBarsIndexOrder) do
		actionBar:MarkBarAsPageable();
	end
end

local function ChangePageButton_OnClick(self, button)
	local pageMod = 1;

	if (button == "RightButton") then
		pageMod = -1;
	end

	local pageTracker = self:GetParent();
	local pagingUnit = pageTracker:GetParent();

	local currentPageToMoveFrom = pageTracker.currentPage;
	if (pageTracker.tempCurrentPage) then
		currentPageToMoveFrom = pageTracker.tempCurrentPage;
		pageTracker.tempCurrentPage = nil;
	end

	local newPage = currentPageToMoveFrom + pageMod;
	local NUM_PAGES_PER_GAMEPAD_PAGE_UNIT = ACTION_BAR_CONSTANTS.NUM_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT;
	if newPage < 1 then
		newPage = NUM_PAGES_PER_GAMEPAD_PAGE_UNIT;
	elseif newPage > NUM_PAGES_PER_GAMEPAD_PAGE_UNIT then
		newPage = 1;
	end

	pagingUnit.changingPageClickedDirButton = button;
	pagingUnit:SetCurrentPage(newPage);
end

local function SetupPageTracker(pageUnit)
	local pageTracker = pageUnit.PageTracker;

	pageTracker.currentPage = STARTING_PAGE_ON_LOAD;
	pageTracker.pageChangeCallbacks = {};
	pageTracker.slots = {};

	-- Setup the slot templates.
	for i = 1, ACTION_BAR_CONSTANTS.NUM_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT do
		local isStandardPage = i <= ACTION_BAR_CONSTANTS.NUM_STANDARD_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT;
		local hasImageForPage = isStandardPage and i <= NUM_STANDARD_PAGE_IMAGES;
		local templateName = (hasImageForPage and "GamepadActionBarPageTrackerSlotImageFrame") or "GamepadActionBarPageTrackerSlotTextFrame";
		local slot = CreateFrame("Frame", nil, pageTracker, templateName);
		slot:SetPoint("LEFT", pageTracker, "LEFT", (i - 1) * slot:GetWidth() + PAGE_TRACKER_BACKGROUND_WIDTH_PADDING, 0);
		table.insert(pageTracker.slots, slot);
		slot.num = i;

		if isStandardPage then
			slot:SetParentKey("standardSlot" .. i);
			slot:Initialize(i);
		end
	end

	-- Assign info for the special slot.
	local specialPageSlot = pageTracker.slots[ACTION_BAR_CONSTANTS.GAMEPAD_ACTION_BAR_PAGE_UNIT_SPECIAL_PAGE_INDEX];
	specialPageSlot:SetParentKey("specialSlot");
	specialPageSlot:Initialize("S");
	local pageButton = CreateFrame("Button", nil, pageTracker);
	pageButton:SetParentKey("ChangePageButton");
	pageButton:SetScript("OnClick", ChangePageButton_OnClick);
end

function GamepadActionBarPageUnitMixin:InitializeTargetingBars()
	self.targetingBarsSharedState = CreateFromMixins(TargetActionBars_Shared.SharedBarStateMixin);
	self.targetingBarsSharedState:Init(self);
end

function GamepadActionBarPageUnitMixin:OnLoad()
	self:GenerateCallbackEvents(PAGE_UNIT_CALLBACK_EVENTS);
	CallbackRegistryMixin.OnLoad(self);

	SetupActionBarReferences(self);
	self:InitializePossessBar();
	self:InitializeStanceBar();
	self:InitializeTargetingBars();
	SetupPageTracker(self);

	CVarCallbackRegistry:SetCVarCachable("GamepadShowActionBarButtonPrompts");
	CVarCallbackRegistry:SetCVarCachable("GamepadShowActionBarHighlight");
	CVarCallbackRegistry:SetCVarCachable("GamepadShowActionBarScaling");
	CVarCallbackRegistry:SetCVarCachable("GamepadUseCompactActionBar");
	CVarCallbackRegistry:RegisterCallback("GamepadShowActionBarButtonPrompts", self.ActionBarModKeyDownStateCheck, self);
	CVarCallbackRegistry:RegisterCallback("GamepadShowActionBarHighlight", self.ActionBarModKeyDownStateCheck, self);
	CVarCallbackRegistry:RegisterCallback("GamepadShowActionBarScaling", self.ActionBarModKeyDownStateCheck, self);
	CVarCallbackRegistry:RegisterCallback("GamepadUseCompactActionBar", self.RefreshCompactLayout, self);
	InputDeviceIconSetManager:RegisterActiveInputDeviceIconSetUpdatedCallback(self.OnInputDeviceIconSetUpdated, self);

	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function GamepadActionBarPageUnitMixin:OnEvent(event, ...)
	if (event == "ACTIONBAR_SLOT_CHANGED") then
		self:RefreshActionBarVisibilities();
		self:ActionBarModKeyDownStateCheck();
	end
end

function GamepadActionBarPageUnitMixin:InitializeGamepad()
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");

	self:InitializeCompactLayout();
	self:ActionBarModKeyDownStateCheck();

	EventUtil.ContinueOnVariablesLoaded(GenerateClosure(self.PostVariableSetUp, self));
end

function GamepadActionBarPageUnitMixin:UninitializeGamepad()
	self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED");
end

function GamepadActionBarPageUnitMixin:ShouldUseCompactLayout()
	return self.useCompactLayout == nil
		and CVarCallbackRegistry:GetCVarValueBool("GamepadUseCompactActionBar")
		or self.useCompactLayout;
end

function GamepadActionBarPageUnitMixin:SetUseCompactLayout(value)
	-- NOTE:
	-- `RefreshCompactLayout` should be called sometime after you call `SetUseCompactLayout`.
	-- `RefreshCompactLayout` uses a character stored cvar and so must be called after cvars are loaded.
	-- Therefore it is up to the caller to ensure `RefreshCompactLayout` is called at an appropiate time.
	self.useCompactLayout = value;
end

function GamepadActionBarPageUnitMixin:InitializeCompactLayout()
	self.anchorPoints = {
		[self.TopCenteredAnchor] = {},
		[self.LeftCenteredAnchor] = {},
		[self.RightCenteredAnchor] = {},
	};

	for anchor, points in pairs(self.anchorPoints) do
		for i = 1, anchor:GetNumPoints() do
			local point, relativeTo, relativePoint, x, y = anchor:GetPoint(i);
			table.insert(points, {
				point = point,
				relativeTo = relativeTo,
				relativePoint = relativePoint,
				x = x,
				y = y,
			});
		end
	end
end

function GamepadActionBarPageUnitMixin:RefreshCompactLayout()
	local useCompactLayout = self:ShouldUseCompactLayout();

	local anchors = {
		self.TopCenteredAnchor,
		self.LeftCenteredAnchor,
		self.RightCenteredAnchor,
	};

	if useCompactLayout then
		for _, anchor in ipairs(anchors) do
			anchor:SetAllPoints(self.BottomCenteredAnchor);
		end
	else
		for _, anchor in ipairs(anchors) do
			anchor:ClearAllPoints();
			for _, point in ipairs(self.anchorPoints[anchor]) do
				anchor:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y);
			end
		end
	end

	self:RefreshActionBarVisibilities();
end

--[[
	Returns the list of action bars that are marked as pageable for the page unit
	in the order they are stored internally.
]]
function GamepadActionBarPageUnitMixin:GetPageableActionBarsInIndexOrder()
	return self.pageableActionBarsIndexOrder;
end

function GamepadActionBarPageUnitMixin:RefreshPageTracker()
	local function IsPageEmpty(pageNumber)
		if (not GamepadActionBarBindingUtil.IsValidGamepadPageNumber(pageNumber)) then
			-- Page is empty because it doesn't exist.
			return true;
		end

		for _, pageableActionBar in ipairs(self.pageableActionBarsIndexOrder) do
			if not pageableActionBar:IsBarEmptyOnPage(pageNumber) then
				return false;
			end
		end

		return true;
	end

	-- Update the highlight on the page tracker to match the current page.
	for _, page in pairs(self.PageTracker.slots) do
		if (page.num == self.PageTracker.currentPage) then
			page:SetPageSlotState(PageSlotState.Active);
		elseif not IsPageEmpty(page.num) then
			page:SetPageSlotState(PageSlotState.Empty);
		else
			page:SetPageSlotState(PageSlotState.Disabled);
		end
	end
end

function GamepadActionBarPageUnitMixin:SetInitialPageDisplay()
	self:RefreshPageTracker();

	for _, actionBar in pairs(self.actionBars) do
		actionBar:CollapseActionButtons();
	end
end

function GamepadActionBarPageUnitMixin:ShowModifierIcons(show)
	for _, icon in pairs(self.ModifierIcons) do
		if show then
			icon:Show();
		else
			icon:Hide();
		end
	end
end

function GamepadActionBarPageUnitMixin:SetGamepadActionBarSlotIDs()
	for barIndex, actionBar in ipairs(self.pageableActionBarsIndexOrder) do
		local offset = (barIndex - 1) * ACTION_BAR_CONSTANTS.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR;
		for i = 1, ACTION_BAR_CONSTANTS.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR do
			local actionButton = actionBar:GetActionButtonByIndex(i);
			actionButton:SetGamepadPageUnitSlotID(offset + i);
			actionButton:UpdatePageableGamepadButtonAction(STARTING_PAGE_ON_LOAD);
		end
	end
end

function GamepadActionBarPageUnitMixin:PostVariableSetUp()
	self:SetGamepadActionBarSlotIDs();
	self:RefreshCompactLayout();
	self:SetInitialPageDisplay();
	self:ActionBarModKeyDownStateCheck();
end

function GamepadActionBarPageUnitMixin:OnPageChange(oldPageNum)
	local currentPage = self:GetCurrentPage();

	--[[
		Update the displayed actions for standard pages.

		Implementation note:
		Because the possess bar is non-paged its displayed actions are updated from pet
		bar update events, so even though its update function is called in the function
		below we don't need to worry about the current page potentially not containing
		the possessBar.
	]]
	if (currentPage <= ACTION_BAR_CONSTANTS.NUM_STANDARD_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT) then
		for _, actionBar in pairs(self.actionBars) do
			actionBar:UpdateDisplayedActionsToPageUnitCurrentPage();
		end
	end

	-- Handle override bars
	for _, overrideBar in ipairs(self.overrideBars) do
		overrideBar:PageChangeHandler(oldPageNum);
	end

	-- Update action bar visibilities based on settings and page unit state.
	self:RefreshActionBarVisibilities();
	self:ActionBarModKeyDownStateCheck();

	for _, callback in ipairs(self.PageTracker.pageChangeCallbacks) do
		callback();
	end
end

function GamepadActionBarPageUnitMixin:SetCurrentPage(pageNum)
	if (not GamepadActionBarBindingUtil.IsValidGamepadPageNumber(pageNum) or pageNum == self.PageTracker.currentPage) then
		return;
	end

	-- Handle setting the current page to the special page, but the special page can't be selected.
	if (pageNum == ACTION_BAR_CONSTANTS.GAMEPAD_ACTION_BAR_PAGE_UNIT_SPECIAL_PAGE_INDEX) then
		if (not self:IsSpecialPageAvailableForSelection()) then
			self.PageTracker.tempCurrentPage = pageNum;
			if (not self.changingPageClickedDirButton) then
				self.changingPageClickedDirButton = "LeftButton";
			end

			ChangePageButton_OnClick(self.PageTracker.ChangePageButton, self.changingPageClickedDirButton);
			self.changingPageClickedDirButton = nil;
			return;
		end
	end

	local oldPageNum = self.PageTracker.currentPage;
	self.PageTracker.currentPage = pageNum;
	self:OnPageChange(oldPageNum);

	for _, actionBar in pairs(self.actionBars) do
		actionBar:UpdateActionButtonsStateAndFlash();
	end

	self:RefreshPageTracker();
end

function GamepadActionBarPageUnitMixin:AddPageChangeCallback(callback)
	table.insert(self.PageTracker.pageChangeCallbacks, callback);
end

function GamepadActionBarPageUnitMixin:GetCurrentPage()
	return self.PageTracker.currentPage;
end

function GamepadActionBarPageUnitMixin:ShowActionBarPageTracker(show)
	self.PageTracker:SetShown(show);

	-- Show or hide the special page slot depending on if it can be navigated to.
	self:RefreshPageTrackerSpecialPageSlotVisibility();
end

function GamepadActionBarPageUnitMixin:ClickChangePageButton(button, down)
	self.PageTracker.ChangePageButton:Click(button, down);
end

function GamepadActionBarPageUnitMixin:ClearSpellMappingHighlights()
	-- Clear the global list of abilities to highlight
	ClearOnBarHighlightMarks();

	-- Manually trigger updates to fix the highlight state immediately
	for _, actionBar in pairs(self.actionBars) do
		actionBar:RefreshSpellHighlights();
	end
end

function GamepadActionBarPageUnitMixin:SetAllPageUnitActionButtonsSaturation(saturateValue)
	for _, actionBar in pairs(self.actionBars) do
		actionBar:SetActionButtonsSaturation(saturateValue);
	end
end

--[[
	Takes an action bar slot and gives back the action button frame for this page unit

	slotID: Number index of the desired controller action button

	returns: Actionbutton frame that has that slot ID, will return nil if id is invalid
]]
function GamepadActionBarPageUnitMixin:GetControllerActionButtonFromSlot(slotID)
	local actionBars = self:GetPageableActionBarsInIndexOrder();
	local NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP = ACTION_BAR_CONSTANTS.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP;
	local quadIndex = slotID % NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP;
	if (quadIndex == 0) then
		quadIndex = NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP;
	end

	-- Figure out which action bar it is
	local bar = math.floor((slotID - 1) / ACTION_BAR_CONSTANTS.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR) + 1;

	-- Find what ActionButton it is
	local isDPAD = false;
	local barIndex = slotID % ACTION_BAR_CONSTANTS.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR;
	if (barIndex == 0) then
		barIndex = ACTION_BAR_CONSTANTS.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR;
	end

	if (barIndex <= NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP) then
		isDPAD = true;
	end

	-- Set side based on DPAD
	local side = nil;
	if (isDPAD) then
		side = "Left";
	else
		side = "Right";
	end

	if (actionBars[bar]) then
		return actionBars[bar][side]["ActionButton" .. quadIndex];
	end
end

function GamepadActionBarPageUnitMixin:SetActiveActionBar(barToActivate, leftModifierDown, rightModifierDown)
	self.activeBar = barToActivate;

	for _, actionBar in pairs(self.actionBars) do
		if actionBar == barToActivate then
			actionBar:ShowHighlight();
		else
			actionBar:HideHighlight();
		end
	end

	if self.activeFlyoutButton then
		self.activeFlyoutButton:ClosePopup();
	end

	self:RefreshActionBarVisibilities();
	self:TriggerEvent(ACTIVE_ACTION_BAR_UPDATED_EVENT);
end

function GamepadActionBarPageUnitMixin:GetActiveBar()
	return self.activeBar;
end

function GamepadActionBarPageUnitMixin:ActionBarModKeyDownStateCheck()
	local leftModifierDown = GamepadMode.IsLeftModifierDown();
	local rightModifierDown = GamepadMode.IsRightModifierDown();

	local actionBars = self.actionBars;
	local actionBarToActivate = nil;

	local function AttemptSetActionBarToActivate(pageUnit, actionBar)
		actionBarToActivate = actionBar;

		for _, overrideBar in ipairs(pageUnit.overrideBars) do
			if (overrideBar:IsBarActivelyOverridingActionBar(actionBar)) then
				actionBarToActivate = overrideBar;
				return;
			end
		end
	end

	-- Attempt to focus an action bar associated with the right modifier.
	if (rightModifierDown) then
		AttemptSetActionBarToActivate(self, actionBars.rightBar);
	end

	--[[
		Attempt to focus an action bar associated with the left modifier. This
		will take priority over the right modifier bar if one is focused.
	]]
	if (leftModifierDown) then
		AttemptSetActionBarToActivate(self, actionBars.leftBar);
	end

	--[[
		Handle the case when both the left and right were held. If there is an
		action bar that is specified to be activated it may be overriden if
		the left and right modifiers can focus a bar instead.
	]]
	if (leftModifierDown and rightModifierDown) then
		AttemptSetActionBarToActivate(self, actionBars.bottomBar);
	end

	-- If no modifier specific action bars were focused then default to the top bar.
	if (not actionBarToActivate) then
		local barToFocus = actionBars.topBar;
		if (self:GetCurrentPage() == ACTION_BAR_CONSTANTS.GAMEPAD_ACTION_BAR_PAGE_UNIT_SPECIAL_PAGE_INDEX) then
			-- Handle the special case where the possess bar is the top bar on the special page
			barToFocus = actionBars.possessBar;
		end
		AttemptSetActionBarToActivate(self, barToFocus);
	end

	if (actionBarToActivate) then
		self:SetActiveActionBar(actionBarToActivate, leftModifierDown, rightModifierDown);
	end
end

function GamepadActionBarPageUnitMixin:OnSelectedActionBarModifierStateChange()
	self:ActionBarModKeyDownStateCheck();
end

function GamepadActionBarPageUnitMixin:StartListeningForModifierUpdates()
	GamepadMode.RegisterCrossBarModifierStateChanged(self.OnSelectedActionBarModifierStateChange, self);

	-- Check for LB press to open up page tracker
	GamepadMode.RegisterInputModifierStateChangeCallback(self.ShowActionBarPageTracker, self);
end

function GamepadActionBarPageUnitMixin:StopListeningForModifierUpdates()
	GamepadMode.UnregisterCrossBarModifierStateChanged(self);
	GamepadMode.UnregisterInputModifierStateChangeCallback(self);
end

function GamepadActionBarPageUnitMixin:GetTopAnchorFrame()
	return self.TopCenteredAnchor;
end

function GamepadActionBarPageUnitMixin:GetLeftAnchorFrame()
	return self.LeftCenteredAnchor;
end

function GamepadActionBarPageUnitMixin:GetRightAnchorFrame()
	return self.RightCenteredAnchor;
end

function GamepadActionBarPageUnitMixin:GetBottomAnchorFrame()
	return self.BottomCenteredAnchor;
end

function GamepadActionBarPageUnitMixin:IsSpecialPageAvailableForSelection()
	return self:IsPossessBarActiveAndOnSpecialPage();
end

function GamepadActionBarPageUnitMixin:RefreshPageTrackerSpecialPageSlotVisibility()
	if (self.PageTracker.specialSlot) then
		self.PageTracker.specialSlot:SetShown(self:IsSpecialPageAvailableForSelection());
		self:ReevaluatePageTrackerWidth();
	end
end

-- Handle the case where the player is on the special page and the special page becomes unselectable.
function GamepadActionBarPageUnitMixin:HandleSpecialPageActiveStateChange()
	local currentPage = self:GetCurrentPage();

	if (currentPage == ACTION_BAR_CONSTANTS.GAMEPAD_ACTION_BAR_PAGE_UNIT_SPECIAL_PAGE_INDEX and not self:IsSpecialPageAvailableForSelection()) then
		self:SetCurrentPage(1);
	end
end

--[[
	Goes through each of the 4 standard action bars and checks settings to see if the action bar should be hidden or shown.
]]
function GamepadActionBarPageUnitMixin:RefreshActionBarVisibilities()
	if self:ShouldUseCompactLayout() then
		for _, actionBar in pairs(self.actionBars) do
			actionBar:SetShown(actionBar == self.activeBar);
		end
	else
		for _, actionBar in pairs(self.actionBars) do
			actionBar:RefreshActionBarVisibility();
		end
	end
end

function GamepadActionBarPageUnitMixin:ReevaluatePageTrackerWidth()
	local slotWidth = 2 * PAGE_TRACKER_BACKGROUND_WIDTH_PADDING;
	for i = 1, ACTION_BAR_CONSTANTS.NUM_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT do
		local slot = self.PageTracker.slots[i];
		if (slot:IsShown()) then
			slotWidth = slotWidth + slot:GetWidth();
		end
	end
	self.PageTracker:SetWidth(slotWidth);
end

function GamepadActionBarPageUnitMixin:DebugPrintPageableActionBarsForPage(pageNum)
	if (not GamepadActionBarBindingUtil.IsValidGamepadPageNumber(pageNum) or pageNum > ACTION_BAR_CONSTANTS.NUM_STANDARD_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT) then
		return;
	end

	for _, pageableActionBar in ipairs(self.pageableActionBarsIndexOrder) do
		pageableActionBar:DebugPrintActionBarButtonInfoForPage(pageNum);
	end
end

function GamepadActionBarPageUnitMixin:IsAnyOverrideBarOverridingActionBar(actionBar)
	for _, overrideBar in ipairs(self.overrideBars) do
		if (overrideBar:IsBarActivelyOverridingActionBar(actionBar)) then
			return true;
		end
	end

	return false;
end

function GamepadActionBarPageUnitMixin:OnInputDeviceIconSetUpdated()
	for _, actionBar in pairs(self.actionBars) do
		actionBar:UpdateButtonsEmptySlotBackgroundTexture();
	end
end

function GamepadActionBarPageUnitMixin:RegisterActiveActionBarUpdatedCallback(callback, owner)
	self:RegisterCallback(ACTIVE_ACTION_BAR_UPDATED_EVENT, callback, owner);
end

function GamepadActionBarPageUnitMixin:SetPageTrackerPagingPromptVisibility(show)
	self.PageTracker.SwitchPagePrompt:SetShown(show);
end

function GamepadActionBarPageUnitMixin:DisableActionButtonGameplayFeedback()
	for _, actionBar in pairs(self.actionBars) do
		actionBar:DisableActionButtonGameplayFeedback();
	end
end

function GamepadActionBarPageUnitMixin:OnFlyoutOpened(button)
	-- Everything should be transparent _except_ the flyout, and its button
	if self.activeFlyoutButton then
		self:OnFlyoutClosed();
	end

	self.activeFlyoutButton = button;
	button.popup:SetIgnoreParentAlpha(true);
	self:SetAlpha(FLYOUT_INACTIVE_ALPHA);
end

function GamepadActionBarPageUnitMixin:OnFlyoutClosed()
	if self.activeFlyoutButton then
		self.activeFlyoutButton.popup:SetIgnoreParentAlpha(false);
		self.activeFlyoutButton = nil;
	end

	self:SetAlpha(1);
end
