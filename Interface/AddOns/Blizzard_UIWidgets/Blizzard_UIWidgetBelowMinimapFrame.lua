UIWidgetBelowMinimapContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	DefaultWidgetLayout(widgetContainer, sortedWidgets);
	UIParent_ManageFramePositions();
end

function UIWidgetBelowMinimapContainerMixin:OnLoad()
	UIWidgetContainerMixin.OnLoad(self);
	local setID = C_UIWidgetManager.GetBelowMinimapWidgetSetID();
	self:RegisterForWidgetSet(setID, WidgetsLayout);
end
