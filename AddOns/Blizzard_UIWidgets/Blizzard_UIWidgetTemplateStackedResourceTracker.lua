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

function UIWidgetTemplateStackedResourceTrackerMixin:Setup(widgetInfo)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo);
	self.resourcePool:ReleaseAll();
	self.FontStrings = {};

	local previousResourceFrame;

	for index, resourceInfo in ipairs(widgetInfo.resources) do
		local resourceFrame = self.resourcePool:Acquire();
		resourceFrame:Show();

		resourceFrame:Setup(resourceInfo);

		if previousResourceFrame then
			resourceFrame:SetPoint("TOPLEFT", previousResourceFrame, "BOTTOMLEFT", 0, -6);
		else
			resourceFrame:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 49, -38);
		end

		table.insert(self.FontStrings, resourceFrame.Text);

		previousResourceFrame = resourceFrame;
	end
	
	SetupTextureKits(widgetInfo.frameTextureKitID, self, frameTextureKitRegions, false, true);

	self:SetWidth(self.Frame:GetWidth() + 45);
	self:SetHeight(self.Frame:GetHeight());
end

function UIWidgetTemplateStackedResourceTrackerMixin:OnLoad()
	self.resourcePool = CreateFramePool("FRAME", self, "UIWidgetBaseResourceTemplate");
end

function UIWidgetTemplateStackedResourceTrackerMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.resourcePool:ReleaseAll();
	self.FontStrings = {};
end

function UIWidgetTemplateStackedResourceTrackerMixin:GatherColorableFontStrings()
	return self.FontStrings;
end
