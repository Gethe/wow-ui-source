local function GetButtonHeaderVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetButtonHeaderWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.ButtonHeader, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateButtonHeader"}, GetButtonHeaderVisInfoData);

UIWidgetTemplateButtonHeaderMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local buttonHeaderTextureKitRegions = {
	["Frame"] = "%s-frame",
}

function UIWidgetTemplateButtonHeaderMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	self:SetTooltip(widgetInfo.tooltip);
	self.HeaderText:SetText(widgetInfo.headerText);

	SetupTextureKitOnRegions(widgetInfo.frameTextureKit, self, buttonHeaderTextureKitRegions, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);

	self.buttonPool:ReleaseAll();

	for index, buttonInfo in ipairs(widgetInfo.buttons) do
		local buttonFrame = self.buttonPool:Acquire();
		buttonFrame:Setup(widgetContainer, buttonInfo);
		buttonFrame.layoutIndex = index;
		buttonFrame:Show();
	end
	self.ButtonContainer:Layout();

	self:Layout();
	self:Show();
end

function UIWidgetTemplateButtonHeaderMixin:OnLoad()
	self.buttonPool = CreateFramePool("BUTTON", self.ButtonContainer, "UIWidgetBaseButtonTemplate");
end