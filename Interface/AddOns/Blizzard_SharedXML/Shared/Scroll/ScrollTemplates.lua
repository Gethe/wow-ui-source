ScrollingEditBoxMixin = CreateFromMixins(CallbackRegistryMixin);
ScrollingEditBoxMixin:GenerateCallbackEvents(
	{
		"OnTabPressed",
		"OnTextChanged",
		"OnCursorChanged",
		"OnFocusGained",
		"OnFocusLost",
		"OnEnterPressed",
	}
);

function ScrollingEditBoxMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	
	assert(self.fontName);

	local scrollBox = self:GetScrollBox();
	scrollBox:SetAlignmentOverlapIgnored(true);

	self:SetInterpolateScroll(self.canInterpolateScroll);

	local editBox = self:GetEditBox();
	
	if self.maxLetters then
		editBox:SetMaxLetters(self.maxLetters);
	end

	editBox.fontName = self.fontName;
	editBox.defaultFontName = self.defaultFontName;
	editBox:SetFontObject(self.fontName);
	
	if self.fontColor then
		self:SetTextColor(self.fontColor);
	end

	if self.defaultFontColor then
		self:SetDefaultTextColor(self.defaultFontColor);
	end

	if self.defaultText then
		self:SetDefaultText(self.defaultText);
	end

	local fontHeight = editBox:GetFontHeight();
	local bottomPadding = fontHeight * .5;
	local view = CreateScrollBoxLinearView(0, bottomPadding, 0, 0, 0);
	view:SetPanExtent(fontHeight);
	scrollBox:Init(view);

	editBox:RegisterCallback("OnTabPressed", self.OnEditBoxTabPressed, self);
	editBox:RegisterCallback("OnTextChanged", self.OnEditBoxTextChanged, self);
	editBox:RegisterCallback("OnEnterPressed", self.OnEditBoxEnterPressed, self);
	editBox:RegisterCallback("OnCursorChanged", self.OnEditBoxCursorChanged, self);
	editBox:RegisterCallback("OnEditFocusGained", self.OnEditBoxFocusGained, self);
	editBox:RegisterCallback("OnEditFocusLost", self.OnEditBoxFocusLost, self);
	editBox:RegisterCallback("OnMouseUp", self.OnEditBoxMouseUp, self);
end

function ScrollingEditBoxMixin:SetInterpolateScroll(canInterpolateScroll)
	local scrollBox = self:GetScrollBox();
	scrollBox:SetInterpolateScroll(canInterpolateScroll);
end

function ScrollingEditBoxMixin:OnShow()
	local editBox = self:GetEditBox();
	editBox:TryApplyDefaultText();
end

function ScrollingEditBoxMixin:OnMouseDown()
	local editBox = self:GetEditBox();
	editBox:SetFocus();
end

function ScrollingEditBoxMixin:OnEditBoxMouseUp()
	local allowCursorClipping = false;
	self:ScrollCursorIntoView(allowCursorClipping);
end

function ScrollingEditBoxMixin:GetScrollBox()
	return self.ScrollBox;
end

function ScrollingEditBoxMixin:HasScrollableExtent()
	local scrollBox = self:GetScrollBox();
	return scrollBox:HasScrollableExtent();
end

function ScrollingEditBoxMixin:GetEditBox()
	return self:GetScrollBox().EditBox;
end

function ScrollingEditBoxMixin:SetFocus()
	self:GetEditBox():SetFocus();
end

function ScrollingEditBoxMixin:SetFontObject(fontName)
	local editBox = self:GetEditBox();
	editBox:SetFontObject(fontName);

	local scrollBox = self:GetScrollBox();
	local fontHeight = editBox:GetFontHeight();
	local padding = scrollBox:GetPadding();
	padding:SetBottom(fontHeight * .5);

	scrollBox:SetPanExtent(fontHeight);
	scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
	scrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function ScrollingEditBoxMixin:ClearText()
	self:SetText("");
end

function ScrollingEditBoxMixin:SetText(text)
	local editBox = self:GetEditBox();
	editBox:ApplyText(text);

	local scrollBox = self:GetScrollBox();
	scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
	scrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function ScrollingEditBoxMixin:SetDefaultTextEnabled(enabled)
	local editBox = self:GetEditBox();
	editBox:SetDefaultTextEnabled(enabled);
end

function ScrollingEditBoxMixin:SetDefaultText(defaultText)
	local editBox = self:GetEditBox();
	editBox:ApplyDefaultText(defaultText);
end

function ScrollingEditBoxMixin:SetTextColor(color)
	local editBox = self:GetEditBox();
	editBox:ApplyTextColor(color);
end

function ScrollingEditBoxMixin:SetDefaultTextColor(color)
	local editBox = self:GetEditBox();
	editBox:ApplyDefaultTextColor(color);
end

function ScrollingEditBoxMixin:GetInputText()
	local editBox = self:GetEditBox();
	return editBox:GetInputText();
end

function ScrollingEditBoxMixin:GetFontHeight()
	local editBox = self:GetEditBox();
	return editBox:GetFontHeight();
end

function ScrollingEditBoxMixin:ClearFocus()
	local editBox = self:GetEditBox();
	editBox:ClearFocus();
end

function ScrollingEditBoxMixin:SetEnabled(enabled)
	local editBox = self:GetEditBox();
	editBox:SetEnabled(enabled);
end

function ScrollingEditBoxMixin:OnEditBoxTabPressed(editBox)
	self:TriggerEvent("OnTabPressed", editBox);
end

