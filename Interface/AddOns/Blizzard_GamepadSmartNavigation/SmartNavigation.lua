local Utility = require(".Utility");

local DEFAULT_DIRECTION_BUFFER = 45 * (math.pi / 180);
local ALLOW_DIAGONAL_NAVIGATION = false; -- May be re-enabled as an optional setting or special case solution later
local STICK_NAV_THRESHOLD = 0.1;

--[[
	Get a reference to the table holding all the buttons contained within `scrollFrame` for the
	active panel.
]]
local function GetButtonsForScrollFrame(self, scrollFrame)
	local focusedGroup = self:GetActiveGroup(self.activeInfo);

	if focusedGroup and focusedGroup.scrollFrames then
		for _, frameInfo in ipairs(focusedGroup.scrollFrames) do
			if frameInfo.scrollFrame == scrollFrame then
				return frameInfo.buttons;
			end
		end
	end
end

local function SelectClosestScrollFrameButton(self, scrollFrame, scrollFrameButtons)
	local scrollLeft, scrollBottom, scrollWidth, scrollHeight = scrollFrame:GetRect();
	local scrollRight, scrollTop = scrollLeft + scrollWidth, scrollBottom + scrollHeight;
	local scrollX, scrollY = scrollLeft + scrollWidth * 0.5, scrollBottom + scrollHeight * 0.5;
	local bestDistSq = math.huge;
	local bestButton = nil;

	for _, button in ipairs(scrollFrameButtons) do
		local buttonIsValid = self:CanNavigateToButton(button);
		if buttonIsValid then
			local left, bottom, width, height = button:GetRect();
			if left then
				local right, top = left + width, bottom + height;

				local closestX = math.clamp(scrollX, left, right);
				local closestY = math.clamp(scrollY, bottom, top);

				local distX = scrollX - closestX;
				local distY = scrollY - closestY;
				local distSq = distX * distX + distY * distY;

				if (distSq < bestDistSq) then
					bestDistSq = distSq;
					bestButton = button;
				end
			end
		end
	end

	self:SelectButton(bestButton);
end

--[[
	Update the selected button while scrolling through a scroll frame.
]]
local function UpdateScrollSelection(self)
	local scrollFrame = self.activeInfo.currentScrollFrame;
	if SmartNavigation_ShouldScrollFrameMaintainPreviousButtonOnScroll(scrollFrame) then
		return;
	end

	local scrollFrameButtons = GetButtonsForScrollFrame(self, scrollFrame);
	if scrollFrameButtons then
		SelectClosestScrollFrameButton(self, scrollFrame, scrollFrameButtons);
	end
end

SmartNavigationMixin = CreateFromMixins(CallbackRegistryMixin);

local SmartNavigationEvents =
{
	"HitTopEdge",
	"HitBottomEdge",
	"HitLeftEdge",
	"HitRightEdge",
	"FocusedFrame",
	"UnfocusedFrame",
	"SelectedButtonUpdated",
	"SelectedButtonEnabledStateChanged"
};

SmartNavigationMixin:GenerateCallbackEvents(SmartNavigationEvents);

function SmartNavigationMixin:ResetVars()
	self.activePanels = {};
	self.hookedFrames = {};

	self.activeInfo = nil;
	self.currentButton = nil;
	self.clickButton = nil;

	self.currentDirections = {};
	self.lastDirection = nil;

	self.rightStickScrolling = false;
	self.bindingActive = false;

	--[[
		Used in cases where the scroll bar offset can only be integer values but we
		still want to handle varying scroll speeds based on right stick input.
	]]
	self.accumulatedRightStickScrollOffset = 0;

	self.enabled = false;
end

function SmartNavigationMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self:EnableGamePadButton(true);
	self:SetFrameStrata("TOOLTIP");

	self:ResetVars();

	self.navigatingTime = 0;
	self.startedNavigating = false;
	self.startDelay = ALLOW_DIAGONAL_NAVIGATION and 0.1 or 0.0; -- To allow for multiple inputs for diagonals
	self.repeatStart = 0.4;
	self.repeatDelay = 0.2;
	self.isRepeating = false;
	self.maxScrollSpeed = GetCVarNumberOrDefault("SmartNavigationScrollSpeed");

	self.IsHandlingInputEvents = true;

	self:UpdateResolution();

	self:SetPosition(400, 400);

	self:HideCursor();

	self:SetupFrameHooks();

	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("KIOSK_SESSION_EXPIRED");
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	CVarCallbackRegistry:RegisterCallback("SmartNavigationScrollSpeed", function()
		self.maxScrollSpeed = GetCVarNumberOrDefault("SmartNavigationScrollSpeed");
	end, self);

	self:SetRightStickScrollingEnabled(false);

	self:RegisterForTransitions();
	return true;
end

function SmartNavigationMixin:RegisterForTransitions()
	InputUtil.RegisterForHighPrioInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function SmartNavigationMixin:InitializeGamepad()
	self.enabled = true;
end

function SmartNavigationMixin:UninitializeGamepad()
	self.enabled = false;
	self:HideCursor();
	self:ResetVars();

	GamepadMode.DeactivateBindingGroup(self.navigationBindings);
	GamepadMode.DeactivateBindingGroup(self.rightStickScrollBindings);
end

function SmartNavigationMixin:SetupInputBindings()
	local function OnNavigationBindingOverbound(inDirection)
		local index = tIndexOf(self.currentDirections, inDirection);
		if index ~= nil then
			table.remove(self.currentDirections, index);
		end
		self.navigatingTime = 0;
		self.shouldPropagate = false;
	end

	self.navigationBindings = GamepadMode.CreateBindingGroup("SmartNavigationBindings");
	self.navigationBindings:AddFunctionBinding(GAMEPAD_DPAD_RIGHT, GenerateClosure(self.NavigateRight, self), GAMEPAD_BUTTON_ANY_DOWN_OR_UP,
											   GenerateClosure(OnNavigationBindingOverbound,  SMART_NAV_INPUT_DIRECTION.RIGHT));
	self.navigationBindings:AddFunctionBinding(GAMEPAD_DPAD_LEFT, GenerateClosure(self.NavigateLeft, self), GAMEPAD_BUTTON_ANY_DOWN_OR_UP,
											   GenerateClosure(OnNavigationBindingOverbound,  SMART_NAV_INPUT_DIRECTION.LEFT));
	self.navigationBindings:AddFunctionBinding(GAMEPAD_DPAD_TOP, GenerateClosure(self.NavigateUp, self), GAMEPAD_BUTTON_ANY_DOWN_OR_UP,
											   GenerateClosure(OnNavigationBindingOverbound,  SMART_NAV_INPUT_DIRECTION.UP));
	self.navigationBindings:AddFunctionBinding(GAMEPAD_DPAD_BOTTOM, GenerateClosure(self.NavigateDown, self), GAMEPAD_BUTTON_ANY_DOWN_OR_UP,
											   GenerateClosure(OnNavigationBindingOverbound,  SMART_NAV_INPUT_DIRECTION.DOWN));

	self.navigationBindings:AddFunctionBinding(GAMEPAD_FACE_BOTTOM, GenerateClosure(self.Click, self));
	self.navigationBindings:AddFunctionBinding(GAMEPAD_FACE_RIGHT, GenerateClosure(self.AttemptClose, self));

	self.rightStickScrollBindings = GamepadMode.CreateBindingGroup("SmartNavigationScrolling");
	self.rightStickScrollBindings:AddAxisBinding(GAMEPAD_STICK_RIGHT, GenerateClosure(self.OnGamepadRightStick, self));

	if self.bindingActive then
		GamepadMode.ActivateBindingGroup(self.navigationBindings);
	end

	if self.rightStickScrolling then
		GamepadMode.ActivateBindingGroup(self.rightStickScrollBindings);
	end
