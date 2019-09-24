local function GetTextWithStateVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.TextWithState, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateTextWithState"}, GetTextWithStateVisInfoData);

UIWidgetTemplateTextWithStateMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textFontSizes =
{
	[Enum.UIWidgetTextSizeType.Small]	= "GameTooltipText",
	[Enum.UIWidgetTextSizeType.Medium]	= "Game16Font",
	[Enum.UIWidgetTextSizeType.Large]	= "Game24Font",
	[Enum.UIWidgetTextSizeType.Huge]	= "Game27Font",
}

local function GetTextSizeFont(textSizeType)
	return textFontSizes[textSizeType] and textFontSizes[textSizeType] or textFontSizes[Enum.UIWidgetTextSizeType.Small];
end

function UIWidgetTemplateTextWithStateMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);

	self.Text:SetFontObject(GetTextSizeFont(widgetInfo.textSizeType));

	self.Text:SetText(widgetInfo.text);
	self.Text:SetEnabledState(widgetInfo.enabledState);

	if self.fontColor then
		self.Text:SetTextColor(self.fontColor:GetRGB());
	end

	local width = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or self.Text:GetStringWidth();

	self:SetWidth(width);
	self:SetHeight(self.Text:GetStringHeight());
end

function UIWidgetTemplateTextWithStateMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.fontColor = nil;
end

function UIWidgetTemplateTextWithStateMixin:SetFontStringColor(fontColor)
	self.fontColor = fontColor;
end
