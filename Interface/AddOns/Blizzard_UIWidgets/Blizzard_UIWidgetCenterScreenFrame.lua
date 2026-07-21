UIWidgetCenterScreenContainerMixin = {}

local centerScreenSetID = 676;
function UIWidgetCenterScreenContainerMixin:Layout()
	-- Keep the size of the widget container the same because it's centered
end

function UIWidgetCenterScreenContainerMixin:OnLoad()
	UIWidgetContainerMixin.OnLoad(self);
	self:RegisterForWidgetSet(centerScreenSetID);
end