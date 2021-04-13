ButtonGroupBaseMixin = CreateFromMixins(CallbackRegistryMixin);

ButtonGroupBaseMixin:GenerateCallbackEvents(
	{
		"Selected",
		"Unselected",
	}
);

function ButtonGroupBaseMixin:Init()
	CallbackRegistryMixin.OnLoad(self);
	self.buttons = {};
end

function ButtonGroupBaseMixin:AddButton(button)
	self:AddInternal(button);
end

function ButtonGroupBaseMixin:AddButtons(buttons)
	for buttonIndex, button in ipairs(buttons) do
		self:AddInternal(button);
	end
end

function ButtonGroupBaseMixin:AddInternal(button, func, owner)
	table.insert(self.buttons, button);
	button:RegisterSelectionChangedCallback(func, owner);
end

function ButtonGroupBaseMixin:RemoveButton(button)
	self:RemoveInternal(button);
end

function ButtonGroupBaseMixin:RemoveButtons(buttons)
	if buttons == self.buttons then
		self:RemoveAllButtons();
	else
		for buttonIndex, button in ipairs(buttons) do
			self:RemoveInternal(button);
		end
	end
end

function ButtonGroupBaseMixin:RemoveInternal(button)
	tDeleteItem(self.buttons, button);
	button:UnregisterSelectionChangedCallback(self);
end

function ButtonGroupBaseMixin:SetButtons(buttons)
	self:RemoveAllButtons();
	self:AddButtons(buttons);
end

function ButtonGroupBaseMixin:RemoveAllButtons()
	for index, button in ipairs_reverse(self.buttons) do
		self:RemoveInternal(button);
	end
end

function ButtonGroupBaseMixin:GetButtons()
	return self.buttons;
end

function ButtonGroupBaseMixin:Reset()
	self:RemoveAllButtons();
	self:UnregisterEvents();
	self.callbacks = {};
end

function ButtonGroupBaseMixin:FindButtonByPredicate(pred)
	for buttonIndex, button in ipairs(self.buttons) do
		if pred(button) then
			return button;
		end
	end
	return nil;
end

function ButtonGroupBaseMixin:GetButtonsByPredicate(pred)
	local buttons = {};
	for buttonIndex, button in ipairs(self.buttons) do
		if pred(button) then
			table.insert(buttons, button);
		end
	end
	return buttons;
end

function ButtonGroupBaseMixin:Unselect(button)
	self:UnselectAtIndex(self:GetButtonIndex(button));
end

function ButtonGroupBaseMixin:Select(button, isInitializing)
	self:SelectAtIndex(self:GetButtonIndex(button), isInitializing);
end

function ButtonGroupBaseMixin:UnselectAtIndex(index)
	local button = self:GetAtIndex(index);
	if button then
		local isInitializing = false;
		button:SetSelected(false, isInitializing);
	end
end

function ButtonGroupBaseMixin:SelectAtIndex(index, isInitializing)
	local button = self:GetAtIndex(index);
	if button then
		button:SetSelected(true, isInitializing);
	end
end

function ButtonGroupBaseMixin:UnselectAtIndex(index)
	local button = self:GetAtIndex(index);
	if button then
		button:SetSelected(false);
	end
end

function ButtonGroupBaseMixin:GetSelectedButtons()
	return self:GetButtonsByPredicate(
		function(button)
			return button:IsSelected();
		end
	);
end

function ButtonGroupBaseMixin:GetButtonIndex(button)
	return tIndexOf(self.buttons, button);
end

function ButtonGroupBaseMixin:GetAtIndex(index)
	return self.buttons[index];
end

ButtonGroupMixin = CreateFromMixins(ButtonGroupBaseMixin);

function ButtonGroupMixin:OnSelectionChange(button, newSelected)
	local event = newSelected and ButtonGroupBaseMixin.Event.Selected or ButtonGroupBaseMixin.Event.Unselected;
	self:TriggerEvent(event, button, self:GetButtonIndex(button));
end

function ButtonGroupMixin:AddInternal(button)
	ButtonGroupBaseMixin.AddInternal(self, button, self.OnSelectionChange, self);
end

function CreateButtonGroup()
	return CreateAndInitFromMixin(ButtonGroupMixin);
end

RadioButtonGroupMixin = CreateFromMixins(ButtonGroupBaseMixin);

function RadioButtonGroupMixin:CanChangeSelection(button, newSelected)
	return not (not newSelected and #self:GetSelectedButtons() == 1);
end

function RadioButtonGroupMixin:OnSelectionChange(button, newSelected)
	if newSelected then
		for selectedButtonIndex, selectedButton in ipairs(self:GetSelectedButtons()) do
			if selectedButton ~= button then
				selectedButton:SetSelected(false);
				self:TriggerEvent(ButtonGroupBaseMixin.Event.Unselected, selectedButton, self:GetButtonIndex(selectedButton));
			end
		end
	
		self:TriggerEvent(ButtonGroupBaseMixin.Event.Selected, button, self:GetButtonIndex(button));
	end
end

function RadioButtonGroupMixin:AddInternal(button)
	button:SetSelectionChangeInterrupt(GenerateClosure(self.CanChangeSelection, self));
	ButtonGroupBaseMixin.AddInternal(self, button, self.OnSelectionChange, self);
end

function RadioButtonGroupMixin:RemoveInternal(button)
	button:SetSelectionChangeInterrupt(nil);
	ButtonGroupBaseMixin.RemoveInternal(self, button);
end

function CreateRadioButtonGroup()
	return CreateAndInitFromMixin(RadioButtonGroupMixin);
end