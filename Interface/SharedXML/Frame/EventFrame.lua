EventFrameMixin = CreateFromMixins(CallbackRegistryMixin);

EventFrameMixin:GenerateCallbackEvents(
	{
		"OnHide",
		"OnShow",
		"OnSizeChanged",
	}
);

function EventFrameMixin:OnLoad_Intrinsic()
	CallbackRegistryMixin.OnLoad(self);
end

function EventFrameMixin:OnHide_Intrinsic()
	self:TriggerEvent("OnHide");
end

function EventFrameMixin:OnShow_Intrinsic()
	self:TriggerEvent("OnShow");
end

function EventFrameMixin:OnSizeChanged_Intrinsic(width, height)
	self:TriggerEvent("OnSizeChanged", width, height);
end