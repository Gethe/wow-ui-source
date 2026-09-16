--[[
	Handles transferring controls when multiple windows are active.

	A frame can subscribe to this by either being a part of ShowUIPanel or
	by manually calling FrameShown on their OnShow event.

	The "FocusGamepad" and "UnfocusGamepad" are called on frames registered to this function.
	Each frame is responsible for handling it's own activation and deactivation.
]]

GamepadFrameControlsManagerMixin = {};

-- Turns on Smart Navigation unless the frame has some custom navigation it uses.
local function EnableNavigation(inFrame)
	if inFrame.useCustomNavigation then
		SmartNavigation:Hide();
	else
		SmartNavigation:ActivateBinding();
		SmartNavigation:HandlePanelOpen(inFrame);
	end
end

local function DisableNavigation()
	SmartNavigation:Hide();
end

-----------------------------------------------------------------------------------
-- Vars
-----------------------------------------------------------------------------------

-- Holds frame, point, and text to set the next and prev buttons on individual frames
local nextPrevButtonReg = {
}

-----------------------------------------------------------------------------------
-- Private Methods
-----------------------------------------------------------------------------------
local function UnfocusFocusedFrame(self)
	if not self.focusedFrame then
		return;
	end

	local frameToUnfocus = self.focusedFrame;

	if (frameToUnfocus.UnfocusGamepad) then
		frameToUnfocus:UnfocusGamepad();
	end
	if (frameToUnfocus.EndFocus) then
		frameToUnfocus:EndFocus();
	end

	--[[
		Unfocusing a frame may cause another frame to become
		focused depending on what occurs in the frame's unfocus call, so
		we can't clear the focused frame all the time.

		However, if the frameToUnfocus remains the active frame after its
		UnfocusGamepad function call, then no other frame should be focused and the
		focused frame reference can be cleared.
	]]
	if (self.focusedFrame == frameToUnfocus) then
		self.focusedFrame = nil;
	end
end

--[[
	Sets the frame at the given index as focused.

	index: Index of the frame to focus

	return: True if successful, false otherwise
]]
local function FocusFrame(self, index)
	local frame = self.shownFrames[index];
	if (not frame) then
		return false;
	end

	if self.focusedFrame == frame then
		return true;
	end

	if (not frame.skipFrameDeactivation) then
		UnfocusFocusedFrame(self);
	end

	if (not InGlue()) then
		if GamepadMode.ResetModifiers then
			GamepadMode.ResetModifiers();
		end
	end

	-- Enable navigation before updating focus to ensure panel info is created.
	self.focusedFrame = frame;
	EnableNavigation(frame);

	if (frame.FocusGamepad) then
		frame:FocusGamepad();
	end
	if (self.focusedFrame.StartFocus) then
		self.focusedFrame:StartFocus();
	end

	self:RefreshFocus();

	return true;
end

