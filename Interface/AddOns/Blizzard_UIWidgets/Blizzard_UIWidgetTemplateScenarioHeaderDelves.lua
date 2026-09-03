local function GetScenarioHeaderDelvesVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.ScenarioHeaderDelves, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateScenarioHeaderDelves"}, GetScenarioHeaderDelvesVisInfoData);

UIWidgetTemplateScenarioHeaderDelvesMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local tierFlagTextureKitString = "%s-flag";
local spellRingTextureKitString = "%s-affix-ring";

local rewardTextureKits = {
	[Enum.UIWidgetRewardShownState.ShownEarned] = "%s-treasure-available",
	[Enum.UIWidgetRewardShownState.ShownUnearned] = "%s-treasure-unavailable",
};

function UIWidgetTemplateScenarioHeaderDelvesMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	local waitingForStageUpdate = UIWidgetBaseScenarioHeaderTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	if waitingForStageUpdate then
		return;
	end

	self:SetTooltip(widgetInfo.tooltip);

	SetupTextureKitOnFrame(widgetInfo.frameTextureKit, self.TierFrame.Flag, tierFlagTextureKitString, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize)
	self.TierFrame.Text:SetText(widgetInfo.tierText);
	self.TierFrame.tooltipSpellID = widgetInfo.tierTooltipSpellID;
	self.TierFrame:Layout();

	self.currencyPool:ReleaseAll();

	for index, currencyInfo in ipairs(widgetInfo.currencies) do
		local currencyFrame = self.currencyPool:Acquire();
		currencyFrame:Setup(widgetContainer, currencyInfo, currencyInfo.textEnabledState);
		currencyFrame:SetTooltipLocation(Enum.UIWidgetTooltipLocation.BottomRight);
		currencyFrame.layoutIndex = index;
		currencyFrame:Show();
	end

	self.CurrencyContainer:Layout();

	local oldSpellCount = self.spellPool:GetNumActive();
	if oldSpellCount ~= #widgetInfo.spells then
		-- If the number of spells changed, call UIWidgetBaseSpellPoolOnReset to kill effects on existing spell frames
		UIWidgetBaseSpellPoolOnReset(self.spellPool);
	else
		self.spellPool:ReleaseAll();
	end

	local spellRingTextureKit = spellRingTextureKitString:format(widgetInfo.frameTextureKit);

	for index, spellInfo in ipairs(widgetInfo.spells) do
		local spellFrame = self.spellPool:Acquire();
		spellFrame:Setup(widgetContainer, spellInfo, 0, spellRingTextureKit);
		self:UpdateSpellFrameEffects(widgetInfo, spellInfo, spellFrame);
		spellFrame.layoutIndex = index;
		spellFrame:Show();
	end

	self.SpellContainer:Layout();

	if widgetInfo.rewardInfo.shownState ~= Enum.UIWidgetRewardShownState.Hidden then
		SetupTextureKitOnFrame(widgetInfo.frameTextureKit, self.RewardFrame.Texture, rewardTextureKits[widgetInfo.rewardInfo.shownState], TextureKitConstants.SetVisibility, TextureKitConstants.IgnoreAtlasSize)
		local rewardTooltip = (widgetInfo.rewardInfo.shownState == Enum.UIWidgetRewardShownState.ShownEarned) and widgetInfo.rewardInfo.earnedTooltip or widgetInfo.rewardInfo.unearnedTooltip;
		self.RewardFrame:SetTooltipLocation(Enum.UIWidgetTooltipLocation.BottomRight);
		self.RewardFrame:SetTooltip(rewardTooltip);
		self.RewardFrame:Show();
	else
		self.RewardFrame:Hide();
	end
end

function UIWidgetTemplateScenarioHeaderDelvesMixin:ApplyEffects(widgetInfo)
	-- Intentionally empty, ScenarioHeaderDelves widgets apply effects to child spell frames (see UpdateSpellFrameEffects)
end

function UIWidgetTemplateScenarioHeaderDelvesMixin:UpdateSpellFrameEffects(widgetInfo, spellInfo, spellFrame)
	if spellInfo.showGlowState == Enum.WidgetShowGlowState.ShowGlow then
		if not spellFrame.effectController then
			self:ApplyEffectToFrame(widgetInfo, self.widgetContainer, spellFrame);
		end
	elseif spellFrame.effectController then
		spellFrame.effectController:CancelEffect();
		spellFrame.effectController = nil;
	end
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
	UIWidgetBaseCurrencyPoolOnReset(self.currencyPool);
	UIWidgetBaseSpellPoolOnReset(self.spellPool);
end

UIWidgetTemplateScenarioHeaderDelvesTierFrameMixin = {};

function UIWidgetTemplateScenarioHeaderDelvesTierFrameMixin:OnEnter()
	if self.tooltipSpellID then
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
		EmbeddedItemTooltip:SetSpellByID(self.tooltipSpellID);
	end
end

function UIWidgetTemplateScenarioHeaderDelvesTierFrameMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
end
