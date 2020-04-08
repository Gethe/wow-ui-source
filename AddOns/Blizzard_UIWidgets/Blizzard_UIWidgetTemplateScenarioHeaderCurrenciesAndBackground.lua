local function GetScenarioHeaderCurrenciesAndBackgroundVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.ScenarioHeaderCurrenciesAndBackground, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateScenarioHeaderCurrenciesAndBackground"}, GetScenarioHeaderCurrenciesAndBackgroundVisInfoData);

UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local frameTextureKitRegions = {
	["Frame"] = "%s-frame",
}

local DEFAULT_CURRENCY_FRAME_WIDTH = 95;

function UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self.currencyPool:ReleaseAll();

	local previousCurrencyFrame;
	local totalCurrencyWidth = 0;
	local totalCurrencyHeight = 0;

	for index, currencyInfo in ipairs(widgetInfo.currencies) do
		local currencyFrame = self.currencyPool:Acquire();
		currencyFrame:Show();

		local enabledState = currencyInfo.isCurrencyMaxed and Enum.WidgetEnabledState.Red or Enum.WidgetEnabledState.Enabled;
		currencyFrame:Setup(widgetContainer, currencyInfo, enabledState);
		currencyFrame.Text:SetPoint("LEFT", currencyFrame.Icon, "RIGHT", 8, 0);

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

	SetupTextureKitOnRegions(widgetInfo.frameTextureKit, self, frameTextureKitRegions, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);

	self:SetWidth(self.Frame:GetWidth());
	self:SetHeight(self.Frame:GetHeight());
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