local function CheckForInputBinding(self)
	if (#self.shownFrames > 0 and self.focusedFrame and (not self.focusedFrame.disableFrameFocusPagingWhenFocused)) then
		GamepadMode.ActivateBindingGroup(self.gamepadBindings);
	else
		GamepadMode.DeactivateBindingGroup(self.gamepadBindings);
	end
end

local function FrameLessThanCmp(a, b)
	local aX, aY = GetScaledCenter(a);
	local bX, bY = GetScaledCenter(b);

	-- Compare vertically for stacked frames (Bags)
	if (aX == bX) then
		return aY > bY;
	end

	return aX < bX;
end

local function ArrayIndexOf(tbl, obj)
	for k, v in ipairs(tbl) do
		if v == obj then
			return k;
		end
	end

	return 0;
end

-----------------------------------------------------------------------------------
-- Public Methods
-----------------------------------------------------------------------------------

function GamepadFrameControlsManagerMixin:ResetVars()
	self.shownFrames = {};

	self.focusedFrame = nil;
	self.prevFrame = nil;
	self.nextFrame = nil;
	self.topSuspendedFrame = nil;

	self.isPopupFrame = {};

	self.isUIFocused = false;
end

--[[
	This is eventually getting moved over to left stick.
	Making it an externally callback function for now until
	that change is good to go game-wide.
]]
function GamepadFrameControlsManagerMixin:ToggleTooltips()
	if GetCVarBool("GamepadDisableTooltips") then
		SetCVar("GamepadDisableTooltips", false);
		local button = SmartNavigation:GetCurrentButton()
		if button then
			SmartNavigation:SelectButton(nil);
			SmartNavigation:SelectButton(button);
		end
	else
		SetCVar("GamepadDisableTooltips", true);
		GameTooltip:Hide();
	end
end

function GamepadFrameControlsManagerMixin:Init()
	GamepadPopupHandler:Init();

	self:ResetVars();

	local function FocusNextFrameHandler()
		self:FocusNextFrame();
		CheckForInputBinding(self);
	end

	local function FocusPreviousFrameHandler()
		self:FocusPreviousFrame();
		CheckForInputBinding(self);
	end

	self.gamepadBindings = GamepadMode.CreateBindingGroup("FrameControlsManagerBindings");
	if (not InGlue()) then
		self.gamepadBindings:AddFunctionBinding(GAMEPAD_TRIGGER_RIGHT, FocusNextFrameHandler);
		self.gamepadBindings:AddFunctionBinding(GAMEPAD_TRIGGER_LEFT,  FocusPreviousFrameHandler);
		self.gamepadBindings:AddFunctionBinding(GAMEPAD_STICK_RIGHT_PRESS, GenerateClosure(self.ToggleTooltips, self));
	end

	self.gamepadFallthroughCatcherBindings = GamepadMode.CreateBindingGroup("FrameControlsManagerFallthroughCatcherBindings");
	self.gamepadFallthroughCatcherBindings:BlockDpadAndFaceButtons();

	-- Capture UI panel show and hide events so the frame controls manager automatically works with most frames.
	if (not InGlue()) then
		EventRegistry:RegisterCallback("UIParentPanelManager.ShowUIPanel", function(_, frame)
			if (not frame) then
				return;
			end

			self:FrameShown(frame);
		end, self);

		--[[
			Hide events for UIPanels come from two mechanisms:
			1. Explicit hiding of a panel (the public HideUIPanel interface, callable anywhere)
			2. Implicit hiding of a panel (stomping on existing panels on-screen)
				* Note: Code paths for explicit hides can also call implicit hides, but those
				  will safely no-op if the panel is already hidden.
		]]
		local function HandlePanelFrameHidden(_, frame)
			if (not frame) then
				return;
			end

			self:FrameHidden(frame);
		end
		EventRegistry:RegisterCallback("UIParentPanelManager.HideUIPanel", HandlePanelFrameHidden, self);
		EventRegistry:RegisterCallback("UIParentPanelManager.ForcePanelHide", HandlePanelFrameHidden, self);

		EventRegistry:RegisterCallback("ContainerFrame.OpenBag", function(_)
			self:FrameShown(ContainerFrameCombinedBags);
		end, self)

		EventRegistry:RegisterCallback("ContainerFrame.CloseBag", function(_)
			self:FrameHidden(ContainerFrameCombinedBags);
		end, self)
	end

	--[[
		Ideally, menus would just be separate frames, which can claim focus away from the parent
		frames that spawn them. Then return focus to the parent frames when closed. Each frame
		would own its own bindings, its own focus treatment, etc.

		This class is the only systemic focus management we have. Context menus are managed by this
		system, but exempted from the L+R navigation of this class. That functionality is disabled
		while context menus are open, by "suspending" the focus frame at time of menu open.

		History lesson: prior implementation established a pattern where the menu would be opened,
		and then the parent would "suspend", freezing all navigation in time until the menu finished
		performing whatever action was in flight. Then the source frame is "unsuspended", never losing
		its focus appearance, but allowing the spawned menu to take over navigation. Current UX
		dictates that spawned menus claim focus, and also surface their own visual binding
		indicators, etc.

		Refactoring the focus management was deemed out of scope. As such, we utilize what we can of
		the old functionality. The old frame is still "suspended", but the new menu _does_ claim focus.
		We still disable L+R paging until the context menu is addressed.
	]]
	EventRegistry:RegisterCallback("MenuProxy.OnShow", function(_, menu)
		-- Setup menu popups to work with gamepad smartnav.
		if not InputUtil.IsGamepadUIEnabled() then
			return;
		end

		menu.SmartNavigationCloseHandler = function()
			menu:Close();
			return true;
		end

		self:SkipGamepadAutoFocus(menu);
		self:DismissOnUnfocus(menu);
		self:SuspendFrame();

		SmartNavigation:SuspendCursor(false);
		self:FrameShown(menu);
	end, self);

	--[[
		Needs to use close callback, and not the on-hide handler. On close, the
		menu may be cleaned up / re-used such that the on-hide property is cleared.
		The closed callback is executed synchronously.
	]]
	EventRegistry:RegisterCallback("MenuProxy.OnClose", function(_, menu)
		if not InputUtil.IsGamepadUIEnabled() then
			return;
		end

		self:FrameHidden(menu);

		-- Context menus should not retain navigation position data between uses.
		SmartNavigation:HandlePanelClose(menu);
	end, self);

	self:RegisterForTransitions();

	self:RefreshFocus();

	return self;
end

function GamepadFrameControlsManagerMixin:RegisterForTransitions()
	InputUtil.RegisterForHighPrioInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function GamepadFrameControlsManagerMixin:UninitializeGamepad()
	self:ResetVars();
end

--[[
	Focuses the frame to the left of the currently focused one

	return: True is successful, false otherwise
]]
function GamepadFrameControlsManagerMixin:FocusPreviousFrame()
	local index = ArrayIndexOf(self.shownFrames, self.focusedFrame);
	if (index <= 1) then
		return false;
	end

	self.focusedFrame.returnToPlayerControl = false;
	return FocusFrame(self, index - 1);
end

--[[
	Focuses the frame to the right of the currently focused one

	return: True is successful, false otherwise
]]
function GamepadFrameControlsManagerMixin:FocusNextFrame()
	local index = ArrayIndexOf(self.shownFrames, self.focusedFrame);
	if (index == 0) or (index == #self.shownFrames) then
		return false;
	end

	self.focusedFrame.returnToPlayerControl = false;
	return FocusFrame(self, index + 1);
end

--[[
	Focuses the passed frame if it is currently shown

	return: True is successful, false otherwise
]]
function GamepadFrameControlsManagerMixin:FocusFrame(frame)
	local index = ArrayIndexOf(self.shownFrames, frame);
	if (index == 0) then
		return false;
	end

	self.isUIFocused = true;
	return FocusFrame(self, index);
end

--[[
	Called when SmartNavigation is hidden. Confirms that there are no frames shown that should be focused.
]]
function GamepadFrameControlsManagerMixin:FocusFirstFrameShown()
	--[[
		Fixes an issue where a frame being focused which uses custom navigation results in the frame
		being unfocused from the logic below.

		This can occur in frames that act as popups or overlays opened from other frames. The root cause
		is that during the activation process if the new active frame uses custom navigation, smart navigation
		is hidden which in turn calls this function. Without this condition the FocusFrame call below would
		then deactivate the recently updated active frame which would result in the the wrong frame being active
		at the end of the process.
	]]
	if (self.focusedFrame and self.focusedFrame.useCustomNavigation) then
		return;
	end

	if (#self.shownFrames >= 1 and self.isUIFocused) then
		FocusFrame(self, 1);
	end
end

--[[
	Called when a frame is opened, sorts it into shownFrames

	frame: Frame that was shown

	isPopup: If frame is a popup

	shouldFocusFrame: true if the frame should be focused, false otherwise
					  can be a function that must return true or false and is called
					  before `FocusFrame` after `frame` has been added to `shownFrames`

	return: True is successful false otherwise
]]
function GamepadFrameControlsManagerMixin:FrameShown(frame, isPopup, shouldFocusFrame)
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	if shouldFocusFrame == nil then
		shouldFocusFrame = true;
	end

	if (not InGlue()) then
		if RaidTargetingFreeSelection then
			RaidTargetingFreeSelection:SetActive(false); -- Remove Raid targeting state.
		end
	end

	if (not frame) then
		return false;
	end

	assert(type(frame) == "table", "Param frame is of wrong type");

	if (ArrayIndexOf(self.shownFrames, frame) > 0) then
		return false;
	end

	table.insert(self.shownFrames, frame)
	table.sort(self.shownFrames, FrameLessThanCmp)

	if isPopup then
		self.isPopupFrame[frame] = true
	end

	if not self.isUIFocused then
		-- Popups that were not the result of player-triggered actions should be tagged to not focus automatically.
		if isPopup then
			self.isUIFocused = not frame.skipGamepadAutoFocus;
		else
			self.isUIFocused = true;
		end
	end

	if self.isUIFocused then
		local shouldActivateFrame = shouldFocusFrame;
		if type(shouldActivateFrame) == "function" then
			shouldActivateFrame = shouldActivateFrame();
		end

		if isPopup then
			shouldActivateFrame = not frame.skipGamepadAutoFocus;

			-- Sub-menus should not persist when unfocused, so close them before swapping focus to the popup.
			if shouldActivateFrame then
				self:UnsuspendAllFrames();
			end
		end

		if shouldActivateFrame then
			self:SetFallThroughCatcherActive(true);

			FocusFrame(self, ArrayIndexOf(self.shownFrames, frame));
		end
		CheckForInputBinding(self);
	else
		-- If the UI is not focused and a popup is not set to autofocus, set it as the active frame so it is the first thing to be focused when the UI is refocused.
		if isPopup then
			self.focusedFrame = frame;
		end
	end

	if not self.focusedFrame then
		self.focusedFrame = frame;
	end

	self:RefreshFocus();

	return true;
end

--[[
	Called when a frame is closed, takes it out of shownFrames.

	frame: Frame that was closed

	return: True is successful false otherwise
]]
function GamepadFrameControlsManagerMixin:FrameHidden(frame)
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	if (not frame) then
		return false;
	end

	assert(type(frame) == "table", "Param frame is of wrong type");

	local index = ArrayIndexOf(self.shownFrames, frame);
	if (index == 0) then
		return false;
	end

	table.remove(self.shownFrames, index)

	if self.isPopupFrame[frame] then
		self.isPopupFrame[frame] = nil;
	end

	-- Check if this frame was the active one, if so, transfer ownership
	if (self.focusedFrame == frame) then
		local foundNewFrameInGroup = false;
		-- If there is a group associated with this frame, check to make sure there are not others.
		if (frame.FrameControlManagerGroup and #self.shownFrames >= 1) then
			for shownFrameIndex, shownFrame in ipairs(self.shownFrames) do
				if (shownFrame ~= nil and frame.FrameControlManagerGroup == shownFrame.FrameControlManagerGroup) then
					FocusFrame(self, shownFrameIndex);
					foundNewFrameInGroup = true;
					break;
				end
			end
		end
		-- assuming a new frame in the group was not found, handle hiding as usual
		if (not foundNewFrameInGroup) then
			if (frame.returnToPlayerControl and self.isUIFocused) then
				-- If the frame should return to player control, do so
				UnfocusFocusedFrame(self);
				if (#self.shownFrames >= 1) then
					self.focusedFrame = self.shownFrames[1];
				end
				self:SetUIFocusState(false);
			elseif (#self.shownFrames >= 1) then
				-- If there are more frames, focus one
				if self.isUIFocused then
					FocusFrame(self, 1);
				else
					self.focusedFrame = self.shownFrames[1];
				end
			else
				UnfocusFocusedFrame(self);
			end
		end
	end

	if (#self.shownFrames <= 0) then
		self:SetFallThroughCatcherActive(false);
		DisableNavigation();

		self.isUIFocused = false;
	end

	CheckForInputBinding(self);

	self:RefreshFocus();

	if (not InGlue()) and (#self.shownFrames == 0) and SpellCanTargetItem() then
		SpellStopTargeting();
	end

	return true;
end

function GamepadFrameControlsManagerMixin:HandlePopupShown(popupFrame)
	self:FrameShown(popupFrame, true);

	if self.isUIFocused then
		CheckForInputBinding(self);
	end
end

function GamepadFrameControlsManagerMixin:HandlePopupHide(popupFrame)
	self:FrameHidden(popupFrame);
end

--[[
	Returns the amount of focusable frames

	return: Amount of focusable frames
]]
function GamepadFrameControlsManagerMixin:GetShownFrameCount()
	return #self.shownFrames;
end

--[[
	Hides all active Frames
]]
function GamepadFrameControlsManagerMixin:HideActiveFrames()
	local i = 1
	while i <= #self.shownFrames do
		local frame = self.shownFrames[i];
		if self.isPopupFrame[frame] then
			-- Popup frames cannot be easily re-shown via user interaction unlike other frames
			-- so ensure we do not hide popup frames and remove tracking of popup frames
			i = i + 1
		else
			-- Hiding the frame removes it from shownFrames
			HideUIPanel(frame);
		end
	end
end

function GamepadFrameControlsManagerMixin:SetFallThroughCatcherActive(inActive)
	if (self.fallThroughCatcherActive ~= inActive) then
		if inActive then
			GamepadMode.ActivateBindingGroup(self.gamepadFallthroughCatcherBindings);
		else
			GamepadMode.DeactivateBindingGroup(self.gamepadFallthroughCatcherBindings);
		end
		self.fallThroughCatcherActive = inActive;
	end
end

function GamepadFrameControlsManagerMixin:SetUIFocusState(shouldFocusUI)
	if (shouldFocusUI) then
		if (not self.isUIFocused) then
			if (#self.shownFrames <= 0) then
				UIErrorsFrame:AddExternalErrorMessage(ERROR_NO_FRAME_TO_FOCUS);
				return;
			end

			GamepadRadial:Hide(); -- Hide the menu radial when toggling the UI and focusing a frame.

			self:SetFallThroughCatcherActive(true);

			self.isUIFocused = shouldFocusUI;

			if (#GamepadMode.PopupHandler.visiblePopups > 0) then
				self.focusedFrame = GamepadMode.PopupHandler.visiblePopups[1];
			end

			-- Enable navigation before updating focus to ensure panel info is created.
			local currentFocusedFrame = self.focusedFrame;
			EnableNavigation(currentFocusedFrame);

			if (currentFocusedFrame.FocusGamepad) then
				currentFocusedFrame:FocusGamepad();
			end
			if (currentFocusedFrame.StartFocus) then
				currentFocusedFrame:StartFocus();
			end

			CheckForInputBinding(self);
		end
	else
		if (self.isUIFocused) then
			-- Close any popup menus when toggling the UI.
			local currentActiveFrame = self.focusedFrame;
			if (currentActiveFrame and currentActiveFrame.dismissOnUnfocus) then
				if (currentActiveFrame.SmartNavigationCloseHandler) then
					currentActiveFrame:SmartNavigationCloseHandler();
				else
					HideUIPanel(currentActiveFrame);
				end

				if (GamepadMode.FrameControlsManager:IsFrameSuspended()) then
					GamepadMode.FrameControlsManager:UnsuspendFrame();
				end
			end

			self.isUIFocused = shouldFocusUI;
			GamepadMode.PopupHandler:UpdateVisiblePopups();

			currentActiveFrame = self.focusedFrame;
			if (currentActiveFrame and currentActiveFrame.UnfocusGamepad) then
				currentActiveFrame:UnfocusGamepad();
			end
			if (currentActiveFrame and currentActiveFrame.EndFocus) then
				currentActiveFrame:EndFocus();
			end

			GamepadMode.DeactivateBindingGroup(self.gamepadBindings);

			self:SetFallThroughCatcherActive(false);

			DisableNavigation();
		end
	end

	self:RefreshFocus();
end

function GamepadFrameControlsManagerMixin:ToggleUIFocus()
	local newFocusState = not self.isUIFocused;
	self:SetUIFocusState(newFocusState);
end

--[[
	Records the current frame that will be focused in the expected following UnsuspendFrame call.
	For instances where we open subsequent frame and expect to return to a specific position on closing that frame
]]
function GamepadFrameControlsManagerMixin:SuspendFrame()
	local currentFrame = self.focusedFrame;
	if currentFrame and currentFrame ~= self.topSuspendedFrame then
		currentFrame.suspendedButton = SmartNavigation:GetCurrentButton();
		currentFrame.unsuspendToFrame = self.topSuspendedFrame; -- Sets to nil for initial/bottom suspended frame.
		self.topSuspendedFrame = currentFrame;
		return true;
	end
	return false;
end

function GamepadFrameControlsManagerMixin:SuspendFrameWithFooter()
	--[[
		If the suspend did not succeed, do not proceed to attempt showing the footer;
		This can occur if the mouse was used to open a context menu directly, outside of the gamepad focus flow.
	]]
	if not self:SuspendFrame() then
		return;
	end

	-- The suspend footer should only be applied once when a root level frame is suspended, subsequent layers won't move it.
	if not GamepadSharedUtility.IsSuspendFooterShown() then
		GamepadSharedUtility.ShowSuspendFooterOnFrame(self.topSuspendedFrame);
	end
end

--[[
	Focuses the previously suspended frame if it is still open. Follows a call to SuspendFrame on closing the subsequent frame.
]]
function GamepadFrameControlsManagerMixin:UnsuspendFrame()
	local returnFrame = self.topSuspendedFrame;

	if not returnFrame then
		return;
	end

	local returnButton = returnFrame.suspendedButton;
	local nextReturnFrame = returnFrame.unsuspendToFrame;

	-- Only hide the footer if there is nothing else in the suspend chain.
	if GamepadSharedUtility.IsSuspendFooterShown() and (not nextReturnFrame) and (not GamepadSharedUtility.IsSuspendFooterLocked()) then
		GamepadSharedUtility.HideSuspendFooter();
	end

	if (returnFrame and returnFrame.LockInFocus) then
		returnFrame:LockInFocus(false);
	end

	local frameFocused = false;
	if (self.isUIFocused) then
		frameFocused = self:FocusFrame(returnFrame);
	end

	if (frameFocused) then
		SmartNavigation:SelectButton(returnButton);
	end

	-- If there is a suspended frame below the one we just unsuspended, cache that now; can be nil.
	self.topSuspendedFrame = nextReturnFrame;

	return frameFocused;
end

function GamepadFrameControlsManagerMixin:UnsuspendAllFrames()
	while self:IsFrameSuspended() do
		self:UnsuspendFrame();
	end
end

function GamepadFrameControlsManagerMixin:IsFrameSuspended()
	return (self.topSuspendedFrame ~= nil);
end

function GamepadFrameControlsManagerMixin:GetSuspendedFrame()
	return self.topSuspendedFrame;
end

function GamepadFrameControlsManagerMixin:IsSuspendedFrame(frame)
	return self.topSuspendedFrame == frame;
end

function GamepadFrameControlsManagerMixin:GetSuspendedButton()
	return self.topSuspendedFrame and self.topSuspendedFrame.suspendedButton;
end

function GamepadFrameControlsManagerMixin:GetActiveFrame()
	return self.focusedFrame;
end

--[[
	Add the frame to a frame group. This ensures that once a frame in a group is
	focused, the next shown frame in the group will be focused when the previous is closed.
]]
function GamepadFrameControlsManagerMixin:AddToFrameGroup(focusedFrame, key)
	focusedFrame.FrameControlManagerGroup = key;
end
function  GamepadFrameControlsManagerMixin:ClearFromAllFrameGroups(focusedFrame)
	focusedFrame.FrameControlManagerGroup = nil;
end

--[[
	Flags to set on frames for specific behaviors
]]
function GamepadFrameControlsManagerMixin:SkipFrameDeactivation(focusedFrame)
	focusedFrame.skipFrameDeactivation = true;
end
function GamepadFrameControlsManagerMixin:ReenableFrameDeactivation(focusedFrame)
	focusedFrame.skipFrameDeactivation = nil;
end
function GamepadFrameControlsManagerMixin:SkipGamepadAutoFocus(focusedFrame)
	focusedFrame.skipGamepadAutoFocus = true;
end
function GamepadFrameControlsManagerMixin:ReenableGamepadAutoFocus(focusedFrame)
	focusedFrame.skipGamepadAutoFocus = nil;
end
function GamepadFrameControlsManagerMixin:DisableFrameFocusPagingWhenFocused(focusedFrame)
	focusedFrame.disableFrameFocusPagingWhenFocused = true;
end
function GamepadFrameControlsManagerMixin:ReenableFrameFocusPagingWhenFocused(focusedFrame)
	focusedFrame.disableFrameFocusPagingWhenFocused = nil;
end
function GamepadFrameControlsManagerMixin:DismissOnUnfocus(focusedFrame)
	focusedFrame.dismissOnUnfocus = true;
end
function GamepadFrameControlsManagerMixin:DisableDismissOnUnfocus(focusedFrame)
	focusedFrame.dismissOnUnfocus = nil;
end
function GamepadFrameControlsManagerMixin:ReturnToPlayerControl(focusedFrame)
	focusedFrame.returnToPlayerControl = true;
end
function GamepadFrameControlsManagerMixin:DisableReturnToPlayerControl(focusedFrame)
	focusedFrame.returnToPlayerControl = nil;
end
function GamepadFrameControlsManagerMixin:UseCustomNavigation(focusedFrame)
	focusedFrame.useCustomNavigation = true;
end
function GamepadFrameControlsManagerMixin:DisableCustomNavigation(focusedFrame)
	focusedFrame.useCustomNavigation = nil;
end
function GamepadFrameControlsManagerMixin:ClearSmartNavReturnFrame(focusedFrame)
	focusedFrame.smartNavReturnFrame = nil;
end

function GamepadFrameControlsManagerMixin:ToggleFrameControls(enable)
	if (enable) then
		GamepadMode.ActivateBindingGroup(self.gamepadBindings);
	else
		GamepadMode.DeactivateBindingGroup(self.gamepadBindings);
	end
end

-- Prevent the gamepad cursor from triggering unit hover and tooltip events when we are interacting with a menu.
function GamepadFrameControlsManagerMixin:RefreshGamepadCursorHovering()
	local shouldUseCursorHovering = not self.isUIFocused;
	C_GamePad.SetAllowHoverEventsWithFreeLook(shouldUseCursorHovering);
end

local function ShowLeftJumpHint(frame, show)
	if show then
		if frame.ShowLeftJumpHint then
			frame:ShowLeftJumpHint();
		end
	else
		if frame.HideLeftJumpHint then
			frame:HideLeftJumpHint();
		end
	end
end

local function ShowRightJumpHint(frame, show)
	if show then
		if frame.ShowRightJumpHint then
			frame:ShowRightJumpHint();
		end
	else
		if frame.HideRightJumpHint then
			frame:HideRightJumpHint();
		end
	end
end

local function ShowFocusJumpHint(frame, show)
	if show then
		if frame.ShowFocusJumpHint then
			frame:ShowFocusJumpHint();
		end
	else
		if frame.HideFocusJumpHint then
			frame:HideFocusJumpHint();
		end
	end
end

--[[
	Returns the current focus target as deemed relevant for Jump hints.

	Private helper function not intended to be used by external sources.
	Jump hint logic considers additional potential "focus" targets when setting label visiblity.
	Specifically, it considers pop up targets as "focused", even if the UI isn't active.
]]
local function GetJumpHintFocusedFrame(manager)
	local focusedFrame = manager.focusedFrame;

	-- A popup will have refocus priority in SetUIFocusState, so treat it as our potential target if we are unfocused.
	if not manager.isUIFocused then
		if (#GamepadMode.PopupHandler.visiblePopups > 0) then
			focusedFrame = GamepadMode.PopupHandler.visiblePopups[1];
		end
	end

	return focusedFrame;
end

--[[
	Returns the label of the leftward Jump Hint.
	Private helper function not intended to be used by external sources.

	Returns nil if there is no JumpHint target.
]]
local function GetJumpHintLeftLabel(manager, frame)
	assert(frame, "Nil frame provided to GetJumpHintLeftLabel");
	local frameIndex = ArrayIndexOf(manager.shownFrames, frame);

	-- Footers are established when they are not tracked by FrameControlsManager
	if frameIndex == 0 then
		return nil;
	end

	local hasLeftFrame = frameIndex > 1;
	if not hasLeftFrame then
		return nil;
	end

	local prevIndex = frameIndex - 1;
	local prevFrame = manager.shownFrames[prevIndex];
	if prevFrame.GetJumpHintLabel then
		return prevFrame:GetJumpHintLabel();
	end

	return PREVIOUS;
end

--[[
	Returns the label of the rightward Jump Hint.
	Private helper function not intended to be used by external sources.

	Returns nil if there is no JumpHint target.
]]
local function GetJumpHintRightLabel(manager, frame)
	assert(frame, "Nil frame provided to GetJumpHintRightLabel");
	local frameIndex = ArrayIndexOf(manager.shownFrames, frame);

	-- Footers are established when they are not tracked by FrameControlsManager
	if frameIndex == 0 then
		return nil;
	end

	local hasRightFrame = frameIndex < #manager.shownFrames;
	if not hasRightFrame then
		return nil;
	end

	local nextIndex = frameIndex + 1;
	local nextFrame = manager.shownFrames[nextIndex];
	if nextFrame.GetJumpHintLabel then
		return nextFrame:GetJumpHintLabel();
	end

	return NEXT;
end

--[[
	Returns if the provided frame should display a jump hint directing leftward.
	Private helper function not intended to be used by external sources.
]]
local function HasJumpHintLeft(manager, frame)
	if frame.disableFrameFocusPagingWhenFocused then
		return false;
	end

	return GetJumpHintLeftLabel(manager, frame) ~= nil;
end

--[[
	Returns if the provided frame should display a jump hint directing rightward.
	Private helper function not intended to be used by external sources.
]]
local function HasJumpHintRight(manager, frame)
	if frame.disableFrameFocusPagingWhenFocused then
		return false;
	end

	return GetJumpHintRightLabel(manager, frame) ~= nil;
end

--[[
	Processes a prompted binding as the "Right" directional jump hint. Called from footers.
]]
function GamepadFrameControlsManagerMixin:RegisterJumpHintRightBinding(frame, promptedBinding)
	promptedBinding:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	promptedBinding:AddCondition(GenerateClosure(HasJumpHintRight, self, frame));
	promptedBinding:SetLabelFunction(GenerateClosure(GetJumpHintRightLabel, self, frame));
end

--[[
	Processes a prompted binding as the "Left" directional jump hint. Called from footers.
]]
function GamepadFrameControlsManagerMixin:RegisterJumpHintLeftBinding(frame, promptedBinding)
	promptedBinding:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	promptedBinding:AddCondition(GenerateClosure(HasJumpHintLeft, self, frame));
	promptedBinding:SetLabelFunction(GenerateClosure(GetJumpHintLeftLabel, self, frame));
end

function GamepadFrameControlsManagerMixin:ClearAllJumpHints()
	for _, frame in ipairs(self.shownFrames) do
		ShowLeftJumpHint(frame, false);
		ShowRightJumpHint(frame, false);
		ShowFocusJumpHint(frame, false);
	end
end

--[[
	Updates Left, Right, and TargetFocus jump hint prompts on managed frames.

	Current implmentation is for frames to register their footer bindings with
	this class. See: RegisterJumpHintRightBinding, RegisterJumpHintLeftBinding

	Migration: Navigation jump hints should be handled via frame footers. Frames
	that have been migrated should set self.useFooterJumpHints = true. When
	we are confident that no unmigrated frames remain, we can remove this
	branch / functionality altogether.

	Legacy: Show directional jump hints on the target frames
	Current: Show directional jump hints on the focused frame's footer

	Cleanup Task: https://t2jira.corp.blizzard.net/browse/CAM-14610
]]
function GamepadFrameControlsManagerMixin:RefreshJumpHints()
	self:ClearAllJumpHints();

	-- If the Radial is up, no jump hints.
	local isMainMenuShown = not InGlue() and GamepadRadial and GamepadRadial:IsShown();
	if isMainMenuShown then
		return;
	end

	local focusedFrame = GetJumpHintFocusedFrame(self);

	-- If we do not have a focused frame, no jump hints
	if not focusedFrame then
		return;
	end

	-- If frame paging is disabled, no jump hints
	if focusedFrame.disableFrameFocusPagingWhenFocused then
		return;
	end

	-- If not in UI mode, the "focusedFrame" needs a jump target hint
	if focusedFrame and not self.isUIFocused then
		ShowFocusJumpHint(focusedFrame, true);
	end

	-- Legacy: Show JumpHints on the surrounding frames
	local focusedIndex = ArrayIndexOf(self.shownFrames, focusedFrame);
	assert(focusedIndex > 0, "Frame is not tracked by FrameControlsManager");

	-- Legacy: Previous frame gets a "LT" image
	local previousIndex = focusedIndex > 1 and focusedIndex - 1 or nil;
	local previousFrame = previousIndex and self.shownFrames[previousIndex] or nil;
	if previousFrame and not focusedFrame.useFooterJumpHints then
		ShowLeftJumpHint(previousFrame, true);
	end

	-- Legacy: Next frame gets a "RT" image
	local nextIndex = focusedIndex < #self.shownFrames and focusedIndex + 1 or nil;
	local nextFrame = nextIndex and self.shownFrames[nextIndex] or nil;
	if nextFrame and not focusedFrame.useFooterJumpHints then
		ShowRightJumpHint(nextFrame, true);
	end
end

function GamepadFrameControlsManagerMixin:RefreshFocus()
	self:RefreshGamepadCursorHovering();
	self:RefreshJumpHints();
	EventRegistry:TriggerEvent("Gamepad.RefreshFrameFocus");
end

-----------------------------------------------------------------------------------
-- Create Singleton
-----------------------------------------------------------------------------------
GamepadMode.FrameControlsManager = CreateAndInitFromMixin(GamepadFrameControlsManagerMixin);
