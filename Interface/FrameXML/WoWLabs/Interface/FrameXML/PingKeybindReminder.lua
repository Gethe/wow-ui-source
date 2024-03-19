
KeybindReminderMixin = {};

function KeybindReminderMixin:OnLoad()
	self:RegisterEvent("UPDATE_BINDINGS");
	self.UnboundText:SetText(("(%s)"):format(NOT_BOUND));
	self.BindingAction:SetText(self.overrideBindingActionText or _G["BINDING_NAME_"..self.keybind]);
end

function KeybindReminderMixin:OnEvent(event)
	if event == "UPDATE_BINDINGS" then
		local key = GetBindingKey(self.keybind);
		local bindingText = GetBindingText(key, 1);
		local hasBindingText = bindingText ~= "";
		self.KeyIcon:SetShown(hasBindingText);
		self.KeyBind:SetShown(hasBindingText);
		self.UnboundText:SetShown(not hasBindingText);
		self.KeyBind:SetText(bindingText);
	end
end
