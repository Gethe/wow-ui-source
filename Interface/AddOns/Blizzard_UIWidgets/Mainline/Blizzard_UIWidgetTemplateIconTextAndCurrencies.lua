local function GetIconTextAndCurrenciesVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetIconTextAndCurrenciesWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.IconTextAndCurrencies, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateIconTextAndCurrencies"}, GetIconTextAndCurrenciesVisInfoData);

UIWidgetTemplateIconTextAndCurrenciesMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegions = {
	["Icon"] = "%s",
}

function UIWidgetTemplateIconTextAndCurrenciesMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self.currencyPool:ReleaseAll();

	SetupTextureKitOnRegions(widgetInfo.textureKit, self, textureKitRegions);
	self.Text:SetText(widgetInfo.text);
	local enabledState = widgetInfo.enabledState;
	if widgetInfo.enabledState == Enum.WidgetEnabledState.Yellow then
		enabledState = Enum.WidgetEnabledState.White;
	end
	self.Text:SetEnabledState(enabledState);

	local disabled = (enabledState == Enum.WidgetEnabledState.Disabled);
	self.Icon:SetDesaturated(disabled);

	local previousCurrencyFrame;
	local firstCurrencyFrame;

	local currencyHeight = 0;
	for index, currencyInfo in ipairs(widgetInfo.currencies) do
		local currencyFrame = self.currencyPool:Acquire();
		currencyFrame:Show();

		currencyFrame:Setup(widgetContainer, currencyInfo, enabledState);
		currencyFrame:SetTooltipLocation(widgetInfo.tooltipLoc);

		if previousCurrencyFrame then
			currencyFrame:SetPoint("TOPLEFT", previousCurrencyFrame, "TOPRIGHT", 10, 0);
		else
			currencyFrame:SetPoint("TOPLEFT", self.Text, "BOTTOMLEFT", 0, -2);
			firstCurrencyFrame = currencyFrame;
		end

		previousCurrencyFrame = currencyFrame;

		currencyHeight = math.max(currencyHeight, currencyFrame:GetHeight() + 2);
	end

	local descHeight = 0;
	local showDescription = (widgetInfo.descriptionShownState == Enum.WidgetShownState.Shown) and (widgetInfo.description ~= "");
	if showDescription then
		self.Description:SetText(widgetInfo.description);
		self.Description:SetEnabledState(widgetInfo.descriptionEnabledState);
		self.Description:Show();

		self.Description:ClearAllPoints();
		if firstCurrencyFrame then
			self.Description:SetPoint("TOPLEFT", firstCurrencyFrame, "BOTTOMLEFT", 0, -2);
		else
			self.Description:SetPoint("TOPLEFT", self.Text, "BOTTOMLEFT", 0, -2);
		end

		descHeight = self.Description:GetStringHeight() + 2;
	else
		self.Description:Hide();
	end

	local otherHeight = self.Text:GetStringHeight() + currencyHeight + descHeight;

	self:SetHeight(math.max(self.Icon:GetHeight(), otherHeight));
end

function UIWidgetTemplateIconTextAndCurrenciesMixin:OnLoad()
	self.currencyPool = CreateFramePool("FRAME", self, "UIWidgetBaseCurrencyTemplate");
end

function UIWidgetTemplateIconTextAndCurrenciesMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.currencyPool:ReleaseAll();
end
