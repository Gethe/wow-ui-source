------------------------
-- Action Bar Styling --
------------------------
local gamepadActionBarStyleInfo = {};
local GamepadActionBarStyleInfoMixin = {};
local ACTION_BAR_GROUPS = { LEFT = "leftGroup", RIGHT = "rightGroup" };
local ACTION_BUTTONS = { LEFT = 1, TOP = 2, RIGHT = 3, BOTTOM = 4 };
local ACTION_STATES = { NORMAL = "NORMAL", PUSHED = "PUSHED"};
local LEFTSQUARE_RIGHTCIRCLE_STYLE = 0;
local ACTION_BAR_BUTTON_PRESSED_SIZE_OFFSET = 4;
local FocusFX = require('.ActionBarFocusFX');

GamepadActionBarStyleUtil = {};

local function CreateGroupInfoTable(styleObj, groupKey)
	styleObj[groupKey] = {};

	for _, state in pairs(ACTION_STATES) do
		styleObj[groupKey][state] = {};
		for _, value in pairs(ACTION_BUTTONS) do
			styleObj[groupKey][state][value] = { collapsedButtonInfo = {}, expandedButtonInfo = {} };
		end
	end
end

function GamepadActionBarStyleInfoMixin:Init(style)
	gamepadActionBarStyleInfo[style] = self;

	CreateGroupInfoTable(self, "leftGroup");
	CreateGroupInfoTable(self, "rightGroup");

	local emptyFunc = function() end;

	self.applyCollapsedButtonStyle = emptyFunc;
	self.applyExpandedButtonStyle = emptyFunc;
	self.applyExpandedButtonIconStyle = emptyFunc;
end

function GamepadActionBarStyleInfoMixin:GetLeftGroupInfo()
	return self.leftGroup;
end

function GamepadActionBarStyleInfoMixin:GetRightGroupInfo()
	return self.rightGroup;
end

function GamepadActionBarStyleInfoMixin:GetGroupInfo(group)
	return self[group];
end

function GamepadActionBarStyleInfoMixin:SetCollapsedButtonAnchorInfo(group, state, buttonIndex, point, relativePoint, xOffset, yOffset)
	local groupInfo = self:GetGroupInfo(group);
	local groupButtonCollapsedInfo = groupInfo[state][buttonIndex].collapsedButtonInfo;

	groupButtonCollapsedInfo.point = point;
	groupButtonCollapsedInfo.relativePoint = relativePoint;
	groupButtonCollapsedInfo.xOffset = xOffset;
	groupButtonCollapsedInfo.yOffset = yOffset;
end

function GamepadActionBarStyleInfoMixin:SetExpandedButtonAnchorInfo(group, state, buttonIndex, point, relativePoint, xOffset, yOffset)
	local groupInfo = self:GetGroupInfo(group);
	local groupButtonExpandedInfo = groupInfo[state][buttonIndex].expandedButtonInfo;

	groupButtonExpandedInfo.point = point;
	groupButtonExpandedInfo.relativePoint = relativePoint;
	groupButtonExpandedInfo.xOffset = xOffset;
	groupButtonExpandedInfo.yOffset = yOffset;
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

function GamepadActionBarStyleInfoMixin:SetCollapsedButtonStyleSizing(group, state, width, height)
	self[group][state].collapsedButtonWidth = width;
	self[group][state].collapsedButtonHeight = height;
end

function GamepadActionBarStyleInfoMixin:SetExpandedButtonStyleSizing(group, state, width, height)
	self[group][state].expandedButtonWidth = width;
	self[group][state].expandedButtonHeight = height;
end

function GamepadActionBarStyleInfoMixin:SetCollapsedActionBarSize(width, height)
	self.collapsedActionBarWidth = width;
	self.collapsedActionBarHeight = height;
end

function GamepadActionBarStyleInfoMixin:SetExpandedActionBarSize(width, height)
	self.expandedActionBarWidth = width;
	self.expandedActionBarHeight = height;
end

function GamepadActionBarStyleInfoMixin:SetCollapsedButtonScale(scale)
	self.collapsedButtonScale = scale;
end

function GamepadActionBarStyleInfoMixin:SetExpandedButtonScale(scale)
	self.expandedButtonScale = scale;
end

function GamepadActionBarStyleInfoMixin:SetCollapsedShadowDistance(value)
	self.collapsedShadowDistance = value;
end

function GamepadActionBarStyleInfoMixin:SetExpandedShadowDistance(value)
	self.expandedShadowDistance = value;
end

function GamepadActionBarStyleInfoMixin:SetCheckedDistance(value)
	self.checkedDistance = value;
end

function GamepadActionBarStyleInfoMixin:SetExpandSequenceMixin(mixin)
	self.expandSequenceMixin = mixin;
end

function GamepadActionBarStyleInfoMixin:SetCollapseSequenceMixin(mixin)
	self.collapseSequenceMixin = mixin;
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

local leftSquareRightCircleStyleInfo = CreateAndInitFromMixin(GamepadActionBarStyleInfoMixin, LEFTSQUARE_RIGHTCIRCLE_STYLE);

