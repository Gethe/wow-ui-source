local function GetTextWithStateVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.TextWithState, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateTextWithState"}, GetTextWithStateVisInfoData);

UIWidgetTemplateTextWithStateMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local normalFonts =
{
	[Enum.UIWidgetTextSizeType.Small]	= "SystemFont_Med1",
	[Enum.UIWidgetTextSizeType.Medium]	= "SystemFont_Large",
	[Enum.UIWidgetTextSizeType.Large]	= "SystemFont_Huge2",
	[Enum.UIWidgetTextSizeType.Huge]	= "SystemFont_Huge4",
}

local shadowFonts =
{
	[Enum.UIWidgetTextSizeType.Small]	= "SystemFont_Shadow_Med1",
	[Enum.UIWidgetTextSizeType.Medium]	= "SystemFont_Shadow_Large",
	[Enum.UIWidgetTextSizeType.Large]	= "SystemFont_Shadow_Huge2",
	[Enum.UIWidgetTextSizeType.Huge]	= "SystemFont_Shadow_Huge4",
}

local outlineFonts =
{
	[Enum.UIWidgetTextSizeType.Small]	= "SystemFont_Shadow_Med1_Outline",
	[Enum.UIWidgetTextSizeType.Medium]	= "SystemFont_Shadow_Large_Outline",
	[Enum.UIWidgetTextSizeType.Large]	= "SystemFont_Shadow_Huge2_Outline",
	[Enum.UIWidgetTextSizeType.Huge]	= "SystemFont_Shadow_Huge4_Outline",
}

local fontTypes = 
{
	[Enum.UIWidgetFontType.Normal]	= normalFonts,
	[Enum.UIWidgetFontType.Shadow]	= shadowFonts,
	[Enum.UIWidgetFontType.Outline]	= outlineFonts,
}

local function GetTextFont(textSizeType, fontType)
	return fontTypes[fontType][textSizeType];
end

function UIWidgetTemplateTextWithStateMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);

	self.Text:SetFontObject(GetTextFont(widgetInfo.textSizeType, widgetInfo.fontType));

	self.Text:SetText(widgetInfo.text);
	self.Text:SetEnabledState(widgetInfo.enabledState);

	if self.fontColor then
		self.Text:SetTextColor(self.fontColor:GetRGB());
	end

	local width = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or self.Text:GetStringWidth();

	self:SetWidth(width);

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
