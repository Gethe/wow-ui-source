local function GetStatusBarVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.StatusBar, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateStatusBar"}, GetStatusBarVisInfoData);

UIWidgetTemplateStatusBarMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateStatusBarMixin:Setup(widgetInfo)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo);
	self.Bar:SetMinMaxValues(widgetInfo.barMin, widgetInfo.barMax);
	self.Bar:SetValue(widgetInfo.barValue);

	local barPercent = FormatPercentage(PercentageBetween(widgetInfo.barValue, widgetInfo.barMin, widgetInfo.barMax), true);
	self.Bar.Label:SetText(barPercent);

	self.Label:SetText(widgetInfo.text);

	local totalWidth = self.Bar:GetWidth() > self.Label:GetWidth() and self.Bar:GetWidth() or self.Label:GetWidth();
	self:SetWidth(totalWidth);

	local totalHeight = (widgetInfo.text and widgetInfo.text ~= "") and (self.Bar:GetHeight() + 5 + self.Label:GetHeight() + 7) or (self.Bar:GetHeight() + 5);
	self:SetHeight(totalHeight);
end
