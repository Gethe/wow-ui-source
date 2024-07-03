local function GetScenarioHeaderDelvesVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.ScenarioHeaderDelves, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateScenarioHeaderDelves"}, GetScenarioHeaderDelvesVisInfoData);

UIWidgetTemplateScenarioHeaderDelvesMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegions = {
	["TierFlag"] = "%s-flag",
}

function UIWidgetTemplateScenarioHeaderDelvesMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	local waitingForStageUpdate = UIWidgetBaseScenarioHeaderTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	if waitingForStageUpdate then
		return;
	end

	SetupTextureKitOnRegions(widgetInfo.frameTextureKit, self, textureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	self.TierText:SetText(widgetInfo.tierText);

	self.currencyPool:ReleaseAll();

	for index, currencyInfo in ipairs(widgetInfo.currencies) do
		local currencyFrame = self.currencyPool:Acquire();
		currencyFrame:Setup(widgetContainer, currencyInfo, currencyInfo.textEnabledState);
		currencyFrame.layoutIndex = index;
		currencyFrame:Show();
	end

	self.CurrencyContainer:Layout();

	self.spellPool:ReleaseAll();

	for index, spellInfo in ipairs(widgetInfo.spells) do
		local spellFrame = self.spellPool:Acquire();
		spellFrame:Setup(widgetContainer, spellInfo, 0, "delves-affix-ring");
		spellFrame.layoutIndex = index;
		spellFrame:Show();
	end

	self.SpellContainer:Layout();
end

function UIWidgetTemplateScenarioHeaderDelvesMixin:CustomDebugSetup(color)
	for currency in self.currencyPool:EnumerateActive() do
		if not currency._debugBGTex then
			currency._debugBGTex = currency:CreateTexture()
			currency._debugBGTex:SetColorTexture(color:GetRGBA());
			currency._debugBGTex:SetAllPoints(currency);
		end
	end

	for spell in self.spellPool:EnumerateActive() do
		if not spell._debugBGTex then
			spell._debugBGTex = spell:CreateTexture()
			spell._debugBGTex:SetColorTexture(color:GetRGBA());
			spell._debugBGTex:SetAllPoints(spell);
		end
	end
end

function UIWidgetTemplateScenarioHeaderDelvesMixin:OnLoad()
	self.currencyPool = CreateFramePool("FRAME", self.CurrencyContainer, "UIWidgetBaseCurrencyTemplate");
	self.spellPool = CreateFramePool("FRAME", self.SpellContainer, "UIWidgetBaseSpellTemplate");
end

function UIWidgetTemplateScenarioHeaderDelvesMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.currencyPool:ReleaseAll();
	self.spellPool:ReleaseAll();
end
