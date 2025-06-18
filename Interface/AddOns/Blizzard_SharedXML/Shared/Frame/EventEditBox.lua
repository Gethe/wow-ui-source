EventEditBoxMixin = CreateFromMixins(CallbackRegistryMixin);

EventEditBoxMixin:GenerateCallbackEvents(
	{
		"OnMouseDown",
		"OnMouseUp",
		"OnTabPressed",
		"OnTextChanged",
		"OnCursorChanged",
		"OnEscapePressed",
		"OnEnterPressed",
		"OnKeyDown",
		"OnEditFocusGained",
		"OnEditFocusLost",
	}
);

function EventEditBoxMixin:OnLoad_Intrinsic()
	CallbackRegistryMixin.OnLoad(self);

	self.defaultTextEnabled = true;
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
		self.defaulted = self:IsDefaultTextEnabled() and self:GetText() == "";
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
	self:TriggerEvent("OnEscapePressed", self);
end

function EventEditBoxMixin:OnEnterPressed_Intrinsic()
	self:TriggerEvent("OnEnterPressed", self);
end

function EventEditBoxMixin:OnKeyDown_Intrinsic(key)
	self:TriggerEvent("OnKeyDown", self, key);
end

function EventEditBoxMixin:OnEditFocusGained_Intrinsic()
	if self:IsDefaultTextDisplayed() then
		self:SetText("");
		self:SetFontObject(self.fontName);

		if self.textColor then
			self:SetTextColor(self.textColor:GetRGB());
		else
			self:SetTextColor(1, 1, 1);
		end

		self:SetCursorPosition(0);
	end

	self:TriggerEvent("OnEditFocusGained", self);
end

function EventEditBoxMixin:OnEditFocusLost_Intrinsic()
	self:ClearHighlightText();

	-- HasFocus() returns 'true' if this event occured while transferred focus to another frame. 
	-- Conversely, if this event occured due to a call to ClearFocus(), HasFocus returns 'false'.
	-- Will be discussed to fix, but in the meantime, force ShouldDefault() to return as if focus
	-- actually was cleared in the former case.
	self.expectNoFocus = true;

	local text = self:GetText();
	if self:ShouldDefault(text) then
		self:ApplyText("");
	end

	self:TriggerEvent("OnEditFocusLost", self);
	
	self.expectNoFocus = false;
end

function EventEditBoxMixin:ExpectedHasFocus()
	if self.expectNoFocus then
		return false;
	end

	return self:HasFocus();
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
	self.defaulted = self:ShouldDefault(text);
	if self.defaulted then
		self:SetText(self.defaultText);

		if self.defaultFontName then
			self:SetFontObject(self.defaultFontName);
		end
		
		if self.defaultFontColor then
			self:SetTextColor(self.defaultFontColor:GetRGB());
		else
			self:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		end
	else
		self:SetText(text);
		self:SetFontObject(self.fontName);

		if self.textColor then
			self:SetTextColor(self.textColor:GetRGB());
		else
			self:SetTextColor(1, 1, 1);
		end
	end
	self:SetCursorPosition(0);
end

function EventEditBoxMixin:ApplyDefaultText(defaultText)
	self.defaultText = defaultText;
	
	self:TryApplyDefaultText();
end

function EventEditBoxMixin:SetDefaultTextEnabled(enabled)
	self.defaultTextEnabled = enabled;
end

function EventEditBoxMixin:IsDefaultTextEnabled()
	return self.defaultText and self.defaultTextEnabled;
end

function EventEditBoxMixin:ShouldDefault(text)
	if text ~= "" then
		return false;
	end

	if not self:IsDefaultTextEnabled() then
		return false;
	end

	if self:ExpectedHasFocus() then
		return false;
	end

	return true;
end

function EventEditBoxMixin:TryApplyDefaultText()
	local text = self:GetText();
	if self:ShouldDefault(text) then
		self:ApplyText("");
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
		self:SetTextColor(color:GetRGB());
	end
end

function EventEditBoxMixin:ApplyDefaultTextColor(color)
	self.defaultFontColor = color;

	if self:IsDefaultTextDisplayed() then
		self:SetTextColor(color:GetRGB());
	end
end