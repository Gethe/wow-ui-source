local function GetTextColumnRowVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetTextColumnRowVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.TextColumnRow, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateTextColumnRow"}, GetTextColumnRowVisInfoData);

UIWidgetTemplateTextColumnRowMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateTextColumnRowMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self); 
	self.entryPool = CreateFramePool("FRAME", self, "UIWidgetTemplateTextColumnRowColumnTemplate");
end

local textureKitRegionFormatStrings = {
	["HighlightLeft"] = "%s-left",
	["HighlightRight"] = "%s-right",
	["HighlightCenter"] = "_%s-center",
};

function UIWidgetTemplateTextColumnRowMixin:UpdateMouseEnabled()
	-- Do nothing, we want to mouse to stay enabled
end

function UIWidgetTemplateTextColumnRowMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);

	SetupTextureKitOnRegions(widgetInfo.textureKit, self, textureKitRegionFormatStrings, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);

	self.entryPool:ReleaseAll();
	self.fixedHeight = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or nil;
	self.bottomPadding = widgetInfo.bottomPadding;

	if self.bottomPadding == 0 then
		self.HighlightLeft:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.HighlightRight:SetPoint("RIGHT", self, "RIGHT", 0, 0);
	else
		local yOffset = self.bottomPadding / 2;
		self.HighlightLeft:SetPoint("LEFT", self, "LEFT", 0, yOffset);
		self.HighlightRight:SetPoint("RIGHT", self, "RIGHT", 0, yOffset);
		if self.fixedHeight then
			self.fixedHeight = self.fixedHeight + self.bottomPadding;
		end
	end

	for index, entryInfo in ipairs(widgetInfo.entries) do
		local entry = self.entryPool:Acquire();
		entry:Setup(entryInfo.text, widgetInfo.fontType, widgetInfo.textSizeType, entryInfo.enabledState, entryInfo.hAlign, entryInfo.columnWidth, index);
		entry:Show();
	end
	
	if #widgetInfo.entries == 0 then
		self:Hide();
		return;
	else
		self:Layout();
	end
end

function UIWidgetTemplateTextColumnRowMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.entryPool:ReleaseAll();
end

UIWidgetTemplateTextColumnRowColumnMixin = {};

function UIWidgetTemplateTextColumnRowColumnMixin:Setup(text, fontType, textSizeType, enabledState, hAlign, columnWidth, layoutIndex)
	self.Text:SetWidth(columnWidth);
	self.Text:Setup(text, fontType, textSizeType, enabledState, hAlign);
	self.layoutIndex = layoutIndex;
end
