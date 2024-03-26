local function GetScenarioHeaderCurrenciesAndBackgroundVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.ScenarioHeaderCurrenciesAndBackground, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateScenarioHeaderCurrenciesAndBackground"}, GetScenarioHeaderCurrenciesAndBackgroundVisInfoData);

UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitInfo =
{
	["jailerstower-scenario"] = {currencyContainerOffsets = {xOffset = 32, yOffset = -46}},
	["jailerstower-scenario-nodeaths"] = {currencyContainerOffsets = {xOffset = 34, yOffset = -46}},
	["plunderstorm-scenariotracker-active"] = {currencyFontObject = GameFontHighlight, hideCurrencyIcon = true, currencyContainerOffsets = {xOffset = 40, yOffset = -46}, currencyFontColor = WHITE_FONT_COLOR},
	["plunderstorm-scenariotracker-waiting"] = {currencyFontObject = GameFontHighlight, hideCurrencyIcon = true, currencyContainerOffsets = {xOffset = 40, yOffset = -46}, currencyFontColor = WHITE_FONT_COLOR},
}

local DEFAULT_CURRENCY_FRAME_WIDTH = 95;
local DEFAULT_CURRENCY_CONTAINER_OFFSETS = {xOffset = 19, yOffset = -46};

function UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	local waitingForStageUpdate = UIWidgetBaseScenarioHeaderTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	if waitingForStageUpdate then
		return;
	end

	local textureKitInfo = textureKitInfo[widgetInfo.frameTextureKit];
	local currencyContainerOffsets = textureKitInfo and textureKitInfo.currencyContainerOffsets or DEFAULT_CURRENCY_CONTAINER_OFFSETS;
	self.CurrencyContainer:SetPoint("TOPLEFT", self, "TOPLEFT", currencyContainerOffsets.xOffset, currencyContainerOffsets.yOffset);

	self.currencyPool:ReleaseAll();

	local previousCurrencyFrame;
	local totalCurrencyWidth = 0;
	local totalCurrencyHeight = 0;

	for index, currencyInfo in ipairs(widgetInfo.currencies) do
		local currencyFrame = self.currencyPool:Acquire();
		currencyFrame:Show();

		local enabledState = currencyInfo.isCurrencyMaxed and Enum.WidgetEnabledState.Red or Enum.WidgetEnabledState.Yellow;
		local hideCurrencyIcon = textureKitInfo and textureKitInfo.hideCurrencyIcon;
		local customFontObj = textureKitInfo and textureKitInfo.currencyFontObject;
		local customFontColor = textureKitInfo and textureKitInfo.currencyFontColor;
		currencyFrame:Setup(widgetContainer, currencyInfo, enabledState, nil, hideCurrencyIcon, customFontObj, customFontColor);

		if not hideCurrencyIcon then
			currencyFrame.Text:SetPoint("LEFT", currencyFrame.Icon, "RIGHT", 8, 0);
		end

		if previousCurrencyFrame then
			currencyFrame:SetPoint("TOPLEFT", previousCurrencyFrame, "TOPRIGHT", 10, 0);
			totalCurrencyWidth = totalCurrencyWidth + currencyFrame:GetWidth() + 10;
			currencyFrame:SetWidth(DEFAULT_CURRENCY_FRAME_WIDTH);
		else
			currencyFrame:SetPoint("TOPLEFT", self.CurrencyContainer, "TOPLEFT", 0, 0);
			totalCurrencyWidth = totalCurrencyWidth + currencyFrame:GetWidth();

			local leftCurrencyWidth = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or DEFAULT_CURRENCY_FRAME_WIDTH;
			currencyFrame:SetWidth(leftCurrencyWidth);
		end

		totalCurrencyHeight = currencyFrame:GetHeight();

		previousCurrencyFrame = currencyFrame;
	end

	self.CurrencyContainer:SetWidth(totalCurrencyWidth);
	self.CurrencyContainer:SetHeight(totalCurrencyHeight);
end

function UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin:CustomDebugSetup(color)
	for currency in self.currencyPool:EnumerateActive() do
		if not currency._debugBGTex then
			currency._debugBGTex = currency:CreateTexture()
			currency._debugBGTex:SetColorTexture(color:GetRGBA());
			currency._debugBGTex:SetAllPoints(currency);
		end
	end
end

function UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin:OnLoad()
	self.currencyPool = CreateFramePool("FRAME", self.CurrencyContainer, "UIWidgetBaseCurrencyTemplate");
end

function UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.currencyPool:ReleaseAll();
end
