------------------------
-- Action Bar Styling --
------------------------
local gamepadActionBarStyleInfo = {};
local GamepadActionBarStyleInfoMixin = {};
local ACTION_BAR_GROUPS = { LEFT = "leftGroup", RIGHT = "rightGroup" };
local ACTION_BUTTONS = { LEFT = 1, TOP = 2, RIGHT = 3, BOTTOM = 4 };
local ACTION_STATES = { NORMAL = "NORMAL", PUSHED = "PUSHED" };
local FOCUS_STATES = { COLLAPSED = 1, EXPANDED = 2 };
local LEFTSQUARE_RIGHTCIRCLE_STYLE = 0;
local ACTION_BAR_BUTTON_PRESSED_SIZE_OFFSET = -4;
local ACTION_BAR_BUTTON_PRESSED_ANCHOR_OFFSET = { x=0, y=math.round(ACTION_BAR_BUTTON_PRESSED_SIZE_OFFSET * 0.5) };
local FocusFX = require('.ActionBarFocusFX');

GamepadActionBarStyleUtil = {};

GamepadActionBarStyleUtil.ACTION_STATES = ACTION_STATES;
GamepadActionBarStyleUtil.FOCUS_STATES = FOCUS_STATES;
GamepadActionBarStyleUtil.CIRCULAR_BUTTON_COLLAPSED_SIZE = 30;
GamepadActionBarStyleUtil.CIRCULAR_BUTTON_EXPANDED_SIZE = 38;
GamepadActionBarStyleUtil.SQUARE_BUTTON_COLLAPSED_SIZE = 32;
GamepadActionBarStyleUtil.SQUARE_BUTTON_EXPANDED_SIZE = 40;
GamepadActionBarStyleUtil.PUSHED_BUTTON_ANCHOR_OFFSET = ACTION_BAR_BUTTON_PRESSED_ANCHOR_OFFSET;
GamepadActionBarStyleUtil.PUSHED_BUTTON_SIZE_OFFSET = ACTION_BAR_BUTTON_PRESSED_SIZE_OFFSET

local function CreateGroupInfoTable(styleObj, groupKey)
	styleObj[groupKey] = {};

	for _, value in pairs(ACTION_BUTTONS) do
		styleObj[groupKey][value] = {
			[FOCUS_STATES.COLLAPSED] = { anchorInfo={} },
			[FOCUS_STATES.EXPANDED] = { anchorInfo={} },
		};
	end
end

function GamepadActionBarStyleInfoMixin:Init(style)
	gamepadActionBarStyleInfo[style] = self;

	CreateGroupInfoTable(self, ACTION_BAR_GROUPS.LEFT);
	CreateGroupInfoTable(self, ACTION_BAR_GROUPS.RIGHT);

	self.applyCollapsedButtonStyle = nop;
	self.applyExpandedButtonStyle = nop;
	self.applyExpandedButtonIconStyle = nop;
	self.actionBarSizes = {};
	self.focusSequenceMixins = {};
	self.shadowDistances = {};
end

function GamepadActionBarStyleInfoMixin:GetLeftGroupInfo()
	return self[ACTION_BAR_GROUPS.LEFT];
end

function GamepadActionBarStyleInfoMixin:GetRightGroupInfo()
	return self[ACTION_BAR_GROUPS.RIGHT];
end

function GamepadActionBarStyleInfoMixin:GetGroupInfo(group)
	return self[group];
end

function GamepadActionBarStyleInfoMixin:SetButtonAnchorInfo(focusState, group, buttonIndex, xOffset, yOffset)
	local groupInfo = self:GetGroupInfo(group);
	local anchorInfo = groupInfo[buttonIndex][focusState].anchorInfo;
	anchorInfo.x = xOffset;
	anchorInfo.y = yOffset;
end

function GamepadActionBarStyleInfoMixin:SetShadowDistance(focusState, value)
	self.shadowDistances[focusState] = value;
end

function GamepadActionBarStyleInfoMixin:SetCheckedDistance(value)
	self.checkedDistance = value;
end

function GamepadActionBarStyleInfoMixin:SetSequenceMixin(focusState, mixin)
	self.focusSequenceMixins[focusState] = mixin;
end

function GamepadActionBarStyleInfoMixin:SetActionBarSize(focusState, width, height)
	self.actionBarSizes[focusState] = { width, height };
end

