OribosScrollBarButtonScriptsMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function OribosScrollBarButtonScriptsMixin:OnLoad()
	ButtonStateBehaviorMixin.OnLoad(self);

	self:DesaturateIfDisabled();
end

function OribosScrollBarButtonScriptsMixin:OnButtonStateChanged()
	self.Down:SetShown(self:IsDown());
	self.Enter:SetShown(self:IsOver());
end