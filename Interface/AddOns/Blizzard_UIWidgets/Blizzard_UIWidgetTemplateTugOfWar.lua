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
	["Divider"] = {formatString = "%s-Spark-Line", useAtlasSize = true, setVisibility = true},
	["Spark"] = {formatString = "%s-Spark-arrows", useAtlasSize = true, setVisibility = true},
}

function UIWidgetTemplateTugOfWarMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);

	SetupTextureKitsFromRegionInfo(widgetInfo.textureKit, self, textureKitRegionInfo);

	local currentValuePercent = ClampedPercentageBetween(widgetInfo.currentValue, widgetInfo.minValue, widgetInfo.maxValue);
	local sparkXOffset = self.BarBackgroundMiddle:GetWidth() * currentValuePercent;
	self.Spark:SetPoint("CENTER", self.BarBackgroundMiddle, "LEFT", sparkXOffset, 0);

	-- TODO: full support for neutral zone size
	local hasDividerTexture = self.Divider:IsShown();
	if hasDividerTexture and widgetInfo.neutralZoneSize > 0 then
		local neutralCenterPercent = ClampedPercentageBetween(widgetInfo.neutralZoneCenter, widgetInfo.minValue, widgetInfo.maxValue);
		local dividerXOffset = self.BarBackgroundMiddle:GetWidth() * neutralCenterPercent;
		self.Divider:SetPoint("CENTER", self.BarBackgroundMiddle, "LEFT", dividerXOffset, 0);
		self.Divider:Show();
	else
		self.Divider:Hide();
	end

	local inLeftZone = widgetInfo.currentValue < widgetInfo.neutralZoneCenter;
	local inRightZone = widgetInfo.currentValue > widgetInfo.neutralZoneCenter;

	self.LeftIcon:Setup(widgetContainer, widgetInfo.textureKit, widgetInfo.leftIconInfo, inLeftZone, widgetInfo.glowAnimType);
	self.RightIcon:Setup(widgetContainer, widgetInfo.textureKit, widgetInfo.rightIconInfo, inRightZone, widgetInfo.glowAnimType);

	local maxIconWidth = math.max(self.LeftIcon:GetWidth(), self.RightIcon:GetWidth());
	local maxIconHeight = math.max(self.LeftIcon:GetHeight(), self.RightIcon:GetHeight());
	local widgetWidth = self.BarBackgroundMiddle:GetWidth() + (2 * maxIconWidth);
	local widgetHeight = math.max(maxIconHeight, self.BarBackgroundMiddle:GetHeight());

	self:SetSize(math.max(widgetWidth, widgetInfo.widgetSizeSetting), widgetHeight);
end

function UIWidgetTemplateTugOfWarMixin:AnimOut()
	self.LeftIcon:StopAnims();
	self.RightIcon:StopAnims();
	UIWidgetBaseTemplateMixin.AnimOut(self);
end