function GamepadActionBarStyleInfoMixin:SetFunc_ApplyExpandedButtonIconStyle(func)
	self.applyExpandedButtonIconStyle = func;
end

function GamepadActionBarStyleInfoMixin:SetFunc_ApplyCollapsedButtonStyle(func)
	self.applyCollapsedButtonStyle = func;
end

function GamepadActionBarStyleInfoMixin:SetFunc_ApplyExpandedButtonStyle(func)
	self.applyExpandedButtonStyle = func;
end

function GamepadActionBarStyleUtil.ApplyCollapsedActionBarStyle(actionBar, style)
	actionBar.appliedStyle = style;
	local styleInfo = gamepadActionBarStyleInfo[style];

	styleInfo:applyCollapsedButtonStyle(actionBar);
end

function GamepadActionBarStyleUtil.ApplyExpandedActionBarStyle(actionBar, style)
	actionBar.appliedStyle = style;
	local styleInfo = gamepadActionBarStyleInfo[style];

	styleInfo:applyExpandedButtonStyle(actionBar);
	styleInfo:applyExpandedButtonIconStyle(actionBar);
end

function GamepadActionBarStyleUtil.ApplyExtraButtonStyles(
	button,
	actionState,	-- ACTION_STATES
	focusState,		-- FOCUS_STATES
	styleParams,	-- { expandedSize=?, collapsedSize=?, shapeMethod=? }
	anchorInfo		-- { relativeTo=?, x=?, y=? }
)
	local buttonSize = styleParams.collapsedSize;
	local expandOrCollapseMethod = "Collapse";
	local anchorParent = anchorInfo.relativeTo or button:GetParent();
	local anchorOffsetX = anchorInfo.x or 0;
	local anchorOffsetY = anchorInfo.y or 0;

	if actionState == ACTION_STATES.PUSHED then
		anchorOffsetX = anchorOffsetX + GamepadActionBarStyleUtil.PUSHED_BUTTON_ANCHOR_OFFSET.x;
		anchorOffsetY = anchorOffsetY + GamepadActionBarStyleUtil.PUSHED_BUTTON_ANCHOR_OFFSET.y;
		buttonSize = buttonSize + GamepadActionBarStyleUtil.PUSHED_BUTTON_SIZE_OFFSET;
	end

	if focusState == FOCUS_STATES.EXPANDED then
		buttonSize = styleParams.expandedSize;
		expandOrCollapseMethod = "Expand";
	end

	button[styleParams.shapeMethod](button);
	button:SetSize(buttonSize, buttonSize);
	button:ClearAllPoints();
	button:SetPoint("CENTER", anchorParent, "CENTER", anchorOffsetX, anchorOffsetY);
	button[expandOrCollapseMethod](button);
end

GamepadActionBarStyleUtil.circleStyleParams = {
	shapeMethod = "SetShapeToCircle",
	collapsedSize = 30,
	expandedSize = 38,
};

GamepadActionBarStyleUtil.squareStyleParams = {
	shapeMethod = "SetShapeToSquare",
	collapsedSize = 32,
	expandedSize = 40,
};

local leftSquareRightCircleStyleInfo = CreateAndInitFromMixin(GamepadActionBarStyleInfoMixin, LEFTSQUARE_RIGHTCIRCLE_STYLE);

leftSquareRightCircleStyleInfo:SetActionBarSize(FOCUS_STATES.COLLAPSED, 208, 68);
leftSquareRightCircleStyleInfo:SetActionBarSize(FOCUS_STATES.EXPANDED, 266, 86);
leftSquareRightCircleStyleInfo:SetShadowDistance(FOCUS_STATES.COLLAPSED, 4);
leftSquareRightCircleStyleInfo:SetShadowDistance(FOCUS_STATES.EXPANDED, 13);
leftSquareRightCircleStyleInfo:SetSequenceMixin(FOCUS_STATES.COLLAPSED, FocusFX.GamepadActionBarSequenceGameplayCollapseMixin);
leftSquareRightCircleStyleInfo:SetSequenceMixin(FOCUS_STATES.EXPANDED, FocusFX.GamepadActionBarSequenceGameplayExpandMixin);
leftSquareRightCircleStyleInfo:SetCheckedDistance(4);

leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.COLLAPSED, ACTION_BAR_GROUPS.LEFT, ACTION_BUTTONS.TOP, -58, 17);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.COLLAPSED, ACTION_BAR_GROUPS.LEFT, ACTION_BUTTONS.BOTTOM, -58, -17);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.COLLAPSED, ACTION_BAR_GROUPS.LEFT, ACTION_BUTTONS.LEFT, -92, 0);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.COLLAPSED, ACTION_BAR_GROUPS.LEFT, ACTION_BUTTONS.RIGHT, -24, 0);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.COLLAPSED, ACTION_BAR_GROUPS.RIGHT, ACTION_BUTTONS.TOP, 55, 18);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.COLLAPSED, ACTION_BAR_GROUPS.RIGHT, ACTION_BUTTONS.BOTTOM, 55, -18);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.COLLAPSED, ACTION_BAR_GROUPS.RIGHT, ACTION_BUTTONS.LEFT, 25, 0);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.COLLAPSED, ACTION_BAR_GROUPS.RIGHT, ACTION_BUTTONS.RIGHT, 85, 0);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.EXPANDED, ACTION_BAR_GROUPS.LEFT, ACTION_BUTTONS.TOP, -75, 23);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.EXPANDED, ACTION_BAR_GROUPS.LEFT, ACTION_BUTTONS.BOTTOM, -75, -23);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.EXPANDED, ACTION_BAR_GROUPS.LEFT, ACTION_BUTTONS.LEFT, -119, 0);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.EXPANDED, ACTION_BAR_GROUPS.LEFT, ACTION_BUTTONS.RIGHT, -31, 0);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.EXPANDED, ACTION_BAR_GROUPS.RIGHT, ACTION_BUTTONS.TOP, 70, 23);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.EXPANDED, ACTION_BAR_GROUPS.RIGHT, ACTION_BUTTONS.BOTTOM, 70, -23);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.EXPANDED, ACTION_BAR_GROUPS.RIGHT, ACTION_BUTTONS.LEFT, 32, 0);
leftSquareRightCircleStyleInfo:SetButtonAnchorInfo(FOCUS_STATES.EXPANDED, ACTION_BAR_GROUPS.RIGHT, ACTION_BUTTONS.RIGHT, 108, 0);

leftSquareRightCircleStyleInfo:SetFunc_ApplyExpandedButtonStyle(
	function(self, actionBar)
		local actionBarSize = self.actionBarSizes[FOCUS_STATES.EXPANDED];
		actionBar:SetSize(unpack(actionBarSize));
		actionBar.LeftButtonFrame:Hide();
		actionBar.RightButtonFrame:Hide();

		local leftGroupInfo = self:GetLeftGroupInfo();
		local rightGroupInfo = self:GetRightGroupInfo();

		for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP do
			local actionButtonName = "ActionButton" .. i;
			local leftButton = actionBar.Left[actionButtonName];
			local rightButton = actionBar.Right[actionButtonName];
			local buttonIndex = i;

			-- Left group
			leftButton.ApplyExtraButtonStylesForState = function(button, state)
				local anchorInfo = leftGroupInfo[buttonIndex][FOCUS_STATES.EXPANDED].anchorInfo;
				GamepadActionBarStyleUtil.ApplyExtraButtonStyles(
					button,
					state,
					FOCUS_STATES.EXPANDED,
					GamepadActionBarStyleUtil.squareStyleParams,
					{ relativeTo=actionBar, x=anchorInfo.x, y=anchorInfo.y });
			end

			leftButton:ApplyExtraButtonStylesForState(leftButton:GetButtonState());

			-- Right group
			rightButton.ApplyExtraButtonStylesForState = function(button, state)
				local anchorInfo = rightGroupInfo[buttonIndex][FOCUS_STATES.EXPANDED].anchorInfo;
				GamepadActionBarStyleUtil.ApplyExtraButtonStyles(
					button,
					state,
					FOCUS_STATES.EXPANDED,
					GamepadActionBarStyleUtil.circleStyleParams,
					{ relativeTo=actionBar, x=anchorInfo.x, y=anchorInfo.y });
			end

			rightButton:ApplyExtraButtonStylesForState(rightButton:GetButtonState());

			if actionBar.showCheckedStateOnOnExpand then
				local highestPriorityDisplay = not (leftButton.PermaboundOverlay and leftButton.PermaboundOverlay:IsShown());
				leftButton.CheckedTexture:SetShown(highestPriorityDisplay);

				highestPriorityDisplay = not (rightButton.PermaboundOverlay and rightButton.PermaboundOverlay:IsShown());
				rightButton.CheckedTexture:SetShown(highestPriorityDisplay);
			end
		end

		if (actionBar.BackgroundWatermark) then
			actionBar.BackgroundWatermark:SetSize(250, 115);
			actionBar.BackgroundWatermark:SetPoint("CENTER", actionBar, "CENTER", 0, -10);
		end

		if actionBar.collapseSequence and actionBar.collapseSequence:IsPlaying() then
			actionBar.collapseSequence:Stop();
		end

		if not actionBar.expandSequence then
			local sequence = self.focusSequenceMixins[FOCUS_STATES.EXPANDED];
			actionBar:SetExpandSequence(CreateAndInitFromMixin(sequence, actionBar));
		end

		if not actionBar.expandSequence:IsPlaying() then
			actionBar.expandSequence:Start();
		end
	end
);

