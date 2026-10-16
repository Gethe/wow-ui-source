GamepadBaseDialogMixin = {};

function GamepadBaseDialogMixin:GamepadBaseDialog_OnLoad()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitGamepad, self));
end

function GamepadBaseDialogMixin:GamepadBaseDialog_OnShow()
	GamepadMode.FrameControlsManager:FrameShown(self);
end

function GamepadBaseDialogMixin:GamepadBaseDialog_OnHide()
	GamepadMode.FrameControlsManager:FrameHidden(self);
end

function GamepadBaseDialogMixin:CreateGamepadFooter()
	local footer = GamepadSharedUtility.CreatePromptedBindingFooter(self);
	footer:AddStandardSelectPrompt();
	footer:AddStandardBackPrompt();
	footer:Finalize();
	return footer;
end

function GamepadBaseDialogMixin:SetupGamepad()
	self.gamepadFooter = self:CreateGamepadFooter();
end

function GamepadBaseDialogMixin:InitGamepad()
	if self.CloseButton then
		self.CloseButton:Hide();
	end
end

function GamepadBaseDialogMixin:UninitGamepad()
	if self.CloseButton then
		self.CloseButton:Show();
	end
end

function GamepadBaseDialogMixin:FocusGamepad()
	if self.gamepadFooter then
		self.gamepadFooter:ShowAndActivateBindings();
	end
end

function GamepadBaseDialogMixin:UnfocusGamepad()
	if self.gamepadFooter then
		self.gamepadFooter:HideAndDeactivateBindings();
	end
end
