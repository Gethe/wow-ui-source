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