leftSquareRightCircleStyleInfo:SetFunc_ApplyCollapsedButtonStyle(
	function(self, actionBar)
		local actionBarSize = self.actionBarSizes[FOCUS_STATES.COLLAPSED];
		actionBar:SetSize(unpack(actionBarSize));
		actionBar.LeftButtonFrame:Hide();
		actionBar.RightButtonFrame:Hide();

		local leftGroupInfo = self:GetLeftGroupInfo();
		local rightGroupInfo = self:GetRightGroupInfo();

		for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP do
			local actionButtonName = "ActionButton" .. i;
			local leftButton = actionBar.Left[actionButtonName];
			local rightButton = actionBar.Right[actionButtonName];
			local buttonIndex = i;

			-- Left group
			leftButton.ApplyExtraButtonStylesForState = function(button, state)
				local anchorInfo = leftGroupInfo[buttonIndex][FOCUS_STATES.COLLAPSED].anchorInfo;
				GamepadActionBarStyleUtil.ApplyExtraButtonStyles(
					button,
					state,
					FOCUS_STATES.COLLAPSED,
					GamepadActionBarStyleUtil.squareStyleParams,
					{ relativeTo=actionBar, x=anchorInfo.x, y=anchorInfo.y });
			end

			leftButton:ApplyExtraButtonStylesForState(leftButton:GetButtonState());

			-- Right group
			rightButton.ApplyExtraButtonStylesForState = function(button, state)
				local anchorInfo = rightGroupInfo[buttonIndex][FOCUS_STATES.COLLAPSED].anchorInfo;
				GamepadActionBarStyleUtil.ApplyExtraButtonStyles(
					button,
					state,
					FOCUS_STATES.COLLAPSED,
					GamepadActionBarStyleUtil.circleStyleParams,
					{ relativeTo=actionBar, x=anchorInfo.x, y=anchorInfo.y });
			end

			rightButton:ApplyExtraButtonStylesForState(rightButton:GetButtonState());

			rightButton.CircleShadow:Show();
			rightButton.CircleShadowFocus:Hide();
			leftButton.SquareShadow:Show();
			leftButton.SquareShadowFocus:Hide();

			-- Right only needs to update circle, left only needs to update square.
			local shadowDistance = self.shadowDistances[FOCUS_STATES.COLLAPSED];
			rightButton.CircleShadow:SetPoint("TOPLEFT", -shadowDistance, shadowDistance);
			rightButton.CircleShadow:SetPoint("BOTTOMRIGHT", shadowDistance, -shadowDistance);
			leftButton.SquareShadow:SetPoint("TOPLEFT", -shadowDistance, shadowDistance);
			leftButton.SquareShadow:SetPoint("BOTTOMRIGHT", shadowDistance, -shadowDistance);
		end

		local identifierIconWidth = 30;
		local identifierIconHeight = 30;
		local identifierAnchorXOffset = 0;
		local identifierAnchorYOffset = 38;
		actionBar.IdentifierIcon:SetSize(identifierIconWidth, identifierIconHeight);
		actionBar.IdentifierIcon:ClearAllPoints();
		actionBar.IdentifierIcon:SetPoint("CENTER", actionBar, "CENTER", identifierAnchorXOffset, identifierAnchorYOffset);

		if (actionBar.BackgroundWatermark) then
			actionBar.BackgroundWatermark:SetSize(210, 92);
			actionBar.BackgroundWatermark:SetPoint("CENTER", actionBar, "CENTER", 0, -10);
		end

		if actionBar.modifierIcon and actionBar.modifierIcon.SetPressable then
			actionBar.modifierIcon:SetPressable();
		end

		if actionBar.expandSequence and actionBar.expandSequence:IsPlaying() then
			actionBar.expandSequence:Stop();
		end

		if not actionBar.collapseSequence then
			local sequence = self.focusSequenceMixins[FOCUS_STATES.COLLAPSED];
			actionBar:SetCollapseSequence(CreateAndInitFromMixin(sequence, actionBar));
		end
		if not actionBar.collapseSequence:IsPlaying() then
			actionBar.collapseSequence:Start();
		end
	end
);

