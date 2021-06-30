local function GetDoubleIconAndTextVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetDoubleIconAndTextWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.DoubleIconAndText, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateDoubleIconAndText"}, GetDoubleIconAndTextVisInfoData);

UIWidgetTemplateDoubleIconAndTextMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegions = {
	["LeftIcon"] = "%s-leftIcon",
	["RightIcon"] = "%s-rightIcon",
}

function UIWidgetTemplateDoubleIconAndTextMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	SetupTextureKitOnRegions(widgetInfo.textureKit, self, textureKitRegions, TextureKitConstants.SetVisibility);

	self.Label:SetText(widgetInfo.label);

	self.Left.Text:SetText(widgetInfo.leftText);
	self.Left:SetTooltipLocation(widgetInfo.tooltipLoc);
	self.Left:SetTooltip(widgetInfo.leftTooltip);
	self.Left:SetWidth(self.Left.Icon:GetWidth() + self.Left.Text:GetWidth() + 5)

	self.Right.Text:SetText(widgetInfo.rightText);
	self.Right:SetTooltipLocation(widgetInfo.tooltipLoc);
	self.Right:SetTooltip(widgetInfo.rightTooltip);
	self.Right:SetWidth(self.Right.Icon:GetWidth() + self.Right.Text:GetWidth() + 5)

	local totalWidth = self.Label:GetWidth() + 15 + self.Left:GetWidth() + 25 + self.Right:GetWidth();
	self:SetWidth(totalWidth);
end

function UIWidgetTemplateDoubleIconAndTextMixin:OnLoad()
	self.LeftIcon = self.Left.Icon;
	self.RightIcon = self.Right.Icon;
end
