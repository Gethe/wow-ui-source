UIWidgetBelowMinimapContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	local widgetsHeight = 0;

	for index, widgetFrame in ipairs(sortedWidgets) do
		if ( index == 1 ) then
			widgetFrame:SetPoint("TOPRIGHT");
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOPRIGHT", relative, "BOTTOMRIGHT", 0, -4);
		end

		widgetsHeight = widgetsHeight + widgetFrame:GetHeight();
	end

	widgetContainer:SetHeight(widgetsHeight);
	UIParent_ManageFramePositions();
end

function UIWidgetBelowMinimapContainerMixin:OnLoad()
	local setID = C_UIWidgetManager.GetBelowMinimapWidgetSetID();
	UIWidgetManager:RegisterWidgetSetContainer(setID, self, WidgetsLayout);
end