local pushOffset = ACTION_BAR_BUTTON_PRESSED_SIZE_OFFSET;
local pushOffsetHalf = Round(ACTION_BAR_BUTTON_PRESSED_SIZE_OFFSET * 0.5);
leftSquareRightCircleStyleInfo:SetCollapsedActionBarSize(208, 68);
leftSquareRightCircleStyleInfo:SetCollapsedButtonScale(1);
leftSquareRightCircleStyleInfo:SetCollapsedButtonStyleSizing(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.NORMAL, 30, 30);
leftSquareRightCircleStyleInfo:SetCollapsedButtonStyleSizing(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.PUSHED, 30 - pushOffset, 30 - pushOffset);
leftSquareRightCircleStyleInfo:SetCollapsedButtonStyleSizing(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.NORMAL, 32, 32);
leftSquareRightCircleStyleInfo:SetCollapsedButtonStyleSizing(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.PUSHED, 32 - pushOffset, 32 - pushOffset);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.NORMAL, ACTION_BUTTONS.TOP, "CENTER", "CENTER", -58, 17);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.PUSHED, ACTION_BUTTONS.TOP, "CENTER", "CENTER", -58, 17 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.NORMAL, ACTION_BUTTONS.BOTTOM, "CENTER", "CENTER", -58, -17);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.PUSHED, ACTION_BUTTONS.BOTTOM, "CENTER", "CENTER", -58, -17 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.NORMAL, ACTION_BUTTONS.LEFT, "CENTER", "CENTER", -92, 0);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.PUSHED, ACTION_BUTTONS.LEFT, "CENTER", "CENTER", -92, 0 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.NORMAL, ACTION_BUTTONS.RIGHT, "CENTER", "CENTER", -24, 0);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.PUSHED, ACTION_BUTTONS.RIGHT, "CENTER", "CENTER", -24, 0 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.NORMAL, ACTION_BUTTONS.TOP, "CENTER", "CENTER", 55, 18);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.PUSHED, ACTION_BUTTONS.TOP, "CENTER", "CENTER", 55, 18 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.NORMAL, ACTION_BUTTONS.BOTTOM, "CENTER", "CENTER", 55, -18);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.PUSHED, ACTION_BUTTONS.BOTTOM, "CENTER", "CENTER", 55, -18 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.NORMAL, ACTION_BUTTONS.LEFT, "CENTER", "CENTER", 25, 0);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.PUSHED, ACTION_BUTTONS.LEFT, "CENTER", "CENTER", 25, 0 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.NORMAL, ACTION_BUTTONS.RIGHT, "CENTER", "CENTER", 85, 0);
leftSquareRightCircleStyleInfo:SetCollapsedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.PUSHED, ACTION_BUTTONS.RIGHT, "CENTER", "CENTER", 85, 0 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetCollapsedShadowDistance(4);

leftSquareRightCircleStyleInfo:SetExpandedActionBarSize(266, 86);
leftSquareRightCircleStyleInfo:SetExpandedButtonScale(1);
leftSquareRightCircleStyleInfo:SetExpandedButtonStyleSizing(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.NORMAL, 38, 38);
leftSquareRightCircleStyleInfo:SetExpandedButtonStyleSizing(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.PUSHED, 38 - pushOffset, 38 - pushOffset);
leftSquareRightCircleStyleInfo:SetExpandedButtonStyleSizing(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.NORMAL, 40, 40);
leftSquareRightCircleStyleInfo:SetExpandedButtonStyleSizing(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.PUSHED, 40 - pushOffset, 40 - pushOffset);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.NORMAL, ACTION_BUTTONS.TOP, "CENTER", "CENTER", -75, 23);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.PUSHED, ACTION_BUTTONS.TOP, "CENTER", "CENTER", -75, 23 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.NORMAL, ACTION_BUTTONS.BOTTOM, "CENTER", "CENTER", -75, -23);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.PUSHED, ACTION_BUTTONS.BOTTOM, "CENTER", "CENTER", -75, -23 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.NORMAL, ACTION_BUTTONS.LEFT, "CENTER", "CENTER", -119, 0);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.PUSHED, ACTION_BUTTONS.LEFT, "CENTER", "CENTER", -119, 0 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.NORMAL, ACTION_BUTTONS.RIGHT, "CENTER", "CENTER", -31, 0);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.LEFT, ACTION_STATES.PUSHED, ACTION_BUTTONS.RIGHT, "CENTER", "CENTER", -31, 0 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.NORMAL, ACTION_BUTTONS.TOP, "CENTER", "CENTER", 70, 23);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.PUSHED, ACTION_BUTTONS.TOP, "CENTER", "CENTER", 70, 23 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.NORMAL, ACTION_BUTTONS.BOTTOM, "CENTER", "CENTER", 70, -23);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.PUSHED, ACTION_BUTTONS.BOTTOM, "CENTER", "CENTER", 70, -23 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.NORMAL, ACTION_BUTTONS.LEFT, "CENTER", "CENTER", 32, 0);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.PUSHED, ACTION_BUTTONS.LEFT, "CENTER", "CENTER", 32, 0 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.NORMAL, ACTION_BUTTONS.RIGHT, "CENTER", "CENTER", 108, 0);
leftSquareRightCircleStyleInfo:SetExpandedButtonAnchorInfo(ACTION_BAR_GROUPS.RIGHT, ACTION_STATES.PUSHED, ACTION_BUTTONS.RIGHT, "CENTER", "CENTER", 108, 0 - pushOffsetHalf);
leftSquareRightCircleStyleInfo:SetExpandedShadowDistance(13);
leftSquareRightCircleStyleInfo:SetCheckedDistance(4);

