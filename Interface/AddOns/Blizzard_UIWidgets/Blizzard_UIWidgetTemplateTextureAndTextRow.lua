local function GetTextureAndTextRowVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetTextureAndTextRowVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.TextureAndTextRow, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateTextureAndTextRow"}, GetTextureAndTextRowVisInfoData);

UIWidgetTemplateTextureAndTextRowMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateTextureAndTextRowMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self); 
	self.entryPool = CreateFramePool("FRAME", self, "UIWidgetBaseTextureAndTextTemplate");
	self.animationPools = CreateFramePoolCollection();
end

local DEFAULT_SPACING = 10;

local texturekitAnimationTemplatesInfo = {
	["jailerstower-score-gem-icon"] = {template = "TorghastGemsAnimationTemplate", animationDelayModifier = .5, effectDelay = .25};
}

function UIWidgetTemplateTextureAndTextRowMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	self.entryPool:ReleaseAll();
	self.animationPools:ReleaseAll();
	self.spacing = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or DEFAULT_SPACING;
	self.fixedWidth = widgetInfo.fixedWidth;

	self.animationInfo = texturekitAnimationTemplatesInfo[widgetInfo.frameTextureKit];
	local shownEntries = {};
	local animateEntries = {};
	for index, entryInfo in ipairs(widgetInfo.entries) do
		local entryFrame = self.entryPool:Acquire();
		entryFrame:Setup(widgetContainer, entryInfo.text, entryInfo.tooltip, widgetInfo.frameTextureKit, widgetInfo.textureKit, widgetInfo.textSizeType, index);
		entryFrame:SetTooltipLocation(widgetInfo.tooltipLoc);

		if self.animationInfo then
			if not self.lastShownEntries[index] then
				table.insert(animateEntries, entryFrame);
			end
		else
			entryFrame:SetAlpha(1);
		end

		entryFrame:Show();

		shownEntries[index] = true;
	end
	self.lastShownEntries = shownEntries;

	if #widgetInfo.entries == 0 then
		self:Hide();
		return;
	else
		self:Layout(); -- Layout visible entries horizontally
	end

	if self.animationInfo then
		self:PlayAnimations(widgetInfo, animateEntries);
	end
end

function UIWidgetTemplateTextureAndTextRowMixin:PlayAnimations(widgetInfo, animateEntries)
	for index, entryFrame in ipairs(animateEntries) do
		entryFrame:SetAlpha(0);
		self:PlayAnimOnEntryFrame(widgetInfo, entryFrame, index);
	end
end

function UIWidgetTemplateTextureAndTextRowMixin:PlayAnimOnEntryFrame(widgetInfo, entryFrame, index)
	if self.animationInfo then
		local animationPool = self.animationPools:GetOrCreatePool("FRAME", self, self.animationInfo.template);
		if animationPool and not entryFrame.animationFrame then 
			entryFrame.animationFrame = animationPool:Acquire(); 
			entryFrame.animationFrame:SetPoint("CENTER", entryFrame);
			entryFrame.animationFrame:SetFrameLevel(entryFrame:GetFrameLevel() + 1);
			entryFrame.animationFrame:Reset();
			entryFrame.animationFrame:Show();

			local function applyEffectAndClearAnim()
				self:ApplyEffectToFrame(widgetInfo, self.widgetContainer, entryFrame);
				entryFrame:SetAlpha(1);
				entryFrame.animationFrame = nil;
			end

			local function playAnim()
				entryFrame.animationFrame:Play();
				entryFrame.animTimer = C_Timer.NewTimer(self.animationInfo.effectDelay, applyEffectAndClearAnim);
			end

			entryFrame.animTimer = C_Timer.NewTimer(index * self.animationInfo.animationDelayModifier, playAnim);
		end
	end
end

function UIWidgetTemplateTextureAndTextRowMixin:ApplyEffects(widgetInfo)
	if not self.animationInfo then
		UIWidgetBaseTemplateMixin.ApplyEffects(self, widgetInfo);
	end
end

function UIWidgetTemplateTextureAndTextRowMixin:ClearAllAnimations()
	for entryFrame in self.entryPool:EnumerateActive() do
		if entryFrame.animTimer then
			entryFrame.animTimer:Cancel();
		end
		if entryFrame.animationFrame then
			entryFrame.animationFrame:Reset();
			entryFrame.animationFrame = nil;
		end
	end

	self.animationPools:ReleaseAll();
	self.lastShownEntries = {};
end

function UIWidgetTemplateTextureAndTextRowMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self:ClearAllAnimations();
	self.entryPool:ReleaseAll();
	self.animationInfo = nil;
	self.fixedWidth = nil;
end