end

function SmartNavigationMixin:SetupFrameHooks()
	hooksecurefunc("CreateFrame", function(frameType, name, parent, template, id)
		if parent then
			self:UpdateParent(parent);
		end
	end);
end

function SmartNavigationMixin:OnDropDownShown(inListFrame)
	if self.activeInfo then
		self:AnchorDropDown(inListFrame);
		self:HandlePanelOpen(inListFrame);
	end
end

function SmartNavigationMixin:ActivateBinding()
	if (self.bindingActive) then
		return;
	end

	if self.navigationBindings then
		GamepadMode.ActivateBindingGroup(self.navigationBindings);
	end

	self.bindingActive = true;
end

function SmartNavigationMixin:DeactivateBinding()
	if (not self.bindingActive) then
		return;
	end

	if (self.navigationBindings) then
		GamepadMode.DeactivateBindingGroup(self.navigationBindings);
	end

	self.bindingActive = false;
end

function SmartNavigationMixin:SetRightStickScrollingEnabled(inEnable)
	if self.rightStickScrolling == inEnable then
		return;
	end

	if self.rightStickScrollBindings then
		if inEnable then
			GamepadMode.ActivateBindingGroup(self.rightStickScrollBindings);
		else
			GamepadMode.DeactivateBindingGroup(self.rightStickScrollBindings);
		end
	end

	self.rightStickScrolling = inEnable;
	self.scrollSpeed = 0;
end

function SmartNavigationMixin:OnShow()
	if not self.enabled then
		return;
	end

	if self.activeInfo then
		self:ShowCursor(true);
	end
end

function SmartNavigationMixin:OnHide()
	self:SetActiveFrame(nil);
	self:HideCursor();

	self:SetRightStickScrollingEnabled(false);

	self:DeactivateBinding();

	if( not InGlue() ) then
		-- Smart navigation supports moving items, we should cancel that only when all frames are closed unless we are deleting an item
		local cursorType, itemID = GetCursorInfo();
		if( cursorType ) then
			if self.itemBeingDeleted and cursorType == "item" then
				if itemID ~= self.itemBeingDeleted then
					ClearCursor();
					self:ClearItemToBeDeleted();
				end
			else
				ClearCursor();
			end
		end

		-- Called as the final step for hiding smartnav in-game. Confirms if there is a shown frame that should be activated.
		GamepadMode.FrameControlsManager:FocusFirstFrameShown();
	end
end

function SmartNavigationMixin:SuspendCursor(shouldSuspend)
	if (shouldSuspend) then
		self:SelectButton(nil)
		self:HideCursor();
		self.isCursorSuspended = true;
	else
		self.isCursorSuspended = false;
	end
end

function SmartNavigationMixin:ShowCursor(shouldSelectButton)
	if (not self.enabled or self.isCursorSuspended) then
		return;
	end

	--Disable stick controlling the cursor/character while SmartNavigation is active.
	SetGamePadCursorControl(false);
	self:Show();
	self:SetAlpha(1);

	local introAnim = self.Pointer.IntroAnim;
	if introAnim:IsPaused() then
		introAnim:Play();
	end

	if (shouldSelectButton and self.currentButton == nil) then
		self:SelectFirstButton();
	end
end

function SmartNavigationMixin:HideCursor(maintainPreviousButton)
	self:ClearNavigationInput();
	self:SetAlpha(0);

	self.Pointer.IntroAnim:Restart();
	self.Pointer.IntroAnim:Pause();

	if (not maintainPreviousButton) then
		self:SelectButton(nil);
	end

	--Enable stick controlling the cursor/character while SmartNavigation is not active.
	SetGamePadCursorControl(false);
end

function SmartNavigationMixin:IsCursorHidden()
	return self:GetAlpha() == 0;
end

-- Allow cases to alter the cursor when Smart Navigation is still active but in a state that will not move the cursor.
function SmartNavigationMixin:ShowCursorAsActive(active)
	if active then
		self:SetAlpha(1);
	else
		self:SetAlpha(0.35);
	end
end

function SmartNavigationMixin:UpdateCursorColor()
	local color = SpellIsTargeting() and GAMEPAD_SMARTNAV_TARGETING_CURSOR_COLOR or GAMEPAD_SMARTNAV_CURSOR_COLOR;
	self.Pointer.Icon.Cursor:SetVertexColor(color:GetRGBA());
end

function SmartNavigationMixin:OnEvent(event, ...)
	if event == "DISPLAY_SIZE_CHANGED" then
		self:UpdateResolution();
	elseif event == "ADDON_LOADED" then
		local addonLoaded = ...;
		if addonLoaded == "Blizzard_GamepadSharedUtility" then
			self:SetupInputBindings();
		end
	elseif event == "KIOSK_SESSION_EXPIRED" then
		self:HideCursor();
	elseif event == "CURRENT_SPELL_CAST_CHANGED" then
		self:UpdateCursorColor();
	end
end

