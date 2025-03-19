
function EditBox_OnTabPressed(self)
	if ( self.previousEditBox and IsShiftKeyDown() ) then
		self.previousEditBox:SetFocus();
	elseif ( self.nextEditBox ) then
		self.nextEditBox:SetFocus();
	end
end

function EditBox_ClearFocus(self)
	self:ClearFocus();
end

function EditBox_HighlightText(self)
	self:HighlightText();
end

function EditBox_ClearHighlight(self)
	self:HighlightText(0, 0);
end

function ScrollFrame_OnLoad(self)
	if not self.noScrollBar then
		local scrollBarTemplate = self.scrollBarTemplate or SCROLL_FRAME_SCROLL_BAR_TEMPLATE;
		if not scrollBarTemplate then
			error("SCROLL_FRAME_SCROLL_BAR_TEMPLATE undefined. Check ScrollDefine.lua")
		end
		
		local left = self.scrollBarX or SCROLL_FRAME_SCROLL_BAR_OFFSET_LEFT;
		if not left then
			error("SCROLL_FRAME_SCROLL_BAR_OFFSET_LEFT undefined. Check ScrollDefine.lua")
		end

		local top = self.scrollBarTopY or SCROLL_FRAME_SCROLL_BAR_OFFSET_TOP;
		if not top then
			error("SCROLL_FRAME_SCROLL_BAR_OFFSET_TOP undefined. Check ScrollDefine.lua")
		end

		local bottom = self.scrollBarBottomY or SCROLL_FRAME_SCROLL_BAR_OFFSET_BOTTOM;
		if not bottom then
			error("SCROLL_FRAME_SCROLL_BAR_OFFSET_BOTTOM undefined. Check ScrollDefine.lua")
		end

		self.ScrollBar = CreateFrame("EventFrame", nil, self, scrollBarTemplate);
		self.ScrollBar:SetHideIfUnscrollable(self.scrollBarHideIfUnscrollable);
		self.ScrollBar:SetHideTrackIfThumbExceedsTrack(self.scrollBarHideTrackIfThumbExceedsTrack);
		self.ScrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", left, top);
		self.ScrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", left, bottom);
		self.ScrollBar:Show();

		ScrollUtil.InitScrollFrameWithScrollBar(self, self.ScrollBar);

		self.ScrollBar:Update();
	end
end

function ScrollingEdit_OnTextChanged(self, scrollFrame)
	-- force an update when the text changes
	self.handleCursorChange = true;
	ScrollingEdit_OnUpdate(self, 0, scrollFrame);
end

function ScrollingEdit_OnLoad(self)
	ScrollingEdit_SetCursorOffsets(self, 0, 0);
end

function ScrollingEdit_SetCursorOffsets(self, offset, height)
	self.cursorOffset = offset;
	self.cursorHeight = height;
end

function ScrollingEdit_OnCursorChanged(self, x, y, w, h)
	ScrollingEdit_SetCursorOffsets(self, y, h);
	self.handleCursorChange = true;
end

-- NOTE: If your edit box never shows partial lines of text, then this function will not work when you use
-- your mouse to move the edit cursor. You need the edit box to cut lines of text so that you can use your
-- mouse to highlight those partially-seen lines; otherwise you won't be able to use the mouse to move the
-- cursor above or below the current scroll area of the edit box.
function ScrollingEdit_OnUpdate(self, elapsed, scrollFrame)
	local height, range, scroll, cursorOffset;
	if ( self.handleCursorChange ) then
		if ( not scrollFrame ) then
			scrollFrame = self:GetParent();
		end
		height = scrollFrame:GetHeight();
		range = scrollFrame:GetVerticalScrollRange();
		scroll = scrollFrame:GetVerticalScroll();
		cursorOffset = -self.cursorOffset;

		if ( math.floor(height) <= 0 or math.floor(range) <= 0 ) then
			--Frame has no area, nothing to calculate.
			return;
		end

		while ( cursorOffset < scroll ) do
			scroll = (scroll - (height / 2));
			if ( scroll < 0 ) then
				scroll = 0;
			end
			scrollFrame:SetVerticalScroll(scroll);
		end

		while ( (cursorOffset + self.cursorHeight) > (scroll + height) and scroll < range ) do
			scroll = (scroll + (height / 2));
			if ( scroll > range ) then
				scroll = range;
			end
			scrollFrame:SetVerticalScroll(scroll);
		end

		self.handleCursorChange = false;
	end
