local function GetTextWithStateVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.TextWithState, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateTextWithState"}, GetTextWithStateVisInfoData);

UIWidgetTemplateTextWithStateMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateTextWithStateMixin:Setup(widgetInfo)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo);

	self.Text:SetText(widgetInfo.text);
	self.Text:SetEnabledState(widgetInfo.enabledState);

	if self.fontColor then
		self.Text:SetTextColor(self.fontColor:GetRGB());
	end

	if widgetInfo.widgetWidth > 0 then
		self:SetWidth(widgetInfo.widgetWidth);
	else
		self:SetWidth(self.Text:GetWidth());
	end

	self:SetHeight(self.Text:GetHeight());
end

function UIWidgetTemplateTextWithStateMixin:SetFontStringColor(fontColor)
	self.fontColor = fontColor;
end
