SelectableButtonMixin = CreateFromMixins(CallbackRegistryMixin);

SelectableButtonMixin:GenerateCallbackEvents(
	{
		"SelectionChanged",
	}
);

function SelectableButtonMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self.selected = false;
end

function SelectableButtonMixin:Reset()
	self.CanChangeSelectionOverride = nil;
	self.selected = false;
end

function SelectableButtonMixin:OnClick()
	self:SetSelected(not self:IsSelected());
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

function SelectableButtonMixin:RegisterSelectionChangedCallback(func, owner, ...)
	return self:RegisterCallback(SelectableButtonMixin.Event.SelectionChanged, func, owner, ...);
end

function SelectableButtonMixin:UnregisterSelectionChangedCallback(owner)
	self:UnregisterCallback(SelectableButtonMixin.Event.SelectionChanged, owner);
end


function SelectableButtonMixin:SetSelectionChangeInterrupt(callback)
	self.SelectionChangeInterrupt = callback;
end

function SelectableButtonMixin:IsSelected()
	return self.selected;
end

function SelectableButtonMixin:SetSelected(newSelected)
	if self:CanChangeSelection(newSelected) then
		self.selected = newSelected;

		self:TriggerEvent(SelectableButtonMixin.Event.SelectionChanged, self, newSelected);
		self:OnSelected(newSelected);
	end
end

function SelectableButtonMixin:OnSelected(newSelected)
-- Derive
end