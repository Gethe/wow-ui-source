local function GetSpacerVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetSpacerVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.Spacer, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateSpacer"}, GetSpacerVisInfoData);

UIWidgetTemplateSpacerMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateSpacerMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetWidth(Clamp(widgetInfo.widgetWidth, 1, widgetInfo.widgetWidth));
	self:SetHeight(Clamp(widgetInfo.widgetHeight, 1, widgetInfo.widgetHeight));
end
