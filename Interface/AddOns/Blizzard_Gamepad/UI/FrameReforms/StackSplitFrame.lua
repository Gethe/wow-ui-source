--[[
	This file extends the functionality of StackSplitMixin to respect gamepad behaviors.
	Because Blizzard_FrameXML/[Family]/StackSplitMixin is already loaded when this file 
	is processed, OnLoad is off the table. So we will lazy-init gamepad behaviors the first
	time the user attempts to open the stack split frame.
]]
StackSplitGamepadMixin = {};

local ParentOpenStackSplit = StackSplitMixin.OpenStackSplitFrame;
function StackSplitGamepadMixin:OpenStackSplitFrame(maxStack, parent, anchor, anchorTo, stackCount)
	self:LazyInitGamepad();
	ParentOpenStackSplit(self, maxStack, parent, anchor, anchorTo, stackCount);
end

function StackSplitGamepadMixin:LazyInitGamepad()
	if self.hasInitGamepad then
		return;
	end

	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitGamepad, self));

	self.hasInitGamepad = true;
end

function StackSplitGamepadMixin:SetupGamepad()
	self.footer = GamepadSharedUtility.CreatePromptedBindingFooter(self, "StackSplitFooter");
	local confirmBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, StackSplitOkayButton_OnClick, FRAME_ACTION_CONFIRM);
	self.footer:AddPromptedBinding(confirmBinding);
	local cancelBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, StackSplitCancelButton_OnClick, FRAME_ACTION_CANCEL);
	self.footer:AddPromptedBinding(cancelBinding);
	self.footer:AddFunctionBinding(GAMEPAD_DPAD_LEFT, StackSplitLeftButton_OnClick);
	self.footer:AddFunctionBinding(GAMEPAD_DPAD_RIGHT, StackSplitRightButton_OnClick);
	self.footer:Finalize();

	self:SetScript("OnShow", function()
		GamepadMode.FrameControlsManager:FrameShown(self);
	end);
	self:SetScript("OnHide", function()
		GamepadMode.FrameControlsManager:FrameHidden(self);
	end);

	GamepadMode.FrameControlsManager:DismissOnUnfocus(self);
	GamepadMode.FrameControlsManager:UseCustomNavigation(self);
	GamepadMode.FrameControlsManager:DisableFrameFocusPagingWhenFocused(self);
end

function StackSplitGamepadMixin:InitGamepad()
	self.CancelButton:Hide();
	self.OkayButton:Hide();
end

function StackSplitGamepadMixin:UninitGamepad()
	self.CancelButton:Show();
	self.OkayButton:Show();
end

function StackSplitGamepadMixin:FocusGamepad()
	self.footer:ShowAndActivateBindings();
end

function StackSplitGamepadMixin:UnfocusGamepad()
	self.footer:HideAndDeactivateBindings();
end

Mixin(StackSplitMixin, StackSplitGamepadMixin);

--[[
	At this point, the already-created StackSplitFrame does not have the new
	functionality. Apply it now.
]]
Mixin(StackSplitFrame, StackSplitGamepadMixin);