leftSquareRightCircleStyleInfo:SetFunc_ApplyExpandedButtonIconStyle(
	function(self, actionBar)
		local BUTTON_ICON_WIDTH = 15;
		local BUTTON_ICON_HEIGHT = 15;
		local RIGHT_SIDE_ICON_Y_OFFSET = -3;

		for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP do
			local actionButton = "ActionButton" .. i;
			local leftButton = actionBar.Left[actionButton];
			local rightButton = actionBar.Right[actionButton];
			local leftButtonIcon = leftButton.ButtonIcon;
			local rightButtonIcon = rightButton.ButtonIcon;

			leftButtonIcon:ClearAllPoints();
			rightButtonIcon:ClearAllPoints();
			leftButtonIcon:SetSize(BUTTON_ICON_WIDTH, BUTTON_ICON_HEIGHT);
			rightButtonIcon:SetSize(BUTTON_ICON_WIDTH, BUTTON_ICON_HEIGHT);
			leftButtonIcon:SetPoint("TOPRIGHT", -1, -1);
			rightButtonIcon:SetPoint("TOPRIGHT", 0, RIGHT_SIDE_ICON_Y_OFFSET);

			local checkedDistance = self.checkedDistance;
			leftButton.CheckedTexture:SetPoint("TOPLEFT", -checkedDistance, checkedDistance);
			leftButton.CheckedTexture:SetPoint("BOTTOMRIGHT", checkedDistance, -checkedDistance);
			rightButton.CheckedTexture:SetPoint("TOPLEFT", -checkedDistance, checkedDistance);
			rightButton.CheckedTexture:SetPoint("BOTTOMRIGHT", checkedDistance, -checkedDistance);

			rightButton.CircleShadow:Hide();
			rightButton.CircleShadowFocus:Show();
			leftButton.SquareShadow:Hide();
			leftButton.SquareShadowFocus:Show();

			-- Right only needs to update circle, left only needs to update square.
			local shadowDistance = self.shadowDistances[FOCUS_STATES.EXPANDED];
			rightButton.CircleShadowFocus:SetPoint("TOPLEFT", -shadowDistance, shadowDistance);
			rightButton.CircleShadowFocus:SetPoint("BOTTOMRIGHT", shadowDistance, -shadowDistance);
			leftButton.SquareShadowFocus:SetPoint("TOPLEFT", -shadowDistance, shadowDistance);
			leftButton.SquareShadowFocus:SetPoint("BOTTOMRIGHT", shadowDistance, -shadowDistance);

			if actionBar.showCheckedStateOnOnExpand then
				local highestPriorityDisplay = not (leftButton.PermaboundOverlay and leftButton.PermaboundOverlay:IsShown());
				leftButton.CheckedTexture:SetShown(highestPriorityDisplay);

				highestPriorityDisplay = not (rightButton.PermaboundOverlay and rightButton.PermaboundOverlay:IsShown());
				rightButton.CheckedTexture:SetShown(highestPriorityDisplay);
			end
		end

		local identifierIconWidth = 35;
		local identifierIconHeight = 35;
		local identifierAnchorXOffset = 0;
		local identifierAnchorYOffset = 48;
		actionBar.IdentifierIcon:SetSize(identifierIconWidth, identifierIconHeight);
		actionBar.IdentifierIcon:ClearAllPoints();
		actionBar.IdentifierIcon:SetPoint("CENTER", actionBar, "CENTER", identifierAnchorXOffset, identifierAnchorYOffset);

		if actionBar.modifierIcon and actionBar.modifierIcon.SetFocused then
			actionBar.modifierIcon:SetFocused();
		end
	end
);
