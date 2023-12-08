local function GetTugOfWarVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetTugOfWarWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.TugOfWar, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateTugOfWar"}, GetTugOfWarVisInfoData);

UIWidgetTemplateTugOfWarMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegionInfo = {
	["BarBackgroundMiddle"] = {formatString = "%s-Background-Middle", useAtlasSize = true, setVisibility = true},
	["BarBackgroundLeft"] = {formatString = "%s-Background-Left", useAtlasSize = true, setVisibility = true},
	["BarBackgroundRight"] = {formatString = "%s-Background-Right", useAtlasSize = true, setVisibility = true},
	["Marker"] = {formatString = "%s-Marker-%s", useAtlasSize = true, setVisibility = true},
	["NeutralFill"] = {formatString = "%s-neutralfill", useAtlasSize = true, setVisibility = true},
	["NeutralFillGlow"] = {formatString = "%s-neutralfill-glow", useAtlasSize = true, setVisibility = true},
	["LeftArrow"] = {formatString = "%s-arrow", useAtlasSize = true},
	["RightArrow"] = {formatString = "%s-arrow", useAtlasSize = true},
};

local frameTextureKitInfo = 
{
	["plain"] = {arrowXOffset = 9},
	["diamond"] = {markerYOffset = 3, arrowXOffset = 8, arrowYOffset = 9},
};

local neutralFillColorFromStyleValue = {
	[Enum.TugOfWarStyleValue.DefaultYellow] = DARKYELLOW_FONT_COLOR,
	[Enum.TugOfWarStyleValue.ArchaeologyBrown] = ARCHAEOLOGY_BROWN,
};

local neutralFillGlowColorFromStyleValue = {
	[Enum.TugOfWarStyleValue.DefaultYellow] = WHITE_FONT_COLOR,
	[Enum.TugOfWarStyleValue.ArchaeologyBrown] = ARCHAEOLOGY_LIGHT_BROWN,
};

function UIWidgetTemplateTugOfWarMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);

	if not self.oldValue then
		self.oldValue = widgetInfo.currentValue;
	end

	local textureKits = {widgetInfo.textureKit, widgetInfo.frameTextureKit};
	SetupTextureKitsFromRegionInfo(textureKits, self, textureKitRegionInfo);

	local extraFrameInfo = frameTextureKitInfo[widgetInfo.frameTextureKit];

	local currentValuePercent = ClampedPercentageBetween(widgetInfo.currentValue, widgetInfo.minValue, widgetInfo.maxValue);
	local markerXOffset = self.BarBackgroundMiddle:GetWidth() * currentValuePercent;
	local markerYOffset = extraFrameInfo and extraFrameInfo.markerYOffset or 0;
	self.Marker:SetPoint("CENTER", self.BarBackgroundMiddle, "LEFT", markerXOffset, markerYOffset);

	local arrowXOffset = extraFrameInfo and extraFrameInfo.arrowXOffset or 0;
	local arrowYOffset = extraFrameInfo and extraFrameInfo.arrowYOffset or 0;
	self.LeftArrow:SetPoint("RIGHT", self.Marker, "LEFT", arrowXOffset, arrowYOffset);
	self.RightArrow:SetPoint("LEFT", self.Marker, "RIGHT", -arrowXOffset, arrowYOffset);

	local neutralCenterPercent = ClampedPercentageBetween(widgetInfo.neutralZoneCenter, widgetInfo.minValue, widgetInfo.maxValue);
	local maxNeutralZoneSize = ((neutralCenterPercent > 0.5) and (widgetInfo.maxValue - widgetInfo.neutralZoneCenter) or (widgetInfo.neutralZoneCenter - widgetInfo.minValue)) * 2;
	local neutralZoneSize = Clamp(widgetInfo.neutralZoneSize, 0, maxNeutralZoneSize);

	local hasNeutralFillTexture = self.NeutralFill:IsShown();
	if hasNeutralFillTexture and neutralZoneSize > 0 then
		local neutralFillColor = neutralFillColorFromStyleValue[widgetInfo.neutralFillStyle] or WHITE_FONT_COLOR;
		self.NeutralFill:SetVertexColor(neutralFillColor:GetRGB());

		local neutralFillXOffset = self.BarBackgroundMiddle:GetWidth() * neutralCenterPercent;
		self.NeutralFill:SetPoint("CENTER", self.BarBackgroundMiddle, "LEFT", neutralFillXOffset, -0.5);

		local neutralZoneSizePercent = ClampedPercentageBetween(neutralZoneSize, 0, widgetInfo.maxValue - widgetInfo.minValue);
		local neutralFillWidth = neutralZoneSizePercent * self.BarBackgroundMiddle:GetWidth();
		self.NeutralFill:SetWidth(neutralFillWidth);

		self.NeutralFill:Show();
	else
		self.NeutralFill:Hide();
	end

	local halfNeutralZoneSize = neutralZoneSize / 2;

	local inLeftZone = widgetInfo.currentValue < (widgetInfo.neutralZoneCenter - halfNeutralZoneSize);
	local inRightZone = widgetInfo.currentValue > (widgetInfo.neutralZoneCenter + halfNeutralZoneSize);
	local inNeutralZone = not inLeftZone and not inRightZone;

	self.LeftIcon:Setup(widgetContainer, widgetInfo.textureKit, widgetInfo.leftIconInfo, inLeftZone, widgetInfo.glowAnimType);
	self.RightIcon:Setup(widgetContainer, widgetInfo.textureKit, widgetInfo.rightIconInfo, inRightZone, widgetInfo.glowAnimType);

	local hasNeutralFillGlowTexture = self.NeutralFillGlow:IsShown();
	if inNeutralZone and hasNeutralFillGlowTexture then
		local neutralFillGlowColor = neutralFillGlowColorFromStyleValue[widgetInfo.neutralFillStyle] or WHITE_FONT_COLOR;
		self.NeutralFillGlow:SetVertexColor(neutralFillGlowColor:GetRGB());

		self.NeutralFillGlow:Show();
		if widgetInfo.glowAnimType == Enum.WidgetGlowAnimType.Pulse then
			self.NeutralFillGlowPulseAnim:Play();
		else
			self.NeutralFillGlowPulseAnim:Stop();
			self.NeutralFillGlow:SetAlpha(0.75);
		end
	else
		self.NeutralFillGlowPulseAnim:Stop();
		self.NeutralFillGlow:Hide();
	end

	if widgetInfo.markerArrowShownState == Enum.TugOfWarMarkerArrowShownState.Never then
		self.LeftArrowAnim:Stop();
		self.LeftArrow:Hide();
		self.RightArrowAnim:Stop();
		self.RightArrow:Hide();
	elseif widgetInfo.markerArrowShownState == Enum.TugOfWarMarkerArrowShownState.Always then
		self.LeftArrowAnim:Stop();
		self.LeftArrow:Show();
		self.RightArrowAnim:Stop();
		self.RightArrow:Show();
	else
		local movedLeft = (widgetInfo.currentValue < self.oldValue);
		local movedRight = (widgetInfo.currentValue > self.oldValue);

		if movedLeft then
			self.LeftArrow:Show();
			self.LeftArrowAnim:Restart();
			self.RightArrowAnim:Stop();
			self.RightArrow:Hide();
		elseif movedRight then
			self.LeftArrowAnim:Stop();
			self.LeftArrow:Hide();
			self.RightArrow:Show();
			self.RightArrowAnim:Restart();
		else
			self.LeftArrowAnim:Stop();
			self.LeftArrow:Hide();
			self.RightArrowAnim:Stop();
			self.RightArrow:Hide();
		end
	end

	local leftIconWidth = self.LeftIcon:IsShown() and self.LeftIcon:GetWidth() or self.BarBackgroundLeft:GetWidth();
	local leftIconHeight = self.LeftIcon:IsShown() and self.LeftIcon:GetHeight() or 0;
	local rightIconWidth = self.RightIcon:IsShown() and self.RightIcon:GetWidth() or self.BarBackgroundRight:GetWidth();
	local rightIconHeight = self.RightIcon:IsShown() and self.RightIcon:GetHeight() or 0;

	local maxIconWidth = math.max(leftIconWidth, rightIconWidth);
	local maxIconHeight = math.max(leftIconHeight, rightIconHeight);
	local widgetWidth = self.BarBackgroundMiddle:GetWidth() + (2 * maxIconWidth);
	local widgetHeight = math.max(maxIconHeight, self.BarBackgroundMiddle:GetHeight());

	self:SetSize(math.max(widgetWidth, widgetInfo.widgetSizeSetting), widgetHeight);

	self.oldValue = widgetInfo.currentValue;
end

function UIWidgetTemplateTugOfWarMixin:AnimOut()
	self.LeftIcon:StopAnims();
	self.RightIcon:StopAnims();
	self.NeutralFillGlowPulseAnim:Stop();
	self.NeutralFillGlow:Hide();
	self.LeftArrowAnim:Stop();
	self.LeftArrow:Hide();
	self.RightArrowAnim:Stop();
	self.RightArrow:Hide();
	self.oldValue = nil;
	UIWidgetBaseTemplateMixin.AnimOut(self);
end