function ScrollingEditBoxMixin:OnEditBoxTextChanged(editBox, userChanged)
	local scrollBox = self:GetScrollBox();
	scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);

	self:TriggerEvent("OnTextChanged", editBox, userChanged);
end

function ScrollingEditBoxMixin:OnEditBoxEnterPressed(editBox)
	self:TriggerEvent("OnEnterPressed", editBox);
end

function ScrollingEditBoxMixin:OnEditBoxCursorChanged(editBox, x, y, width, height, context)
	local scrollBox = self:GetScrollBox();
	scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);

	local allowCursorClipping = context ~= Enum.InputContext.Keyboard;
	self:ScrollCursorIntoView(allowCursorClipping);

	self:TriggerEvent("OnCursorChanged", editBox, x, y, width, height);
end

function ScrollingEditBoxMixin:OnEditBoxFocusGained(editBox)
	self:TriggerEvent("OnFocusGained", editBox);
end

function ScrollingEditBoxMixin:OnEditBoxFocusLost(editBox)
	self:TriggerEvent("OnFocusLost", editBox);
end

function ScrollingEditBoxMixin:ScrollCursorIntoView(allowCursorClipping)
	local editBox = self:GetEditBox();
	local cursorOffset = -editBox:GetCursorOffset();
	local cursorHeight = editBox:GetCursorHeight();

	local scrollBox = self:GetScrollBox();
	local editBoxExtent = scrollBox:GetFrameExtent(editBox);
	if editBoxExtent <= 0 then
		return;
	end

	local scrollOffset = Round(scrollBox:GetDerivedScrollOffset());
	if cursorOffset < scrollOffset then
		local visibleExtent = scrollBox:GetVisibleExtent();
		local deltaExtent = editBoxExtent - visibleExtent;
		if deltaExtent > 0 then
			local percentage = cursorOffset / deltaExtent;
			scrollBox:ScrollToFrame(editBox, percentage);
		end
	else
		local visibleExtent = scrollBox:GetVisibleExtent();
		local offset = allowCursorClipping and cursorOffset or (cursorOffset + cursorHeight);
		if offset >= (scrollOffset + visibleExtent) then
			local deltaExtent = editBoxExtent - visibleExtent;
			if deltaExtent > 0 then
				local descenderPadding = math.floor(cursorHeight * .3);
				local cursorDeltaExtent = offset - visibleExtent;
				if cursorDeltaExtent + descenderPadding > deltaExtent then
					scrollBox:ScrollToEnd();
				else
					local percentage = (cursorDeltaExtent + descenderPadding) / deltaExtent;
					scrollBox:ScrollToFrame(editBox, percentage);
				end
			end
		end
	end
end

ScrollingFontMixin = {};

function ScrollingFontMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	
	assert(self.fontName);
	
	local scrollBox = self:GetScrollBox();
	scrollBox:SetAlignmentOverlapIgnored(true);

	local fontString = self:GetFontString();
	fontString:SetFontObject(self.fontName);

	local fontHeight = select(2, fontString:GetFont());
	local bottomPadding = fontHeight * .5;
	local view = CreateScrollBoxLinearView(0, bottomPadding, 0, 0, 0);
	view:SetPanExtent(fontHeight);
	scrollBox:Init(view);

	local width = scrollBox:GetWidth();
	local fontStringContainer = self:GetFontStringContainer();
	fontStringContainer:SetWidth(width);
	fontString:SetWidth(width);
end

function ScrollingFontMixin:OnSizeChanged(width, height)
	local scrollBox = self:GetScrollBox();
	scrollBox:SetWidth(width);

	local fontString = self:GetFontString();
	fontString:SetWidth(width);

	local fontStringContainer = self:GetFontStringContainer();
	fontStringContainer:SetWidth(width);
	fontStringContainer:SetHeight(fontString:GetStringHeight());
end

function ScrollingFontMixin:GetScrollBox()
	return self.ScrollBox;
end

function ScrollingFontMixin:HasScrollableExtent()
	local scrollBox = self:GetScrollBox();
	return scrollBox:HasScrollableExtent();
end

function ScrollingFontMixin:GetFontString()
	local fontStringContainer = self:GetFontStringContainer();
	return fontStringContainer.FontString;
end

function ScrollingFontMixin:GetFontStringContainer()
	local scrollBox = self:GetScrollBox();
	return scrollBox.FontStringContainer;
end

function ScrollingFontMixin:SetText(text)
	local fontString = self:GetFontString();
	fontString:SetText(text);
	local height = fontString:GetStringHeight();	

	local fontStringContainer = self:GetFontStringContainer();
	fontStringContainer:SetHeight(height);

	local scrollBox = self:GetScrollBox();
	scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
	scrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function ScrollingFontMixin:SetTextColor(color)
	local fontString = self:GetFontString();
	fontString:SetTextColor(color:GetRGB());
end

function ScrollingFontMixin:ClearText()
	self:SetText("");
end

function ScrollingFontMixin:SetTextColor(color)
	local fontString = self:GetFontString();
	fontString:SetTextColor(color:GetRGB());
end

function ScrollingFontMixin:SetFontObject(fontName)
	local fontString = self:GetFontString();
	fontString:SetFontObject(fontName);
	
	local fontStringContainer = self:GetFontStringContainer();
	fontStringContainer:SetHeight(fontString:GetStringHeight());

	local scrollBox = self:GetScrollBox();
	local fontHeight = select(2, fontString:GetFont());
	local padding = scrollBox:GetPadding();
	padding:SetBottom(fontHeight * .5);

	scrollBox:SetPanExtent(fontHeight);
	scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
	scrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end