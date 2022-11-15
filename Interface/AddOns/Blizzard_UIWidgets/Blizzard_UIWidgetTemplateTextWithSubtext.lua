local function GetTextWithSubtextVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetTextWithSubtextWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.TextWithSubtext, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateTextWithSubtext"}, GetTextWithSubtextVisInfoData);

UIWidgetTemplateTextWithSubtextMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateTextWithSubtextMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);

	self.Text:Setup(widgetInfo.text, widgetInfo.fontType, widgetInfo.textSizeType, widgetInfo.enabledState, widgetInfo.hAlign);

	if self.fontColor then
		self.Text:SetTextColor(self.fontColor:GetRGB());
		self.SubText:SetTextColor(self.fontColor:GetRGB());
	end

	self.SubText:Setup(widgetInfo.subText, widgetInfo.subTextFontType, widgetInfo.subTextSizeType, widgetInfo.subTextEnabledState, widgetInfo.subTextHAlign);
	local textWidth = self.Text:GetStringWidth() or 0;
	local subTextWidth = self.SubText:GetStringWidth() or 0;
	local width = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or math.max(subTextWidth, textWidth); 

	self.spacing = widgetInfo.spacing; 
	self.SubText:SetWidth(width); 
	self.Text:SetWidth(width);
	self.fixedWidth = width; 
	self:Layout(); 
end

function UIWidgetTemplateTextWithSubtextMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.fontColor = nil;
end

function UIWidgetTemplateTextWithSubtextMixin:SetFontStringColor(fontColor)
	self.fontColor = fontColor;
end
