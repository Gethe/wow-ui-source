local function GetItemDisplayVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetItemDisplayVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.ItemDisplay, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateItemDisplay"}, GetItemDisplayVisInfoData);

UIWidgetTemplateItemDisplayMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateItemDisplayMixin:Setup(widgetInfo, widgetContainer)
	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end

	self.continuableContainer = ContinuableContainer:Create();

	self:SetSize(1, 1);

	local item = Item:CreateFromItemID(widgetInfo.itemInfo.itemID);
	self.continuableContainer:AddContinuable(item);

	self.continuableContainer:ContinueOnLoad(function()
		UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

		self.Item:Setup(widgetContainer, widgetInfo.itemInfo, widgetInfo.widgetSizeSetting);
		self.Item:SetTooltipLocation(widgetInfo.tooltipLoc);

		self:SetWidth(self.Item:GetWidth());
		self:SetHeight(self.Item:GetHeight());
		widgetContainer:MarkDirtyLayout();
	end);
end

function UIWidgetTemplateItemDisplayMixin:OnReset()
	self.Item:OnReset();
	UIWidgetBaseTemplateMixin.OnReset(self);
	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end
end