GamepadClassActionButtonMixin = {};

function GamepadClassActionButtonMixin:OnLoad()
	GamepadActionBarStandardButtonMixin.OnLoad(self);

	-- These don't refer to actual actions, they are just styled as action buttons
	self.action = 0;
	self:SetAttribute("action", 0);
	self:UpdateAction();
	C_ActionBar.UnregisterActionUIButton(self);

	-- Default to a click action
	self:SetAttribute("type", "click");
	self:SetAttribute("clickbutton", self);

	-- Use the round style
	local size = GamepadActionBarStyleUtil.CIRCULAR_BUTTON_EXPANDED_SIZE;
	self:SetShapeToCircle();
	self:UpdateEmptySlotBackgroundTexture();
	self:SetSize(size, size);
	self.CircleShadow:ClearAllPoints();
	self.CircleShadow:SetPoint("TOPLEFT", -4, 4);
	self.CircleShadow:SetPoint("BOTTOMRIGHT", 4, -4);

	local _, relativeTo, _, x, y = self:GetPoint(1);
	self.anchorInfo = { relativeTo=relativeTo, x=x, y=y };
end

function GamepadClassActionButtonMixin:OnShow()
	ActionBarActionButtonMixin.OnShow(self);

	if self.inputPromptKey then
		-- This must be remembered, since if the button gets hidden while a flyout is open it will
		-- have the wrong parent.
		self.inputPrompt = self:GetParent()[self.inputPromptKey];
		self.inputPrompt:Show();
	end
end

function GamepadClassActionButtonMixin:OnHide()
	ActionBarActionButtonMixin.OnHide(self);

	self:ClosePopup();

	if self.inputPrompt then
		self.inputPrompt:Hide();
		self.inputPrompt = nil;
	end
end

function GamepadClassActionButtonMixin:ApplyExtraButtonStylesForState(state)
	local focusState = GamepadActionBarStyleUtil.FOCUS_STATES.EXPANDED;
	local styleParams = GamepadActionBarStyleUtil.circleStyleParams;
	GamepadActionBarStyleUtil.ApplyExtraButtonStyles(self, state, focusState, styleParams, self.anchorInfo);
end

-- Implemented as a per-frame OnUpdate check for now: We can't use OnGamePadButtonDown and
-- OnGamepadButtonUp since we don't want to block inputs, and the up event is only called for the
-- frame that blocked input in the down event. Eventually it'd be better to do this in the same
-- place where the modifiers are handled.
function GamepadClassActionButtonMixin:OnUpdate(_)
	local isShoulderDown = IsKeyDown(self.shoulderButton);
	local isTriggerDown = IsKeyDown(self.triggerButton);

	if self.isPressed then
		if not isShoulderDown or not isTriggerDown then
			self:TriggerSecureClick("LeftButton", false);
		end
	else
		if isShoulderDown and isTriggerDown and GamepadSharedUtility.InputBindingManager:IsOnlyCoreBindingSetActive() then
			self:TriggerSecureClick("LeftButton", true);
			GamepadTargetLogic:ConsumeModifier();
		end
	end
end

function GamepadClassActionButtonMixin:ApplyPressedStyle(pressed)
	self.isPressed = pressed;
	GamepadActionBarButtonMixin.ApplyPressedStyle(self, pressed);
end

-- Gamepad action buttons call this function to support bound spell flyouts properly, but most of
-- the buttons using this won't need to use that, and it actively breaks non-action behaviors. So
-- by default it is overridden to do nothing, and then mixins for these buttons can re-add it if
-- they need it.
--
-- Overrides GamepadActionBarButtonFlyoutMixin.SetActionAttributes
function GamepadClassActionButtonMixin:SetActionAttributes()
end
