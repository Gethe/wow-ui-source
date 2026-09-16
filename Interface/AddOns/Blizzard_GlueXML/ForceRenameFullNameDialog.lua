--------------------------------------------------------------------------------
-- ForceRenameFullNameDialogMixin
--------------------------------------------------------------------------------
ForceRenameFullNameDialogMixin = {};

function ForceRenameFullNameDialogMixin:OnLoad()
	CharacterSelectBlockingFrameMixin.OnLoad(self);

	local editBoxCharacterName = self.RenameFrame.EditBoxes.EditBoxCharacterName;
	editBoxCharacterName:SetScript("OnEscapePressed", GenerateClosure(self.Cancel, self));
	editBoxCharacterName:SetScript("OnEnterPressed", GenerateClosure(self.Confirm, self));
	editBoxCharacterName:SetScript("OnTextChanged", GenerateClosure(self.OnTextChanged, self, editBoxCharacterName));
	editBoxCharacterName:SetScript("OnShow", GenerateClosure(self.OnTextChanged, self, editBoxCharacterName));

	local editBoxSurname = self.RenameFrame.EditBoxes.EditBoxSurname;
	editBoxSurname:SetScript("OnEscapePressed", GenerateClosure(self.Cancel, self));
	editBoxSurname:SetScript("OnEnterPressed", GenerateClosure(self.Confirm, self));
	editBoxSurname:SetScript("OnTextChanged", GenerateClosure(self.OnTextChanged, self, editBoxSurname));
	editBoxSurname:SetScript("OnShow", GenerateClosure(self.OnTextChanged, self, editBoxSurname));

	local confirmButton = self.RenameFrame.Buttons.ConfirmButton;
	confirmButton:SetScript("OnClick", GenerateClosure(self.Confirm, self));

	local cancelButton = self.RenameFrame.Buttons.CancelButton;
	cancelButton:SetScript("OnClick", GenerateClosure(self.Cancel, self));
end

function ForceRenameFullNameDialogMixin:OnHide()
	self.RenameFrame.EditBoxes.EditBoxCharacterName:SetText("");
	self.RenameFrame.EditBoxes.EditBoxSurname:SetText("");
end

function ForceRenameFullNameDialogMixin:ShowWithInstructions(instructions)
	self.RenameFrame.Instructions.Text:SetText(instructions);
	self.RenameFrame:MarkDirty();
	self:Show();
end

function ForceRenameFullNameDialogMixin:GetNames()
	local characterName = self.RenameFrame.EditBoxes.EditBoxCharacterName:GetText();
	local surname = self.RenameFrame.EditBoxes.EditBoxSurname:GetText();
	return characterName, surname;
end

function ForceRenameFullNameDialogMixin:Confirm()
	if (not self.RenameFrame.Buttons.ConfirmButton:IsEnabled()) then
		return;
	end

	local characterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
	local characterName, surname = self:GetNames();
	local sentToServer = RenameCharacterFullName(characterID, characterName, surname);

	if (sentToServer) then
		self:Hide();
	end
end

function ForceRenameFullNameDialogMixin:Cancel()
	self:Hide();
end

function ForceRenameFullNameDialogMixin:OnTextChanged(editBox)
	editBox:OnTextChanged();

	local characterName, surname = self:GetNames();
	self.RenameFrame.Buttons.ConfirmButton:SetEnabled(#characterName >= 3 and #surname >= 3);
end

--------------------------------------------------------------------------------
-- ForceRenameEditBoxCharacterNameMixin
--------------------------------------------------------------------------------
ForceRenameEditBoxCharacterNameMixin = {};

function ForceRenameEditBoxCharacterNameMixin:OnTabPressed()
	self:ClearFocus();
	EditBox_ClearHighlight(self);
	self:GetParent().EditBoxSurname:SetFocus();
end

--------------------------------------------------------------------------------
-- ForceRenameEditBoxSurnameMixin
--------------------------------------------------------------------------------
ForceRenameEditBoxSurnameMixin = {};

function ForceRenameEditBoxSurnameMixin:OnTabPressed()
	self:ClearFocus();
	EditBox_ClearHighlight(self);
	self:GetParent().EditBoxCharacterName:SetFocus();
end
