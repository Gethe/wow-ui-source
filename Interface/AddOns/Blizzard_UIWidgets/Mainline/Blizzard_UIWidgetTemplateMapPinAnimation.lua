local function GetMapPinAnimationVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetMapPinAnimationWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.MapPinAnimation, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateMapPinAnimation"}, GetMapPinAnimationVisInfoData);

UIWidgetTemplateMapPinAnimationMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegions = {
	["Background"] = "%s-background",
	["TopHighlight"] = "%s-tophighlight",
};

local textureKitPadding = 
{
	["mappinglowblue"] = {glowPadding = 32},
	["mappinglowgreen"] = {glowPadding = 32},
};

local DEFAULT_GLOW_PADDING = 16;

function UIWidgetTemplateMapPinAnimationMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	SetupTextureKitOnRegions(widgetInfo.textureKit, self, textureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	local mapPin = widgetContainer:GetParent();
	local pinWidth, pinHeight = mapPin:GetSize();

	local texKitPadInfo = textureKitPadding[widgetInfo.textureKit];
	local glowPadding = (texKitPadInfo and texKitPadInfo.glowPadding or DEFAULT_GLOW_PADDING) + widgetInfo.widgetSizeSetting;

	self.Background:SetSize(pinWidth + glowPadding, pinHeight + glowPadding);
	self.TopHighlight:SetSize(pinWidth + glowPadding, pinHeight + glowPadding);

	if mapPin.widgetAnimationTexture and widgetInfo.animType ~= Enum.MapPinAnimationType.None then
		self.MapPinTextureCopy:SetSize(mapPin.widgetAnimationTexture:GetSize());

		local atlas = mapPin.widgetAnimationTexture:GetAtlas();
		if atlas then
			self.MapPinTextureCopy:SetTexCoord(0, 1, 0, 1);
			self.MapPinTextureCopy:SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
		else
			self.MapPinTextureCopy:SetTexture(mapPin.widgetAnimationTexture:GetTexture());
			self.MapPinTextureCopy:SetTexCoord(mapPin.widgetAnimationTexture:GetTexCoord());
		end
		self.MapPinTextureCopy:Show();

		self.PinPulse:Play();
	else
		self.MapPinTextureCopy:Hide();
	end

	self:Layout();
end