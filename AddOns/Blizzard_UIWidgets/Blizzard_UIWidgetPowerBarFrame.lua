UIWidgetPowerBarContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	DefaultWidgetLayout(widgetContainer, sortedWidgets);
	UIParent_ManageFramePositions();
end

function UIWidgetPowerBarContainerMixin:OnLoad()
	UIWidgetContainerMixin.OnLoad(self);
	local setID = C_UIWidgetManager.GetPowerBarWidgetSetID();
	self:RegisterForWidgetSet(setID, WidgetsLayout);
end