function SmartNavigationMixin:OnUpdate(delta)
	if self.activeInfo then
		if #self.currentDirections > 0 then
			self.navigatingTime = self.navigatingTime + delta;
			local shouldNavigate = false;
			if not self.startedNavigating then
				shouldNavigate = self.navigatingTime > self.startDelay;

				if shouldNavigate then
					self.startedNavigating = true;
					self.navigatingTime = self.navigatingTime - self.startDelay;
				end
			else
				local _;
				if not self.isRepeating then
					shouldNavigate = self.navigatingTime > self.repeatStart;
					if shouldNavigate then
						_, self.navigatingTime = math.modf(self.navigatingTime / self.repeatStart);
						self.isRepeating = true;
					end
				else
					shouldNavigate = self.navigatingTime > self.repeatDelay;
					if shouldNavigate then
						_, self.navigatingTime = math.modf(self.navigatingTime / self.repeatDelay);
					end
				end
			end

			if shouldNavigate then
				self:Navigate(self:GetCurrentDirection());
			end
		else
			self.startedNavigating = false;
			self.isRepeating = false;
		end

		if self.rightStickScrolling and self.activeInfo.currentScrollFrame then
			local scrollFrame = self.activeInfo.currentScrollFrame;
			local canScroll = false;
			if self.scrollSpeed ~= 0 then
				if scrollFrame:IsObjectType("ScrollFrame")  then
					local maxOffset = scrollFrame:GetVerticalScrollRange();
					canScroll = maxOffset > 0.01;
					if canScroll then
						local currentOffset = scrollFrame:GetVerticalScroll();
						local newOffset = currentOffset - (self.scrollSpeed * delta);

						newOffset = Clamp(newOffset, 0, maxOffset);

						scrollFrame:SetVerticalScroll(newOffset);
					end
				elseif (scrollFrame.isScrollingMessageFrame) then
					local maxOffset = scrollFrame:GetMaxScrollRange();
					canScroll = maxOffset > 0;
					if canScroll then
						local currentOffset = scrollFrame:GetScrollOffset();

						--[[
							Update the offset amount that the SMF is accumulating across ticks. Each tick's accumulation may be different
							due to how much the right stick is pressed effects the scroll speed and the time between ticks.
						]]
						if (currentOffset ~= maxOffset or currentOffset ~= 0) then
							self.accumulatedRightStickScrollOffset = self.accumulatedRightStickScrollOffset + (self.scrollSpeed * delta);
						else
							-- Reset the accumulated offset to 0 since we have reached the min/max scroll.
							self.accumulatedRightStickScrollOffset = 0;
						end

						if (self.accumulatedRightStickScrollOffset > 0) then
							--[[
								SMF scroll bars can only be scrolled in integer increments, so we use the floor to determine
								what the offset would be if we scrolled up by the incremental amounts we have accumulated.
							]]
							local accumulatedOffset = math.floor(currentOffset + self.accumulatedRightStickScrollOffset);

							--[[
								If the accumulated offset is different than the SMF's current offset then the player has held
								the right stick enough across multiple ticks in order to scroll to a higher value.
							]]
							if (currentOffset ~= accumulatedOffset) then
								local offsetStep = accumulatedOffset - currentOffset;
								scrollFrame:ScrollByAmount(offsetStep);

								-- Reset the accumulated offset to only that unused when stepping to the higher integer offset.
								self.accumulatedRightStickScrollOffset = self.accumulatedRightStickScrollOffset - (scrollFrame:GetScrollOffset() - currentOffset);
							end
						elseif (self.accumulatedRightStickScrollOffset < 0) then
							--[[
								SMF scroll bars can only be scrolled in integer increments, so we use the ceiling to determine
								what the offset would be if we scrolled down by the incremental amounts we have accumulated.
							]]
							local accumulatedOffset = math.ceil(currentOffset + self.accumulatedRightStickScrollOffset);

							--[[
								If the accumulated offset is different than the SMF's current offset then the player has held
								the right stick enough across multiple ticks in order to scroll to a lower value.
							]]
							if (currentOffset ~= accumulatedOffset) then
								local offsetStep = accumulatedOffset - currentOffset;
								scrollFrame:ScrollByAmount(offsetStep);

								-- Reset the accumulated offset to only that unused when stepping to the lower integer offset.
								self.accumulatedRightStickScrollOffset = self.accumulatedRightStickScrollOffset + (currentOffset - scrollFrame:GetScrollOffset());
							end
						end
					end
				else
					local scrollRange = scrollFrame:GetDerivedScrollRange();
					canScroll = scrollRange > 0.01;
					if canScroll then
						local scrollOffset = scrollFrame:GetDerivedScrollOffset();
						local newOffset = (scrollOffset - (self.scrollSpeed * delta))/scrollRange;

						newOffset = Clamp(newOffset, 0, 1);

						scrollFrame:SetScrollPercentage(newOffset);
					end
				end

				if canScroll then
					UpdateScrollSelection(self);
				end
			else
				self.accumulatedRightStickScrollOffset = 0;
			end
		end
	end
end

function SmartNavigationMixin:TrySelectButton(inButton)
	while inButton and inButton.smartNavigationProxyTarget do
		inButton = inButton.smartNavigationProxyTarget;
	end

	if self.currentButton == inButton
		or not inButton
		or not self.activeInfo
		or not self:IsButtonValid(inButton)
	then
		return;
	end

	local function FindButtonInGroup(buttonGroup)
		if buttonGroup.buttons and table.contains(buttonGroup.buttons, inButton) then
			return true;
		end
		if buttonGroup.scrollFrames then
			for _, scrollInfo in ipairs(buttonGroup.scrollFrames) do
				if scrollInfo.buttons and table.contains(scrollInfo.buttons, inButton) then
					return true, scrollInfo.scrollFrame;
				end
			end
		end
	end

	local activeGroup = self:GetActiveGroup(self.activeInfo);
	if activeGroup then
		local found, scrollFrame = FindButtonInGroup(activeGroup);
		if found then
			self:SelectButton(inButton, scrollFrame);
			return;
		end
	end

	local buttonGroups = self.activeInfo.buttonGroups;
	if not buttonGroups then
		return;
	end

	if buttonGroups.mainGroup and buttonGroups.mainGroup ~= activeGroup then
		local found, scrollFrame = FindButtonInGroup(buttonGroups.mainGroup);
		if found then
			self:LeaveFocusGroup(inButton, scrollFrame);
			return;
		end
	end

	if buttonGroups.subGroups then
		local function TryEnterGroupAndSelectButton(buttonGroup, focusKey)
			local found, scrollFrame = FindButtonInGroup(buttonGroup);
			if found then
				self:EnterFocusGroup(focusKey, nil, inButton, scrollFrame);
				return true;
			end
		end

		for key, buttonGroup in pairs(buttonGroups.subGroups) do
			if TryEnterGroupAndSelectButton(buttonGroup, key) then
				return;
			end
		end
	end
end

function SmartNavigationMixin:SelectButton(inButton, forceReselect)
	if self.isCursorSuspended or (self.currentButton == inButton and not forceReselect) then
		return;
	end

	-- This _shouldn't_ be called recursively, but try to act sensibly if it does since it calls so
	-- many user-provided callbacks that it inevitably _will_ be called recursively.
	local sequence = (self.selectButtonSequence or 0) + 1;
	self.selectButtonSequence = sequence;
	local function IsCurrent()
		return self.selectButtonSequence == sequence;
	end

	local prevButton = self.currentButton;
	if prevButton then
		prevButton:SetHighlightLocked(false);

		self:RunCurrentButtonLeaveScript();

		-- RunCurrentButtonLeaveScript may have re-selected this button, in which case we need to
		-- leave it selected.
		if prevButton.OnSmartNavDeselect and (IsCurrent() or self.currentButton ~= prevButton) then
			prevButton:OnSmartNavDeselect();
		end

		-- OnSmartNavDeselect may also have changed the current button, in which case none of the
		-- remaining work applies anymore.
		if not IsCurrent() then
			return;
		end

		self.currentButton = nil;
	end

	if inButton then
		self.currentButton = inButton;
		self.currentButton:SetHighlightLocked(true);
		self:TrackButtonEnabledState(inButton);

		self:RunCurrentButtonEnterScript();

		-- RunCurrentButtonEnterScript may have called SelectButton
		if IsCurrent() then
			local activeFrame = self.activeInfo.frame;
			if activeFrame and activeFrame.SmartNavigationOnSelect then
				activeFrame:SmartNavigationOnSelect(inButton);
			end
		end

		-- OnSmartNavSelect will have already been called if there was a recursive call with the
		-- same button. Or if another button was selected instead it's no longer relevant.
		if inButton.OnSmartNavSelect and IsCurrent() then
			inButton:OnSmartNavSelect();
		end

		if IsCurrent() then
			self:UpdateCursorPosition();
		end
	end

	self:TriggerEvent("SelectedButtonUpdated");
end

function SmartNavigationMixin:TrackButtonEnabledState(button)
	if not button then
		return;
	end

	self.hookedButtons = self.hookedButtons or {};

	if self.hookedButtons[button] then
		return;
	end

	self.hookedButtons[button] = true;

	local function OnEnabledStateChanged(btn)
		if btn == self.currentButton then
			self:TriggerEvent("SelectedButtonEnabledStateChanged");
		end
	end

	button:HookScript("OnEnable", OnEnabledStateChanged);
	button:HookScript("OnDisable", OnEnabledStateChanged);
end

function SmartNavigationMixin:ReselectCurrentButton()
	local forceReselect = true;
	self:SelectButton(self.currentButton, forceReselect);
end

function SmartNavigationMixin:RunCurrentButtonEnterScript()
	if self.currentButton then
		self.currentButton:FocusEnter();
	end
end

function SmartNavigationMixin:RunCurrentButtonLeaveScript()
	if self.currentButton then
		self.currentButton:FocusExit();
	end
end

