local function GetHorizontalCurrenciesVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetHorizontalCurrenciesWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.HorizontalCurrencies, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateHorizontalCurrencies"}, GetHorizontalCurrenciesVisInfoData);

UIWidgetTemplateHorizontalCurrenciesMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateHorizontalCurrenciesMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self.currencyPool:ReleaseAll();

	local previousCurrencyFrame;
	local biggestHeight = 0;

	local totalWidth = 0;

	for index, currencyInfo in ipairs(widgetInfo.currencies) do
		local currencyFrame = self.currencyPool:Acquire();
		currencyFrame:Show();

		local tooltipEnabledState = currencyInfo.isCurrencyMaxed and Enum.WidgetEnabledState.Red or Enum.WidgetEnabledState.White;

		currencyFrame:Setup(widgetContainer, currencyInfo, Enum.WidgetEnabledState.Yellow, tooltipEnabledState, nil, nil, nil, widgetInfo.tooltipLoc);

		if previousCurrencyFrame then
			currencyFrame:SetPoint("TOPLEFT", previousCurrencyFrame, "TOPRIGHT", 10, 0);
			totalWidth = totalWidth + currencyFrame:GetWidth() + 10;
		else
			currencyFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
			totalWidth = currencyFrame:GetWidth();
		end

		currencyFrame:SetOverrideNormalFontColor(self.fontColor);

		previousCurrencyFrame = currencyFrame;

		local currencyHeight = currencyFrame:GetHeight();
		if currencyHeight > biggestHeight then
			biggestHeight = currencyHeight;
		end
	end

	local useSizeSetting = widgetInfo.widgetSizeSetting > totalWidth;

	-- To keep things centered even though the frames are anchored to the topleft of the widget use half the difference
	-- compared to the fixed size.
	local width = useSizeSetting and (totalWidth + ((widgetInfo.widgetSizeSetting - totalWidth) / 2)) or totalWidth;
	self:SetWidth(width);
	self:SetHeight(biggestHeight);
end

function UIWidgetTemplateHorizontalCurrenciesMixin:OnLoad()
	self.currencyPool = CreateFramePool("FRAME", self, "UIWidgetBaseCurrencyTemplate");
end

function UIWidgetTemplateHorizontalCurrenciesMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	UIWidgetBaseCurrencyPoolOnReset(self.currencyPool);
	self.fontColor = nil;
end

function UIWidgetTemplateHorizontalCurrenciesMixin:SetFontStringColor(fontColor)
	self.fontColor = fontColor;
end
