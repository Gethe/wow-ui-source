PropertySliderMixin = {};

function PropertySliderMixin:OnValueChanged(value, isMouse)
	if isMouse then
		self:CallMutator(value);
	end

	self:OnPropertyChanged("OnValueChanged", value, isMouse);
end

function PropertySliderMixin:UpdateVisibleState()
	if PropertyBindingMixin.UpdateVisibleState(self) then
		local value = self:CallAccessor();
		self:SetEnabled(value ~= nil);
		if value ~= nil then
			self:SetValue(value);
		end
	end
end