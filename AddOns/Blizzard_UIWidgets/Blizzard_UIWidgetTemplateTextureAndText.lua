local function GetTextureAndTextVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetTextureAndTextVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.TextureAndText, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateTextureAndText"}, GetTextureAndTextVisInfoData);

UIWidgetTemplateTextureAndTextMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateTextureAndTextMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self);
	UIWidgetBaseTextureAndTextTemplateMixin.OnLoad(self);
end 
function UIWidgetTemplateTextureAndTextMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	UIWidgetBaseTextureAndTextTemplateMixin.Setup(self, widgetContainer, widgetInfo.text, widgetInfo.tooltip, widgetInfo.frameTextureKit, widgetInfo.textureKit);
	self:SetTooltipLocation(widgetInfo.tooltipLoc);
end