local function GetStatusBarVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		widgetInfo.hasTimer = widgetInfo.barValueInSeconds > -1;
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

	self.Bar:SetWidth(widgetInfo.barWidth);
	self.Bar:SetMinMaxValues(widgetInfo.barMin, widgetInfo.barMax);
	self.Bar:SetValue(widgetInfo.barValue);

	if widgetInfo.barValueInSeconds > -1 then
		self.Bar.Label:SetText(SecondsToTime(widgetInfo.barValueInSeconds, true, true, 2, true));
	else
		local barPercent = PercentageBetween(widgetInfo.barValue, widgetInfo.barMin, widgetInfo.barMax);
		local barPercentText = FormatPercentage(barPercent, true);
		self.Bar.Label:SetText(barPercentText);
	end

	local showSpark = widgetInfo.barValue > widgetInfo.barMin and widgetInfo.barValue < widgetInfo.barMax;
	self.Bar.Spark:SetShown(showSpark);
	if showSpark then
		self.Bar.Spark:ClearAllPoints();
		self.Bar.Spark:SetPoint("CENTER", self.Bar:GetStatusBarTexture(), "RIGHT", 0, 0);
	end

	self.Label:SetText(widgetInfo.text);

	local barWidth = self.Bar:GetWidth() + 6;
	local labelWidth = self.Label:GetWidth();

	local totalWidth = barWidth > labelWidth and barWidth or labelWidth;
	self:SetWidth(totalWidth);

	local barHeight = self.Bar:GetHeight() + 16;
	local labelHeight = self.Label:GetHeight() + 7;

	local totalHeight = (widgetInfo.text and widgetInfo.text ~= "") and (barHeight + labelHeight) or barHeight;
	self:SetHeight(totalHeight);
end
