UIWidgetTopCenterContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	-- Need to keep this at least height 1 because other frames anchor to it and trying to anchor to a frame of height 0 is undefined.
	local widgetsHeight = 1;

	local maxIconWidgetWidth = 0;
	local iconAndTextWidgets = {};

	for index, widgetFrame in ipairs(sortedWidgets) do
		local xOffset = 0;

		if widgetFrame.widgetType == Enum.UIWidgetVisualizationType.IconAndText then
			if not widgetFrame.Icon:IsShown() then
				-- Because the icon does not span the entirety of its atlas tile, use magic number to offset the UI element.
				local iconEmptySpaceWidthOffset = -12;

				-- Align all text elements in the vertical layout, even for entries with no icon.
				xOffset = widgetFrame.Icon:GetWidth() + iconEmptySpaceWidthOffset;
			end

			-- Cache the largest icon widget width so it can be used to size all of the icon widgets.
			if widgetFrame.alignWidth > maxIconWidgetWidth then
				maxIconWidgetWidth = widgetFrame.alignWidth;
			end

			table.insert(iconAndTextWidgets, widgetFrame);
		end

		-- Stack the widgets and center them on their container.
		if ( index == 1 ) then
			widgetFrame:SetPoint("TOP", widgetContainer, "TOP", xOffset, 0);
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOP", relative, "BOTTOM", xOffset, 0);
		end

		widgetsHeight = widgetsHeight + widgetFrame:GetHeight();
	end
	widgetContainer:SetHeight(widgetsHeight);

	-- Set width of all icon widgets equal to the width of the largest. Keeps them visually aligned.
	for index, widgetFrame in ipairs(iconAndTextWidgets) do
		widgetFrame:SetWidth(maxIconWidgetWidth);
	end
end

function UIWidgetTopCenterContainerMixin:OnLoad()
	local setID = C_UIWidgetManager.GetTopCenterWidgetSetID();
	UIWidgetManager:RegisterWidgetSetContainer(setID, self, WidgetsLayout);
end

function UIWidgetTopCenterContainerMixin:SetSpectatorMode(spectatorMode, relativeFrame)
	if (spectatorMode) then
		if (relativeFrame) then
			self:SetPoint("TOP", relativeFrame, "BOTTOM", 0, 0);
		end
		self:SetScale(1.5);
	else
		self:SetPoint("TOP", 0, -15);
		self:SetScale(1.0);
	end
end