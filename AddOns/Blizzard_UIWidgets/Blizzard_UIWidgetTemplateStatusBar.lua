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

	self.Bar:SetMinMaxValues(widgetInfo.barMin, widgetInfo.barMax);
	self.Bar:SetValue(widgetInfo.barValue);

	self.Bar.Label:SetShown(widgetInfo.barValueTextType ~= Enum.StatusBarValueTextType.Hidden);

	local maxTimeCount = self:GetMaxTimeCount(widgetInfo);

	if maxTimeCount then
		self.Bar.Label:SetText(SecondsToTime(widgetInfo.barValue, false, true, maxTimeCount, true));
	elseif widgetInfo.barValueTextType == Enum.StatusBarValueTextType.Value then
		self.Bar.Label:SetText(widgetInfo.barValue);
	elseif widgetInfo.barValueTextType == Enum.StatusBarValueTextType.ValueOverMax then
		self.Bar.Label:SetText(FormatFraction(widgetInfo.barValue, widgetInfo.barMax));
	elseif widgetInfo.barValueTextType == Enum.StatusBarValueTextType.Percentage then
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

	local barWidth = self.Bar:GetWidth() + 6;

	local totalWidth = math.max(barWidth, labelHeight);
	self:SetWidth(totalWidth);

	local barHeight = self.Bar:GetHeight() + 16;

	local totalHeight = barHeight + labelHeight;
	self:SetHeight(totalHeight);
end

function UIWidgetTemplateStatusBarMixin:GetMaxTimeCount(widgetInfo)
	if widgetInfo.barValueTextType == Enum.StatusBarValueTextType.Time then
		return 2;
	elseif widgetInfo.barValueTextType == Enum.StatusBarValueTextType.TimeShowOneLevelOnly then
		return 1;
	end
end
