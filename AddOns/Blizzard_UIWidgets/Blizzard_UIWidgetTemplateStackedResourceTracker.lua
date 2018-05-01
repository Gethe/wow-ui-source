UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.StackedResourceTracker, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateStackedResourceTracker"}, C_UIWidgetManager.GetStackedResourceTrackerWidgetVisualizationInfo);

UIWidgetTemplateStackedResourceTrackerMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local frameTextureKitRegions = {
	["Frame"] = "%s-frame",
}

function UIWidgetTemplateStackedResourceTrackerMixin:Setup(widgetInfo)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo);
	self.resourcePool:ReleaseAll();
	self.FontStrings = {};

	local previousResourceFrame;

	for index, resource in ipairs(widgetInfo.resources) do
		local resourceFrame = self.resourcePool:Acquire();
		resourceFrame:Show();

		local atlasName = "%s-icon"..index;
		resourceFrame:Setup(resource, widgetInfo.textureKitID, atlasName);

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
