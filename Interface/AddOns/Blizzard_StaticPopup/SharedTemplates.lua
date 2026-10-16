StaticPopupElementMixin = {};

function StaticPopupElementMixin:SetOwningDialog(dialog)
	self.owningDialog = dialog;
end

function StaticPopupElementMixin:GetOwningDialog()
	return self.owningDialog;
end

function StaticPopupElementMixin:GetOwningDialogInfo()
	local dialog = self:GetOwningDialog();
	return dialog and dialog.dialogInfo;
end

function StaticPopupElementMixin:GetOwningDialogData()
	local dialog = self:GetOwningDialog();
	return dialog and dialog.data;
end

StaticPopupEditBoxMixin = CreateFromMixins(StaticPopupElementMixin);

local StaticPopupEditBoxAttributes = {
	ClearEditBox = "clear-editbox",
};

function StaticPopupEditBoxMixin:OnAttributeChanged(attr)
	if attr == StaticPopupEditBoxAttributes.ClearEditBox then
		self:SetText("");
		self:SetSecureText(false);
	end
end

local function GetDialog(editBox)
	local parent = editBox:GetParent();
	if parent.which then
		return parent;
	end

	-- This is needed if this is a money input frame since it's nested deeper than a normal edit box
	return GetDialog(parent);
end

function StaticPopupEditBoxMixin:OnEnterPressed()
	-- Note: This function can be invoked standalone on editboxes that don't
	-- have the mixin applied - see handling of hasMoneyInputFrame in GameDialogMixin:Init
	local dialog = GetDialog(self);
	local which = dialog.which;
	if ( not self.hasAutoComplete or not AutoCompleteEditBox_OnEnterPressed(self) ) then
		local EditBoxOnEnterPressed = StaticPopupDialogs[which].EditBoxOnEnterPressed;
		if ( EditBoxOnEnterPressed ) then
			EditBoxOnEnterPressed(self, dialog.data);
		elseif dialog.dialogInfo.hasConfirmationEditBox then
			dialog:GetButton1():Click();
		end
	end
end

function StaticPopupEditBoxMixin:OnEscapePressed()
	local dialog = GetDialog(self);
	local EditBoxOnEscapePressed = StaticPopupDialogs[dialog.which].EditBoxOnEscapePressed;
	if ( EditBoxOnEscapePressed ) then
		EditBoxOnEscapePressed(self, self:GetParent().data);
	elseif dialog.dialogInfo.hasConfirmationEditBox then
		StaticPopup_StandardEditBoxOnEscapePressed(self);
	end
end

function StaticPopupEditBoxMixin:OnTextChanged(userInput)
	local dialog = GetDialog(self);
	if ( not self.hasAutoComplete or not AutoCompleteEditBox_OnTextChanged(self, userInput) ) then
		local EditBoxOnTextChanged = StaticPopupDialogs[self:GetParent().which].EditBoxOnTextChanged;
		if ( EditBoxOnTextChanged ) then
			EditBoxOnTextChanged(self, self:GetParent().data);
		elseif dialog.dialogInfo.hasConfirmationEditBox then
			StaticPopup_StandardConfirmationTextHandler(self, dialog.dialogInfo.confirmationString);
		end
	end
	self.Instructions:SetShown(self:GetText() == "");
end

function StaticPopupEditBoxMixin:ClearText()
	self:SetAttribute(StaticPopupEditBoxAttributes.ClearEditBox, true);
end
