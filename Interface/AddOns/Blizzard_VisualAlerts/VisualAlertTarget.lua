-- Any frame that can display a visual alert needs to include this mixin.
VisualAlertTargetMixin = {};

function VisualAlertTargetMixin:GetOrCreateAlertContainer()
	local container = GetOrCreateTableEntry(self, "alertContainer");
	return container;
end

function VisualAlertTargetMixin:GetAlertContainer()
	return self.alertContainer;
end

function VisualAlertTargetMixin:GetAlertTargetFrame()
	-- override as necessary, used as the parent of the frame displaying the visual alert.
	return self;
end

function VisualAlertTargetMixin:AddAlert(alert)
	local container = self:GetOrCreateAlertContainer();
	table.insert(container, alert);
	self:UpdateAlerts();
end

function VisualAlertTargetMixin:RemoveAlert(alert)
	local container = self:GetAlertContainer();
	if container then
		if tDeleteItem(container, alert) > 0 then
			self:UpdateAlerts();
		end
	end
end

function VisualAlertTargetMixin:UpdateAlerts()
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

function VisualAlertTargetMixin:GetAlertSortFunction()
	-- override as necessary
	return SortAlertsDefault;
end
