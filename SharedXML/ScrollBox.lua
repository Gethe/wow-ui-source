ScrollBoxMixin = CreateFromMixins(CallbackRegistryMixin, ControlExtentAccessorMixin, ScrollControllerMixin);

ScrollBoxMixin:GenerateCallbackEvents(
	{
		"OnScroll",
		"OnSizeChanged",
	}
);

function ScrollBoxMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	ScrollControllerMixin.OnLoad(self);

	self.ScrollTarget:SetScript("OnSizeChanged", GenerateClosure(self.OnScrollTargetSizeChanged, self));
end

function ScrollBoxMixin:Init(scrollValue, elementExtent)
	self.elementExtent = elementExtent;
	self:SetStepExtent(self:CalculateStepExtent());
	self:SetScrollValue(scrollValue);
end

function ScrollBoxMixin:ScrollTo(element)
	local ratio = PercentageBetween(self:GetLower(element), self:GetUpper(self.ScrollTarget), self:GetLower(self.ScrollTarget));
	self:SetScrollValue(ratio);
end

function ScrollBoxMixin:CalculateStepExtent()
	local scrollRange = self:GetScrollRange();
	if scrollRange > 0 then
		return self:GetElementExtent() / scrollRange;
	end
	return 0;
end

function ScrollBoxMixin:ScrollInDirection(ratio, direction)
	ScrollControllerMixin.ScrollInDirection(self, ratio, direction);
	self:UpdateVisuals();

	self:TriggerEvent("OnScroll", self:GetScrollValue());
end

function ScrollBoxMixin:OnMouseWheel(value)
	if value < 0 then
		self:ScrollInDirection(self:GetWheelExtent(), ScrollControllerMixin.Directions.Increase);
	else
		self:ScrollInDirection(self:GetWheelExtent(), ScrollControllerMixin.Directions.Decrease);
	end
end

function ScrollBoxMixin:SetScrollValue(scrollValue)
	ScrollControllerMixin.SetScrollValue(self, scrollValue);
	self:UpdateVisuals();
end

function ScrollBoxMixin:GetExtentVisibleRatio()
	local extent = self:GetExtent();
	return extent > 0 and (self:GetExtentVisible() / extent) or 0;
end

function ScrollBoxMixin:GetElementExtent()
	return self.elementExtent;
end

function ScrollBoxMixin:GetExtent()
	return self.ScrollTarget:GetHeight();
end

function ScrollBoxMixin:GetExtentVisible()
	return self:GetHeight();
end

function ScrollBoxMixin:GetScrollRange()
	return math.max(0, self:GetExtent() - self:GetExtentVisible());
end

function ScrollBoxMixin:UpdateVisuals()
	local scrollValue = self:GetScrollValue();
	local scrollRange = self:GetScrollRange();
	local offset = scrollRange * scrollValue;
	self.ScrollTarget:SetPoint("TOPLEFT", 0, scrollRange * scrollValue);

	self:TriggerEvent("OnScroll", scrollValue, self:GetExtentVisibleRatio());
end

function ScrollBoxMixin:OnScrollTargetSizeChanged()
	if self.ScrollTarget:GetBottom() > self:GetBottom() then
		self:SetScrollValue(1.0);
	else
		local y = select(5, self.ScrollTarget:GetPoint("TOPLEFT"));
		self:SetScrollValue(y / self:GetScrollRange());
	end

	self:SetStepExtent(self:CalculateStepExtent());

	self:TriggerEvent("OnSizeChanged", self:GetExtentVisibleRatio());
end