function SmartNavigationMixin:SetPosition(inX, inY)
	if inX > self.xRes then
		inX = self.xRes;
	end

	if inY > self.yRes then
		inY = self.yRes;
	end

	self:ClearAllPoints();
	self:SetPoint("RIGHT", UIParent, "BOTTOMLEFT", inX, inY);
end

function SmartNavigationMixin:UpdateCursorPosition()
	if (not self.currentButton) then
		return;
	end

	-- Default to horizontal cursor
	self:SetCursorArtHorizontal();

	if (self.currentButton.smartNavigationVerticalCursor) then
		self:SetCursorArtVerical();
		self:ClearAllPoints();
		self:SetPoint("TOP", self.currentButton, "BOTTOM", 0, 0);
		return;
	end

	if (self.currentButton.smartNavigationCustomCursorAnchor) then
		local clearAllPoints = true;
		self.currentButton.smartNavigationCustomCursorAnchor:SetPoint(self, clearAllPoints);
		return;
	end

	local xOffset = self.cursorOffsetX;
	local yOffset = self.cursorOffsetY;

	-- Use custom offsets if they have been set for the button
	if (self.currentButton.customSmartNavOffsetX) then
		xOffset = self.currentButton.customSmartNavOffsetX;
	end
	if (self.currentButton.customSmartNavOffsetY) then
		yOffset = self.currentButton.customSmartNavOffsetY;
	end

	self:ClearAllPoints();
	self:SetPoint("RIGHT", self.currentButton, "LEFT", xOffset, yOffset);

	-- The cursor may not be showing yet, depending on how we got here
	self:ShowCursor(false);
end

function SmartNavigationMixin:GetPanelInfo(inFrame, dontCreateIfNotFound)
	local foundPanelInfo = nil;

	for _, panelInfo in ipairs(self.activePanels) do
		if panelInfo.frame == inFrame then
			foundPanelInfo = panelInfo;
			break;
		end
	end

	if not dontCreateIfNotFound and not foundPanelInfo then
		foundPanelInfo = { frame = inFrame, buttonGroups = {} };
		if not self.hookedFrames[inFrame] then
			-- There is no way to unhook a script so make sure we only hook it one time.
			self.hookedFrames[inFrame] = true;
			inFrame:HookScript("OnHide", function(hiddenPanel)
				self:HandlePanelClose(hiddenPanel);
			end);
		end

		table.insert(self.activePanels, foundPanelInfo);

		if (inFrame.smartNavPanelInfoAddedCallback) then
			inFrame.smartNavPanelInfoAddedCallback(foundPanelInfo);
		end
	end

	return foundPanelInfo;
end

function SmartNavigationMixin:GetLastButtonForPanelInfo(panelInfo)
	return panelInfo.lastButton;
end

function SmartNavigationMixin:SetLastButtonForPanelInfo(panelInfo, lastButton)
	panelInfo.lastButton = lastButton;
end

function SmartNavigationMixin:GetActiveGroup(inFrameInfo)
	local activeGroup = nil;
	if inFrameInfo then
		local buttonGroups = inFrameInfo.buttonGroups;
		if buttonGroups.focusedGroup ~= nil then
			activeGroup = buttonGroups.focusedGroup;
		else
			activeGroup = buttonGroups.mainGroup;
		end
	end

	return activeGroup;
end

function SmartNavigationMixin:HandlePanelClose(inPanel)
	self:RemovePanelInfo(inPanel);
end

function SmartNavigationMixin:RemovePanelInfo(inFrame)
	local index = nil;
	local associatedPanelInfo = nil;
	for i, panelInfo in ipairs(self.activePanels) do
		if panelInfo.frame == inFrame then
			index = i;
			associatedPanelInfo = panelInfo;
			break;
		end
	end

	if index then
		table.remove(self.activePanels, index);
	end

	if self.activeInfo and self.activeInfo.frame == inFrame then
		self:SetActiveFrame(nil);
	end

	-- Called after the remove so that the SetActiveFrame call can update the last button for the active frame's info.
	if associatedPanelInfo and inFrame.smartNavPanelInfoRemovedCallback then
		inFrame.smartNavPanelInfoRemovedCallback(associatedPanelInfo);
	end

	return index ~= nil;
end

function SmartNavigationMixin:SetActiveFrame(inFrameInfo)
	if self.activeInfo ~= inFrameInfo then
		if self.activeInfo then
			GamepadScrollBarHint:Hide();
			self:SetLastButtonForPanelInfo(self.activeInfo, self.currentButton);
			self.accumulatedRightStickScrollOffset = 0;
		end

		--Clear any direction inputs when changing frames
		self.currentDirections = {};
		self:SelectButton(nil);
		self:SetRightStickScrollingEnabled(false);

		self.activeInfo = inFrameInfo;

		if self.activeInfo then
			self:ShowCursor(true);
			if self.activeInfo.currentScrollFrame then
				self:SetRightStickScrollingEnabled(true);
			end

			local frame = self.activeInfo.frame;
			if frame.OnSmartNavFocus then
				frame:OnSmartNavFocus();
			end
		else
			self:Hide();
		end
	end
end

function SmartNavigationMixin:ClearActiveFrames()
	while self.activeInfo ~= nil do
		self:RemovePanelInfo(self.activeInfo.frame);
	end
end

function SmartNavigationMixin:SelectFirstButton(forceReselect)
	if self.activeInfo then
		if self.activeInfo.lastButton then
			self:SelectButton(self.activeInfo.lastButton, forceReselect);
		elseif self.activeInfo.targetButton then
			self:SelectButton(self.activeInfo.targetButton, forceReselect);
		else
			self:SelectButton(self:FindTopLeftButton(self.activeInfo), forceReselect);
		end
	end

	-- If there is no button then hide the smart nav cursor. Useful for frame tabs that can be activated with no buttons.
	if (self.currentButton == nil) then
		self:HideCursor();
	end
end

function SmartNavigationMixin:SelectTopLeftButton()
	if self.activeInfo then
		self:SelectButton(self:FindTopLeftButton(self.activeInfo));

		if (self.currentButton == nil) then
			self:HideCursor();
		end
	end
end

function SmartNavigationMixin:IsButtonInCurrentFocusGroup(button)
	local activeInfo = self.activeInfo;
	if not activeInfo then
		return false;
	end

	local activeGroup = activeInfo.buttonGroups.focusedGroup;
	if activeGroup == nil then
		activeGroup = activeInfo.buttonGroups.mainGroup;
	end

	if tContains(activeGroup.buttons, button) then
		return true;
	end

	for _, scrollFrame in ipairs(activeGroup.scrollFrames) do
		if tContains(scrollFrame.buttons, button) then
			return true;
		end
	end

	return false;
end

function SmartNavigationMixin:SetTargetButtonForFrame(inFrame, inTargetButton)
	local panelInfo = self:GetPanelInfo(inFrame, true);
	if panelInfo then
		panelInfo.targetButton = inTargetButton;

		if self.activeInfo == panelInfo and inTargetButton then
			self:SelectButton(inTargetButton);
		end
	end
end

function SmartNavigationMixin:SetScrollFrameForFrame(inFrame, inScrollFrame)
	local panelInfo = self:GetPanelInfo(inFrame, true);
	if panelInfo then
		if panelInfo.currentScrollFrame ~= inScrollFrame then
			self.accumulatedRightStickScrollOffset = 0;
			panelInfo.currentScrollFrame = inScrollFrame;
			if self.activeInfo == panelInfo then
				self:SetRightStickScrollingEnabled(inScrollFrame ~= nil);
			end
		end
	end
end

