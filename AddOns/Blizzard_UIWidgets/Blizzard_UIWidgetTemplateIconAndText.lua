local function GetIconAndTextVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.state > Enum.IconAndTextWidgetState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.IconAndText, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateIconAndText"}, GetIconAndTextVisInfoData);

UIWidgetTemplateIconAndTextMixin = {}

function UIWidgetTemplateIconAndTextMixin:Setup(widgetInfo)
	self:Show();
	self.Text:SetText(widgetInfo.text);
	self.Icon:SetTexture(widgetInfo.icon);
	self.DynamicIconButton.Icon:SetTexture(widgetInfo.dynamicIcon);
	self.Flash.Texture:SetTexture(widgetInfo.dynamicIconFlash);
	self.tooltip = widgetInfo.tooltip;
	self.DynamicIconButton.tooltip = widgetInfo.dynamicTooltip;
	self.hasTimer = widgetInfo.hasTimer;
	self.orderIndex = widgetInfo.orderIndex;

	if ( widgetInfo.state == Enum.IconAndTextWidgetState.ShownWithDynamicIconFlashing ) then
		UIFrameFlash(self.Flash, 0.5, 0.5, -1);
		self.DynamicIconButton:Show();
	elseif ( widgetInfo.state == Enum.IconAndTextWidgetState.ShownWithDynamicIconNotFlashing ) then
		UIFrameFlashStop(self.Flash);
		self.DynamicIconButton:Show();
	else
		UIFrameFlashStop(self.Flash);
		self.DynamicIconButton:Hide();
	end
end
