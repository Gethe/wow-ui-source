local function GetZoneControlVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetZoneControlVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.ZoneControl, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateZoneControl"}, GetZoneControlVisInfoData);

UIWidgetTemplateZoneControlMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateZoneControlMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self);
	self.entryPool = CreateFramePool("FRAME", self, "UIWidgetBaseControlZoneTemplate");
	self.lastVals = {};
end

function UIWidgetTemplateZoneControlMixin:SetZoneAnchors(zoneFrame, index)
	zoneFrame:ClearAllPoints();
	if index == 1 then
		zoneFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
	elseif index == 2 then
		zoneFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 150, 0);
	elseif index == 3 then
		zoneFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 75, -100);
	elseif index == 4 then
		zoneFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 75, -30);
	end
end

function UIWidgetTemplateZoneControlMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	SetupTextureKitOnFrame(widgetInfo.textureKit, self.Background, "%s-lines", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	self.entryPool:ReleaseAll();

	for index, zoneInfo in ipairs(widgetInfo.zoneEntries) do
		local entryFrame = self.entryPool:Acquire();
		entryFrame:Show();
		local lastVals = (self.lastVals[index] and (self.lastVals[index].state == zoneInfo.state)) and self.lastVals[index] or nil;
		entryFrame:Setup(widgetContainer, index, widgetInfo.mode, widgetInfo.leadingEdgeType, widgetInfo.dangerFlashType, zoneInfo, lastVals, widgetInfo.textureKit);
		entryFrame:SetTooltipLocation(widgetInfo.tooltipLoc);
		self:SetZoneAnchors(entryFrame, index);
		self.lastVals[index] = zoneInfo;
	end

	if #widgetInfo.zoneEntries == 0 then
		self:Hide();
		return;
	else
		self:Layout();
	end
end

function UIWidgetTemplateZoneControlMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.entryPool:ReleaseAll();
end
