EventEditBoxMixin = CreateFromMixins(CallbackRegistryMixin);

EventEditBoxMixin:GenerateCallbackEvents(
	{
		"OnMouseDown",
		"OnMouseUp",
		"OnTabPressed",
		"OnTextChanged",
		"OnCursorChanged",
		"OnEscapePressed",
		"OnEditFocusGained",
		"OnEditFocusLost",
	}
);

function EventEditBoxMixin:OnLoad_Intrinsic()
	CallbackRegistryMixin.OnLoad(self);
end

function EventEditBoxMixin:OnMouseDown_Intrinsic()
	self:SetFocus();
	self:TriggerEvent("OnMouseDown", self);
end

function EventEditBoxMixin:OnMouseUp_Intrinsic()
	self:TriggerEvent("OnMouseUp", self);
end

function EventEditBoxMixin:OnTabPressed_Intrinsic()
	self:TriggerEvent("OnTabPressed", self);
end

function EventEditBoxMixin:OnTextChanged_Intrinsic(userChanged)
	if userChanged then
		self.defaulted = self.defaultText and self:GetText() == "";
	end

	self:TriggerEvent("OnTextChanged", self, userChanged);
end

function EventEditBoxMixin:OnCursorChanged_Intrinsic(x, y, width, height, context)
	self.cursorOffset = y;
	self.cursorHeight = height;

	if self:HasFocus() then
		self:TriggerEvent("OnCursorChanged", self, x, y, width, height, context);
	end
end

function EventEditBoxMixin:OnEscapePressed_Intrinsic()
	self:ClearFocus();

	self:TriggerEvent("OnEscapePressed", self);
end

function EventEditBoxMixin:OnEditFocusGained_Intrinsic()
	if self:IsDefaultTextDisplayed() then
		self:SetText("");
		self:SetTextColor(self:GetTextColorRGB());
		self:SetCursorPosition(0);
	end

	self:TriggerEvent("OnEditFocusGained", self);
end

function EventEditBoxMixin:OnEditFocusLost_Intrinsic()
	self:ClearHighlightText();

	self:TryApplyDefaultText();

	self:TriggerEvent("OnEditFocusLost", self);
end

function EventEditBoxMixin:GetCursorOffset()
	return self.cursorOffset or 0;
end

function EventEditBoxMixin:GetCursorHeight()
	return self.cursorHeight or 0;
end

function EventEditBoxMixin:GetFontHeight()
	return select(2, self:GetFont());
end

function EventEditBoxMixin:ApplyText(text)
	self.defaulted = self.defaultText and text == "";
	if self.defaulted then
		self:SetText(self.defaultText);
		self:SetTextColor(GRAY_FONT_COLOR:GetRGB());
	else
		self:SetText(text);
		self:SetTextColor(self:GetTextColorRGB());
	end
	self:SetCursorPosition(0);
end

function EventEditBoxMixin:ApplyDefaultText(defaultText)
	self.defaultText = defaultText;
	
	self:TryApplyDefaultText();
end

function EventEditBoxMixin:TryApplyDefaultText()
	if self.defaultText then
		if self:GetText() == "" then
			self:SetText(self.defaultText);
			self:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			self:SetCursorPosition(0);
		end
	end
end

function EventEditBoxMixin:GetInputText()
	if not self.defaulted then
		return self:GetText();
	end
	return "";
end

function EventEditBoxMixin:IsDefaultTextDisplayed()
	if self.defaulted then
		return self:GetText() == self.defaultText;
	end
	return false;
end

function EventEditBoxMixin:ApplyTextColor(color)
	self.textColor = color;

	if not self:IsDefaultTextDisplayed() then
		self:SetTextColor(self:GetTextColorRGB());
	end
end

function EventEditBoxMixin:GetTextColorRGB()
	return self.textColor:GetRGB();
end
