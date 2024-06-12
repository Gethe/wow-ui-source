local function GetTextureWithAnimationVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetTextureWithAnimationVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.TextureWithAnimation, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateTextureWithAnimation"}, GetTextureWithAnimationVisInfoData);

local textureKitRegionInfo = {
	["BackgroundGlow"] = {formatString = "%s-backgroundglow", setVisibility = true, useAtlasSize = true},
	["BorderGlow1"] = {formatString = "%s-borderglow1", setVisibility = true, useAtlasSize = true},
	["BorderGlow2"] = {formatString = "%s-borderglow2", setVisibility = true, useAtlasSize = true},
	["BorderGlow3"] = {formatString = "%s-borderglow3", setVisibility = true, useAtlasSize = true},
	["BorderGlow4"] = {formatString = "%s-borderglow4", setVisibility = true, useAtlasSize = true},
	["TransitionGlow"] = {formatString = "%s-transitionglow", setVisibility = true, useAtlasSize = true},
	["TransitionGlow2"] = {formatString = "%s-transitionglow2", setVisibility = true, useAtlasSize = true},
	["TransitionGlow3"] = {formatString = "%s-transitionglow3", setVisibility = true, useAtlasSize = true},
	["Background"] = {formatString = "%s-background", setVisibility = true, useAtlasSize = true},
	["CenterEffect1"] = {formatString = "%s-centereffect1", setVisibility = true, useAtlasSize = true},
	["CenterEffect2"] = {formatString = "%s-centereffect2", setVisibility = true, useAtlasSize = true},
	["CenterEffect3"] = {formatString = "%s-centereffect3", setVisibility = true, useAtlasSize = true},
	["CenterEffect4"] = {formatString = "%s-centereffect4", setVisibility = true, useAtlasSize = true},
	["CenterEffect5"] = {formatString = "%s-centereffect5", setVisibility = true, useAtlasSize = true},
	["Border"] = {formatString = "%s-border", setVisibility = true, useAtlasSize = true},
};

UIWidgetTemplateTextureWithAnimationMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateTextureWithAnimationMixin:StartAnimations()
	if ( self.CenterEffect1:IsShown() ) then
		self.CenterEffect1Anim:Play();
	end
	
	if ( self.TransitionGlow:IsShown() and self.TransitionGlow2:IsShown() and self.TransitionGlow3:IsShown() ) then
		self.TransitionGlowAnim:Play();
	end
	
	if ( self.CenterEffect2:IsShown() ) then
		self.CenterEffect2Anim:Play();
	end

	if ( self.CenterEffect4:IsShown() ) then
		self.CenterEffect4GlowAnim:Play();
	end

	if ( self.CenterEffect5:IsShown() ) then
		self.CenterEffect5Anim:Play();
	end

	if ( self.BorderGlow1:IsShown() ) then
		self.BorderGlow1Anim:Play();
	end

	if ( self.BorderGlow2:IsShown() ) then
		self.BorderGlow2Anim:Play();
	end

	if ( self.BorderGlow3:IsShown() ) then
		self.BorderGlow3Anim:Play();
	end

	if ( self.BorderGlow4:IsShown() ) then
		self.BorderGlow4Anim:Play();
	end
end

local textureKitTooltipBackdropStyles = {
	["eyeofthejailer"] = GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY,
};

function UIWidgetTemplateTextureWithAnimationMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	local textureKit = widgetInfo.textureKit;
	SetupTextureKitsFromRegionInfo(textureKit, self, textureKitRegionInfo);

	local tooltipTextureKit = strsub(textureKit, 1, 14);
	self.tooltipBackdropStyle = textureKitTooltipBackdropStyles[tooltipTextureKit];

	self:SetTooltip(widgetInfo.tooltip);
	self:StartAnimations();
end