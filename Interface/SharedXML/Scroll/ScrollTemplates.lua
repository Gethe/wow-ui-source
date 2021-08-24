WowScrollBarStepperButtonScriptsMixin = {};

function WowScrollBarStepperButtonScriptsMixin:OnEnter()
	self.Overlay:SetAtlas(self.overTexture, TextureKitConstants.UseAtlasSize);
	self.Overlay:Show();
end

function WowScrollBarStepperButtonScriptsMixin:OnLeave()
	self.Overlay:Hide();
end

function WowScrollBarStepperButtonScriptsMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Texture:SetAtlas(self.downTexture, TextureKitConstants.UseAtlasSize);
		self.Texture:AdjustPointsOffset(-1, 0);
		self.Overlay:AdjustPointsOffset(-1, -1);
	end
end

function WowScrollBarStepperButtonScriptsMixin:OnMouseUp()
	if self:IsEnabled() then
		self.Texture:SetAtlas(self.normalTexture, TextureKitConstants.UseAtlasSize);
		self.Texture:AdjustPointsOffset(1, 0);
		self.Overlay:AdjustPointsOffset(1, 1);
	end
end

function WowScrollBarStepperButtonScriptsMixin:OnDisable()
	self.Texture:SetAtlas(self.disabledTexture, TextureKitConstants.UseAtlasSize);
	self.Texture:ClearPointsOffset();
end

function WowScrollBarStepperButtonScriptsMixin:OnEnable()
	self.Texture:SetAtlas(self.normalTexture, TextureKitConstants.UseAtlasSize);
end

function WowScrollBarStepperButtonScriptsMixin:OnDisable()
	self.Texture:SetAtlas(self.disabledTexture, TextureKitConstants.UseAtlasSize);
end

WowScrollBarThumbButtonScriptsMixin = {};

function WowScrollBarThumbButtonScriptsMixin:OnLoad()
	self:ApplyNormalAtlas();
end

function WowScrollBarThumbButtonScriptsMixin:OnEnter()
	self.Begin:SetAtlas(self.overBeginTexture, TextureKitConstants.UseAtlasSize);
	self.End:SetAtlas(self.overEndTexture, TextureKitConstants.UseAtlasSize);
	self.Middle:SetAtlas(self.overMiddleTexture, TextureKitConstants.UseAtlasSize);
end

function WowScrollBarThumbButtonScriptsMixin:ApplyNormalAtlas()
	self.Begin:SetAtlas(self.normalBeginTexture, TextureKitConstants.UseAtlasSize);
	self.End:SetAtlas(self.normalEndTexture, TextureKitConstants.UseAtlasSize);
	self.Middle:SetAtlas(self.normalMiddleTexture, TextureKitConstants.UseAtlasSize);
end

function WowScrollBarThumbButtonScriptsMixin:OnLeave()
	self:ApplyNormalAtlas();
end

function WowScrollBarThumbButtonScriptsMixin:OnEnable()
	self:ApplyNormalAtlas();
end

function WowScrollBarThumbButtonScriptsMixin:OnDisable()
	self.Begin:SetAtlas(self.disabledBeginTexture, TextureKitConstants.UseAtlasSize);
	self.End:SetAtlas(self.disabledEndTexture, TextureKitConstants.UseAtlasSize);
	self.Middle:SetAtlas(self.disabledMiddleTexture, TextureKitConstants.UseAtlasSize);
end

function WowScrollBarThumbButtonScriptsMixin:OnSizeChanged(width, height)
	local info = C_Texture.GetAtlasInfo(self.Middle:GetAtlas());
	if self.isHorizontal then
		self.Middle:SetWidth(width);
		local u = width / info.width;
		self.Middle:SetTexCoord(0, u, 0, 1);
	else
		self.Middle:SetHeight(height);
		local v = height / info.height;
		self.Middle:SetTexCoord(0, 1, 0, v);
	end
end

WowTrimScrollBarMixin = {};

