PropertySliderMixin = {};

function PropertySliderMixin:OnValueChanged(value, isMouse)
	if isMouse then
		self:CallMutator(value);
	end

	self:OnPropertyChanged("OnValueChanged", value, isMouse);
end

function PropertySliderMixin:UpdateVisibleState()
	if PropertyBindingMixin.UpdateVisibleState(self) then
		self:SetValue(self:CallAccessor());
	end
end