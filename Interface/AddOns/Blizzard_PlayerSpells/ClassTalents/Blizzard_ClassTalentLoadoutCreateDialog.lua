ClassTalentLoadoutCreateDialogMixin = {};

function ClassTalentLoadoutCreateDialogMixin:OnLoad()
	self.exclusive = true;
	self.AcceptButton:SetOnClickHandler(GenerateClosure(self.OnAccept, self));
	self.CancelButton:SetOnClickHandler(GenerateClosure(self.OnCancel, self));
	ClassTalentLoadoutDialogMixin.OnLoad(self);
end

function ClassTalentLoadoutCreateDialogMixin:UpdateAcceptButtonEnabledState()
	local nameTextFilled = self.NameControl:HasText();
	self.AcceptButton:SetEnabled(nameTextFilled);
end

function ClassTalentLoadoutCreateDialogMixin:OnTextChanged()
	self:UpdateAcceptButtonEnabledState();
end

function ClassTalentLoadoutCreateDialogMixin:OnAccept()
	if self.AcceptButton:IsEnabled() then
		local loadoutName = self.NameControl:GetText();

		StaticPopupSpecial_Hide(self);

		self.acceptCallback(loadoutName);
	end
end

function ClassTalentLoadoutCreateDialogMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end


function ClassTalentLoadoutCreateDialogMixin:ShowDialog(acceptCallback)
	self.acceptCallback = acceptCallback;
	StaticPopupSpecial_Show(self);
end

ClassTalentLoadoutCreateDialogNameControlMixin = {};

function ClassTalentLoadoutCreateDialogNameControlMixin:OnShow()
	ClassTalentLoadoutDialogNameControlMixin.OnShow(self);
	self:GetEditBox():SetFocus();
end

function ClassTalentLoadoutCreateDialogNameControlMixin:OnEnterPressed()
	self:GetParent():OnAccept();
end

function ClassTalentLoadoutCreateDialogNameControlMixin:OnEscapePressed()
	self:GetParent():OnCancel();
end

function ClassTalentLoadoutCreateDialogNameControlMixin:OnTextChanged()
	self:GetParent():OnTextChanged();
end