function WowTrimScrollBarMixin:OnLoad()
	ScrollBarMixin.OnLoad(self);

	if self.hideBackground then
		self.Background:Hide();
	end
	
	if self.trackAlpha then
		self.Track:SetAlpha(self.trackAlpha);
	end
end

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
	
	local scrollBox = self:GetScrollBox();
	scrollBox:SetAlignmentOverlapIgnored(true);

	local fontHeight = 10;
	local editBox = self:GetEditBox();
	if self.fontName then
		editBox:SetFontObject(self.fontName);
		fontHeight = editBox:GetFontHeight();
	end
	
	if self.maxLetters then
		editBox:SetMaxLetters(self.maxLetters);
	end

	if self.textColor then
		self:SetTextColor(self.textColor);
	end

	if self.defaultText then
		self:SetDefaultText(self.defaultText);
	end

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

function ScrollingEditBoxMixin:SetFontObject(fontName)
	local editBox = self:GetEditBox();
	editBox:SetFontObject(fontName);

	local scrollBox = self:GetScrollBox();
	local fontHeight = editBox:GetFontHeight();
	local padding = scrollBox:GetPadding();
	padding:SetBottom(fontHeight * .5);

	scrollBox:SetPanExtent(fontHeight);
	scrollBox:UpdateImmediately();
	scrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function ScrollingEditBoxMixin:ClearText()
	self:SetText("");
end

function ScrollingEditBoxMixin:SetText(text)
	local editBox = self:GetEditBox();
	editBox:ApplyText(text);

	local scrollBox = self:GetScrollBox();
	scrollBox:UpdateImmediately();
	scrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function ScrollingEditBoxMixin:SetDefaultText(defaultText)
	local editBox = self:GetEditBox();
	editBox:ApplyDefaultText(defaultText);
end

function ScrollingEditBoxMixin:SetTextColor(color)
	local editBox = self:GetEditBox();
	editBox:ApplyTextColor(color);
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

function ScrollingEditBoxMixin:OnEditBoxTabPressed(editBox)
	self:TriggerEvent("OnTabPressed", editBox);
end

function ScrollingEditBoxMixin:OnEditBoxTextChanged(editBox, userChanged)
	local scrollBox = self:GetScrollBox();
	scrollBox:UpdateImmediately();

	self:TriggerEvent("OnTextChanged", editBox, userChanged);
end

function ScrollingEditBoxMixin:OnEditBoxEnterPressed(editBox)
	self:TriggerEvent("OnEnterPressed", editBox);
end

function ScrollingEditBoxMixin:OnEditBoxCursorChanged(editBox, x, y, width, height, context)
	local scrollBox = self:GetScrollBox();
	scrollBox:UpdateImmediately();

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

	local scrollOffset = scrollBox:GetDerivedScrollOffset();
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
	
	local fontHeight = 10;
	local fontString = self:GetFontString();
	if self.fontName then
		fontString:SetFontObject(self.fontName);
		fontHeight = select(2, fontString:GetFont());
	end

	local scrollBox = self:GetScrollBox();
	scrollBox:SetAlignmentOverlapIgnored(true);

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

	local fontStringContainer = self:GetFontStringContainer();
	fontStringContainer:SetWidth(width);

	local fontString = self:GetFontString();
	fontString:SetWidth(width);
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
	scrollBox:UpdateImmediately();
	scrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function ScrollingFontMixin:ClearText()
	self:SetText("");
end

function ScrollingFontMixin:SetTextColor(color)
	local fontString = self:GetFontString();
	fontString:SetTextColor(color.r, color.g, color.b);
end

function ScrollingFontMixin:SetFontObject(fontName)
	local fontString = self:GetFontString();
	fontString:SetFontObject(fontName);
	
	local scrollBox = self:GetScrollBox();
	local fontHeight = select(2, fontString:GetFont());
	local padding = scrollBox:GetPadding();
	padding:SetBottom(fontHeight * .5);

	scrollBox:SetPanExtent(fontHeight);
	scrollBox:UpdateImmediately();
	scrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end