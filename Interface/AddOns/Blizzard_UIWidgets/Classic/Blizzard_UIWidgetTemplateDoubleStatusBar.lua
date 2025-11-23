local function GetDoubleStatusBarVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.DoubleStatusBar, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateDoubleStatusBar"}, GetDoubleStatusBarVisInfoData);

UIWidgetTemplateDoubleStatusBarMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local leftBarTextureKitRegions = {
	["BG"] = "%s-bar-background",
	["BorderLeft"] = "%s-bar-border-left",
	["BorderRight"] = "%s-bar-border-right",
	["BorderCenter"] = "%s-bar-border-middle",
	["Spark"] = "%s-bar-spark-left",
	["Icon"] = "%s-icon-left",
	["IconGlow"] = "%s-icon-left",
}

local rightBarTextureKitRegions = {
	["BG"] = "%s-bar-background",
	["BorderLeft"] = "%s-bar-border-left",
	["BorderRight"] = "%s-bar-border-right",
	["BorderCenter"] = "%s-bar-border-middle",
	["Spark"] = "%s-bar-spark-right",
	["Icon"] = "%s-icon-right",
	["IconGlow"] = "%s-icon-right",
}

local textureKitStatusBars = {
	["LeftBar"] = "%s-bar-fill-left",
	["RightBar"] = "%s-bar-fill-right",
}

local BAR_WIDTH = 92;
local ICON_OFFSET = 12;

function UIWidgetTemplateDoubleStatusBarMixin:Setup(widgetInfo)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo);
	local textureKit = GetUITextureKitInfo(widgetInfo.textureKitID);

	SetupTextureKitOnRegions(textureKit, self.LeftBar, leftBarTextureKitRegions);
	SetupTextureKitOnRegions(textureKit, self.RightBar, rightBarTextureKitRegions);
	SetupTextureKitOnRegions(textureKit, self, textureKitStatusBars);

	self.LeftBar.Spark:SetShown(widgetInfo.leftBarValue > widgetInfo.leftBarMin and widgetInfo.leftBarValue < widgetInfo.leftBarMax);

	local leftBarPercent = PercentageBetween(widgetInfo.leftBarValue, widgetInfo.leftBarMin, widgetInfo.leftBarMax);
	local sparkXOffset = BAR_WIDTH * leftBarPercent;
	self.LeftBar:SetMinMaxValues(widgetInfo.leftBarMin, widgetInfo.leftBarMax);
	self.LeftBar:SetValue(widgetInfo.leftBarValue);
	self.LeftBar.Text:SetText(widgetInfo.leftBarValue);
	
	self.LeftBar.Spark:ClearAllPoints();
	self.LeftBar.Spark:SetPoint("CENTER", self.LeftBar, "LEFT", sparkXOffset, 0);
	
	self.LeftBar.Icon:ClearAllPoints();
	self.LeftBar.Icon:SetPoint("CENTER", self.LeftBar, "LEFT", -ICON_OFFSET, 0);
	
	self.LeftBar.IconGlow:ClearAllPoints();
	self.LeftBar.IconGlow:SetPoint("CENTER", self.LeftBar, "LEFT", -ICON_OFFSET, 0);
	
	self.LeftBar.SparkGlow:ClearAllPoints();
	self.LeftBar.SparkGlow:SetPoint("LEFT", self.Spark, -4, 0);

	self.RightBar.Spark:SetShown(widgetInfo.rightBarValue > widgetInfo.rightBarMin and widgetInfo.rightBarValue < widgetInfo.rightBarMax);

	local rightBarPercent = PercentageBetween(widgetInfo.rightBarValue, widgetInfo.rightBarMin, widgetInfo.rightBarMax);
	sparkXOffset = -BAR_WIDTH * rightBarPercent;
	self.RightBar:SetMinMaxValues(widgetInfo.rightBarMin, widgetInfo.rightBarMax);
	self.RightBar:SetValue(widgetInfo.rightBarValue);
	self.RightBar.Text:SetText(widgetInfo.rightBarValue);
	
	self.RightBar.Spark:ClearAllPoints();
	self.RightBar.Spark:SetPoint("CENTER", self.RightBar, "RIGHT", sparkXOffset, 0);
	
	self.RightBar.Icon:ClearAllPoints();
	self.RightBar.Icon:SetPoint("CENTER", self.RightBar, "RIGHT", ICON_OFFSET, 0);
	
	self.RightBar.IconGlow:ClearAllPoints();
	self.RightBar.IconGlow:SetPoint("CENTER", self.RightBar, "RIGHT", ICON_OFFSET, 0);
	
	self.LeftBar.SparkGlow:ClearAllPoints(); 
	self.LeftBar.SparkGlow:SetPoint("RIGHT", self.Spark, -4, 0);
	
	self.Label:SetText(widgetInfo.text);
end

function UIWidgetTemplateDoubleStatusBarMixin:PlayBarGlow(playRightBarGlow)
	if ( playRightBarGlow ) then 
		self.RightBar.Flash:Play();
	else
		self.LeftBar.Flash:Play();
	end
end
