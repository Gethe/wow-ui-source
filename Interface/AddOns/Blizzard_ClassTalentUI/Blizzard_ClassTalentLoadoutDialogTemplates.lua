ClassTalentLoadoutDialogMixin = {};

function ClassTalentLoadoutDialogMixin:OnLoad()
	self.Title:SetText(self.titleText);
end


ClassTalentLoadoutDialogInputControlMixin = {};

function ClassTalentLoadoutDialogInputControlMixin:OnLoad()
	local editBox = self:GetEditBox();
	editBox:SetScript("OnTextChanged", GenerateClosure(self.OnTextChanged, self));
	editBox:SetScript("OnEnterPressed", GenerateClosure(self.OnEnterPressed, self));
	editBox:SetScript("OnEscapePressed", GenerateClosure(self.OnEscapePressed, self));
	self.Label:SetText(self.labelText);
end

function ClassTalentLoadoutDialogInputControlMixin:OnShow()
	self:GetEditBox():SetText("");
end

function ClassTalentLoadoutDialogInputControlMixin:GetText()
	return self:GetEditBox():GetText();
end

function ClassTalentLoadoutDialogInputControlMixin:SetText(text)
	return self:GetEditBox():SetText(text);
end

function ClassTalentLoadoutDialogInputControlMixin:HasText()
	return UserEditBoxNonEmpty(self:GetEditBox());
end

function ClassTalentLoadoutDialogInputControlMixin:OnEnterPressed()
	-- Override in derived
end

function ClassTalentLoadoutDialogInputControlMixin:OnEscapePressed()
	-- Override in derived
end

function ClassTalentLoadoutDialogInputControlMixin:OnTextChanged()
	-- Override in derived
end

function ClassTalentLoadoutDialogInputControlMixin:GetEditBox()
	-- Override in derived
end

ClassTalentLoadoutDialogNameControlMixin = CreateFromMixins(ClassTalentLoadoutDialogInputControlMixin);

function ClassTalentLoadoutDialogNameControlMixin:GetEditBox()
	return self.EditBox;
end