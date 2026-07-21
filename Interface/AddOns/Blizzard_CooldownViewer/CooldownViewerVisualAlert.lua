CooldownViewerVisualAlertMixin = {};

function CooldownViewerVisualAlertMixin:SetAlertTarget(target)
	-- override as necessary, but continue calling base
	local currentTarget = self:GetAlertTarget();
	assertsafe(currentTarget == nil, "CooldownViewerVisualAlert: Attempting to set alert target when one is already set");
	if currentTarget then
		self:ClearAlertTarget();
	end

	-- The target must implement the CooldownViewerVisualAlertTargetMixin API, but can track the region that the alert anchors/parents to separately.
	self.alertTarget = target;
	self:SetParent(self:GetAlertTargetFrame());
	self:AnchorAlert();
	target:AddAlert(self);
	self:Show();
end

function CooldownViewerVisualAlertMixin:GetAlertTarget()
	return self.alertTarget;
end

function CooldownViewerVisualAlertMixin:GetAlertTargetFrame()
	local target = self:GetAlertTarget();
	return target and target:GetAlertTargetFrame();
end

function CooldownViewerVisualAlertMixin:ClearAlertTarget()
	-- override as necessary, but continue calling base
	local currentTarget = self:GetAlertTarget();
	assertsafe(currentTarget ~= nil, "CooldownViewerVisualAlert: Attempt to clear alert target when none is set");
	if currentTarget then
		currentTarget:RemoveAlert(self);
	end

	self.alertTarget = nil;
	self:SetParent(nil);
end

function CooldownViewerVisualAlertMixin:GetAnchors()
	-- Override as necessary, a nil return value means use SetAllPoints.
	-- When returning anchors created with CreateAnchor, the relativeTo will be updated to be the current target and used to call SetPoint.
	return nil;
end

function CooldownViewerVisualAlertMixin:AnchorAlertInternal(...)
	self:ClearAllPoints();

	local targetRegion = self:GetAlertTargetFrame();
	local anchorCount = select("#", ...);
	local firstAnchorTest = (anchorCount > 0) and select(1, ...);

	if firstAnchorTest then

		for i = 1, anchorCount do
			local anchor = select(i, ...);
			anchor:SetRelativeTo(targetRegion);
			anchor:SetPoint(self);
		end
	else
		self:SetAllPoints(targetRegion);
	end
end

function CooldownViewerVisualAlertMixin:AnchorAlert()
	-- override as necessary
	self:AnchorAlertInternal(self:GetAnchors());
end

function CooldownViewerVisualAlertMixin:GetPriority()
	return self.alertPriority or 0;
end

-- This only serves to allow a stable sort for alerts.
local alertIDCounter = 0;
function CooldownViewerVisualAlertMixin:GetAlertID()
	if self.alertID then
		return self.alertID;
	else
		alertIDCounter = alertIDCounter + 1;
		self.alertID = alertIDCounter;
		return self.alertID;
	end
end
