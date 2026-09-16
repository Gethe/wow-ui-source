GamepadInputSequenceMixin = {};

function GamepadInputSequenceMixin:OnLoad()
	self.currentSequenceIndex = 1;
	self.sequenceButtons = {}
	self.sequenceButtonNames = {};

	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
end

function GamepadInputSequenceMixin:OnShow()
	self:Layout();
end

function GamepadInputSequenceMixin:SetupGamepad()
	self.inputSequenceBindings = GamepadMode.CreateBindingGroup("InputSequenceBindings");
	self.inputSequenceBindings:AddFunctionBinding(GAMEPAD_FACE_LEFT, function() self:ProcessButton(GAMEPAD_FACE_LEFT) end);
	self.inputSequenceBindings:AddFunctionBinding(GAMEPAD_FACE_BOTTOM, function() self:ProcessButton(GAMEPAD_FACE_BOTTOM) end);
	self.inputSequenceBindings:AddFunctionBinding(GAMEPAD_FACE_TOP, function() self:ProcessButton(GAMEPAD_FACE_TOP) end);
	self.inputSequenceBindings:AddFunctionBinding(GAMEPAD_DPAD_LEFT, function() self:ProcessButton(GAMEPAD_DPAD_LEFT) end);
	self.inputSequenceBindings:AddFunctionBinding(GAMEPAD_DPAD_RIGHT, function() self:ProcessButton(GAMEPAD_DPAD_RIGHT) end);
	self.inputSequenceBindings:AddFunctionBinding(GAMEPAD_DPAD_BOTTOM, function() self:ProcessButton(GAMEPAD_DPAD_BOTTOM) end);
	self.inputSequenceBindings:AddFunctionBinding(GAMEPAD_DPAD_TOP, function() self:ProcessButton(GAMEPAD_DPAD_TOP) end);
	self.inputSequenceBindings:AddFunctionBinding(GAMEPAD_SHOULDER_LEFT, function() self:ProcessButton(GAMEPAD_SHOULDER_LEFT) end);
	self.inputSequenceBindings:AddFunctionBinding(GAMEPAD_SHOULDER_RIGHT, function() self:ProcessButton(GAMEPAD_SHOULDER_RIGHT) end);
	self.inputSequenceBindings:AddFunctionBinding(GAMEPAD_TRIGGER_LEFT, function() self:ProcessButton(GAMEPAD_TRIGGER_LEFT) end);
	self.inputSequenceBindings:AddFunctionBinding(GAMEPAD_TRIGGER_RIGHT, function() self:ProcessButton(GAMEPAD_TRIGGER_RIGHT) end);
end

function GamepadInputSequenceMixin:EnableBindings()
	GamepadMode.ActivateBindingGroup(self.inputSequenceBindings);
end

function GamepadInputSequenceMixin:DisableBindings()
	GamepadMode.DeactivateBindingGroup(self.inputSequenceBindings);
end

function GamepadInputSequenceMixin:ResetButtons()
	self.currentSequenceIndex = 1;

	for _, button in ipairs(self.sequenceButtons) do
		button.NormalTexture:Show();
		button.DisabledTexture:Hide();
	end
end

function GamepadInputSequenceMixin:SetSequence(inButtonNames)
	self.sequenceButtonNames = inButtonNames;

	for _, button in ipairs(self.sequenceButtons) do
		button:Hide();
	end

	for i, buttonName in ipairs(self.sequenceButtonNames) do
		local button = self.sequenceButtons[i];
		if not button then
			button = CreateFrame("FRAME", nil, self, "InputIconTextureFrameTemplate");
			button.layoutIndex = i;
		end

		button:SetInputKey(buttonName);
		button:EnableDropShadow();
		button:Show();

		table.insert(self.sequenceButtons, button);
	end
end

function GamepadInputSequenceMixin:ProcessButton(inButtonName)
	local currentButton = self.sequenceButtons[self.currentSequenceIndex];

	if currentButton.mappedButtonKey == inButtonName then
		currentButton.NormalTexture:Hide();
		currentButton.DisabledTexture:Show();
		self.currentSequenceIndex = self.currentSequenceIndex + 1;
	else
		self:ResetButtons();
	end

	if self:IsSequenceValid() then
		self:DisableBindings();
		if self.onSequenceComplete then
			self.onSequenceComplete();
		end
	end
end

function GamepadInputSequenceMixin:IsSequenceValid()
	return self.currentSequenceIndex > #self.sequenceButtonNames;
end

function GamepadInputSequenceMixin:RegisterOnSequenceComplete(inFunc)
	self.onSequenceComplete = inFunc;
end
