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
end

local DEFAULT_SPACING = 10;

local texturekitAnimationTemplates = {
	["jailerstower-score-gem-icon"] = "TorghastGemsAnimationTemplate";
}

function UIWidgetTemplateTextureAndTextRowMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	self.entryPool:ReleaseAll();
	local animationTemplate = texturekitAnimationTemplates[widgetInfo.frameTextureKit]; 

	if(self.animationsPool) then 
		self.animationsPool:ReleaseAll(); 
	end 

	if (animationTemplate) then		
		self.animationsPool = CreateFramePool("FRAME", self, animationTemplate);
	end
	self.spacing = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or DEFAULT_SPACING;

	for index, entryInfo in ipairs(widgetInfo.entries) do
		local entryFrame = self.entryPool:Acquire();
		entryFrame:Show();	
		entryFrame:Setup(widgetContainer, entryInfo.text, entryInfo.tooltip, widgetInfo.frameTextureKit, widgetInfo.textureKit, widgetInfo.textSizeType, index);
		entryFrame:SetTooltipLocation(widgetInfo.tooltipLoc);

		if(self.animationsPool) then 
			entryFrame.FadeIn:Play(); 
			local animationFrame = self.animationsPool:Acquire(); 
			animationFrame:SetPoint("CENTER", entryFrame);
			animationFrame:SetFrameLevel(entryFrame:GetFrameLevel() - 1);
			animationFrame:Show(); 
			animationFrame.Anim1:Play();
		end
	end

	self:MarkDirty(); -- Layout visible entries horizontally
end

function UIWidgetTemplateTextureAndTextRowMixin:ShouldApplyEffectsToSubFrames()
	return true;
end

function UIWidgetTemplateTextureAndTextRowMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.entryPool:ReleaseAll();
	if (self.animationsPool) then 
		self.animationsPool:ReleaseAll();
	end 
end
