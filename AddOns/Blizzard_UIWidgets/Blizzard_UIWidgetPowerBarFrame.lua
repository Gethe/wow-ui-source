UIWidgetPowerBarContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	-- Temp: Make a bigger capture bar
	for index, widgetFrame in ipairs(sortedWidgets) do
		widgetFrame:SetScale(1.5);
	end

	DefaultWidgetLayout(widgetContainer, sortedWidgets);
	UIParent_ManageFramePositions();
end

function UIWidgetPowerBarContainerMixin:OnLoad()
	UIWidgetContainerMixin.OnLoad(self);
	local setID = C_UIWidgetManager.GetPowerBarWidgetSetID();
	self:RegisterForWidgetSet(setID, WidgetsLayout);
end
