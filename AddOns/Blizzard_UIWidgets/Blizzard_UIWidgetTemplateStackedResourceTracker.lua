local function GetStackedResourceTrackerVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetStackedResourceTrackerWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.StackedResourceTracker, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateStackedResourceTracker"}, GetStackedResourceTrackerVisInfoData);

UIWidgetTemplateStackedResourceTrackerMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local frameTextureKitRegions = {
	["Frame"] = "%s-frame",
}

function UIWidgetTemplateStackedResourceTrackerMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self.resourcePool:ReleaseAll();

	local previousResourceFrame;

	local hasFrame = widgetInfo.frameTextureKit ~= nil;

	local resourceWidth = 0;
	local resourceHeight = 0;

	for index, resourceInfo in ipairs(widgetInfo.resources) do
		local resourceFrame = self.resourcePool:Acquire();
		resourceFrame:Show();

		resourceFrame:Setup(widgetContainer, resourceInfo);
		resourceFrame:SetTooltipLocation(widgetInfo.tooltipLoc);

		if previousResourceFrame then
			resourceFrame:SetPoint("TOPLEFT", previousResourceFrame, "BOTTOMLEFT", 0, -6);
			resourceHeight = resourceHeight + resourceFrame:GetHeight() + 6;
		else
			if hasFrame then
				resourceFrame:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 49, -38);
			else
				resourceFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
			end

			resourceHeight = resourceFrame:GetHeight();
		end

		resourceFrame:SetOverrideNormalFontColor(self.fontColor);

		resourceWidth = math.max(resourceWidth, resourceFrame:GetWidth());

		previousResourceFrame = resourceFrame;
	end
	
	SetupTextureKitOnRegions(widgetInfo.frameTextureKit, self, frameTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	if hasFrame then
		self:SetWidth(self.Frame:GetWidth() + 45);
		self:SetHeight(self.Frame:GetHeight());
	else
		self:SetWidth(resourceWidth);
		self:SetHeight(resourceHeight);
	end
end

function UIWidgetTemplateStackedResourceTrackerMixin:OnLoad()
	self.resourcePool = CreateFramePool("FRAME", self, "UIWidgetBaseResourceTemplate");
end

function UIWidgetTemplateStackedResourceTrackerMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.resourcePool:ReleaseAll();
	self.fontColor = nil;
end

function UIWidgetTemplateStackedResourceTrackerMixin:SetFontStringColor(fontColor)
	self.fontColor = fontColor;
end
