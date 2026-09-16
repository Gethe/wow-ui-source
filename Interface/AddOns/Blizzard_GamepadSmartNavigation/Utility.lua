local Utility = {};

-- The directional inputs smart nav can use
SMART_NAV_INPUT_DIRECTION =
{
	UP = { x = 0, y = 1, dirKey = "up" },
	DOWN = { x = 0, y = -1, dirKey = "down" },
	LEFT = { x = -1, y = 0, dirKey = "left" },
	RIGHT = { x = 1, y = 0, dirKey = "right" }
}

--All children of the frame will be ignored too
function SmartNavigation_MarkFrameIgnored(inFrame)
	inFrame.smartNavigationIgnored = true;
end

function SmartNavigation_ClearIgnoreStatus(inFrame)
	inFrame.smartNavigationIgnored = nil;
end

function SmartNavigation_IsFrameIgnored(frame)
	if not frame then
		return true;
	end

	if frame.smartNavigationIgnored == true or frame.smartNavigationIgnoredDontPropagate == true then
		return true;
	end

	-- If parent exists, only inherit if parent allows propagation
	local parent = frame:GetParent();
	if parent then
		if parent.smartNavigationIgnoredDontPropagate == true then
			return false;
		end

		return SmartNavigation_IsFrameIgnored(parent);
	end

	return false;
end

function SmartNavigation_MarkFrameFocusable(inFrame)
	inFrame.smartNavigationCanFocus = true;
end

function SmartNavigation_IsFrameFocusable(inFrame)
	return inFrame and inFrame.smartNavigationCanFocus == true;
end

--[[
	Unlike the Ignored mark, this mark indicates that the frame being
	marked should be ignored, but not the frame's children (unless
	the child itself is marked as ignored).
]]
function SmartNavigation_MarkFrameIgnoredContainerFrame(inFrame)
	inFrame.smartNavigationIgnoredContainerFrame = true;
end

function SmartNavigation_IsIgnoredContainerFrame(inFrame)
	return inFrame and inFrame.smartNavigationIgnoredContainerFrame;
end

function SmartNavigation_MarkFrameSubSection(inFrame, inFocusKey)
	inFrame.smartNavigationFocusKey = inFocusKey;
end

function SmartNavigation_SetDirectionBufferThreshold(inFrame, direction, degree)
	if (not inFrame or not direction) then
		return;
	end

	if (not inFrame.smartNavigationDirectionBufferData) then
		inFrame.smartNavigationDirectionBufferData = {};
	end
	inFrame.smartNavigationDirectionBufferData[direction] = degree * (math.pi / 180);
end

function SmartNavigation_IsFrameSubSection(inFrame)
	return inFrame and inFrame.smartNavigationFocusKey ~= nil;
end

function SmartNavigation_SetReturnFrameFocusButton(inButton)
	local activeFrame = GamepadMode.FrameControlsManager:GetActiveFrame();

	if (activeFrame.smartNavReturnFrame) then
		local returnFramePanelInfo = SmartNavigation:GetPanelInfo(activeFrame.smartNavReturnFrame, true);
		if (returnFramePanelInfo) then
			SmartNavigation:SetLastButtonForPanelInfo(returnFramePanelInfo, inButton);
		end
	end
end

function SmartNavigation_MarkFrameNonCollapsingScrollBoxElement(inFrame)
	inFrame.smartNavigationNonCollapsingScrollBoxElement = true;
end

function SmartNavigation_IsFrameNonCollapsingScrollBoxElement(inFrame)
	return inFrame and inFrame.smartNavigationNonCollapsingScrollBoxElement;
end

