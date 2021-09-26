UIWidgetTopCenterContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	local widgetsHeight = 1; --Need to keep this at least height 1 because other frames anchor to it and trying to anchor to a frame of height 0 is undefined

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
			widgetFrame:SetPoint("TOP", widgetContainer, "TOP", 0, 0);
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOP", relative, "BOTTOM", 0, 0);
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

function UIWidgetTopCenterContainerMixin:SetSpectatorMode(spectatorMode, relativeFrame)
	if (spectatorMode) then
		if (relativeFrame) then
			self:SetPoint("TOP", relativeFrame, "BOTTOM", 0, -5);
		end
		self:SetScale(1.5);
	else
		self:SetPoint("TOP", 0, -15);
		self:SetScale(1.0);
	end
end