leftSquareRightCircleStyleInfo:SetExpandSequenceMixin(FocusFX.GamepadActionBarSequenceGameplayExpandMixin);
leftSquareRightCircleStyleInfo:SetCollapseSequenceMixin(FocusFX.GamepadActionBarSequenceGameplayCollapseMixin);

leftSquareRightCircleStyleInfo:SetFunc_ApplyExpandedButtonStyle(
	function(self, actionBar)
		actionBar:SetSize(self.expandedActionBarWidth, self.expandedActionBarHeight);
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
				local groupStateInfo = leftGroupInfo[state] or leftGroupInfo[ACTION_STATES.NORMAL];
				local expandedButtonInfo = groupStateInfo[buttonIndex].expandedButtonInfo;
				button:SetScale(self.expandedButtonScale);
				button:SetShapeToSquare();
				button:SetSize(groupStateInfo.expandedButtonWidth, groupStateInfo.expandedButtonHeight);
				button:ClearAllPoints();
				button:SetPoint(expandedButtonInfo.point, actionBar, expandedButtonInfo.relativePoint, expandedButtonInfo.xOffset, expandedButtonInfo.yOffset);
				button:Expand();
			end

			leftButton:ApplyExtraButtonStylesForState(leftButton:GetButtonState());

			-- Right group
			rightButton.ApplyExtraButtonStylesForState = function(button, state)
				local groupStateInfo = rightGroupInfo[state] or rightGroupInfo[ACTION_STATES.NORMAL];
				local expandedButtonInfo = groupStateInfo[buttonIndex].expandedButtonInfo;
				button:SetScale(self.expandedButtonScale);
				button:SetShapeToCircle();
				button:SetSize(groupStateInfo.expandedButtonWidth, groupStateInfo.expandedButtonHeight);
				button:ClearAllPoints();
				button:SetPoint(expandedButtonInfo.point, actionBar, expandedButtonInfo.relativePoint, expandedButtonInfo.xOffset, expandedButtonInfo.yOffset);
				button:Expand();
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
			actionBar:SetExpandSequence(CreateAndInitFromMixin(self.expandSequenceMixin, actionBar));
		end

		if not actionBar.expandSequence:IsPlaying() then
			actionBar.expandSequence:Start();
		end
	end
);

leftSquareRightCircleStyleInfo:SetFunc_ApplyCollapsedButtonStyle(
	function(self, actionBar)
		actionBar:SetSize(self.collapsedActionBarWidth, self.collapsedActionBarHeight);
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
				local groupStateInfo = leftGroupInfo[state] or leftGroupInfo[ACTION_STATES.NORMAL];
				local collapsedButtonInfo = groupStateInfo[buttonIndex].collapsedButtonInfo;
				button:SetScale(self.collapsedButtonScale);
				button:SetShapeToSquare();
				button:SetSize(groupStateInfo.collapsedButtonWidth, groupStateInfo.collapsedButtonHeight);
				button:ClearAllPoints();
				button:SetPoint(collapsedButtonInfo.point, actionBar, collapsedButtonInfo.relativePoint, collapsedButtonInfo.xOffset, collapsedButtonInfo.yOffset);
				button:Collapse();
			end

			leftButton:ApplyExtraButtonStylesForState(leftButton:GetButtonState());

			-- Right group
			rightButton.ApplyExtraButtonStylesForState = function(button, state)
				local groupStateInfo = rightGroupInfo[state] or rightGroupInfo[ACTION_STATES.NORMAL];
				local collapsedButtonInfo = groupStateInfo[buttonIndex].collapsedButtonInfo;
				button:SetScale(self.collapsedButtonScale);
				button:SetShapeToCircle();
				button:SetSize(groupStateInfo.collapsedButtonWidth, groupStateInfo.collapsedButtonHeight);
				button:ClearAllPoints();
				button:SetPoint(collapsedButtonInfo.point, actionBar, collapsedButtonInfo.relativePoint, collapsedButtonInfo.xOffset, collapsedButtonInfo.yOffset);
				button:Collapse();
			end

			rightButton:ApplyExtraButtonStylesForState(rightButton:GetButtonState());


			rightButton.CircleShadow:Show();
			rightButton.CircleShadowFocus:Hide();
			leftButton.SquareShadow:Show();
			leftButton.SquareShadowFocus:Hide();

			-- Right only needs to update circle, left only needs to update square.
			local shadowDistance = self.collapsedShadowDistance;
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
			actionBar:SetCollapseSequence(CreateAndInitFromMixin(self.collapseSequenceMixin, actionBar));
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
			local shadowDistance = self.expandedShadowDistance;
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
