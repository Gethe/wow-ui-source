UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.IconTextAndBackground, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateIconTextAndBackground"}, C_UIWidgetManager.GetIconTextAndBackgroundWidgetVisualizationInfo);

UIWidgetTemplateIconTextAndBackgroundMixin = {};

local textureKitRegions = {
	["Icon"] = "%s-icon",
	["Glow"] = "%s-glow",
};

function UIWidgetTemplateIconTextAndBackgroundMixin:Setup(widgetInfo)
	self:Show();
	SetupTextureKits(widgetInfo.textureKitID, self, textureKitRegions, true);

	self.Text:SetText(widgetInfo.value);
	self.orderIndex = widgetInfo.orderIndex;
end
