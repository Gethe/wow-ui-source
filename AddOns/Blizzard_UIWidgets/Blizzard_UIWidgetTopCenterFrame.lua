UIWidgetTopCenterContainerMixin = {}

function UIWidgetTopCenterContainerMixin:OnLoad()
	UIWidgetContainerMixin.OnLoad(self);
	local setID = C_UIWidgetManager.GetTopCenterWidgetSetID();
	self:RegisterForWidgetSet(setID);
end
