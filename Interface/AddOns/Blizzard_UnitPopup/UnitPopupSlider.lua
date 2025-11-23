UnitPopupSliderMixin = {};

function UnitPopupSliderMixin:OnEnter()
	ExecuteFrameScript(self:GetParent(), "OnEnter");
	PropertyBindingMixin.OnEnter(self);
end

function UnitPopupSliderMixin:OnLeave()
	ExecuteFrameScript(self:GetParent(), "OnLeave");
	PropertyBindingMixin.OnLeave(self);
end