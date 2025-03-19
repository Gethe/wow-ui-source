ClassTalentLoadoutImportDialogMixin = {};

function ClassTalentLoadoutImportDialogMixin:OnLoad()
	self.exclusive = true;
	self.AcceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self));
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self));
	ClassTalentLoadoutDialogMixin.OnLoad(self);

	self.NameControl:GetEditBox():SetAutoFocus(false);
	self.ImportControl:GetEditBox():SetAutoFocus(true);
end

function ClassTalentLoadoutImportDialogMixin:OnHide()

end

function ClassTalentLoadoutImportDialogMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end

function ClassTalentLoadoutImportDialogMixin:OnAccept()
	if self.AcceptButton:IsEnabled() then
		local importText = self.ImportControl:GetText();
		local loadoutName = self.NameControl:GetText();
		local success = PlayerSpellsFrame.TalentsFrame:ImportLoadout(importText, loadoutName);
		
		if success then
			StaticPopupSpecial_Hide(self);
		end
	end
end

function ClassTalentLoadoutImportDialogMixin:UpdateAcceptButtonEnabledState()
	local importTextFilled = self.ImportControl:HasText();
	local nameTextFilled = self.NameControl:HasText();
	self.AcceptButton:SetEnabled(importTextFilled and nameTextFilled);
end

function ClassTalentLoadoutImportDialogMixin:OnTextChanged()
	self:UpdateAcceptButtonEnabledState();
end

function ClassTalentLoadoutImportDialogMixin:ShowDialog()
	StaticPopupSpecial_Show(self);
end


ClassTalentLoadoutImportDialogImportControlMixin = CreateFromMixins(ClassTalentLoadoutDialogInputControlMixin);

function ClassTalentLoadoutImportDialogImportControlMixin:OnShow()
	ClassTalentLoadoutDialogInputControlMixin.OnShow(self);
end

function ClassTalentLoadoutImportDialogImportControlMixin:OnEnterPressed()
	self:GetParent():OnAccept();
end

function ClassTalentLoadoutImportDialogImportControlMixin:OnEscapePressed()
	self:GetParent():OnCancel();
end

function ClassTalentLoadoutImportDialogImportControlMixin:OnTextChanged()
	self:GetParent():OnTextChanged();
	InputScrollFrame_OnTextChanged(self.InputContainer.EditBox);
end

function ClassTalentLoadoutImportDialogImportControlMixin:GetEditBox()
	return self.InputContainer.EditBox;
end


ClassTalentLoadoutImportDialogNameControlMixin = {}

function ClassTalentLoadoutImportDialogNameControlMixin:OnEnterPressed()
	self:GetParent():OnAccept();
end

function ClassTalentLoadoutImportDialogNameControlMixin:OnEscapePressed()
	self:GetParent():OnCancel();
end

function ClassTalentLoadoutImportDialogNameControlMixin:OnTextChanged()
	self:GetParent():OnTextChanged();
end