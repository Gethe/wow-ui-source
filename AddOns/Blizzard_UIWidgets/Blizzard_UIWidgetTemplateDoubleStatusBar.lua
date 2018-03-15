UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.DoubleStatusBar, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateDoubleStatusBar"}, C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo);

UIWidgetTemplateDoubleStatusBarMixin = {}

local leftBarTextureKitRegions = {
	["BG"] = "%s-bar-background",
	["BorderLeft"] = "%s-bar-border-left",
	["BorderRight"] = "%s-bar-border-right",
	["BorderCenter"] = "%s-bar-border-middle",
	["Spark"] = "%s-bar-spark-left",
	["Icon"] = "%s-icon-left",
}

local rightBarTextureKitRegions = {
	["BG"] = "%s-bar-background",
	["BorderLeft"] = "%s-bar-border-left",
	["BorderRight"] = "%s-bar-border-right",
	["BorderCenter"] = "%s-bar-border-middle",
	["Spark"] = "%s-bar-spark-right",
	["Icon"] = "%s-icon-right",
}

local textureKitStatusBars = {
	["LeftBar"] = "%s-bar-fill-left",
	["RightBar"] = "%s-bar-fill-right",
}

local BAR_WIDTH = 92;
local ICON_OFFSET = 12;

function UIWidgetTemplateDoubleStatusBarMixin:Setup(widgetInfo)
	local textureKit = GetUITextureKitInfo(widgetInfo.textureKitID);

	SetupTextureKitOnRegions(textureKit, self.LeftBar, leftBarTextureKitRegions);
	SetupTextureKitOnRegions(textureKit, self.RightBar, rightBarTextureKitRegions);
	SetupTextureKitOnRegions(textureKit, self, textureKitStatusBars);

	local leftBarPercent = PercentageBetween(widgetInfo.leftBarValue, widgetInfo.leftBarMin, widgetInfo.leftBarMax);
	local sparkXOffset = BAR_WIDTH * leftBarPercent;
	self.LeftBar:SetMinMaxValues(widgetInfo.leftBarMin, widgetInfo.leftBarMax);
	self.LeftBar:SetValue(widgetInfo.leftBarValue);
	self.LeftBar.Text:SetText(widgetInfo.leftBarValue);
	self.LeftBar.Spark:ClearAllPoints();
	self.LeftBar.Spark:SetPoint("CENTER", self.LeftBar, "LEFT", sparkXOffset, 0);
	self.LeftBar.Icon:ClearAllPoints();
	self.LeftBar.Icon:SetPoint("CENTER", self.LeftBar, "LEFT", -ICON_OFFSET, 0);

	local rightBarPercent = PercentageBetween(widgetInfo.rightBarValue, widgetInfo.rightBarMin, widgetInfo.rightBarMax);
	sparkXOffset = -BAR_WIDTH * rightBarPercent;
	self.RightBar:SetMinMaxValues(widgetInfo.rightBarMin, widgetInfo.rightBarMax);
	self.RightBar:SetValue(widgetInfo.rightBarValue);
	self.RightBar.Text:SetText(widgetInfo.rightBarValue);
	self.RightBar.Spark:ClearAllPoints();
	self.RightBar.Spark:SetPoint("CENTER", self.RightBar, "RIGHT", sparkXOffset, 0);
	self.RightBar.Icon:ClearAllPoints();
	self.RightBar.Icon:SetPoint("CENTER", self.RightBar, "RIGHT", ICON_OFFSET, 0);

	self.Label:SetText(widgetInfo.text);

	self:Show();
	self.orderIndex = widgetInfo.orderIndex;
end
