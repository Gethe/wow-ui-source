SelectableButtonMixin = {};

function SelectableButtonMixin:OnLoad()
	self.selected = false;
end

function SelectableButtonMixin:Reset()
	self.CanChangeSelectionOverride = nil;
	self.selected = false;
end

function SelectableButtonMixin:OnClick()
	return self:SetSelected(not self:IsSelected());
end

function SelectableButtonMixin:CanChangeSelection(newSelected)
	if self:IsSelected() == newSelected then
		return false;
	end

	if self.SelectionChangeInterrupt then
		return self.SelectionChangeInterrupt(self, newSelected);
	end

	return true;
end

function SelectableButtonMixin:SetSelectionChangeInterrupt(callback)
	self.SelectionChangeInterrupt = callback;
end

function SelectableButtonMixin:IsSelected()
	return not not self.selected;
end

function SelectableButtonMixin:SetSelected(newSelected)
	if self:CanChangeSelection(newSelected) then
		self:SetSelectedState(newSelected);
		self:OnSelected(newSelected);
	end
end

function SelectableButtonMixin:OnSelected(newSelected)
-- Derive
end

function SelectableButtonMixin:SetSelectedState(newSelected)
	-- Derive
	self.selected = newSelected;
end