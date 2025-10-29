MovePadMixin = {};

function MovePadMixin:OnLoad()
	local function OnValueChanged(o, setting, value)
		self:SetShown(value);
	end

	if Settings then
		Settings.SetOnValueChangedCallback("enableMovePad", OnValueChanged);
	end

	CVarCallbackRegistry:SetCVarCachable("movePadLocked");
	self:SetLockedMode(CVarCallbackRegistry:GetCVarValueBool("movePadLocked"));

	CVarCallbackRegistry:SetCVarCachable("movePadInPressAndHoldMode");
	self:SetPressAndHoldMode(CVarCallbackRegistry:GetCVarValueBool("movePadInPressAndHoldMode"));

	self:SetupDropdownMenu();

	MovePadForward.opposingMoveButton = MovePadBackward;
	MovePadBackward.opposingMoveButton = MovePadForward;

	MovePadRotateLeft.opposingMoveButton = MovePadRotateRight;
	MovePadRotateRight.opposingMoveButton = MovePadRotateLeft;

	MovePadStrafeLeft.opposingMoveButton = MovePadStrafeRight;
	MovePadStrafeRight.opposingMoveButton = MovePadStrafeLeft;

	FrameUtil.RegisterForTopLevelParentChanged(self);
end

function MovePadMixin:SetLockedMode(locked)
	self.locked = locked;
end

function MovePadMixin:SetPressAndHoldMode(pressAndHoldMode)
	self.pressAndHoldMode = pressAndHoldMode;
	self:ResetMoveButtons();

	for _, button in ipairs(self.MoveButtons) do
		button:SetPressAndHoldMode(pressAndHoldMode);
	end
end

function MovePadMixin:SetupDropdownMenu()
	local function IsLocked()
		return CVarCallbackRegistry:GetCVarValueBool("movePadLocked");
	end

	local function SetLockedMode(locked)
		if locked ~= IsLocked() then
			SetCVar("movePadLocked", locked);
			self:SetLockedMode(locked);
		end
	end

	local function ToggleLockedMode()
		SetLockedMode(not IsLocked());
	end

	local function IsInPressAndHoldMode()
		return CVarCallbackRegistry:GetCVarValueBool("movePadInPressAndHoldMode");
	end

	local function SetPressAndHoldMode(pressAndHoldMode)
		if pressAndHoldMode ~= IsInPressAndHoldMode() then
			SetCVar("movePadInPressAndHoldMode", pressAndHoldMode);
			self:SetPressAndHoldMode(pressAndHoldMode);
		end
	end

	local function TogglePressAndHoldMode()
		SetPressAndHoldMode(not IsInPressAndHoldMode());
	end

	self.SettingsDropdown:SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MOVE_PAD_SETTINGS_MENU");
		rootDescription:CreateCheckbox(MOVE_PAD_LOCKED, IsLocked, ToggleLockedMode);
		rootDescription:CreateCheckbox(MOVE_PAD_PRESS_AND_HOLD_MODE, IsInPressAndHoldMode, TogglePressAndHoldMode);
	end);
end

function MovePadMixin:OnDragStart()
	if not self.locked then
		self:SetFrameStrata("DIALOG");
		self:StartMoving();
	end
end

function MovePadMixin:OnDragStop()
	if not self.locked then
		self:StopMovingOrSizing();
		ValidateFramePosition(self);
		self:SetFrameStrata("BACKGROUND");
	end
end

function MovePadMixin:ResetMoveButtons(exemptButton)
	for _, button in ipairs(self.MoveButtons) do
		if button ~= exemptButton then
			button:ResetButton();
		end
	end
end

MovePadCheckboxMixin = {};

function MovePadCheckboxMixin:ResetButton()
	self:SetChecked(false);
	self.stopAction();
end

function MovePadCheckboxMixin:OnMovePadCheckboxClick()
	if not self.pressAndHoldMode then
		if self.opposingMoveButton then
			self.opposingMoveButton:ResetButton();
		end

		if self:GetChecked() then
			self.startAction();
		else
			self.stopAction();
		end
	end
end

function MovePadCheckboxMixin:OnMovePadCheckboxMouseDown()
	if self.pressAndHoldMode then
		MovePadFrame:ResetMoveButtons(self);
		self.startAction();
	end
end

function MovePadCheckboxMixin:OnMovePadCheckboxMouseUp()
	if self.pressAndHoldMode then
		MovePadFrame:ResetMoveButtons();
		self.stopAction();
	end
end

function MovePadCheckboxMixin:SetPressAndHoldMode(pressAndHoldMode)
	self.pressAndHoldMode = pressAndHoldMode;
	if pressAndHoldMode then
		self:RegisterForClicks();
	else
		self:RegisterForClicks("AnyUp");
	end
end

MovePadForwardMixin = {};

function MovePadForwardMixin:OnLoad()
	SquareButton_SetIcon(self, "UP");
end

MovePadBackwardMixin = {};

function MovePadBackwardMixin:OnLoad()
	SquareButton_SetIcon(self, "DOWN");
end

MovePadRotateLeftMixin = {};

function MovePadRotateLeftMixin:OnLoad()
	self.icon:SetTexture("Interface\\Buttons\\UI-RotationLeft-Button-Up");
	self.icon:SetTexCoord(0,1,0,1);
	self.icon:SetSize(35,35);
end

MovePadRotateRightMixin = {};

function MovePadRotateRightMixin:OnLoad()
	self.icon:SetTexture("Interface\\Buttons\\UI-RotationRight-Button-Up");
	self.icon:SetTexCoord(0,1,0,1);
	self.icon:SetSize(35,35);
end

MovePadStrafeLeftMixin = {};

function MovePadStrafeLeftMixin:OnLoad()
	SquareButton_SetIcon(self, "LEFT");
end

MovePadStrafeRightMixin = {};

function MovePadStrafeRightMixin:OnLoad()
	SquareButton_SetIcon(self, "RIGHT");
end

MovePadJumpMixin = {};

function MovePadJumpMixin:OnLoad()
	self.icon:SetTexture("Interface\\Buttons\\JumpUpArrow");
	self.icon:SetTexCoord(0,1,0,1);
	self.icon:SetSize(18,18);
end

function MovePadJumpMixin:OnMovePadJumpMouseDown()
	if self:IsEnabled() then
		self.icon:SetPoint("CENTER", -1, -1);
	end

	RunBinding("JUMP", "down");
end

function MovePadJumpMixin:OnMovePadJumpMouseUp()
	self.icon:SetPoint("CENTER", 0, 0);
	RunBinding("JUMP", "up");
end
