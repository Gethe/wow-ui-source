UIWidgetSubZoneTextContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	DefaultWidgetLayout(widgetContainer, sortedWidgets);
	ManageFramePositions();
end

function UIWidgetSubZoneTextContainerMixin:OnLoad()
	UIWidgetContainerMixin.OnLoad(self);
	self:RegisterForWidgetSet(563, WidgetsLayout);
end
