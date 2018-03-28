UIWidgetTopCenterContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	local widgetsHeight = 0;

	local maxIconWidgetWidth = 0;
	local iconAndTextWidgets = {};

	for index, widgetFrame in ipairs(sortedWidgets) do
		if widgetFrame.widgetType == Enum.UIWidgetVisualizationType.IconAndText then
			if widgetFrame.Icon:IsShown() and widgetFrame.alignWidth > maxIconWidgetWidth then
				maxIconWidgetWidth = widgetFrame.alignWidth;
			end

			table.insert(iconAndTextWidgets, widgetFrame);
		end

		if ( index == 1 ) then
			widgetFrame:SetPoint("TOP");
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOP", relative, "BOTTOM");
		end

		widgetsHeight = widgetsHeight + widgetFrame:GetHeight();
	end

	-- Align all the icons for iconAndTextWidgets with the widest icon widget
	if maxIconWidgetWidth > 0 then
		for index, widgetFrame in ipairs(iconAndTextWidgets) do
			local offsetX = -(maxIconWidgetWidth - widgetFrame.alignWidth) / 2;

			if not widgetFrame.Icon:IsShown() then
				offsetX = offsetX + widgetFrame.Icon:GetWidth() - 12;
			end

			widgetFrame.Icon:ClearAllPoints();
			widgetFrame.Icon:SetPoint("TOPLEFT", widgetFrame, "TOPLEFT", offsetX, 0);
		end
	end

	widgetContainer:SetHeight(widgetsHeight);
end

function UIWidgetTopCenterContainerMixin:OnLoad()
	local setID = C_UIWidgetManager.GetTopCenterWidgetSetID();
	UIWidgetManager:RegisterWidgetSetContainer(setID, self, WidgetsLayout);
end
