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

function UIWidgetTemplateTextureAndTextRowMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	self.entryPool:ReleaseAll();

	self.spacing = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or DEFAULT_SPACING;

	for index, entryInfo in ipairs(widgetInfo.entries) do
		local entryFrame = self.entryPool:Acquire();
		entryFrame:Show();
		entryFrame:Setup(widgetContainer, entryInfo.text, entryInfo.tooltip, widgetInfo.frameTextureKit, widgetInfo.textureKit, widgetInfo.textSizeType, index);
	end

	self:MarkDirty(); -- Layout visible entries horizontally
end

function UIWidgetTemplateTextureAndTextRowMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.entryPool:ReleaseAll();
end
