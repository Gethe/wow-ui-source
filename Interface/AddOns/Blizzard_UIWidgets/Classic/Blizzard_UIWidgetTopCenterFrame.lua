UIWidgetTopCenterContainerMixin = {}

local function WidgetsLayout(widgetContainer, sortedWidgets)
	-- Need to keep this at least height 1 because other frames anchor to it and trying to anchor to a frame of height 0 is undefined.
	local widgetsHeight = 1;

	for index, widgetFrame in ipairs(sortedWidgets) do
		-- Stack the widgets and center them on their container.
		if ( index == 1 ) then
			widgetFrame:SetPoint("TOP", widgetContainer, "TOP", 0, 0);
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOP", relative, "BOTTOM", 0, 0);
		end

		widgetsHeight = widgetsHeight + widgetFrame:GetHeight();
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
			self:SetPoint("TOP", relativeFrame, "BOTTOM", 0, 0);
		end
		self:SetScale(1.5);
	else
		self:SetPoint("TOP", 0, -15);
		self:SetScale(1.0);
	end
end
