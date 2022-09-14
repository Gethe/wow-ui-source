ClassTalentLoadoutImportDialogMixin = {};

function ClassTalentLoadoutImportDialogMixin:OnLoad()
	self.exclusive = true;
	self.AcceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self));
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self));
	self.ImportBox.EditBox:SetScript("OnTextChanged", GenerateClosure(self.OnTextChanged, self));
	self.ImportBox.EditBox:SetScript("OnEnterPressed", GenerateClosure(self.OnAccept, self));
	self.ImportBox.EditBox:SetScript("OnEscapePressed", GenerateClosure(self.OnCancel, self));
	ClassTalentLoadoutDialogMixin.OnLoad(self);
end

function ClassTalentLoadoutImportDialogMixin:OnHide()

end

function ClassTalentLoadoutImportDialogMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end

function ClassTalentLoadoutImportDialogMixin:OnAccept()
	if self.AcceptButton:IsEnabled() then
		local importText = self.ImportBox.EditBox:GetText();
		local success = ClassTalentFrame.TalentsTab:ImportLoadout(importText);
		
		if success then
			StaticPopupSpecial_Hide(self);
		end
	end
end


function ClassTalentLoadoutImportDialogMixin:UpdateAcceptButtonEnabledState()
	local importTextFilled = UserEditBoxNonEmpty(self.ImportBox.EditBox);
	self.AcceptButton:SetEnabled(importTextFilled);
end

function ClassTalentLoadoutImportDialogMixin:OnTextChanged()
	self:UpdateAcceptButtonEnabledState();
	InputScrollFrame_OnTextChanged(self.ImportBox.EditBox);
end

function ClassTalentLoadoutImportDialogMixin:ShowDialog()
	self.ImportBox.EditBox:SetText("");
	StaticPopupSpecial_Show(self);
	self.ImportBox.EditBox:SetFocus();
end