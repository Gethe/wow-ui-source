ClassTalentImportDialogMixin = {};

function ClassTalentImportDialogMixin:OnLoad()
    self.exclusive = true;
	self.AcceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self));
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self));
    self.ImportBox.EditBox:SetScript("OnTextChanged", GenerateClosure(self.OnTextChanged, self));
	self.ImportBox.EditBox:SetScript("OnEnterPressed", GenerateClosure(self.OnAccept, self));
	self.ImportBox.EditBox:SetScript("OnEscapePressed", GenerateClosure(self.OnCancel, self));
end

function ClassTalentImportDialogMixin:OnHide()

end

function ClassTalentImportDialogMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end

function ClassTalentImportDialogMixin:OnAccept()
    if self.AcceptButton:IsEnabled() then
        local importText = self.ImportBox.EditBox:GetText();
		StaticPopupSpecial_Hide(self);
        ClassTalentFrame.TalentsTab:ImportLoadout(importText);
	end
end


function ClassTalentImportDialogMixin:UpdateAcceptButtonEnabledState()
    local importTextFilled = UserEditBoxNonEmpty(self.ImportBox.EditBox);
    self.AcceptButton:SetEnabled(importTextFilled);
end

function ClassTalentImportDialogMixin:OnTextChanged()
	self:UpdateAcceptButtonEnabledState();
end

function ClassTalentImportDialogMixin:ShowDialog()
    self.ImportBox.EditBox:SetText("");
	StaticPopupSpecial_Show(self);
	self.ImportBox.EditBox:SetFocus();
end