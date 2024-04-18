local function GetUnitPowerBarVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetUnitPowerBarWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.UnitPowerBar, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateUnitPowerBar"}, GetUnitPowerBarVisInfoData);

UIWidgetTemplateUnitPowerBarMixin = CreateFromMixins(UIWidgetBaseTemplateMixin, UIWidgetBaseStatusBarTemplateMixin);

local textureKitRegionFormatStrings = {
	["Frame"] = "%s-Frame",
	["BG"] = "%s-BG",
	["Fill"] = "%s-Fill",
	["Flash"] = "%s-Flash",
	["Spark"] = "%s-Spark",
}

function UIWidgetTemplateUnitPowerBarMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	SetupTextureKitOnRegions(widgetInfo.textureKit, self, textureKitRegionFormatStrings, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	local flashBlendMode = (widgetInfo.flashBlendModeType == Enum.UIWidgetBlendModeType.Additive) and "ADD" or "BLEND";
	self.Flash:SetBlendMode(flashBlendMode);
	
	local sparkBlendMode = (widgetInfo.sparkBlendModeType == Enum.UIWidgetBlendModeType.Additive) and "ADD" or "BLEND";
	self.Spark:SetBlendMode(sparkBlendMode);

	self.flashMomentType = widgetInfo.flashMomentType;
	self.insetAmount = widgetInfo.widgetSizeSetting;
	self.fillTotalWidth = self.Fill:GetWidth();
	self.fillWidth = self.fillTotalWidth - (self.insetAmount * 2);

	UIWidgetBaseStatusBarTemplateMixin.Setup(self, widgetContainer, widgetInfo);

	self:Layout();
end

function UIWidgetTemplateUnitPowerBarMixin:SetMinMaxValues(barMin, barMax)
	if self.flashMomentType == Enum.WidgetUnitPowerBarFlashMomentType.FlashWhenMax then
		self.flashValue = barMax;
	elseif self.flashMomentType == Enum.WidgetUnitPowerBarFlashMomentType.FlashWhenMin then
		self.flashValue = barMin;
	else
		self.flashValue = nil;
	end
end

function UIWidgetTemplateUnitPowerBarMixin:SetValue(barValue)
	if self.range >= 0 then
		local fillPercentage = (barValue - self.barMin) / self.range;
		local fillFinalWidth = max(self.insetAmount + (fillPercentage * self.fillWidth), 1);
		local fillFinalPercentage = fillFinalWidth / self.fillTotalWidth
		self.Fill:SetWidth(fillFinalWidth);
		self.Fill:SetTexCoord(0, fillFinalPercentage, 0, 1);
	else
		self.Fill:SetWidth(1);
		self.Fill:SetTexCoord(0, 1, 0, 1);
	end

	if self.flashValue then
		local wasAtFlashValue = self.isAtFlashValue;
		self.isAtFlashValue = (barValue == self.flashValue);

		if self.isAtFlashValue and not wasAtFlashValue then
			if self.lastBarValue then
				self.flashOutAnim:Stop();
				self.flashInAnim:Play();
			else
				self.Flash:SetAlpha(1);
			end
		elseif not self.isAtFlashValue and wasAtFlashValue then
			self.flashInAnim:Stop();
			self.flashOutAnim:Play();
		end
	else
		self.flashInAnim:Stop();
		self.flashOutAnim:Stop();
		self.Flash:SetAlpha(0);
		self.isAtFlashValue = nil;
	end

	self.lastBarValue = barValue;
end
