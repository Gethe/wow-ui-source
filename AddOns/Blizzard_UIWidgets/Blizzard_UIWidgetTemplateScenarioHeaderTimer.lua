local function GetScenarioHeaderTimerVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.ScenarioHeaderTimer, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateScenarioHeaderTimer"}, GetScenarioHeaderTimerVisInfoData);

local fillTextureKitFormatString = "%s-barfill";

UIWidgetTemplateScenarioHeaderTimerMixin = CreateFromMixins(UIWidgetBaseTemplateMixin, UIWidgetBaseScenarioHeaderTemplateMixin);

function UIWidgetTemplateScenarioHeaderTimerMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	local waitingForStageUpdate = UIWidgetBaseScenarioHeaderTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	if waitingForStageUpdate then
		return;
	end

	local timerValue = Clamp(widgetInfo.timerValue, widgetInfo.timerMin, widgetInfo.timerMax);
	local timeRemaining = timerValue - widgetInfo.timerMin;
	local timerText = SecondsToClock(timeRemaining);

	self.Timer.Text:SetWidth(0);
	self.Timer.Text:SetText(timerText);
	self.Timer:SetTooltip(widgetInfo.timerTooltip);

	SetupTextureKitOnFrame(widgetInfo.frameTextureKit, self.TimerBar, fillTextureKitFormatString, TextureKitConstants.SetVisibility)
	self.TimerBar:SetMinMaxValues(widgetInfo.timerMin, widgetInfo.timerMax);
	self.TimerBar:SetValue(timerValue);

	self.TimerBar:SetTooltip(widgetInfo.timerTooltip);
end
