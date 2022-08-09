UIWidgetPowerBarContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	DefaultWidgetLayout(widgetContainer, sortedWidgets);

	EncounterBar:Layout();
	if EncounterBar:IsInDefaultPosition() then
		UIParent_ManageFramePositions();
	end
end

function UIWidgetPowerBarContainerMixin:OnLoad()
	UIWidgetContainerMixin.OnLoad(self);
	local setID = C_UIWidgetManager.GetPowerBarWidgetSetID();
	self:RegisterForWidgetSet(setID, WidgetsLayout);
end