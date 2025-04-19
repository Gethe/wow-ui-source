
--------------------------------------------------
-- TABARD MODEL CONTROL ROTATE BUTTON MIXIN
TabardModelControlRotateButtonMixin = CreateFromMixins(ModelControlRotateButtonMixin);

function TabardModelControlRotateButtonMixin:OnLoad()
	--cache off the model
	self.model = self:GetParent();
end