function SmartNavigationMixin:GetParentPanelInfo(frame)
	if #self.activePanels == 0 then
		return;
	end

	local function CheckForPanelInfo(curr)
		if curr and curr ~= UIParent then
			local panelInfo = self:GetPanelInfo(curr, true);
			return panelInfo or CheckForPanelInfo(curr:GetParent());
		end
	end

	return CheckForPanelInfo(frame);
end

function SmartNavigationMixin:SetNavigationFunction(inFrame, inFunc)
	local panelInfo = self:GetPanelInfo(inFrame, true);
	if panelInfo then
		panelInfo.canNavigateTo = inFunc;
	end
end

function SmartNavigationMixin:ClearLastTarget(inFrame)
	local panelInfo = self:GetPanelInfo(inFrame, true);
	if panelInfo then
		self:SetLastButtonForPanelInfo(panelInfo, nil);
	end
end

function SmartNavigationMixin:SetWrapping(inFrame, shouldWrap)
	local panelInfo = self:GetPanelInfo(inFrame, true);
	if panelInfo then
		panelInfo.isWrapping = shouldWrap;
	end
end

-- Changes the navigation to use a logical grid to allow for more specific wrapping behaviors.
-- This assumes all the frames exist in a strict grid where all frames share an X or Y coord with their neighbors.
-- The frames are sorted into columns and rows to be used for navigation instead of using directional raycasts.
function SmartNavigationMixin:SetUseGridNavigation(inFrame, inUseGrid)
	local panelInfo = self:GetPanelInfo(inFrame, true);
	if panelInfo then
		panelInfo.useGrid = inUseGrid;
		self:UpdateGrid(panelInfo);
	end
end

function SmartNavigationMixin:HandleScroll(nextButton, buttonScrollFrame)
	-- We will try to keep the target button in the middle of the scroll frame
	-- May want to add a way to "jump" out of a scroll frame
	local _, scrollMiddile = buttonScrollFrame:GetCenter();
	local _, buttonMiddle = nextButton:GetCenter();
	local scrollOffset = scrollMiddile - buttonMiddle;
	local logicalChange = false;

	if buttonScrollFrame:IsObjectType("ScrollFrame") then
		local newScrollOffset = buttonScrollFrame:GetVerticalScroll() + scrollOffset;
		local maxScroll = buttonScrollFrame:GetVerticalScrollRange();
		if newScrollOffset < 0 then
			newScrollOffset = 0;
		elseif newScrollOffset > maxScroll then
			newScrollOffset = maxScroll;
		end

		buttonScrollFrame:SetVerticalScroll(newScrollOffset);
	else
		if buttonScrollFrame:HasScrollableExtent() or buttonScrollFrame.ScrollTarget then
			local scrollPercentageOffset = 0;
			local scrollRange = buttonScrollFrame:GetDerivedScrollRange();
			if scrollRange > 0 then
				scrollPercentageOffset = scrollOffset / scrollRange;
			end
			local oldScrollPercentage = buttonScrollFrame:CalculateScrollPercentage();

			local newScrollPercentage = scrollPercentageOffset + oldScrollPercentage;

			if newScrollPercentage < 0 then
				newScrollPercentage = 0;
			elseif newScrollPercentage > 1 then
				newScrollPercentage = 1;
			end

			local oldElementData = nil;
			-- If this a button inside of a button we need a way to track back to the button if the scrollBox is moved
			local childMap = {};
			if nextButton.GetElementData then
				oldElementData = nextButton:GetElementData();
			else
				local element = nextButton;
				while element.GetElementData == nil do
					local elementParent = element:GetParent();
					local elementChildren = { elementParent:GetChildren() };

					for i, child in ipairs(elementChildren) do
						if child == element then
							table.insert(childMap, 1, i);
							break
						end
					end

					element = elementParent;

					if element == buttonScrollFrame then
						break;
					end
				end

				if element ~= buttonScrollFrame and element.GetElementData ~= nil then
					oldElementData = element:GetElementData();
				end
			end

			buttonScrollFrame:SetScrollPercentage(newScrollPercentage);
			-- The ScrollBox frames are in a pool and can change when scrolling
			-- We have to make sure the button is the same logical button after the scroll happens
			if oldElementData and newScrollPercentage ~= oldScrollPercentage then
				local newNextButton = buttonScrollFrame:FindFrame(oldElementData);

				nextButton = newNextButton;
				-- Some buttons have buttons inside of them so when updating to the correct logical button
				-- we have to find the correct child to focus again.
				if #childMap > 0 then
					for _, childIndex in ipairs(childMap) do
						local children = { nextButton:GetChildren() };
						nextButton = children[childIndex];
					end
				end
				logicalChange = true;
			end
		end
	end

	return nextButton, logicalChange;
end

function SmartNavigationMixin:GetCurrentDirection()
	local direction = CreateVector2D(0,0);

	for _, directionPart in ipairs(self.currentDirections) do
		direction = direction:Add(CreateVector2D(directionPart.x, directionPart.y));
	end

	return direction:Normalize();
end

local AnchorResolvers = {};

function AnchorResolvers.CENTER(l, b, w, h) return l + w * 0.5, b + h * 0.5; end
function AnchorResolvers.TOP(l, b, w, h) return l + w * 0.5, b + h; end
function AnchorResolvers.LEFT(l, b, w, h) return l, b + h * 0.5; end
function AnchorResolvers.RIGHT(l, b, w, h) return l + w, b + h * 0.5; end
function AnchorResolvers.BOTTOM(l, b, w, h) return l + w * 0.5, b; end
function AnchorResolvers.TOPLEFT(l, b, w, h) return l, b + h; end
function AnchorResolvers.TOPRIGHT(l, b, w, h) return l + w, b + h; end
function AnchorResolvers.BOTTOMLEFT(l, b, w, h) return l, b; end
function AnchorResolvers.BOTTOMRIGHT(l, b, w, h) return l + w, b; end

function ResolveAnchor(point, left, bottom, width, height)
	return AnchorResolvers[point](left, bottom, width, height)
end

function SmartNavigationMixin:CanNavigateToButton(inButton)
	if SmartNavigation_IsFrameIgnored(inButton) then
		return false;
	end

	if self.activeInfo.canNavigateTo then
		if not self.activeInfo.canNavigateTo(inButton) then
			return false;
		end
	end

	return true;
end

function SmartNavigationMixin:IsButtonValid(inButton, inScrollFrame)
	if not self:CanNavigateToButton(inButton) then
		return false;
	end

	local valid = inButton:IsVisible() and inButton:IsRectValid();
	local offsetX, offsetY = nil, nil;

	if valid then
		local width, height = inButton:GetSize();
		local buttonX, buttonY;
		local sCenterX, sCenterY;

		local anchor = inButton.smartNavigationCustomCursorAnchor;
		if anchor then
			buttonX, buttonY = ResolveAnchor(anchor.relativePoint, anchor.relativeTo:GetRect());
			sCenterX, sCenterY = ResolveAnchor(anchor.relativePoint, anchor.relativeTo:GetScaledRect());
		else
			local left, bottom, sWidth, sHeight = inButton:GetScaledRect();
			buttonX, buttonY = inButton:GetCenter();
			sCenterX = left + (sWidth / 2);
			sCenterY = bottom + (sHeight / 2);
		end

		local inView = true;
		if inScrollFrame then
			local scrollTop = inScrollFrame:GetTop();
			local scrollBottom = inScrollFrame:GetBottom();
			local scrollLeft = inScrollFrame:GetLeft();
			local scrollRight = inScrollFrame:GetRight();

			inView = buttonX > scrollLeft and buttonX < scrollRight and buttonY < scrollTop and buttonY > scrollBottom;
		end

		valid = width and height and buttonX and buttonY and inView;

		offsetX = sCenterX;
		offsetY = sCenterY;
	end

	return valid, offsetX, offsetY;
