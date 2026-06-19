-- The Blizzard_VisualAlerts addon provides a system for displaying animated overlay alerts on UI frames.
-- A VisualAlert is an individual animated alert frame that anchors and parents itself to a
-- VisualAlertTarget, which is any frame that includes VisualAlertTargetMixin to host and priority-sort
-- multiple concurrent alerts.
-- The VisualAlertsManager pools alert frames by type (acquiring and releasing them on demand), while
-- VisualAlertTemplates defines the concrete visual styles (e.g. MarchingAnts, Flash, and color variants)
-- and registers them with the manager.

VisualAlertMixin = {};

function VisualAlertMixin:SetAlertTarget(target)
	-- override as necessary, but continue calling base
	local currentTarget = self:GetAlertTarget();
	assertsafe(currentTarget == nil, "VisualAlert: Attempting to set alert target when one is already set");
	if currentTarget then
		self:ClearAlertTarget();
	end

	-- The target must implement the VisualAlertTargetMixin API, but can track the region that the alert anchors/parents to separately.
	self.alertTarget = target;
	self:SetParent(self:GetAlertTargetFrame());
	self:AnchorAlert();
	self:GetAlertID();
	target:AddAlert(self);
	self:Show();
end

function VisualAlertMixin:GetAlertTarget()
	return self.alertTarget;
end

function VisualAlertMixin:GetAlertTargetFrame()
	local target = self:GetAlertTarget();
	return target and target:GetAlertTargetFrame();
end

function VisualAlertMixin:ClearAlertTarget()
	-- override as necessary, but continue calling base
	local currentTarget = self:GetAlertTarget();
	assertsafe(currentTarget ~= nil, "VisualAlert: Attempt to clear alert target when none is set");
	if currentTarget then
		currentTarget:RemoveAlert(self);
	end

	self.alertTarget = nil;
	self.alertID = nil;
	self:SetParent(nil);
end

function VisualAlertMixin:GetAnchors()
	-- Override as necessary, a nil return value means use SetAllPoints.
	-- When returning anchors created with CreateAnchor, the relativeTo will be updated to be the current target and used to call SetPoint.
	return nil;
end

function VisualAlertMixin:AnchorAlertInternal(...)
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

function VisualAlertMixin:AnchorAlert()
	-- override as necessary
	self:AnchorAlertInternal(self:GetAnchors());
end

function VisualAlertMixin:GetPriority()
	return self.alertPriority or 0;
end

-- This only serves to allow a stable sort for alerts.
local alertIDCounter = 0;
function VisualAlertMixin:GetAlertID()
	if self.alertID then
		return self.alertID;
	else
		alertIDCounter = alertIDCounter + 1;
		self.alertID = alertIDCounter;
		return self.alertID;
	end
end
