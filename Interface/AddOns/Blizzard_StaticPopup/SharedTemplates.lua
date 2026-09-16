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

function StaticPopupEditBoxMixin:OnEnterPressed()
	-- Note: This function can be invoked standalone on editboxes that don't
	-- have the mixin applied - see handling of hasMoneyInputFrame in GameDialogMixin:Init
	local EditBoxOnEnterPressed, which, dialog;
	local parent = self:GetParent();
	if ( parent.which ) then
		which = parent.which;
		dialog = parent;
	elseif ( parent:GetParent().which ) then
		-- This is needed if this is a money input frame since it's nested deeper than a normal edit box
		which = parent:GetParent().which;
		dialog = parent:GetParent();
	end
	if ( not self.hasAutoComplete or not AutoCompleteEditBox_OnEnterPressed(self) ) then
		EditBoxOnEnterPressed = StaticPopupDialogs[which].EditBoxOnEnterPressed;
		if ( EditBoxOnEnterPressed ) then
			EditBoxOnEnterPressed(self, dialog.data);
		end
	end
end

function StaticPopupEditBoxMixin:OnEscapePressed()
	local EditBoxOnEscapePressed = StaticPopupDialogs[self:GetParent().which].EditBoxOnEscapePressed;
	if ( EditBoxOnEscapePressed ) then
		EditBoxOnEscapePressed(self, self:GetParent().data);
	end
end

function StaticPopupEditBoxMixin:OnTextChanged(userInput)
	if ( not self.hasAutoComplete or not AutoCompleteEditBox_OnTextChanged(self, userInput) ) then
		local EditBoxOnTextChanged = StaticPopupDialogs[self:GetParent().which].EditBoxOnTextChanged;
		if ( EditBoxOnTextChanged ) then
			EditBoxOnTextChanged(self, self:GetParent().data);
		end
	end
	self.Instructions:SetShown(self:GetText() == "");
end

function StaticPopupEditBoxMixin:ClearText()
	self:SetAttribute(StaticPopupEditBoxAttributes.ClearEditBox, true);
end