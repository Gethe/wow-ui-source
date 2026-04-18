CooldownViewerVisualAlertTargetMixin = {};

function CooldownViewerVisualAlertTargetMixin:GetOrCreateAlertContainer()
	local container = GetOrCreateTableEntry(self, "alertContainer");
	return container;
end

function CooldownViewerVisualAlertTargetMixin:GetAlertContainer()
	return self.alertContainer;
end

function CooldownViewerVisualAlertTargetMixin:GetAlertTargetFrame()
	-- override as necessary
	return self;
end

function CooldownViewerVisualAlertTargetMixin:AddAlert(alert)
	local container = self:GetOrCreateAlertContainer();
	table.insert(container, alert);
	self:UpdateAlerts();
end

function CooldownViewerVisualAlertTargetMixin:RemoveAlert(alert)
	local container = self:GetAlertContainer();
	if container then
		if tDeleteItem(container, alert) > 0 then
			self:UpdateAlerts();
		end
	end
end

function CooldownViewerVisualAlertTargetMixin:UpdateAlerts()
	local container = self:GetAlertContainer();
	if container then
		table.sort(container, self:GetAlertSortFunction());

		local currentLevel = self:GetFrameLevel();

		for index, alert in ipairs(container) do
			alert:SetFrameLevel(currentLevel + index);
		end
	end
end

local function SortAlertsDefault(alertA, alertB)
	local priorityA = alertA:GetPriority();
	local priorityB = alertB:GetPriority();
	if priorityA ~= priorityB then
		return priorityA < priorityB;
	end

	return alertA:GetAlertID() < alertB:GetAlertID();
end

function CooldownViewerVisualAlertTargetMixin:GetAlertSortFunction()
	-- override as necessary
	return SortAlertsDefault;
end
