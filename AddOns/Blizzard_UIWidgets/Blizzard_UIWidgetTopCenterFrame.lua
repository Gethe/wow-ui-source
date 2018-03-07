UIWidgetTopCenterContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	for index, widgetFrame in ipairs(sortedWidgets) do
		if ( index == 1 ) then
			widgetFrame:SetPoint("TOP");
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOP", relative, "BOTTOM");
		end
	end
end

function UIWidgetTopCenterContainerMixin:OnLoad()
	local setID = C_UIWidgetManager.GetTopCenterWidgetSetID();
	UIWidgetManager:RegisterWidgetSetContainer(setID, self, WidgetsLayout);
end
