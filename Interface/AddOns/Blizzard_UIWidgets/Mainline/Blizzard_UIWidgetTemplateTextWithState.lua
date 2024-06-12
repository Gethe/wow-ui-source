local function GetTextWithStateVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.TextWithState, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateTextWithState"}, GetTextWithStateVisInfoData);

UIWidgetTemplateTextWithStateMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateTextWithStateMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);

	if widgetInfo.widgetSizeSetting > 0 then
		self.Text:SetWidth(widgetInfo.widgetSizeSetting);
	else
		self.Text:SetWidth(0);
	end

	self.Text:Setup(widgetInfo.text, widgetInfo.fontType, widgetInfo.textSizeType, widgetInfo.enabledState, widgetInfo.hAlign);

	if self.fontColor then
		self.Text:SetTextColor(self.fontColor:GetRGB());
	end

	if widgetInfo.widgetSizeSetting > 0 then
		self:SetWidth(widgetInfo.widgetSizeSetting);
	else
		self:SetWidth(self.Text:GetStringWidth());
	end

	local textHeight = self.Text:GetStringHeight();
	local bottomPadding = Clamp(widgetInfo.bottomPadding, 0, textHeight - 1);	-- don't allow bottomPadding to be less than 0 or greater than or equal to the height of the text (could just add a blank line in that case)
	self:SetHeight(textHeight + bottomPadding);
end

function UIWidgetTemplateTextWithStateMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.fontColor = nil;
end

function UIWidgetTemplateTextWithStateMixin:SetFontStringColor(fontColor)
	self.fontColor = fontColor;
end
