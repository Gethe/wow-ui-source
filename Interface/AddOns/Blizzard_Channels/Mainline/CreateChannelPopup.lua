CreateChannelPopupMixin = {};

function CreateChannelPopupMixin:OnLoad()
	self.tabGroup = CreateTabGroup(self.Name, self.Password);

	self.UseVoiceChat.Text:SetFontObject(GameFontNormal);
	self.UseVoiceChat.Text:SetText(ENABLE_VOICECHAT);
	self.UseVoiceChat.Text:SetPoint("LEFT", self.UseVoiceChat, "RIGHT", 2, 2);

	self:RegisterForTransitions();
end

function CreateChannelPopupMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
end

function CreateChannelPopupMixin:SetupGamepad()
	GamepadMode.FrameControlsManager:DisableFrameFocusPagingWhenFocused(self);
	self.footer = GamepadSharedUtility.CreatePromptedBindingFooter(self, "CreateChannelPopup");
	local createChannelBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, GenerateClosure(self.OnOKClicked, self), OKAY);
	self.footer:AddPromptedBinding(createChannelBinding);
	local cancelBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, GenerateClosure(self.OnCancelClicked, self), FRAME_ACTION_CANCEL);
	self.footer:AddPromptedBinding(cancelBinding);
	self.footer:Finalize();
end

function CreateChannelPopupMixin:InitializeGamepad()
	self.CloseButton:Hide();
	self.OKButton:Hide();
	self.CancelButton:Hide();
end

function CreateChannelPopupMixin:FocusGamepad()
	self.footer:ShowAndActivateBindings();
end

function CreateChannelPopupMixin:UnfocusGamepad()
	self.footer:HideAndDeactivateBindings();
	if self:IsShown() then
		self:Hide();
	end
end

function CreateChannelPopupMixin:SetCallback(contextObject, callbackFunction)
	self.contextObject = contextObject;
	self.callbackFunction = callbackFunction;
end

function CreateChannelPopupMixin:DoCallback(...)
	self.callbackFunction(self.contextObject, ...)
end

function CreateChannelPopupMixin:OnOKClicked()
	self:DoCallback(self.Name:GetText(), self.Password:GetText());
	StaticPopupSpecial_Hide(self);
end

function CreateChannelPopupMixin:OnCancelClicked()
	StaticPopupSpecial_Hide(self);
end

function CreateChannelPopupMixin:OnTabPressed()
	self.tabGroup:OnTabPressed();
end

function CreateChannelPopupMixin:OnShow()
	if InputUtil.IsGamepadUIEnabled() then
		GamepadMode.FrameControlsManager:FrameShown(self);
	end
end

function CreateChannelPopupMixin:OnHide()
	self.Name:SetText("");
	self.Password:SetText("");
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	if InputUtil.IsGamepadUIEnabled() then
		GamepadMode.FrameControlsManager:FrameHidden(self);
	end
end
