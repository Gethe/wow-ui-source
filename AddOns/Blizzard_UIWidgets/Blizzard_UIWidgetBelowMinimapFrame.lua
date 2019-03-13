UIWidgetBelowMinimapContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	local widgetsHeight = 0;
	local maxWidgetWidth = 0;

	for index, widgetFrame in ipairs(sortedWidgets) do
		if ( index == 1 ) then
			widgetFrame:SetPoint("TOPRIGHT", widgetContainer, "TOPRIGHT", 0, 0);
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOPRIGHT", relative, "BOTTOMRIGHT", 0, -4);
		end

		widgetsHeight = widgetsHeight + widgetFrame:GetHeight();

		local widgetWidth = widgetFrame:GetWidth();
		if widgetWidth > maxWidgetWidth then
			maxWidgetWidth = widgetWidth;
		end
	end

	widgetContainer:SetHeight(math.max(widgetsHeight, 1));
	widgetContainer:SetWidth(math.max(maxWidgetWidth, 1));
	UIParent_ManageFramePositions();
end

function UIWidgetBelowMinimapContainerMixin:OnLoad()
	UIWidgetContainerMixin.OnLoad(self);
	local setID = C_UIWidgetManager.GetBelowMinimapWidgetSetID();
	self:RegisterForWidgetSet(setID, WidgetsLayout);
end
