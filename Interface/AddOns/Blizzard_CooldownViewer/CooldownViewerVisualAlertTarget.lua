CooldownViewerVisualAlertTargetMixin = CreateFromMixins(VisualAlertTargetMixin);

local function AnchorAlertTypeIcons(overlay)
	local firstAlertIcon = overlay.visibleIcons[1];
	if not firstAlertIcon then
		return;
	end

	local iconWidth = firstAlertIcon:GetWidth();
	local totalIconsWidth = (#overlay.visibleIcons * iconWidth) + ((#overlay.visibleIcons - 1) * 2);
	local overlayWidth = overlay:GetWidth();
	local firstIconOffset = (overlayWidth - totalIconsWidth) / 2;

	local anchor = CreateAnchor("LEFT", overlay, "LEFT", firstIconOffset, 0);
	local clearAllPoints = true;

	for _index, icon in ipairs(overlay.visibleIcons) do
		anchor:SetPoint(icon, clearAllPoints);
		anchor:Set("LEFT", icon, "RIGHT", 2, 0);
	end
end

local function AddAlertTypeIcon(index, alertType, overlay)
	local asset = CooldownViewerAlert_GetTypeAtlas(alertType);
	if asset then
		local icon = overlay.icons[index];
		if not icon then
			icon = overlay:CreateTexture(nil, "ARTWORK");
			local size = overlay:GetHeight() - 2;
			icon:SetSize(size, size);

			overlay.icons[index] = icon;
		end

		icon:SetAtlas(asset);
		icon:Show();

		table.insert(overlay.visibleIcons, icon);
	end
end

local function HideAlertTypeIcons(overlay)
	for _, icon in ipairs(overlay.icons) do
		icon:Hide();
	end

	overlay.visibleIcons = {};
end

function CooldownViewerVisualAlertTargetMixin:GetAllAlertTypes()
	-- override as necessary
end

function CooldownViewerVisualAlertTargetMixin:CheckCreateAlertOverlay()
	if not self.AlertTypesOverlay then
		local overlay = CreateFrame("Frame", nil, self);
		overlay:SetPoint("BOTTOM", self.Icon, "BOTTOM", 0, 2);
		overlay:SetSize(34, 14);

		overlay.BG = overlay:CreateTexture(nil, "BACKGROUND");
		overlay.BG:SetAllPoints(overlay);
		overlay.BG:SetColorTexture(0, 0, 0, 0.7);

		overlay.icons = {};

		overlay:SetScript("OnHide", function()
			local alertContainer = self:GetAlertContainer();
			if alertContainer then
				for i = #alertContainer, 1, -1 do
					local alert = alertContainer[i];
					if alert:GetAlertTarget() then
						VisualAlertsManager:ReleaseAlert(alert);
					else
						table.remove(alertContainer, i);
					end
				end
			end
		end);

		self.AlertTypesOverlay = overlay;
	end
end

function CooldownViewerVisualAlertTargetMixin:RefreshAlertTypeOverlay()
	local alertTypes = self:GetAllAlertTypes();
	if alertTypes then
		self:CheckCreateAlertOverlay();

		HideAlertTypeIcons(self.AlertTypesOverlay);

		for index, alertType in ipairs(alertTypes) do
			AddAlertTypeIcon(index, alertType, self.AlertTypesOverlay);
		end

		AnchorAlertTypeIcons(self.AlertTypesOverlay);

		self.AlertTypesOverlay:Show();
	elseif self.AlertTypesOverlay then
		self.AlertTypesOverlay:Hide();
	end
end
