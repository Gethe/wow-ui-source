
EventScrollFrameMixin = CreateFromMixins(CallbackRegistryMixin);

EventScrollFrameMixin:GenerateCallbackEvents(
	{
		"OnHorizontalScroll",
		"OnVerticalScroll",
		"OnScrollRangeChanged",
		"OnMouseWheel",
		"OnSizeChanged",
	}
);

function EventScrollFrameMixin:OnLoad_Intrinsic()
	CallbackRegistryMixin.OnLoad(self);
end

function EventScrollFrameMixin:OnHorizontalScroll_Intrinsic(offset)
	self:TriggerEvent("OnHorizontalScroll", offset);
end

function EventScrollFrameMixin:OnVerticalScroll_Intrinsic(offset)
	self:TriggerEvent("OnVerticalScroll", offset);
end

function EventScrollFrameMixin:OnScrollRangeChanged_Intrinsic(xrange, yrange)
	self:TriggerEvent("OnScrollRangeChanged", xrange, yrange);
end

function EventScrollFrameMixin:OnMouseWheel_Intrinsic(direction)
	self:TriggerEvent("OnMouseWheel", direction);
end

function EventScrollFrameMixin:OnSizeChanged_Intrinsic(width, height)
	self:TriggerEvent("OnSizeChanged", width, height);
end