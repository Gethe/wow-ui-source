local function GetStatusBarVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.StatusBar, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateStatusBar"}, GetStatusBarVisInfoData);

UIWidgetTemplateStatusBarMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegionFormatStrings = {
	["BorderLeft"] = "%s-BorderLeft",
	["BorderRight"] = "%s-BorderRight",
	["BorderCenter"] = "%s-BorderCenter",
	["BGLeft"] = "%s-BGLeft",
	["BGRight"] = "%s-BGRight",
	["BGCenter"] = "%s-BGCenter",
	["Spark"] = "%s-Spark",
}

local fillTextureKitFormatString = "%s-Fill-%s";

function UIWidgetTemplateStatusBarMixin:Setup(widgetInfo)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo);

	local frameTextureKit = GetUITextureKitInfo(widgetInfo.frameTextureKitID);
	local fillTextureKit = GetUITextureKitInfo(widgetInfo.fillTextureKitID);
	if frameTextureKit and fillTextureKit then
		local fillAtlas = fillTextureKitFormatString:format(frameTextureKit, fillTextureKit);
		self.Bar:SetStatusBarAtlas(fillAtlas);
	end

	SetupTextureKitOnRegions(frameTextureKit, self.Bar, textureKitRegionFormatStrings, false, true);

	self:SetTooltip(widgetInfo.tooltip);

	if widgetInfo.barWidth > 0 then
		self.Bar:SetWidth(widgetInfo.barWidth);
	else
		self.Bar:SetWidth(215);
	end

	local minVal, maxVal, barVal = widgetInfo.barMin, widgetInfo.barMax, widgetInfo.barValue;
	if minVal > 0 and minVal == maxVal and barVal == maxVal then
		-- If all 3 values are the same and greater than 0, show the bar as full
		minVal, maxVal, barVal = 0, 1, 1;
	end

	self.Bar:Setup(minVal, maxVal, barVal, widgetInfo.barValueTextType);

	local showSpark = widgetInfo.barValue > widgetInfo.barMin and widgetInfo.barValue < widgetInfo.barMax;
	self.Bar.Spark:SetShown(showSpark);
	if showSpark then
		self.Bar.Spark:ClearAllPoints();
		self.Bar.Spark:SetPoint("CENTER", self.Bar:GetStatusBarTexture(), "RIGHT", 0, 0);
	end

	self.Label:SetText(widgetInfo.text);

	local labelWidth = 0;
	local labelHeight = 0;
	self.Bar:ClearAllPoints();
	if widgetInfo.text ~= "" then
		labelWidth = self.Label:GetWidth();
		labelHeight = self.Label:GetHeight() + 3;
		self.Bar:SetPoint("TOP", self.Label, "BOTTOM", 0, -8);
	else
		self.Bar:SetPoint("TOP", self, "TOP", 0, -8);
	end

	local barWidth = self.Bar:GetWidth() + 16;

	local totalWidth = math.max(barWidth, labelWidth);
	self:SetWidth(totalWidth);

	local barHeight = self.Bar:GetHeight() + 16;

	local totalHeight = barHeight + labelHeight;
	self:SetHeight(totalHeight);
end
