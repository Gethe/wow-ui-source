UIWidgetBelowMinimapContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	for index, widgetFrame in ipairs(sortedWidgets) do
		if ( index == 1 ) then
			widgetFrame:SetPoint("TOPRIGHT");
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOPRIGHT", relative, "BOTTOMRIGHT", 0, -4);
		end
	end
end

function UIWidgetBelowMinimapContainerMixin:OnLoad()
	local setID = C_UIWidgetManager.GetBelowMinimapWidgetSetID();
	UIWidgetManager:RegisterWidgetSetContainer(setID, self, WidgetsLayout);
end