end

function SmartNavigationMixin:GetButtonInfoInDirection(inButton, inDirection, inOffset)
	local distanceSorted = {};

	if not inOffset then
		inOffset = {};
		inOffset.x = 0;
		inOffset.y = 0;
	end

	local currentX, currentY;

	local currentAnchor = inButton.smartNavigationCustomCursorAnchor;
	if currentAnchor then
		currentX, currentY = ResolveAnchor(currentAnchor.relativePoint, currentAnchor.relativeTo:GetScaledRect());
	else
		local currentWidth, currentHeight;
		currentX, currentY, currentWidth, currentHeight = inButton:GetScaledRect();
		currentX = currentX + (currentWidth / 2) + inOffset.x;
		currentY = currentY + (currentHeight / 2) + inOffset.y;
	end

	local function FindNearestInDirection(inButtons, inScrollFrame)
		for i, button in ipairs(inButtons) do
			local validButton, buttonX, buttonY = self:IsButtonValid(button, inScrollFrame);

			if button ~= inButton and validButton then
				local directionTo = CreateVector2D(buttonX - currentX, buttonY - currentY);
				if directionTo:GetLength() > 0 then
					local angle = math.abs(Vector2D_CalculateAngleBetween(directionTo.x, directionTo.y, inDirection.x, inDirection.y));

					-- Adjust directional buffer based on the frames custom buffer data.
					local buffer = nil;
					local bufferData = inButton.smartNavigationDirectionBufferData;
					if bufferData then
						local usedSmartNavDirection = nil;
						for _, smartNavDirection in pairs(SMART_NAV_INPUT_DIRECTION) do
							if (smartNavDirection.x == inDirection.x and smartNavDirection.y == inDirection.y) then
								usedSmartNavDirection = smartNavDirection;
								break;
							end
						end

						if (bufferData[usedSmartNavDirection]) then
							buffer = bufferData[usedSmartNavDirection];
						end
					end

					if (buffer == nil) then
						buffer = DEFAULT_DIRECTION_BUFFER;
					end

					if angle <= buffer then
						local distance = directionTo:GetLength();

						local buttonInfo = {};
						buttonInfo.button = button;
						buttonInfo.distance = distance;
						buttonInfo.angle = angle;
						buttonInfo.directionTo = directionTo;
						buttonInfo.scrollFrame = inScrollFrame;

						table.insert(distanceSorted, buttonInfo);
					end
				end
			end
		end
	end

	local activeGroup = self:GetActiveGroup(self.activeInfo);

	if activeGroup then
		FindNearestInDirection(activeGroup.buttons);
		for _, scrollInfo in ipairs(activeGroup.scrollFrames) do
			FindNearestInDirection(scrollInfo.buttons, scrollInfo.scrollFrame);
		end
	end

	local function ButtonDistanceLessThan(buttonInfoA, buttonInfoB)
		return buttonInfoA.distance < buttonInfoB.distance;
	end

	table.sort(distanceSorted, ButtonDistanceLessThan);

	local nextInfo = nil;

	if #distanceSorted > 0 then
		nextInfo = distanceSorted[1];
	end

	return nextInfo;
end

function SmartNavigationMixin:UpdateGrid(inPanelInfo)
	if not inPanelInfo.useGrid then
		inPanelInfo.grid = nil;
		return;
	end

	local activeGroup = self:GetActiveGroup(inPanelInfo);
	inPanelInfo.grid = {};
	local sortedButtons = {};

	if activeGroup then
		for _, button in ipairs(activeGroup.buttons) do
			local validButton = self:IsButtonValid(button);
			if validButton then
				table.insert(sortedButtons, button);
			end
		end
	end

	local sortFunc = function(buttonA, buttonB)
		local _, buttonAX, buttonAY = self:IsButtonValid(buttonA);
		local _, buttonBX, buttonBY = self:IsButtonValid(buttonB);

		if buttonAX == buttonBX then
			return buttonAY > buttonBY;
		else
			return buttonAX < buttonBX;
		end
	end

	table.sort(sortedButtons, sortFunc);

	local lastX = nil;
	local currentColumn = nil;
	for _, button in ipairs(sortedButtons) do
		local _, currentX = self:IsButtonValid(button);
		if not lastX or lastX ~= currentX then
			currentColumn = {};
			table.insert(inPanelInfo.grid, currentColumn);
		end

		if currentColumn then
			table.insert(currentColumn, button);
		end

		lastX = currentX;
	end
end

function SmartNavigationMixin:GetButtonAtGridIndex(inX, inY)
	local grid = self.activeInfo.grid;

	if grid then
		local column = grid[inX];
		if column then
			return column[inY];
		end
	end

	return nil;
end

