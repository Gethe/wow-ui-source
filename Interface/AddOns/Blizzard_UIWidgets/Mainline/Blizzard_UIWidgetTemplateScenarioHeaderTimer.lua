local function GetScenarioHeaderTimerVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.ScenarioHeaderTimer, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateScenarioHeaderTimer"}, GetScenarioHeaderTimerVisInfoData);

local fillTextureKitFormatString = "%s-barfill";

local textureKitOffsets = {
	["evergreen-scenario"] = {timerBarYOffset = 7, timerBarWidth = 239},
	["thewarwithin-scenario"] = {timerBarXOffset = -1, timerBarYOffset = 5, timerBarWidth = 239},
};

local defaultTimerBarXOffset = 0;
local defaultTimerBarYOffset = 4;
local defaultTimerBarWidth = 233;

UIWidgetTemplateScenarioHeaderTimerMixin = CreateFromMixins(UIWidgetBaseTemplateMixin, UIWidgetBaseScenarioHeaderTemplateMixin);

function UIWidgetTemplateScenarioHeaderTimerMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	local waitingForStageUpdate = UIWidgetBaseScenarioHeaderTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	if waitingForStageUpdate then
		return;
	end

	local textureKitInfo = textureKitOffsets[widgetInfo.frameTextureKit];

	local timerValue = Clamp(widgetInfo.timerValue, widgetInfo.timerMin, widgetInfo.timerMax);
	local timeRemaining = timerValue - widgetInfo.timerMin;
	local timerText = SecondsToClock(timeRemaining);

	self.Timer.Text:SetWidth(0);
	self.Timer.Text:SetText(timerText);
	self.Timer:SetTooltip(widgetInfo.timerTooltip);

	SetupTextureKitOnFrame(widgetInfo.frameTextureKit, self.TimerBar, fillTextureKitFormatString, TextureKitConstants.SetVisibility)
	self.TimerBar:SetMinMaxValues(widgetInfo.timerMin, widgetInfo.timerMax);
	self.TimerBar:SetValue(timerValue);

	local timerBarXOffset = textureKitInfo and textureKitInfo.timerBarXOffset or defaultTimerBarXOffset;
	local timerBarYOffset = textureKitInfo and textureKitInfo.timerBarYOffset or defaultTimerBarYOffset;
	self.TimerBar:SetPoint("BOTTOM", self, "BOTTOM", timerBarXOffset, timerBarYOffset);

	local timerBarWidth = textureKitInfo and textureKitInfo.timerBarWidth or defaultTimerBarWidth;
	self.TimerBar:SetWidth(timerBarWidth);

	self.TimerBar:SetTooltip(widgetInfo.timerTooltip);
end
