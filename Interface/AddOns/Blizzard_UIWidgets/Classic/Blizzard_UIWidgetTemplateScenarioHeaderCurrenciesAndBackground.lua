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

function UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin:Setup(widgetInfo)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo);
	self.currencyPool:ReleaseAll();

	local previousCurrencyFrame;
	local totalCurrencyWidth = 0;
	local totalCurrencyHeight = 0;

	for index, currencyInfo in ipairs(widgetInfo.currencies) do
		local currencyFrame = self.currencyPool:Acquire();
		currencyFrame:Show();

		local enabledState = currencyInfo.isCurrencyMaxed and Enum.WidgetEnabledState.Red or Enum.WidgetEnabledState.Normal;
		currencyFrame:Setup(currencyInfo, enabledState);
		currencyFrame.Text:SetPoint("LEFT", currencyFrame.Icon, "RIGHT", 8, 0);

		-- Keep the currency frame width the same for anchoring
		currencyFrame:SetWidth(95);

		if previousCurrencyFrame then
			currencyFrame:SetPoint("TOPLEFT", previousCurrencyFrame, "TOPRIGHT", 10, 0);
			totalCurrencyWidth = totalCurrencyWidth + currencyFrame:GetWidth() + 10;
		else
			currencyFrame:SetPoint("TOPLEFT", self.CurrencyContainer, "TOPLEFT", 0, 0);
			totalCurrencyWidth = totalCurrencyWidth + currencyFrame:GetWidth();
		end

		totalCurrencyHeight = currencyFrame:GetHeight();

		previousCurrencyFrame = currencyFrame;
	end

	self.CurrencyContainer:SetWidth(totalCurrencyWidth);
	self.CurrencyContainer:SetHeight(totalCurrencyHeight);

	SetupTextureKits(widgetInfo.frameTextureKitID, self, frameTextureKitRegions, false, true);

	self:SetWidth(self.Frame:GetWidth());
	self:SetHeight(self.Frame:GetHeight());
end

function UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin:OnLoad()
	self.currencyPool = CreateFramePool("FRAME", self.CurrencyContainer, "UIWidgetBaseCurrencyTemplate");
end

function UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.currencyPool:ReleaseAll();
end
