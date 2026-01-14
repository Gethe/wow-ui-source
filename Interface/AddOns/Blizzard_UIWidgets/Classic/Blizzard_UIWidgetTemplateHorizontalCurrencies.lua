local function GetHorizontalCurrenciesVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetHorizontalCurrenciesWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.HorizontalCurrencies, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateHorizontalCurrencies"}, GetHorizontalCurrenciesVisInfoData);

UIWidgetTemplateHorizontalCurrenciesMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateHorizontalCurrenciesMixin:Setup(widgetInfo)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo);
	self.currencyPool:ReleaseAll();

	local previousCurrencyFrame;
	local biggestHeight = 0;

	local totalWidth = 0;

	for index, currencyInfo in ipairs(widgetInfo.currencies) do
		local currencyFrame = self.currencyPool:Acquire();
		currencyFrame:Show();

		currencyFrame:Setup(currencyInfo, Enum.WidgetEnabledState.Highlight);

		if previousCurrencyFrame then
			currencyFrame:SetPoint("TOPLEFT", previousCurrencyFrame, "TOPRIGHT", 10, 0);
			totalWidth = totalWidth + currencyFrame:GetWidth() + 10;
		else
			currencyFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
			totalWidth = currencyFrame:GetWidth();
		end

		if self.fontColor then
			currencyFrame:SetFontColor(self.fontColor);
		end

		previousCurrencyFrame = currencyFrame;

		local currencyHeight = currencyFrame:GetHeight();
		if currencyHeight > biggestHeight then
			biggestHeight = currencyHeight;
		end
	end

	self:SetWidth(totalWidth);
	self:SetHeight(biggestHeight);
end

function UIWidgetTemplateHorizontalCurrenciesMixin:OnLoad()
	self.currencyPool = CreateFramePool("FRAME", self, "UIWidgetBaseCurrencyTemplate");
end

function UIWidgetTemplateHorizontalCurrenciesMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.currencyPool:ReleaseAll();
	self.fontColor = nil;
end

function UIWidgetTemplateHorizontalCurrenciesMixin:SetFontStringColor(fontColor)
	self.fontColor = fontColor;
end