end

function InputScrollFrame_OnLoad(self)
	self.scrollBarX = -10;
	self.scrollBarTopY = -1;
	self.scrollBarBottomY = -3;
	self.scrollBarHideIfUnscrollable = true;

	ScrollFrame_OnLoad(self);

	self.EditBox:SetWidth(self:GetWidth() - 18);
	self.EditBox:SetMaxLetters(self.maxLetters);
	self.EditBox.Instructions:SetText(self.instructions);
	self.EditBox.Instructions:SetWidth(self:GetWidth());
	self.CharCount:SetShown(not self.hideCharCount);
end

function InputScrollFrame_OnMouseDown(self)
	self.EditBox:SetFocus();
end

InputScrollFrame_OnTabPressed = EditBox_OnTabPressed;

function InputScrollFrame_OnTextChanged(self)
	local scrollFrame = self:GetParent();
	ScrollingEdit_OnTextChanged(self, scrollFrame);
	if ( self:GetText() ~= "" ) then
		self.Instructions:Hide();
	else
		self.Instructions:Show();
	end
	scrollFrame.CharCount:SetText(self:GetMaxLetters() - self:GetNumLetters());

	if scrollFrame.ScrollBar then
		if ( scrollFrame.ScrollBar:IsShown() ) then
			scrollFrame.CharCount:SetPoint("BOTTOMRIGHT", -17, 0);
		else
			scrollFrame.CharCount:SetPoint("BOTTOMRIGHT", 0, 0);
		end
	end
end

function InputScrollFrame_OnUpdate(self, elapsed)
	ScrollingEdit_OnUpdate(self, elapsed, self:GetParent());
end

function InputScrollFrame_OnEscapePressed(self)
	self:ClearFocus();
end

function UIPanelButton_OnLoad(self)
	if ( not self:IsEnabled() ) then
		self.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
		self.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
		self.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
	end
end

function UIPanelButton_OnMouseDown(self)
	if ( self:IsEnabled() ) then
		self.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down");
		self.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down");
		self.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down");
	end
end

function UIPanelButton_OnMouseUp(self)
	if ( self:IsEnabled() ) then
		self.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
		self.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
		self.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
	end
end

function UIPanelButton_OnShow(self)
	if ( self:IsEnabled() ) then
		-- we need to reset our textures just in case we were hidden before a mouse up fired
		self.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
		self.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
		self.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
	end
end

function UIPanelButton_OnDisable(self)
	self.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
	self.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
	self.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
end

function UIPanelButton_OnEnable(self)
	self.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
	self.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
	self.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
end

UIButtonFitToTextBehaviorMixin = {};

function UIButtonFitToTextBehaviorMixin:SetTextToFit(text)
	self:SetText(text);
	self:FitToText();
end

function UIButtonFitToTextBehaviorMixin:FitToText()
	local minWidth = self.fitTextCanWidthDecrease and 0 or self:GetWidth();
	self:SetWidth(math.max(minWidth, self:GetTextWidth() + self.fitTextWidthPadding));
end

UIPanelButtonNoTooltipResizeToFitMixin = {};

function UIPanelButtonNoTooltipResizeToFitMixin:OnLoad()
	UIPanelButton_OnLoad(self);
	self.Text.layoutIndex = 1;
	self:MarkDirty();
end

function UIPanelButtonNoTooltipResizeToFitMixin:SetText(text)
	self.Text:SetText(text);
	self:MarkDirty();
end

function SelectionFrameCancelButton_OnClick(self, ...)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
	local cancelFunction = self:GetParent().OnCancel;
	if cancelFunction then
		cancelFunction(self, ...);
	end
end

function SelectionFrameOkayButton_OnClick(self, ...)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
	local okayFunction = self:GetParent().OnOkay;
	if okayFunction then
		okayFunction(self, ...);
	end
end

LoadingSpinnerMixin = {};

function LoadingSpinnerMixin:OnShow()
	self.Anim:Play();
end

function LoadingSpinnerMixin:OnHide()
	self.Anim:Stop();
end