function SmartNavigation_SelectScrollBoxCurrentOrTop(scrollBox)
	local scrollBoxFrames = scrollBox:GetFrames();
	local index = scrollBox:GetScrollPercentage() == 0 and 1 or math.ceil(#scrollBoxFrames * 0.5);
	if not SmartNavigation_IsFrameFocusable(scrollBoxFrames[index]) then
		-- If the current frame is not focusable, assume it is a header and select the next one down.
		index = index + 1;
	end
	SmartNavigation:SelectButton(scrollBoxFrames[index]);
end

function SmartNavigation_MarkFrameBlockingSmartNavClick(inFrame)
	inFrame.blockSmartNavClick = true;
end

function SmartNavigation_IsFrameBlockingSmartNavClick(inFrame)
	return inFrame and inFrame.blockSmartNavClick;
end

function SmartNavigation_SetCustomCursorAnchorPointForFrame(inFrame, cursorAnchor)
	inFrame.smartNavigationCustomCursorAnchor = cursorAnchor;
end

--[[
	Informs the smart nav system that it should maintain the previous button when
	hiding the smart nav cursor to scroll the scroll frame.

	Implementation Note:
	This flag was added as a way to indicate to the smart nav scrolling system that the smart nav cursor
	should return to the currently focused element after scrolling rather than trying to find a frame in the
	scrollable content to focus on. This is primarily useful in handling cases where the
	currently focused element is related to the focused frame but not a part of it (it doesn't get found in the
	FindButtons function), and the scroll frame doesn't have any focusable content itself (like message text).
]]
function SmartNavigation_MarkScrollFrameMaintainPreviousButtonOnScroll(inScrollFrame)
	inScrollFrame.smartNavMaintainPreviousButtonOnScroll = true;
end

function SmartNavigation_ShouldScrollFrameMaintainPreviousButtonOnScroll(inScrollFrame)
	return inScrollFrame and inScrollFrame.smartNavMaintainPreviousButtonOnScroll;
end

function SmartNavigation_IsCurrentButtonClickable()
	local currentButton = SmartNavigation:GetCurrentButton();
	if (not currentButton) then
		return false;
	end

	local isEnabled = true;
	if (currentButton.IsEnabled) then
		isEnabled = currentButton:IsEnabled();
	end

	return isEnabled and (not SmartNavigation_IsFrameBlockingSmartNavClick(currentButton));
end

--[[
	Undo all smart nav customization applied to a frame, and optionally all its children.
]]
function SmartNavigation_ResetData(frame, recurse)
	frame.blockSmartNavClick = nil;
	frame.smartNavigationCanFocus = nil;
	frame.smartNavigationCustomCursorAnchor = nil;
	frame.smartNavigationDirectionBufferData = nil;
	frame.smartNavigationFocusKey = nil;
	frame.smartNavigationIgnored = nil;
	frame.smartNavigationIgnoredContainerFrame = nil;
	frame.smartNavigationIgnoredDontPropagate = nil;
	frame.smartNavigationNonCollapsingScrollBoxElement = nil;
	frame.smartNavigationVerticalCursor = nil;
	frame.smartNavData = nil;
	frame.smartNavMaintainPreviousButtonOnScroll = nil;
	frame.smartNavReturnFrame = nil;

	if recurse then
		for _, child in ipairs({frame:GetChildren()}) do
			SmartNavigation_ResetData(child, true);
		end
	end
end

--[[
	Returns whether smart nav could potentially focus the provided frame. This differs from
	SmartNavigation_IsFrameFocusable in that that function only says whether a call to
	SmartNavigation_MarkFrameFocusable has made it expressly focusable. This function only
	considers that as one of the factors.

	Note that this function does _not_ check for ignored frames, and that must be done separately
	using SmartNavigation_IsFrameIgnored.
]]
function SmartNavigation_CanFocusFrame(frame)
	local isButton = frame:IsObjectType("Button") or frame:IsObjectType("EditBox");
	local canFocus = SmartNavigation_IsFrameFocusable(frame);

	-- Check for things that act like buttons but are not...
	if not isButton then
		isButton = frame:GetScript("OnMouseUp") ~= nil or frame:GetScript("OnMouseDown") ~= nil;
	end

	return (isButton or canFocus) and frame:GetSize() and (not SmartNavigation_IsIgnoredContainerFrame(frame));
end

Utility.FindButtons = function(inFrame, extraPanels, includeInFrame)
	local buttonsFound = {};
	local scrollFramesFound = {};

	local function FindButtons(frame, foundButtons, inButton)
		if (SmartNavigation_IsFrameSubSection(frame) and frame ~= inFrame) then
			return;
		end

		if SmartNavigation_CanFocusFrame(frame) and (includeInFrame or frame ~= inFrame) then
			table.insert(foundButtons, frame);
		end

		local isScrollFrame = frame:IsObjectType("ScrollFrame") or frame.ScrollTarget ~= nil;
		local scrollInfo = nil;
		if isScrollFrame and not isButton then
			scrollInfo = { scrollFrame = frame, buttons = {} };
			table.insert(scrollFramesFound, scrollInfo);
		end

		local children = { frame:GetChildren() };

		if scrollInfo then
			for _, child in ipairs(children) do
				FindButtons(child, scrollInfo.buttons, isButton or inButton);
			end
		else
			for _, child in ipairs(children) do
				FindButtons(child, foundButtons, isButton or inButton);
			end
		end
	end

	FindButtons(inFrame, buttonsFound);

	if extraPanels then
		for _, panel in pairs(extraPanels) do
			FindButtons(panel, buttonsFound);
		end
	end

	-- Prevent duplicate buttons from being returned
	local uniqueButtons = {}
	for i = #buttonsFound, 1, -1 do
		if (not uniqueButtons[buttonsFound[i]]) then
			uniqueButtons[buttonsFound[i]] = true;
		else
			table.remove(buttonsFound, i);
		end
	end

	return buttonsFound, scrollFramesFound;
end

Utility.FindButtonGroups = function(inFrame, extraPanels)
	local buttonGroups = {};
	buttonGroups.mainGroup = {};
	buttonGroups.subGroups = {};

	local subSections = {};

	local function SearchForSubSections(frameToSearch)
		local children = { frameToSearch:GetChildren() };
		for _, child in ipairs(children) do
			if (SmartNavigation_IsFrameSubSection(child)) then
				table.insert(subSections, child);
			else
				SearchForSubSections(child);
			end
		end
	end

	SearchForSubSections(inFrame);

	buttonGroups.mainGroup.buttons, buttonGroups.mainGroup.scrollFrames = Utility.FindButtons(inFrame, extraPanels);

	for _, subSection in ipairs(subSections) do
		local subGroup = {};
		subGroup.buttons, subGroup.scrollFrames = Utility.FindButtons(subSection);

		buttonGroups.subGroups[subSection.smartNavigationFocusKey] = subGroup;
	end

	return buttonGroups;
end

function Utility.ForEachButtonInGroup(buttonGroup, cb)
	if not buttonGroup then
		return;
	end

	if buttonGroup.buttons then
		for _, button in ipairs(buttonGroup.buttons) do
			cb(button);
		end
	end

	if buttonGroup.scrollFrames then
		for _, scrollFrameGroup in ipairs(buttonGroup.scrollFrames) do
			for _, button in ipairs(scrollFrameGroup.buttons) do
				cb(button, scrollFrameGroup.scrollFrame);
			end
		end
	end
end

function Utility.ForEachScrollFrameInGroup(buttonGroup, cb)
	if not buttonGroup or not buttonGroup.scrollFrames then
		return;
	end

	for _, scrollFrameGroup in ipairs(buttonGroup.scrollFrames) do
		cb(scrollFrameGroup.scrollFrame);
	end
end

--[[
	Adds a custom jump navigation override to the navOverrideInfo's button. When the smart nav
	system is focused on the button and the specified input direction (SMART_NAV_INPUT_DIRECTION)
	is used, the overrideButton frame will be focused.

	button = The button that smart nav would be focusing on to trigger the override

	direction = The input direction that smart nav must use for the override to trigger.
				See SMART_NAV_INPUT_DIRECTION for valid arguments.

	overrideButton = The button that will be focused if the override is triggered. This
					 argument can either be a reference to the button frame or a function
					 that returns a reference to a button frame.
]]
function SmartNavigation_AddJumpNavigationOverride(button, direction, overrideButton)
	if (not button or not direction) then
		return;
	end

	if (not button.smartNavData) then
		button.smartNavData = {};
	end

	if (not button.smartNavData.navigationOverrides) then
		button.smartNavData.navigationOverrides = {};
	end

	button.smartNavData.navigationOverrides[direction.dirKey] = overrideButton;
end

--[[
	Adds a custom jump navigation override to both the source button and destination button. When the smart nav system
	is focused on the source button and the specified destination direction (SMART_NAV_INPUT_DIRECTION) is used, the
	destination button will be focused. When the smart nav system is focused on the destination and the specified source
	direction is used, the source button will be focused.

	sourceButton = The button that smart nav would be focused on to trigger the jump override to the destination
				   button / the button which is jumped to when the jump override is triggered when focused on the
				   destination button.

	destinationDir = The input direction that smart nav must use to jump to the destination button when focused on
					 the source button. See SMART_NAV_INPUT_DIRECTION for valid arguments.

	destinationButton = The button that is jumped to when the jump override is triggered when focused on the source
						button / the button that smart nav would be focused on to trigger the jump override to the
						source button.

	optionalSourceDir = The input direction that smart nav must use to jump to the source button when focused on the
						direction button. See SMART_NAV_INPUT_DIRECTION for valid arguments. If not specified the
						direction opposite of the destination direction will be used.
]]
function SmartNavigation_AddBidirectionalJumpNavigationOverride(sourceButton, destinationDir, destinationButton, optionalSourceDir)
	local sourceDir = optionalSourceDir;
	if (not sourceDir) then
		if (destinationDir == SMART_NAV_INPUT_DIRECTION.UP) then
			sourceDir = SMART_NAV_INPUT_DIRECTION.DOWN;
		elseif (destinationDir == SMART_NAV_INPUT_DIRECTION.DOWN) then
			sourceDir = SMART_NAV_INPUT_DIRECTION.UP;
		elseif (destinationDir == SMART_NAV_INPUT_DIRECTION.LEFT) then
			sourceDir = SMART_NAV_INPUT_DIRECTION.RIGHT;
		else
			sourceDir = SMART_NAV_INPUT_DIRECTION.LEFT;
		end
	end
	SmartNavigation_AddJumpNavigationOverride(sourceButton, destinationDir, destinationButton);
	SmartNavigation_AddJumpNavigationOverride(destinationButton, sourceDir, sourceButton);
end

--[[
	Clears all jump overrides set on the button, regardless of directional button
	the jump override is tied to.

	button = The button that smart nav would be focusing on to trigger the override
]]
function SmartNavigation_ClearJumpNavigationOverrides(button)
	if (not button or not button.smartNavData) then
		return;
	end

	button.smartNavData.navigationOverrides = nil;
end

--[[
	Clears the custom jump navigation override for a given direction. When the smart nav
	system is focused on the button and the specified input direction (SMART_NAV_INPUT_DIRECTION)
	is used, the default behavior will be used instead of any override previously set.

	button = The button that smart nav would be focusing on to trigger the override

	direction = The input direction to clear the override.
				See SMART_NAV_INPUT_DIRECTION for valid arguments.
]]
function SmartNavigation_ClearJumpNavigationOverridesInDirection(button, direction)
	if (not button or not direction -- Validate arguments are not nil.
		or not button.smartNavData -- Validates that the button is registered by Smart Navigation.
		or not button.smartNavData.navigationOverrides) then -- Validates that there are overrides.
		return;
	end

	button.smartNavData.navigationOverrides[direction.dirKey] = nil;
end

--[[
	Adds a smart navigation override to the navOverrideInfo's button such that when the
	specified input direction is used when the button is focused the smart nav system will
	not attempt to navigate in that direction.

	button = The button that smart nav would be focusing on to trigger the override

	direction = The input direction that smart nav must use for the override to trigger.
				See SMART_NAV_INPUT_DIRECTION for valid arguments.
]]
function SmartNavigation_AddIgnoreInputNavigationOverride(button, direction)
	if (not button or not direction) then
		return;
	end

	if (not button.smartNavData) then
		button.smartNavData = {};
	end

	if (not button.smartNavData.navigationOverrides) then
		button.smartNavData.navigationOverrides = {};
	end

	button.smartNavData.navigationOverrides[direction.dirKey] = { shouldIgnoreInputNavOverride = true };
end

--[[
	Returns the overrideButton that was specified when setting up the navigation override for the button.

	For jump navigation overrides that were setup with a function instead of a button reference, the function
	will be called first and its return value will be returned.

	For navigation overrides that were setup using the SmartNavigation_AddIgnoreInputNavigationOverride
	function a table containing a shouldIgnoreInputNavOverride key set to true will be returned.

	button = The button which we will return the navigation override for
	direction = The directional override we are requesting from the frame. (SMART_NAV_INPUT_DIRECTION)
]]
function SmartNavigation_GetNavigationOverrideFrame(button, direction)
	if (not button or not direction or not button.smartNavData or not button.smartNavData.navigationOverrides) then
		return;
	end

	local navOverride = button.smartNavData.navigationOverrides[direction.dirKey];
	if (type(navOverride) == "function") then
		return navOverride();
	end
	return navOverride;
end

--[[
	Registers a function to be called when the specified button is focused by smart nav and
	a successful navigation off of the button in the specified direction occurs.

	button = The button which must be focused on by smart nav for the registered function
			 to be called.

	direction = The outgoing direction we are registering a navigation event function for.
				See SMART_NAV_INPUT_DIRECTION.

	callback = The function that will be called when the focused button successfully is
			   navigated off of in the passed in direction.
]]
function SmartNavigation_RegisterOutgoingDirNavCallback(button, direction, callback)
	if (not button or not direction) then
		return;
	end

	if (not button.smartNavData) then
		button.smartNavData = {};
	end

	if (not button.smartNavData.navigationCallbacks) then
		button.smartNavData.navigationCallbacks = {};
	end

	local callbackTable = button.smartNavData.navigationCallbacks[direction.dirKey];
	if (callbackTable) then
		table.insert(callbackTable, callback);
	else
		button.smartNavData.navigationCallbacks[direction.dirKey] = { callback };
	end
end

--[[
	Provides a multi directional method of registering for outgoing directional
	navigation callbaks. See SmartNavigation_RegisterOutgoingDirNavCallback.
]]
function SmartNavigation_RegisterOutgoingNavCallback_MultiDir(button, directions, callback)
	if (not button or not directions) then
		return;
	end

	for _, direction in ipairs(directions) do
		SmartNavigation_RegisterOutgoingDirNavCallback(button, direction, callback);
	end
end

--[[
	Calls the button's outgoing navigation callback functions registered to the passed in
	navigation direction.

	button = The button that contains the registered function data
	direction = The direction that the registered functions should be called for. See
				SMART_NAV_INPUT_DIRECTION.
]]
function SmartNavigation_CallOutgoingDirNavigationCallbacks(button, direction)
	if (not button or not direction or not button.smartNavData or not button.smartNavData.navigationCallbacks) then
		return;
	end

	local navigationCallbacks = button.smartNavData.navigationCallbacks;
	if (navigationCallbacks and navigationCallbacks[direction.dirKey]) then
		if #navigationCallbacks[direction.dirKey] > 0 then
			for _, callback in ipairs(navigationCallbacks[direction.dirKey]) do
				callback();
			end
		end
	end
end

function SmartNavigation_UseVerticalCursorForFrame(inFrame)
	inFrame.smartNavigationVerticalCursor = true;
end

return Utility;
