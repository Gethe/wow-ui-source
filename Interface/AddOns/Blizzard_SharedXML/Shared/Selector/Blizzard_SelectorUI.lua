
SelectorMixin = {};

function SelectorMixin:OnSelection(selectionIndex)
	if self.selectedCallback ~= nil then
		self.selectedCallback(selectionIndex, self:GetSelection(selectionIndex));
	end

	self:SetSelectedIndex(selectionIndex);
end

function SelectorMixin:SetSelectedIndex(selectionIndex)
	self.selectedIndex = selectionIndex;
	self:UpdateAllSelectedTextures();
end

function SelectorMixin:GetSelectedIndex()
	return self.selectedIndex;
end

function SelectorMixin:UpdateAllSelectedTextures()
	if self.initialized then
		for button in self:EnumerateButtons() do
			button:UpdateSelectedTexture();
		end
	end
end

function SelectorMixin:IsSelected(selectionIndex)
	return selectionIndex == self.selectedIndex;
end

-- callback takes the selectionIndex and the selection.
function SelectorMixin:SetSelectedCallback(callback)
	self.selectedCallback = callback;
end

function SelectorMixin:SetSelectionsArray(selectionsArray)
	local function SelectorGetArraySelectionByIndex(selectionIndex)
		return selectionsArray[selectionIndex];
	end

	local function SelectorGetNumArraySelections()
		return #selectionsArray;
	end

	self:SetSelectionsDataProvider(SelectorGetArraySelectionByIndex, SelectorGetNumArraySelections);
end

function SelectorMixin:SetSelectionsDataProvider(getSelectionByIndex, getNumSelections)
	self.getSelectionByIndex = getSelectionByIndex;
	self.getNumSelections = getNumSelections;
	self:UpdateSelections();
end

function SelectorMixin:GetNumSelections()
	return (self.getNumSelections ~= nil) and self.getNumSelections() or 0;
end

function SelectorMixin:GetSelection(selectionIndex)
	return self.getSelectionByIndex(selectionIndex);
end

function SelectorMixin:SetCustomButtonTemplate(customTemplateType, customButtonTemplate)
	self.templateType = customTemplateType;
	self.buttonTemplate = customButtonTemplate;
end

function SelectorMixin:GetButtonTemplate()
	return self.templateType, self.buttonTemplate;
end

-- Takes the button to setup, the selectionIndex, and the selection.
function SelectorMixin:SetSetupCallback(setupCallback)
	self.setupCallback = setupCallback;
end

function SelectorMixin:GetSetupCallback()
	return self.setupCallback;
end

function SelectorMixin:RunSetup(button, selectionIndex)
	button:Init(self);

	button:SetSelectionIndex(selectionIndex);

	if self.setupCallback ~= nil then
		self.setupCallback(button, selectionIndex, self:GetSelection(selectionIndex));
	end
end

-- Override in your derived mixin.
function SelectorMixin:EnumerateButtons()
	return nil;
end

-- Override in your derived mixin.
function SelectorMixin:UpdateSelections()
end


SelectorButtonMixin = {};

function SelectorButtonMixin:Init(selectorFrame)
	self.selectorFrame = selectorFrame;
end

function SelectorButtonMixin:SetSelectionIndex(selectionIndex)
	self.selectionIndex = selectionIndex;
	self:UpdateSelectedTexture();
end

function SelectorButtonMixin:GetSelectionIndex()
	return self.selectionIndex;
end

function SelectorButtonMixin:SetIconTexture(iconTexture)
	self.Icon:SetTexture(iconTexture);
end

function SelectorButtonMixin:GetIconTexture()
	return self.Icon:GetTexture();
end

function SelectorButtonMixin:UpdateSelectedTexture()
	self.SelectedTexture:SetShown(self:GetSelectorFrame():IsSelected(self.selectionIndex));
end

function SelectorButtonMixin:OnClick()
	self:GetSelectorFrame():OnSelection(self.selectionIndex);
end

function SelectorButtonMixin:GetSelection()
	return self:GetSelectorFrame():GetSelection(self.selectionIndex);
end

function SelectorButtonMixin:GetSelectorFrame()
	return self.selectorFrame;
end
