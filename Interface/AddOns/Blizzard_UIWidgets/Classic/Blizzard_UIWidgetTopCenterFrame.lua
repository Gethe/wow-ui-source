UIWidgetTopCenterContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	-- Need to keep this at least width/height 1 because other frames anchor to it and trying to anchor to a frame of height 0 is undefined.
	local widgetsHeight = 1;
	local maxIconWidgetWidth = 1;

	for index, widgetFrame in ipairs(sortedWidgets) do
		if widgetFrame.widgetType == Enum.UIWidgetVisualizationType.IconAndText then
			-- Align the widgets to the left of the container.
			local xOffset = 0;
			if not widgetFrame.Icon:IsShown() then
				-- Because the icon does not span the entirety of its atlas tile, use magic number to offset the UI element.
				local iconEmptySpaceWidthOffset = -12;

				-- Align all text elements in the vertical layout, even for entries with no icon.
				xOffset = widgetFrame.Icon:GetWidth() + iconEmptySpaceWidthOffset;
			end
			widgetFrame:SetPoint("LEFT", widgetContainer, "LEFT", xOffset, 0);

			-- Cache the largest icon widget width so it can be used to size the container and keep all rows visually centered.
			if widgetFrame.alignWidth > maxIconWidgetWidth then
				maxIconWidgetWidth = widgetFrame.alignWidth;
			end
		end

		-- Stack the widgets.
		if (index == 1) then
			widgetFrame:SetPoint("TOP", widgetContainer, "TOP");
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOP", relative, "BOTTOM");
		end

		widgetsHeight = widgetsHeight + widgetFrame:GetHeight();
	end

	-- Size the container to its contents. This results in left-aligned rows appearing centered in the container.
	widgetContainer:SetWidth(maxIconWidgetWidth);
	widgetContainer:SetHeight(widgetsHeight);
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