function SmartNavigationMixin:GetButtonInDirectionGrid(inButton, inDirection)
	local panelInfo = self.activeInfo;
	local grid = panelInfo.grid;
	local nextButton = nil;

	local currentX, currentY = 1, 1;

	local foundButton = false;
	for indexX, buttonColumn in ipairs(grid) do
		for indexY, button in ipairs(buttonColumn) do
			if button == inButton then
				currentX = indexX;
				currentY = indexY;
				foundButton = true;
				break;
			end
			if foundButton then
				break;
			end
		end
	end

	local nextX = currentX + inDirection.x;
	local nextY = currentY - inDirection.y;

	nextButton = self:GetButtonAtGridIndex(nextX, nextY);

	if panelInfo.isWrapping then
		if not nextButton then
			local maxGridX = #grid;

			if inDirection:IsEqualTo(SMART_NAV_INPUT_DIRECTION.UP) then
				nextX = currentX;
				local currentColumn = grid[nextX];
				nextY = #currentColumn;
			elseif inDirection:IsEqualTo(SMART_NAV_INPUT_DIRECTION.DOWN) then
				nextX = currentX;
				nextY = 1;
			elseif inDirection:IsEqualTo(SMART_NAV_INPUT_DIRECTION.RIGHT) then
				nextX = currentX + 1;
				if nextX > maxGridX then
					nextX = 1;
				end
				local newColumn = grid[nextX];
				nextY = Clamp(nextY, 1, #newColumn);
			elseif inDirection:IsEqualTo(SMART_NAV_INPUT_DIRECTION.LEFT) then
				nextX = currentX - 1;
				if nextX < 1 then
					nextX = maxGridX;
				end
				local newColumn = grid[nextX];
				nextY = Clamp(nextY, 1, #newColumn);
			end

			nextButton = self:GetButtonAtGridIndex(nextX, nextY);
		end
	end

	if not nextButton then
		nextButton = inButton;
	end

	return nextButton;
end

function SmartNavigationMixin:Navigate(inDirection)
	inDirection = CreateVector2D(inDirection.x, inDirection.y)
	if self.activeInfo then
		inDirection = inDirection:Normalize();

		if inDirection:GetLength() == 0 then
			return;
		end

		if not self.currentButton then
			self:SelectButton(self:FindTopLeftButton(self.activeInfo));
		else
			if not self.currentButton:IsRectValid() then
				self:SelectButton(self:FindTopLeftButton(self.activeInfo));
				return;
			end

			-- Map the directional input to one of the SMART_NAV_INPUT_DIRECTION
			local usedSmartNavDirection = nil;
			for _, smartNavDirection in pairs(SMART_NAV_INPUT_DIRECTION) do
				if (smartNavDirection.x == inDirection.x and smartNavDirection.y == inDirection.y) then
					usedSmartNavDirection = smartNavDirection;
					break;
				end
			end

			-- Handle Navigation Overrides
			if (usedSmartNavDirection) then
				local navOverride = SmartNavigation_GetNavigationOverrideFrame(self.currentButton, usedSmartNavDirection);
				if (navOverride) then
					if (navOverride == true) or navOverride.shouldIgnoreInputNavOverride then
						return;
					elseif (self:IsButtonValid(navOverride) or SmartNavigation_IsFrameNonCollapsingScrollBoxElement(navOverride)) then
						local previousButton = self.currentButton;
						self:SelectButton(navOverride);
						SmartNavigation_CallOutgoingDirNavigationCallbacks(previousButton, usedSmartNavDirection);
						return;
					end
				end
			end

			if self.activeInfo.useGrid then
				local nextButton = self:GetButtonInDirectionGrid(self.currentButton, inDirection);
				if nextButton then
					self:SelectButton(nextButton);
				end
				return;
			end
			local nextInfo = self:GetButtonInfoInDirection(self.currentButton, inDirection);

			if not nextInfo then
				--The Wrapping assumes we are only moving in a cardinal diration
				if self.activeInfo.isWrapping and usedSmartNavDirection then
					local offset = {};
					offset.x = 0;
					offset.y = 0;
					if inDirection.x == 0 then
						offset.y = (-1 * inDirection.y) * self.yRes;
					end
					if inDirection.y == 0 then
						offset.x = (-1 * inDirection.x) * self.xRes;
					end
					nextInfo = self:GetButtonInfoInDirection(self.currentButton, inDirection, offset);
				else
					-- Trigger the edge events
					if inDirection:IsEqualTo(SMART_NAV_INPUT_DIRECTION.UP) then
						self:TriggerEvent("HitTopEdge");
					elseif inDirection:IsEqualTo(SMART_NAV_INPUT_DIRECTION.DOWN) then
						self:TriggerEvent("HitBottomEdge");
					elseif inDirection:IsEqualTo(SMART_NAV_INPUT_DIRECTION.RIGHT) then
						self:TriggerEvent("HitRightEdge");
					elseif inDirection:IsEqualTo(SMART_NAV_INPUT_DIRECTION.LEFT) then
						self:TriggerEvent("HitLeftEdge");
					end
				end
			end

			if nextInfo then
				local nextButton = nextInfo.button;
				local forceReselect = nil;
				if nextInfo.scrollFrame then
					nextButton, forceReselect = self:HandleScroll(nextButton, nextInfo.scrollFrame);
				end

				local previousButton = self.currentButton;
				self:SelectButton(nextButton, forceReselect);
				if (usedSmartNavDirection) then
					SmartNavigation_CallOutgoingDirNavigationCallbacks(previousButton, usedSmartNavDirection);
				end
			end
		end
	end
end

function SmartNavigationMixin:ClearNavigationInput()
	table.wipe(self.currentDirections);
end

function SmartNavigationMixin:HandleNavigationInput(isDown, inDirection)
	if isDown then
		if not tContains(self.currentDirections, inDirection) then
			if not ALLOW_DIAGONAL_NAVIGATION then
				-- Limit navigation to cardinal directions by only allowing the most recent direction to be active
				table.wipe(self.currentDirections);
			end
			table.insert(self.currentDirections, inDirection);
		end
	else
		local index = tIndexOf(self.currentDirections, inDirection);
		if index ~= nil then
			table.remove(self.currentDirections, index);

			-- Only start navigation if we actually consumed a directional input, to not navigate
			-- on a button release from an action that triggered smart nav.
			if not self.startedNavigating then
				self:Navigate(inDirection);
			end
		end
	end

	self.navigatingTime = 0;
	self.shouldPropagate = false;
end

function SmartNavigationMixin:NavigateRight(isDown)
	self:HandleNavigationInput(isDown, SMART_NAV_INPUT_DIRECTION.RIGHT);
end

function SmartNavigationMixin:NavigateLeft(isDown)
	self:HandleNavigationInput(isDown, SMART_NAV_INPUT_DIRECTION.LEFT);
end

function SmartNavigationMixin:NavigateUp(isDown)
	self:HandleNavigationInput(isDown, SMART_NAV_INPUT_DIRECTION.UP);
end

function SmartNavigationMixin:NavigateDown(isDown)
	self:HandleNavigationInput(isDown, SMART_NAV_INPUT_DIRECTION.DOWN);
end

local function PerformClick(inButton)
	inButton:MouseDown();
	inButton:MouseUp();
end

function SmartNavigationMixin:Click()
	if self.activeInfo then
		self.shouldPropagate = false;
		if SmartNavigation_IsCurrentButtonClickable() then
			local cachedButton = self.currentButton;
			if cachedButton.OnSmartNavClick then
				cachedButton:OnSmartNavClick();
			else
				cachedButton:MouseDown();
				cachedButton:MouseUp();
			end
		end
	end
end

function SmartNavigationMixin:RightClick()
	if self.activeInfo then
		self.shouldPropagate = false;
		if SmartNavigation_IsCurrentButtonClickable() then
			local cachedButton = self.currentButton;
			cachedButton:MouseDown("RightButton");
			cachedButton:MouseUp("RightButton");
		end
	end
end

function SmartNavigationMixin:AttemptClose()
	if self.activeInfo then
		local activeFrame = self.activeInfo.frame;

		if activeFrame.SmartNavigationCloseHandler then
			if activeFrame:SmartNavigationCloseHandler() then
				self.shouldPropagate = false;
				return;
			end
		end

		local possibleCloseButton = activeFrame.CloseButton;
		if not possibleCloseButton then
			local activeGroup = self:GetActiveGroup(self.activeInfo);
			if activeGroup then
				for _, button in ipairs(activeGroup.buttons) do
					if button:IsVisible() then
						local buttonName = button:GetName();
						if buttonName and string.match(buttonName, "CloseButton") then
							possibleCloseButton = button;
							break;
						end
					end
				end
			end
		end

		if possibleCloseButton then
			self.shouldPropagate = false;
			PerformClick(possibleCloseButton);
		end
	end
end

function SmartNavigationMixin:OnGamepadRightStick(inX, inY)
	if self.activeInfo and self.activeInfo.currentScrollFrame then
		local scrollFrame = self.activeInfo.currentScrollFrame;
		local maxScrollSpeed = scrollFrame.smartNavRightStickMaxScrollSpeed and scrollFrame.smartNavRightStickMaxScrollSpeed or self.maxScrollSpeed;
		self.scrollSpeed = inY * maxScrollSpeed;
	end

	return false;
end

function SmartNavigationMixin:FindTopLeftButton(frameInfo)
	local topLeftButton = nil;

	--Top Left of the screen is at 0, YRes
	local lowestX = self.xRes;
	local highestY = 0;

	local function SearchButtons(inButtons, inScrollFrame)
		for _, button in ipairs(inButtons) do
			if (self:IsButtonValid(button, inScrollFrame)) then
				local buttonX = button:GetLeft();
				local buttonY = button:GetBottom();

				if (buttonX and buttonY) then
					if ((lowestX >= buttonX) and (highestY < buttonY)) then
						topLeftButton = button;
						lowestX = buttonX;
						highestY = buttonY;
					end
				end
			end
		end
	end

	local activeGroup = self:GetActiveGroup(frameInfo);

	if activeGroup then
		SearchButtons(activeGroup.buttons);
		for _, scrollInfo in ipairs(activeGroup.scrollFrames) do
			SearchButtons(scrollInfo.buttons, scrollInfo.scrollFrame);
		end
	end

	return topLeftButton;
end

function SmartNavigationMixin:UpdateResolution()
	self.xRes, self.yRes = GetPhysicalScreenSize();
end

function SmartNavigationMixin:HandlePanelOpen(inPanel, extraPanels)
	local panelInfo = self:GetPanelInfo(inPanel);

	if not panelInfo then
		return;
	end

	panelInfo.buttonGroups = Utility.FindButtonGroups(inPanel, extraPanels);

	-- When frames are updated while we are interacting with them we need to make sure we stay in a focused area if we were in one.
	if panelInfo.focusedKey then
		panelInfo.buttonGroups.focusedGroup = panelInfo.buttonGroups.subGroups[panelInfo.focusedKey];
	end

	self:SetActiveFrame(panelInfo);
end

function SmartNavigationMixin:RefreshButtonGroups(inPanel, extraPanels)
	local panelInfo = self.activeInfo;

	if inPanel then
		panelInfo = self:GetPanelInfo(inPanel);
	else
		inPanel = panelInfo and panelInfo.frame;
	end

	if not panelInfo or not inPanel then
		return;
	end

	panelInfo.buttonGroups = Utility.FindButtonGroups(inPanel, extraPanels);

	--Make sure to re-focus if we have a focused group
	if panelInfo.focusedKey then
		panelInfo.buttonGroups.focusedGroup = panelInfo.buttonGroups.subGroups[panelInfo.focusedKey];
	end
	if panelInfo.useGrid then
		self:UpdateGrid(panelInfo);
	end
end

function SmartNavigationMixin:UpdateParent(inChild)
	local parentFrame = self:GetParentPanelInfo(inChild);
	if parentFrame then
		self:RefreshButtonGroups(parentFrame.frame);
	end
end


function SmartNavigationMixin:AnchorDropDown(inDropDown)
	if self.currentButton and self:IsVisible() then
		local x, y = self.currentButton:GetCenter();

		if x > (self.xRes / 2) then
			local dropDownX = self.currentButton:GetLeft();
			local dropDownY = y;
			inDropDown:ClearAllPoints();
			inDropDown:SetPoint("RIGHT", UIParent, "BOTTOMLEFT", dropDownX - 220, dropDownY - 130);
		else
			local dropDownX = self.currentButton:GetRight();
			local dropDownY = y;
			inDropDown:ClearAllPoints();
			inDropDown:SetPoint("LEFT", UIParent, "BOTTOMLEFT", dropDownX + 220, dropDownY - 130);
		end
	end
end

function SmartNavigationMixin:GetCurrentButton()
	return self.currentButton;
end

function SmartNavigationMixin:IsCurrentButton(button)
	return self.currentButton == button;
end

function SmartNavigationMixin:GetCurrentButtonContext()
	local button = self:GetCurrentButton();
	return button and button.buttonContext or nil;
end

function SmartNavigationMixin:FindButton(inMatchFunc)
	local function CheckForMatch(buttons, matchFunc)
		local foundButton = nil;
		for _, button in ipairs(buttons) do
			if self:IsButtonValid(button) and matchFunc(button) then
				foundButton = button;
				break;
			end
		end

		return foundButton;
	end

	local foundButton = nil;

	if self.activeInfo then
		local activeGroup = self:GetActiveGroup(self.activeInfo);

		if activeGroup then
			foundButton = CheckForMatch(activeGroup.buttons, inMatchFunc);

			if not foundButton then
				for _, scrollInfo in ipairs(activeGroup.scrollFrames) do
					foundButton = CheckForMatch(scrollInfo.buttons, inMatchFunc);

					if foundButton then
						break;
					end
				end
			end
		end
	end

	return foundButton;
end

function SmartNavigationMixin:GetActiveFrame()
	if (self.activeInfo) then
		return self.activeInfo.frame
	end
end

function SmartNavigationMixin:SetIsHandlingInputEvents(handleInputEvents)
	self.IsHandlingInputEvents = handleInputEvents;
end

-- Specifying a focus group owner will set the active frame to the focus group owner and then enter the focus group.
function SmartNavigationMixin:EnterFocusGroup(inFocusKey, optionalFocusGroupOwner, button, scrollFrame)
	if (optionalFocusGroupOwner) then
		local focusGroupOwnerPanelInfo = self:GetPanelInfo(optionalFocusGroupOwner);
		self:SetActiveFrame(focusGroupOwnerPanelInfo);
	end

	if self.activeInfo then
		local buttonGroups = self.activeInfo.buttonGroups;

		local groupToFocus = buttonGroups.subGroups[inFocusKey];

		-- Don't refocus a group we already have focused.
		if (groupToFocus == buttonGroups.focusedGroup) then
			return;
		end

		buttonGroups.focusedGroup = groupToFocus;
		self.activeInfo.focusedKey = inFocusKey;
		self.activeInfo.lastButton = nil;
		if buttonGroups.focusedGroup then
			if button then
				self:SelectButton(button, scrollFrame);
			else
				self:SelectButton(self:FindTopLeftButton(self.activeInfo));
			end
			self:ShowCursor(true);
		end
	end
end

function SmartNavigationMixin:LeaveFocusGroup(button, scrollFrame)
	if self.activeInfo then
		self.activeInfo.buttonGroups.focusedGroup = nil;
		self.activeInfo.focusedKey = nil;

		if button then
			self:SelectButton(button, scrollFrame);
		else
			self:SelectFirstButton();
		end
	end
end

function SmartNavigationMixin:IsInFocusGroup()
	local inFocusGroup = false;
	if self.activeInfo then
		inFocusGroup = self.activeInfo.buttonGroups.focusedGroup ~= nil;
	end

	return inFocusGroup;
end

function SmartNavigationMixin:SetItemToBeDeleted(cursorType, ...)
	if cursorType == "item" then
		local itemID = ...;
		self.itemBeingDeleted = itemID;
	end
end

function SmartNavigationMixin:ClearItemToBeDeleted()
	self.itemBeingDeleted = nil;
end

--[[
	Specifies a function which gets called when the panelInfo table associated
	with the inFrame is removed the smart nav system in RemovePanelInfo.

	The callback function will be passed in the panelInfo table associated with
	the inFrame as its first parameter.
]]
function SmartNavigationMixin:SetSmartNavPanelInfoRemovedCallback(inFrame, callback)
	inFrame.smartNavPanelInfoRemovedCallback = callback;
end

--[[
	Specifies a function which gets called when a panelInfo table associated
	with the inFrame is created by the smart nav system in GetPanelInfo.

	The callback function will be passed in the panelInfo table associated with
	the inFrame as its first parameter.
]]
function SmartNavigationMixin:SetSmartNavPanelInfoAddedCallback(inFrame, callback)
	inFrame.smartNavPanelInfoAddedCallback = callback;
end

function SmartNavigationMixin:SetOverrideIconAtlas(atlas)
	self.Pointer.Icon.Cursor:SetAtlas(atlas, true);
end

function SmartNavigationMixin:ClearOverrideIconAtlas()
	self.Pointer.Icon.Cursor:SetAtlas("gamepad-largecursor", true);
end

function SmartNavigationMixin:SetCursorArtHorizontal()
	SetClampedTextureRotation(self.Pointer.Icon.Cursor, 0);
end

function SmartNavigationMixin:SetCursorArtVerical()
	SetClampedTextureRotation(self.Pointer.Icon.Cursor, 270);
end
