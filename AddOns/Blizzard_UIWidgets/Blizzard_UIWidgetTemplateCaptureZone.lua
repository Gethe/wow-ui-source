local function GetCaptureZoneVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetCaptureZoneVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.CaptureZone, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateCaptureZone"}, GetCaptureZoneVisInfoData);

UIWidgetTemplateCaptureZoneMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateCaptureZoneMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self); 
	ResizeLayoutMixin.OnLoad(self); 
	self.lastVals = {};
end

function UIWidgetTemplateCaptureZoneMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	local zoneInfo = widgetInfo.zoneInfo;
	local lastVals = (self.lastVals.state == zoneInfo.state) and self.lastVals or nil;
	self.Zone:Setup(1, widgetInfo.mode, widgetInfo.leadingEdgeType, widgetInfo.dangerFlashType, zoneInfo, lastVals, widgetInfo.textureKitID);
	self.lastVals = zoneInfo;

	self:Layout();
end
