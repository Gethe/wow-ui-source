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

local DEFAULT_BAR_WIDTH = 92;
local ICON_OFFSET = 12;

function UIWidgetTemplateDoubleStatusBarMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	local textureKit = widgetInfo.textureKit;

	SetupTextureKitOnRegions(textureKit, self.LeftBar, leftBarTextureKitRegions);
	SetupTextureKitOnRegions(textureKit, self.RightBar, rightBarTextureKitRegions);
	SetupTextureKitOnRegions(textureKit, self, textureKitStatusBars);

	local barWidth = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or DEFAULT_BAR_WIDTH;

	self.LeftBar:SetWidth(barWidth);
	self.RightBar:SetWidth(barWidth);

	local leftBarInfo = CopyTable(widgetInfo);
	leftBarInfo.barMin = widgetInfo.leftBarMin;
	leftBarInfo.barMax = widgetInfo.leftBarMax;
	leftBarInfo.barValue = widgetInfo.leftBarValue;
	leftBarInfo.tooltip = widgetInfo.leftBarTooltip;
	self.LeftBar:Setup(widgetContainer, leftBarInfo);
	self.LeftBar:SetTooltipLocation(widgetInfo.leftBarTooltipLoc);
	self.LeftBar.Spark:SetPoint("CENTER", self.LeftBar:GetStatusBarTexture(), "RIGHT", 0, 0);

	local rightBarInfo = CopyTable(widgetInfo);
	rightBarInfo.barMin = widgetInfo.rightBarMin;
	rightBarInfo.barMax = widgetInfo.rightBarMax;
	rightBarInfo.barValue = widgetInfo.rightBarValue;
	rightBarInfo.tooltip = widgetInfo.rightBarTooltip;
	self.RightBar:Setup(widgetContainer, rightBarInfo);
	self.RightBar:SetTooltipLocation(widgetInfo.rightBarTooltipLoc);
	self.RightBar.Spark:SetPoint("CENTER", self.RightBar:GetStatusBarTexture(), "LEFT", 0, 0);

	self.LeftBar.Icon:ClearAllPoints();
	self.LeftBar.Icon:SetPoint("CENTER", self.LeftBar, "LEFT", -ICON_OFFSET, 0);
	
	self.LeftBar.IconGlow:ClearAllPoints();
	self.LeftBar.IconGlow:SetPoint("CENTER", self.LeftBar, "LEFT", -ICON_OFFSET, 0);
	
	self.LeftBar.SparkGlow:ClearAllPoints();
	self.LeftBar.SparkGlow:SetPoint("LEFT", self.LeftBar.Spark, -4, 0);

	self.RightBar.Icon:ClearAllPoints();
	self.RightBar.Icon:SetPoint("CENTER", self.RightBar, "RIGHT", ICON_OFFSET, 0);
	
	self.RightBar.IconGlow:ClearAllPoints();
	self.RightBar.IconGlow:SetPoint("CENTER", self.RightBar, "RIGHT", ICON_OFFSET, 0);
	
	self.RightBar.SparkGlow:ClearAllPoints(); 
	self.RightBar.SparkGlow:SetPoint("RIGHT", self.RightBar.Spark, 4, 0);
	
	self.Label:SetText(widgetInfo.text);

	self:SetWidth(barWidth * 2 + 14);

	if widgetInfo.text ~= "" then
		self:SetHeight(self.Label:GetHeight() + 43);
	else
		self:SetHeight(32);
	end
end

function UIWidgetTemplateDoubleStatusBarMixin:PlayBarGlow(playRightBarGlow)
	if ( playRightBarGlow ) then 
		self.RightBar.Flash:Play();
	else
		self.LeftBar.Flash:Play();
	end
end

function UIWidgetTemplateDoubleStatusBarMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.LeftBar:OnReset();
	self.RightBar:OnReset();
end
