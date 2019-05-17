local function GetIconAndTextVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.state > Enum.IconAndTextWidgetState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.IconAndText, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateIconAndText"}, GetIconAndTextVisInfoData);

UIWidgetTemplateIconAndTextMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegions = {
	["Icon"] = "%s-icon",
	["DynamicIconTexture"] = "%s-dynamicIcon",
	["FlashTexture"] = "%s-flash",
}

function UIWidgetTemplateIconAndTextMixin:OnAcquired(widgetInfo)
	self.Text:ClearAllPoints();

	if self.Icon:IsShown() then
		self.alignWidth = self.Icon:GetWidth()- 12 + self.Text:GetStringWidth();
		self.Text:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", -12, -6);
	else
		self.alignWidth = self.Text:GetStringWidth();
		self.Text:SetPoint("TOPLEFT", self.Icon, "TOPLEFT", 0, -6);
	end

	self:SetWidth(self.alignWidth);
end

function UIWidgetTemplateIconAndTextMixin:Setup(widgetInfo)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo);
	SetupTextureKits(widgetInfo.textureKitID, self, textureKitRegions, true);

	self.Text:SetText(widgetInfo.text);
	self:SetTooltip(widgetInfo.tooltip);
	self.DynamicIconButton:SetTooltip(widgetInfo.dynamicTooltip);

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

function UIWidgetTemplateIconAndTextMixin:OnLoad()
	self.DynamicIconTexture = self.DynamicIconButton.Icon;
	self.FlashTexture = self.Flash.Texture;
end
