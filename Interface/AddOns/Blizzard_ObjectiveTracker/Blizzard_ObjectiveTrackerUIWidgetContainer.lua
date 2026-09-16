local settings = {
	headerText = TRACKER_HEADER_SCENARIO,
	events = { "ZONE_CHANGED_NEW_AREA" },
	fromHeaderOffsetY = -9,
};

UIWidgetObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

function UIWidgetObjectiveTrackerMixin:OnEvent()
	self:SetHeader(GetRealZoneText());
end

function UIWidgetObjectiveTrackerMixin:LayoutContents()
	-- We only ever use a single block for the widget container
	local block = self.Block;

	-- We add or remove the block based on whether there are any widgets showing
	local hasWidgets = ObjectiveTrackerUIWidgetContainer:GetNumWidgetsShowing() > 0;
	local blockAdded = false;
	if hasWidgets then
		-- If there are widgets showing, add the block
		block.height = ObjectiveTrackerUIWidgetContainer:GetHeight();
		blockAdded = self:LayoutBlock(block);
	end

	if blockAdded then
		-- This means there ARE widgets showing...attach the widget container to the new block and "show" it (alpha to 1)
		self:SetHeader(GetRealZoneText());
		ObjectiveTrackerUIWidgetContainer:AttachToBlockAndShow(block);
		block:Show();
		block:MarkDirty();
	else
		-- This means there are no widgets showing or we could not add the block...unattach the widget container and "hide" it (alpha to 0 so we still get updates on it)
		ObjectiveTrackerUIWidgetContainer:UnattachFromBlockAndHide();
	end
end

ObjectiveTrackerUIWidgetContainerMixin = {};

local function WidgetsLayout(widgetContainer, sortedWidgets)
	DefaultWidgetLayout(widgetContainer, sortedWidgets);

	-- When the widgets in this container update we also need to update the UI_WIDGET_TRACKER_MODULE (it needs to show or hide based on whether there are any widget showing)
	UIWidgetObjectiveTracker:MarkDirty();
end

function ObjectiveTrackerUIWidgetContainerMixin:OnLoad()
	UIWidgetContainerMixin.OnLoad(self);
	local setID = C_UIWidgetManager.GetObjectiveTrackerWidgetSetID();
	self:RegisterForWidgetSet(setID, WidgetsLayout);
end

-- SetParent to block, anchor and set alpha to 1
function ObjectiveTrackerUIWidgetContainerMixin:AttachToBlockAndShow(block)
	self:SetParent(block);
	self:SetPoint("TOP", block, "TOP", 0, 0);
	self:SetAlpha(1);	-- Use alpha for showing and hiding the widget container because we still need to get updates when it is hidden (so we can add the block and re-parent again)
end

-- SetParent to UIParent and set alpha to 0. This is so we continue to get updates when widgets are shown, allowing us to add the tracker block again
function ObjectiveTrackerUIWidgetContainerMixin:UnattachFromBlockAndHide()
	self:SetAlpha(0);
	self:SetParent(UIParent);
end