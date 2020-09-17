EventButtonMixin = CreateFromMixins(CallbackRegistryMixin);

EventButtonMixin:GenerateCallbackEvents(
	{
		"OnMouseUp",
		"OnMouseDown",
		"OnClick",
		"OnEnter",
		"OnLeave",
	}
);

function EventButtonMixin:OnLoad_Intrinsic()
	CallbackRegistryMixin.OnLoad(self);
end

function EventButtonMixin:OnMouseUp_Intrinsic(buttonName, upInside)
	self:TriggerEvent("OnMouseUp", buttonName, upInside);
end

function EventButtonMixin:OnMouseDown_Intrinsic(buttonName)
	self:TriggerEvent("OnMouseDown", buttonName);
end

function EventButtonMixin:OnClick_Intrinsic(buttonName, down)
	self:TriggerEvent("OnClick", buttonName, down);
end

function EventButtonMixin:OnEnter_Intrinsic()
	self:TriggerEvent("OnEnter");
end

function EventButtonMixin:OnLeave_Intrinsic()
	self:TriggerEvent("OnLeave");
end